---
title: 【Unity】VRIKとHumanPoseHandler.SetHumanPoseを併用するとプルプルする問題の備忘録
tags:
  - Unity
private: false
updated_at: '2025-10-06T21:48:16+09:00'
id: 2165d50b1568ac398a85
organization_url_name: unity-game-dev-guild
slide: false
ignorePublish: false
---

# はじめに

現在開発の[アバターを使ったアプリ](https://booth.pm/ja/items/3024741)では、VRMモデルを下記の機能を併用して制御をしています。

- Animator（全身のポーズに使用）
- VRIK（腕の動きに使用）
- `HumanPoseHandler` (指の制御に使用）

その際、下記のようにモデルがプルプルする現象が発生してしまました。

![guiter.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/007fed60-8391-170b-028f-ea5537cabc51.gif)

結論としては`AnimatorUpdateMode`を`Normal`にすることで解決したのですが、根本的な原因は分からずじまいでした。色々と調べたこともあるので、この時の状況についてまとめておきたいと思います。

# 各実行タイミングについて

下記ページの図を見ながら整理しました。

https://docs.unity3d.com/ja/2021.3/Manual/ExecutionOrder.html

必要なライフサイクルを抜粋すると、下記の流れを繰り返します。

1. Physics
    1. `FixedUpdate()`
    1. Animation実行（`AnimatorUpdateMode.AnimatePhysics`の場合）
1. Game logic
    1. `Update()`
    1. Animation実行（`AnimatorUpdateMode.Normal`の場合）
    1. `LateUpdate()`
1. Scene rendering（実際に画面に描画される）

PhysicsはGame logicと別のタイミングで実行されていて、どちらかが連続で呼ばれることもあります。

## Animator

`AnimatorUpdateMode`の値によって実行タイミングが変わります。

https://docs.unity3d.com/ja/2020.3/ScriptReference/AnimatorUpdateMode.html

- `AnimatorUpdateMode.Normal` : `Update()`と`LateUpdated()`の間で実行される
- `AnimatorUpdateMode.AnimatePhysics` : `FixedUpdate()`の直後に実行される

Animatorを使うと基本的にすべての値が上書きされてしまうようで、スクリプトを併用する場合はAnimatorの実行後にタイミング（`LateUpdate()`など）で実行する必要があります。

https://bibinbaleo.hatenablog.com/entry/2021/03/04/215544

AvatarMaskを使った方法についても検討しましたが、Maskした部分以外の値も上書きされてしまうようです。

なお、VRMのHumanoidはUnityのHumanoidAvatarを元にしていますが、Avatarオブジェクトは持っていないため、対応が失敗している可能性はあるかもしれません。

https://vrm.dev/univrm/humanoid/humanoid_overview.html

## VRIK

VRIKは`LateUpdate()`内から呼び出される`UpdateSolver()`内で、ボーンのtransformの値を直接書き換えることで姿勢の制御をしています。書き換え前の値は内部でキャッシュしておらず、同じフレーム内で取得しているようにみえました。

注目したいこととして、`UpdateSolver()`は`LateUpdate()`内で呼ばれる時と呼ばれないときがありました。

```（抜粋）SolverManager.cs
void FixedUpdate() {
	updateFrame = true;
}

void LateUpdate() {
	// Check if either animatePhysics is false or FixedUpdate has been called
	if (!animatePhysics) updateFrame = true;
	if (!updateFrame) return;
	updateFrame = false;
	
	UpdateSolver();
}
```

内容としてはこのように制御しているようです。

- `AnimatorUpdateMode.Normal`の場合、毎回の`LateUpdate()`で実行
- `AnimatorUpdateMode.AnimatePhysics`の場合、`FixedUpdate()`が呼ばれた後の`LateUpdate()`のみで実行

## HumanPoseHandler

下記のコードを一部改変して使用しています。Animationとの兼ね合いで、`Update()`ではなく`LateUpdate()`にて実行しています。

https://qiita.com/HhotateA/items/e4d240fbf9a95683b706

このコードでも、書き換え前の値は内部でキャッシュしておらず、同じフレーム内で取得しています。

```cs
var handler = new HumanPoseHandler(_HumanoidAnim.avatar, _HumanoidAnim.transform);
handler.GetHumanPose(ref targetHumanPose);
// 姿勢の変更
handler.SetHumanPose(ref targetHumanPose);
```

# 発生していたこと

`AnimatorUpdateMode.AnimatePhysics`の時にVRIK内の`UpdateSolver()`が呼ばれないタイミングがあり、`HumanPoseHandler.SetHumanPose()`が連続で呼ばれる状況でプルプルが発生していました。

`AnimatorUpdateMode.Normal`ではそれぞれが毎フレーム呼ばれるようになり、プルプルしなくなりました。同じ`LateUpdate()`内での実行なので呼び出し順は不定なのですが、Script Execution Orderで指定してみても特に挙動は変わりませんでした。

https://docs.unity3d.com/ja/2018.4/Manual/class-MonoManager.html

## 分からなかったこと

- プルプルする原因が分からない
- VRIKもHumanPoseHandlerもそれぞれ同じフレーム内で直前の値を取得しているはずなのに、呼び出し頻度によって挙動が変わる理由が分からない

# 最後に

何か原因が思い当たることがある方は是非コメントなどで教えてもらえると嬉しいです！

Twitter: [@nkjzm](https://twitter.com/nkjzm)

# 2023/05/22 追記

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">SetHumanPoseをvrik.GetIKSolver().OnPostUpdateでやった方が良さそうですがなんでプルプルするんでしょうね。</p>&mdash; あきら☎︎@VMC (@sh_akira) <a href="https://twitter.com/sh_akira/status/1660468478850256896?ref_src=twsrc%5Etfw">May 22, 2023</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

便利デリゲートを教えていただきました！実行順を制御できて呼び出し頻度も連動させられるので、こちらの方がよさそうですね。ありがとうございます！


# 関連

https://qiita.com/nkjzm/items/57d6fe67eb35abc9eb4e
