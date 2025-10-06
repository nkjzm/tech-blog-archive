---
title: 1分で理解するScriptable Render Pipeline(SRP)の概略と使い方
tags:
  - Unity
  - VR
private: false
updated_at: '2019-07-05T18:33:17+09:00'
id: 60aeabd42a83c1d8c098
organization_url_name: null
slide: false
ignorePublish: false
---
# TL;DR

- 今までProjectSettingsで設定していた項目を、いい感じにしてくれる機能
- HDRP(高画質)とLWRP(軽量)という2つの構築済みSRPで気軽に使える
- Standard Sharderが使えないなど、一部制約もあったりするので注意

# はじめに

Scriptable Render Pipeline(SRP)のなんとなくの雰囲気を知るためのメモです。
参考リンクも付けているので、正確な情報は各自調べてください。

# 用語

- ビルドインレンダーパイプライン
    - 従来の描画システム
- SRP: Scriptable Render Pipeline
    - いい感じにカスタマイズが出来る機能
    - 基本的に構築済みSRPを調整する形で使うことが推奨されている
- HDRP: High Definition Render Pipeline
    - SRPの高画質な構築済みSRP
    - Shader GraphとPost-Processingが含まれている
- LWRP: Lightweight Definition Render Pipeline
    - SRPの軽量な構築済みSRP
    - Shader GraphとPost-Processingが含まれている
    - 全てのVRプラットフォームに対応

# どこから導入できるの？

Unity2019.xだとプロジェクトの新規作成時に選べる。

<img width="600" alt="スクリーンショット 2019-07-05 18.16.52.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/b6d81fc0-0c23-f4c5-ca7b-d53d13379651.png">

- HDRPはビルドイン/LWRPと互換性がないため、この時点で決定する必要がある(多分)
- サンプルシーンに設定済みのSRPが含まれる

既存のプロジェクトに導入する場合は、PackageManagerから。

<img width="600" alt="スクリーンショット 2019-07-05 18.21.54.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/287ad1bd-7634-bc5d-18ef-ee66c23c5374.png">

- Core RP Library
    - SPRを熟知している人が構築済みSRPを使わずにカスタマイズする時に使うライブラリ。
    - 構築済みSRPを使う場合は不要
- High Definition RP
    - HDRP
- Lightweight RP
    - LWRP

LWRPの場合使えないシェーダーがあるが、以下のメニューより良い感じに置き換えてくれる

<img width="600" alt="スクリーンショット 2019-07-05 18.31.12.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/06476c6d-cb0e-df00-7338-13c54f3774d2.png">


# どこで紐付いてるの？

Graphic Settingsで設定できる

<img width="600" alt="スクリーンショット 2019-07-05 18.13.51.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/d84d792a-ea39-abec-20b1-638d742bb640.png">

Quality Settingsで設定していたような項目が、SRP用のScriptableObjectで設定できるようになった感じ。

<img width="917" alt="スクリーンショット 2019-07-05 16.55.38.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/7618a94d-482f-4aa3-5082-e59e5b0907a1.png">
_左: SRP未設定状態のQuality Settings, 右: LWRP-HightQuality_

<img width="482" alt="スクリーンショット 2019-07-05 17.36.28.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/035ba735-eb3c-9081-475f-2cfe9ff0ea3a.png">
_SPRを適用すると設定項目が減る_



# 参考

- [Scriptable Render Pipeline# - Unity マニュアル](https://docs.unity3d.com/ja/2018.1/Manual/ScriptableRenderPipeline.html)
- [【Unity】既存のプロジェクトにLightweight RenderPipelineを導入する - テラシュールブログ](http://tsubakit1.hateblo.jp/entry/2018/09/07/221355)
- [軽量レンダーパイプライン ― リアルタイムパフォーマンスの最適化 – Unity Blog](https://blogs.unity3d.com/jp/2018/02/21/the-lightweight-render-pipeline-optimizing-real-time-performance/)

