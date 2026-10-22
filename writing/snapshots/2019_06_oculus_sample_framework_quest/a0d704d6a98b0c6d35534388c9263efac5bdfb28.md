---
title: "OculusのSampleFramework全シーンをQuest実機で動かしてみた【Unity】"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "VR", "OculusQuest"]
published: true
published_at: 2019-06-14 18:14
---
# TL;DR

- Oculus IntegrationのSampleFramework内の全シーンをQuest実機で動かした
- 大体Riftと同じだった
- 一部おかしな部分があった

# はじめに

UnityでOculus Questの開発をする際に利用する「Oculus Integration」には、SampleFrameworkが含まれています。これは、Oculus製品の開発を行う際に参考になるシーンがまとまったものです。サンプルを一通り見れば、Oculus Integrationでどのようなことが出来るのかがすぐに理解できると思います。

「Oculus Integration」は全てのOculus製品共通のものになっているので、今回はQuest実機でどのような挙動をするのか調べてみました。

- [Oculus Integration - Asset Store](https://assetstore.unity.com/packages/tools/integration/oculus-integration-82022)
- [Oculus Integration for Unity - 1.37](https://developer.oculus.com/downloads/package/unity-integration/1.37.0/)

また、Oculus Quest/Go向けにビルドした.apkファイルを以下にアップしておきました。[ライセンス](https://github.com/nkjzm/QuestSamples/blob/master/license.txt)に同意した上でご利用ください。

Release Samples.apk · nkjzm/QuestSamples
https://github.com/nkjzm/QuestSamples/releases/tag/v0.1.0

# 環境

- Unity 2018.3.14f1
- Oculus Integration for Unity - 1.37
  - Oculus Utilities Plugin 1.32.0
- Mac OSX 10.14.4（18E226）

# サンプル紹介

各シーン毎に紹介していきます。

## StartScene

ランチャー的なシーンです。ここから全部のシーンを起動出来てとても便利なのですが、遷移先から戻ることが(多分)できないので、別のシーンを起動する時はアプリを終了させる必要がありました。

![fadsfas.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/b53ec2e1-2f0a-4930-b44c-b025ca1836a0.png)

## AvatarGrab

モノを持ち上げたり、投げたりすることが出来るサンプルシーンです。`OVR Grabber`と`OVR Grabbable`の２つのコンポーネントにより実現されています。

![grab.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/079618e3-a7dd-c03f-ef1d-d063ccc3d1d9.gif)

以下の記事にて詳しく紹介されています。

【Oculus Quest開発メモ】物を掴む、物を投げる OVR Grabber & Grabbable編【Unity】 - Raspberlyのブログ
https://raspberly.hateblo.jp/entry/OculusQuestGrabberGrabbable

## CustomControllers

コントローラーが表示されるシーンです。旧Rift用コントローラーでした(プロジェクトを見ても他のモデルは入っておらず)。

![custom.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/b0ea3b06-539f-2de0-e63b-e79a5718125d.gif)

動作するのはグリップ、トリガー、ジョイスティックのみでした。

## CustomHands

手が表示されるシーンです。

![hand.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/6bc406fc-651b-5cca-26f6-12efe50df043.gif)

従来のRiftと同様に接触センサーにも対応していて、非接触状態・接触状態・押し込み状態に応じて手の形が変化するようになっていました。

## DebugUI

VR空間上でuGUIベースのUIの表示・操作が出来るシーンです。

![ui.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/f8f3bf19-7d53-3295-c884-12c0a7e43231.gif)

以下のコンポーネントの操作が確認出来ました。

- ボタン
- ラベル(表示のみ)
- スライダー
- チェックボックス
- トグル(チェックボックスを排他制御したもの)

## DistanceGrab

離れた場所からモノを掴むことが出来るシーンです。

![distance.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/2cc7cead-ed3b-3f9e-47e7-75f1b354b649.gif)

手からRayを飛ばしていて、Rayがあたったオブジェクトには緑のアウトラインが表示されます。その状態でグリップを握ることでものを掴むことが出来ます。Rayのオプションが設定できて、通常の直線に加え、球状のRayを飛ばすモード、壁(Collision)をすり抜けるRayを飛ばせるモードがありました。掴んだ時に自分が吹き飛んでしまうバグ(?)がありました。

## GuardianBoundarySystem

ガーディアン境界をアプリケーションレイヤーで表示できるシーンです。

下記のように、静止モードの場合は動作しませんでした。

![gd.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/d6282406-c991-e0fc-4895-678bb2db827a.gif)

ルームスケールにすると、以下のように地面にガーディアン境界の線が表示されます。

![gd2.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/e9d2c86c-87ed-6b12-b6ca-68ba85056a0a.gif)

動画では境界線に近づいた時に表示される壁に触れる動きをしているのですが、公式の録画機能では映らないようになっているようです。

## Locomotion

テレポート移動ができるシーンです。

![move.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/3cb72189-eebd-369f-69c5-b2c0c01b7dd5.gif)

Robo Recallのような方式で、トリガーを倒す方向で移動後の向きを決定、コントローラーの角度で移動先の作業を決定、トリガーを解放することで移動を確定するという仕組みです。移動可能領域はNavMeshが使われており、角度が急なところなどは移動できないようになっていました。

## MixedRealityCapture

MixedRealityCaptureのためのシーンです。

![mr.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/008f2263-6033-88bd-1b10-aa86514477b2.gif)

外部カメラとグリーンバックを利用してMR撮影が出来る機能が元々あり、そのための機能です。Questで利用できるかどうかは分からなかったです。
参考: https://developer.oculus.com/documentation/pcsdk/latest/concepts/mr-intro/

## OVROverlay

VR Compositor Layerが利用できるシーンです。奥に見える色々なアプリのサムネイルに対し、VR Compositor Layerのオンオフを切り替えています。

![lay.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/0e9399bc-9ba8-de8c-7368-bd3551cb6bcb.gif)

VR Compositor Layerとはアプリケーションとは別の仕組みで動作するレイヤーで、異なるフレームレートを持つそうです。有効にすると描画が奥行きに依らず手前に来ていることが確認出来ます。適用されたテクスチャやオブジェクトは明瞭に描画できるそうです。奥側にも描画が出来るため、背景などにも使えるようです。詳しくは以下。

参考: https://developer.oculus.com/documentation/unity/latest/concepts/unity-ovroverlay/

# 最後に

概ね普通に動作しているようで良かったです。
誤りや不正確な記述があれば教えてください。
