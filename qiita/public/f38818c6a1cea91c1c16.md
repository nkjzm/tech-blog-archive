---
title: UnityのTimelineでオーディオの再生終了をループで待つ
tags:
  - Unity
private: false
updated_at: '2019-08-01T00:02:47+09:00'
id: f38818c6a1cea91c1c16
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

これは[『Unityゆるふわサマーアドベントカレンダー2019』](https://qiita.com/nkjzm/items/7c933bb5c772a0b75512)の初日の記事です。今回はUnityのTimelineに関するちょっと変わった使い方の紹介をしたいと思います。

UnityのTimelineはマルチトラックに演出等を作成するための標準機能で、主にゲーム中のムービーシーン・カットシーンの作成に役立つものです。標準のAnimationと異なり、復数のアセットを同期的に動かすことが出来るため、複雑な演出をほとんどコードを書かずに実現することが出来ます。

そんな優れたTimelineですが、基本的にはその名の通り時系列に沿った演出が主になります。しかし、コンテンツによってクリップの長さを可変にすることで出来る表現があるのではないかと思いました。そこで今回はオーディオの長さに応じて自動的に再生位置を調整するTrackを実装してみました。

# セリフを読み終わるまでループで待つTrack

こちらのリポジトリを改変する形で作りました。
参考: [tsubaki/Timeline-Loop](https://github.com/tsubaki/Timeline-Loop)

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">これはブログ埋め込み用の動画です <a href="https://t.co/mgtmNskpSW">pic.twitter.com/mgtmNskpSW</a></p>&mdash; Nakaji Kohki / リリカちゃん (@nkjzm) <a href="https://twitter.com/nkjzm/status/1156552125364617217?ref_src=twsrc%5Etfw">July 31, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
© UTJ/UCL

音声が再生し終わるまで、`LoopClip`の上を繰り返しシークバーが移動している様子が確認出来ると思います。

## 実装

ほぼほぼtsubakiさんのままですが、折角なので解説込みで紹介します。

まずTimelineの基本的な構成の話です。イメージとしては`TrackAsset`という枠を用意して、その中に`PlayableAsset`というクリップを配置します。そして`PlayableAsset`の位置に合わせて`PlayableBehaviour`のライフサイクルが回りだす感じです。`PlayableBehaviour`は実行時に生成されるため、Hierarchy上の参照等は`PlayableAsset`から受け渡してもらう必要があります。
<img width="849" alt="afsadfas.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/09fb7ff0-04e7-5c36-a02c-af6dae8e7812.png">

主に3種類のスクリプトに分かれているため一見複雑ですが、`PlayableBehaviour`を動かすためにゴニョゴニョ準備をしている、というイメージがわかりやすいと思います。
参考: [そろそろUnity2017のTimelineの基礎を押さえておこう - 渋谷ほととぎす通信](https://www.shibuya24.info/entry/timeline_basis)

では`PlayableBehaviour`を継承したこのクラスから紹介していきます。

```LoopBehaviour.cs
using System;
using UnityEngine;
using UnityEngine.Playables;

[Serializable]
public class LoopBehaviour : PlayableBehaviour
{
    public PlayableDirector director { get; set; }
    public WaitTimeline waitTimeline { get; set; }
    public AudioSource audioSource { get; set; }
    public AudioClip audioClip { get; set; }
    public override void OnBehaviourPlay(Playable playable, FrameData info)
    {
        if (!audioSource.isPlaying)
        {
            audioSource.PlayOneShot(audioClip, 1);
        }
    }
    float timer = 0f;
    public override void PrepareFrame(Playable playable, FrameData info)
    {
        timer += Time.deltaTime;
        if (timer < audioClip.length)
        {
            return;
        }
        waitTimeline.trigger = true;
    }
    public override void OnBehaviourPause(Playable playable, FrameData info)
    {
        if (waitTimeline.trigger == true)
        {
            waitTimeline.trigger = false;
            return;
        }
        director.time -= playable.GetDuration();
    }
}
```

`PlayableBehaviour`はタイミングに応じていくつかの関数が呼び出されます。今回のイメージとしては以下の様になっています。

<img width="542" alt="fsdfasggg.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/da951ff0-2545-49b5-1347-72ab818c49bf.png">

まずは`PlayableAsset`の再生時に実行される`OnBehaviourPlay()`では音声の再生をしています。

```.cs
public override void OnBehaviourPlay(Playable playable, FrameData info)
{
    if (!audioSource.isPlaying)
    {
        audioSource.PlayOneShot(audioClip, 1);
    }
}
```

続く`PrepareFrame()`は毎フレーム呼ばれる関数で、経過時間の計測を行なっています。また、経過時間が`audioClip`の長さを超えた時に`trigger`をTrueにしています。

```.cs
public override void PrepareFrame(Playable playable, FrameData info)
{
    timer += Time.deltaTime;
    if (timer < audioClip.length)
    {
        return;
    }
    waitTimeline.trigger = true;
}
```

最後の`OnBehaviourPause()`は名前からは想像しづらいのですが、ポーズした時だけでなく`PlayableAsset`の最後のフレームでも呼び出される関数です。この時に`trigger`がTrue、つまり再生が終わっていたらそのままにし、終わっていなければTimelineの時間を巻き戻しています。

```.cs
public override void OnBehaviourPause(Playable playable, FrameData info)
{
    if (waitTimeline.trigger == true)
    {
        waitTimeline.trigger = false;
        return;
    }
    director.time -= playable.GetDuration();
}
```

`LoopBehaviour`を実行するための参照は`PlayableAsset`を継承したクラスで行なっています。Hierarchy上の参照に関しては`CreatePlayable(PlayableGraph graph, GameObject owner)`の`owner`、つまりPlayableDirectorコンポーネントを持つGameObjectを経由して取得しています。

```LoopClip.cs
using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[Serializable]
public class LoopClip : PlayableAsset, ITimelineClipAsset
{
    public ClipCaps clipCaps { get { return ClipCaps.None; } }

    [SerializeField]
    AudioClip audioClip = null;

    public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
    {
        var playable = ScriptPlayable<LoopBehaviour>.Create(graph);
        LoopBehaviour beheviour = playable.GetBehaviour();
        beheviour.director = owner.GetComponent<PlayableDirector>();
        beheviour.waitTimeline = owner.GetComponent<WaitTimeline>();
        beheviour.audioSource = owner.GetComponent<AudioSource>();
        beheviour.audioClip = audioClip;
        return playable;
    }
}
```

再生する`AudioClip`だけは`PlayableAsset`毎に異なるため、`PlayableAsset`のInspector上から指定する形式にしています。

<img width="559" alt="スクリーンショット 2019-07-31 22.50.58.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/8f8f4e0d-fe5c-e54d-1bc7-3862965336ff.png">

最後は`PlayableAsset`を配置するための`TrackAsset`の実装です。これは単に継承して`TrackClipType`で紐付けをするだけでした。

```LoopTrack.cs
using UnityEngine.Timeline;

[TrackColor(1f, 0.2794118f, 0.7117646f)]
[TrackClipType(typeof(LoopClip))]
public class LoopTrack : TrackAsset
{
}
```

## LoopClip配置時のコツ

ループ時には再生位置が巻き戻るため、再生中のアニメーションが不自然に切り替わってしまう発生しました。

今回は再生する`AudioClip`の長さの等倍の感覚で再生することで、切り替わり時の違和感を軽減させられました。

# 最後に

元々はTimelineでノベルエディタのようなようなものを作りたくて検証しはじめました。Timelineのダイナミックな演出と長さが異なるセリフの効率的な管理を両立できると思ったのですが、ループ中の制約がかなり厳しいことに気が付きました。動的に出来るメリットとしては他にも、音声を外部から参照できる形にして、ユーザーがセリフを差し替えられるツールなども作れると思います。[Default Playables](https://assetstore.unity.com/packages/essentials/default-playables-95266)を使えば字幕なども出すことが出来るので、もしやる気があったら作ったみたいと思います。

そんな感じのゆるゆわ記事でした。明日の[『Unityゆるふわサマーアドベントカレンダー2019』](https://qiita.com/nkjzm/items/7c933bb5c772a0b75512)は[@pCYSl5EDgo](https://twitter.com/pCYSl5EDgo)さんによる「LINQ to NativeArrayについてなんか書く」です。お楽しみに。





