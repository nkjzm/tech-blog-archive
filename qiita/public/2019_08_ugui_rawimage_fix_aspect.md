---
title: 【uGUI】元サイズに合わせて適切にアスペクト比を修正するRawImageの拡張メソッド【FixAspect()】
private: false
tags:
  - Unity
updated_at: '2025-10-06T21:48:16+09:00'
id: 7d1ffcb2b8dce38bd2d8
organization_url_name: null
slide: false
---
この記事は[「Unityゆるふわサマーアドベントカレンダー 2019」](https://qiita.com/nkjzm/items/7c933bb5c772a0b75512) 27日目の代理投稿です。昨日は@UnagiHuman さんの[「OculusQuestとRealsenseを接続してPointCloudを見る」](https://qiita.com/UnagiHuman/items/b654430fccb26af0c0a5)でした。

## はじめに

`RawImage`は`Texture`をuGUI上で描画できるコンポーネントです。UIを組む時などは`Image`を使うことが多いと思いますが、動的なテクスチャを扱う場合には`RawImage`の方が便利な時があります。そんな時に使える拡張メソッドを紹介したいと思います。

![Aug-15-2019 21-59-59.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/d83e9a02-d14b-7148-dbf0-16ef17e2fc2b.gif)

この拡張メソッドでは、上記Gif画像のようにUIのサイズに合わせて最大の大きさでアスペクト比を自動調整します。強みとしてはAnchorの状態に関わらず使うことができるので、StretchさせたUIパーツにも適用しやすいと思います。

## 使い方

[サンプル(nkjzm/FixAspectSample)](https://github.com/nkjzm/FixAspectSample/tree/master)の中にある[RawImageExtensions.cs](https://github.com/nkjzm/FixAspectSample/blob/master/Assets/RawImageExtensions.cs)をプロジェクトにインポートしてください。

拡張メソッドとして用意してあるので、適用したい`RawImage`から以下の様に呼び出せます。

```cs
[SerializeField] RawImage rawImage = null;
void Start()
{
    rawImage.FixAspect();
}
```

気軽に使える[ImageFitter.cs](https://github.com/nkjzm/FixAspectSample/blob/master/Assets/ImageFitter.cs)も用意しました。UIにアタッチすると、付けた時、再生した時、コンポーネントのメニューから「FixAspect」を選択した時に自動的に適用してくれます。とりあえず試したい時とかにオススメです。

また、上記は元のUIサイズを基準としているため、異なるサイズのテクスチャで繰り返し使用するとどんどんサイズが小さくなってしまうというありがちなミスがあります(下記gif画像参照)。

![Aug-15-2019 22-34-46.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/4d64c7fe-745a-2c16-2014-2346619960ea.gif)

そこで引数に`Vector2`を渡せる`void FixAspect(this RawImage image, Vector3 originalSize)`を用意しました。このような使い方を想定しています。

```cs
Vector2 initialSize;
void Start()
{
    initialSize = rawImage.rectTransform.rect.size;
}
void UpdateImage(Texture tex)
{
    rawImage.texture = tex;
    rawImage.FixAspect(initialSize);
}
```

こうしておくと何度適用しても元の大きさは変わりません。使い分けてください。

![Aug-15-2019 22-35-50.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/bb53e8af-7b3e-afd3-9765-a1fc37964102.gif)


# 実装

```cs:FixAspectExtensions.cs
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// RawImageの大きさを変える拡張メソッド
/// </summary>
public static class FixAspectExtensions
{
    /// <summary>
    /// アスペクト比に合わせてRawImageのサイズを修正する
    /// 現在のUIサイズが基準となる
    /// </summary>
    public static void FixAspect(this RawImage image)
    {
        image.FixAspect(image.rectTransform.rect.size);
    }
    /// <summary>
    /// アスペクト比に合わせてRawImageのサイズを修正する
    /// </summary>
    /// <param name="originalSize">基準となるUIサイズ</param>
    public static void FixAspect(this RawImage image, Vector3 originalSize)
    {
        var textureSize = new Vector2(image.texture.width, image.texture.height);

        var heightScale = originalSize.y / textureSize.y;
        var widthScale = originalSize.x / textureSize.x;
        var rectSize = textureSize * Mathf.Min(heightScale, widthScale);

        var anchorDiff = image.rectTransform.anchorMax - image.rectTransform.anchorMin;
        var parentSize = (image.transform.parent as RectTransform).rect.size;
        var anchorSize = parentSize * anchorDiff;

        image.rectTransform.sizeDelta = rectSize - anchorSize;
    }
}

```

## 解説

uGUIの仕組みをある程度理解している人向けです。

ポイントとなるのが`sizeDelta`で、これは「Anchorで定義された領域との差分」を表しています。例を上げると、Anchorがストレッチしていない場合(`AnchorMin`と`AnchorMax`が一致している状態)の`sizeDelta`は矩形(`Rect`)のサイズと一致します。何故ならAnchorで定義された領域は点であるため、矩形のサイズは`sizeDelta`のみで表現されている状態だからです。また、Anchorがストレッチしていて、かつ`Top`,`Right`などの余白が0の時、`sizeDelta`は`(0,0)`となります。Anchorで定義された領域と矩形のサイズが完全に一致しているため、「Anchorで定義された領域との差分」がない状態だからです。これを理解できると、ストレッチしているかどうかに書かわらず処理を一般化することが出来ます。

まずは前半部分です。

```cs
var textureSize = new Vector2(image.texture.width, image.texture.height);

var heightScale = originalSize.y / textureSize.y;
var widthScale = originalSize.x / textureSize.x;
var rectSize = textureSize * Mathf.Min(heightScale, widthScale);
```

これは処理後の大きさを求めるためのブロックです。テキスチャサイズを基準に、縦と横で元のUI要素のサイズの比率を比べています。それぞれが縦幅に合わせた時、横幅に合わせた時の最大のスケールを表しているため、小さい方を採用することで領域をはみ出ない最も大きなサイズになります。最後の行では`textureSize`に最適なスケールが掛け合わされることで、最終的なUIの大きさが求められました。

次のブロックではAnchorで定義された領域を求める処理をしています。

```cs
var anchorDiff = image.rectTransform.anchorMax - image.rectTransform.anchorMin;
var parentSize = (image.transform.parent as RectTransform).rect.size;
var anchorSize = parentSize * anchorDiff;
```

`anchorDiff`はAnchorで表される領域の相対的な大きさです。`(0,0)`なら領域は点となり、`(1,1)`なら親サイズと一致するサイズになります。次の行では親のサイズを習得しています。`rect`には常に矩形のサイズが入っているので便利ですが、代入することは出来ない点に注意です。最後の行では領域の具体的なサイズを計算しています。`Vector2`同士の掛け算では各要素をかけてくれるので、このように書くことが出来ました。

そして最後の行です。

```cs
image.rectTransform.sizeDelta = rectSize - anchorSize;
```

これはまさに「Anchorで定義された領域との差分」という言葉通りで、最終的なサイズからAnchorで定義された領域を引くことで`sizeDelta`が求められます。

# 最後に

GitHubにMITで置いてあるのでお気軽にご利用ください。
[nkjzm/FixAspectSample](https://github.com/nkjzm/FixAspectSample/tree/master)

[「Unityゆるふわサマーアドベントカレンダー 2019」](https://qiita.com/nkjzm/items/7c933bb5c772a0b75512) 28日目の担当は @tan-y さんです。
