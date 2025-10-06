---
title: 'JsonUtilityでVector2, Vector3をシリアライズする'
private: false
tags:
  - Unity
updated_at: '2018-12-28T15:36:04+09:00'
id: 770dae999f2978de94ff
organization_url_name: null
slide: false
---
# はじめに

Unity標準のJsonパーサー `JsonUtility`は`Vector2`,`Vector3`に対応しています。素晴らしいですね！

どんな感じか見てみましょう。

# コード

```cs
// シリアライズ
var vec2 = new Vector2(33, 4);
var vec3 = new Vector3(11, 45, 14);
Debug.Log(JsonUtility.ToJson(vec2)); // 出力: {"x":33.0,"y":4.0}
Debug.Log(JsonUtility.ToJson(vec3)); // 出力: {"x":11.0,"y":45.0,"z":14.0}
// デシリアライズ
var vec2json = "{\"x\":33.0,\"y\":4.0}";
var vec3json = "{\"x\":11.0,\"y\":45.0,\"z\":14.0}";
Debug.Log(JsonUtility.FromJson<Vector2>(vec2json)); // 出力: (33.0, 4.0)
Debug.Log(JsonUtility.FromJson<Vector3>(vec3json)); // 出力: (11.0, 45.0, 14.0)
```
