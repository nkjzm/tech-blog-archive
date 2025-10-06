---
title: 【Oculus/SteamVR】バイブレーション機能の周波数の範囲を調べてみた【Unity】
tags:
  - Unity
  - VR
private: false
updated_at: '2020-06-27T02:09:29+09:00'
id: f8c95c748990a0791495
organization_url_name: null
slide: false
ignorePublish: false
---
# TL;DR

多分この範囲、違ってたら教えてください

- Rift: 160-320Hz
- Rift S: 160-500Hz
- Quest: 160-500Hz
- SteamVR: 0-360Hz

# はじめに

現行のOculus/SteamVRのバイブレーション機能のメソッドで共通している`frequency(周波数)`の範囲について調べてみました。

```.cs
// Oculus Integration 17.0 (OVRPlugin 1.49.0)
SetControllerVibration (float frequency, float amplitude, Controller controllerMask)

// SteamVR Plugin V2
Execute(float secondsFromNow, float durationSeconds, float frequency, float amplitude, SteamVR_Input_Sources inputSource)
```

- [Unity Haptics](https://developer.oculus.com/documentation/unity/unity-haptics/)
- [Class SteamVR_Action_Vibration | SteamVR Unity Plugin](https://valvesoftware.github.io/steamvr_unity_plugin/api/Valve.VR.SteamVR_Action_Vibration.html#Valve_VR_SteamVR_Action_Vibration_Execute_System_Single_System_Single_System_Single_System_Single_Valve_VR_SteamVR_Input_Sources_)

# Oculusのバイブレーション機能

Oculusの`SetControllerVibration()`では`frequency`を`0-1`で指定します。

> 振幅と振動数の期待値は0から1の間の値(両端を含む)です。値が大きいほど、コントローラーの振動がより強くなるか、振動数が大きくなります。

引用元: [Unity Haptics](https://developer.oculus.com/documentation/unity/unity-haptics/)

上記のページには周波数の値について言及がないのですが、古いドキュメントに下記のような記載がありました。

> 振動を有効にするには振動数を指定します。0.0fを指定すると、160Hzで振動します。1.0fを指定すると、Riftでは320Hz、Rift Sでは500Hzで振動します。

引用元: [Haptic Feedback](https://developer.oculus.com/documentation/native/pc/dg-input-touch-haptic/?locale=ja_JP&device=RIFT)

この範囲が変わっていないとすると、`0-1`指定はこのような対応になりそうです。

- Rift: 160-320Hz
- Rift S: 160-500Hz
- Quest: 160-500Hz (Rift Sと同じコントローラーのはず[^1]）

[^1]: "QuestとRift Sは、共通の「Oculus Touch」コントローラーを使用しています。"（引用元: [「Oculus Quest」「Oculus Rift S」「Oculus Go」どれを買う？ オススメVRデバイス徹底比較 | Mogura VR](https://www.moguravr.com/oculus-rift-s-quest-go)）

# SteamVR

SteamVRの場合はドキュメントのDescriptionに記載がありました。

> // How often the haptic motor should bounce (0 - 320 in hz. The lower end being more useful)

引用元: [Class SteamVR_Action_Vibration | SteamVR Unity Plugin](https://valvesoftware.github.io/steamvr_unity_plugin/api/Valve.VR.SteamVR_Action_Vibration.html#Valve_VR_SteamVR_Action_Vibration_Execute_System_Single_System_Single_System_Single_System_Single_Valve_VR_SteamVR_Input_Sources_)

デバイス毎に違いがないのか気になるところですが、SteamVRでは`0-360Hz`の値を指定できるようです。

# 最後に（ポエム）

Oculusでは同じ`0-1`の指定で周波数の最大値が360Hz/500Hzと異なるデバイスがありますが、体験をデザインする上でこれって最適なんでしょうか？同じアプリでもRiftとRift Sでは感じ方が意図せず変わってしまうことを危惧しています。

例えば「軽めの振動と重めの振動」のような使い分けなら大丈夫そうですが、特定のモノ（リンゴなど）に触った時の最適な周波数は同じ値になる気がします。下記のような実装で一応固定値の指定はできますが、用意されているメソッドの使い道から外れていてかなり気持ち悪いです。どうするのがいいんでしょうね？

```.cs
// 周波数を200Hzで指定する
var clampedFrequency = GetClamp01(200f);
OVRInput.SetControllerVibration (clampedFrequency, amplitude, controllerMask)

// デバイスの差異を無くすためのメソッド
float GetClamp01(float frequency)
{
	if(Rift)
	{
		return (frequency - 160f) / (360f - 160f);
	}
	if(RiftS || Quest)
	{
		return (frequency - 160f) / (500f - 160f);
	}
}

```

# 参考

[[SteamVR Plugin V2] コントローラーへバイブレーション機能を付ける - Unity+UnrealEngine4+Blog.](https://nabesi777.hatenablog.com/entry/2019/03/07/_%E3%82%B3%E3%83%B3%E3%83%88%E3%83%AD%E3%83%BC%E3%83%A9%E3%83%BC%E3%81%B8%E3%83%90%E3%82%A4%E3%83%96%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E6%A9%9F%E8%83%BD%E3%82%92%E4%BB%98%E3%81%91%E3%82%8B)

