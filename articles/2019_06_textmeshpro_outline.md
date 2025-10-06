---
title: "【Unity】TextMesh Proで文字を潰さず縁取りする方法 (Editor & Script)"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
---
# はじめに

TextMesh Proではアウトライン(`Thickness`)を広げると内側につぶれてしまう現象があるのですが、`Dilate`(拡張するという意)を調整することで綺麗に表示されることが出来ます。今回はその変更方法を紹介します。

![20190611-142930.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/1ca194ef-a4fa-ae05-61e8-6b9631f714de.png)

体感的に、`Thickness`と`Dilate`は同じくらいの値に調整すると大抵綺麗に見えると思います。

# Editorから変更する

FontAsset、もしくはTextMesh ProコンポーネントのInspectorからマテリアルを選択し、[Face]-[Dilate]と[Outline]-[Thickness]の値を調整してください。

<img width="312" alt="スクリーンショット 2019-06-11 14.33.00.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/49e9336e-4d2d-caf8-a233-c264500a56ab.png">

# スクリプトから変更する

```cs

void SetOutline(TMPro.TextMeshProUGUI tmp, float outlineWitdh, float dilateRate)
{
    tmp.outlineWidth = outlineWitdh;
    tmp.materialForRendering.SetFloat("_FaceDilate", dilateRate);
    tmp.UpdateFontAsset();
}
```


アウトライン幅はメソッドが用意されていますが、Dilateに関しては直接マテリアルのパラメータに代入する必要がある点がハマりどころです。`tmp.UpdateFontAsset()`は呼び出す前後の処理によっては不要かもしれません。

ちなみにコードには含めていませんが、`Thickness`の値域は`[0,1]`、`Dilate`の値域は`[-1,1]`です。

## 拡張メソッド版

拡張メソッドにしておいても便利そうだと思ったので載せておきます。

```cs:TextMeshProUGUIExtensions.cs
namespace TMPro
{
    public static class TextMeshProUGUIExtensions
    {
        public static void SetOutline(this TextMeshProUGUI tmp, float outlineWitdh, float dilateRate)
        {
            tmp.outlineWidth = outlineWitdh;
            tmp.materialForRendering.SetFloat("_FaceDilate", dilateRate);
            tmp.UpdateFontAsset();
        }
    }
}
```

拡張メソッドを呼び出すためには`TMPro`をusingする必要がある点に注意です。

```呼び出し側.cs
using TMPro:

public class Hoge
{
    TextMeshProUGUI title;

    public void EnableOutline()
    {
        title.SetOutline(0.5f, 0.5f);
    }
}
```


# 参考

【Unity】TextMesh Pro でアウトラインを太くしたら文字が潰れてしまう現象を防ぐ方法 - コガネブログ
http://baba-s.hatenablog.com/entry/2018/09/18/120000
