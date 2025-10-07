---
title: Twitterのエゴサ結果をIFTTTでSlackに見やすく投稿する
published_at: '2020-12-05 04:15'
private: false
tags:
  - Slack
updated_at: '2020-12-05T04:15:23+09:00'
id: 59b432a29f1344b356ae
organization_url_name: null
slide: false
---

# はじめに

「Twitterの検索結果をSlackに流すにはIFTTTを使えばいい！」って記事はたくさんヒットするんだけど、微妙に検索結果をフィルタリングしたり整形するのに手間取ったので備忘録として残しておきます

![Image from iOS.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/7b921975-1964-4865-b49c-962a27341803.png)

# 方法

## IFTTTでTwitter→Slack連携

丁寧に紹介してくれている分かりやすい記事があるので、こちらを参照してください。

Twitterで特定の単語を含むTweetを自動で拾ってSlack通知する方法 | by 福本 晃之 | Teruhisa Fukumoto | Medium
https://medium.com/@teruhisafukumoto/how-to-notice-to-slackwhen-speciality-word-are-tweeted-f91a226c5d4e

## 検索結果をいい感じに整形する

ハッシュタグのみなら簡単ですが、いくつかフィルターしたい場合があるので紹介です。

- 複数キーワードの組み合わせや除外
  - 以下のページで設定をして、出てきた文字列をコピペ
  - https://twitter.com/search-advanced
- 検索結果にリツイートを含まない
  - exclude:nativeretweets


参考：【2020年版】Twitterの検索コマンド60種類全まとめ！ユーザー指定や日付指定など使い方を解説 | ヨノイブログ
https://yonoi.com/twitter-search-command/#excludenativeretweets


### Slack上でツイートをいい感じに展開する

IFTTTでは投稿のタイトルや本文の内容、リンク先などを細かく設定することができるのですが、正直重複する内容が多くて見えづらいように思います。なので、いつも見慣れているSlack標準の展開機能を使う形にしてみましょう。

設定は以下の画像を参照してください。初期状態では左のような状態なのですが、右図のように本文にあたる「Messege」のみに「LinkToTweet」を設定してください。そうすると冒頭の画像のように綺麗に展開されるはずです。

![befaf.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/5bf47eb2-dc6d-043f-885a-cd3cb1884610.png)

ただこの方法には課題があって、URLのOGPなどは表示してくれません。

その場合はこちらの記事などが参考になるんじゃないかと思います。
http://www.imyme9.com/entry/slack_twitter_eyecatch

# 最後に

所属するMyDearest株式会社ではVRゲーム『[ALTDEUS: Beyond Chronos](https://twitter.com/chronos_series)』の開発をしています。よかったら遊んでみてください！

僕のTwitterもぜひフォローしてくれると嬉しいです：[@nkjzm](https://twitter.com/nkjzm)

