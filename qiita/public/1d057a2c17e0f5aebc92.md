---
title: 【Unity】モバイルアプリのビルド番号を実行時に取得するライブラリを公開しました
tags:
  - Android
  - iOS
  - Untiy
private: false
updated_at: '2021-06-12T07:22:40+09:00'
id: 1d057a2c17e0f5aebc92
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

モバイル向けアプリを作っている時、現在実機にインストールされているバージョンを起動画面や設定画面に表示することがあると思います。バージョンの場合は`Application.version`で取得できるので簡単に実装できるのですが、ビルド番号を実機で取得する方法は用意されていません。

そこで、実機でのビルド番号取得を簡単に実現するライブラリを作成したので紹介したいと思います。

https://github.com/nkjzm/UniBuildNumber

ちなみにEditorの場合は下記のように取得できるのですが、もちろん実機では動作しません。

```.cs
// バージョン
PlayerSettings.bundleVersion;
// ビルド番号
PlayerSettings.iOS.buildNumber;
PlayerSettings.Android.bundleVersionCode;
```

## 想定している用途

よくあるパターンとして、CIでビルドするたびに[セマンティクスバージョニング](https://semver.org/lang/ja/)のバッチバージョンへビルド番号に反映させることあります(e.g. `v1.0.[ビルド番号]`) 。この方法ですとバージョン表記だけでどこまでの変更が反映されているか判断できるのでビルド番号は必要ないのですが、アプリバージョンを頻繁に変えたくない場合もあると思います。

バージョン表記を綺麗に保ちたい場合などが多いと思うのですが、今回僕が必要だと思ったきっかけはTest Flightの関係です。Test Flightでは外部テスターにアプリを配布する際に簡易的な審査（1日程度）が挟まるのですが、同一バージョンは審査されない仕様を利用すると即時配布することが可能になります。この仕組みを使うためにバージョンを変えなくなかったのですが、実機にインストールされているバージョンが分からなくなってしまうためビルド番号を併記したいという状況になりました。

https://qiita.com/mironal/items/8580a7fe1be2048c51d7


## 免責事項

プラットフォーム毎に呼び方が違いますが、この記事では下記のような使い分けをしています。

- バージョン (Version)
    - iOS: `CFBundleShortVersionString`
    - Android: `versionName`
- ビルド番号 (Build Number)
    - iOS: `CFBundleVersion`
    - Android: `versionName`


# 導入方法と使い方

READMEに書いてある通りですが、簡単に日本語でも紹介します。

https://github.com/nkjzm/UniBuildNumber

## 導入方法

Unity 2019.3.4f1, Unity 2020.1a21以降で使えるPackage Managerの機能を使って配布しています。

1. Unityプロジェクトを開く
1. Window -> Package Managerを開く
1. 左上の"+"ボタンから"Add package from git URL..."をクリック
1. `https://github.com/nkjzm/UniBuildNumber.git?path=Assets/UniBuildNumber`を入力し、"Add"をクリック

## 使い方

下記の3つのstaticなメソッドを用意してあります。iOS/Androidで型が違うので注意してください。

```.cs
// Get build number in iOS
string buildNumber_ios = nkjzm.UniBuildNumber.GetIOSBuildNumber();

// Get build number in Android
int buildNumber_android = nkjzm.UniBuildNumber.GetAndroidVersionCode();

// Get build number in current platform (iOS or Android)
string buildNumber = nkjzm.UniBuildNumber.GetCurrentBuildNumber();
```

僕の場合は下記のように使用しています。

```.cs
private void Start()
{
    versionLabel.text = $"{Application.version} ({UniBuildNumber.GetCurrentBuildNumber()})";
}
```

# 参考

今回のライブラリは下記の記事を参考にライブラリを作成・公開させていただきました。ありがとうございます。

http://nobollel-tech.hatenablog.com/entry/unity-app-version

# 最後に

普段はTwitterでUnityやxR技術の情報発信をしているので、良かったらフォローしていただけると嬉しいです。

https://twitter.com/nkjzm/status/1403016738623524865

