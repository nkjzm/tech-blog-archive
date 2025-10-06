---
title: 【初心者向け】UnityとLive2Dで拡張しやすいVTuber配信システムを作る方法
tags:
  - C#
  - Unity
  - Live2D
private: false
updated_at: '2020-07-27T08:50:05+09:00'
id: 1ba5dfc0575ed6ddd8ff
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

この記事は[VTuber Tech #1 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/vtuber)の1日目の記事です。

こんにちは、[@nkjzm](https://twitter.com/nkjzm)です。
今回はUnityとLive2Dを使ったVTuber配信システムの作り方を紹介します。
**Unityに初めて触る人でも分かる**くらい丁寧に書いているので、ぜひ色々な方にご覧いただきたいです。

![Nov-30-2018 23-23-42.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/0cfeaa0e-5770-e974-a9a5-ff490d9d3617.gif)
_作成できるシステムのイメージ_

現状、Live2DでのVTuber配信は[FaceRig](https://store.steampowered.com/app/274920/FaceRig/)というアプリケーションが用いられることが多いと思います。導入すればすぐにモデルを動かすことができるため非常に便利なのですが、反面キャラクターとしての表現を追求する際に制約となる場合もあります。

そこで、本記事ではUnityを用いることで**拡張しやすいVTuber配信システム**の作り方を紹介します。
サンプルとして完成プロジェクトも用意しましたので、適宜参考にしながら読み進めてください。

**この記事で扱うこと**

- UnityとLive2Dを使ったシステム構築
- OBSを使った配信方法

**この記事で扱わないこと**

- Live2Dモデルの作り方

## 必要な環境

- 以下のいずれかのOS
    - macOS High Sierra (10.13.6にて動作確認済み)
    - Windows 10
- [Unity](https://unity3d.com/jp/get-unity/download)
    - 2017.4.x~ / 2018.2.x~ (2018.2.11f1にて動作確認済み)
- [Live2D Cubism 3 SDK for Unity](https://live2d.github.io/#unity)
    - R10にて動作確認済み
    - Unity2017系と2018系に対応済み [^1] [^2]
- [OVRLipSync](https://developer.oculus.com/downloads/package/oculus-lipsync-unity)
    - 1.28.0にて動作確認済み

[^1]: http://docs.live2d.com/cubism-sdk-tutorials/getting-started/
[^2]: https://forum.live2d.com/discussion/comment/3653/#Comment_3653

## VTuberKitについて

nkjzm/VTuberKit
https://github.com/nkjzm/VTuberKit

今回紹介する方法の完成プロジェクトです。
主に`Assets/VTuberKit/Examples/Koharu/`以下のシーンが参考になると思います。

[MITライセンス](https://github.com/nkjzm/VTuberKit/blob/master/LICENSE)で配布しているので、このプロジェクトを基盤にシステムを作っていただいても大丈夫です。

※ただしいくつかのSDKの利用を前提としているため、それぞれのライセンスには従ってください。
特にLive2Dの「拡張性アプリケーション」に該当しないかどうかはきちんと確認してください。
[拡張性アプリケーションのリリースライセンスについて](https://www.live2d.com/ja/products/releaselicense/expandable_application)

利用方法についてはリポジトリの[README.md](https://github.com/nkjzm/VTuberKit/blob/master/README.md)をご覧ください。

## 質問について

記事中で分からないことがあれば[@nkjzm](https://twitter.com/nkjzm)までご連絡ください（軽い質問であればお答えします）。また、月額制のメンターサービスで開発サポートをしているので、詳しく教えてほしい方はこちらをご利用ください。　
https://menta.work/plan/1115


# 配信システム基盤の作成

ここからはVTuber配信システムの具体的な作成手順を紹介します。
分からない点があれば、適宜[VTuberKit](https://github.com/nkjzm/VTuberKit)を参考にしてください。

## Unityプロジェクトの新規作成

Unityのインストールが済んでいない方は、[こちら](https://unity3d.com/jp/get-unity/download)からインストーラーをダウンロードします。UnityHubを利用すると複数バージョンのUnityを管理出来るのでオススメです。

具体的な手順は今回は割愛します。画面に従ってインストールを進めてください。

UnityHub(もしくはUnity)を起動します。

<img width="509" alt="スクリーンショット_2018-10-17_0_01_52.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/14742225-0e39-bda0-d5db-c2fd87c086c5.png">

右上の「新規」をクリックしてください。

<img width="1013" alt="スクリーンショット 2018-10-17 0.08.21.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/cd42fb77-bb83-b415-805c-1cd8f8b35ee9.png">

- Project Nameを入力
- Templeteを`2D`に変更

上記のように入力して「Create project」をクリックしてください。

<img width="1680" alt="スクリーンショット 2018-10-17 2.50.56.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/d0f20d78-bec9-6424-7d61-b16b2149216e.png">

プロジェクトが作成され、Unityエディタと呼ばれる画面が開くと思います。

## Live2DモデルをUnityに組み込み

ここからは実際にLive2DのモデルをUnity上に組み込んで行きましょう。

### Live2D SDKのインポート

UnityでLive2Dを扱うためのSDKをインポートします。
[配布ページ](https://live2d.github.io/#unity)にアクセスすると、利用にあたってのライセンスが表示されます。ライセンスに同意した上で、少し下の方にある「Download Live2D Cubism 3 SDK for Unity R10」のリンクをクリックしてください。ダウンロードが開始します。

<img width="1190" alt="スクリーンショット 2018-10-17 3.01.48.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/469a8f8d-3f30-e7c7-cf14-aec491109658.png">

次に、ダウンロードした`Cubism3SDKforUnity-9.unitypackage`というファイルをダブルクリックしてください。

<img width="365" alt="スクリーンショット 2018-10-17 3.12.06.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/f7c2a51a-1058-f40e-3a0c-117e75bcb239.png">

このような画面が開くと思います。
(上記の操作で画面が開かない場合は、Unityエディタ上にドラッグアンドドロップする操作を試してみてください。)

すべてチェックマークが入っていることを確認して、右下のインポートボタンを押してください。

<img width="437" alt="スクリーンショット 2018-10-17 3.20.31.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/bdf4b920-1f61-9843-68bc-aa55906e57d2.png">

このように再起動を促すメッセージが表示されるので、「ok」をクリックします。インポート終了後に再起動をしてください。

再起動の手順としては、まずUnityを終了させます。Unityを選択した状態で、Macなら`Command(⌘) + Q`を、Windowsなら`Alt + F4`を押してください。

次にUnityHubアプリを起動し、プロジェクトの中から先程作成したプロジェクトを選択してください。

<img width="1007" alt="スクリーンショット 2018-10-17 3.31.01.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/0e7662a1-1188-9d61-81e6-a189b67bb837.png">

これでLive2D SDKが読み込みは完了です。

では正常に読み込めているか確認してみましょう。SDKにはいくつかのサンプルが含まれています。その中の一つを開いてみたいと思います。

<img width="1680" alt="スクリーンショット 2018-10-17 3.35.22.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/900a150e-6d9f-d619-a09f-af80ffac3046.png">

①Unityエディタ上のProjectビューから、`[Asset]>[Live2D]>[Cubism]>[Samples]>[Animation]`と辿っていき、②`Animation`というシーンファイルをダブルクリックしてください。③Gameビューにキャラクターが表示されます。④最後に再生ボタンを押してください。

![Oct-17-2018 03-40-37.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/51786e6f-632b-f2ac-5b17-876b7f12a6c4.gif)

Gameビューのキャラクターがこのようにアニメーションしていることが確認できると思います。

### モデルのインポート

他のモデルをインポートする手順を紹介します。

今回は公式の『桃瀬ひより』というサンプルモデルを例に説明します。
自作モデルを利用する場合などは、適宜読み替えて進めてください。

[サンプルモデル集](http://docs.live2d.com/cubism-editor-manual/sample-model/)より『桃瀬ひより』の「Freeダウンロード」をクリックしてください。利用の際には[『無償提供マテリアルの使用許諾契約書』](http://www.live2d.com/eula/live2d-free-material-license-agreement_jp.html)を確認しておいてください。

<img width="927" alt="スクリーンショット 2018-10-18 3.36.10.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/a4b695fe-cc79-3c8c-e862-58046d1d7bde.png">

zipファイルがダウンロード出来るので、ダブルクリックなどで解凍しておいてください。

Live2D Cubism 3のモデルデータは`.cmo3`という拡張子で保存されています。しかし、Unityにインポートする際には`.moc3`という拡張子の組込み用ファイル形式を用意する必要があります。

今回利用する『桃瀬ひより』は`.cmo3`形式のみの配布なので、`.moc3`形式に書き出す方法を説明します。

組込み用ファイルの書き出しにはCubism Editorを使用します。

[こちら](http://cubism3.live2d.com.s3-website-ap-northeast-1.amazonaws.com/)からCubism Editorをインストールしましょう。

<img width="1078" alt="スクリーンショット 2018-10-18 2.49.49.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/aa842ed3-a089-dd97-dfaa-7646fb1f82e5.png">

利用規約に同意した後、メールアドレスを入力し「最新版をダウンロード」をクリックしてください。ダウンロードしたファイルをダブルクリックし、手順に従ってインストールしてください。

<img width="639" alt="スクリーンショット 2018-10-18 2.54.47.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/2aeb3f8d-2028-5ddc-46bc-b8688646457b.png">

インストールが完了しました。

次に、以下のページに従って`.moc3`ファイルを書き出してください。

~~moc3ファイルの書き出し | Live2D Manuals & Tutorials~~
~~http://docs.live2d.com/cubism-editor-manual/moc3-file/~~

(2020.07.27追記)上記URLがリンク切れになっていました。恐らく以下の手順で大丈夫ですが、未確認です。
組み込み用データ | Live2D Manuals & Tutorials
https://docs.live2d.com/cubism-editor-manual/export-moc3-motion3-files/

<img width="556" alt="スクリーンショット 2018-10-18 3.48.35.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/f17a9641-8dd6-87e3-bb6b-236ebf326475.png">

書き出したファイルは、上記のように一つのフォルダにまとめておいてください。

組込み用ファイルをUnityにインポートしていきます。先程のフォルダをUnityエディタのProjectビュー上にドラッグアンドドロップします。

<img width="493" alt="スクリーンショット 2018-10-18 3.54.47.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/3f9136da-0ce5-dc58-3e93-e074f092c237.png">

インポートが終わると、このようにプレハブファイルが生成されます。

**プレハブファイルが正常に生成されない時は？**

- Live2D SDKのインポート後にUnityの再起動はしましたか？
- 書き出し用ファイルに不足はありませんか？

### モデルをシーン上に配置する

インポートしたモデルをUnityで表示してみましょう。

Projectビュー上で右クリックをして、`[Create]>[Scene]`を選択してください。

<img width="860" alt="スクリーンショット 2018-10-18 4.01.37.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/7f03f137-b534-ba86-71ce-ccf59bbde26a.png">

`Main`と入力してください。

<img width="502" alt="スクリーンショット 2018-10-18 4.01.49.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/0e3e5719-6c58-e050-5afc-b01cc5debf17.png">

作成したシーンをダブルクリックで開いてください。

もし以下のようなウィンドウが表示されたら、`[Don't Save]`を押せば大丈夫です。
<img width="465" alt="スクリーンショット 2018-10-18 4.04.57.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/7251c4ed-5b06-a4ae-856e-25d7ffd41582.png">

Projectビューから、生成されたプレハブを選択し、Hierarchyビューにドラッグアンドドロップします。

<img width="779" alt="スクリーンショット 2018-10-18 4.06.48.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/eeddfa6a-b7cd-ffd6-c073-61f469f6e95c.png">

以下のような状態になればOKです。

<img width="825" alt="スクリーンショット 2018-10-18 4.09.47.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/47a1c1d2-1b2e-5414-7ce3-28d5e7e240e2.png">

Sceneビューにはモデルが表示されていますが、Gameビューには小さく表示されてしまっています。カメラの設定を変更して、大きく表示されるように調整をします。

Hierarchyビューで`Main Camera`を選択してください。

Inspectorビューにカメラの設定が表示されるので、以下のように変更してください。

<img width="378" alt="スクリーンショット 2018-10-18 4.20.05.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/7c177278-c895-f931-5f4e-9fccf8fcd067.png">

- TransformのPosition yを`0.4`に変更
- Backgroundを`(R,G,B)=(0,255,0)`に変更
- CameraのProjectionが`Orthographic`になっていることを確認する
- Sizeを`0.2`に変更

<img width="244" alt="スクリーンショット 2018-10-18 4.19.57.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/b2bf9706-ef47-1fa2-2a26-724474419a7d.png">
Backgroundの設定

<img width="550" alt="スクリーンショット 2018-10-18 4.20.13.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/0f8a4e66-929c-170e-86d7-ce87061b34f7.png">

Gameビューにこのように表示されるようになりました。

メニューから`[File]>[Save Scenes]`をクリックして、シーンを保存しておきましょう。

<img width="321" alt="スクリーンショット 2018-10-18 4.32.03.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/ced5c791-ee91-9c54-ba49-068f7f8c0b1f.png">

では最後に、Unity上でモデルを動かしてみましょう。

Hierarchyビューからモデルを選択してみてください。
<img width="686" alt="スクリーンショット 2018-10-18 4.51.26.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/f10512fa-3bf7-225b-d6da-9d8e130cf965.png">
(レイアウトを変えています)
Inspectorビューに`Cubism Parameters Inspecotr (Script)`というコンポーネントが表示されると思います。それぞれの項目がモデルの各パラメータと対応しています。自由に色々と動かしてみましょう。

![Oct-18-2018 04-55-55 (2).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/116c5bd8-feb0-f99c-7843-38eee6541131.gif)

このように連動してモデルが動くことが確認できます。
なお、変更したパラメータは、右下の「Reset」ボタンでリセットすることができます。

# プレゼンスを上げる

さて、ここからはLive2Dモデルがキャラクターらしく振る舞うための設定をしていきます。

## 口パクの実装

まずは自分の声に合わせてキャラクターが口パクをするようにしてみましょう。
Unityでマイク音声を取得し、音声の大きさをキャラクターの口の開閉に反映させることで実現させます。

Projectビュー上で右クリックをして、`[Create]>[C# Script]`をクリックしてください。ファイル名には`SimpleLipSyncer`と入力してください。

`SimpleLipSyncer`をダブルクリックしてエディタを開きます。以下のスクリプトをコピーアンドペーストし、保存してください。

```cs:SimpleLipSyncer.cs
using UnityEngine;
using Live2D.Cubism.Core;

/// <summary>
/// 口パクを行うクラス
/// </summary>
[RequireComponent(typeof(AudioSource))]
public class SimpleLipSyncer : MonoBehaviour
{
    AudioSource audioSource = null;

    [SerializeField]
    CubismParameter MouthOpenParameter = null;

    float velocity = 0.0f;
    float currentVolume = 0.0f;

    [SerializeField]
    float Power = 20f;

    [SerializeField, Range(0f, 1f)]
    float Threshold = 0.1f;

    void Start()
    {
        // 空の Audio Sourceを取得
        audioSource = GetComponent<AudioSource>();

        // Audio Source の Audio Clip をマイク入力に設定
        // 引数は、デバイス名（null ならデフォルト）、ループ、何秒取るか、サンプリング周波数
        audioSource.clip = Microphone.Start(null, true, 1, 44100);
        // マイクが Ready になるまで待機（一瞬）
        while (Microphone.GetPosition(null) <= 0) { }
        // 再生開始（録った先から再生、スピーカーから出力するとハウリングします）
        audioSource.Play();
        audioSource.loop = true;
    }

    private void LateUpdate()
    {
        float targetVolume = GetAveragedVolume() * Power;
        targetVolume = targetVolume < Threshold ? 0 : targetVolume;
        currentVolume = Mathf.SmoothDamp(currentVolume, targetVolume, ref velocity, 0.05f);

        if (MouthOpenParameter == null)
        {
            Debug.LogError("MouthOpenParameterが設定されていません");
            return;
        }
        // CubismParameterの更新はLateUpdate()内で行う必要がある点に注意
        MouthOpenParameter.Value = Mathf.Clamp01(currentVolume);
    }

    float GetAveragedVolume()
    {
        float[] data = new float[256];
        float a = 0;
        audioSource.GetOutputData(data, 0);
        foreach (float s in data)
        {
            a += Mathf.Abs(s);
        }
        return a / 255.0f;
    }
}
```

Hierarchyビュー上で右クリックをして、`Create Empty`を選択してください。作成したGameObjectを選択した状態で、`Add Component`をクリックしてください。

SimpleLipSyncを検索し、決定します。

<img width="278" alt="スクリーンショット 2018-10-18 5.30.26.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/69ee55de-da27-ce20-236a-dd7b7ab7088b.png">

このスクリプトがマイク音声を取得する役割を果たします。

次に取得した音声を口の開閉に反映させるための設定を行います。
先程のGameObjectを選択した状態で、`Simple Lip Syncer`の`Mouth Open Parameter`の右端の○をクリックします。ウィンドウが表示されるので、`ParameterMouthOpenY`を検索して選択します。

<img width="527" alt="スクリーンショット 2018-10-18 5.31.23.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/d6804ba5-b833-8a91-da74-0d9a3c68e05e.png">

この状態でPlayボタンを押して再生し、してマイクに向かって喋ってみましょう。

![Oct-18-2018 05-36-59 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/d3f87034-bc79-8fda-eaae-1c9998a95b4a.gif)

キャラクターが自分の声に合わせて口パクするようになりました。

なお、この方法だとマイク音がPCから鳴ってしまう点に注意してください。
(問題がある場合は、後述のAniLipSync-live2dなどを使用してください。口の形が一つだけでも5箇所に設定してしまって大丈夫です。)

## まばたきを付ける

参考: [自動まばたきの設定](http://docs.live2d.com/cubism-sdk-tutorials/eyeblink/)

シーン上のモデルに以下のスクリプトを`AddComponent`します。

- `CubismEyeBlinkController`
    - `BlendMode`を`Override`に設定
- `CubismAutoEyeBlinkInput`

<img width="491" alt="スクリーンショット 2018-10-18 5.42.55.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/546d86e9-56dc-ffaf-8c17-c404160fa501.png">

まばたきさせたいパラメータ(=目の開閉パラメータ)に`CubismEyeBlinkParameter`を`AddComponent`します。

対象は以下の2つです。
- `モデル/Parameters/ParamEyeLOpen`
- `モデル/Parameters/ParamEyeROpen`

<img width="493" alt="スクリーンショット 2018-10-18 5.45.40.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/9c9cd246-7b83-5c29-e15e-d49f6d1859f7.png">
`ParamEyeROpen`も同様に設定してください。

![Oct-18-2018 05-51-50 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/06bd9a4b-e781-2426-3066-b6658fbbd6c4.gif)

設定後、再生してみるとまばたきすることが確認できると思います。

## 呼吸モーション

参考: [パラメータを周期的に動作させる方法](http://docs.live2d.com/cubism-sdk-tutorials/harmonicmotion/)

シーン上のモデルに以下のスクリプトを`AddComponent`します。

- `CubismHarmonicMotionController`
    - `BlendMode`を`Override`に設定

呼吸に合わせて動かしたいパラメータに`CubismHarmonicMotionParameter`を`AddComponent`します。

今回は以下の2つに追加してみましょう。
- `モデル/Parameters/ParamBodyAngleY`
- `モデル/Parameters/ParamBreath`

<img width="581" alt="スクリーンショット 2018-10-18 5.59.13.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/c120c074-6bdb-6a2d-09e0-0a31a0818d0c.png">
それぞれのコンポーネントに、上記のような値を設定してください。

![Oct-18-2018 06-04-02 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/e41a14a7-0a5d-16bd-2e63-5f1eb4a505b0.gif)

設定後、再生してみると呼吸モーションを確認できると思います。

## 頭と視線を動かす

マウスの動きに合わせてキャラクターが目で追うようにしてみましょう。

Projectビュー上で右クリックをして、`[Create]>[C# Script]`をクリックしてください。ファイル名には`GazeController`と入力してください。

`GazeController`をダブルクリックしてエディタを開きます。以下のスクリプトをコピーアンドペーストし、保存してください。

```cs:GazeController.cs
using Live2D.Cubism.Core;
using UnityEngine;

/// <summary>
/// 目線の追従を行うクラス
/// </summary>
public class GazeController : MonoBehaviour
{
    [SerializeField]
    Transform Anchor = null;
    Vector3 centerOnScreen;
    void Start()
    {
        centerOnScreen = Camera.main.WorldToScreenPoint(Anchor.position);
    }
    void LateUpdate()
    {
        var mousePos = Input.mousePosition - centerOnScreen;
        UpdateRotate(new Vector3(mousePos.x, mousePos.y, 0) * 0.2f);
    }
    Vector3 currentRotateion = Vector3.zero;
    Vector3 eulerVelocity = Vector3.zero;

    [SerializeField]
    CubismParameter HeadAngleX = null, HeadAngleY = null, HeadAngleZ = null;
    [SerializeField]
    CubismParameter EyeBallX = null, EyeBallY = null;
    [SerializeField]
    float EaseTime = 0.2f;
    [SerializeField]
    float EyeBallXRate = 0.05f;
    [SerializeField]
    float EyeBallYRate = 0.02f;
    [SerializeField]
    bool ReversedGazing = false;
    void UpdateRotate(Vector3 targetEulerAngle)
    {
        currentRotateion = Vector3.SmoothDamp(currentRotateion, targetEulerAngle, ref eulerVelocity, EaseTime);
        // 頭の角度
        SetParameter(HeadAngleX, currentRotateion.x);
        SetParameter(HeadAngleY, currentRotateion.y);
        SetParameter(HeadAngleZ, currentRotateion.z);
        // 眼球の向き
        SetParameter(EyeBallX, currentRotateion.x * EyeBallXRate * (ReversedGazing ? -1 : 1));
        SetParameter(EyeBallY, currentRotateion.y * EyeBallYRate * (ReversedGazing ? -1 : 1));
    }
    void SetParameter(CubismParameter parameter, float value)
    {
        if (parameter != null)
        {
            parameter.Value = Mathf.Clamp(value, parameter.MinimumValue, parameter.MaximumValue);
        }
    }
}
```

Hierarchyビューのモデルの上で右クリックをし、`[CreateEmpty]`を選択、`Anchor`という名前にしてください。Editorビュー上で眉間の位置に`Anchor`を移動させましょう。ひよりモデルの場合は、`(x,y,z)=(0,0.45,0)`の位置です。

<img width="1044" alt="スクリーンショット 2018-11-30 6.50.52.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/f9c17dd6-2d07-cc3b-d251-b45f464f2507.png">

モデルに対して先程のコンポーネントをアタッチします。
以下のように設定してください。対応するパラメータが存在しない場合があるかと思いますが、ある分だけで大丈夫です。

<img width="347" alt="スクリーンショット 2018-11-30 6.55.32.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/9fa05f22-db4b-5578-fa64-49c6d3b95cd8.png">

この状態で再生をし、マウスを動かして見てください。

![Nov-30-2018 07-02-07 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/fb1ff803-db80-18be-c42d-6634e6fa697f.gif)

マウスの先を追うように頭が動くと思います。

<img width="267" alt="スクリーンショット 2018-11-30 7.03.38.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/b0cb5d80-4836-be69-04d4-25c43ea49e13.png">

また、`ReversedGazing`にチェックを入れてみると以下のようになります。

![Nov-30-2018 07-06-33 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/966bab53-3bde-e596-1069-d1f3d845df00.gif)

今度は常に正面を見つめた状態で頭が動くようになりました。

## 表情を付ける

こちらの記事を参考にしてください。
[表情・ポーズを切り替える](http://docs.live2d.com/cubism-sdk-tutorials/blendexpression/)

# 応用編

ここからは応用編です。いくつかの「より魅力的になる表現」を紹介するので、ぜひ参考にしてみてください。

## リミテッドアニメのようなリップシンクを実装する

Live2Dでアニメ調のリップシンクを実現できる[AniLipSync-live2d](https://github.com/nkjzm/AniLipSync-live2d)というライブラリを使った例です。

![Nov-30-2018 08-24-00 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/77538784-de03-b9fb-b6af-46351d34581b.gif)
_「あーいーうーえーおー。こんな感じで、リップシンクができます！」_

別の記事で導入方法を紹介しているので、参考にしてみてください。
[Live2Dでアニメ調のリップシンクを実現する『AniLipSync-live2d』の使い方](https://qiita.com/nkjzm/items/b0d283cf8b1f7fdcf91b)

## ボイスチェンジャー

VTuberとして活動するとき、見た目と声が合っていない場合があると思います。
その場合はボイスチェンジャーを使ってリアルタイムに別の声に変換するという選択肢があります。

Windowsではフリーソフトの[恋声](http://www.geocities.jp/moe_koigoe/koigoe/koigoe.html)を使ったやり方がお手軽です。MacならGarageBandで代替出来ると思います。

また、[VT-4](https://www.roland.com/jp/products/vt-4/)などボイストランスフォーマーと呼ばれる機器を用いて声の変換を行うこともあります。是非調べてみてください。

<blockquote class="twitter-tweet" data-conversation="none" data-lang="ja"><p lang="ja" dir="ltr">あっまじだ、隠すと全然違う…知見だ… <a href="https://t.co/JKK0Je8kds">pic.twitter.com/JKK0Je8kds</a></p>&mdash; Nakaji Kohki (@kohki_nakaji) <a href="https://twitter.com/kohki_nakaji/status/1018007595393605632?ref_src=twsrc%5Etfw">2018年7月14日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## ARKitを使った表情認識

iPhone X以降のFaceIDが付いた端末で利用できるARKitのFace Trackingという機能を使うと、このように高い精度で顔認識をして表情などを変えることが出来ます。

<blockquote class="twitter-tweet" data-conversation="none" data-lang="ja"><p lang="ja" dir="ltr">iPhone X+ARKit+Live2Dがどんな感じに動くかのサンプル<br>(音声はPCで再生してるやつを録音したもの)<br>まだ表情のパラメーターは弄りがいがある感じ <a href="https://t.co/xNQZcQhsTY">pic.twitter.com/xNQZcQhsTY</a></p>&mdash; 🕯 (@mzyy94) <a href="https://twitter.com/mzyy94/status/931228533166260225?ref_src=twsrc%5Etfw">2017年11月16日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## OpenCVforUnityを使った実装

ARKitのFace Trackingを使わない顔認識だと、このような選択肢もあります。
少し高額な有料アセットが必要ですが、導入しやすいと思います。

![](https://camo.qiitausercontent.com/83509f595ad771e62ba1fcd376f581a6bcc1bc69/68747470733a2f2f71696974612d696d6167652d73746f72652e73332e616d617a6f6e6177732e636f6d2f302f32383535382f63343164383630322d383364392d343963652d633131622d3135646239383437613065392e676966)

参考: [FaceRig無しでも中の人(二次元)になりたい！【Unity × OpenCV × Dlib × Live2D】 - Qiita](https://qiita.com/utibenkei/items/15925db826721f6bb00c)

# OBSを使った動画の収録・配信

キャラクターを動かすための配信システムは最低限できたと思うので、次は実際に配信する手順を紹介します。

## 配信アプリの書き出し

まずは先程のシステムを、配信に使いやすいようにアプリとして書き出します。

### PlayerSettingsの設定

メニューより、`[Edit]>[Project Settings]>[Player]`を選択します。

<img width="577" alt="スクリーンショット 2018-11-30 9.01.19.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/8e119bd9-fefd-fa81-0c70-7016dbb525f5.png">

Inscpectビューで`[スタンドアロンタブ]>[Resolution and Presentation]`を開き、`Run In Background`にチェックをいれる。

<img width="272" alt="スクリーンショット 2018-11-30 9.03.16.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/43595104-765e-1911-6c77-f93b6a7f88a7.png">

### BuildSettingsの設定

メニューより、`[File]>[Build Settings]`を選択します。

<img width="339" alt="スクリーンショット 2018-11-30 9.06.00.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/70d8ad57-7b07-ebeb-c77c-509f15e929c0.png">

`Add Open Scenes`を選択し、Mainシーンが`Scenes In Build`に追加されたことを確認してBuildボタンを押す。

<img width="640" alt="スクリーンショット 2018-11-30 9.07.05.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/5b40cdf7-8dce-3f0b-8b7a-9bcdb52fcea0.png">

適当な名前を付けて「Save」ボタンを押す。

<img width="720" alt="スクリーンショット 2018-11-30 9.09.38.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/775a589b-6fee-5407-ea20-6731f4605a2f.png">

このように無事アプリが書き出されたらビルド成功です。
Windowsの方は適宜読み替えてください。

<img width="643" alt="スクリーンショット 2018-11-30 13.12.02.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/e925d1b1-5142-8c8a-80ad-20e2196b021e.png">

`.dll`周りでエラーが出た場合、Unityを再起動してもう一度試してみてください。

### アプリの起動確認

ビルドしたファイルをダブルクリックで実行します。

<img width="488" alt="スクリーンショット 2018-11-30 20.04.59.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/b424b85c-3078-f146-0943-b26430afe68d.png">

`Windowed`にチェックを入れます。
その他の設定はおまかせで良いですが、Live2DやOVRLipSyncはそこそこ負荷が高いアプリなので、動作が重くなるようでしたら低めにすると良いかと思います。

任意の設定が完了したら「Play!」ボタンを押します。

<img width="737" alt="スクリーンショット 2018-10-18 18.49.30.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/d9665c44-2205-98b1-06e1-c4fa7b1a6075.png">

モデルが呼吸などのアニメーションをしていること、リップシンクが正常に動くことなどを確認してください。

## OBSの設定

配信にはOpen Broadcaster Software (OBS)というアプリケーションを利用します。
Windows, Mac, Linuxをサポートしているオープンソースの配信ソフトウェアです。

[こちらのダウンロードページ](https://obsproject.com/ja/download)を開き、お使いのOSに対応したインストーラーをダウンロードしてください。また、そのままインストールを進めてください。

インストールが完了したらOBSを起動します。初回起動時におすすめ設定を適用するか聞かれるかもしれませんが、あとから変更できるのでどちらでも大丈夫です。

<img width="1087" alt="スクリーンショット 2018-11-30 21.15.20.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/50116d06-b1a6-9e89-1609-c8d9733ce198.png">

このような画面が表示されます。

### ソースの設定

ソースの「+」からウィンドウキャプチャを選択

<img width="271" alt="スクリーンショット 2018-11-30 21.17.20.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/388ba996-ca37-56e0-a541-ed8a2d5d2c3a.png">

新規作成が選択された状態で任意の名前を入力し、OKを押します。名前はそのままでも大丈夫です。

<img width="376" alt="スクリーンショット 2018-11-30 21.18.30.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/32a0f16c-7620-54ea-bc64-7f4bf09ee7eb.png">

リストの中から書き出したアプリを選択する。
起動中のアプリのみがリストに表示される点に注意してください。

<img width="735" alt="スクリーンショット 2018-11-30 21.45.15.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/1574164d-0cab-bab4-141b-b1da516c7926.png">

正しく選択できると上記のように書き出したアプリの映像が表示されるので、その状態でOKを押します。

ソースから、先程追加したウィンドウキャプチャの上で右クリックをし、`フィルタ`を選択します。

<img width="507" alt="スクリーンショット 2018-11-30 21.57.28.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/69a92fff-c55b-8bf0-e1cd-62ce4cb597c1.png">

エフェクトフィルタより`クロマキー`を選択

<img width="317" alt="スクリーンショット 2018-11-30 21.57.58.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/814540e9-d2e2-9070-a367-c2d61e19381d.png">

デフォルトで緑になっているので、このように背景が透過されます。
もしUnity側で別の色を背景色に設定していた場合などは、適宜設定を変更してください。

<img width="566" alt="スクリーンショット 2018-11-30 21.58.45.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/d33afaf6-9a87-5442-9431-4b26bef0caaf.png">

(Macのみ)ウィンドウの枠を切り抜きます。エフェクトフィルタより`クロップ/パッド`を選択してください。画像のように値を調整してください。 

<img width="867" alt="スクリーンショット 2018-11-30 22.02.11.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/83b1bf29-99cd-1548-2b9a-ab81e95fe2ca.png">

設定が完了したら、右下の「閉じる」ボタンを押してください。

最後に、赤枠をドラッグしてサイズと位置を調整してください。
端の方は補正が効くので合わせやすいと思います。

![Nov-30-2018 22-05-58 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/7224041a-20fd-8501-72dd-a73ef657e733.gif)

### 背景の設定

背景を設定します。今回は画像を利用しますが、例えば動画ファイルやデスクトップ、ゲーム画面などを背景にしても大丈夫です。著作権などには十分に注意してください。

今回は[こちらの画像](http://creativefreaks.net/?p=4370)を使用させていただきました。

ソースの「+」から画像を選択し、新規作成から任意の名前を付けてOKを押します。
「参照」をクリックし、ファイラーから任意の画像を選択します。

<img width="731" alt="スクリーンショット 2018-11-30 22.18.35.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/f182d39d-def0-0f15-e4d9-5ac2a98a7d39.png">

上記のようになったら、「OK」をクリックします。

赤枠をドラッグしてサイズや位置の調整を行います。

![Nov-30-2018 22-22-26 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/a81f011a-c76c-c4c3-4b9e-77efcf127d91.gif)


背景がキャラクターよりも上に表示されているので、重なり順を入れ替えます。
ソースから画像をクリックして、「V」をクリックします。

<img width="199" alt="スクリーンショット 2018-11-30 22.23.37.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/39c187b8-63fd-318f-79eb-7fdbc20e9726.png">

ソースでは順番が上のものほど手前に表示されるので、以下のように正しい重なり順になりました。

<img width="899" alt="スクリーンショット 2018-11-30 22.24.55.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/b65354de-696e-070d-4467-5374981cdb3f.png">

これで映像の準備は完了しました。

### 音声の設定

最後に音声の設定をします。

ソースの「+」から「音声入力キャプチャ」を選択し、新規作成から任意の名前を打ってOKを押します。

デバイスのリストから「既定」を選択します。もし入力したい音声ソースがある場合や、ボイスチェンジャーなどを使っていて仮想音声ソース(Soundflower等)を使いたい場合などは、そちらを設定してください。

<img width="309" alt="スクリーンショット 2018-11-30 22.27.23.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/eb515394-a262-1f09-969e-b22b092a3c7a.png">

選択したらOKを押します。

設定した音声に併せてゲージが反応することが確認出来ると思います。

![Nov-30-2018 22-30-17 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/af5e09ff-1662-7081-b829-de3b12a83354.gif)

これだけでも良いのですが、OBSでは映像のキャプチャ時に少し遅延があります。
書き出したアプリをOBSを並べて口パクさせてみると、元アプリ(右)の口が動いてからOBS(左)の口が動くまでにワンテンポ遅れていることが分かると思います。

![Nov-30-2018 22-36-57 (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/65cf4c41-73a4-d4d2-8ebf-030b4cc1aefd.gif)

そこで、ボイスの収録を映像の遅延に併せて少し遅らせる設定をします。
ミキサーの右の歯車アイコンをクリックし、「オーディオの詳細プロパティ」を選択してください。

<img width="451" alt="スクリーンショット 2018-11-30 22.40.49.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/a50bfde3-c7c3-4a50-af0b-feeed22565b4.png">

マイクの同期オフセットに値を入力してください。環境毎に遅延時間が異なるので、調整してみてください。

<img width="1002" alt="スクリーンショット 2018-11-30 22.42.09.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/d3267af8-5aaf-0990-2539-e85a190c23bf.png">

完了したら閉じるを押してください。
これで映像と音声の準備が出来ました。

### 動画の録画

右下の「設定」より、出力タブの「録画フォーマット」をmp4やmovなどに変更してください。
(デフォルトの`flv`だと扱いづらいと思うので)

録画開始ボタンで録画開始、録画終了ボタンで録画終了です。

なお、リップシンクの反応が悪い時は、書き出したアプリを選択した状態で収録を行ってください(録画開始ボタンを押した直後に、書き出したアプリのウィンドウをクリックすればOKです)。ウィンドウを選択していない状態だと認識しづらい問題があるようです。

録画が終了すると、MacだとMovieフォルダなどに出力されます。
出力場所は、「設定」から出力タブを選び、「録画ファイルのパス」にて確認・変更することが出来ます。

<img width="604" alt="スクリーンショット 2018-11-30 22.48.49.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/3946f742-0f60-97dd-3790-582fe8ef487c.png">

動画を再生し、映像や音声がきちんと収録されていることを確認してください。

あとはTwitterやYouTubeにアップロードすれば、**見事VTuberデビューです！**

### その他

OBSにはYouTubeなどの生配信を行う機能や、音声のノイズを除去する機能など、様々な機能が付いています。
やりたいことがあれば、是非調べて挑戦してみてください。

# 最後に

今回扱った内容は基本的なことばかりです。
色々な技術を組み合わせてぜひ魅力的なキャラクターを生み出してください！

明日は、[バーチャルモーションキャプチャ](https://sh-akira.github.io/VirtualMotionCapture/)開発者の @sh_akira さんによる[UniVRM+SteamVR+Final IKで始めるVTuber](https://qiita.com/sh_akira/items/81fca69d6f34a42d261c)です。
[VTuber Tech #1 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/vtuber) 
[VTuber Tech #2 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/vtuber2) 

# 関連

【サポーターズCoLab勉強会】Unity+Live2Dで始めるVTuber入門ハンズオン - サポーターズCoLab
https://supporterzcolab.com/event/568/

低スペックPCでVtuberになるいくつかの方法 - Qiita
https://qiita.com/Hirosaji/items/83777124823683766d96



