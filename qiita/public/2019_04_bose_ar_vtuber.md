---
title: Bose ARでVTuberっぽいアプリを作る方法
published_at: '2019-04-01 00:02'
private: false
tags:
  - Unity
  - VR
updated_at: '2019-04-01T00:02:11+09:00'
id: 9dfd713b6226debf9be8
organization_url_name: null
slide: false
---
## はじめに

BoseのARグラスを使ってVTuberっぽいアプリを作りました。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">BoseのARグラスを使って自分のアバターを動かしてみました！<br>Bose Framesはサングラス型のオーディオデバイスですが、加速度が拾えるIMUやマイクが搭載されています。今回はそれを活用して、アバターの顔の向きや口の開閉に反映されるようにしてみました。タップで表情も変えられます。 <a href="https://twitter.com/hashtag/BoseFrames?src=hash&amp;ref_src=twsrc%5Etfw">#BoseFrames</a> <a href="https://t.co/I9NrzIBhPc">pic.twitter.com/I9NrzIBhPc</a></p>&mdash; Nakaji Kohki / リリカちゃん (@nkjzm) <a href="https://twitter.com/nkjzm/status/1108859682200805377?ref_src=twsrc%5Etfw">2019年3月21日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

スマホを使ってアバターを動かすアプリはいくつかありますが、ARグラスのセンサーのみを使って動かしている点が特徴です。スマホのカメラなどを使っていないため、上記動画のように画面を相手側に向けても動かすことができます。

<blockquote class="twitter-tweet" data-conversation="none" data-lang="ja"><p lang="ja" dir="ltr">単体で見るとこんな感じ。だいぶ可愛い。 <a href="https://t.co/mP804vxiR7">pic.twitter.com/mP804vxiR7</a></p>&mdash; Nakaji Kohki / リリカちゃん (@nkjzm) <a href="https://twitter.com/nkjzm/status/1108880522283909121?ref_src=twsrc%5Etfw">2019年3月21日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>


今回は作成の手順を紹介したいと思います。

### 環境

- Mac OS 10.14.3
- Unity 2018.3.9f1
- iOS 12.1.2

ちなみにBose AR SDKの対応プラットフォームは以下のとおりです。

- Android (5.0+)
- iOS (11.4+)

## Bose ARについて

![Bose_Frames.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/b9066b3c-0d41-fd27-e509-2b9699b7cb59.jpeg)

引用元: https://globalpressroom.bose.com/

オーディオデバイスメーカーのBoseは2019.1にBose FramesというARグラスの販売を開始しています。形状が異なる2種類が発売されていますが機能としては同じです。ARグラスといっても映像表示などはありません。前面にはサングラス用のレンズが入っています。では何がARかというと、Bose Framesは音のARと呼ばれています。内部にIMUセンサーを持ち、頭の方向によって聞こえる音を制御することが可能です。スピーカーは骨伝導ではありませんが、耳の少し手前位置に設置されており指向性のある音声が直接入ってくるイメージです。オーディオメーカーの製品だけあって音質は非常に良いと思いました。

このBoseのARグラスですが、SDKがiOS/Android向けだけでなく、なんとUnity用SDKも用意されています。実際に2019.3開催のSXSW2019ではBose ARをつかったゲームアプリの展示なども行われていました。私もたまたま会場で購入することができたので、SDKを使ってちょっとしたアプリを作ってみた流れになります。

## Bose ARの開発手引き

まずはSDKを入手します。BoseのDeveloper Portalにアクセスし、開発者登録を行います。完了すると即時ログインできるようになるので、SDKをダウンロードしてください。

Bose Developer Portal | Bose AR Beta
https://developer.bose.com/bose-ar

Unityプロジェクトを立ち上げます。先程のSDKをインポートしてください。

### デモアプリの確認

デモアプリを入れてみましょう。ビルドしたいプラットフォームにSwitch Platformをしてから、`Tools > Bose Wearable > Build Wearable Demo`を選択してください。XCodeなどが立ち上がったらそのままビルドしてみてください。

![D2MLujvUkAAJZDV.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/b9be2d76-f3ae-f266-b7cf-2b0a97215ff3.jpeg)

こんなアプリが立ち上がります。

- Basic Demo
    - IMUの動作の様子を確認できます
- Advanced Demo
    - IMUを使って立体音源を体験することができます
- Gesture Demo
    - IMUを応用した3つのジェスチャーを体験できます
        - タップ(縁を2回連続でタップする)
        - Yes (顔を上下に振る)(反応しなかった)
        - No (顔を左右に振る)(反応しなかった)

### VTuberアプリの作成

サンプルのBasicDemoシーンを改変してVTuberアプリを作っていきます。

主な手順としては以下の通りです。

1. [UniVRM](https://github.com/dwango/UniVRM/releases)をインポート
2. VRMモデルをインポート。今回は[リリカちゃん](https://hub.vroid.com/characters/6874596705216592350/models/5941561814243096928)を利用しました。
3. IMUを反映させる
    - `RotationMatcher`に`Transform target`というメンバ変数を追加
    - `transform.rotation = frame.rotation`と同様に`target.localRotation = frame.rotation`を追加
    - `if (_mode == RotationReference.Relative)`の時も同様
    - InspectorビューでTargetにVRMモデルの首のジョイント(`J_Bip_C_Head`)を指定
4. リップシンクを実装する
    - [こちらの記事](https://qiita.com/nkjzm/items/1ba5dfc0575ed6ddd8ff#%E5%8F%A3%E3%83%91%E3%82%AF%E3%81%AE%E5%AE%9F%E8%A3%85)のスクリプトを利用
    - Bose Framesのマイクの場合、Power=8, Threshold=0.5くらいがベスト
    - iOSの場合、PlayerSettingsから`Microphone Usage Description`にテキストを入れないと実行時にエラーが出るので要注意。
5. 表情変更を実装する
  - 以下の`Smile`コンポーネントをアタッチ
  - SDKに入っている`Gesture Detector`コンポーネントをアタッチ
    - Gestureを`Double Tap`に設定
    - `OnGestureDetected`に`Smile.OnSmile()`を設定
6. ビルドして完成 

```cs:Smile.cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRM;

public class Smile : MonoBehaviour
{
    [SerializeField]
    VRMBlendShapeProxy proxy;
    [SerializeField]
    AnimationCurve curve;


    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            Debug.Log("a");
            OnSmile();
        }
    }

    Coroutine coroutine;
    public void OnSmile()
    {
        if (coroutine != null)
        {
            StopCoroutine(coroutine);
            coroutine = null;
        }
        coroutine = StartCoroutine(SetSmile());
    }

    IEnumerator SetSmile()
    {
        Debug.Log("b");
        var time = 0f;
        while (time < curve.keys[curve.keys.Length - 1].time)
        {
            proxy.SetValue(BlendShapePreset.Fun, curve.Evaluate(time));
            time += Time.deltaTime / 2f;
            yield return null;
        }
        yield return new WaitForSeconds(2f);
        time = 0f;
        while (time < curve.keys[curve.keys.Length - 1].time)
        {
            proxy.SetValue(BlendShapePreset.Fun, 1 - curve.Evaluate(time));
            time += Time.deltaTime / 5f;
            yield return null;
        }
    }
}
```

問題なく進めば1時間くらいで出来ると思います。簡単にできて見栄えがするのでおすすめです。

## 最後に

Bose SDKはまだまだ遊び甲斐があるSDKだと思うので、また何か思いついたらやっていきたいと思います。

また、日本だと恐らく技適が通っていないので、電源を入れた瞬間に違法ですのでお気をつけください。


