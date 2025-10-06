---
title: 【Oculus Quest】OVRGrabbableでかっこよく銃を実装する
tags:
  - Unity
  - VR
  - OculusQuest
private: false
updated_at: '2025-10-06T21:48:16+09:00'
id: 5ca336343c51603e31e9
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

以下の記事の中で、「Individualなキーマッピングは左右を区別しないため、**モノ自体にトリガーを持たせる**場合に活躍をする」という話をしました。この記事では、その思想に則ってキー入力を必要とする「銃」の実装を紹介したいと思います。

Oculus Questコントローラーが持つ複数のキーマッピングについて - Qiita
https://qiita.com/nkjzm/items/96cd9cddc645c45dd5e5

# 環境

- Unity 2018.3.14f1
- Oculus Integration for Unity - 1.37
  - Oculus Utilities Plugin 1.32.0
- Mac OSX 10.14.4（18E226）

# 適切な位置で銃を掴む

Oculus Integrationを使ってモノを掴むには、主に`OVRGrabber`と`OVRGrabbable`という２つのクラスを使います。

基本的な使い方については以下の記事が参考になりました。
[【Oculus Quest開発メモ】物を掴む、物を投げる OVR Grabber & Grabbable編【Unity】 - Raspberlyのブログ](https://raspberly.hateblo.jp/entry/OculusQuestGrabberGrabbable)

ここではSnap機能を使い、銃を「適切な位置で掴む」方法を紹介します。

![output2.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/507e7aee-cddc-1fff-b949-0c20560c3b14.gif)

上記のgifを見ると、手に対して銃が適切な位置で固定されていることが分かると思います。

<img width="285" alt="スクリーンショット 2019-06-23 21.03.53.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/aa3fb2ec-6f03-e149-75e2-06ef8b84bd84.png">

設定は`OVRGrabbable`の`Snap Position`, `Snap Orientation`にチェックを入れることで可能です。注意したいのが`Snap Offset`で、結論から言うとこの項目は使用しない方が良いです(nullでも機能するので)。

手の中心から掴みたいモノの座標をOffset分だけずらすというもので、`Snap Offset`で指定したオブジェクトのPositionとRotationが適用されます。ただし、その値はWorld座標系での原点との距離=offsetになるため、非常に使いづらいです。掴みたいモノの子オブジェクトにしてしまうと、手を動かすたびにOffsetの値も変化してしまう挙動をします。

ベストプラクティスとしては、`Snap Offset`を`null`にしておき、掴みたいモノのPrefab側で座標を調整してあげると良いです。掴みたい位置が、そのPrafabの原点になるようRendererの位置をずらすということです。

<img width="605" alt="スクリーンショット 2019-06-23 11.34.56.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/90b6bc6a-f89e-ea1d-e239-178ddc409ba0.png">

Quest実機で調整してみたところ、掴んだ時の手の原点は中指の付け根あたりにくるようでした。上記画像で矢印が出ているところがPrefabの原点になっているのですが、このように中指の付け根に当たる場所に描画オブジェクトを調整してみてください。Sceneビューでギズモを平行投影に切り替えて2視点から調整すると確実です。

# キー取得部分の実装

銃を適切な位置でつかめるようになったので、次はトリガー押下を検知する方法を考えます。

以下は`OVRGrabbable`を継承した`Gun`クラスです。

```cs:Gun.cs
public class Gun : OVRGrabbable, IGrabbable
{
    OVRInput.Controller currentController;
    public void GrabBegin(OVRInput.Controller controller)
    {
        currentController = controller;
    }
   void Update()
    {
        if (isGrabbed && 
        OVRInput.GetDown(OVRInput.Button.PrimaryIndexTrigger, currentController))
        {
            // implement
        }
    }
}
```

`Update()`の中身に注目すると、`OVRInput.GetDown(OVRInput.Button.PrimaryIndexTrigger, currentController)`という記述があります。第二引数に渡している`currentController`は変数になっていて、現在自身を掴んでいる方のコントローラーの値が格納されています。これにより、「モノ自体にトリガーを持たせる」銃が実現できます。

では、掴んでいるコントローラーの値を通知する`void GrabBegin(OVRInput.Controller controller)`の呼び出しについて見てみましょう。`IGrabbable`というインターフェースで定義されているメソッドになります。

```cs:IGrabbable.cs
public interface IGrabbable
{
    void GrabBegin(OVRInput.Controller controller);
}
```

このメソッドを、掴む側の`OVRGrabber`を継承した`CustomOVRGrabbable`から呼び出しています。掴んだオブジェクトが`IGrabbable`を継承していれば、`GrabBegin()`を呼び出すという実装です。

```cs:CustomOVRGrabbable.cs
using UnityEngine;

public class CustomOVRGrabbable : OVRGrabber
{
    protected override void GrabBegin()
    {
        base.GrabBegin();
        if (m_grabbedObj is IGrabbable)
        {
            ((IGrabbable)m_grabbedObj).GrabBegin(m_controller);
        }
    }
}
```

これらの実装により、掴む側でなく、掴まれるモノ側にキー入力の定義がある状態を実現出来ました。「指を引いた時、持っているものが銃であったら弾が出る」よりも、今回の実装のように「**銃を持っている時、指を引くと弾が出る**」の方が、直感的で分かりやすい実装だと思います。

# 最後に

`OVRInput`にはキー入力をの他にHapticsの実装なども用意されています。同様にコントローラーを引数に渡せる実装になっているため、今回紹介した方法を同じように適用出来ると思います。

よかったら是非参考にしてみてください。



