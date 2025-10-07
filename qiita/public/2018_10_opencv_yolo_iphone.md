---
title: OpenCV For Unityを使ってiPhone上でYOLOを動かす
published_at: '2018-10-26 21:33'
private: false
tags:
  - Unity
updated_at: '2018-10-26T21:33:51+09:00'
id: 6bbebf264b98b23f180e
organization_url_name: null
slide: false
---

## はじめに

[OpenCV for Unity](https://assetstore.unity.com/packages/tools/integration/opencv-for-unity-21088)には色々なサンプルが入っており、その中にYOLOを使ったものがあります。

YOLOとは画像認識のアルゴリズムで、比較的処理が高速なことが知られています。

[OpenCV for Unity](https://assetstore.unity.com/packages/tools/integration/opencv-for-unity-21088)に含まれているYOLOのデモは以下の2つで、[WebGLでのデモページ](https://enoxsoftware.github.io/OpenCVForUnity/webgl_example/index.html)からも試すことが出来ます。

- YoloObjectDetectionExample
    - 画像を使ったYOLOのデモ
- YoloObjectDetectionWebCamTextureExample
    - Webカメラを使ったYOLOのデモ

また、このデモをiPhone XSで動かした動画が以下になります。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">iPhoneでYOLOです <a href="https://t.co/zrqRHj4mpE">pic.twitter.com/zrqRHj4mpE</a></p>&mdash; Nakaji Kohki (@kohki_nakaji) <a href="https://twitter.com/kohki_nakaji/status/1055786287209168896?ref_src=twsrc%5Etfw">2018年10月26日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

[OpenCV for Unity](https://assetstore.unity.com/packages/tools/integration/opencv-for-unity-21088)はiOSを始めとして様々なプラットフォームに対応したアセットなのですが、2018/10/26現在の環境で動かすためにはいくつかの手順が必要でしたので、記しておきたいと思います。

## 手順

予め[OpenCV for Unity](https://assetstore.unity.com/packages/tools/integration/opencv-for-unity-21088)をプロジェクトにインポートしておきます。

YOLOを使うためには、まずモデルデータをインポートする必要があります。ライセンスの関係でOpenCVForUnityのパッケージ自体には入っていないので、別途リポジトリからダウンロードしてきます。

必要なファイル以下の3つです。

- https://github.com/pjreddie/darknet/tree/master/data/coco.names
- https://github.com/pjreddie/darknet/blob/master/cfg/yolov3-tiny.cfg
- https://pjreddie.com/media/files/yolov3-tiny.weights
- https://github.com/pjreddie/darknet/blob/master/data/person.jpg
    - (YoloObjectDetectionExampleのみ必要)

これを、`Assets/StreamingAssets/dnn`以下に置いておく必要があります。

OpenCVForUnityの直下にある`StreamingAssets`に雛形があるので、フォルダ毎`Assets`直下に移動させると良いと思います。

*ちなみにですが、`StreamingAssets/dnn`以下にあるドキュメントでは`coco.names`の記述が抜けているのと、実行時のファイル参照エラーメッセージでは指定されているyoloのバージョンが異なっていました。罠っぽい…。*

ここまでやると、エディタ上で実行ができる状態になります。
`OpenCVForUnity/Examples/MainModules/dnn/YoloExample`以下にあるシーンを再生してみてください。

<img width="587" alt="スクリーンショット 2018-10-26 21.25.57.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/41d0e489-b4fa-65e3-2f2e-b8ac7d435143.png">
*画像: `YoloObjectDetectionExample.unity`を再生した例*

iPhoneで再生するためにはもう一つ手順が必要です。

iOSで実行した場合`Utils.cs`の`string getFilePath (string filepath, bool refresh = false)`という関数内にある`File.Exists (destPath)`がtrueを返してくれない事象を確認しました。そのため、モデルデータを読み込めず、正常に実行されません。

対処としては、ファイルの存在チェックを行わずにpathを返すようにすれば良いです。

```変更前.cs
if (File.Exists (destPath)) {
    return destPath;
} else {
    return String.Empty;
}
```
```変更後.cs
return destPath;
```

この状態でビルドすれば冒頭の動画のように実行出来ると思います。

