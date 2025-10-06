---
title: 【Unity】OpenVRで取得できるOculusコントローラー(Touch)のボタン入力
private: false
tags:
  - Unity
  - VR
updated_at: '2025-10-06T21:48:16+09:00'
id: 768919a00a2e3da08f67
organization_url_name: null
slide: false
---
# はじめに

公式のマニュアルが分かりづらかったので、備忘録を書いてみました。

OpenVR コントローラーの入力 - Unity マニュアル
https://docs.unity3d.com/ja/2018.4/Manual/OpenVRControllers.html

# 環境

- Windows 10 Home
- Untiy 2019.3.13f1
- Oculus Desktop 2.38.4
  * Virtual Reality SDKsでOculusを追加すると自動的にインポートしてくれる
- OpenVR Desktop 2.0.5
  * Virtual Reality SDKsでOpenVRを追加すると自動的にインポートしてくれる
- Oculus Rift CV1
    - Rift S / QuestのTouchコンも互換あるはずなのでキーマッピングは同じ気がする

# 調べ方

適当なプロジェクトで下記コードを動かして対応関係を調べた

```cs:test.cs
using UnityEngine;

public class test : MonoBehaviour
{
	private void Update()
	{
		// コントローラーのキーマッピングを調べるためのコード
		for (var keyCode = KeyCode.JoystickButton0; keyCode <= KeyCode.JoystickButton19; ++keyCode)
		{
			if (Input.GetKeyDown(keyCode))
			{
				Debug.Log($"{keyCode}が反応しました。");
			}
		}
	}
}
```

`Player Settings -> XR Settings`のVirtual Reality SDKsの設定で、どちらが有効か（上が優先される）で挙動が違いました。

![xr.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/d214f46b-0321-fe8c-3328-db285ec145fc.png)


nkjzm/OpenVR-Oculus-test
https://github.com/nkjzm/OpenVR-Oculus-test

# キーマッピング

左がPrimaryで、右がSecondaryです。

![oculus_touch.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/46cace91-3ec7-9ce5-fcd3-fa845611f6f3.jpeg)
出典: https://developer.oculus.com/documentation/unity/unity-ovrinput/

# Oculusが有効な時

|ボタン|説明|インタラクションタイプ|KeyCode|
|---|---|---|---|
|Button.One|Aボタン|押す|`JoystickButton0`|
|Button.Two|Bボタン|押す|`JoystickButton1`|
|Button.Three|Xボタン|押す|`JoystickButton2`|
|Button.Four|Yボタン|押す|`JoystickButton3`|
|Axis1D.PrimaryIndexTrigger|左トリガー|押す|なし|
|Axis1D.SecondaryIndexTrigger|右トリガー|押す|なし|
|Axis1D.PrimaryHandTrigger|左グリップ|押す|`JoystickButton4`|
|Axis1D.SecondaryHandTrigger|右グリップ|押す|`JoystickButton5`|
|Button.PrimaryThumbstick|左ジョイスティック|押す|`JoystickButton8`|
|Button.SecondaryThumbstick|右ジョイスティック|押す|`JoystickButton9`|
|Button.One|Aボタン|接触|`JoystickButton10`|
|Button.Two|Bボタン|接触|`JoystickButton11`|
|Button.Three|Xボタン|接触|`JoystickButton12`|
|Button.Four|Yボタン|接触|`JoystickButton13`|
|Axis1D.PrimaryIndexTrigger|左トリガー|接触|`JoystickButton14`|
|Axis1D.SecondaryIndexTrigger|右トリガー|接触|`JoystickButton15`|
|Axis1D.PrimaryHandTrigger|左グリップ|接触|なし|
|Axis1D.SecondaryHandTrigger|右グリップ|接触|なし|
|Button.PrimaryThumbstick|左ジョイスティック|接触|`JoystickButton16`|
|Button.SecondaryThumbstick|右ジョイスティック|接触|`JoystickButton17`|
|Touch.PrimaryThumbRest|左の指置き場|接触|`JoystickButton18`|
|Touch.SecondaryThumbRest|右の指置き場|接触|`JoystickButton19`|

トリガーを押した時の入力が取れないのしんどいですね

# OpenVRが有効な時

|ボタン|説明|インタラクションタイプ|KeyCode|
|---|---|---|---|
|Button.One|Aボタン|押す|`JoystickButton1`|
|Button.Two|Bボタン|押す|`JoystickButton0`|
|Button.Three|Xボタン|押す|`JoystickButton3`|
|Button.Four|Yボタン|押す|`JoystickButton2`|
|Axis1D.PrimaryIndexTrigger|左トリガー|押す|`JoystickButton14`|
|Axis1D.SecondaryIndexTrigger|右トリガー|押す|`JoystickButton15`|
|Axis1D.PrimaryHandTrigger|左グリップ|押す|`JoystickButton4`|
|Axis1D.SecondaryHandTrigger|右グリップ|押す|`JoystickButton5`|
|Button.PrimaryThumbstick|左ジョイスティック|押す|`JoystickButton8`|
|Button.SecondaryThumbstick|右ジョイスティック|押す|`JoystickButton9`|
|Button.One|Aボタン|接触|なし|
|Button.Two|Bボタン|接触|なし|
|Button.Three|Xボタン|接触|なし|
|Button.Four|Yボタン|接触|なし|
|Axis1D.PrimaryIndexTrigger|左トリガー|接触|なし|
|Axis1D.SecondaryIndexTrigger|右トリガー|接触|なし|
|Axis1D.PrimaryHandTrigger|左グリップ|接触|なし|
|Axis1D.SecondaryHandTrigger|右グリップ|接触|なし|
|Button.PrimaryThumbstick|左ジョイスティック|接触|`JoystickButton16`|
|Button.SecondaryThumbstick|右ジョイスティック|接触|`JoystickButton17`|
|Touch.PrimaryThumbRest|左の指置き場|接触|なし|
|Touch.SecondaryThumbRest|右の指置き場|接触|なし|

対応していない入力が増えます。AB, XYの対応関係が逆になる点に注意です。

# 使い方

```cs
// OpenVRが有効な状態でAボタンを押す場合
if (Input.GetKeyDown(KeyCode.JoystickButton1))
{
    // do something
}
```

シンプルな方法でアクセスできるのは、やはり便利そうですね。

# 最後に

間違ってたり漏れがあったら教えてください。
