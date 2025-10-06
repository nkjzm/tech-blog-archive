# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
