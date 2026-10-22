---
title: "【YouTube, Twitch】Restream+棒読みちゃんでコメント読み上げ ※2018/07/24現在"
emoji: "📄"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["正規表現"]
published: true
---

# デモ

![demo.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/96efeb5b-dc69-8025-1b49-e637a7fac67d.gif)


# 初めに

Restreamを使うとYouTube Live(YouTube Gaming)やTwitchなど複数のサービスに同時に配信をすることが出来ます。

また、RestreamのChatアプリを使うと複数の配信サービスのコメントを一か所に集約することができ、さらに棒読みちゃんを組み合わせることに読み上げることも可能です。

今回はYouTube LiveとTwitchに対応した正規表現のコードと一緒にその手順を紹介しようと思います。

# 実現方法

## 確認済みの動作環境

- Windows 10 Home

## 使用アプリ

- [Restream](https://restream.io/)
- [Restream Chat 1.0](https://restream.io/chat)
- [棒読みちゃん](http://chi.usamimi.info/Program/Application/BouyomiChan/)
- [BouLog](https://qt.hotmint.com/boulog.html)

## 導入手順

こちらのページの手順が参考になりました。
[【Youtube,Twitch,Mixer】Restreamで棒読みちゃんの使い方 - AkaMaruServer](https://webcache.googleusercontent.com/search?q=cache:wZnMw9etYYIJ:https://25reinyan25.net/%3Fp%3D4248+&cd=1&hl=ja&ct=clnk&gl=jp)

中段辺りにある「Boulog」の説明の**「基本設定」と「設定1」の設定方法**まで進めたら以下をご覧ください。

## BouLogの設定

### 設定の例

![キャプチャ2.PNG](https://qiita-image-store.s3.amazonaws.com/0/55365/e4bf3c1e-4e41-9ca9-70db-93ebba153cc5.png)

**YouTube Live**
検索文字列: `\[.*\] Twitch.tv.*, (.*) (.*)`

**Twitch**
検索文字列: `\[.*\] Youtube.com.*, (.*): (.*)`

「設定 1」にTwitchを、「設定 2」にYouTube Liveを設定しています。他の配信サービスを追加する場合は、「設定 3」以降を使用してください。


### 置換文字列について

`(`と`)`で囲った部分にマッチした文字列を左から順に`$1`,`$2`で取得することが出来ます。

そのため、上記画像の設定を例にすると以下の整形することが可能です。

元の文字列: `[2:56:45] Youtube.com UCQAEaOgBMidPZqlluTpAb4A, なかじ: テスト`
置換文字列: `$1さんのコメント、$2`
実際に読み上げられる文字列: `なかじさんのコメント、テスト`

# おまけ: 正規表現文字列の作り方

![キャプチャ3.PNG](https://qiita-image-store.s3.amazonaws.com/0/55365/c8ec558d-7799-b342-2c9b-44e1dd2a6d41.png)

Sublime Textで左下辺りの正規表現オプションを入れた状態で試すとやりやすいと思います。

# 関連

- [雑記、引用、その他諸々 — Beamでチャットを棒読みちゃんに読ませるにはちょっと一手間かかるよ](https://hideblack.tumblr.com/post/153234871781/beam%E3%81%A7%E3%83%81%E3%83%A3%E3%83%83%E3%83%88%E3%82%92%E6%A3%92%E8%AA%AD%E3%81%BF%E3%81%A1%E3%82%83%E3%82%93%E3%81%AB%E8%AA%AD%E3%81%BE%E3%81%9B%E3%82%8B%E3%81%AB%E3%81%AF%E3%81%A1%E3%82%87%E3%81%A3%E3%81%A8%E4%B8%80%E6%89%8B%E9%96%93%E3%81%8B%E3%81%8B%E3%82%8B%E3%82%88)
