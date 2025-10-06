---
title: '[iOSでも動く] SALSAでバーチャルYouTuber向けのリップシンクを導入する方法'
tags:
  - Unity
private: false
updated_at: '2018-12-26T13:27:46+09:00'
id: 18c6ab7f5428076ab413
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

この記事は[VTuber Tech #1 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/vtuber) 20日目の代理投稿です。昨日は @welchi さんによる[Tensorflow.jsによるActionRecognitionでUnityのゲームキャラクターを動かしてみる](https://qiita.com/welchi/items/0b2e1228e97c1da10285)でした。

バーチャルYouTuber(以下VTuber)の配信システムでリップシンク(口パク)を作る時、もはや定番といえる[OVRLipSync](https://developer.oculus.com/downloads/package/oculus-lipsync-unity/)ですが、実はiOSに対応していないという弱点があります。

そこで今回は、iOSでリップシンクを実装する方法を考えつつ、手軽に導入できるSALSAの使い方を紹介しようと思います。(blendshapeのみに対応です)

![Dec-26-2018 13-23-42.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/8f3ec66c-7022-e066-e472-69fff1de3502.gif)
使用モデル: [リリカ / Lyrica / 標準ver - VRoid Hub](https://hub.vroid.com/characters/6874596705216592350/models/5941561814243096928)

ちなみにリップシンクという言葉を整理しておくと、大きく「開閉するもの(0-1)」と「口形素(aa,E,ih,oh,ouなど)を区別するもの」の2種類があります。また、ゲームの文脈だと音声は事前収録されたものを使いますが、VTuber文脈ではリアルタイムのマイク入力を指すことが多いと思います。

# iOSでリップシンクを実装する方法

## 顔認識を使う方法

イレギュラーですが、マイク入力でなくカメラ画像からリップシンクをさせる方法です。
iOSだとARKitのFaceTrackingが使えますし(iOSバージョン要確認)、dlibなどの顔認識アセットも配布されています。

## OVRLipSyncを使う方法

`1.30`(2018.12.26時点)では未対応ですが、今後対応予定があるそうです。
OVRLipSyncは15種類の口形素を取得することが出来るので、リッチな口パク表現をすることが出来ます。
もしiOSに対応したらかなり有力な候補になるような気がします。

<blockquote class="twitter-tweet" data-conversation="none" data-lang="ja"><p lang="ja" dir="ltr">OVRLipSyncは今日1.30がリリースされる。UE4対応強化と、笑いの検知beta版。GoではCPUとは別のハードウェアDSP上で動くようになる。そのあとのリリースではiOSサポートも予定されてる。<a href="https://twitter.com/hashtag/OC5JP?src=hash&amp;ref_src=twsrc%5Etfw">#OC5JP</a></p>&mdash; よしたか (@TyounanMOTI) <a href="https://twitter.com/TyounanMOTI/status/1045070556402335745?ref_src=twsrc%5Etfw">2018年9月26日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## 音量を使う方法

マイク音量を正規化して、直接口の開閉に割り当てるパターンです。１番シンプルですが、配信において考慮すべきことが出てきたりするので、結果ライブラリ使ったほうが早いのでは？ってなりそうな気がします。

実装は以下の記事のコードが参考になると思います。
[【初心者向け】UnityとLive2Dで拡張しやすいVTuber配信システムを作る方法](https://qiita.com/nkjzm/items/1ba5dfc0575ed6ddd8ff#%E5%8F%A3%E3%83%91%E3%82%AF%E3%81%AE%E5%AE%9F%E8%A3%85)

## SALSAを使う方法

[SALSA With RandomEyes](https://www.assetstore.unity3d.com/en/#!/content/16944)
2018.12.26時点で$35でした。

SALSAは"Simple Automated Lip Sync Approximation"の略で、その名の通りシンプルなLipSyncアセットです。
取得できる値は音量だけなのですが、上記の方法をラップした感じだと思います。スムージングとか(多分)エラー処理とかをしてくれているので、手軽にそれっぽいリップシンクが実現出来る方法だと思います。

> Windows, Mac, Linux, Android, IOS, Windows Store UWP (8 & 10 .NET Core), WP8, and WP10. WebGL is supported

サポートしてるプラットフォームがすごい。欠点としては、コアのコードがdll化されているので困った時に中身をいじれないこと(OVRLipSyncもそうですが)と、日本語の情報が少ないことです。あとマイク入力を使う時は別途アセットを入手する必要があるなど少しだけややこしいです。

# SALSAでVTuber向けのリップシンクを導入する方法

以下の動画の手順通りにやっていけば良いだけなのですが、英語でとっつきにくいと思うので日本語で紹介していきます。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">SALSAでマイク入力を使う方法<br><br>Unity Microphone Input using SALSA Lip Sync - YouTube<a href="https://t.co/dnRitW6DIY">https://t.co/dnRitW6DIY</a></p>&mdash; Nakaji Kohki / リリカちゃん💜💊 (@nkjzm) <a href="https://twitter.com/nkjzm/status/1077631471521677312?ref_src=twsrc%5Etfw">2018年12月25日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

まずはBlendShapeが入ったモデルを含むUnityプロジェクトを用意してください。VRMでも大丈夫です。SALSAをインポートしておいてください。

次にマイク入力用のアセットを取得します。以下のリンクにアクセスし、Donwload Filesというボタンを押してください。
http://crazyminnowstudio.com/posts/real-time-microphone-input-for-salsa-lip-sync/#Download

購入した時のメールアドレスと番号を求められます。番号はUnityのOrder numberに該当するので、メールフォルダを検索すると出てくると思います。
<img width="617" alt="スクリーンショット 2018-12-26 3.33.07.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/f6c0a5a9-fead-c240-9c0c-1103178cf6f2.png">

認証が通ったらDLページに進みます。

`MicInput-Lite`を探してダウンロードしてください。なお2018.12.26時点では`v1.6.0`(安定版)と`v1.7.0`(β版)がありました。`v1.7.0`は遅延が10倍以上少ないそうです。お好みで。

UnityPackageが落ちてくるので、プロジェクトにインポートします。

Mixerを作ります。Projectorビューで右クリックをして、`Create > Audio Mixer`から作成できます。
ダブルクリックするとAudioMixerビューが開くので、下記のように編集してください。

<img width="400" alt="スクリーンショット 2018-12-26 3.42.14.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/c272350e-535c-5040-c3a9-8fdacff398b8.png">

上記が面倒くさい人のために、設定済みのMixerを`.unitypackage`で配布します。ご活用ください。
https://drive.google.com/open?id=19BNw8pOEzx4pX27vpiYm5VbvtvwDQJJR

さて、もう少しです。
シーンにある3Dモデルを選択してください。AddComponentから`Crazy Minnow Studio > SALSA > Salsa 3D`を選択してください。検索でもいけます。

次にマイクを付けます。AddComponentから`Crazy Minnow Studio > SALSA > addons > micinput`を選択してください。`CM_Mic Input`というコンポーネントがアタッチされます。

AudioSourceに自身を設定してください。また必要であればAvailable Microphonesから利用したいマイク入力を選択してください。

<img width="450" alt="スクリーンショット 2018-12-26 3.50.14.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/6885e509-e502-8a89-f0f4-e8c3d5aa45c7.png">

AudioSourceのOutPutにmicInputを設定してください。右側の○から探すと楽です。

<img width="442" alt="スクリーンショット 2018-12-26 3.48.33.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/fa50b392-38d9-92b6-ccc0-18ec66b03855.png">

`Salsa 3D`の`Skinned Mesh Render`に顔のBlendShapeを設定してください。
下の`SaySmall Index`, `SayMedium Index`, `SayLarge Index`が選択可能になります。小さい音の時、普通の音の時、大きな音の時という意味で、シーケンシャルです。

<img width="449" alt="スクリーンショット 2018-12-26 3.52.40.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/58c4ef0b-fe42-3d3a-9da5-0a355d07450d.png">

先人によると以下のようにするとオススメらしいです。ただ僕が試した感じだとモデルに寄りそうので、色々調整してみてください。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">めも<br>SALSA のリップシンク<br>Small -&gt; ii<br>Medium -&gt; ee<br>Large -&gt; oo</p>&mdash; karukaru👑@白魔導技士 (@_karukaru_) <a href="https://twitter.com/_karukaru_/status/999215352742494208?ref_src=twsrc%5Etfw">2018年5月23日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>


あと`BlendSpeed`はデフォルト10なのですが、緩慢な動きはVTuberに合わないと思うので、20くらいに設定するといい感じだと思います。あと`Range of Mosion`はどのくらい口を大げさに開閉するかのパラメータなので、必要なら調整してください。こちらのAliciaモデルは100で大丈夫そうですが、記事先頭にあるVRoidのモデルは70くらいに設定してあります。

この状態で再生すると、こんな感じで口パクすると思います。

![Dec-26-2018 03-58-52.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/802f1dda-dd80-6a2d-6bc1-fb07779fd368.gif)

僕が試してみたところ、「oh, E, aa」でもいい感じだと思います。

![Dec-26-2018 04-01-55.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/dbac6e64-1fbd-3c3b-b619-2674a4082c42.gif)

結構印象変わるので、やっぱりここだけは調整してみてください。

# まとめ

使ってみたら意外とそれっぽく動いて良かったです。SALSAはいいぞ！

[VTuber Tech #1 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/vtuber) 21日目は @segur さんによる[VRoidのウィンドウを透過させてトレースモデリングする](https://qiita.com/segur/items/fc6c4874a0569309eeec)です。

# 関連

- [UnityでVRコスプレするときに詰まったところの覚え書　その3](https://qiita.com/_karukaru_/items/3b4efd166e2418777c1c)

