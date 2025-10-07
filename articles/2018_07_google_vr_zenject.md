---
title: "Google VR SDKの入力クラスをZenjectで抽象化する"
emoji: "🥽"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "Oculus", "VR", "daydream", "Zenject"]
published: true
published_at: 2018-07-25 19:57
---
# はじめに

Google VR SDKでは`GvrControllerInput`というクラスを通してstaticに入力を取得できます。
https://developers.google.com/vr/unity/reference/class/GvrControllerInput

例えばボタンのクリックは以下のように検知できます。

``` Test.cs
using UnityEngine;

public class Test : MonoBehaviour
{
    void Update()
    {
        if (GvrControllerInput.ClickButton)
        {
            Debug.Log("ボタンがクリックされた");
        }
    }
}
```

今回はこの入力をZenjectを用いて抽象化することで、Google VR SDK以外の入力も扱えるようにしました。

# 実装

## 抽象クラスの定義

まずは入力の抽象クラスを定義します。
GoogleVRで拾える入力をそのまま抜き出した形です。

``` IHandController.cs
using UnityEngine;

public interface IHandController
{
    Vector3 Position { get; }
    Quaternion Orientation { get; }
    Vector3 Gyro { get; }
    Vector3 Accel { get; }
    bool IsTouching { get; }
    bool TouchDown { get; }
    bool TouchUp { get; }
    Vector2 TouchPos { get; }
    Vector2 TouchPosCentered { get; }
    bool Recentered { get; }
    bool ClickButton { get; }
    bool ClickButtonDown { get; }
    bool ClickButtonUp { get; }
    bool AppButton { get; }
    bool AppButtonDown { get; }
    bool AppButtonUp { get; }
    bool HomeButtonDown { get; }
    bool HomeButtonState { get; }
}
```

次に、`GvrControllerInput`を直接呼び出していた実装を抽象クラスで置き換えます。

``` Test.cs
using UnityEngine;
using Zenject;

public class Test : MonoBehaviour
{
    [Inject]
    IHandController HandController = null;

    void Update()
    {
        // 書き換え前
        // if (GvrControllerInput.ClickButton)
        // 書き換え後
        if (HandController.ClickButton)
        {
            Debug.Log("ボタンがクリックされた");
        }
    }
}
```

`GvrControllerInput`に依存しない状態になりました。

## 抽象クラスにZenjectで値を流しこむ

では実際に`IHandController`に任意の入力を流し込んでみましょう。

まずは流し込みたい入力を`IHandController`を継承して定義します。
以下は`GvrControllerInput`を用いて実装した例です。

``` GvrHandController.cs
public class GvrHandController : IHandController
{
    Transform controller = null;
    public Vector3 Position { get { return (controller ?? (controller = GameObject.FindObjectOfType<GvrTrackedController>().transform)).position; } }
    public Quaternion Orientation { get { return GvrControllerInput.Orientation; } }
    public Vector3 Gyro { get { return GvrControllerInput.Gyro; } }
    public Vector3 Accel { get { return GvrControllerInput.Accel; } }
    public bool IsTouching { get { return GvrControllerInput.IsTouching; } }
    public bool TouchDown { get { return GvrControllerInput.TouchDown; } }
    public bool TouchUp { get { return GvrControllerInput.TouchUp; } }
    public Vector2 TouchPos { get { return GvrControllerInput.TouchPos; } }
    public Vector2 TouchPosCentered { get { return GvrControllerInput.TouchPosCentered; } }
    public bool Recentered { get { return GvrControllerInput.Recentered; } }
    public bool ClickButton { get { return GvrControllerInput.ClickButton; } }
    public bool ClickButtonDown { get { return GvrControllerInput.ClickButtonDown; } }
    public bool ClickButtonUp { get { return GvrControllerInput.ClickButtonUp; } }
    public bool AppButton { get { return GvrControllerInput.AppButton; } }
    public bool AppButtonDown { get { return GvrControllerInput.AppButtonDown; } }
    public bool AppButtonUp { get { return GvrControllerInput.AppButtonUp; } }
    public bool HomeButtonDown { get { return GvrControllerInput.HomeButtonDown; } }
    public bool HomeButtonState { get { return GvrControllerInput.HomeButtonState; } }
} 
```

これをIHandControllerとして呼び出せる形(Injectできる形)にする必要があります。
先ほどの`Test.cs`クラスでいうと、この部分に`GvrHandController `を流し込んでいきます。

``` .cs
    [Inject]
    IHandController HandController = null;
```

Zenjectの紹介記事ではよく`ZenjectBinding`が利用されていますが、今回は`MonoBehavior`を継承していないクラスなので、コード上で紐づけを行います。

`MonoInstaller`を継承したInstallerクラスで以下のようにBindすることができます。

``` .cs
Container.Bind<[抽象クラス]>().To<[派生クラス]>().AsSingle();
```

`AsSingle()`は全てのInjectで再利用されるようにする指定です。
参考: [#Binding - Zenject READMEの日本語訳 - Qiita](https://qiita.com/rookx/items/3510467a2b57d3e39bc1#binding)

今回の実装例はこちらです。

``` HandControllerInstaller.cs
using Zenject;

public class HandControllerInstaller : MonoInstaller<HandControllerInstaller>
{
    public override void InstallBindings()
    {
        Container.Bind<IHandController>().To<GvrHandController>().AsSingle();
    }
}
```

これを`SceneContext`クラスを用いて呼び出します。
`SceneContext`はScript Execute Orderで必ず初めに呼び出されるようになっているので、確実にInjectを実行することができます。

<img width="378" alt="スクリーンショット 2018-07-25 17.26.23.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/1b5e6d23-0e7a-7d8a-7c92-4c5e786de159.png">


以上の作業で、抽象化した入力クラスに入力の定義を流し込むことが出来るようになりました。

## おまけ：Oculusでの実装

`GvrControllerInput`とは少し勝手が違いますが、こんな感じで行けると思います。

``` OvrHandController.cs
public class OvrHandController : IHandController
{
    // public bool ClickButton { get { return GvrControllerInput.ClickButton; } }
    public bool ClickButton { get { return OVRInput.Get(OVRInput.Button.PrimaryTouchpad); } }
} 
```

参考: [Oculus Goのコントローラ入力の取得まとめ - Qiita](https://qiita.com/rykgy/items/2b783b969c874ef4cc64)

# まとめ

Zenjectで綺麗な設計やっていきましょう:muscle:
