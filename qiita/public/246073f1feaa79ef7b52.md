---
title: uGUIのInputFieldで編集できない入力フォームを作る
tags:
  - Unity
private: false
updated_at: '2018-09-29T00:39:46+09:00'
id: 246073f1feaa79ef7b52
organization_url_name: null
slide: false
ignorePublish: false
---
# 検証環境

Unity2018.2.1f1

# 解説

<img width="358" alt="sふぁsfさdふぁs.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/d88b6cf0-3ad4-7905-9d58-f0557b01dc92.png">

InputFieldコンポーネントの設定を変更することで実現可能です。

| プロパティ | 説明 |
|---|---|
|Interactable | UI要素を選択する機能の有効/無効を切り替える。デフォルトで有効。 |
|ReadOnly | 読み取り専用の有効/無効を切り替える。デフォルトで無効。 |


https://docs.unity3d.com/ja/current/ScriptReference/UI.InputField-readOnly.html


## 挙動

上から、

- Interactable = true && ReadOnly = false
- Interactable = false&& ReadOnly = false
- Interactable = true && ReadOnly = true


![fasdfas.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/02c32190-a8c4-c44c-dbeb-450d4bd70fed.gif)


Interactableがfalseだと選択自体が出来なくて、ReadOnlyがtrueだと選択は出来るけど変更が加えられない挙動をします。

用途に応じて使い分けるとよいかと思います。参考にしてみてください。
