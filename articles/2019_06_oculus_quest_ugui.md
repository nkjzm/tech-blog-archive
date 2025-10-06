---
title: "Oculus QuestでuGUIを操作する"
emoji: "🥽"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "VR", "OculusQuest"]
published: true
---
# はじめに

基本的にはOculusGoなどと同じですが、少し情報が古くなっているので、2019.06時点での情報を記して置きます。

Oculus Go 開発メモ - uGUI編 - Qiita
https://qiita.com/JunSuzukiJapan/items/bead777e8dfeaa49ea30

今回はSampleFrameworkのプレハブを使って最小限の手順を紹介します。

関連: [OculusのSampleFramework全シーンをQuest実機で動かしてみた【Unity】 - Qiita](https://qiita.com/nkjzm/items/58a696f66c4989e5a35c#guardianboundarysystem)

# 環境

- Unity 2018.3.14f1
- Oculus Integration for Unity - 1.37
  - Oculus Utilities Plugin 1.32.0
- Mac OSX 10.14.4（18E226）


# 手順

## 0.前提

- Oculus Integrationsがインポート済み
- 組み込むシーンにOVRCameraRigが存在している

## 1. 操作される側(Canvas)の設定

`Assets>Oculus>VR>Scenes`のUIシーンにある`LightCanvas`をコピーして持ってくるのが早いと思います。余計なスクリプトついてないので、改変しやすいです。

デフォルト値からの差分としては以下の通りです。

- `Render Mode`は`World Space`に設定
  - Scaleをシーンに合わせる(ref: [World Space UI の作成 - Unity マニュアル](https://docs.unity3d.com/ja/current/Manual/HOWTO-UIWorldSpace.html)
- `Graphic Raycaster`を削除し、代わりに`OVR Raycaster`をアタッチする


## 2. 操作する側(EventSystem, LaserPointer)の設定

`Assets>Oculus/SampleFramework/Core/DebugUI/Prefab`内の`UIHelpers`とうPrefabに全部まとまっています。初めに挙げた記事などではインスペクター上での設定をしていますが、このPrefabはシーンに配置するだけですぐに動作します(デフォルトで右手からRayを飛ばす設定)。

Prefabの中には3つのGameObjectが入っています。

- EventSystem
    - `Standalone Input Module`の代わりに`OVR Input Module`がアタッチされている
    - `Ray Transform`(Rayを飛ばす原点)は`UIHelpers`についている`HandedInputSelector`が上書きする設定になっているため、必要であれば書き換える
- LaserPointer
    - `OVRCursor`を継承したクラスを持ち、`OVR Input Module`から参照されている
    - `CursorVirual`でカーソルとして使用するオブジェクトを指定可能
    - カーソルまでの線を描画したい場合はLine Rendererをenableにする
- Sphere
    - LaserPointerで`Cursor`表示用に参照されている

# 最後に

プレハブ2つをコピーしてくるだけで動きました。
それぞれシンプルな作りなので、ここから必要に応じて変更を加える形が分かりやすいと思います。


