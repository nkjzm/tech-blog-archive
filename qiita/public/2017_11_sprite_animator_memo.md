---
title: 2dスプライトアニメーションをAnimatorで制御する時の備忘録
published_at: '2017-11-06 22:39'
private: false
tags:
  - Unity
updated_at: '2017-11-06T22:39:55+09:00'
id: 72f6744fda4c1c8a39c5
organization_url_name: null
slide: false
---
スプライトアニメーションは連続画像を複数選択してScene上にドラッグドロップするだけでAnimationファイルとAnimatorContollerファイルを作成してくれ、簡単に扱えると思うのですが、要件的に少し特殊なことをしようとしてハマったので備忘録として残します。

間違っていたり動かないことがあればご指摘いただけますと幸いです。

# ケーススタディ

## 1. スクリプトの値を動的に使う

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">UnityのAnimatorでparametersのfloat値とか使って動的にAnimationを変化させたさある</p>&mdash; Nakaji Kohki (@kohki_nakaji) <a href="https://twitter.com/kohki_nakaji/status/906541383959199744">2017年9月9日</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

結論としては無理なので、スクリプトで制御しました(今回は角度)。

``` PlayerRenderer.cs
        public void SetShot(float angle, bool isGround)
        {
            Debug.Log("shot");
            bodyAnimator.SetTrigger(SRAnimators.player.Parameters.shot);

            var _angle = ((angle + 45f) % 90) - 45f;
            transform.rotation = Quaternion.Euler(0, 0, _angle);

            // do something
        }
```

## 2. 動的に変化させた値をAnimatorでデフォルト値に戻す

上記でスクリプトから設定した値を、Animationの設定で上書きして値を戻すというアプローチです。

結論これも無理でした。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">UnityのAnimatorで角度はスクリプトからいじってるんだけど、Animationに一つでも角度のパラメータが入るとAnimatior側で管理されるようになってスクリプトからいじれなくなる、クソい</p>&mdash; Nakaji Kohki (@kohki_nakaji) <a href="https://twitter.com/kohki_nakaji/status/906544833589682181">2017年9月9日</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Write Defaultについては今回は用途が違いましたが、うまく使うと便利そう。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">Write Defaultはそのあたりを制御できるのかと思ってたけど、管理されているけどそのAnimationで指定されていないパラメータに関して、前Animationの値を使う(false)場合と初期値を使う場合(true)の制御だった</p>&mdash; Nakaji Kohki (@kohki_nakaji) <a href="https://twitter.com/kohki_nakaji/status/906545242521739265">2017年9月9日</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

## 3. Animationの開始時に処理を挟む

2. の手法が使えなかったので、スクリプトから開始時を判定して処理を挟み込みます。

方法はいくつかあります。

### AnimationState.normalizedTimeを監視する
https://docs.unity3d.com/ScriptReference/AnimationState-normalizedTime.html

### StateMachineBehaviourを使用する

これはAnimationのイベントを拾うことができるBehaviorです。StateMachineBehaviourを継承して使うことができます。 **Componentと少し扱いが違うので注意です(ちょっとハマりました)。** Animatorウィンドウ上でステートを選択し、Inspectorウィンドウで「Add Behavior」をすることでアタッチできます。

こちらの記事が参考になると思います。
[【Unity5】StateMachineBehaviourでAnimatorを監視する - Qiita](http://qiita.com/toRisouP/items/b6540b7f514d18b9a426)

また、上記記事の後半に書かれているUniRx版ですが、 `UniRx.Triggers` にまさしく同じような機能が `ObservableStateMachineTrigger` として実装されています。使い方は「Add Behavior」しておいた上で `Animator.GetBehavior` もしくは `Animator.GetBehaviors` で取得し、あとは `hogehogeAsObservable()` に対して `Subscribe` することができると思います。

## その他: Exit TimeとTransition Duration

Transition Durationは3Dの場合はいい感じにブレンドして自然に遷移してくれる機能ですが、2Dでは特にクロスフェード等してくれる訳ではないので、基本的には0にしておくといいと思います。
(これが0でない値になっているのに気がつかず、うまく意図しない挙動になっていてハマりました。。)

また、同様Exit Timeを使い場合も開始位置は終端の1に合わせておきましょう。


# さいごに

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">当たり前の話ではあるんだけど、アニメーションの制御はAnimatorに任せるパラメータとスクリプトで管理するパラメータの住み分けしっかり考えた方がよさそう</p>&mdash; Nakaji Kohki (@kohki_nakaji) <a href="https://twitter.com/kohki_nakaji/status/906545811735035909">2017年9月9日</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

# 参考
[【Unity】Animatorのアニメーション終了待ちをする方法 - テラシュールブログ](http://tsubakit1.hateblo.jp/entry/2016/02/11/021743)
