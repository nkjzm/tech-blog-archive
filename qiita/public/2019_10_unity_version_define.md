---
title: 【Unity2017.x~】新しいバージョンナンバリングシステムにおける#defineディレクティブ
published_at: '2019-10-29 13:19'
private: false
tags:
  - Untiy
updated_at: '2019-10-29T13:19:14+09:00'
id: 42a29285e2dd8db6bb91
organization_url_name: null
slide: false
---
# TL;DR

Unity2017.x~以降も[ドキュメント](https://docs.unity3d.com/ja/current/Manual/PlatformDependentCompilation.html)に書かれているUnity5.3.4以降と同様の命名則。

# はじめに

Unityの[プラットフォーム依存コンパイル機能](https://docs.unity3d.com/ja/current/Manual/PlatformDependentCompilation.html)はエディタバージョンによって切り分けることも出来るのですが、(2019.10.29時点で)最新版のドキュメントにはUnity2017.x以降について明示的な記述がありません。

日本語: [プラットフォーム依存コンパイル - Unity マニュアル](https://docs.unity3d.com/ja/current/Manual/PlatformDependentCompilation.html)
English: [Unity - Manual : Platform dependent compilation](https://docs.unity3d.com/Manual/PlatformDependentCompilation.html)

そこでどのような命名規則になっているか調べてまとめました。

# Unity2017.x~のディレクティブを調べる

## 環境

- Mac OSX 10.15
- Unity 2019.2.9f1

## 方法

[EditorUserBuildSettings.activeScriptCompilationDefines](https://docs.unity3d.com/jp/460/ScriptReference/EditorUserBuildSettings-activeScriptCompilationDefines.html)を使います。

```cs
// 現在のプラットフォームで定義されているディレクティブを取得
var defines = EditorUserBuildSettings.activeScriptCompilationDefines;
// 結合して出力
Debug.Log(string.Join("\n- ", defines.Select(d => d.ToString())));
```

## 結果

関連しそうなものだけ

- UNITY_2019_2_9
- UNITY_2019_2
- UNITY_2019
- UNITY_5_3_OR_NEWER
- UNITY_5_4_OR_NEWER
- UNITY_5_5_OR_NEWER
- UNITY_5_6_OR_NEWER
- UNITY_2017_1_OR_NEWER
- UNITY_2017_2_OR_NEWER
- UNITY_2017_3_OR_NEWER
- UNITY_2017_4_OR_NEWER
- UNITY_2018_1_OR_NEWER
- UNITY_2018_2_OR_NEWER
- UNITY_2018_3_OR_NEWER
- UNITY_2018_4_OR_NEWER
- UNITY_2019_1_OR_NEWER
- UNITY_2019_2_OR_NEWER

### `UNITY_X_Y_OR_NEWER`の命名

Unity5.3以降の各マイナーバージョン毎に `UNITY_X_Y_OR_NEWER` が定義されていることが確認できます。

> Unity 5.3.4 以降、指定した部分のコードのコンパイル、または実行に必要な最も古い Unity のバージョンに基づいて、選択的にコードをコンパイルできます。前述の (X.Y.Z) と同じバージョン形式を使用して、Unity は、UNITY_X_Y_OR_NEWER の形式でグローバルな #define を示します。

Unity2017.x以降もドキュメントに書かれている内容と合致していることが分かりました。

### スコープが異なるエディターバージョンの指定

上記は**Unity 2019.2.9f1**で実行した結果なので、細かいバージョン単位の指定が有効になっていました。

- UNITY_2019_2_9
- UNITY_2019_2
- UNITY_2019

> Unity 2.6.0 以降、選択的にコンパイルできるようになりました。使用できるオプションは使用しているエディターバージョンによります。 バージョン番号 X.Y.Z (例えば 2.6.0) の場合、Unity は 3つのグローバルな #define ディレクティブを以下の形式で示します。UNITY_X, UNITY_X_Y, UNITY_X_Y_Z

こちらもドキュメントに書かれている内容と合致しています。

# まとめ

Unity2017.x~以降も[ドキュメント](https://docs.unity3d.com/ja/current/Manual/PlatformDependentCompilation.html)に書かれているUnity5.3.4以降と同様の命名則でした。ドキュメントには明記されていないだけですね。

# おまけ: 出力されたアクティブなディレクティブ一覧

PlatformはWebGL向けの設定です。

- UNITY_2019_2_9
- UNITY_2019_2
- UNITY_2019
- UNITY_5_3_OR_NEWER
- UNITY_5_4_OR_NEWER
- UNITY_5_5_OR_NEWER
- UNITY_5_6_OR_NEWER
- UNITY_2017_1_OR_NEWER
- UNITY_2017_2_OR_NEWER
- UNITY_2017_3_OR_NEWER
- UNITY_2017_4_OR_NEWER
- UNITY_2018_1_OR_NEWER
- UNITY_2018_2_OR_NEWER
- UNITY_2018_3_OR_NEWER
- UNITY_2018_4_OR_NEWER
- UNITY_2019_1_OR_NEWER
- UNITY_2019_2_OR_NEWER
- UNITY_INCLUDE_TESTS
- ENABLE_AUDIO
- ENABLE_CACHING
- ENABLE_CLOTH
- ENABLE_MULTIPLE_DISPLAYS
- ENABLE_PHYSICS
- ENABLE_TEXTURE_STREAMING
- ENABLE_UNET
- ENABLE_UNITYEVENTS
- ENABLE_WEBCAM
- ENABLE_WWW
- ENABLE_CLOUD_SERVICES_COLLAB
- ENABLE_CLOUD_SERVICES_COLLAB_SOFTLOCKS
- ENABLE_CLOUD_SERVICES_USE_WEBREQUEST
- ENABLE_CLOUD_SERVICES_UNET
- ENABLE_CLOUD_SERVICES_BUILD
- ENABLE_CLOUD_LICENSE
- ENABLE_EDITOR_HUB_LICENSE
- ENABLE_WEBSOCKET_CLIENT
- ENABLE_DIRECTOR_AUDIO
- ENABLE_DIRECTOR_TEXTURE
- ENABLE_MANAGED_JOBS
- ENABLE_MANAGED_TRANSFORM_JOBS
- ENABLE_MANAGED_ANIMATION_JOBS
- ENABLE_MANAGED_AUDIO_JOBS
- ENABLE_MONO_BDWGC
- RENDER_SOFTWARE_CURSOR
- ENABLE_VIDEO
- PLATFORM_WEBGL
- UNITY_WEBGL
- UNITY_WEBGL_API
- UNITY_DISABLE_WEB_VERIFICATION
- UNITY_GFX_USE_PLATFORM_VSYNC
- ENABLE_CRUNCH_TEXTURE_COMPRESSION
- ENABLE_UNITYWEBREQUEST
- ENABLE_CLOUD_SERVICES
- ENABLE_CLOUD_SERVICES_ADS
- ENABLE_CLOUD_SERVICES_ANALYTICS
- ENABLE_CLOUD_SERVICES_PURCHASING
- ENABLE_CLOUD_SERVICES_CRASH_REPORTING
- ENABLE_ENGINE_CODE_STRIPPING
- ENABLE_VR
- ENABLE_SPATIALTRACKING
- ENABLE_MONO
- NET_STANDARD_2_0
- ENABLE_PROFILER
- DEBUG
- TRACE
- UNITY_ASSERTIONS
- UNITY_EDITOR
- UNITY_EDITOR_64
- UNITY_EDITOR_OSX
- ENABLE_UNITY_COLLECTIONS_CHECKS
- ENABLE_BURST_AOT
- UNITY_TEAM_LICENSE
- ENABLE_CUSTOM_RENDER_TEXTURE
- ENABLE_DIRECTOR
- ENABLE_LOCALIZATION
- ENABLE_SPRITES
- ENABLE_TERRAIN
- ENABLE_TILEMAP
- ENABLE_TIMELINE
- ENABLE_LEGACY_INPUT_MANAGER
- UNITY_POST_PROCESSING_STACK_V2

# 参考

- [プラットフォーム依存コンパイル - Unity マニュアル](https://docs.unity3d.com/ja/current/Manual/PlatformDependentCompilation.html)
- [【Unity】#defineで定義されているシンボルを一覧で表示するウィンドウをエディタ拡張で実装する - コガネブログ](http://baba-s.hatenablog.com/entry/2014/07/25/105332)
- [Unity 2017 世代の #define ディレクティブ - 強火で進め](http://nakamura001.hatenablog.com/entry/20170831/1504168917)

