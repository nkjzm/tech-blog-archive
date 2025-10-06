---
title: 【初心者向け】Hugo + GitHub Pagesで静的なポートフォリオを作る
private: false
tags:
  - GitHub
updated_at: '2022-02-24T00:32:06+09:00'
id: ab8595f185348de7ba7e
organization_url_name: null
slide: false
---
※ この記事は[自身のブログ記事](http://kohki.hatenablog.jp/entry/hugo-portfolio)を再編したものです。

その後の記事

https://qiita.com/nkjzm/items/ebb078ec452a15a37bf8

## はじめに

知り合いがResume(職務経歴書)をGitHubを使って公開しているのをみて、自分もやってみようと思いました。

### 出来たもの

![20180610230627.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/771b35c7-ec77-0e4b-6b37-6dd57080c347.gif)
*urlの先の内容が変わって趣旨が伝わらなくならないようにするためのgif*

URL:
https://nkjzm.github.io/

GitHub Pagesのリポジトリ:
[nkjzm/nkjzm.github.io](https://github.com/nkjzm/nkjzm.github.io)

## 技術選定

- ホスティング: GitHub Pages
- 静的サイト生成ツール: Hugo (+Academicテーマ)

なるべく手軽に公開できて、かつマークダウンに対応している点で選びました。

### GitHub Pages (採用)

- 自分でサーバーをホスティングしなくて良い
- GitHubに対する操作だけで完結できる
- 独自ドメインにも対応

自分はウェブ系のエンジニアでないため、自分でホスティングしなくて良いのは魅力的でした。GitHubは普段から使っているサービスなので安心感もあります。

また、標準のurlはユーザーidでドメインを発行してくるところも気に入りました。(例: `https://[user_id].github.io/`)

### Jekyll (不採用)

- GitHubが開発してる静的サイト生成ツール
- **GitHub Pagesで正式サポート**
- Markdownにも対応

一見かなり良さそうでした。実際に試した所、ブラウザ上でGithubを操作するだけでページが作成できてしまい、しっかりとしたサポートがありました。

[Adding a Jekyll theme to your GitHub Pages site - GitHub Help](https://help.github.com/en/articles/adding-a-jekyll-theme-to-your-github-pages-site)

しかし、カスタマイズをしたい場合は設定が煩雑になり、また反映まで毎回待たされるのがストレスでした。かなり広く使われているツールなので、使いこなせれば便利だと思うのですが、自分の場合は後述するHugoの方が使いやすかったです。

### Hugo

- 静的サイト生成ツール
- Markdownにも対応
- 静的ファイルの生成速度が早い

そこまで大きな差はないのですが、**導入の容易さと生成速度の速さ**が良かったです。
ただ、Jekyllと違い正式なサポートがないため、一部だけ手間のかかる部分がありました。

## Github Pagesの仕様の話

2016年くらいに導入されてからいくつか仕様の変更があったので簡単にまとめようと思います。

`gh-pages`ブランチの情報がいくつか出てきますが、現状だと使う必要がないので参考にしない方ことをおすすめします。

### ページの分類

GitHub Pagesには『ユーザーページ』と『プロジェクトページ』の2種類の仕様が存在します。


| 　　　　　 | ユーザーページ | プロジェクトページ |
|:-----------|------------:|:------------:|
| 用途       | ポートフォリオやResume        | プロジェクトのWebページ         |
| リポジトリ名     |  `[user_id].github.io`     | `[user_id].github.io/[repository_name]`       |
| 付与されるurl     | `https://[user_id].github.io/`      | `https://nkjzm.github.io/[repository_name]/`       |
| 公開対象       | masterブランチ直下        | masterブランチ直下、もしくは**指定ブランチ直下のdocsフォルダ**         |

プロジェクトページは、プロジェクトのソースコード管理と同じリポジトリで管理できるように、`docs`フォルダ以下を公開対象に設定出来ます。

対してユーザーページはmasterブランチ直下しか公開できない制約があります。今回は生成元ファイルも同時にGitで管理したかったため、[後述](https://qiita.com/nkjzm/items/ab8595f185348de7ba7e#hugo%E3%81%AE%E7%94%9F%E6%88%90%E5%85%83%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%81%A8%E5%85%AC%E9%96%8B%E5%AF%BE%E8%B1%A1%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%82%92%E5%90%8C%E3%81%98%E3%83%AA%E3%83%9D%E3%82%B8%E3%83%88%E3%83%AA%E3%81%A7%E7%AE%A1%E7%90%86%E3%81%99%E3%82%8B)する作業を行う必要がありました。

### 利用方法

上記の公開対象にファイルを置いたら、リポジトリのSettingタブから、GitHub Pagesの項目を見つけます。
Sourceで公開対象にするブランチを設定し、Saveします (ユーザーページは自動的にmasterが設定されている模様)

一点注意があって、公開対象に更新があった場合、反映までに少し時間がかかります。

push直後は以下のようなメッセージが表示されます。

```
Your site is ready to be published at https://nkjzm.github.io/
```
 
反映されたら、

```
Your site is published at https://nkjzm.github.io/
```

というメッセージに変わります。ミニマム30秒くらい。

失敗すると失敗のメッセージが表示され、メールで通知がきます。その場合公開済みのページが壊れることはなく、失敗前のバージョンが表示され続けます。


参考: [GitHub Pagesを使ってサクッとWebページを公開する - Qiita](https://qiita.com/0084ken/items/4acdc7a00bf2e6f41f94)


## Hugoの導入

以下のページを見て導入しました。

[HugoとGitHub Pagesで静的サイトを公開する - Qiita](https://qiita.com/satzz/items/e24bd703fc04fb45f7ef)


簡単にまとめると、

(Macでbrewインストール済みの場合)

```
$ brew install hugo
$ hugo new site hugo-test
$ cd hugo-test

# サーバー起動
$ hugo server 

# 静的ファイル生成
$ hugo
```

上記の状態だと何も表示されませんが、themeを設定してカスタマイズすることで独自のページを作っていけます。

### ローカルサーバーでのプレビュー

```
$ http://localhost:1313
```

からプレビューができます。

これがかなり優秀で、起動しておけばファイルの変更のたびに自動的に更新をしてくれます。

サーバーを落とすときは `Control + C` をしないとプロセスが残ることがあるので気をつけましょう。

### Github Pagesに向けた設定

`hugo`コマンドで、`public`以下に静的ファイルが生成され、これを公開対象に設定することでGitHub Pagesとして表示がされます。しかし、GitHub Pagesの場合公開対象に選べるのは`master`直下、もしくは`docs`フォルダなので、設定を変更する必要があります。

設定は`config.toml`ファイル内の`publishDir = "public"`で定義されています。`docs`以下のフォルダを設定する場合は`publishDir = "docs"`を指定してください。

ユーザーページの場合は`master`直下しか公開できない制約があると言いましたが、[後述](https://qiita.com/nkjzm/items/ab8595f185348de7ba7e#hugo%E3%81%AE%E7%94%9F%E6%88%90%E5%85%83%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%81%A8%E5%85%AC%E9%96%8B%E5%AF%BE%E8%B1%A1%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%82%92%E5%90%8C%E3%81%98%E3%83%AA%E3%83%9D%E3%82%B8%E3%83%88%E3%83%AA%E3%81%A7%E7%AE%A1%E7%90%86%E3%81%99%E3%82%8B)する方法で対応が可能なため`docs`を指定しておけばOKです。

ソースコードの管理が不要な場合は`publishDir`フォルダをGitのルートにする方法と、`publishDir = "./"`を指定してプロジェクト直下に吐き出す方法があります。

参考: [Host on GitHub | Hugo](https://gohugo.io/hosting-and-deployment/hosting-on-github/)

### 大まかなカスタマイズのイメージ

使用するテーマによって異なる部分もあるので、詳細は各テーマのREADMEやドキュメントを参照してください。

テーマ毎のサンプルページをコピーしてから必要な部分を書き換えていく方法が分かりやすいように思いました。

- サイト全体に関するメタ情報などは `config.toml`に記述していきます。
- 画像は`static/img`以下に格納していきます。
- 各要素やページの内容は`content`以下に記述します。
  - `content/home`にトップページの各要素の内容を記述します。
  - `content/post`などに記事の内容などを記述します。


### Academicテーマ

広く利用されているオープンソースのテーマです。

- MITライセンス
- レスポンシブデザイン

[Academic | Hugo Themes](https://themes.gohugo.io/academic/)

書き方に困ったら僕のリポジトリを参考にしてください。
[nkjzm/nkjzm.github.io](https://github.com/nkjzm/nkjzm.github.io)


### Hugoの生成元ファイルと公開対象ファイルを同じリポジトリで管理する

GitHug Pagesのユーザーページはmasterブランチ直下のファイルしか公開できない制約があるため、そのままでは実現できません。

そこで以下の記事が参考になりました。

[GitHub PagesのUser Pagesでドキュメントルートを変更するにはmasterを殺す - Qiita](https://qiita.com/kwappa/items/03ffdeb89039a7249619)

更新したい場合は、以下の操作を行えばokです(`publishDir`が`docs`の場合)。

```
$ git push origin source
$ git subtree push --prefix docs/ origin master
```

余談ですが、2行目の操作をGitのhooks機能を使い、`pre-push`で自動化しようと考えました。

参考: [gitのpre-push hookでmasterブランチにpushする際にプロンプトで確認するようにする - Qiita](https://qiita.com/mkiken/items/af5c40ce0d0c6d3530c7)

参考: [git/hooks--pre-push.sample at master · git/git](https://github.com/git/git/blob/master/templates/hooks--pre-push.sample)

しかし、`while read local_ref local_sha1 remote_ref remote_sha1`が動作せず、断念しました。

*whileより前の行で`echo "hello"`を記述するとpush時に`hello`が出力されるが、while内の処理が呼ばれない*

どなたか原因思い当たる方がいましたらぜひご教授くださいmm


## 最後に (ポエム)

Github PagesとHugoを使い、手軽に自分のポートフォリオサイトを作成することができました。

最近思ったのですが、こういった自分の情報を俯瞰して参照できるページはかなり意義があるのではないでしょうか。

僕は普段から技術研鑽やアウトプットをしていると自負していて、Twitterなどで出来るだけ周りに発信するように心がけています。しかし、そういった発信を後から参照することは難しいです。実際ある程度交流がある人でも、その人が過去に何をしていたかよく知らないことは多いと思います。そこで、自分の実績やスキル、指向性などがまとまった場所の必要性を改めて感じました。

自分の指向性として、直接の対話でなくアウトプットを通じて自分を理解して欲しい想いがあるのですが、そのためにも自分がアウトプットしてきたことを人に伝える努力は怠ってはいけないと思いました。

## 謝辞

デバッグに協力してくれた[@pagu0602](https://twitter.com/pagu0602)に感謝🙏


