---
title: "【Unity】ドコモAIエージェントAPI SpeakSDKのサンプルをEditor上で実行する"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
---

# 初めに

「SpeakSDK for Unity サンプルアプリケーション」の実行手順をまとめました。トライアルサーバ向けの手順です。
[docomoDeveloperSupport/speak-unity-sample](https://github.com/docomoDeveloperSupport/speak-unity-sample)

概ね以下の記事の通りですが、少しバージョンが変わっていたので補足していきます。
[ドコモAIエージェントAPIを使ってキャラクターと会話する - Qiita](https://qiita.com/broken55/items/5cdda8366aa2b6fa6fc0)

# 環境

- Windows 10 Home
- Untiy 2019.3.13f1（推奨バージョンは2019.3.2f1）
- speak-unity-sdk v1.14.4

# 流れ

1. サンプルのソースコードをダウンロード
2. SDKのダウンロードとインポート
3. デバイスIDの取得
4. デバイストークンの取得
5. Unity上でデバイストークンを登録
6. 実行

# 手順

以下のリポジトリをソースコード毎clone、もしくはダウンロードしてください。
https://github.com/docomoDeveloperSupport/speak-unity-sample

speak-unity-sdkの最新版をダウンロードしてください。
https://github.com/docomoDeveloperSupport/speak-unity-sdk/releases/latest

Uniyでspeak-unity-sampleを開き、先ほどのSDKをUnityプロジェクト上にインポートしてください。

次にデバイスIDを取得します。以下のページにログインをし、設定から「デバイスIDの追加」を行ってください。デバイスIDが表示されるので、メモしておいてください。
https://agentcraft.sebastien.ai/

デバイストークンを取得します。以下のページにログインをし、左上の「＋」アイコンから新規デバイス登録画面を開いてください。先ほどのデバイスIDを入力し、登録してください。
https://users-v2.sebastien.ai/

サンプルの直下に入っている`GetTrialDeviceToken.py`を実行する準備をします。

まずは`GetTrialDeviceToken.py`を適当なエディタ（メモ帳でもOK）で開き、42行目の`XXXXXXXXXXXXXXXXXXXX`部分を先ほど取得したデバイスIDに書き換えて保存します。

```（抜粋）GetTrialDeviceToken.py
CONFIG = {
    "trial":{
        "device_id":"XXXXXXXXXXXXXXXXXXXX",
        "uds":"https://users-v2.sebastien.ai"
    }
}
```
引用元：https://github.com/docomoDeveloperSupport/speak-unity-sample/blob/master/GetTrialDeviceToken.py#L40-L45

次にスクリプトを実行します。
Windowsの場合はpython3の実行環境が必要なので、こちらを参考にインストールしてください。パスを通すにチェックを入れておけば、コマンドプロンプトからコマンドが打てるようになります。
https://www.python.jp/install/windows/install_py3.html

python3のインストール後、コマンドプロンプト上で以下のようにコマンドを入力してください。

```bash
# サンプルのコードに移動
$ cd move/your/directory
# デバイストークンの発行
$ python GetTrialDeviceToken.py
```

メッセージが表示されるのでエンターキーを押します。今までの手順が成功していれば次のような出力がされます。

```bash
{
    "device_token": "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy", 
    "refresh_token": "oooooooo-oooo-oooo-oooo-oooooooooooo", 
    "status": "valid"
}
SAVE ./.trial_device_token : yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy
SAVE ./.trial_refresh_token : oooooooo-oooo-oooo-oooo-oooooooooooo
```

`device_token`の右側にある`yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy`の部分がデバイストークンなので、メモしておいてください。

次に、Unity上でデバイストークンを登録します。`Assets/Scripts/SpeakSDKManager.cs`の139, 140行目を以下のように書き換えてください。

- `wss://hostname.domain:443/path` -> `wss://spf-v2.sebastien.ai/talk`
- `PUT_YOUR_DEVICE_TOKEN` -> 先ほど発行したデバイストークン（デバイスIDではない）

```（抜粋）SpeakSDKManager.cs
    // ---------------------------------------------------------------------------- //
    //  SDK初期化処理
    // ---------------------------------------------------------------------------- //
    private void InitializeSpeakSDK()
    {
        Speak.Instance().SetURL("wss://hostname.domain:443/path");
        Speak.Instance().SetDeviceToken("PUT_YOUR_DEVICE_TOKEN");

        // Callback.
        Speak.Instance().SetOnTextOut(OnTextOut);
        Speak.Instance().SetOnMetaOut(OnMetaOut);
    }
```
引用元：https://github.com/docomoDeveloperSupport/speak-unity-sample/blob/master/sample_app/SpeakSampleApp/Assets/Scripts/SpeakSDKManager.cs#L134-L145

Editor上でSDKを実行するためにはDLLの設定を変更する必要があります。（64bit環境の場合）`Assets/Plugins/Windows/x86_64/flow.dll`のinclude platformで`Editor`にチェックを入れ、Applyボタンを押してください。

![sdfasdfas.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/ab8b6d58-0d67-b9c2-7d48-a5905c089862.png)

準備は以上です。Unityの`Assets/Scenes/main.unity`を開き、シーンを実行します。

`SDKstart`をクリックすると少し待って緑色に変化します。その状態でテキストフィールドに「こんにちは」などと打って、テキストと音声が再生されれば成功です。お疲れ様でした。

![fasdfasdfas.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/625fe301-054e-eccd-8363-3bfb7def2d10.png)

# 最後に

宣伝ですが、 月額制のメンターサービスで初心者向けの開発サポートをしているので、分からないことがあれば是非こちらで質問してください！　
https://menta.work/plan/1115
