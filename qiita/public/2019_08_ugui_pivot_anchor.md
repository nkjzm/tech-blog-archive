---
title: uGUIで座標を変えずにPivotとAnchorの値を変えるための拡張メソッド(RectTransform)
tags:
  - C#
  - Unity
private: false
updated_at: '2019-08-13T11:38:11+09:00'
id: 297fb6921d5caca3eca9
organization_url_name: null
slide: false
ignorePublish: false
---
## TL;DR

ソースコード: https://gist.github.com/nkjzm/1b31512c00aee93403427f14ebfb4db8

```cs
// 使い方
var rectTransform = transform as RectTransform;
// Pivotを(0.0f,0.0f)にする
rectTransform.SetPivotWithKeepingPosition(Vector2.zero);
// Pivotを(0.2f,0.7f)にする
rectTransform.SetPivotWithKeepingPosition(0.2f, 0.7f);
// Anchorを中心(0,5f,0.5f)にする
rectTransform.SetAnchorWithKeepingPosition(0.5f, 0.5f);
// AnchorMinを左下(0.0f,0.0f)、AnchorMacを右上(1.0f,1.0f)にする (ストレッチ)
rectTransform.SetAnchorWithKeepingPosition(Vector2.zero, Vector2.one);
```

## はじめに

みなさん、uGUIのレイアウトシステム使ってますか？

uGUI要素に付いている`RectTransform`を使うやつです。
<img width="264" alt="スクリーンショット 2018-11-18 17.33.27.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/8d70398b-5ca9-6318-102d-430745969f07.png">

適切に使うとiPhone XSとiPhone 8のように、解像度が異なるデバイスであっても単一の設定でレイアウトを組み上げることが出来ます。便利ですね！

![20181118-002633.png](https://qiita-image-store.s3.amazonaws.com/0/55365/9fbd01c1-31f6-45b0-5ae9-7b6973409817.png) ![20181118-002658.png](https://qiita-image-store.s3.amazonaws.com/0/55365/269fed60-8ceb-fb60-1327-e335b283921e.png)
_左: iPhone X/XR, 右: iPhone 6/7/8_

使い方についてはテラシュールブログさんの記事とかを参考にしてください。
[UnityのuGUIのレイアウト調整機能について解説してみる（RectTransform入門） - テラシュールブログ](http://tsubakit1.hateblo.jp/entry/2014/12/19/033946)

そんな便利なuGUIのレイアウトシステムなんですけど、開発をしているとAnchorやPivotをスクリプトから変更したくなる場合があると思います。僕はありました。

例えばですが、複数解像度対応のためにPivotを左端`(0.0,0.5)`に置いたが、拡大アニメーションの時は起点を中心`(0.5,0.5)`にしたい場合などです。

## 問題

そんな時、安易に`RectTransform.pivot`の値とかを変えてみると、元の座標とずれてしまうと思います。
実はInspectorからRectTransformを操作している時はUnityエディタが親切に座標を保ってくれていたのですが、スクリプトから変更すると対応する値**だけ**が変更されるので、当然の挙動です。


ちなみにInspectorビューのハンバーガーメニューから`Debug`を選択すると内部の値を確認できます。
<img width="396" alt="スクリーンショット 2018-11-18 17.54.56.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/edbcca5a-78fc-c0c4-9171-f7eb2ed4d927.png">
<img width="266" alt="スクリーンショット 2018-11-18 17.55.04.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/914f280b-f430-b8d9-bb70-6b0f6ad82bf4.png">
_1番初めに載せたRectTransformのスクショと同じゲームオブジェクトの例_

そこで、今回は**元の座標を保ったままPivotやAnchorの値を変更することができるスクリプト**を作成しました。`RectTransform`の拡張メソッドとして作ったので使いやすいと思います。

## `RectTransformExtensions.cs`の使い方

ソースコードをプロジェクトにインポートしてください。

この記事の下部にもありますし、Gistにも上げてあります。
Gist: https://gist.github.com/nkjzm/1b31512c00aee93403427f14ebfb4db8

用意した拡張メソッドは以下の2つです。
PivotやAnchorはそれぞれ`Vector2`型の値として表現されていますが、直接`x`,`y`の値でも指定デキルように、いくつかオーバーロードも用意してあります。

```cs
// 座標を保ったままPivotを変更するメソッド
void SetPivotWithKeepingPosition(Vector2 targetPivot)
// 座標を保ったままAnchorを変更する
void SetAnchorWithKeepingPosition(Vector2 targetMinAnchor, Vector2 targetMaxAnchor)
```

使い方は簡単で、変更したいRectTransformから以下のように呼び出してください。

```cs
var rectTransform = transform as RectTransform;
// Pivotを(0.0f,0.0f)にする
rectTransform.SetPivotWithKeepingPosition(Vector2.zero);
// Pivotを(0.2f,0.7f)にする
rectTransform.SetPivotWithKeepingPosition(0.2f, 0.7f);
// Anchorを中心(0,5f,0.5f)にする
rectTransform.SetAnchorWithKeepingPosition(0.5f, 0.5f);
// AnchorMinを左下(0.0f,0.0f)、AnchorMacを右上(1.0f,1.0f)にする (ストレッチ)
rectTransform.SetAnchorWithKeepingPosition(Vector2.zero, Vector2.one);
```

Anchorは`AnchorMin`と`AnchorMax`が一致していない場合はストレッチといわれるような指定(各AnchorからRect端までの長さを指定＝大きさが変化する)になるのですが、その場合でも対応しているはずです。

もし不具合等あれば教えてほしいです。


## スクリプト

```cs:RectTransformExtensions.cs
using UnityEngine;

public static class RectTransformExtensions
{
    /// <summary>
    /// 座標を保ったままPivotを変更する
    /// </summary>
    /// <param name="rectTransform">自身の参照</param>
    /// <param name="targetPivot">変更先のPivot座標</param>
    public static void SetPivotWithKeepingPosition(this RectTransform rectTransform, Vector2 targetPivot)
    {
        var diffPivot = targetPivot - rectTransform.pivot;
        rectTransform.pivot = targetPivot;
        var diffPos = new Vector2(rectTransform.sizeDelta.x * diffPivot.x, rectTransform.sizeDelta.y * diffPivot.y);
        rectTransform.anchoredPosition += diffPos;
    }
    /// <summary>
    /// 座標を保ったままPivotを変更する
    /// </summary>
    /// <param name="rectTransform">自身の参照</param>
    /// <param name="x">変更先のPivotのx座標</param>
    /// <param name="y">変更先のPivotのy座標</param>
    public static void SetPivotWithKeepingPosition(this RectTransform rectTransform, float x, float y)
    {
        rectTransform.SetPivotWithKeepingPosition(new Vector2(x, y));
    }
    /// <summary>
    /// 座標を保ったままAnchorを変更する
    /// </summary>
    /// <param name="rectTransform">自身の参照</param>
    /// <param name="targetAnchor">変更先のAnchor座標 (min,maxが共通の場合)</param>
    public static void SetAnchorWithKeepingPosition(this RectTransform rectTransform, Vector2 targetAnchor)
    {
        rectTransform.SetAnchorWithKeepingPosition(targetAnchor, targetAnchor);
    }
    /// <summary>
    /// 座標を保ったままAnchorを変更する
    /// </summary>
    /// <param name="rectTransform">自身の参照</param>
    /// <param name="x">変更先のAnchorのx座標 (min,maxが共通の場合)</param>
    /// <param name="y">変更先のAnchorのy座標 (min,maxが共通の場合)</param>
    public static void SetAnchorWithKeepingPosition(this RectTransform rectTransform, float x, float y)
    {
        rectTransform.SetAnchorWithKeepingPosition(new Vector2(x, y));
    }
    /// <summary>
    /// 座標を保ったままAnchorを変更する
    /// </summary>
    /// <param name="rectTransform">自身の参照</param>
    /// <param name="targetMinAnchor">変更先のAnchorMin座標</param>
    /// <param name="targetMaxAnchor">変更先のAnchorMax座標</param>
    public static void SetAnchorWithKeepingPosition(this RectTransform rectTransform, Vector2 targetMinAnchor, Vector2 targetMaxAnchor)
    {
        var parent = rectTransform.parent as RectTransform;
        if (parent == null) { Debug.LogError("Parent cannot find."); }

        var diffMin = targetMinAnchor - rectTransform.anchorMin;
        var diffMax = targetMaxAnchor - rectTransform.anchorMax;
        // anchorの更新
        rectTransform.anchorMin = targetMinAnchor;
        rectTransform.anchorMax = targetMaxAnchor;
        // 上下左右の距離の差分を計算
        var diffLeft = parent.rect.width * diffMin.x;
        var diffRight = parent.rect.width * diffMax.x;
        var diffBottom = parent.rect.height * diffMin.y;
        var diffTop = parent.rect.height * diffMax.y;
        // サイズと座標の修正
        rectTransform.sizeDelta += new Vector2(diffLeft - diffRight, diffBottom - diffTop);
        var pivot = rectTransform.pivot;
        rectTransform.anchoredPosition -= new Vector2(
             (diffLeft * (1 - pivot.x)) + (diffRight * pivot.x),
             (diffBottom * (1 - pivot.y)) + (diffTop * pivot.y)
        );
    }
    /// <summary>
    /// 座標を保ったままAnchorを変更する
    /// </summary>
    /// <param name="rectTransform">自身の参照</param>
    /// <param name="minX">変更先のAnchorMinのx座標</param>
    /// <param name="minY">変更先のAnchorMinのy座標</param>
    /// <param name="maxX">変更先のAnchorMaxのx座標</param>
    /// <param name="maxY">変更先のAnchorMaxのy座標</param>
    public static void SetAnchorWithKeepingPosition(this RectTransform rectTransform, float minX, float minY, float maxX, float maxY)
    {
        rectTransform.SetAnchorWithKeepingPosition(new Vector2(minX, minY), new Vector2(maxX, maxY));
    }
}
```

Licenseはちゃんと書いてありませんが、MITでお願いします。(責任免除の条約を適用したいため)

### ちょっとした解説

`SetPivotWithKeepingPosition`の方は簡単です。Pivotを変えると元の基準となる位置からPivotの変化量に応じて座標がずれるので、変化量から実際にずれる座標を計算して差し引いているだけです。

`SetAnchorWithKeepingPosition`は以外と苦戦しました。
まずAnchorは自分の座標の基準となる親のRectTransformの値が影響してくるため、計算が複雑になります。
アプローチしては`SetPivotWithKeepingPosition`と同様にずれた分を修正するだけなのですが、座標だけでなく`sizeDelta`の値をも修正しなければならない点が要注意です。

## 感想

`RectTransform`はストレッチと言われるモードがありますが、内部では同じように扱えるようになっていました。理解が深まってよかったです。


