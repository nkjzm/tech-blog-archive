---
title: "シンボリックリンクでJenkinsのworkspaceパスを変更する"
emoji: "🔧"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Jenkins"]
published: true
---
## はじめに

以前のJenkinsでは`[Jenkinsの管理]->[システムの設定]->[高度な設定]->[ワークスペース・ルートディレクトリ]`という設定があったみたいなのですが、ver. 2.204.1では確認できなかったためシンボリックリンクで対応をしました。簡単に書き残したいと思います。

参考: [Jenkinsで容量が圧迫されるときの対処法 - Qiita](https://qiita.com/kuro123/items/bfb1bc699ecba0aa2406)

## 環境

- Windows 10 Home
- Jenkins: ver. 2.204.1

## 手順


作業中は念のためJenkinsを停止しておいた方が良いと思います。Jenkinsをmsi経由でインストールした場合はウィンドウズメニューから「サービス」を検索し、Jenkinsを停止してください。

![aaaaaaキャプチャ.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/201bac95-5c79-345b-76ee-193e0b39e0e7.png)

次に、既存のワークスペースを置き換えるため、フォルダの削除もしくはファイル名の変更を行っておいてください。

ではシンボリックリンクを作成していきます。Jenkinsのデフォルトでシステムディレクトリ上に作成されていると思うので、管理者権限でコマンドプロンプトを起動してください。`mklink`というコマンドを使います。

```bat
> C:\WINDOWS\system32>mklink
シンボリック リンクを作成します。

MKLINK [[/D] | [/H] | [/J]] リンク ターゲット

        /D          ディレクトリのシンボリック リンクを作成します。既定では、
                    ファイルのシンボリック リンクが作成されます。
        /H          シンボリック リンクではなく、ハード リンクを作成します。
        /J          ディレクトリ ジャンクションを作成します。
        リンク      新しいシンボリック リンク名を指定します。
        ターゲット  新しいリンクが参照するパス (相対または絶対)
                    を指定します。

C:\WINDOWS\system32>mklink /D "C:\Program Files (x86)\Jenkins\workspace" E:\Jenkins\workspace
```

構文に従って新しいworkspaceのパスを指定してください。無事作成されるとショートカットと同じアイコンが表示されます。（ショートカットとは異なります）

![fasdfasdfasdfasd.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/ed6c023b-2416-8e96-abf4-9b7307098a87.png)

参考: [Windowsでシンボリックリンクを作る ｜ Developers.IO](https://dev.classmethod.jp/etc/make_windows_symbolic_link/)

あとは先ほどのサービスからJenkinsを起動してあげると今までと同じように実行できることが確認できると思います。

## 最後に

環境変数で変更する方法などもありますが、この方法だと動かなくなるリスクが少なくて良いと思いました（感想）

