#!/bin/bash

# Qiita記事をZenn形式に変換してarticles/にコピーするスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
QIITA_DIR="$PROJECT_ROOT/qiita/public"
ARTICLES_DIR="$PROJECT_ROOT/articles"
EMOJI_DICT="$SCRIPT_DIR/emoji_dict.txt"

# テストモード: 1ファイルのみ処理する場合は TEST_MODE=1 を設定
TEST_MODE="${TEST_MODE:-0}"
TEST_FILE="${1:-}"

# 絵文字辞書を読み込んで、タイトルから絵文字を選択する関数
get_emoji_from_title() {
    local title="$1"
    local emoji="📄"  # デフォルト

    while IFS=' ' read -r keyword emoji_char || [ -n "$keyword" ]; do
        # コメント行とDEFAULT行をスキップ
        [[ "$keyword" =~ ^#.*$ ]] && continue
        [[ "$keyword" == "DEFAULT" ]] && continue
        [[ -z "$keyword" ]] && continue

        # タイトルにキーワードが含まれているかチェック（大文字小文字を区別しない）
        if echo "$title" | grep -iq "$keyword"; then
            emoji="$emoji_char"
            break
        fi
    done < "$EMOJI_DICT"

    echo "$emoji"
}

# Qiita記事を1ファイル変換する関数
convert_article() {
    local qiita_file="$1"
    local filename="$(basename "$qiita_file")"
    local zenn_file="$ARTICLES_DIR/$filename"

    # すでに存在する場合はスキップ
    if [ -f "$zenn_file" ]; then
        echo "スキップ: $filename (すでに存在)"
        return 0
    fi

    echo "変換中: $filename"

    # ファイルを読み込み、ヘッダーと本文を分離
    local in_header=0
    local header_end_line=0
    local line_num=0

    # ヘッダー終了行を見つける
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        if [ "$line" = "---" ]; then
            if [ $in_header -eq 0 ]; then
                in_header=1
            else
                header_end_line=$line_num
                break
            fi
        fi
    done < "$qiita_file"

    # ヘッダー部分からメタデータを抽出
    local title=""
    local tags=()
    local private_flag="false"
    local updated_at=""

    in_header=0
    line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        if [ "$line" = "---" ]; then
            if [ $in_header -eq 0 ]; then
                in_header=1
                continue
            else
                break
            fi
        fi

        if [ $in_header -eq 1 ]; then
            # title を抽出
            if [[ "$line" =~ ^title:\ (.+)$ ]]; then
                title="${BASH_REMATCH[1]}"
                # 既存の引用符を削除
                title="${title#\"}"
                title="${title%\"}"
                title="${title#\'}"
                title="${title%\'}"
            fi

            # tags を抽出
            if [[ "$line" =~ ^\ \ -\ (.+)$ ]]; then
                tag="${BASH_REMATCH[1]}"
                tags+=("$tag")
            fi

            # private を抽出
            if [[ "$line" =~ ^private:\ (.+)$ ]]; then
                private_flag="${BASH_REMATCH[1]}"
            fi

            # updated_at を抽出
            if [[ "$line" =~ ^updated_at:\ (.+)$ ]]; then
                updated_at="${BASH_REMATCH[1]}"
                # 引用符を削除
                updated_at="${updated_at#\'}"
                updated_at="${updated_at%\'}"
            fi
        fi
    done < "$qiita_file"

    # published を決定 (private: false -> published: true)
    local published="true"
    if [ "$private_flag" = "true" ]; then
        published="false"
    fi

    # 絵文字を選択
    local emoji=$(get_emoji_from_title "$title")

    # topics配列を作成
    local topics_str="["
    for i in "${!tags[@]}"; do
        if [ $i -gt 0 ]; then
            topics_str+=", "
        fi
        topics_str+="\"${tags[$i]}\""
    done
    topics_str+="]"

    # Zennヘッダーを作成
    cat > "$zenn_file" <<EOF
---
title: "$title"
emoji: "$emoji"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: $topics_str
published: $published
---

EOF

    # 本文を追加（ヘッダー以降の部分）
    tail -n +$((header_end_line + 1)) "$qiita_file" >> "$zenn_file"

    echo "✓ 変換完了: $filename"
    echo "  - emoji: $emoji"
    echo "  - topics: $topics_str"
    echo "  - published: $published"
}

# メイン処理
main() {
    echo "=========================================="
    echo "Qiita → Zenn 記事変換スクリプト"
    echo "=========================================="
    echo ""

    # ディレクトリの確認
    if [ ! -d "$QIITA_DIR" ]; then
        echo "エラー: Qiitaディレクトリが見つかりません: $QIITA_DIR"
        exit 1
    fi

    if [ ! -d "$ARTICLES_DIR" ]; then
        mkdir -p "$ARTICLES_DIR"
        echo "作成: $ARTICLES_DIR"
    fi

    if [ ! -f "$EMOJI_DICT" ]; then
        echo "エラー: 絵文字辞書が見つかりません: $EMOJI_DICT"
        exit 1
    fi

    # テストモード: 特定のファイルまたは最初の1ファイルのみ処理
    if [ "$TEST_MODE" = "1" ]; then
        if [ -n "$TEST_FILE" ]; then
            echo "テストモード: $TEST_FILE を処理します"
            convert_article "$QIITA_DIR/$TEST_FILE"
        else
            echo "テストモード: 最初の1ファイルのみ処理します"
            first_file=$(ls "$QIITA_DIR"/*.md | head -1)
            convert_article "$first_file"
        fi
    else
        # 全ファイル処理
        local total=0
        local converted=0
        local skipped=0

        for qiita_file in "$QIITA_DIR"/*.md; do
            total=$((total + 1))

            if convert_article "$qiita_file"; then
                if [ -f "$ARTICLES_DIR/$(basename "$qiita_file")" ]; then
                    # 新規変換かスキップかを判定（メッセージで判別）
                    if grep -q "スキップ" <<< "$(convert_article "$qiita_file" 2>&1)"; then
                        skipped=$((skipped + 1))
                    else
                        converted=$((converted + 1))
                    fi
                fi
            fi
        done

        echo ""
        echo "=========================================="
        echo "変換完了"
        echo "  - 総ファイル数: $total"
        echo "  - 変換済み: $converted"
        echo "  - スキップ: $skipped"
        echo "=========================================="
    fi
}

main "$@"
