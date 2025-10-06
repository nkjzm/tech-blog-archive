---
title: 【Unity】ランタイムで指定したフォルダをファイラーで開く（Mac/Windows）
tags:
  - Unity
private: false
updated_at: '2025-10-06T21:48:16+09:00'
id: 7a3bac223a8ad89fb520
organization_url_name: unity-game-dev-guild
slide: false
ignorePublish: false
---

# TL;DR

```cs
// MyPicturesフォルダを開く場合
var path = Environment.GetFolderPath(Environment.SpecialFolder.MyPictures);
System.Diagnostics.Process.Start(path);
```

# 経緯

Windows/Mac向けに開発している『[Vフレット](https://nkjzm.jp/vfret)』というアプリには、スクリーンショットを撮影する機能があります。
![20230224-020432.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/94ee83f8-fa5c-2ace-2546-1ba9f4fbcedb.png)

スクリーンショットは直接PCの指定フォルダ上に保存される仕組みなのですが、撮影後に保存先のフォルダを開くことができると便利かなと思い方法を調べてみました。

まずはこちらで紹介されている方法を試したところ、Windows版では問題なかったのですが、Mac版でうまく動作しない問題に遭遇しました。

https://masakami.com/archives/2020/05/22/663/

そこで Twitterや[Unityゲーム開発者ギルド](https://unity-game-dev-guild.github.io/)で質問をしたところ、Processクラスを使えばいいのではないかとアドバイスをいただきました（皆さんありがとうございました…！）

https://twitter.com/shiena/status/1628730086966071297

Processクラスは通常対象のプロセス名を指定することが多いのですが

```cs
// プロセス名を指定する方法
System.Diagnostics.Process.Start("EXPLORER.EXE", @"C:\My Documents\My Pictures");
```

[こちらの記事](https://dobon.net/vb/dotnet/process/openexplore.html)によると、

> 「ファイルを関連付けられたソフトで開く」と同じように、フォルダも関連付けで開くことができます。フォルダは通常エクスプローラに関連付けられていますので、関連付けが変更されていない限り、エクスプローラでフォルダが開きます。

とありました。今回はWindowsとMacの両方に対応するアプリなので、プロセス名の指定を省略できる方が同じ記述で要件を満たしテストもシンプルになります。

```cs
// MyPicturesフォルダを開く場合
var path = Environment.GetFolderPath(Environment.SpecialFolder.MyPictures);
System.Diagnostics.Process.Start(path);
```

そこで上記のようなコードで試してみたところ、Windows/Macそれぞれで意図通りの動作となりました！！

![scren2.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/98441783-2cf4-417d-1967-dfaa3e552d3a.gif)

# 最後に

Twitterやってるので良かったらフォローお願いします！→ [@nkjzm](https://twitter.com/nkjzm)

また、VRMアバターで"それっぽく"弾き語りができる『Vフレット』というアプリを開発しています。こちらも興味があれば良かったらぜひ見てみてくれると嬉しいです！

https://nkjzm.jp/vfret
