---
title: "Qiitaの記事をZennに移行し、GitHubで同時に管理する"
emoji: "🔄"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["GitHub", "Qiita", "Zenn", "GitHubActions"]
published: false
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

# 採用したライブラリ

今回は [C-Naoki/zenn-qiita-sync](https://github.com/C-Naoki/zenn-qiita-sync)を使って記事の一括管理をすることにしました。

https://github.com/C-Naoki/zenn-qiita-sync

導入については作者の方が詳しく解説されているので、トークン設定などはこちらを参照ください。

https://zenn.dev/naoki0103/articles/zenn-qiita-sync-workflow

このリポジトリでは Zenn 用のマークダウンがマスターファイルとなり、push 時に Qiita 用のマークダウンが自動生成される仕組みになっています。そのため、今回のケースではまず、Qiita 用のマークダウンを Zenn 用に変換する必要がありました。

# Qiita から Zenn への記事変換

Qiita CLI を使うことで、過去に Qiita に公開済みの記事をマークダウンファイルとしてローカルにダウンロードすることができます。このファイルを Zenn 用に変換していきます。

マークダウン部分についてはほとんど共通なので、Front Matter 部分の変換を行なっていきます。下記は変換前後の例です。

```md:Qiita記事のFront Matter
---
title: GASのコードをGithub管理するChrome拡張が便利
private: false
tags:
  - GitHub
  - GoogleAppsScript
updated_at: "2017-12-29T20:28:47+09:00"
id: d384896d01ac3ff6f91c
organization_url_name: null
slide: false
---
```

```md:Zenn記事のFront Matter
---
title: "GASのコードをGithub管理するChrome拡張が便利"
emoji: "🐙"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["GitHub", "GoogleAppsScript"]
published: true
published_at: 2017-12-29 20:28
---
```

https://zenn.dev/adust/articles/cea61d98ea09d3
https://zenn.dev/sc30gsw/articles/76a821f0e3f944
https://zenn.dev/naoki0103/articles/zenn-qiita-sync-workflow
https://github.com/C-Naoki/zenn-qiita-sync?tab=readme-ov-file
https://nokotaro.hatenablog.com/entry/2025/01/07/160253
