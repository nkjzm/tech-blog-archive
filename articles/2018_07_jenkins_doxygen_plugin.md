---
title: "Jenkins + Doxygen Pluginでドキュメントの自動生成"
emoji: "🔧"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Jenkins"]
published: true
published_at: 2018-07-07 15:37
---
# できたもの

Jenkins上から常に最新のソースコードドキュメントを見ることができる状態になった。

![safadsfa_.png](https://qiita-image-store.s3.amazonaws.com/0/55365/b94806c9-8ea9-46ac-d314-08d49e58c142.png)


# 導入について

## DoxyFileの用意

ローカルで設定の確認をしてからリモートにアップすると良い

生成
```$ doxygent -g [任意の名前]```

実行
```$ doxygent [任意の名前]```

以下のページが参考になった。
http://algo13.net/doxygen/doxyfile.html

## Jenkinsの設定

- JenkinsにDoxygenのインストール
- Jenkinsの管理 > プラグインの管理 > 利用可能 > Doxygen Plug-in をインストール
    - 再起動せずインストールで大丈夫だった
- Jenkinsの管理 > Global Tool Configuration > インストール済みDoxygenにパスを通す

<img width="1326" alt="76f75a21-8303-a89a-7cc2-25a34b99eac8.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/b9404b29-16e4-74a7-e54f-0ddf4cfb894b.png">

directoryを指定しろって警告が出るが、実行ファイルのパス指定で問題ない

## ジョブに対してDoxygenの設定

- ビルド手順の追加から「Doxygenでドキュメントを生成する」、を追加し、パスを指定
- ビルド後処理に「Publish Doxygen」を追加し、パスを通す


# 雑感

パス指定周りがローカルとjenkins環境で異なり、何度も試行錯誤をした。
相対パスを意識することと、エラーログをみて修正していったらうまくいった。
