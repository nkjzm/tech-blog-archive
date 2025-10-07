---
title: 【Unity】uGUIで使える『Joystick Pack』をもっと便利に拡張してみる
tags:
  - Unity
private: false
updated_at: '2019-08-13T10:15:38+09:00'
id: 2c977aee580aed001b05
organization_url_name: null
slide: false
ignorePublish: false
---
![Aug-13-2019 10-13-26.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/d4134203-9a4b-c9b5-4b1d-677ed5318f87.gif)
この記事は[「Unity アセット真夏のアドベントカレンダー 2019 Summer!」](http://assetstore.info/eventandcontest/adventcalendar/eventandcontestadventcalendarasset-adventcalendar2019summer/)10日目の記事です。

# はじめに

今回はuGUIベースのバーチャルパッド(Joystick)を実現できる[「Joystick Pack」](https://assetstore.unity.com/packages/tools/input-management/joystick-pack-107631?utm_source=jppt&utm_medium=20190810)の使い方と応用を紹介しようと思います。

![fbba37d9-267d-421b-80f5-524be5582312.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/6b4149d0-1294-673e-2a47-e362751ddb2e.jpeg)
[Joystick Pack](https://assetstore.unity.com/packages/tools/input-management/joystick-pack-107631?utm_source=jppt&utm_medium=20190810)

# Joystick Packの紹介

## Joystickの種類

4種類の挙動をするJoystickが用意されています

### Fixed Joystick

位置が固定された基本的なJoystickです。
![Aug-13-2019 09-00-31.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/47c0f7f1-f7ca-2d1f-85ec-a3ab41d260be.gif)

### Floating Joystick

設定されたRectTransformの範囲内ならどこからでも使えるJoystickです。
![Aug-13-2019 09-02-44.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/67e50fef-6182-5998-79b4-b354fd813776.gif)

### Dynamic Joystick

Floating Joystickの機能に加え、動かした方向に基準が動いていくJoystickです。
![Aug-13-2019 09-05-58.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/41d9b3ec-da0f-59ba-3148-ec2dfb6a6c9c.gif)

### Variable Joystick

上記3つのJoystickを動的に切り替えることができるJoyStickです。ユーザー設定に応じて切り替えるような使い方が出来そうです。(Scriptからは`VariableJoystick.SetMode(JoystickType)`で切替可能)
<img width="265" alt="スクリーンショット 2019-08-13 9.06.42.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/5d7cc80f-0bf2-dc20-2a85-fc10de5aa839.png">

## デザインの種類

計24種類のデザインが予め用意されています。

### 全方位用背景(6種類)

![Aug-13-2019 09-11-51.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/de566874-8f49-637b-16f3-3867d3a66d7a.gif)

### ハンドル(6種類)

![Aug-13-2019 09-13-00.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/a57eab20-8a0e-fbc0-a189-daed8573b134.gif)

### 横方向用背景(6種類)

![Aug-13-2019 09-13-54.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/239c097d-0990-3d2b-6e6a-b4901b309629.gif)

### 縦方向用背景(6種類)

![Aug-13-2019 09-14-59.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/5dc834b3-d5e7-4347-b9b9-7209158c6ee0.gif)

## 設定項目

共通で動作に関する設定が出来ます。

<img width="263" alt="スクリーンショット 2019-08-13 9.19.33.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/e7cde7bb-b40c-0638-8d6e-f89199d27237.png">

- Handle Range
    - ハンドルが動く範囲
    - 背景画像の半径を1としたスケール
- Dead Zone
    - ハンドルが動くまでの閾値
    - 背景画像の半径を1としたスケール
- Axis Options
    - `Both`: 全方位
    - `Horizontal`: 縦方向
    - `Vertical`: 横方向
- Snap X
    - `true`の場合、0か1を返す
- Snap Y
    - `true`の場合、0か1を返す

## 使い方

参照を取得して`float`か`Vector2`として受け取る。

```cs
using UnityEngine;

public class Test : MonoBehaviour
{
    [SerializeField] Joystick joystick = null;
    void Start()
    {
        float horizontal = joystick.Horizontal;
        float vertical = joystick.Vertical;
        Vector2 direction = joystick.Direction;
    }
}
```

# 応用①: 固定っぽいのに実際はどこからでも操作できるJoystick

画面下部に表示されているが、実際にはタップした座標が基準になっています。

![Aug-13-2019 09-34-42.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/7fa049c6-d94e-6350-72b7-a251caa0bc60.gif)

[「アーチャー伝説」](https://apps.apple.com/jp/app/%E3%82%A2%E3%83%BC%E3%83%81%E3%83%A3%E3%83%BC%E4%BC%9D%E8%AA%AC/id1453651052)などで使われている方式です。特徴として、ユーザーに操作しやすい領域を示しつつも、実際の操作時は方向だけ意識すれば思ったとおりの操作ができます。

## 実装

全てのJoystickの親クラスになっている`Joystick`を継承して新たなクラスを作ります。

```cs:FixedFloatingJoystick.cs
using UnityEngine;
using UnityEngine.EventSystems;

public class FixedFloatingJoystick : Joystick
{
    Vector2 InitPos = Vector2.zero;
    protected override void Start()
    {
        InitPos = background.anchoredPosition;
        base.Start();
    }

    public override void OnPointerDown(PointerEventData eventData)
    {
        background.anchoredPosition = ScreenPointToAnchoredPosition(eventData.position);
        background.gameObject.SetActive(true);
        base.OnPointerDown(eventData);
    }

    public override void OnPointerUp(PointerEventData eventData)
    {
        background.anchoredPosition = InitPos;
        base.OnPointerUp(eventData);
    }
}
```

# 応用②: Joystickの位置をRectTransformで設定しやすくする

とても便利な[「Joystick Pack」](https://assetstore.unity.com/packages/tools/input-management/joystick-pack-107631?utm_source=jppt&utm_medium=20190810)ですが、少しだけ不満がありました。それはJoystickの位置の調整が左下のアンカー基準でしか出来ないことです。(そういう実装になっているため)

<img width="264" alt="スクリーンショット 2019-08-13 9.44.46.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/7d527636-716d-bbda-788d-2976fbd8629b.png">

左下アンカーでどういう時に困るかというと、例えば下記のように画面下部中央に設置した場合です。左はiPhone XSに合わせたサイズですが、iPhone 4のCanvasサイズに変えると基準が中央からずれてしまうことが分かります。

![afadsfasdfa.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/10e67243-7f7a-9342-a980-aa5f44790c4d.png)

対策として、継承先クラスで実行時にアンカー位置を修正する処理を入れてやりました。

```Joystickを継承したクラス.cs
    protected override void Start()
    {
        background.SetAnchorWithKeepingPosition(0, 0);
        base.Start();
    }
```

`SetAnchorWithKeepingPosition`は下記の記事で紹介している拡張メソッドです。これによって、エディタ上では任意のアンカーで位置の調整ができるようになりました。

[uGUIで座標を変えずにPivotとAnchorの値を変えるための拡張メソッド(RectTransform) - Qiita](https://qiita.com/nkjzm/items/297fb6921d5caca3eca9)

# 応用③: 入力開始・終了のタイミングを通知する

入力開始と終了のタイミングで処理を挟みたい場合があったので、通知機能を実装してみました。

## 使い方

Joystickが押されたタイミングと離されたタイミングで、以下の様に通知が飛んできます。

```cs
[SerializeField] NotifableJoystick joystick = null;
void Start()
{
    joystick.PressedDown.Subscribe(_ =>
    {
        Debug.Log("押された");
    }).AddTo(gameObject);

    joystick.PressedUp.Subscribe(_ =>
    {
        Debug.Log("離された");
    }).AddTo(gameObject);
}
```

## 実装

[「UniRx」](https://github.com/neuecc/UniRx)を使ってイベントを実装してみました。同様に`JoyStick`を継承して拡張しています。


```cs:NotifableJoystick.cs
using UnityEngine;
using UnityEngine.EventSystems;
using UniRx;
using System;

public class NotifableJoystick : Joystick
{
    public IObservable<Unit> PressedDown { get { return PressedDownSubject.AsObservable(); } }
    Subject<Unit> PressedDownSubject = new Subject<Unit>();
    public IObservable<bool> PressedUp { get { return PressedUpSubject.AsObservable(); } }
    Subject<bool> PressedUpSubject = new Subject<bool>();
    bool isPressing = false;
    public override void OnPointerDown(PointerEventData eventData)
    {
        PressedDownSubject.OnNext(Unit.Default);
        isPressing = true;
        base.OnPointerDown(eventData);
    }
    public override void OnPointerUp(PointerEventData eventData)
    {
        if (isPressing)
        {
            PressedUpSubject.OnNext(true);
            isPressing = false;
        }
        base.OnPointerUp(eventData);
    }
    protected override void HandleInput(float magnitude, Vector2 normalised, Vector2 radius, Camera cam)
    {
        base.HandleInput(magnitude, normalised, radius, cam);
        if (magnitude >= DeadZone && isPressing)
        {
            PressedUpSubject.OnNext(false);
            isPressing = false;
        }
    }
}
```

# 最後に

[「Joystick Pack」](https://assetstore.unity.com/packages/tools/input-management/joystick-pack-107631?utm_source=jppt&utm_medium=20190810)はuGUIベースで使えて、しかも無料の素晴らしいアセットです。この記事がぜひ参考になると嬉しいです。

今回の記事で紹介したコードのライセンスは、特に記載がない限りCC0です。

# 関連

- [Unity アセット真夏のアドベントカレンダー 2019 Summer!](http://assetstore.info/eventandcontest/adventcalendar/eventandcontestadventcalendarasset-adventcalendar2019summer/)
- [【Unity】uGUI でジョイスティック（バーチャルパッド）を使用できる「Joystick Pack」紹介（無料） - コガネブログ](http://baba-s.hatenablog.com/entry/2018/02/22/085100)
- [Virtual Joystick Packの使い方](https://nijigen307439971.wordpress.com/2019/01/08/virtual-joystick-pack%e3%81%ae%e4%bd%bf%e3%81%84%e6%96%b9/)
