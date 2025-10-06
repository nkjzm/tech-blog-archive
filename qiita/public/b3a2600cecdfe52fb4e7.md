---
title: WindowsのServiceでパスワードを持たないユーザーのログオンを許可する
tags:
  - Windows
private: false
updated_at: '2020-11-01T06:28:17+09:00'
id: b3a2600cecdfe52fb4e7
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

備忘録です。運用の都合上パスワードをかけていないWindowsマシンがあり、権限の関係で特定ユーザーでサービスのログオン設定をしたい場合がありました。しかしデフォルト状態では以下の事情からそのままでは実行できなかったため、その設定を変更する手順をまとめました。

> 現代のWindowsではすべて、空のパスワードを持つユーザーがローカルコンソールのみにログオンするように制限するローカルセキュリティポリシーがあります。
http://ja.voidcc.com/question/p-hjwahxks-g.html

# 手順

下記手順に従ってローカルグループポリシーエディタを開く

[グループポリシーgpedit.mscが見つからない時の対処 – Windows10 Home](https://itojisan.xyz/trouble/17155/)


`[ローカルコンピューターポリシー] -> [コンピューターの構成] -> [Windowsの設定] -> [セキュリティの設定] -> [ローカルポリシー] -> [セキュリティオプション] -> [アカウント: ローカルアカウントの空のパスワードの仕様をコンソールログオンのみに制限する]`を無効にすれば完了

# 最後に

よかったらTwitterフォローしてください～
https://twitter.com/nkjzm
