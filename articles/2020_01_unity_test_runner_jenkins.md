---
title: "Unity2019.2以降のTest RunnerをJenkinsと連携させる時の備忘録"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Jenkins", "Unity"]
published: true
---
## はじめに

Test RunnerとJenkinsを連携させる際にバージョンの違いでいくつかコマンドの変更などがあったので、簡単にまとめたいと思います。EditModeとPlayMode両方に対応しています。

## 環境

- Windows 10 Home
- Jenkins: ver. 2.204.1
- Unity 2019.2.17f1
- Test Framework 1.0.18

## Test Runnerの導入

2019.2以降ではデフォルトでTest Runnerが使えない状態になっています。[Window]->[Package Manager]から「Test Framework」をInstallしてください。

インポートが終わると、[Window]->[General]->[Test Runner]からビューを表示できるようになります。

## Tests Assemblyの作成

こちらの記事が分かりやすかったです。

[Unityでテストを書くのが当然になる時代に今から備えよう - Qiita](https://qiita.com/naninunenoy/items/b5092774fed30739adbc#%E3%81%A8%E3%82%8A%E3%81%82%E3%81%88%E3%81%9A%E4%BD%9C%E3%82%8B)

## Jenkinsとの連携

概ねこちらの記事の通りなのですが、いくつか詰まった部分があるので補足していきます。

[UnityのEditor Test RunnerをJenkinsで走らせて、Slackで通知 - Qiita](https://qiita.com/fuqunaga/items/f92244502e946d34578b)

### コマンドラインからTestを実行

ドキュメントはこちらです(Test Framework @1.0系)。
[Running tests from the command line | Package Manager UI website](https://docs.unity3d.com/Packages/com.unity.test-framework@1.0/manual/reference-command-line.html)

[コマンドライン引数のマニュアル](https://docs.unity3d.com/Manual/CommandLineArguments.html)や[Test Runnerのマニュアル](https://docs.unity3d.com/jp/current/Manual/testing-editortestsrunner.html)を見てもほとんど記述がないので混乱するのですが、Package ManagerのTest Frameworkのページに載っていました。今後はこちらに移行するのかと思ったのですが、[Unity2020.1のTest Runnerのマニュアルページ](https://docs.unity3d.com/2020.1/Documentation/Manual/testing-editortestsrunner.html)は存在していてよく分からないです。

テストはこのように実行します。

```sh
-batchmode -runTests -testPlatform editmode -testResults "${WORKSPACE}\result.xml" -logFile
```

- `runTests`: テストを実行します。
- `testPlatform`: `editmode`もしくは`playmode`を指定することができます。`testPlatform`がない場合はデフォルトEditModeで実行されます。この部分にプラットフォーム(StandaloneWindows, iOSなど)も指定できるようですが未確認です。
- `testResults`: 結果ファイルのパスを指定できます。単に`result.xml`だけでは出力に失敗したので、絶対パスで指定するようにしてください。

また、古いバージョンとの差分は恐らくこのようになっています(後方互換性あるかも)。

- `runEditorTests`->`-runTests`
- `testsResultFile`->`testResults`

### テスト結果をビルド結果に反映させる

EditModeとPlayModeの両方のテスト結果を通知する方法を紹介します。先の記事にあるNUnit Pluginを導入してください。(JUnitではないので注意です）

差分として、標準で書き出されるファイル名が`EditorTestResults.xml`でなく`TestResults-xxxxxxxxxxxxxxxxxx.xml`(xは数字)に代わっています。

そのため、[NUnit test result report]の[Test report XMLs]には`*.xml`を指定し、ビルド時には下記のようなコマンドを設定してください。

![dfasdキャプチャ.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/5b84c56b-57c6-0fbc-cb9e-5dfc6f76ad4a.png)

```sh
# EditModeテストの実行
-batchmode -runTests -testPlatform editmode -testResults "${WORKSPACE}\result-editmode.xml" -logFile
# PlayModeテストの実行
-batchmode -runTests -testPlatform playmode -testResults "${WORKSPACE}\result-playmode.xml" -logFile
```

こうすることで、それぞれのビルド結果が`resut-editmode.xml`,`resutl-playmode.xml`に出力され、`*.xml`で両方ともビルド結果に反映されるようになります。出力ファイルはビルドする毎に上書きされます。出力ファイル名を指定しない場合はビルド毎に新しいファイルが生成されるため、ビルド結果に前回のテスト結果も含まれてしまう点に注意してください。また、誤ってEditModeとPlayModeの出力ファイル名を同じにしてしまうと後から実行された方に結果が上書きされてしまう点にも注意してください。

## 参考

- [[UnityTest]UnityTestのPlayModeテストをコマンドラインから実行する - Qiita](https://qiita.com/ShibainuBot/items/306e4d4b3497d07ec577)
- [【Unity】Unity Test Runner がコマンドラインから実行できなかった場合に考えられる原因 - コガネブログ](http://baba-s.hatenablog.com/entry/2019/03/19/172000)

