---
title: "TextMeshProのフォントアセットが壊れた時の対処メモ"
emoji: "📝"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
published_at: 2019-03-04 17:50
---
## はじめに

`(略) because it was serialized with a newer version of Unity. (Has a higher Serialized File version)` などと言われ、フォントアセットが壊れることがある。

## 試してダメだったこと

- Unityのバージョンを最新に変える
- Library, Objフォルダを削除

## 対応

一度Editor上から該当アセットを削除し、Gitで復元すると治ることがある。何も分からん…。

