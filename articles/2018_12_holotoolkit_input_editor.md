---
title: "HoloToolkitの入力クラスをエディタ上で操作する"
emoji: "📄"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "VR", "HoloLens"]
published: true
---
## はじめに

この記事は[Oculus Rift Advent Calendar 2018](https://qiita.com/advent-calendar/2018/oculus-rift) 13日目の記事です。

12日目の記事は@songofsaya_さんの[まわりがGOだらけなのでMirage SOLOでHDRPをデプロイするのを試す記事とか書きますというタイトルでVRアドベントカレンダーに参戦する。](http://sayachang-bot.hateblo.jp/entry/2018/12/08/142732)でした。

![demo.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/b803a0dd-f2ef-6718-5f89-c2b6da4d31af.gif)


今回はHoloLens開発には(多分)欠かせない[HoloToolKit](https://github.com/Microsoft/MixedRealityToolkit-Unity)に関するお話です。

入力回りをいい感じに制御できるクラスがあるのですが、大変便利なことにエディタ上でプレビューする機能も用意されています。すごいことにキーコンフィグも細かく弄れるのですが、反面パッと見で対応するキーマッピングが分かりづらいという状況がありました。

そこで今回はデフォルトのマッピングをまとめつつ、どう定義されているかを簡単に紹介します。

### 動作環境

- Windows 10
- Unity2018.2.18f1
- [HoloToolkit 2017.4.3.0](https://github.com/Microsoft/MixedRealityToolkit-Unity/releases/tag/2017.4.3.0- )

## TL;DR

デフォルト設定だと以下の通りです。
多分これだけ知りたい人が多そう（僕がそうだった）

### 視点操作

| 動作 | マウス | キー |
| --- | --- | --- |
|平行移動 X| - | (→, ←), (D, A) |
|平行移動 Y| - | (Q, E) |
|平行移動 Z| Ctrl + マウススクロール| (↑,↓), (W,S) |
|軸回転 X| 縦方向にドラッグ | テンキーの(2, 8) |
|軸回転 Y| 横方向にドラッグ | テンキーの(6, 4) |
|軸回転 X| - | テンキーの(1, 3), (9, 7) |

正方向が左辺です。テンキーを使う場合は`NumLock`をオンにしてください。
平行移動に関しては`InputManager`の定義が使われているため、変更を加えている方は上の限りでないです。

### ハンドジェスチャ

| 動作 | 入力 |
| --- | --- |
|右手の移動 XY| Space + ドラッグ |
|右手の移動 Z| Space + マウススクロール |
|右手のクリック| Space + 左クリック |
|左手の移動 XY| Shift + ドラッグ |
|左手の移動 Z| Shift + マウススクロール |
|左手のクリック| Shift + 左クリック |

## ちょっとした解説

メニューの`Mixed Reality Toolkit` > `Configure` > `Apply Mixed Reality Scene Settings`より、`MixedRealityCameraParent`, `InputManager`プレハブがシーンに追加された状態での話をしていきます。

![fasdfasdfasdfas.PNG](https://qiita-image-store.s3.amazonaws.com/0/55365/fc9384dc-7e68-01a0-26aa-3d875cff54fa.png)

### 視点操作の解説

![move.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/221925c3-edf0-58dc-ddb8-51fb407de1fa.gif)


視点の制御は`MixedRealityCameraParent`の子の`MixedRealityCamera`についている`ManualGazeControl`というコンポーネントで行われています。

![asdfasdfasdf.PNG](https://qiita-image-store.s3.amazonaws.com/0/55365/879a2717-80d5-b8ad-ac67-b63a26121f3e.png)

マウス、キーボード、ジョイスティック(デフォルトでオフ)によって制御できるように設定されています。チェックボックスでそれぞれについて有効無効を切り替えることができます。

細かい設定については、このGameObjectの子についているコンポーネントに対して行っていきます。

![afdsafasdfasdfasd.PNG](https://qiita-image-store.s3.amazonaws.com/0/55365/7b9c74ae-053c-b604-3e76-8fc88adf5303.png)

`MouseXYRotationAxis`を見てみましょう。`AxisController`というコンポーネントがついていることが確認できます。全ての視点制御はすべてこの`AxisController`のパラメータによって定義されています。

![fasdfasdfasdfasd.PNG](https://qiita-image-store.s3.amazonaws.com/0/55365/bca35a0b-5b0c-ae8e-fc42-928e1f087a4a.png)

入力元の使用する設定はANDの関係です。(一方が`NONE`であれば片方のみ)

**Axis Type**
![asix.PNG](https://qiita-image-store.s3.amazonaws.com/0/55365/5771cc82-2a7f-2d8b-18f5-bf85744601ec.png)

`InputManagerAxis`はUnityの`InputManager`の定義のことです。
それ以外は定義されたいくつかの設定を選択できるようになっています。

**Button Type**
![button.PNG](https://qiita-image-store.s3.amazonaws.com/0/55365/085e2df9-901f-5f07-953b-0854d2f4f0b5.png)

上の方の`Left`,`Right`,`Middle`はマウスのボタンのことです。

平行移動、軸回転ともに軸移動という扱いになっていて、`Axis 0 Destination`などに軸を設定すると、正負の向きに変更ができるようになります。ものによっては複数の軸を持たせることもできます。

### ハンドジェスチャの解説

![click.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/5606e9f6-c443-90d6-5ee7-e4a2ac9eb1bc.gif)

ジェスチャの設定は`Assets/HoloToolkit/Input/Prefabs/RightHandInputControl.prefab`, `~/LeftHandInputControl.prefab`によって行われます。再生するとシーンにInstantiateされます。

手の移動は視線制御同様に`AxisController`によって定義されていますが、クリック操作のみ別のコンポーネントが用意されています。`ButtonController`です。

![buttt.PNG](https://qiita-image-store.s3.amazonaws.com/0/55365/bf43bb65-6ea3-e0d0-6c72-26bc67e9fffb.png)

使い方は非常にシンプルで、クリックジェスチャに該当する操作をInspectorから選択するだけです。
右手のエディタ操作の場合は、ドラッグ時に`Space`とマウス操作を組み合わせるものになっているので、クリック時も`Space`キーは共通(押しっぱなし)にし、マウスの左クリックをすることでクリックジェスチャの入力ができるように設定されていました。

## まとめ

どんな感じで設定できるか分かるといい感じにカスタマイズなどして快適に開発できそうですね！HoloLens開発やっていきましょう！

よかったらTwitter([@nkjzm](https://twitter.com/nkjzm))でも知見共有しあいましょう！よろしくお願いします！

明日の[Oculus Rift Advent Calendar 2018](https://qiita.com/advent-calendar/2018/oculus-rift) 14日目の記事は、@blkcatmanさんによる[Aframe + Vue を使ってOculusGoでWebVRを（なるべく簡単に）はじめる](https://qiita.com/blkcatman/items/2c1c8a5e021eb33ea6c6)です。

