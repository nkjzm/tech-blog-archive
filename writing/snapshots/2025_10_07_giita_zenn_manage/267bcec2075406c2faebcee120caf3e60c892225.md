---
title: "Qiitaの記事をZennに移行し、GitHubで同時に管理する"
emoji: "🔄"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["GitHub", "Qiita", "Zenn", "GitHubActions"]
published: true
---

# はじめに

最近 Qiita で執筆していた技術記事を Zenn に移行しました。Qiita も Zenn もそれぞれ GitHub で記事を管理する機能があるので、統合した形になります。

Qiita と Zenn の一括管理については既にやられている方がいるのですが、元々 Qiita で記事を書いていた場合の移行方法についてはあまり情報がなかったので紹介したいと思います。

# 前提知識

- Zenn の GitHub 連携
  - Zenn の Web ページ上から GitHub リポジトリを連携させることができる
  - 特定のフォーマットで.md ファイルを配置することで記事の公開や更新ができる
- Qiita の GitHub 連携
  - Qiita CLI を使う
  - .md ファイルの push 時に GitHub Actions を発火させ、Qiita CLI を実行することで記事の公開や更新ができる

# 概要

今回は [C-Naoki/zenn-qiita-sync](https://github.com/C-Naoki/zenn-qiita-sync)で記事の一括管理をすることにしました。

https://github.com/C-Naoki/zenn-qiita-sync

導入については作者の方が詳しく解説されています。

https://zenn.dev/naoki0103/articles/zenn-qiita-sync-workflow

このリポジトリでは Zenn 用のマークダウンがマスターファイルとなり、push 時に Qiita 用のマークダウンが自動生成される仕組みになっています。そのため、今回のケースではまず、Qiita 用のマークダウンを Zenn 用に変換する必要がありました。
