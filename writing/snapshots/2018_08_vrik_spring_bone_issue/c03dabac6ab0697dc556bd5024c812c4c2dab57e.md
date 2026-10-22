---
title: "VRIK(FinalIK)を適用するとVRMの揺れもの(VRM Spring Bone)の動きがおかしくなる時の対処"
emoji: "🥽"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "VR"]
published: true
---

# 原因

VRIKの`FixTransforms`によって、揺れものの計算結果が上書きされていることによるものでした。

VRIKの`FixTransforms`がどういうものかというと、ソースコードには以下のように書いてありました。

> If true, will fix all the Transforms used by the solver to their initial state in each Update. This prevents potential problems with unanimated bones and animator culling with a small cost of performance. Not recommended for CCD and FABRIK solvers.

IKで計算されない各Transformの値を毎フレーム初期値でリセットする機能でしょうか。
これによって、揺れもののTransform値が上書きされてしまったようです。

外せるならそれで解決しそうですが、私の場合はオフだとメッシュがプルプルしてたのでつけたままでの対処を考えました。

# 解決方法

Spring Boneの実行順を`FixTransforms`よりも後に設定する。

`ProjectSetttings>ScriptExecutionOrder`を以下のように設定してください。

![aaaaaaa.PNG](https://qiita-image-store.s3.amazonaws.com/0/55365/34465a25-fc59-2529-5a1d-74e4cd5c081f.png)

FinalIKはインポート時にデフォルトより後に実行されるように設定されています。
なので、SpringBoneをそれよりも後に実行するように指定してやれば良いです。

# その他気にするところ

Animatorが設定されている場合は、それによって制御されている場合があるので確認してみてください。
(AnimatorコンポーネントのControllerがnullなら何もしてこないはずです。)


# 参考

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">SmoothJointってアセットで髪揺れ設定したら、昨日は揺れてたのに今日は揺れないやんけ！と思ったら、なんかVRIKと競合してスクリプト実行順で動いたり動かなかったりしてたっぽい。SmoothJointのScriptExecutionOrderをFinalIKより後にしたら動いた。VRIKのFixTransform機能が髪揺れを止めちゃう感じ</p>&mdash; 海行プログラム (@kaigyoPG) <a href="https://twitter.com/kaigyoPG/status/958271307124064256?ref_src=twsrc%5Etfw">2018年1月30日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

ほぼこれと同じ内容でした。
