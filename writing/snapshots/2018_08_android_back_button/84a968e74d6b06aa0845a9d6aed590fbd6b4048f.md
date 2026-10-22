---
title: "UnityでAndroidのバックボタン対応を1行で解決する"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Android", "Unity"]
published: true
---
# やりたいこと
AndroidのBackボタン(左向きの三角ボタン)を押した時にアプリを終了させたい時の話です。

Daydreamでは品質要件にて実装がすべきと明確に決まっています。
[Daydream App Quality Requirements - Functionality  |  Google VR  |  Google Developers](https://developers.google.com/vr/distribute/daydream/functionality-requirements#FN-A2)


# 方法
今まではこういうノリのコードを書いていたのですが、

``` test.cs
void Update()
{
    if (Application.platform == RuntimePlatform.Android && Input.GetKeyDown(KeyCode.Escape))
    {
        Application.Quit();
        return;
     }
}
```

実は一行で対応できることを知りました。

``` solution.cs 
Input.backButtonLeavesApp = true;
```

[Unity - Scripting API: Input.backButtonLeavesApp](https://docs.unity3d.com/ScriptReference/Input-backButtonLeavesApp.html)

Daydreamは「X」ボタンとバックボタンの両方がこれ1行で対応できました。
