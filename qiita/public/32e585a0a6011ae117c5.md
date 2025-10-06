---
title: GitHub PagesでPodcastサーバーを立ち上げるYattecastのコスパが最強だったので紹介する
tags:
  - GitHub
private: false
updated_at: '2019-05-02T14:53:11+09:00'
id: 32e585a0a6011ae117c5
organization_url_name: null
slide: false
ignorePublish: false
---
## TL; DR

- [Yattecast](https://r7kamura.github.io/yattecast/)はGitHub Pages上で動作するPodcastサイトのテンプレート
- 無料で使えて容量制限もほぼなし(1ファイルの最大は100MB)
- Apple PodcastやGoogle Podcast向けの配信にも対応

## はじめに

先日Podcastの配信サーバーをSoundCloudからGitHub Pagesに移行しました。
その際にYattecastというテンプレートを利用させていただいたのですが、これがめちゃめちゃ素晴らしかったので紹介します。

「GitHub Pages + Yattecast」は**"最低限で始められてカスタマイズ性が高い"**という、エンジニア好みの構成だと思います。Podcastを始めたいと思っている方は、是非参考にしてみてください。

## できたもの

![FireShot Capture 005 - xR.fm - xrfm.github.io.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/2bb748fa-d39b-5f83-5c11-1490846c4f66.png)
サイト: xR.fm: https://xrfm.github.io/
リポジトリ: https://github.com/xrfm/xrfm.github.io


## Podcastサーバーの技術選定

Podcast自体の要件は意外とシンプルです。

- 音声ファイルがアップロード出来る
- 対応するRSSを書き出すことが出来る

Apple PodcastなどはRSSを元に音声ファイルをインデックスしてくれるだけなので、音声ファイルのアップロード先は配信側が用意する必要がある点が重要です。

これを踏まえて、Podcastサーバーの選択肢としては大きく2つあると思います。

1. 配信サービスを利用する方法
2. 自分でサーバーを用意する方法(httpsが好ましい)

### 1. 配信サービスを利用する方法

- Anchor
- SoundCloud

あたりが有名でしょうか。特徴としては以下の点が挙げられます

- 配信までの手順が簡単
- 無料で使えるものも多い
- プラスの機能もある(アナリティクスなど)
- 広告などが挿入される場合がある

手軽に利用出来て非常に便利だと思いますが、私が選定しなかった理由としては少なからず制約が入ってしまう点です。例えばAnchorでApple Podcastに配信する場合[^1]はアートワークにロゴと音声の末尾に宣伝が挿入されたり、SoundCloudで配信する場合は総容量制限があったりします。また、サービス自体が終わってしまう可能性がある点も危惧しています[^2]。この辺りはかなり好みや思想による部分ですし、数ある全てのサービスの検討をした訳ではない点にご注意ください。

[^1]: Spotify傘下のサービスなので、恐らく他プラットフォームに配信する場合に制約が入る(推測ですが)。
[^2]: 全てのサービスに言えることではあるのですが、出来るだけその可能性が低したいです。


### 2. 自分でサーバーを用意する方法

- フルスクラッチ
- WordPress
- **Yattecast**

あたりが該当します。配信サービスと比べて自由に出来る幅が広く、反面手間がかかる点が特徴です。特にWordPressはアップロード先のサーバーを用意する必要こそありますが、GUI操作を中心に簡単に構築でき、Podcast用のプラグインが多い点も魅力的でした。しかし、それを踏まえた上で「GitHub Pages + Yattecast」に軍配が上がりました。

## GitHub Pagesとは

GitHub Pagesとは、GitHubによる静的サイトのホスティングサービスです。無料で使えます。

以前書いた記事でも簡単にまとめているので、参考にしてみてください。
[【初心者向け】Hugo + GitHub Pagesで静的なポートフォリオを作る - Qiita](https://qiita.com/nkjzm/items/ab8595f185348de7ba7e)

### 発行されるURL

GitHubアカウント、もしくはリポジトリに紐付いた**綺麗な**URLが発行されます。

- アカウントが`nkjzm`の場合: https://nkjzm.github.io/
- リポジトリ名が`Hoge`の場合: https://nkjzm.github.io/Hoge
- Organization名が`xrfm`の場合: https://xrfm.github.io/

### 容量制限

また、GitHub Pagesは容量制限がほとんどない点も魅力的です。GitHubリポジトリの制限とほぼ同一なので、1ファイル辺りの最大容量が`100MB`になりますが、リポジトリ自体に容量制限がありません(推奨は`1GB`とされていますが、超えても特に制約はないです)。

音声ファイルのフォーマットによっては100MBを超えてしまう場合もありますが、[xR.fm](https://xrfm.github.io/)ではffmpegで`192k`ビットレートの`.mp3`に変換しています。音質の劣化は特に感じず、`30分`ほど話している音声ファイルでも`50MB`に満たないくらいです。

参考: [Mac でコマンドラインから、m4a / WAV → mp3 など音声ファイルの形式を変換 - モノラルログ](https://matsuoshi.hatenablog.com/entry/2018/02/03/000000)

## Yattecastとは

[Yattecast](https://r7kamura.github.io/yattecast/)はGitHub Pages上で動作するPodcastサイトのテンプレートです。[yatteiki.fm](https://yatteiki.fm/)というPodcastをやられている[r7kamura (Ryo Nakamura)](https://github.com/r7kamura)さんがMITライセンス下で公開してくれています。GitHub Pagesが公式にサポートしているJekyll(ジキル)という静的サイトジェネレーターを用いて作られています。

リポジトリ: [r7kamura/yattecast: Podcastサイトをつくるためのテンプレート](https://github.com/r7kamura/yattecast)
公式ページ: [Yattecast - Podcastサイトをつくるためのテンプレート](https://r7kamura.github.io/yattecast/)

### 「GitHub Pages + Yattecast」の特徴

GitHub Pagesが強いので、無料で使えて容量制限もほぼありません。GitHubというバージョン管理サービスの性質上、データが失われる可能性も極めて低いと思います。また、基本的な機能が一通り備わっているのでいくつかのファイルの設定をするだけで簡単に利用できる上に、自由にカスタマイズすることも可能です。まさに、**多くのサービスの強みを兼ね備えた最強の構成**だと思いました。

欠点としては、各種配信サービスで提供されているような便利機能や連携サービスなどはほとんどありません。Yattecastで実現できないことはないのですが、それならば初めから要件に近いサービスを使う方が好ましいと思います。

### 使い方

[公式ページ](https://r7kamura.github.io/yattecast/)に書いてある通りなのですが、少し補足します。

> 1.リポジトリをfork
> r7kamura/yattecast をforkし、適当な名前に変更します。
> orgname.github.io のようなパターンの名前にするのがおすすめです。

GitHub Pagesの仕様で、`orgname.github.io`という名前のリポジトリを作ると`https://orgname.github.io/`というURLが発行されます。Podcast用にOrganizationを作成し、その配下にforkするのが良いと思います。(ref: https://github.com/xrfm/xrfm.github.io)

> 2.設定を変更
> _config.yml のサイト名や説明文などを書き換えます。

この辺りの差分を参考にしてください。
https://github.com/xrfm/xrfm.github.io/commit/e69e7b23f3c62ee1767bfd9f4f8561c6ed99a65a#diff-aeb42283af8ef8e9da40ededd3ae2ab2

`actors`の各`image_url`には`/images/actors/`以下の画像ファイル(400x400px)を指定してください。

> 3.音源を配置
> audioディレクトリにmp3ファイルを配置します。
> サンプルとして最初から空のmp3ファイルが置かれています。

100MB以下のファイルしかアップできない点に注意してください。

> 4.記事を配置
> _postsディレクトリに記事を配置します。
> サンプルの記事ファイルが置かれているので上書きしましょう。

`YYYY-MM-DD-[Number].md`という形式になっています。`[Number]`の値がURLのパスになります。
(例)[2019-04-11-10.md](https://raw.githubusercontent.com/xrfm/xrfm.github.io/master/_posts/2019-04-11-10.md)の場合: https://xrfm.github.io/episode/10

これらを設定してリポジトリのpushすると、1分くらいで反映されるようになると思います(リポジトリページのSettingタブから確認出来ます。)

ページのカスタマイズをしたい場合は`_includes`, `_layouts`内の`.html`や`/css`以下のファイルを書き換えればOKです。あとは各Podcastサービスにも登録しておくと良いかと思います。

- [Apple Podcast](http://podcastsconnect.apple.com/)
- [Spotify](https://podcasters.spotify.com/)

## 最後に

良かったらPodcastも聴いてみてください🙏
xR.fm: https://xrfm.github.io/
Twitter: [@xrfrn](https://twitter.com/xrfrn)




