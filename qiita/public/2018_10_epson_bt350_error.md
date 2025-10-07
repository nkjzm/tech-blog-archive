---
title: Epson BT-350 Update Toolの起動後に「このアプリケーションのサイドバイサイド構成が正しくないため～」と言われた時の対処
published_at: '2018-10-16 10:11'
private: false
tags:
  - AR
updated_at: '2018-10-16T10:11:31+09:00'
id: 521f6147dd424c357141
organization_url_name: null
slide: false
---

## 状況

Epson BT-350 Update Tool の BT-350UpdateTool.exe を起動したところ以下のエラーが発生しました。

> このアプリケーションのサイド バイ サイド構成が正しくないため、アプリケーションを開始できませんでした。詳細については、アプリケーションのイベント ログを参照するか、コマンド ライン ツール sxstrace.exe を使用してください。

## 対処

「Visual C++ 2008 Express Edition」のインストールで解決しました。

下記のページより「vcsetup.exe」をダウンロードし、インストール
http://go.microsoft.com/?LinkId=9348304

## 参考

【雑記】.exe を起動したら「このアプリケーションのサイド バイ サイド構成が正しくないため～」と表示された時の対応方法 - コガネブログ
http://baba-s.hatenablog.com/entry/2018/04/11/120000
