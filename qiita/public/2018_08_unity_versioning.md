---
title: UnityでiOSとAndroidのバージョニングについてまとめた
published_at: '2018-08-06 12:38'
private: false
tags:
  - Android
  - iOS
  - Unity
updated_at: '2018-08-06T12:38:01+09:00'
id: 492cfc1103b8a124770a
organization_url_name: null
slide: false
---
各環境ごとに微妙に文言が統一されておらず、混乱したのでまとめました。
以下のキーワードを使うと検索しやすいと思います。

# キーワードの対応表

| 環境 | バージョン(表示用) | バージョン(内部用)  |
|:-----------|------------:|------------:|
| Unity(Android) | Version(`PlayerSettings.bundleVersion`) | Bundle Version Code (`PlayerSettings.Android.bundleVersionCode`) |
| Unity(iOS) | Version (`PlayerSettings.bundleVersion`) | Build (`PlayerSettings.iOS.buildNumber`) |
| Android | versionName | versionCode |
| iOS | Version (`CFBundleShortVersionString`)  | Build (`CFBundleVersion`) | 

前者がストアなどユーザーが見られるリリースバージョンとして使われ、後者がビルドの区別をするためのバージョン(ビルド番号)です。

# バージョニング管理

セマンティック バージョニング 2.0.0が一般的な考え方のベースになっているようです。
https://semver.org/lang/ja/

## リリースバージョン

一般に以下のフォーマットに則ります。

`x(major).y(minor).z(point)`

ファーストリリース時には`1.0.0`にするのが一般的です。

## ビルドバージョン

内部的な区別にのみ使われるので、ある程度自由です(重複しなければ)
Androidが整数で管理してるので、マルチプラットフォームの場合は合わせておくと良いです。(最大値は`2100000000`)

以下の方法がよく使われると思います。
 - 単調増加(jenkisnのビルド番号などを使う)
 - リリースバージョンを使う

# 参考

AndroidとiOSのアプリバージョン周りについてまとめてみた - Qiita
https://qiita.com/tarappo/items/6d20d2f4bc03135ed9c7

アプリのバージョニング | Android Studio
https://developer.android.com/studio/publish/versioning.html?hl=ja


