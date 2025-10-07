---
title: 【Unity】ドコモAIエージェントAPI SpeakSDKをAudioSource経由で音声出力する
published_at: '2020-05-21 23:59'
private: false
tags:
  - Untiy
updated_at: '2020-05-21T23:59:53+09:00'
id: 117bea07c56af1e5e7a0
organization_url_name: null
slide: false
---
# はじめに

こちらの記事を参考にリップシンク（口パク）をしようとしていたところ、SpeakSDKの仕様変更にぶつかりました。この記事では最新の`speak-unity-sdk v1.14.5`でリップシンクを行う方法を紹介したいと思います。
[ドコモAIエージェントAPIを使ってキャラクターと会話する](https://qiita.com/broken55/items/5cdda8366aa2b6fa6fc0)


# 環境

- Windows 10 Home
- Untiy 2019.3.13f1（推奨バージョンは2019.3.2f1）
- speak-unity-sdk v1.14.5

# 状況

初めの記事のバージョンではUnityの`AudioSource`上から出力されていた音声が、DLLなどネイティブプラグイン側から直接出力される仕様になっていました。こうなるとUnity側には音が流れない状態になるため`AudioListener`で音を拾うことができないという状況が発生していました。

しかし、`v1.14.5`で下記の変更が入ったため、その方法を紹介します。

> AudioSouceで合成音声が利用できるように機能追加

引用元：https://github.com/docomoDeveloperSupport/speak-unity-sdk/releases/tag/v1.14.5

# SpeakSDKをAudioSource経由で音声出力する方法

サンプルのソースコードを元に紹介します。Editor上での動かし方はこちらの記事を参照してください。
[【Unity】ドコモAIエージェントAPI SpeakSDKのサンプルをEditor上で実行する - Qiita](https://qiita.com/nkjzm/items/bdff6d7986144197439e)

AudioSource経由で音声出力する方法は[公式ユーザーガイドPDF](https://github.com/docomoDeveloperSupport/speak-unity-sdk/blob/master/speak_unity_sdk_users_guide.pdf)の27ページ目辺りの6.3章で説明されています。具体的には初期化のタイミングで`SetAudioSource()`を呼び出せばいいそうです。

サンプルの[SpeakSDKManager.cs](https://github.com/docomoDeveloperSupport/speak-unity-sample/blob/master/sample_app/SpeakSampleApp/Assets/Scripts/SpeakSDKManager.cs)の場合、`InitializeSpeakSDK()`に下記の2行を追加してください。

```cs
    private void InitializeSpeakSDK()
    {
        Speak.Instance().SetURL("wss://spf-v2.sebastien.ai/talk");
        Speak.Instance().SetDeviceToken("c0ed13a0-0069-4c81-8dcb-397cdf60c9fa");

        // 以下の2行を追加
        var audioSource = GetComponent<AudioSource>();
        Speak.Instance().SetAudioSource(audioSource);

        // Callback.
        Speak.Instance().SetOnTextOut(OnTextOut);
        Speak.Instance().SetOnMetaOut(OnMetaOut);
    }
```

また、`SpeakSDKManager`がアタッチされているオブジェクトに`AudioSource`コンポーネントを追加しておいてください。

これで、最初の記事の方法でリップシンクができるようになりました。

# おまけ：SDKをアップデートする際の注意点

Unityでは一度でもスクリプトからNative Pluginをロードすると、Unityを再起動するまでUnloadされない仕様になっています。そのため、ロード済みの状態で.unitypackageを適用しようとすると、dllの上書きがされません。アップデート前にプロジェクトを再起動することで解決します。

参考：[【Unity】Macで使えるNative Pluginを作る（OpenCV編） - おもちゃラボ](http://nn-hokuson.hatenablog.com/entry/2017/05/12/201453#%E3%83%97%E3%83%A9%E3%82%B0%E3%82%A4%E3%83%B3%E3%81%AE%E3%83%AD%E3%83%BC%E3%83%89%E3%81%AB%E3%81%AF%E6%B3%A8%E6%84%8F%E3%81%8C%E5%BF%85%E8%A6%81%E3%81%A7%E3%81%99)

また、dllをアップデートするとEditorで使えるようにする設定もリセットされるのでご注意ください。
[【Unity】ドコモAIエージェントAPI SpeakSDKのサンプルをEditor上で実行する - Qiita](https://qiita.com/nkjzm/items/bdff6d7986144197439e)

# 謝辞

この記事を作成するにあたり、[AIセバスちゃんさん (@SebasAi)](https://twitter.com/SebasAi) にアドバイスをいただきました。ありがとうございました！

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">XR Kaigiの講演のスライドです！！<br>「音声対話エンジンを使った中の人がいないバーチャルキャラクターとその先の未来」<a href="https://twitter.com/hashtag/XRKaigi?src=hash&amp;ref_src=twsrc%5Etfw">#XRKaigi</a><a href="https://t.co/ilYDlldAvA">https://t.co/ilYDlldAvA</a></p>&mdash; AIセバスちゃん (@SebasAi) <a href="https://twitter.com/SebasAi/status/1202870099981422592?ref_src=twsrc%5Etfw">December 6, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

# 最後に

宣伝ですが、 月額制のメンターサービスで初心者向けの開発サポートをしています。分からないことがあれば是非こちらで質問してください！　
https://menta.work/plan/1115
