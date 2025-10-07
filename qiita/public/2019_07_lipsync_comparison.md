---
title: VTuberなどに使われる主要なリップシンク方式の比較メモ
tags:
  - Unity
  - VR
private: false
updated_at: '2019-07-01T16:00:25+09:00'
id: 5fb4f4dbcdaa9bc7cc34
organization_url_name: null
slide: false
ignorePublish: false
---
## はじめに

**(この記事はエンジニア以外の方でも分かるような内容になっています)**

VTuberで使われる技術の一つにリップシンクというものがあります。発話に併せてアバターの口を人と同じように動かす技術のことです。

また、二次元寄りの表現をする場合には、本物の人と同じように滑らかに動かすよりも、緩急を付けてアニメ調の動きにした方が自然な場合もあります。

![Nov-30-2018 08-24-00 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/9fa4bab0-5b39-c999-b658-9adffcc7dbbe.gif)
[Live2Dでアニメ調のリップシンクを実現する『AniLipSync-live2d』の使い方 - Qiita](https://qiita.com/nkjzm/items/b0d283cf8b1f7fdcf91b)

このリップシンクを実現するにあたり、いくつかの方法が検討されています。この記事ではそれぞれの方式の長所短所を簡単にまとめたいと思います。紹介しているライブラリ等は全てUnity用のものになります。

## 画像認識による方法

映像から口の形を認識して反映させる方法です。iOSの「アニ文字」などがこの方式です。

参考: [速報：iPhone X「アニ文字」の使い方。サクサク顔認識、気軽に使えます - YouTube](https://www.youtube.com/watch?v=u4fnaMHsxR0)

### 長所

- 口の形を正確に認識できるため、リッチな表現がしやすい

### 短所

- 画像認識のためにカメラが必要となる
- アニメ調の表現には不向きな場合がある

### ライブラリ等

- ARKitのFace Tracking (iOSのみ)
    - 無料
- [Dlib FaceLandmark Detector](https://assetstore.unity.com/packages/tools/integration/dlib-facelandmark-detector-64314)
    - 有償 (OpenCVも必要)
    - 学習データが商用NG(要出典)
- [Single Face Tracker Plugin](https://assetstore.unity.com/packages/tools/integration/single-face-tracker-plugin-lite-version-30-face-tracking-points-90212)
    - 有償
    - 価格は高いが数少ない商用利用が可能な顔認識ライブラリ

## 音圧の大小による方法

音声の音量を口の大きさに反映させる方式です。喋っていない時は口が閉じていて、声を出すと音量に応じて口が開きます。シンプルな表現ですが、アニメ調の表現の場合、実はこのくらいで十分だったりします。

![Oct-18-2018 05-36-59 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/d3f87034-bc79-8fda-eaae-1c9998a95b4a.gif)
[【初心者向け】UnityとLive2Dで拡張しやすいVTuber配信システムを作る方法 - Qiita](https://qiita.com/nkjzm/items/1ba5dfc0575ed6ddd8ff#%E5%8F%A3%E3%83%91%E3%82%AF%E3%81%AE%E5%AE%9F%E8%A3%85)

同じ方式ですが、少し工夫した方式もあります。以下の例では音量のみからリップシンクをしていますが、いくつかの異なる口の動きになっていると思います。

![Dec-26-2018 13-23-42.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/8f3ec66c-7022-e066-e472-69fff1de3502.gif)
[[iOSでも動く] SALSAでバーチャルYouTuber向けのリップシンクを導入する方法 - Qiita](https://qiita.com/nkjzm/items/18c6ab7f5428076ab413)

どうしているかというと、音量の範囲に応じて口の形を変更しています。例えば、

- 小さい音の時は「お」の口
- 中くらいの音の時は「え」の口
- 大きい音の時は「あ」の口

といった具合です。高度な音声認識技術を使わなくても、工夫次第でこのくらいまで自然な動きを作れるという良い例だと思います。

### 長所

- マイクだけあれば良いため、構成がシンプル

### 短所

- 他の方式と比べ、表現力が低い
- 周りの雑音などで口が動いてしまう場合がある

### ライブラリ等

- [独自実装](https://qiita.com/nkjzm/items/1ba5dfc0575ed6ddd8ff#%E5%8F%A3%E3%83%91%E3%82%AF%E3%81%AE%E5%AE%9F%E8%A3%85)
    - シンプルなのでそう難しくない
- [SALSA With RandomEyes](https://assetstore.unity.com/packages/tools/animation/salsa-with-randomeyes-16944)
    - 有料
    - 上記の音圧の範囲毎に口の形をマッピングしてくれるライブラリ

## 音声認識による口形素推定

音声認識によりどんな音を発しているのかを推定して口の形に反映させる方法です。日本では母音の「あ」「い」「う」「え」「お」の5つを認識する方法が多いです。画像認識の方法は「口がどの形をしているか」を認識しているのに対し、この方法は「どの音を発しているか」をまず認識し、次に「その音を発する口の形はどうか」という流れです。

よく使われるOVRLipSycnというライブラリでは、口形素(viseme)を15個まで認識できます(sil, PP, FF, TH, DD, kk, CH, SS, nn, RR, aa, E, ih, oh, and ou)。

![37242285_1756078234512004_3131552026647855104_n.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/98018542-e9ab-6e24-83e2-95c9133b5938.gif)
引用元: [Oculus Lipsync Guide](https://developer.oculus.com/documentation/audiosdk/latest/concepts/book-audio-ovrlipsync/)

### 長所

- マイクだけあれば良いため、構成がシンプル
- 音圧だけの方法と違い、表現力が豊か。
- 周囲の雑音などは声でないので認識されない

### 短所

- 機械学習などを使って推定している場合、**一般的な話し声とかけ離れた音声**を認識できないことがある
    - 女性声優など極端に高い声の人の声は認識できないことが多いそうです

### ライブラリ等

- [Oculus Lipsync Guide](https://developer.oculus.com/documentation/audiosdk/latest/concepts/book-audio-ovrlipsync/)
    - 無料
    - VR用アセットだが良く使われる
    - Win, Mac, Androidに対応しているが、~~iOSでは動かない~~ 1.36で対応された
- [LipSync Pro](https://assetstore.unity.com/packages/tools/animation/lipsync-pro-32117)
    - 有料
    - エディタ上でフェイシャルアニメーションを作成するアセット
    - ランタイム実行は不可
    - Lite版はストアから消えてる

## 番外編: スペースキーで口の開閉を制御

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">リップシンク動かなくてとても悲しい想いをしたので、これからは一生手動でスペースキーを押していく所存です。</p>&mdash; Nakaji Kohki / リリカちゃん #技術書典6 け64 (@nkjzm) <a href="https://twitter.com/nkjzm/status/1016623791693180928?ref_src=twsrc%5Etfw">2018年7月10日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

カメラやマイクなどに依存しない方法です。冗談みたいな話ですが、不確実性は低いです。いざという時のために実装しておくと良いかもしれません。

## 最後に

よく使われる方法としては上記の3つだと思います。(もし他にあれば [@nkjzm](https://twitter.com/nkjzm)までご連絡いただけると嬉しいです)

読んでいただける分かる通り、それぞれの方法には一長一短があります。そのためアプリによっては複数の方法を切り替えられるようにしていることもあります。リップシンクを利用する場合は状況に併せて適した方式を検討されるのが良いかと思います。

