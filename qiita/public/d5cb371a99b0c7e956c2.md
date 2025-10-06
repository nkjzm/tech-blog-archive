---
title: 【Unity】VRカメラのポジショントラッキングを無効化する
tags:
  - Unity
  - VR
private: false
updated_at: '2018-07-07T15:20:22+09:00'
id: d5cb371a99b0c7e956c2
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

こちらの記事で紹介されているコードに、スケールや回転角を考慮した処理を加えたものになります。

[Unity で VR モード時にカメラの位置を固定する – monopocket](http://monopocket.net/blog/vr/unity-hmd-position/)

# コード

``` CameraController.cs
using UnityEngine;
using System.Collections;

public class CameraController : MonoBehaviour
{
   Vector3 basePos = Vector3.zero;

   void Start()
   {
       basePos = transform.position;
   }

   void Update()
   {
       // VR.InputTracking から hmd の位置を取得
       var trackingPos = UnityEngine.XR.InputTracking.GetLocalPosition(UnityEngine.XR.XRNode.CenterEye);

       var scale = transform.localScale;
       trackingPos = new Vector3(
           trackingPos.x * scale.x,
           trackingPos.y * scale.y,
           trackingPos.z * scale.z
       );

       // 回転
       trackingPos = transform.rotation * trackingPos;

       // 固定したい位置から hmd の位置を
       // 差し引いて実質 hmd の移動を無効化する
       transform.position = basePos - trackingPos;

       // 子のカメラの座標がbasePosと同じ値になるかを確認する
       // Debug.Log(transform.GetChild(0).position);
   }
}
```

## 補足: 回転の処理について

大変おこがましいかと思いますが、読んだ人が混乱しないため元記事で誤っているように思う記述について補足させてください。

>    // CameraController 自体の rotation が
>   // zero でなければ rotation を掛ける

元記事だと上記のような補足がされているが、rotationがzeroの時(恐らく `rotation==Quaternion.identity`の状態)であっても乗算することは問題ないはずです。

また、ベクトルを回転させる場合は以下の順番かと思います。
`回転後のベクトル = 回転角 * 回転前のベクトル`


# 課題

`InputTracking.GetLocalPosition()`で取得できる値を元に計算しているので、1フレーム遅延してる気がします。

