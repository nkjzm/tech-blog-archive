---
title: "Oculus Integrationを用いたVive開発時のコントローラー対応について"
emoji: "🥽"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "VR", "OculusQuest"]
published: true
---
# TL;DR

- 概ね直感的な対応付けがされている(Thumbstick->タッチパッド、など)
- 物理的に対応していないキーがある(A,X,Start,Back)
- クロスプラットフォーム対応するなら事前に使うボタンの選別をしておくとよさそう

# 初めに

Oculus Integrationは`1.31`からクロスプラットフォームに対応しており、そのままSteamVRなどで動作させることが出来ます。

基本的にはマジでそのまま動くのですが、コントローラーに関しては物理的に形状やボタンの有無等が異なるため対応が必要になります。今回はその辺りの対応についてまとめたいと思います。主にQuest->Viveを想定した書き方になっています。

参考: [Oculus Unity Integrationクロスプラットフォーム開発ドキュメンテーション 私家訳版 | heistak]( morning https://www.heistak.com/2018/12/04/oculus-unity-crossplatfom-jp-translation/)

# 環境

- Unity 2018.3.14f1
- Oculus Integration for Unity - 1.37
  - Oculus Utilities Plugin 1.32.0
- Windows 10 Home 1809

# Viveで動作させるまで

Oculus Integrationを使って開発したプロジェクトをViveで動かす際に必要だった手順です。

[Player Settings]-[XR Settings]-[Virtual Reality SDKs]にて`OpenVR`の追加だけ必要になると思います(デフォで入ってるかも)。それに伴い、[Window]-[Package Manager]より[OpenVR (Desktop)]もInstallsいてください。記事執筆時は`1.0.5`でした。

以上で、SteamVR Pluginのインポート等は必要ないです。

# コントローラー対応

Oculus Integrationのコントローラー機能については以下の記事で詳しく紹介しています。以下の内容を前提として紹介していきたいと思います。

Oculus Questコントローラーが持つ複数のキーマッピングについて - Qiita
https://qiita.com/nkjzm/items/96cd9cddc645c45dd5e5


以下が対応しているキーです。

- `Button.PrimaryIndexTrigger`
- `Button.SecondaryIndexTrigger`
- `Button.PrimaryHandTrigger`
- `Button.SecondaryHandTrigger`
- `Button.PrimaryThumbstick`
- `Button.SecondaryThumbstick`
- `Button.Two`
- `Button.Four`
- `Axis1D.PrimaryIndexTrigger`
- `Axis1D.PrimaryHandTrigger`
- `Axis1D.SecondaryIndexTrigger`
- `Axis1D.SecondaryHandTrigger`
- `Axis2D.PrimaryThumbstick`
- `Axis2D.SecondaryThumbstick`

`Button`で書いていますが、`Touch`(触れているかどうか)も対応していました。

<img width="518" alt="vive_controllers2.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/016abefa-1132-3830-8967-75c8eee5744f.png">
([Unityマニュアル](https://developer.oculus.com/documentation/unity/latest/concepts/unity-cross-platform-dev/)内の画像を元に、文字を付け加えたもの)

Viveのメニューボタンは`Button.Two`,`Button.Four`に対応付されていました。

OculusでいうThumbstickはViveのタッチパッドに相当しており、座標と押し込みの取得が可能です。Oculus Integrationで定義されている`Up`,`Right`,`Down`,`Left`に関しては、OculusではThumbstickを「その方向に倒した時」に判定されますが、Viveでは「その方向の位置で押し込みをした時」に判定されていました。

コントローラーの思想に関しても、上記の記事で説明しているように、第二引数に渡すコントローラーの種別によってキーマッピングが変化する仕様になっていました。

逆に対応していないキー次のようになります。

- `Button.Start`
- `Button.Back`
- `Button.One`
- `Button.Three`

物理的に対応付けがされていないキーです。`Button.Back`はOculusでアプリ開発をする際はメニュー呼び出しボタンとしてよく利用されるキーなので、結構困りそうですね。

# 最後に

個人的なベストプラクティスとして以下のような形にしておくのが良い気がしました。

- そもそもOculusのA,B,X,Yボタンを使わない(`Button.One`などのこと)
- Viveのメニューボタンは`Button.Back`に対応させる

物理的に難しいとはいえ、ほとんどの機能がそのまま動くクロスプラットフォームはかなり強力だと感じました。予め知っておくとゲームデザインで解決できることでもあるので、うまく対処していきたいと思います。

