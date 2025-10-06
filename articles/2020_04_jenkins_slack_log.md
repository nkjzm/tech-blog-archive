---
title: "【Jenkins】ビルド失敗時のログをSlackに自動投稿する"
emoji: "🔧"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Jenkins", "Slack"]
published: true
---
# はじめに

<img width="709" alt="スクリーンショット 2020-04-03 15.54.20.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/1b15b1a1-4239-fb12-f787-33b0ba8310e6.png">

Jenkinsのビルドが失敗した時、ログから原因を特定して修正を行う必要があります。しかし、Jenkinsを社内のローカルサーバーで動かしている場合など、外部からアクセスできない場合がありました。そこで、今回はビルド失敗時のログを自動的にSlackに投稿する仕組みを作ったので、紹介したいと思います。


# 環境

- Windows 10 Home 1903
- Jenkins ver. 2.204.5

# 方法

## ビルド失敗時のトリガー

今回は[Parameterized Trigger plugin](https://plugins.jenkins.io/parameterized-trigger/)を使いました。これはパラメータを引継ぎつつ下流ジョブを動かすことができるプラグインです。ログを出力する際に必要がパラメーター渡しつつ、また発火の条件を指定することもできる(今回はビルド失敗時)ため、要件に合致していました。

<img width="850" alt="スクリーンショット 2020-04-03 15.36.09.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/70f0dc47-0d9d-c9dd-d8cb-04e62d7947ca.png">

参考: [開発者（個人）のためのJenkins - Parameter編](https://qiita.com/yasuhiroki/items/daff66ab18b315ae4298)

ちなみに下流ジョブでは受け取るパラメータを定義しておく必要がある点に注意です。

<img width="861" alt="スクリーンショット 2020-04-03 15.41.08.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/6947f671-5ba1-b4be-6974-40560ff0ac53.png">


## Jenkinsのビルドログを取得してutf8に変換する

下流ジョブのビルド/シェルの実行にて記述していきます。

```bash
cd "${JENKINS_HOME}/workspace"

curl http://localhost:8080/all/job/${PROJECT_NAME}/${BUILD_NUMBER}/consoleText >${PROJECT_NAME}-${BUILD_NUMBER}.log
./convert.bat ${PROJECT_NAME}-${BUILD_NUMBER}.log
```

ビルドログの取得には`curl`コマンドを利用します。ビルドログは`http://[JENKINS_URL]/job/[JOB_NAME]/[BUILD_NUMBER]/consoleText`で取得できるため、上流ジョブから引き継いだパラメータを利用して加工します。そのままだと`concoleText`という名前で保存されてしまうので、今後のためにビルド情報を使った名前をつけておきます。

また、WindowsではShift-Jis形式になっていて不都合があるため、UTF8に変換しておきます。以下のバッチファイルを利用しました。

参考: [シフトJISのテキストファイルをUTF-8に変換するバッチ - 今日を乗り切るExcel研究所](https://www.shegolab.jp/entry/windows-conv-text-utf8)

(今回は出力ファイルで上書きされるように一部変更しています)

## Slackにログファイルをアップロードする

Slack APIを使ってファイルをアップロードします。ファイル操作の権限が必要なため、Slack Appの作成が必要になります。少し煩雑ですが、ドキュメントを参考に進めていけば難しく無いと思います。

参考: [Basic app setup | Slack](https://api.slack.com/authentication/basics)
参考: [files.upload method | Slack](https://api.slack.com/methods/files.upload)

curlコマンドを使って以下のようにアップロードできました(`CHANNEL_ID`と“ACCESS_TOKEN`は書き換えてください)

```bash
curl -F file=@${PROJECT_NAME}-${BUILD_NUMBER}.log -F channels=[CHANNEL_ID] -H "Authorization: Bearer xoxb-[ACCESS_TOKEN]" https://slack.com/api/files.upload
rm ${PROJECT_NAME}-${BUILD_NUMBER}.log
````

参考: [Slack — APIに使う「チャンネルID」を取得する方法 - Qiita](https://qiita.com/YumaInaura/items/0c4f4adb33eb21032c08)

最後に`rm`コマンドでローカルからファイルを削除して終わりです。

# 最後に

宣伝ですが、MyDearest株式会社では新作VRゲーム[『ALTDEUS: Beyond Chronos（アルトデウス: ビヨンドクロノス）』](https://altdeus.com/)を開発中です。リリースされたぜひ遊んでください！

また、私のTwitter([@nkjzm](https://twitter.com/nkjzm))のフォローや「**LGTM**」もよろしくお願いします！
