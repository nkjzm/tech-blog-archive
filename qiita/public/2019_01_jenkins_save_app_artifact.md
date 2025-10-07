---
title: Jenkinsの「成果物を保存」で.appの保存に失敗した時の備忘録
published_at: '2019-01-27 11:16'
private: false
tags:
  - Jenkins
  - Unity
updated_at: '2019-01-27T11:16:54+09:00'
id: b66a231926c76d28369e
organization_url_name: null
slide: false
---
# 状況

UnityでMac用アプリを書き出す時の話。

「保存するファイル」に以下を指定

```
target/*.app
```

コンソール出力

```
成果物を保存中
ERROR: Step ‘成果物を保存’ failed: 指定されたファイルパターン「target/YourProject.app」に合致するファイルがありません。設定ミス？
Finished: FAILURE
```

# 原因

`.app`の実態はディレクトリなので、ディレクトリとしてパスを指定する必要があった。

# 解決策

「保存するファイル」に以下を指定

```
target/*.app/
```

コンソール出力

```
成果物を保存中
Finished: SUCCESS
```


