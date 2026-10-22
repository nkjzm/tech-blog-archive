---
title: "【Jenkins】ビルドしたUnityアプリをアーカイブして自動プレイを実行をする【bat】"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Jenkins", "Unity"]
published: true
published_at: 2020-06-09 18:47
---
# 初めに

Unityである程度の規模の開発をしていると、何かの変更によって別の何かが動かなくなることなどがあり大変ですよね。レビューフローやテストなどである程度は防げますが、実行してみないと分からないことも多いと思います。そこで、今回はJenkinsとバッチファイルを使って自動プレイの仕組みを作る方法を紹介したいと思います。実行対象のビルドは`.exe`形式です。

この記事の対象は以下のような方です。

- UnityプロジェクトでCI環境を構築したい方
- 自動プレイテストの仕組みを作りたい方

また、自動プレイをアプリ内で実装する詳細は方法については言及していません。

かなり無理やりな方法ですが、誰かの参考になれば幸いです。

# 環境

- Windows 10 Home 1903
- Jenkins ver. 2.222.3

# 自動プレイの目的

自動プレイで確認できる項目はこの辺りでしょうか。

- 起動するか
- ErrorやExceptionがでないか
- エイジングテスト（長時間実行してクラッシュしないか）

これを人間がまじめにやろうとすると地味に面倒なので、リポジトリにpushすれば勝手にビルドして実行してくれて、早い段階で異常に気が付ける環境を作ろうという流れです。

併せてこの辺の仕組みを入れておくと捗るかと思います。

[【Unity】ビルドしたアプリの実行時エラーをSlackに通知する - Qiita](https://qiita.com/nkjzm/items/e27a6805fbf4e472c1d5)

# 手順

JenkinsでUnityプロジェクトをビルドする手順については色々な方がまとめられていると思うので今回は割愛します。

## アプリをアーカイブする

そのままだと成果物はJenkinsによって管理されるのですが、今回はローカルのドライブに保存していきました。

こちらの記事のようにParameterized Trigger pluginを使い、ビルド成功時に動かすジョブを設定しています。

[【Jenkins】ビルド失敗時のログをSlackに自動投稿する - Qiita](https://qiita.com/nkjzm/items/0de43b0f8e75579c30fb)

![キャプチャ.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/fd33bf40-8f33-c9f0-9913-71f8bd426bc6.png)

後続ジョブの設定です。

パラメータの受け渡しをしたい場合は「ビルドのパラメータ化」より同名のパラメータを宣言しておいてください。

![1キャプチャ.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/64023262-ed71-2613-9ada-52619d07bef1.png)

また、「シェルの実行」よりbatファイルを実行するようにしました。

![2キャプチャ.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/41cd84d8-4741-207f-8a42-64cdb64c00fb.png)

コードの中身はこんな感じです。環境ごとに保存方法を分けたりしています。
今回自動プレイを実行するDev環境のコードでは、最新5件のみをアーカイブしておくように設定しました。

```bat:BuildCopy.bat
echo "Build Copy"

setlocal enabledelayedexpansion

set name=%1
set number=%2
set branchpath=%3
set env=%4

echo %name%
echo number%
echo %branchpath%

set n=0

set list=%name:-=,%
for %%a in (%list%) do (
  echo %%a
  set string[!n!]=%%a
  set /a n=n+1
)


set list2=%branchpath:/=,%
for %%b in (%list2%) do (
  echo %%b
  set branch=%%b
)

rem 0: ProjectName
rem 1: Platform
rem 2: Job (Dev/Prd/Demos)

echo "M:\ProjectName\Executables\%string[1]%\%string[2]%"
echo "%name%\Builds\%string[1]%\%string[2]%"

net use m: /delete
net use m: \\192.168.xx.xx\MyDearest 

if %string[2]% == Demo (

  rem 保存先をブランチ毎に分ける
  xcopy "%name%\Builds\%string[1]%\%env%" "M:\ProjectName\Executables\%string[1]%\%string[2]%\%branch%\%number%" /s/e/i/Y

  exit /b 0

) else if %string[2]% == Prd (

  rem Prdは全件保存
  xcopy "%name%\Builds\%string[1]%\%string[2]%" "M:\ProjectName\Executables\%string[1]%\%string[2]%\%number%" /s/e/i/Y

  exit /b 0

) else (

  xcopy "%name%\Builds\%string[1]%\%string[2]%" "M:\ProjectName\Executables\%string[1]%\%string[2]%\%number%" /s/e/i/Y

  cd /d "M:\ProjectName\Executables"

  if not exist "%string[1]%\%string[2]%" (
    md "%string[1]%\%string[2]%"
  )
  cd "%string[1]%\%string[2]%"

  rem 最新5件以外を削除
  for /f "skip=5" %%A in ('dir /ad /b /o-n') do rd /s /q "%%A"
)
```


## アプリに自動プレイモードを仕込む

以下の記事のように、コマンドライン引数付きで起動した場合に自動プレイをするようにしました。

[【Unity】コマンドライン引数で単一ビルドに複数ビルドの振る舞いをさせる - Qiita](https://qiita.com/nkjzm/items/0bb9335111a596b6774f)

これはトリガー部分だけなので、自動的にアプリを進める部分に関しては各アプリで実装してください。モンキーテストのようにランダムにタップする仕組みや、状況に応じて行動するロジック、AIなどの仕組みが必要になるかと思います。

## 自動プレイを実行する

.exeを実行するにあたりJenkinsやWindowsのタスクスケジューラを試したのですが、バッググラウンドでの実行になってしまう点に悩まされました。

そこで、少しだけ手間ですがコマンドプロンプトからbatファイルを起動して常時動かしておくことにしました。特定ディレクトリ内にビルド番号別に実行ファイルが保存されていくので、1時間おきに更新日時が一番新しいものを起動して自動プレイを開始するbatファイルです。

```bat
rem オートモードで実行

rem 
:top

rem ローカルのドライブに名前付け
net use m: /delete
net use m: \\192.168.xx.xx\MyDearest 

rem 外付けドライブに移動 cd でなくpushdを使うとあとでpopdできて便利
pushd "M:\ProjectName\Executables\PlatformXXX\Dev"

rem 更新日時が新しいフォルダのパスを取得
for /f %%i in ('dir /b /od') do set x="%%~fi"

rem フォルダ名部分のみ取得
for /f "DELIMS=" %%a in ("%x%") do set Name=%%~nxa

rem アプリを実行 /maxはウィンドウを最大化するオプション
start /max "" "%Name%\XXX-v0.1.%Name%.exe" -auto

rem 元のパスに戻っておく
popd

rem 3600秒（60秒*60分）待つ
timeout 3600

rem アプリを終了
taskkill /im XXX-v0.1.%Name%.exe

rem 一応ちょっと待つ
timeout 30

rem 先頭に戻って繰り返し
goto top
```

あとは画面収録の様子をストリーミングしたり録画したりしておくと、不具合が起きた時に原因を見つけやすくなって便利だと思います。

# 最後に

宣伝ですが、MyDearest株式会社では新作VRゲーム[『ALTDEUS: Beyond Chronos（アルトデウス: ビヨンドクロノス）』](https://altdeus.com/)を開発中です。リリースされたぜひ遊んでください！

また、よかったらTwitter(@nkjzm)のフォローや「LGTM」もよろしくお願いします！

# その他Jenkins関係の記事

- [【Jenkins】ビルド失敗時のログをSlackに自動投稿する - Qiita](https://qiita.com/nkjzm/items/0de43b0f8e75579c30fb)
- [Unity2019.2以降のTest RunnerをJenkinsと連携させる時の備忘録 - Qiita](https://qiita.com/nkjzm/items/66d3e2ed0035e41a42b6)
- [【Jenkins】特定のジョブを優先実行する【Priority Sorter Plugin】 - Qiita](https://qiita.com/nkjzm/items/d47b2e858e98540be02e)
- [Jenkinsの「成果物を保存」で.appの保存に失敗した時の備忘録 - Qiita](https://qiita.com/nkjzm/items/b66a231926c76d28369e)
- [シンボリックリンクでJenkinsのworkspaceパスを変更する - Qiita](https://qiita.com/nkjzm/items/5fd4fb3dfcba1176937e)
