# AGENTS.md

Claude Code と Codex 共通のプロジェクト指示です。作業時は `~/.codex/AGENTS.md` とリポジトリ直下の本ファイルを両方確認してください。Claude Code は `~/.claude/CLAUDE.md` から共通指示を読み込みます。

## プロジェクト概要

このリポジトリは技術ブログ記事の管理用リポジトリです。ZennとQiitaの両方に記事を公開しており、[zenn-qiita-sync](https://github.com/C-Naoki/zenn-qiita-sync)を使用してZenn記事とQiita記事を自動同期しています。

## ディレクトリ構成

- `articles/`: Zenn記事（Markdown形式）
- `qiita/public/`: Qiita記事（同期によって自動生成される）
- `books/`: Zennの本
- `images/`: 記事や本で使用する画像
- `.github/workflows/`: GitHub Actionsワークフロー

## 開発コマンド

### プレビューサーバーの起動

```bash
npx zenn preview
```

プレビューは http://localhost:8000 で確認できます。

### 新規記事の作成

```bash
npx zenn new:article --slug 記事のスラッグ --title タイトル --type tech --emoji ✨
```

- `--slug`: 記事のスラッグ（a-z0-9、ハイフン、アンダースコアの組み合わせ、12〜50文字）
- `--title`: 記事のタイトル
- `--type`: `tech` または `idea`
- `--emoji`: 記事の絵文字

## CI/CD

### 自動同期ワークフロー

main/masterブランチへのpush時に、GitHub Actionsが以下を自動実行します：

1. Zenn記事をQiita記事に変換（コミットメッセージ: `🔄 auto: synchronize qiita articles`）
2. Qiita CLIでの更新（コミットメッセージ: `🔄 auto: update using qiita-cli`）

このワークフローには`QIITA_TOKEN`シークレットが必要です。

## 記事の管理

- 記事の編集は`articles/`ディレクトリ内のMarkdownファイルを直接編集
- `qiita/`ディレクトリ内のファイルは自動生成されるため、手動編集しない
- 記事のフォーマットはZennの仕様に従う（frontmatterにtitle、emoji、type、topics、publishedを含む）

## 記事生成と人間の推敲履歴

- 記事を生成する前に [writing/README.md](writing/README.md) と `writing/pairs/` の `usableForGeneration: true` のペアを読み、変更前後の原文を比較する。参考にするのは文章や構成の修正であり、記事内容や古い技術条件は転用しない。未確認のスタイル規則を本人の好みとして断定しない。
- `articles/` を記事の正本とし、`writing/snapshots/` と `writing/index.json` は `node scripts/export-writing-history.mjs` で生成する。未コミットの記事は抽出しない。
- AI初稿は人間の修正前にコミットし、メッセージに `writing: AI初稿 <記事ID>` とAI関与のCo-Authored-Byを記載する。
- 人間が編集中の原稿を勝手に整形・巻き戻ししない。本人の確定確認後に `writing: 人間修正確定 <記事ID>` としてコミットし、抽出後に `writing/pairs/` へcommit・path・根拠・確定確認の有無・生成での利用可否を登録する。AIが途中で修正した区間はその事実を残す。
- Gitの作者名だけで執筆主体を判定しない。Co-Authored-ByはAI関与の根拠として扱う。自動同期・frontmatterのみの変更・取り込み・主体不明の修正を人間の推敲教材にしない。初回Git版と執筆初稿を区別する。
- コミット前に `node --check scripts/export-writing-history.mjs` と抽出を実行し、再実行で生成結果が変わらないことを確認する。
