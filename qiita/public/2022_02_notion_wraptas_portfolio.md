---
title: Notion+Wraptasで気軽に編集可能なポートフォリオを実現する
published_at: '2022-02-11 21:34'
private: false
tags:
  - Notion
updated_at: '2022-02-11T21:34:40+09:00'
id: ebb078ec452a15a37bf8
organization_url_name: null
slide: false
---

# はじめに

こんにちは、なかじです。

以前はGitHub Pagesを使ってポートフォリオを公開していたのですが、今回Notion+Wraptasという構成に乗り換えることにしました。そこまで技術的な話ではないのですが、備忘録的に公開までの手順を紹介していこうと思います。

https://qiita.com/nkjzm/items/ab8595f185348de7ba7e

# 今回作成したポートフォリオ

とりあえずこんなページを作りましたという紹介です。

https://nkjzm.jp/portfolio

中身はこんな感じ

![portfolio3.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/bff15c05-a7ed-4b1a-b689-eb8c798469ba.gif)
_urlの先の内容が変わって趣旨が伝わらなくならないようにするためのgif_


# 乗り換えの理由

Hugoは内容の更新が面倒だったためです。一度デザインが決まっていれば`.md`ファイルの更新だけではあるのですが、動作確認のためにはローカルサーバーを立ち上げるかGitHub Pagesにアップロードをする必要があります。また、ポートフォリオは数年毎に更新していく必要があると思うのですが、期間が開くとHugoやテーマ自体の更新があり、都度バージョンアップの手間がかかりました。

こうした背景とは別に、2年ほど前から自身の情報をNotionにまとめて公開するということをしており、更新の気軽さを実感していました。ただNotion単体ではポートフォリオ公開に不十分だと感じており、今回はWraptasを併せて利用することにしました。

簡単な比較を表にしてまとめてみました。

||Hugo + GitHub Pages|Notion|Notion+Wraptas|
|-|-|-|-|
|費用|無料|無料[^1]|1,078円/月|
|URL|https://nkjzm.github.io/|https://nkjzm.notion.site/e9198a90179f4658922b90523c7cd19b|https://nkjzm.wraptas.site/|
|独自ドメイン設定|可能|不可|可能|
|SEO(所感)|普通～強い|弱い|普通～やや強い|
|見た目の自由度|自由|最初から綺麗だけど細かい調整ができない部分もある|CSSである程度カスタマイズ可能|
|更新のしやすさ|GitHubリポジトリに対する更新をする必要があり、やや面倒|直接エディタで編集可能|Notionの内容が自動反映|
|総合的な印象|無料かつ全体的に優秀だが、更新だけやや面倒|公開にはやや不十分だが利便性が高い|Notionの弱点を上手くカバーしてくれている|

[^1]: 画像をたくさんアップロードする場合はProプラン($5/月)が必要になる場合がありそうです

費用についての補足です。私の場合は下記のような契約・構成にしています。

- Notion Proプラン($5/月)
    - 年額：5ドル * 116円 * 12か月 = 6,960円
- Wraptas 1サイト分 (1,078円/月)
    - 年額：1,078 * 12か月 = 12,936円
- 独自ドメイン取得
    - お名前.comには .jp ドメインを取得
    - 初年度330円+DNS追加オプション110円
    - 2年目以降は年間3,200円程度

年額としては大体 6,960円 + 12,936円 + 3200円 = **23,096円** ほどかかる計算です。ポートフォリオサイトの費用としては割高な印象です。私の場合は先述の[自身の情報を公開する用途](https://nkjzm.jp/)にも使っているので許容範囲でしたが、参考にされる方は費用を踏まえて検討するのが良さそうです。

# 作成の手順

## Notion上でポートフォリオをまとめる

Notion上でポートフォリオに掲載する情報をまとめます。カラムやCallout、インラインのデータベースなどを上手く活用すると綺麗な見た目になると思います。参考までに私のNotionのポートフォリオページを張っておきます（複製等ご自由にどうぞ）

https://nkjzm.notion.site/e9198a90179f4658922b90523c7cd19b

また、こちらのページも参考になりました。

https://www.notion.so/Notion-77f57f1ac463497fab63f4e7c35f99ea

## Wraptasで公開する

サイトの案内に沿って登録や設定を行っていきます。

https://wraptas.com/

ほとんど特殊なことはしていないのですが、少しだけ紹介

Wraptasでは自身のポータルページをルートとして登録しているので、その下に配置したポートフォリオページにはパーマリンク設定でURLを割り当ててあります。
![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/cc73faf8-6fc1-b934-c511-9a9d1044264d.png)
また、上記の編集ボタンからOGP情報の設定もできます。
![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/c2111fa5-6939-131b-939b-279f44a03b9d.png)

デザインについて

テーマCSSは使用せずに、公式で紹介されている[コピペで使えるサンプルCSS集](https://wraptas.com/css_sample)を参考に下記の設定を追加しています。

- [フッターに背景色を追加し、横幅ぴったりにする](https://wraptas.com/css_sample#block-c6759a1347c2461e91bdabb438a6297f)
- [ページトップに戻る ボタンをつける](https://wraptas.com/css_sample#block-7900d9fe05fc4ff69272709ff87b2f03)
- [ギャラリーのタイトルを１行で切れないように設定](https://wraptas.com/css_sample#block-c9b8ddfc3c074322ac828e8469b70732)
- [スクロール追従するSNSボタン](https://demo.wraptas.site/fixed_sns_button)

参考までに私が「追加CSS」に貼っているcssを共有しておきます。

```css
/* シェアボタンが最後尾のコンテンツとかぶるのを防ぐ */
.page {
    padding-bottom: 40px;
}
.shareBtns {
    position: fixed;
    bottom: 16px;
    left: 16px;
    z-index: 9;
}
.shareBtns__tw {
    border-radius: 50%;
    height: 40px;
    width: 40px;
    padding: 0;
    box-sizing: border-box;
    justify-content: center;
    align-items: center;
}
.shareBtns__tw__icon {
    margin: 0;
}
.shareBtns__tw__text {
    display: none;
}

/* ページトップに戻る ボタンをつける */

#page_top {
    width: 50px;
    height: 50px;
    position: fixed;
    right: 20px;
    bottom: 20px;
    background: rgb(66 192 226);
    opacity: 0.7;
    display: block;
    text-decoration: none;
    font-weight: bold;
    font-size: 25px;
    color: #fff;
    margin: auto;
    text-align: center;
    line-height: 50px;
    border-radius: 25px;
}

#page_top:hover {
    opacity :0.4;
}

/* ギャラリーのタイトルを１行で切れないように設定 */
.notion-collection-card-property .notion-page-title-text {
    white-space: break-spaces; /* 文字が切れずに改行するように */
    line-height: 1.5; /* ２行になると行間が狭いので、少し広めに */
}
/* ↑だけだと、アイコンが上下中心揃えになるので、上揃えにしたい場合は以下も追加 */
.notion-collection-card-property .notion-page-title {
    align-items: flex-start;
}


:root {
  --menu-btn-color: #000;
}
.header__menuOpenBtn {
    position: relative;
    overflow: hidden;
}
.header__menuOpenBtn svg,
.header__menuCloseBtn svg{
    display: none;
}
.header__menuOpenBtn:before {
    position: absolute;
    display: block;
    content: "";
    top: -18px;
    left: 7px;
    box-shadow: 
        0px 1px var(--menu-btn-color),
        0px 10px #fff,
        0px 11px var(--menu-btn-color),
        0px 21px #fff,
        0px 22px var(--menu-btn-color);
    width: 26px;
    height: 26px;
}

.header__menuCloseBtn:before,
.header__menuCloseBtn:after {
    position: absolute;
    display: block;
    content: "";
    top: 6px;
    background-color: var(--menu-btn-color);
    width: 25px;
    height: 1px;
}

.header__menuCloseBtn:before {
    left: 17px;
    transform: rotate(45deg);
    transform-origin: top left;   
}
.header__menuCloseBtn:after {
    right: 6px;
    transform: rotate(-45deg);
    transform-origin: top right;
}


/* フッターに背景色を追加し、横幅ぴったりにする */
.container {
  max-width: 100%;
  padding: 0;
}
.contents {
  padding: 75px 1em 1em;
  max-width: 800px;
  margin: 0 auto;
}
.notion-full-width .contents {
  max-width: 95%;
}
.footer {
  background-color: #eee;
  padding: 1em;
}
.footer__contentsWrapper {
  max-width: 800px;
  margin: 0 auto;
}
```

また、ページ下部にはフッターを設定しています。

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/d67b7612-dd0a-3a45-b071-4a6ada135790.png)

これもWraptasの標準機能を使っていて、サイトデータ編集→フッター設定に下記のページを指定しています。

https://nkjzm.notion.site/wraptas-42af645cf4974562bb30536edba50575

フッターのCalloutにのみcssを適用したかったため、「[html挿入機能で、そのページにのみ挿入する方法](https://wraptas.com/css_sample#block-5af5fd248afb478886f3aa1b7685fc18)」を使って「[Calloutを吹き出しのようにする](https://demo.wraptas.site/callout_ballon)」を適応しています。

## 独自ドメインを割り当てる

お名前.com でドメインを取得しました。契約時にやたらレンタルサーバーやオプション等をおすすめされますが、基本的には不要かと思います。

取得後はお名前.comのポータルサイトからDNS追加オプション（110円）を契約してください。Wraptasの設定ページかサポートページにDNS設定について記載がありますので、それに従って設定を進めてください。DNS設定は反映に時間がかかるみたいなので、完了後は気長に待ちましょう（私の場合は30分経たずにアクセスできる状態になっていました）

https://wraptas.com/4d19a3867e83402f9c7d2310ebe4b729

## 移行前のポートフォリオ（GitHub Pages）にリダイレクト設定をする

移行前のポートフォリオがある場合、検索結果にインデックスされていたり、既にSNSでシェア済みだったりすると思うので、リダイレクトはしておきたいところです。下記の記事に沿って設定を行いました。

https://zenn.dev/anozon/articles/gh-pages-redirect

少し気になったことをメモしておきます

- 現在のGitHub Pagesでは対象ブランチ指定ができるので、`gh-pages`ブランチをクリーンにする必要はない
  - 移行前の情報を消してしまうのは少し怖かったので、私は新規にブランチを作成しました
- 404ページが上手く動作しなかった
    - `404.html`ではなく`404.md`としてアップしたところ、きちんとリダイレクトされるようになりました
- GitHub Pagesへの変更が反映されない場合があった
    - GitHub Pagesの対象ブランチ設定で、一度別ブランチを指定して保存→リダイレクト用のブランチを指定して保存 という手順を踏むことで再度レンダリングが走り無事反映されました


こちらが以前のポートフォリオのリンクなのですが、きちんとリダイレクトされる状態になっているかと思います。

https://nkjzm.github.io/

# 最後に

基本的にはNotionのページをそのまま生かしたレイアウトにしているのですが、Wraptasで独自ドメインの割り当てやちょっとしたデザインの調整などができるのがかなり便利だと思いました。費用的にはちょっと高めですがかなり気軽に編集できるポートフォリオになったのでとても満足しています。よかったら参考にしてみてください！

また、ぜひTwitterのフォローもよろしくお願いします！→ [@nkjzm](https://twitter.com/nkjzm)



