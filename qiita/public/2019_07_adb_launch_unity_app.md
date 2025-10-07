---
title: adbコマンドでUnity製アプリを起動する
tags:
  - Unity
private: false
updated_at: '2019-07-29T19:06:21+09:00'
id: 943c72bc395f26fd192f
organization_url_name: null
slide: false
ignorePublish: false
---
## はじめに

Buildした.apkを`$ adb install -r hoge.apk`した後に、端末上でアプリを起動するの面倒ですよね。そこでそのままadbコマンドでアプリを起動する方法を調べてみました。Oculus Go/Questの開発時とかにも使えるかもしれません。

## 方法

参考: [package名のみからadb shell am start -nする - Qiita](https://qiita.com/mattak/items/41b1ce1d48ddb3b2bb4a)

UnityではActivity名が`com.unity3d.player.UnityPlayerActivity`で固定なので、Package名だけ指定できれば良い。

## コード

```bash
$ adb shell am start -n {Package Name}/com.unity3d.player.UnityPlayerActivity
```

Package NameはPlayer Settingで設定できる`com.Company.ProductName`みたいなやつです。

## 最後に

書いてて思ったんですけど、初めから`Build & Run`すればいいのでは…？

(同一apkを複数端末で起動する時とかに使えるかも…)
