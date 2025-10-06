---
title: 非Androidエンジニアが既存プロジェクトを雰囲気で開発する時の足がかり
private: false
tags:
  - Android
updated_at: '2019-06-12T15:38:36+09:00'
id: a89be1bf9701a2a90250
organization_url_name: null
slide: false
---

![ダウンロード.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/03098ba6-b116-fab3-db0a-657074e86b27.png)

## はじめに

Androidエンジニアじゃないけど既存のAndroidプロジェクトを触ることになった人向けの取っ掛かりとなる記事です。1から学習する時間がないので雰囲気で開発したい時に役に立つかもしれません。

僕も正しく概念モデルを理解している訳ではないので、つっこみなどは大歓迎です。

## 執筆時の環境

- Android Studio 3.4.1
- Mac OSX 10.14.4
- Android Gradle Plugin Version 3.3.2
- Gradle Version 4.10.1
- Kotlin Version 1.3.10

## ぜんぜんわからない 俺たちは雰囲気でビルドしている

入門記事を見てAndroid Studioをインストールしましょう。プロジェクトのREADMEに`Getting Started`や`Requirement`などが書いてあればそれに従いましょう。

インストールが終わったらメニューバーより`Tools/SKD Manager`を開き必要なSDKなどを入れていきます。`Android SDK`, `JDK`などが必要だったりします。READMEのバージョン等を確認し、特に記載がなければ最新のものを入れましょう。`Android SDK`に関しては最新バージョンに過去のバージョンが内包されている気がします(多分)。

一通りのインストールが終わったらメニューバーより`File/Open`で該当プロジェクトを開きます。Sync?が走ると思います。

<img width="1663" alt="スクリーンショット 2019-04-23 18.52.44.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/feda6275-954e-24e2-bcea-49a66d5e174d.png">

Android Studioは優秀なので、足りないコンポーネントなどがあればダイアログで教えてくれます。警告文の近くにあるボタン・リンク(下図では青字)を言われるがままにクリックしていきましょう。

<img width="1680" alt="スクリーンショット 2019-04-23 18.50.37.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/160ae884-5163-3b22-f332-d699832702b3.png">

完了するとSyncタブの一番上に"synced successfully"と表示されます。

<img width="1650" alt="スクリーンショット 2019-04-23 18.58.43.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/bffc9921-7397-7b2c-c1ec-628f269ff0eb.png">

続いてビルドしてみます。メニューバーより`Build/"Build Bundle(s)/APK(s)"/Build APK(s)`を選択します。Syncの横のBuildタブが開き、ぐるぐる回り始めます。"completed successfully"と表示されれば完了です。

<img width="1643" alt="スクリーンショット 2019-04-23 18.58.30.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/d6bd16e1-6865-af1e-5a6d-3e7abf444896.png">

完了したらプロジェクトディレクトリ以下の`/app/build/outputs/apk/debug/`にapkファイルが生成されます。

大体のプロジェクトは雰囲気でビルド出来ますが、出来なかったらエラーメッセージを読むなどして解決してください。

## ぜんぜんわからない 俺たちは雰囲気でエミュレータを動かしている

メニューバーより`Run/Run 'app'`を押すと、起動対象のデバイスを選択するウィンドウが表示されます。

<img width="634" alt="スクリーンショット 2019-04-25 23.50.27.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/41bbd1a2-0b05-28ba-607d-a637db7dc5e9.png">

実機で動かしてもいいんですけど、毎回繋いでおくのは大変なのでエミュレータで起動してみましょう。Virtual Devicesというのがエミュレータにあたります。画像の場合は「Pixel 2 XL API 28」を選択してOKを押すと起動します。多分初めは出てないので`Create New Virtual Device`から作成してください。少しだけ時間がかかる作業ですが雰囲気で進めていけば大丈夫です。

<img width="430" alt="スクリーンショット 2019-04-26 0.09.24.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/93258fee-4a90-3424-99cc-6ba90cd1337e.png">

起動するとこんな感じ。マウスポインターでタップと同じような操作が出来ますし、それ以外の操作(二本指ジェスチャーなど)も大体サポートされていると思います。

ちなみに実機で動かしたい時はAndroid側の設定が必要です。「開発者モード」「USBデバッグ」などのキーワードで検索してみてください。

## ぜんぜんわからない 俺たちは雰囲気でリーディングをしている

Androidの基本的なことが何も分からないので、ビルドが出来てエミュレータが起動出来てもどこから手をつければよいかわからないと思います。

僕が色々触ってみて、なんとなく各ファイルの役割や組み立て方が分かりそうな情報をざっとあげてみます。

### ディレクトリ構成と各ファイルの役割

大体どのプロジェクトもこんな感じのディレクトリ構成になっていると思います。

<img width="561" alt="スクリーンショット 2019-04-26 0.18.23.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/4f0d58eb-6a1d-775d-2ef2-4f1390122d15.png">

- `manifests/AndroidManifest.xml`
    - Permission(権限)を設定する役割(インターネットアクセスやカメラの許可など)
    - 起動時の画面指定
- `java/`
    - javaのコードが入っている
    - kotlinのコードも入ってたりする
    - ディレクトリはPackage名と完全に一致させる必要があるので、IDEの機能以外で変えないようにすること([※厳密には違うらしい](https://qiita.com/nkjzm/items/a89be1bf9701a2a90250#comment-6b94ed822b4e5ef9691f))
        - ファイルの上で右クリックすると出てくるメニューから`Refactor/`以下の機能を使うと良い
        - ファイル生成時にはパッケージ名を指定すると適切なディレクトリを作ってくれる
        - `com.fido.example.aaa.bbb`というパッケージ名のファイルがあったとして、`com.fido.example.aaa`直下には何もファイルがない場合、フォルダ名は`aaa.bbb`という省略された表示になる(実際のディレクトリは`aaa`の下に`bbb`がある)

<img width="349" alt="スクリーンショット 2019-04-26 0.53.29.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/57423328-abc6-1ce9-1d7c-f463320e04ce.png">

- `res/layout/`
    - レイアウトファイルが入っている
    - `.xml`形式で定義されている
    - 左下のタブを`Design`にすると、GUIで楽しくレイアウトを作れる
    - 左下のタブを`Text`にすると、直接xmlを記述してレイアウトできる(プレビューもある)

<img width="1104" alt="スクリーンショット 2019-04-26 0.57.16.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/d6dec8ab-8ddf-aa6d-e813-f0d7b6eb4ac8.png">

- `res/values/`
    - 定数などが定義されている
    - `string.xml`はアプリ内で使用される文言、など

### layoutの構成

- include
    - 他の`.xml`を引っ張ってこれる機能
- スクリプトで定義
    - パッケージ名が書いてある奴
    - 参考: [[Kotlin] AndroidアプリのレイアウトをXMLを使用せずに設定 - JoyPlotドキュメント](https://joyplot.com/documents/2018/04/25/android-%E3%82%B3%E3%83%BC%E3%83%89%E3%81%A7%E3%83%AC%E3%82%A4%E3%82%A2%E3%82%A6%E3%83%88/)
- コードから参照するには？
    - IDに指定した文字列を変数として参照出来る。
- 非表示にするには？
    - Favorite Attributes/visibilityを`invisible`か`gone`にする
        - 参考: [View.INVISIBLEとView.GONEの違い | MKTIAの備忘録](https://blog.mktia.com/invisible-vs-gone-view-in-android/)


### TIPS

`Shift`を2回連続で押すと検索窓が出てきて、ファイルの名前がメソッド名などを横断的に検索できる

<img width="458" alt="スクリーンショット 2019-04-26 1.01.35.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/c02a7b8d-b24b-3366-679a-c085acb01a8e.png">

`⌘ + Shift + F`でFind in Pathが出来る。こっちはコード中の文字列とかも検索出来るので、強い気がする。

## さいごに

変な所とかあったら教えてください

## 参考

- [Androidアプリのパッケージ名を変更する - Qiita](https://qiita.com/m_saeki/items/a66a21a51504446c09fd)






