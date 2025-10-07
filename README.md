# tech-blog-archive

![](https://github.com/C-Naoki/zenn-archive/actions/workflows/publish.yml/badge.svg)

技術ブログ記事を管理するためのリポジトリです。[Zenn](https://zenn.dev/)と[Qiita](https://qiita.com/)の両方で記事を公開しています。主に自分が作成したコードを共有し、学んだことを記録する場所として利用しています。[zenn-qiita-sync](https://github.com/C-Naoki/zenn-qiita-sync)を使用して、Zenn 記事と Qiita 記事を自動同期しています。

## ディレクトリ構成

- `.github/workflows/`: GitHub Actions のワークフローファイル
- `articles/`: Zenn 記事（Markdown 形式）
- `books/`: Zenn の本
- `images/`: 記事や本で使用する画像
- `qiita/`: Qiita 記事（Zenn 記事から自動生成される）
- `scripts/`: 変換スクリプト

## 開発方法

### Zenn 記事のプレビュー

プレビューサーバーを起動：

```bash
npx zenn preview
```

- ブラウザで [http://localhost:8000](http://localhost:8000) を開くとプレビューが確認できます

### Qiita 記事のプレビュー

プレビューサーバーを起動：

```bash
cd qiita
npx qiita preview
```

- ブラウザで [http://localhost:8888](http://localhost:8888) を開くとプレビューが確認できます

### 新規記事の作成

```bash
npx zenn new:article --slug 記事のスラッグ --title タイトル --type tech --emoji ✨
```

オプション：

- `--slug`: 記事のスラッグ（a-z0-9、ハイフン、アンダースコアの組み合わせ、12〜50 文字）
- `--title`: 記事のタイトル
- `--type`: `tech` または `idea`
- `--emoji`: 記事の絵文字

## 自動同期について

main/master ブランチへの push 時に、GitHub Actions が以下を自動実行します：

1. Zenn 記事を Qiita 記事に変換（コミットメッセージ: `🔄 auto: synchronize qiita articles`）
2. Qiita CLI での更新（コミットメッセージ: `🔄 auto: update using qiita-cli`）

※ 自動同期には`QIITA_TOKEN`シークレットの設定が必要です

## 記事IDの仕組み

### Zenn記事のID

Zenn記事のIDはファイル名で決まります。`articles/`ディレクトリ内のファイル名が記事のslugとして使用されます。

例：`articles/2023_02_unity_open_folder_runtime.md` → slug: `2023_02_unity_open_folder_runtime`

### Qiita記事のID

Qiita記事のIDは、記事のfrontmatterにある`id`フィールドで管理されます。このIDはQiitaサーバー側で自動生成され、記事のURLに使用されます。

例：
```yaml
---
title: タイトル
id: e9d326f3bd0462eba897  # Qiitaの記事ID
---
```

記事URL: `https://qiita.com/ユーザー名/items/e9d326f3bd0462eba897`

### 同期時の対応関係

Zenn記事をQiita記事に変換する際、`articles/`と`qiita/public/`で**同じファイル名**を使用して対応付けています。

例：
- `articles/2023_02_unity_open_folder_runtime.md` (Zenn記事)
- `qiita/public/2023_02_unity_open_folder_runtime.md` (Qiita記事)

変換時には、`qiita/public/`に同名ファイルが存在するかどうかで、新規作成か更新かを判定します。

## 注意事項

- 記事の編集は`articles/`ディレクトリ内の Markdown ファイルを直接編集してください
- `qiita/`ディレクトリ内のファイルは自動生成されるため、手動編集しないでください
