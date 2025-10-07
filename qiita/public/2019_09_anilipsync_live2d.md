---
title: Live2Dでアニメ調のリップシンクを実現する『AniLipSync-live2d』の使い方
published_at: '2019-09-19 02:04'
private: false
tags:
  - Unity
  - Live2D
updated_at: '2019-09-19T02:04:03+09:00'
id: b0d283cf8b1f7fdcf91b
organization_url_name: null
slide: false
---
# はじめに

Live2Dでアニメ調のリップシンクを実現する[AniLipSync-live2d](https://github.com/nkjzm/AniLipSync-live2d)というライブラリをリリースしました。
今回はその導入方法と使い方を紹介していこうと思います。

![Nov-30-2018 08-24-00 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/9fa4bab0-5b39-c999-b658-9adffcc7dbbe.gif)
_「あーいーうーえーおー。こんな感じで、リップシンクができます！」_


また、後半のモデルに適用する設定は説明しきれなかったので、動画も用意しました。適宜参考にしてください。

【解説】AniLipSync-live2dをモデルに適用する手順の紹介 - YouTube
https://www.youtube.com/watch?v=2j2KALzretk

## 環境

- Windows 10 / macOS High Sierra
- Unity 2018.2.10f1

## 必要なアセット

- [Live2d Cubism 3 SDK for Unity R9](https://live2d.github.io/#unity)
- [OVRLipSync Version 1.28.0](https://developer.oculus.com/downloads/package/oculus-lipsync-unity/1.28.0/)

各パッケージについてはそれぞれが定めるライセンスに準拠してください。  

# AniLipSync-live2dの導入

Live2D SDKとLive2Dモデルが入っている前提で、導入の説明をします。

## OVRLipSyncのインポート

マイク音声の取得にはOVRLipSyncというライブラリを利用します。

以下のページから、ダウンロードします。
https://developer.oculus.com/downloads/package/oculus-lipsync-unity

<img width="1046" alt="スクリーンショット 2018-10-18 4.36.57.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/51daa51b-2c98-720a-c406-ecfd76330898.png">

利用規約とプライバリーポリシーに同意のチェックを付け、「Download」ボタンをクリックしてください。ダウンロードしたzipファイルを解凍し、中にある `OVRLipSync.unitypackage`をダブルクリックしてください。

<img width="364" alt="スクリーンショット 2018-10-18 4.42.27.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/b1101a41-8d7a-e2f5-3d8e-3f427dd380d5.png">

「Import」ボタンを押してファイルをインポートします。

## AniLipSync-live2dのインポート

以下から`AniLipSync-live2d.unitypackage`をダウンロードしてダブルクリックします。
https://github.com/nkjzm/AniLipSync-live2d#download

<img width="365" alt="スクリーンショット 2018-11-30 3.02.03.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/ca5e9f22-0a4d-8cb8-fbd0-cff6b519260f.png">

「Import」ボタンを押してファイルをインポートします。

## サンプルシーンの動作確認

Projectビューから`Assets/AniLipSync-live2d/Examples/Scenes/AniLipSync-live2d`をダブルクリックします。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">AniLipSync(<a href="https://t.co/uRmkM1AZvG">https://t.co/uRmkM1AZvG</a>)のLive2D版ライブラリを公開しました。<br>Live2Dでリミテッドアニメ調のリップシンクが簡単に実現できるので、ぜひ使ってみてください。フィードバックもお待ちしております。<br><br>nkjzm/AniLipSync-live2d<a href="https://t.co/atPGZv4eE0">https://t.co/atPGZv4eE0</a> <a href="https://t.co/VA083x7Uiw">pic.twitter.com/VA083x7Uiw</a></p>&mdash; Nakaji Kohki (@kohki_nakaji) <a href="https://twitter.com/kohki_nakaji/status/1046399055302017024?ref_src=twsrc%5Etfw">2018年9月30日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

上記の動画のように動作するか確認してください。

# モデルに適用する

『桃瀬ひより』という[公式のサンプルモデル](http://docs.live2d.com/cubism-editor-manual/sample-model/)を例に説明します。
自作モデルを利用する場合などは、適宜読み替えて進めてください。


## 口形素プリセットの作成

まずは口形素プリセット(VisemeClip)を作成していきます。

Projectビューで右クリックをして、`Create/AniLipSync/VesemeClip`を選択してください。

<img width="625" alt="スクリーンショット 2018-11-30 3.16.36.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/21c4c1f0-634e-e9a5-200f-0f5d9b3e6625.png">

「Aa」という名前で保存します。同様に、「E」「Ih」「Oh」「Ou」も作成してください。

<img width="317" alt="スクリーンショット 2018-11-30 3.20.16.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/bccb7ce2-3dab-9bf2-31e0-b10007f3c2cb.png">

「Aa」を選択し、Inspector上で設定を進めていきます。

`prefab`という項目の右端の○を選択肢、設定したいLive2Dモデルを指定します。

<img width="284" alt="スクリーンショット 2018-11-30 3.20.46.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/6518df18-2428-3d4a-01ae-f98b08f6edb1.png">

`Preset`がAaであることを確認します(異なっていれば同名に設定してください)。

<img width="279" alt="スクリーンショット 2018-11-30 3.21.57.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/06d636e2-320a-9b41-72f5-0cf0177c07d0.png">

`Transition Curve`をクリックし、任意のアニメーションカーブを作成します。

おすすめ設定は以下です(右端の値が`0.1`である点に注意)

<img width="331" alt="スクリーンショット 2018-11-30 3.23.32.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/15451575-00b2-0596-1817-4f37c847a71e.png">

アニメーションカーブの編集の仕方はこちらを参考にしてください。

カーブの編集 - Unity マニュアル
https://docs.unity3d.com/ja/current/Manual/EditingCurves.html

`Serialized Property`には、変化させたいパラメータの値を設定してください。

参考までに、ひよりモデルを使用した時の設定例です。
「Aa」以外の他の口形素についても同様に設定してください。

<img width="844" alt="スクリーンショット 2018-11-30 4.58.06.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/f9215914-96a0-b541-7dab-ed4ca6347faa.png">

以上で口形素プリセットの作成が完了しました。

## シーンへの組込み

次に、実際のシーンに設定をしていきます。

Projectビューから`Assets/AniLipSync-live2d/Prefabs/AniLipSync-live2d.prefab`をHierarchyビューにドラッグします。

<img width="406" alt="スクリーンショット 2018-11-30 3.11.31.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/1ad9e495-585c-cd82-1958-5d996c81def7.png">

Projectビューから`Assets/Oculus/LipSync/Prefabs/LipSyncInterface.prefab`をHierarchyビューにドラッグします。

<img width="474" alt="スクリーンショット 2018-11-30 5.04.08.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/65b88829-d907-823b-c333-59d21a245442.png">

Hierarchyから`AniLipSync-live2d`を選択し、`AnimMorphTarget`を以下のように設定します。

<img width="359" alt="スクリーンショット 2018-11-30 5.06.51.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/134765a4-9b35-b5c0-8052-52872e9f3b65.png">

- `model`: シーン上のモデルを指定
- `Viseme To Shape`: サンプルのプリセットが設定されているので、先程作成したものに変更

この状態で再生ボタンを押すと、マイク入力した音素に併せてモデルが口パクをすると思います。

動かなかった場合、別のリップシンクが有効になっていないかなど確認してください。

# 最後に

フィードバックなどあれば是非お待ちしております。

nkjzm/AniLipSync-live2d: Live2Dでリミテッドアニメのようなリップシンクを実現するためのライブラリです。
https://github.com/nkjzm/AniLipSync-live2d
