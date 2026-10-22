---
title: "【Unity】C#で点と扇形の内外判定の実装 (EditModeテスト付き)"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["C#", "Unity"]
published: true
---
# はじめに

こちらの記事を参考に、C#で点と扇形の内外判定を実装してみました。
[[Python3]2次元平面の扇型の内外判定 - Qiita](https://qiita.com/okamoto950712/items/a3daa8fa0a55a606269e)


# 実装

``` MathUtils.cs
using UnityEngine;

/// <summary>
/// 計算に関するUtilityクラス
/// </summary>
public class MathUtils
{
    /// <summary>
    /// 点と円の内外判定を行う
    /// </summary>
    /// <param name="target">判定する座標</param>
    /// <param name="radius">円の半径</param>
    /// <returns>点が円の内部にあれば真を返す</returns>
    public static bool IsInsideOfCircle(Vector2 target, float radius)
    {
        if (Mathf.Pow(target.x, 2) + Mathf.Pow(target.y, 2) <= Mathf.Pow(radius, 2))
        {
            return true;
        }
        return false;
    }

    /// <summary>
    /// 点と円の内外判定を行う
    /// </summary>
    /// <param name="target">判定する座標</param>
    /// <param name="center">円の中心座標</param>
    /// <param name="radius">円の半径</param>
    /// <returns>点が円の内部にあれば真を返す</returns>
    public static bool IsInsideOfCircle(Vector2 target, Vector2 center, float radius)
    {
        var diff = target - center;
        return IsInsideOfCircle(diff, radius);
    }

    /// <summary>
    /// 点と扇形の内外判定を行う
    /// </summary>
    /// <param name="target">判定する座標</param>
    /// <param name="center">扇形の中心座標</param>
    /// <param name="startDeg">扇形の開始角(度数法)</param>
    /// <param name="endDeg">扇形の終了角(度数法)</param>
    /// <param name="radius">扇形の半径</param>
    /// <returns>点が扇形の内部にあれば真を返す</returns>
    public static bool IsInsideOfSector(Vector2 target, Vector2 center, float startDeg, float endDeg, float radius)
    {
        var diff = target - center;
        var startRad = startDeg * Mathf.Deg2Rad;
        var endRad = endDeg * Mathf.Deg2Rad;
        var startVec = new Vector2(Mathf.Cos(startRad), Mathf.Sin(startRad));
        var endVec = new Vector2(Mathf.Cos(endRad), Mathf.Sin(endRad));

        // 円の内外判定
        if (!IsInsideOfCircle(diff, radius))
        {
            return false;
        }

        // 扇型の角度が180度未満の場合
        if (GetCross2d(startVec, endVec) > 0)
        {
            // diff が startVec より左側 *かつ* diff が endVec より右側の時
            if (GetCross2d(startVec, diff) >= 0 && GetCross2d(endVec, diff) <= 0)
            {
                return true;
            }
            return false;
        }
        // 扇型の角度が180度以上の場合
        else
        {
            // diff が startVec より左側 *または* diff が endVec より右側の時
            if (GetCross2d(startVec, diff) >= 0 || GetCross2d(endVec, diff) <= 0)
            {
                return true;
            }
            return false;
        }
    }

    static float GetCross2d(Vector2 a, Vector2 b)
    {
        return GetCross2d(a.x, a.y, b.x, b.y);
    }

    static float GetCross2d(float ax, float ay, float bx, float by)
    {
        return ax * by - bx * ay;
    }
}
```

## 解説

流れとしてははじめに貼ったリンクの通りではあるのですが、一応解説です。

### 円の内外判定

まず扇型を元となる円の内部にあるかどうかを判定します。

``` .cs
/// <summary>
/// 点と円の内外判定を行う
/// </summary>
/// <param name="target">判定する座標</param>
/// <param name="radius">円の半径</param>
/// <returns>点が円の内部にあれば真を返す</returns>
public static bool IsInsideOfCircle(Vector2 target, float radius)
{
    if (Mathf.Pow(target.x, 2) + Mathf.Pow(target.y, 2) <= Mathf.Pow(radius, 2))
    {
        return true;
    }
    return false;
}
```

三平方の定理から判定しています。

### 扇型の表現

``` .cs
/// <summary>
/// 点と扇形の内外判定を行う
/// </summary>
/// <param name="target">判定する座標</param>
/// <param name="center">扇形の中心座標</param>
/// <param name="startDeg">扇形の開始角(度数法)</param>
/// <param name="endDeg">扇形の終了角(度数法)</param>
/// <param name="radius">扇形の半径</param>
/// <returns>点が扇形の内部にあれば真を返す</returns>
public static bool IsInsideOfSector(Vector2 target, Vector2 center, float startDeg, float endDeg, float radius)
```

![無題の図形描画.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/f74c38e3-5371-3406-b990-fb0ee67e8c41.jpeg)

引数からこんな感じで扇型の形が決まります。

### 扇型の内外判定

``` .cs
    // 扇型の角度が180度未満の場合
    if (GetCross2d(startVec, endVec) > 0)
    {
        // diff が startVec より左側 *かつ* diff が endVec より右側の時
        if (GetCross2d(startVec, diff) >= 0 && GetCross2d(endVec, diff) <= 0)
        {
            return true;
        }
        return false;
    }
    // 扇型の角度が180度以上の場合
    else
    {
        // diff が startVec より左側 *または* diff が endVec より右側の時
        if (GetCross2d(startVec, diff) >= 0 || GetCross2d(endVec, diff) <= 0)
        {
            return true;
        }
        return false;
    }
```

外積(`GetCross2d(Vector2 a, Vector2 b)`)を計算すると、ベクトル`a`からみてベクトル`b`がどちら側にあるかを判定することができます。

まず`if (GetCross2d(startVec, endVec) > 0)`が真であれば、`endVec`は`startVec`より左側、つまり扇型の角度は180度以下であることが分かります。
上の図でいうと、赤い線が`startVec`で、青い線が`endVec`です。

次に、それぞれの場合においても判定していきます。

#### 180度以下の場合

`startVec`よりも、原点から判定したい点に伸びるベクトルが左側にある
**かつ**
`endVec`よりも、原点から判定したい点に伸びるベクトルが右側にある
時、点は扇型の内部にあると言えます。

#### 180度以上の場合

さっきの逆で、
`startVec`よりも、原点から判定したい点に伸びるベクトルが右側にある
**または**
`endVec`よりも、原点から判定したい点に伸びるベクトルが左側にある
時、点は扇型の内部にあると言えます。


## テスト


EditModeでテストを書いてみました。
あんまり書き方わかってないのでアドバイスとかあればお待ちしております。
当たり前の話なんですけど、一回通ったテストがあると、リファクタリングとか最適化がやりやすかったです。

EditModeの使い方は、`Editor`フォルダ以下にコードを置く方法と、Assembly Definition Filesを使う方法があります。
詳しくはこちらを参照してください。
[Unity2017.3のAssembly Definition Filesを適切に設定してコンパイルにかかる時間を削減する - Qiita](https://qiita.com/splas_boomerang/items/aaad87dc7f7bc9703449#testrunner%E3%81%B8%E3%81%AE%E9%81%A9%E7%94%A8)


``` MathUtilsTest.cs
using UnityEngine;
using NUnit.Framework;
// AssertはNUnitのではなくUnityのものを使う
using Assert = UnityEngine.Assertions.Assert;

/// <summary>
/// MathUtilsのテストクラス
/// </summary>
public class MathUtilsTest
{
    [Test]
    public void IsInsideOfSectorTestRounded()
    {
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(0f, 0f), Vector2.zero, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(1f, 0f), Vector2.zero, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(0f, 1f), Vector2.zero, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(-1f, 0f), Vector2.zero, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(0f, -1f), Vector2.zero, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(1.1f, 0f), Vector2.zero, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(0f, 1.1f), Vector2.zero, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(-1.1f, 0f), Vector2.zero, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(0f, -1.1f), Vector2.zero, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(0.7f, 0.7f), Vector2.zero, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(-0.7f, -0.7f), Vector2.zero, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(1f, 1f), Vector2.zero, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(-1f, -1f), Vector2.zero, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(1.7f, 1.7f), new Vector2(1f, 1f), 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(-1.7f, -1.7f), new Vector2(-1f, -1f), 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(0.7f, 0.7f), new Vector2(2f, 2f), 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfCircle(new Vector2(-0.7f, -0.7f), new Vector2(-2f, -2f), 1f), false);
    }

    [Test]
    public void IsInsideOfSectorTest90deg()
    {
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(1f, 0f), Vector2.zero, 0f, 90f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0f, 1f), Vector2.zero, 0f, 90f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-1f, 0f), Vector2.zero, 0f, 90f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0f, -1f), Vector2.zero, 0f, 90f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.5f, 0.5f), Vector2.zero, 0f, 90f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.5f, -0.5f), Vector2.zero, 0f, 90f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-0.5f, 0.5f), Vector2.zero, 0f, 90f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-0.5f, -0.5f), Vector2.zero, 0f, 90f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(1f, 0f), Vector2.zero, 260f, 350f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0f, 1f), Vector2.zero, 260f, 350f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-1f, 0f), Vector2.zero, 260f, 350f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0f, -1f), Vector2.zero, 260f, 350f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.5f, 0.5f), Vector2.zero, 260f, 350f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.5f, -0.5f), Vector2.zero, 260f, 350f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-0.5f, 0.5f), Vector2.zero, 260f, 350f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-0.5f, -0.5f), Vector2.zero, 260f, 350f, 1f), false);
    }

    [Test]
    public void IsInsideOfSectorTest270deg()
    {
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(1f, 0f), Vector2.zero, 89f, 359f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0f, 1f), Vector2.zero, 89f, 359f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-1f, 0f), Vector2.zero, 89f, 359f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0f, -1f), Vector2.zero, 89f, 359f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.5f, 0.5f), Vector2.zero, 90f, 360f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.5f, -0.5f), Vector2.zero, 90f, 360f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-0.5f, 0.5f), Vector2.zero, 90f, 360f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-0.5f, -0.5f), Vector2.zero, 90f, 360f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(1f, 0f), Vector2.zero, -10f, 260f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0f, 1f), Vector2.zero, -10f, 260f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-1f, 0f), Vector2.zero, -10f, 260f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0f, -1f), Vector2.zero, -10f, 260f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.5f, 0.5f), Vector2.zero, -10f, 260f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.5f, -0.5f), Vector2.zero, -10f, 260f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-0.5f, 0.5f), Vector2.zero, -10f, 260f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(-0.5f, -0.5f), Vector2.zero, -10f, 260f, 1f), true);
    }

    [Test]
    public void IsInsideOfSectorTest30deg()
    {
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(1f, 0f), Vector2.zero, 0f, 30f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0f, 1f), Vector2.zero, 0f, 30f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.5f, 0.5f), Vector2.zero, 0f, 30f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.9f, 0.2f), Vector2.zero, 0f, 30f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0f, -1f), Vector2.zero, 260f, 290f, 1f), true);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(1f, 0f), Vector2.zero, 260f, 290f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.5f, -0.5f), Vector2.zero, 260f, 290f, 1f), false);
        Assert.AreEqual(MathUtils.IsInsideOfSector(new Vector2(0.2f, -0.9f), Vector2.zero, 260f, 290f, 1f), true);
    }
}
```
