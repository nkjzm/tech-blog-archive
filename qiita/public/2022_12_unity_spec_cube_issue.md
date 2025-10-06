---
title: Unityのシーン切り替え後にunity_SpecCube0によるskyboxの取得できない問題の解決メモ
tags:
  - Unity
  - Shader
private: false
updated_at: '2025-10-06T21:48:16+09:00'
id: 4918d547b44048f8c102
organization_url_name: mydearest
slide: false
ignorePublish: false
---
# はじめに

Unityではシェーダー内で使える`unity_SpecCube0`という変数が用意されており、以下のような値が入ってきます。

> Reflection Probeの影響範囲内である場合にはReflection Probeによるキューブマップが入ってくる
それ以外の場合にはLighting WindowのEnvironment Reflectionで設定したキューブマップが入ってくる

https://light11.hatenadiary.com/entry/2018/07/08/212014

これを使うことでSkyboxのキューブマップを取得することが出来るのですが、初めに再生したシーン以外でこの値が取得されない問題が発生しました。

根本的な解決は出来なかったのですが、その際の状況をメモしておこうと思います。私自身シェーダーに詳しくないので、何か基本的な見落としなどがあるかもしれません。何かお気づきの方は是非ご指摘いただけると幸いです。

# 再現の流れ

1. `unity_SpecCube0`を使用したシェーダーを配置したシーンAを用意する
1. シーンAを再生し、正常に描画されることを確認
1. 別のシーンBを用意し、シーンAに遷移する処理（`SceneManager.LoadScene("Hoge")`）を用意する
1. シーンBを再生してシーンAに遷移すると、`unity_SpecCube0`が取得できていない状態となる

# 取得方法

[こちらの記事](https://light11.hatenadiary.com/entry/2018/05/06/230414)を参考に下記のように取得しました。

```glsl
half3 reflDir = reflect(-worldViewDir, i.worldNormal);
// 用意されたマクロを使って取得
half4 refColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflDir);
// もしくは下記
half4 refColor = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir, 0);
```

# 解決策

原因は分からなかったのですが、アクティブなEnvironment Reflectionが正常に設定できていないか、もしくは切り替わっていないのかと思いました。

これに対するダイレクトな解決方法は見つけられなかったため、シェーダーのプロパティから直接キューブマップ（Skybox）を参照する形でこの問題を回避しました。

[こちらの記事](https://3dcg-school.pro/unity-shader-cubemap-reflection/)のままなのですが、プロパティに参照を追加した上で

```
Properties
{
    _Cube("Cube", CUBE) = "" {}
}
```

シェーダー内で使える丈太に宣言をし、

```
UNITY_DECLARE_TEXCUBE(_Cube);
```

下記のように置き換えを行いました。

```
// 置き換え前
half4 refColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflDir);
// 置き換え後
half4 refColor = UNITY_SAMPLE_TEXCUBE(_Cube, reflDir);
```

Environmentに設定されたSkyboxを参照する場合と違ってSkyboxの変化には追従できないのですが、少なくとも正しく描画されるようになりました。

# 参考

https://qiita.com/uynet/items/f8b087d47f5cf316eb7e

https://light11.hatenadiary.com/entry/2018/05/06/230414

https://3dcg-school.pro/unity-shader-cubemap-reflection/
