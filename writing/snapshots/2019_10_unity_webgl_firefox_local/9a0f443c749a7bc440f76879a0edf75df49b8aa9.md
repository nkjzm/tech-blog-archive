---
title: "UnityのWebGLビルドをFirefox 68.0 以降でローカル実行する方法"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
---
# ※追記

`Build & Run`をするとUnityが自動でローカルサーバーを立てて実行してくれるようです。ビルドのたびに異なるポート番号が割り振られていることを確認しました。

# はじめに

UnityでWebGLビルドしたファイルをローカル上で実行しようとするとこのようなメッセージが表示されます。

> It seems your browser does not support running Unity WebGL content from file:// urls. Please upload it to an http server, or try a different browser.

「このブラウザはローカルファイルのWebGL実行は対応していないと思われるので、サーバーにアップするか別のブラウザを試してください」という旨が書かれています。

以前はFirefoxでは動作していたのですが、Firefox 68.0以降で変更があり設定が必要になったので紹介しようと思います。

# 環境

- macOS 10.14.6
- Firefox 69.0.3 (64 ビット)

# TL;DR

**※ セキュリティに関する設定なので、自己責任でお願いします。**

1. Firefoxを開いてURL欄に`about:config`と入力する
2. 検索欄で`file_unique_origin`と入力する
3. ダブルクリックで値を`false`にする

<img width="513" alt="スクリーンショット 2019-10-14 23.00.29.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/9316bc61-8f7f-fb63-862f-831b98736ac6.png">


## どんな設定？

セキュリティに関する設定だそうです。

> **CVE-2019-11730: Same-origin policy treats all files in a directory as having the same-origin**
> A vulnerability exists where if a user opens a locally saved HTML file, this file can use file: URIs to access other files in the same directory or sub-directories if the names are known or guessed. The Fetch API can then be used to read the contents of any files stored in these directories and they may uploaded to a server. Luigi Gubello demonstrated that in combination with a popular Android messaging app, if a malicious HTML attachment is sent to a user and they opened that attachment in Firefox, due to that app's predictable pattern for locally-saved file names, it is possible to read attachments the victim received from other correspondents.
https://www.mozilla.org/en-US/security/advisories/mfsa2019-21/#CVE-2019-11730

Webはあまり詳しくないのですが、同一ディレクトリやサブディレクトリ内にアクセスできると意図せずデータがアップロードされることがあるため、デフォルトでアクセス出来ないようにした変更のようです。

# その他: ローカルサーバーを立てる方法

Macではターミナルで以下のコマンドを打って実行できました。

```bash
# WebGLビルドで生成されたindex.htmlがあるディレクトリに移動します。
$ cd move/to/path

# python3がインストールされていない場合は実行(Homebrewが必要)
$ brew install python3

# サーバー実行
$ python3 -m http.server 8000

# ローカルホストの指定ポートにアクセスすれば実行することが出来ます。
# http://localhost:8000/
```

# 参考

- [ローカルUnity WebGLを実行できません（file：// url）Edgeを除くすべてのブラウザー！ -Unityフォーラム](https://forum.unity.com/threads/unable-to-run-local-unity-webgl-file-url-all-browsers-except-edge.709490/)
- [Issues with latest Firefox 68.0 - previewing sites locally - Mobirise Forums](http://forums.mobirise.com/discussion/21485/issues-with-latest-firefox-68-0-previewing-sites-locally)
- [Unity WebGLでビルドしたものが再生できない - Qiita](https://qiita.com/Sabanna-Hirokazu/items/8e644932571c9d05917e)



