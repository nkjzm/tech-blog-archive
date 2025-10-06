---
title: '【Unity】NatShareでツイート後に報酬を付与する #アセットアドカレ2021'
private: false
tags:
  - Unity
updated_at: '2025-10-06T21:48:16+09:00'
id: f5002c72ed3bca1d6ce5
organization_url_name: null
slide: false
---
# はじめに

「[Unity アセット真夏のアドベントカレンダー 2021 Summer!](https://assetstore.info/eventandcontest/adventcalendar/summer-advent-calendar-2021/)」 2日目の記事です。1日目は[ラズ](https://twitter.com/raspberly)さんによる「【アセット紹介】Grabbitでオブジェクトを配置する【Unity】」でした。

今回紹介するアセットはこちら。簡単にSNS投稿や画等付きツイートが実装でき、無料で使えます（記事執筆時点）。

https://assetstore.unity.com/packages/tools/integration/natshare-mobile-sharing-api-117705?utm_source=twitter&utm_medium=social&utm_campaign=jp-advent-calendar-summer

このNatShareを使って、ツイートをした時点で報酬を付与する方法を紹介します。

よくある実装ではツイート画面を開いた時点で付与自体が確定するのでキャンセルしても付与されてしまうのですが、NatShareではシェアの成否に応じた処理の切り分けをすることができます。そこまで厳密な方法ではないのですが、簡単に実装できるのでおすすめです。

![RPReplay_Final1627795549_2.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/40a68000-0bbe-a309-2a25-c69ed5297fdc.gif)


# 環境

- NatShare 1.2.3
    - [Asset Store](https://assetstore.unity.com/packages/tools/integration/natshare-mobile-sharing-api-117705?utm_source=twitter&utm_medium=social&utm_campaign=jp-advent-calendar-summer)
    - [ドキュメント](https://docs.natsuite.io/natshare/)
    - [GitHub](https://github.com/natsuite/NatShare)
- macOS 11.4
- iOS 14.6
- UniTask 2.2.5（サンプルで使用）


# 実装

`payload.Commit()`でSNS共有ができるのですが、非同期で実装されていて成否がbool値で返ってきます。キャンセルの時は`false`が返ってくるので、`true`の時だけ報酬付与処理を実行すればOKです。下記が実装例です。

```cs
// 実装例
shareButton.onClick.AddListener(async () =>
{
    var shareText = $"共有するテキスト";

#if !UNITY_EDITOR
    var payload = new SharePayload();
    payload.AddText(shareText);
    var result = await payload.Commit();
    // キャンセルされた場合は何もしない
    if (!result) return;
#else
    // Editor上では決め打ちで実行
    await UniTask.Delay(TimeSpan.FromSeconds(3f));
#endif

    // SNS共有後のリワード付与処理など
});
```

共有先の指定ができないので実際にはツイッター以外でも成否判定がなされてしまうのですが、かなりライトに実装ができるので活用できる場面は多いんじゃないかなと思います。

# 最後に

最後に宣伝なのですが、この記事で紹介した方法は「[ワンナイト人狼オンライン](https://online.1nite-jinro.com/)」というアプリの開発で使用しています。よかったらぜひ遊んでみてください！

Twitterもやっているのでよかったらフォローお願いします！
https://twitter.com/nkjzm

「[Unity アセット真夏のアドベントカレンダー 2021 Summer!](https://assetstore.info/eventandcontest/adventcalendar/summer-advent-calendar-2021/)」 明日の担当は[さとや]()さんによる「単独でも活用できる！Corgi Engine/TopDown Engineに同梱されているMMFeedbacksの紹介」です。



