---
title: Unityで鏡を実装する方法
tags:
  - C#
  - Unity
  - VR
private: false
updated_at: '2018-12-10T22:30:30+09:00'
id: ccba41a6e7e5211aae95
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

この記事は[Unity Advent Calendar 2018](https://qiita.com/advent-calendar/2018/unity)の5日目の記事です。
昨日は@Kan_Kikuchiさんによる[Unityで作ったアプリのサイズを減らす20の方法【Unity】【容量削減】](http://kan-kikuchi.hatenablog.com/entry/Unity_App_Size)でした。

![Dec-06-2018 23-55-09 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/1d64f9e7-6359-f719-593b-343b32b22b61.gif)

さて、Unityで鏡を使いたい場合は、皆さんはどうしますか？

１番シンプルなのは、面の奥側に手前側を写す鏡を置き、レンダーテクスチャを左右反転させて表示する方法です。ただし、この実装はカメラの位置などを考慮していないため、見え方としてはディスプレイに映ったウェブカメラの映像を見ているような感覚に近いです。

もしくはアセットを使う方法です。[Vive Stereo Rendering Toolkit](https://assetstore.unity.com/packages/tools/particles-effects/vive-stereo-rendering-toolkit-71255)は両眼に対応した鏡アセットで、かなり正確に鏡としての振る舞いが再現されています。

ただし、上記の[Vive Stereo Rendering Toolkit](https://assetstore.unity.com/packages/tools/particles-effects/vive-stereo-rendering-toolkit-71255)はOculusプラットフォームではうまく表示されないという問題がありました。
そこで、今回は自前で鏡を実装する方法を紹介していこうと思います。

ソースコードは以下にアップしてあるので、参考にしてください。MITライセンスです。
両眼対応はしていませんが、OculusGo/OculusRiftで使用できることは確認済みです。

nkjzm/Mirror
https://github.com/nkjzm/Mirror

# 流れ

1. 鏡面用カメラの準備
2. 鏡面の描画
3. 鏡の枠の設定

大まかな仕組みとしては、反射をRenderTextureを使って擬似的に再現してメインカメラに向けて描画、それを3D空間においてある鏡の形に切り取るという流れです。以降の章で詳しく説明していきます。

## 鏡面用カメラの準備

鏡面に描画するための映像を準備します。

鏡が反射する仕組みとして、鏡面で光が面対称に反射して目(今回はカメラ)に入ってくるという流れがあります。そのため、鏡面からカメラに反射する映像を、もう一つのカメラ(反射用カメラとする)を使って再現してみるところから始めて行きたいと思います。

![無題のプレゼンテーション.png](https://qiita-image-store.s3.amazonaws.com/0/55365/0f9ead83-1d25-4f4f-0094-c9f87149e8f5.png)

鏡面からのカメラに反射する映像は、上図のように、鏡面と面対象なカメラの位置から見た映像で再現できます。まずは、カメラと面対象な位置を計算してみましょう。

```.cs
// カメラから鏡面へのベクトル
var diff = transform.position - TrackingCamera.transform.position;
// 鏡面の垂直ベクトル
var normal = transform.forward;
// 鏡面からの反射ベクトル
var reflection = diff + 2 * (Vector3.Dot(-diff, normal)) * normal;
// 鏡面座標に反転させた反射ベクトルを加算する
ReflectionCamera.transform.position = transform.position - reflection;
```

カメラの鏡面ベクトルと、鏡面からカメラへの垂直方向への高さを使って反射ベクトルを求めています。図にすると以下の通りです。

![無題のプレゼンテーション (2).png](https://qiita-image-store.s3.amazonaws.com/0/55365/8463275e-5025-eee8-a50f-31cb9dcc88c8.png)

最後に鏡の中心座標から反射ベクトルを引くと、反射用カメラの位置が計算できました。

次に反射用カメラの向きですが、これはUnityの便利関数`LookAt`を使って、鏡の中心座標に向けて上げるだけで完了です。

```.cs
// 鏡面の方向に向ける
ReflectionCamera.transform.LookAt(Specular.position);
```

最後に[nearClipPlane](https://docs.unity3d.com/ja/2017.4/ScriptReference/Camera-nearClipPlane.html)の設定をします。

![Dec-06-2018 22-04-51.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/b98eea46-4d3b-1aa9-1974-e67d27bda6c3.gif)

これは、描画対象の視錐台の最小距離を設定するための変数です。擬似的な描画をするために鏡の裏側に反射用カメラを置いているので、反射用カメラと鏡の間のオブジェクトによって遮蔽されないための設定です。

```.cs
// カメラ設定の更新
var distance = Vector3.Distance(transform.position, ReflectionCamera.transform.position);
ReflectionCamera.nearClipPlane = distance* 0.9f;
```

今回は大まかな設定をしています。鏡の中心座標から反射用カメラまでの距離を計算し、`0.9`を掛けて最小距離としています。理想的には鏡面に並行に最小距離を置きたいところですが、視錐台を用いる以上、鏡面に対して垂直な場合以外では合わせることができないため、少し余裕を持った値にしています。

## 鏡面の描画

続いて、用意した反射用の映像を鏡面に反映させていきます。

ここでは`RenderTexture`を用います。

<img width="351" alt="スクリーンショット 2018-12-06 22.13.37.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/2d643446-851e-a2e6-6701-d79e2ef32918.png">

`RenderTexture`のサイズは任意ですが、パフォーマンスに影響するので必要最小限にするのが好ましいです。

<img width="350" alt="スクリーンショット 2018-12-06 22.12.45.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/c4cecefd-d66b-743b-abd5-d13cba73d6b7.png">

作成した`RenderTexture`を反射用カメラの`TargetTexture`に設定しました。

これを3D Objectの`Quad`に表示させた結果がこちらです。(Scaleを`(-1,1,0)`にしています)

<img width="676" alt="スクリーンショット 2018-12-06 22.20.24.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/392ed87b-7fdc-e29c-2c0e-037cd67978f4.png">

オブジェクトが反転して映っているのは良いですが、スケール感がおかしいですね。
なぜかと言うと、焦点距離に対して画角が適切でないからです。

画角(rad)を求めるための近似式がこちらです。

<img width="392" alt="スクリーンショット 2018-12-06 22.32.04.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/573ec16b-3938-2be1-f70b-73da89a02545.png">
参考: [焦点距離と実視野の理解](https://www.edmundoptics.jp/resources/application-notes/imaging/understanding-focal-length-and-field-of-view/)

実視野には鏡面としているQuadのサイズを、焦点距離には先程求めた`distance`を代入して求めた結果を反射用カメラに適用していきます。なお、単位はUnity座標系のものを使っています(分母と分子で一致していれば問題ない)

```.cs
// 焦点距離と表示したい鏡面サイズから画角(FOV)を計算する
ReflectionCamera.fieldOfView = 2 * Mathf.Atan(Size / (2 * distance)) * Mathf.Rad2Deg;
```

`fieldOfView`に代入する際、`Mathf.Rad2Deg`を使ってラジアンから度数法に変換しているところに注意してください。

<img width="650" alt="スクリーンショット 2018-12-06 22.38.19.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/80f4c087-2881-7300-685e-044a76f2c10f.png">

適切な大きさで表示されるようになりました。

これで解決したかと思いきやですが、もう一つ課題があります。

![Dec-06-2018 22-40-28.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/26bce753-bc52-4283-4cef-d168d64cdeae.gif)

鏡と右のキューブは平行に置かれているのに、視点を変えると相対的な角度が変化しています。これは正しい鏡の挙動ではないです。

どうしてこうなってしまうのか、鬼分かりやすい図を作りました。

![無題のプレゼンテーション (4).png](https://qiita-image-store.s3.amazonaws.com/0/55365/465ccefe-e528-b948-322b-63817f892e04.png)

本来カメラに対して平行に入ってくる映像は、図の上のような角度でカメラに移ります。
しかし現状では図の下のように、反射する映像を鏡面に並行に描画しています。つまり、②の段階で差が生まれてしまっているのです。②は、カメラが垂直方向に近ければどちらも鏡に対して平行な角度なので問題になりませんが、垂直な位置から離れるほど差異が大きくなってしまします。

解決方法としては、②の角度を本来のようにカメラに対して常に垂直に設定してあげます。

```.cs
// 鏡面をカメラ方向に向ける
Specular.rotation = Quaternion.LookRotation(Specular.position - TrackingCamera.transform.position);
```

![Dec-06-2018 23-00-39.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/9698960c-da05-9af4-f9ad-1eb23f9aa0c6.gif)

カメラを動かすたびに鏡の角度が変わってしまっていますが、反射の見え方としては正しいふるまいになりました。

## 鏡の枠の設定

動かすたびに鏡の角度が変わってしまう問題を解決していきます。
アプローチとしては、角度が変わってしまうのはどうしようもないので、変わってない風の見せ方にしていきます。

角度が変わって見える大きな要因はQuadの境界線が動いている点なので、そこを誤魔化します。本来鏡の場所に枠があるはずなので、その領域のみ鏡が表示されるようにします。
凹みさんの窓シェーダーを使って、窓領域の奥だけ描画するようにします。
参考: [HoloLens で向こう側が見える窓を動的に追加してみる - 凹みTips](http://tips.hecomi.com/entry/2017/02/18/190949)

![Dec-06-2018 23-16-16.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/0bad69a9-126c-2c32-cfaa-180004ee9ace.gif)
_分かりやすくするため、鏡の奥に同じシェーダーで黒い板ポリを置いています_

角度が変わっている感がほとんどなくなりました。もう一息です。
気になるのは、角度が変わった事によって本来鏡がある領域に隙間(gifでいう黒いエリア)が出来てしまっているところです。

角度によって現れるように見えるので、補正を掛けていきましょう。

```.cs
// フレームのサイズを更新
Frame.localScale = new Vector3(Size, Size, 1);
// 鏡面のサイズを調整
var angle = Vector3.Angle(-transform.forward, ReflectionCamera.transform.forward);
var specularSize = Size + Mathf.Sin(angle * Mathf.Deg2Rad);
Specular.localScale = new Vector3(-specularSize, specularSize, 1);
```

フレームのサイズを基準にし、垂直方向からずれた角度`θ`の分だけサイズを`+Sin(θ)`しています。

![Dec-06-2018 23-25-34.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/921188bf-df17-0a51-ede5-9094bd86ea06.gif)

角度を変えても黒枠が目立たないようになりました！
(FOVが小さくなると目立つことを確認しているので、各自+する値は調整してください)

## (おまけ) エディタ上で扱いやすくする工夫

お気づきの方がいるかもしれませんが、記事中のgifはSceneビュー上で撮影をしています。
今回の鏡を実装するに辺り、Editor上での確認をしやすいように工夫をしたので、その方法も紹介します。

### シーン上のカメラを取得する

```.cs
[SerializeField]
bool EnabledTargetCamera = false;

Camera TrackingCamera
{
    get
    {
        if (!EnabledTargetCamera)
        {
#if UNITY_EDITOR
            return SceneView.lastActiveSceneView ? SceneView.lastActiveSceneView.camera : null;
#endif
        }
        return TargetCamera;
    }
}
```

`EnabledTargetCamera`の値によって、Sceneビュー上のカメラを対象のカメラに設定できるようにしました。鏡のデバッグ中はSceneビューの方が視点の切り替えが楽なので、非常に役立ちました。
理想的にはSceneビューがアクティブな場合に自動的に切り替わるなどしたかったです。

### エディタ上でも鏡の描画を更新する

```.cs
void OnEnable()
{
#if UNITY_EDITOR
    EditorApplication.update += UpdateMirror;
#endif
}
void OnDisable()
{
#if UNITY_EDITOR
    EditorApplication.update -= UpdateMirror;
#endif
}
void Update()
{
#if !UNITY_EDITOR
    UpdateMirror();
#endif
}
```

今回紹介した処理は`UpdateMirror()`という関数内の処理だったのですが、Editor上でも実行されるように`EditorApplication.update`というイベントに追加するようにしていました。実行中は`Update()`で呼ぶようにしています。

また、`UpdateMirror()`の中でSceneビューに変更を加えても即時反映されない現象があったのですが、以下のメソッドで解決できました。

```.cs
#if UNITY_EDITOR
// シーンビュー更新
SceneView.RepaintAll();
#endif
```

# まとめ

鏡を実装することで、数学的な知識から、レンズの知識、Unityエディタの知識などを得ることが出来ました。
厳密なアプローチばかりではありませんでしたが、誰かの参考になると幸いです。

今回紹介した鏡の完成プロジェクトです(再掲)
nkjzm/Mirror
https://github.com/nkjzm/Mirror

明日の[Unity Advent Calendar 2018](https://qiita.com/advent-calendar/2018/unity)は@mao_さんによる「PureECSのアニメーションについて纏め直してみる予定です」です。

## 追記

<blockquote class="twitter-tweet" data-conversation="none" data-lang="ja"><p lang="ja" dir="ltr">RenderTextureのColorFormatをDepthとかにすると赤外線カメラっぽい鏡になって面白い。なんか出来そう👀 <a href="https://t.co/mtWb8sqVTI">pic.twitter.com/mtWb8sqVTI</a></p>&mdash; Nakaji Kohki (@nkjzm) <a href="https://twitter.com/nkjzm/status/1071971399248408576?ref_src=twsrc%5Etfw">2018年12月10日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>



## 参考

- [UnityのMirrorRefrectionによる鏡の表現 - Qiita](https://qiita.com/UnagiHuman/items/6fae8e52d9c5c73ce3b0)
- [窓シェーダーを使った仕掛けの作り方 | STYLY](https://styly.cc/ja/tips/9windows_discont_windowshader/)

