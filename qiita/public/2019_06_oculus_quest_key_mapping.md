---
title: Oculus Questコントローラーが持つ複数のキーマッピングについて
published_at: '2019-06-24 18:01'
private: false
tags:
  - Unity
  - VR
  - OculusQuest
updated_at: '2019-06-24T18:01:34+09:00'
id: 96cd9cddc645c45dd5e5
organization_url_name: null
slide: false
---
# はじめに

Oculus Questの入力周りのドキュメントを読んで、ざっと概要をまとめてみました。
その中で少し特殊なキーマッピングついての部分についての説明をします。

OVRInput
https://developer.oculus.com/documentation/unity/latest/concepts/unity-ovrinput/

この話はOculus Questに限らないOculus関連デバイス共通の話ですが、他の環境での動作は未確認です。

# 環境

- Unity 2018.3.14f1
- Oculus Integration for Unity - 1.37
  - Oculus Utilities Plugin 1.32.0
- Mac OSX 10.14.4（18E226）

# Oculusコントローラーのざっくりした基本

Oculus Quest / Rift Sのコントローラーは共通なのですが、どちらも"Oculus Touch"と呼ぶそうです。旧Riftコントローラーと入力自体は同じですが、少なくともドキュメント上では区別されていないようです。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">Oculus Quest / Rift Sのコントローラーは普通に「Oculus Touch」と言うっぽいな<br><br>Oculus Quest Development Guide<a href="https://t.co/6bg3PTS0BZ">https://t.co/6bg3PTS0BZ</a> <a href="https://t.co/T0URZobgsk">pic.twitter.com/T0URZobgsk</a></p>&mdash; Nakaji Kohki / リリカちゃん (@nkjzm) <a href="https://twitter.com/nkjzm/status/1139430488827822080?ref_src=twsrc%5Etfw">2019年6月14日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

入力はこんな感じで拾います。`static`メソッドでアクセス出来るので、ほぼほぼUnity標準のInputクラスと同様に扱えます。

```cs
void Update()
{
    // Aボタン押しっぱなしの時
    bool IsButtonAPressing = OVRInput.Get(OVRInput.Button.One);
    // Xボタンを押した瞬間
    bool IsButtonXPressed = OVRInput.GetDown(OVRInput.Button.Three);
    // 左手ジョイスティックに触れている時
    bool IsLStickTouching = OVRInput.Get(OVRInput.Touch.PrimaryIndexTrigger);
    // 左手ジョイスティックの傾けた値
    Vector2 RStickVec = OVRInput.Get(OVRInput.Axis2D.SecondaryIndexTrigger);
}
```

`OVRInput.Get()`の第一引数は複数の型でオーバーロードされており、`OVRInput.Button`の他に接触状態を取得する`OVRInput.Touch`や連続値として取得する`OVRInput.Axis1D`,`OVRInput.Axis2D`などがあります。返ってくる値も`bool`だけでない点に注意です。

# コントローラーのキーマッピング

上記では説明を省略しましたが、`OVRInput.Get()`は第二引数に`OVRInput.Controller`が指定できるようになっています。

```OVRInputの定義.cs
public static bool Get(Button virtualMask, Controller controllerMask = Controller.Active);
```

これは対象となるコントローラーを指定するもので、省略した場合は有効なものが自動的に設定されています。Oculus Questの場合、ここに指定出来る値が二種類あり、**どちらを指定するかによってキーマッピングが変化**します(重要)。

## 複合コントローラーをとして扱う場合

両手2つのコントローラーを、一つの複合的(Combined)なものとして使った場合のキーマッピングです。

第二引数で`OVRInput.Controller.Touch`を指定した場合が該当します。Touchコントローラーが両手分繋がっている場合はこれがデフォルトです(細かく条件変えて確認したりはしてないです)。先程のサンプルコードもこちらのキーマッピングで書いてあります。

![64515613_622041711631269_1500694343822868480_n.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/fd7e08ca-e9a7-e891-fb20-edb132e22d6b.png)

左手と右手は`Primary`,`Secoundary`というprefixで区別されています。`A`,`B`,`X`,`Y`ボタンは、`OVRInput.Button.One`, `OVRInput.Button.Two`と続きます。

## 個々のコントローラーをとして扱う場合

両手2つのコントローラーを、それぞれ独立した(Individual)コントローラーとして扱い場合のキーマッピングです。

第二引数で`OVRInput.Controller.LTouch`もしくは`OVRInput.Controller.RTouch`を指定した場合が該当します。Touchコントローラーが片手分繋がっている場合は、どちらかがデフォルトになる気がします(未確認)

![64700495_622041714964602_2286289187051143168_n.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/edc99947-030e-d549-7aa9-c9642734b7f4.png)

複合的に扱う場合と異なるのは、左右の区別がない点です。左手の`X`キーと右手の`A`キーに同様の振る舞いを与えることが出来ます。

**追記**

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">前に書いたこの記事 <a href="https://t.co/ahqQwd8EWg">https://t.co/ahqQwd8EWg</a> で、&quot;左手か右手どちらに対する問い合わせなのかを明示的に指定せずにPrimaryボタンの状態を取得した場合、「左手コントローラーが有効であれば左手側についている方、無ければ右手側の方」に問い合わせる挙動&quot;と補足してあるので併せてどうぞ。 <a href="https://t.co/M6A79ITVR0">https://t.co/M6A79ITVR0</a></p>&mdash; Kenji Iguchi (@needle) <a href="https://twitter.com/needle/status/1140559583364038656?ref_src=twsrc%5Etfw">2019年6月17日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>


## キーマッピングの使い分け

多くの場合は前者の複合的な扱いをすることが多いと思いますが、特定の状況で左右を区別しない入力が活躍すると思います。

「トリガーを引いて銃を撃つ」機能を例に考えます。銃はどちらの手で持つこともできますが、普通持っている側のコントローラーでトリガーを引いた場合のみ発射ができると思います。

複合的な扱いをしている場合、銃を持っていることを管理するクラスでは「右手で持っている場合は`OVRInput.Button.SecondaryIndexTrigger`を、左手では`OVRInput.Button.PrimaryIndexTrigger`」というような分岐を書く必要があります。

ここで左右を区別しない指定が出来ると、銃を持っている手の指定(`OVRInput.Controller.LTouch`,`OVRInput.Controller.RTouch`)のみ外部から指定出来るようにしておき、第一引数に渡す値は`OVRInput.Button.PrimaryIndexTrigger`と共通化しておけます。「持っている手に関わらずトリガーを引いたら銃がでる」という実装をする場合、こちらの方が**直感的で分かりやすいコード**になります。また、例えば「グリップを引いて弾をリロードする」という実装をする際にも対応が簡単だと思います。

# 最後に

キーマッピングが２つあることを見て一瞬混乱したんですけど、普通に便利そうな機能でした。特に個々に扱うモードでは機能ごとに入力を管理するような上手い実装ができると気持ちよさそうだと感じました。

もし間違っていることとかあれば教えてください〜

# 関連

- [【Unity】Oculus Questのコントローラ入力の取得方法まとめ - Qiita](https://qiita.com/KanataNao/items/ae3fb03e709de0f9aca6)
- [OculusGoのコントローラーをUnity上でエミュレートする - Qiita](https://qiita.com/nkjzm/items/83d3ab0862fbfef86b63)




