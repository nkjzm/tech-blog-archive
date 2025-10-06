---
title: "Photon PUN2のOnPhotonSerializeView()で送受信できる型一覧"
emoji: "🌐"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
---
# はじめに

リファレンスに書いてある内容です。
[Serialization in Photon | Photon Engine](https://doc.photonengine.com/en-us/pun/v2/reference/serialization-in-photon)

# Photonがサポートしている型

- byte
- bool
- short
- int
- long
- float
- double
- String
- Object[]
- byte[]
- array
- Hashtable
- Dictionary

# PUNがサポートしている追加の型

- Vector2
- Vector3
- Quaternion
- PhotonPlayer

# それ以外の型を使いたい場合

`SerializeMethod`と`DeserializeMethod`を定義して`RegisterType`をすれば、どの型でも扱えるようになる。

参考: [【Unity】僕もPhotonを使いたい #09 RPC() シリアライズ編 - うら干物書き](https://www.urablog.xyz/entry/2016/09/21/223002)
