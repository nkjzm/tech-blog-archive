---
title: "【Unity】Timelineからデバイスの振動を制御する【イージング付き】"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "Oculus", "VR"]
published: true
published_at: 2020-12-12 20:07
---

# はじめに

この記事は[Unity Advent Calendar 2020](https://qiita.com/advent-calendar/2020/unity) 12日目の記事です。昨日は@__poosukeさんの『[Unityから考えるDI](https://qiita.com/__poosuke/items/025c56a1e265a59d8684)』の記事でした。

先日リリースしたVRゲーム『[ALTDEUS: Beyond Chronos（アルトデウス: ビヨンドクロノス）](https://altdeus.com/)』というゲームでは、一部シーンでTimelineを使った演出があります。そのシーンでは臨場感を表現するためデバイスの振動を組み合わせているのですが、これをTimelineを作成するアニメーターさんが扱えるようにしたところ、非常に素晴らしい体験が出来上がりました。

今回はVRのハンドコントローラー(特にOculus)を例に、その方法を紹介したいと思います。

# 環境

- Unity 2019.2.21f1
- Timeline 1.1.0
- DOTween v1.2.335

# Markerを使ってTimeline上からメソッドを呼び出す

Marker機能を使うと、Timelineのシークエンス上にトリガー（下図の逆ティアドロップみたいな形のやつ）を設置し、そこから任意の処理を呼ぶことができます。

![Image from iOS.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/13b4ef42-1982-51cb-6cb8-eea6d225ce8f.jpeg)

参考：[【Unity】Timelineからメソッドを呼ぶ新機能 「Marker」と「Signal、Signal Receiver」 - テラシュールブログ](http://tsubakit1.hateblo.jp/entry/2018/12/10/233146)

詳しくは上の記事で丁寧に説明されているので割愛しますが、大体こんな感じのコードを書いています。Timelineが該当のマーカーに到達すると`INotificationReceiver`を継承した`MonoBehaviour`にイベントが発行されるので、その中で具体的な処理（今回は振動）を書くイメージです。

```cs:VibrateMarker.cs
[System.Serializable, DisplayName ("振動マーカー")]
public class VibrateMarker : Marker, INotification
{
	public VRDefine.HandType HandType = VRDefine.HandType.Both;
	public float Duration = 0.5f;
	[Range (0f, 1f)] public float Power = 0.5f;
	[Range (0f, 1f)] public float Frequency = 0.5f;
	public PropertyName id => new PropertyName ("method");
}
```

# Timeline上からいい感じに振動パターンを指定する

次に振動のパターンを細かく指定できるようにしていきます。先ほどの`VibrateMarker`を見ていただくと分かるように、Inspectorで値の指定が可能になっています。この辺りがSignalとの違いでしょうか。

そこで今回は以下のパラメータを実装しました。

- (Time: Marker標準のパラメータ、開始位置が秒/フレーム数として表示されている）
- Hand Type: 対象となるVRハンドコントローラーを指定する独自のenum（Both, Left, Rightがある）
- Duration: 持続する秒数
- Power: 振動の強さ（振幅）
- Frequency: 振動の細かさ（周波数）
- Should Easing: イージングの有無
- Power Ease: 振動の強さに対するイージングの種類

![haptic.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/0df2721e-3435-1116-ff38-202aed0b46f8.png)

コードはこんな感じ

```cs:VibrateMarker.cs
using System.ComponentModel;
using DG.Tweening;
using MyDearest.Platform;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[System.Serializable, DisplayName ("振動マーカー")]
public class VibrateMarker : Marker, INotification
{
	public VRDefine.HandType HandType = VRDefine.HandType.Both;
	public float Duration = 0.5f;
	[Range (0f, 1f)] public float Power = 0.5f;
	[Range (0f, 1f)] public float Frequency = 0.5f;

	[Space (20), Header ("↓ shouldEasing が true の時のみ 有効")]
	public bool shouldEasing = false;

	public Ease PowerEase = Ease.Linear;
	public PropertyName id => new PropertyName ("method");
}
```

次に、これを受け取る側の処理です。一部抜粋することこんな感じ。

```cs:TimelineController.cs
public sealed class TimelineController : MonoBehaviour, INotificationReceiver
{
	public void OnNotify (Playable origin, INotification notification, object context)
	{
		var element = notification as VibrateMarker;
		if (element == null) return;
		var time = element.time - origin.GetTime ();
		Vibrate (element.HandType, element.shouldEasing, element.Duration, element.Power, element.Frequency, element.PowerEase);
	}
}
```

Markerが呼ばれると `OnNotify` というイベント関数が発火します。ただしどのマーカーであるかはわからないので、`as`を使って型の変換を試みて、`VibrateMarker`であれば処理を続けるという分岐を書いています。マーカーが複数ある場合は `is`とかで処理を分けることになる気がします。

振動の処理は部分はこんな感じです。複数プラットフォームの対応をするため、ラッパーを呼んでいます。

```cs
    public void VibrateCommand (VRDefine.HandType handType, float duration, float power, float frequency)
    {
        VRPlatformManager.Platform.Vibrate (handType, duration, power, frequency);
    }
```

勘のいいひとはお気づきかもしれませんが、Oculusの振動メソッド`OVRInput.SetControllerVibration (frequency, amplitude, controller)`には継続時間の指定がありません。なので、`VRPlatformManager.Platform.Vibrate()`の内側で以下のような処理を呼んで疑似的に実現しています。（2.0秒間振動続けると自動で停止する仕様があるため、2秒ごとにコールしなおしています）

```cs
		IEnumerator VibrateCoroutine (VRDefine.HandType hand, float length, float amplitude, float frequency)
		{
			var lastSecond = length;
			while (lastSecond > 0f)
			{
				SetControllerVibration (hand, amplitude, frequency);
				var waitTime = Mathf.Min (lastSecond, 2.0f);
				yield return new WaitForSeconds (waitTime);
				lastSecond -= waitTime;
			}

			StopControllerVibration (hand);
		}

		void StopControllerVibration (VRDefine.HandType hand)
		{
			SetControllerVibration (hand, 0, 0);
		}

		void SetControllerVibration (VRDefine.HandType hand, float amplitude, float frequency)
		{
			var controller = OVRInput.Controller.None;

			if (hand == VRDefine.HandType.Left) controller = OVRInput.Controller.LTouch;
			if (hand == VRDefine.HandType.Right) controller = OVRInput.Controller.RTouch;

			OVRInput.SetControllerVibration (frequency, amplitude, controller);
		}
```

`TimelineController`の全文は以下です。両手別々にイージング処理をしている関係で冗長になっていますが、大した処理はしていません。


```cs:TimelineController.cs
using System.Collections.Generic;
using DG.Tweening;
using MyDearest.Platform;
using UnityEngine;
using UnityEngine.Playables;

public sealed class TimelineController : MonoBehaviour, INotificationReceiver
{
	private Dictionary<VRDefine.HandType, Tween> tweens = new Dictionary<VRDefine.HandType, Tween>
	{
		{VRDefine.HandType.Right, null}, {VRDefine.HandType.Left, null}
	};

	private Dictionary<VRDefine.HandType, float> LastPowers = new Dictionary<VRDefine.HandType, float>
	{
		{VRDefine.HandType.Right, 0f}, {VRDefine.HandType.Left, 0f}
	};

	public void OnNotify (Playable origin, INotification notification, object context)
	{
		var element = notification as VibrateMarker;
		if (element == null) return;
		var time = element.time - origin.GetTime ();
		// 誤差1秒以内の発火であれば実行
		if (Mathf.Abs ((float)time) < 1f)
		{
			Vibrate (element.HandType, element.shouldEasing, element.Duration, element.Power, element.Frequency,
				element.PowerEase);
		}
	}

	void Vibrate (VRDefine.HandType handType, bool shouldEasing, float duration, float power, float frequency,
		Ease powerEase)
	{
		if (handType == VRDefine.HandType.None) { return; }

		if (handType == VRDefine.HandType.Both)
		{
			Vibrate (VRDefine.HandType.Right, shouldEasing, duration, power, frequency, powerEase);
			Vibrate (VRDefine.HandType.Left, shouldEasing, duration, power, frequency, powerEase);
			return;
		}

		// 前のやつは殺す
		if (tweens[handType] != null)
		{
			tweens[handType].Kill ();
			tweens[handType] = null;
		}

		if (shouldEasing)
		{
			tweens[handType] = DOVirtual.Float (
				LastPowers[handType], power, duration, v =>
				{
					VibrateCommand (handType, Time.deltaTime, v, frequency);
					LastPowers[handType] = v;
				}
			).SetEase (powerEase).OnComplete (() => LastPowers[handType] = 0f);
		}
		else
		{
			VibrateCommand (handType, duration, power, frequency);
			LastPowers[handType] = power;
			tweens[handType] = DOVirtual.DelayedCall (duration, () => LastPowers[handType] = 0f);
		}
	}

	public void VibrateCommand (VRDefine.HandType handType, float duration, float power, float frequency)
	{
		VRPlatformManager.Platform.Vibrate (handType, duration, power, frequency);
	}
}
```

ポイントは`LastPowers`で最後の振動の強さを保持しています。イージング処理をする場合は終点を指定する形になるので前回の値が必要になるのです。前回の振動中に呼ばれた場合はその時点から上書きされますが、一度振動が終わってからイージングが呼ばれる場合もあるので、終了時点で`.OnComplete (() => LastPowers[handType] = 0f);`を呼ぶことを忘れないようにします。


# 最後に

やっていることはシンプルですが、組み合わせるとかなり強力なエディタ機能になったと感じました。よかったら参考にしてみてください！

最後に宣伝ですが、VRゲーム『 [ALTDEUS: Beyond Chronos（アルトデウス: ビヨンドクロノス）](https://altdeus.com/)』では今回の技術を活用した臨場感あふれるマシンアクションを楽しめます。興味がある方はぜひやってみてください！

さて、[Unity Advent Calendar 2020](https://qiita.com/advent-calendar/2020/unity) 13日目の記事は@yunodaさんの『初心者から始めるハイパーカジュアルゲームの作り方』です。こちらもお楽しみに。


