---
title: "【Unity】Package Managerの実体パスのメモ"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
published_at: 2018-08-14 00:28
---
# はじめに

この記事は[Unityゆるふわサマーアドベントカレンダー 2018](https://qiita.com/splas_boomerang/items/e6619fb1e6dd92fd231f)の14日目です。
(あと数枠あるので、興味があったらぜひご参加ください)

UnityHubを使っているせいかバージョンのせいか、Winのパスが違っていたのでメモを残しておきます。

# 検証環境

Win: UnityHub 0.18.1 + Unity2018.2.1f1
Mac: UnityHub 0.18.1 + Unity2018.2.1f1

# Package Managerの実体パス

## バイナリファイル

各フォルダ以下にはパッケージ一覧が保存されている。実行時に参照してるのはここっぽい。

`/{PackageName, eg:com.unity.hoge}/{Version}/`以下にある`.tgz`がバイナリファイル。`.unitypackage`は内部的にこの形式らしい。

### Windows

```
~/AppData/Local/Unity/cache/npm/
```

### Mac

```
~/Library/Unity/cache/npm/
```

## ソースファイル

Unity2018.2くらいからUnity Editor上で見れるようになった。実体はここっぽい。
アクセス権がデフォルトで書き込み不可になっていた。

### Windows

```
~/AppData/Local/Unity/cache/packages/packages.unity.com/
```

### Mac

```
~/Library/Unity/cache/packages/packages.unity.com/
```


# 参考

[Unity: Package ManagerからインストールしたPackageのソースコードの場所 - Kilimanjaro Warehouse](https://kiliware.hateblo.jp/entry/2018/07/29/093431)

[Unity Package Managerについて - Qiita](https://qiita.com/k7a/items/cc5d09bc1000551b203f)

