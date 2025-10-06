---
title: .csvの情報を.ica形式に整形するメモ
private: false
tags:
  - メモ
updated_at: '2018-08-28T08:49:58+09:00'
id: c03585458373bf978d02
organization_url_name: null
slide: false
---
# はじめに

CEDEC2018の講演スケジュールをGoogleカレンダーで確認できるようにしたので、その手順をメモしておこうと思います。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">同期しとくとこんな感じで時間と場所と詳細を確認できて便利になった。<a href="https://twitter.com/hashtag/CEDEC2018?src=hash&amp;ref_src=twsrc%5Etfw">#CEDEC2018</a> <a href="https://t.co/x3c5fep4ft">pic.twitter.com/x3c5fep4ft</a></p>&mdash; Nakaji Kohki (@kohki_nakaji) <a href="https://twitter.com/kohki_nakaji/status/1032173973058945024?ref_src=twsrc%5Etfw">2018年8月22日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

https://calendar.google.com/calendar/embed?src=a20r4f6oav5tr5mi99cidt8mgk%40group.calendar.google.com&ctz=Asia%2FTokyo


# 手順

まずCEDECの公式ページで配布されているcsvファイルをダウンロードしてきます。
https://2018.cedec.cesa.or.jp/

ここで、`.ica`形式の説明です。
Googleカレンダーで採用されている`.ica`はRDFカレンダーという仕様がベースになっています。これはラベルと値が`:`で区切られた形式です。ある程度標準的な規格で、Appleのカレンダーアプリなどでも使用できます。

例えばこちらの予定は…

<img width="449" alt="スクリーンショット 2018-08-26 0.07.12.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/4daa593e-7943-6368-a815-0435fcc9a6ce.png">

以下のような記述で表現されています。

``` :基調講演
BEGIN:VEVENT
DTSTART:20180822T004500Z
DTEND:20180822T020500Z
DTSTAMP:20180822T000000Z
CLASS:PUBLIC
CREATED:20180822T000000Z
DESCRIPTION:講演者:任天堂株式会社 宮本 茂\n主分野:カテゴリなし\n副分野:\nプラットフォーム:\n難易度:0:甘口(学生含めどなたでも)\n特記事項:\nURL:https://2018.cedec.cesa.or.jp/session/detail/s5b1e23aaede0a
LAST-MODIFIED:20180822T000000Z
LOCATION:メインホール
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:[メインホール]「どこから作ればいいんだろう？から１０年」
TRANSP:OPAQUE
END:VEVENT
```

*※いくつかの省略可能な値を省略しています。完全なものを確認したい場合は、自身の[Googleカレンダー](https://calendar.google.com/calendar/r)からファイルをエクスポートしてみてください。*

参考: [RDFカレンダー -- iCalendarとRSSによるイベント情報の公開と活用](https://www.kanzaki.com/docs/sw/rdf-calendar.html)


ここに`.csv`の値を整形していれていきます。今回はエクセルを使用しました。

こちらのデータを例に進めます。
<img width="1040" alt="スクリーンショット 2018-08-25 23.33.42.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/07ab64fd-07ce-706d-425e-0ba94a34684d.png">

まず必要な値を準備します。
先の基調講演のデータを見ると、少し見慣れない形式の値があります。

```
DTSTART:20180822T004500Z
```

これは`ISO 8601`と呼ばれるフォーマットです。
年月日の後ろに`T`を、時分秒の後ろの`Z`が必要になります。

参考: [日時のフォーマット（ISO 8601） - Qiita](https://qiita.com/kidatti/items/272eb962b5e6025fc51e)

上記のフォーマットにしたがい、`TEXT`関数を用いてエクセルで整形すると以下のようになります。

```vb:N2
=TEXT(A2-TIME(9,0,0),"YYYYMMDDThhmmssZ")
```

注意したいのが**UTC表記**という点で、`TEXT`関数はJSTの値として扱われるため、その差異を修正する必要があります。今回は簡易的に`TIME`関数を用いて標準時との差である9時間分を引くことで求めました。

同様に他の時間の値を整形しておきます。


また、`DTSTAMP`や`CREATED`は決めうちの値としました。

```vb:O2
=TEXT(B2-TIME(9,0,0),"YYYYMMDDThhmmssZ")
```

ではこの値をRDFカレンダーの仕様に沿っていれていきます。
エクセルは1セルの上限が255文字までなので、分割して結合する方法をとりました。

```vb:P2
="BEGIN:VEVENT
DTSTART:"&N2&"
DTEND:"&O2&"
DTSTAMP:20180822T000000Z
CLASS:PUBLIC
CREATED:20180822T000000Z
"
```
```vb:Q2
="DESCRIPTION:講演者:"&E2&"\n主分野:"&F2&"\n副分野:"&G2&"\nプラットフォーム:"&H2&"\n難易度:"&I2&"\n特記事項:"&J2&"\nURL:"&K2&"
LAST-MODIFIED:20180822T000000Z
LOCATION:"&L2&"
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:["&L2&"]"&D2&"
TRANSP:OPAQUE
END:VEVENT"
```
```vb:R2
=P2&Q2
```

これで各予定(講演)の情報が整形できました。

最後に必要なヘッダー情報と共に、`.ica`ファイルとして保存します。以下はヘッダーの例です。

``` calendar.ica
BEGIN:VCALENDAR
PRODID:-//Google Inc//Google Calendar 70.9054//EN
VERSION:2.0
CALSCALE:GREGORIAN
METHOD:PUBLISH
X-WR-CALNAME:CEDEC 2018 セッション一覧
X-WR-TIMEZONE:Asia/Tokyo
X-WR-CALDESC:

// ここに各予定の情報が入る

END:VCALENDAR
```



上記の手順で作成した`.ica`ファイルは以下から取得できるので、参考にしてください。
https://calendar.google.com/calendar/embed?src=a20r4f6oav5tr5mi99cidt8mgk%40group.calendar.google.com&ctz=Asia%2FTokyo


# 最後に

今回はカンファレンスの講演スケジュールをGoogleカレンダーに落とし込む方法を紹介しました。
異なるフォーマットのデータをインポート可能な形式にすることで情報が統合でき、とても便利です。ぜひ参考にしてみてください！




