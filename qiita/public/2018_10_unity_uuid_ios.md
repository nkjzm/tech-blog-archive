---
title: UnityでUUIDを生成する方法と、iOSからみる端末固有IDの考察
published_at: '2018-10-12 17:04'
private: false
tags:
  - iOS
  - Unity
updated_at: '2018-10-12T17:04:33+09:00'
id: 06dd56736a37ef915936
organization_url_name: null
slide: false
---
## UnityでUUIDを生成する方法

```cs
string GetUUID()
{
    var guid = System.Guid.NewGuid();
    return guid.ToString();
}
```

## 端末固有IDの考察

### そもそもなぜ必要か

1. 複数のアプリ間で特定のユーザーを追跡したい場合 (広告などの用途)
2. アプリの再インストール時にユーザー情報を復元したい場合

### 端末固有IDに関するiOSの動向

端末固有IDはユーザーが自由に変更できるものでないため、現在は非推奨という形になっています。(バージョンによりますが、該当メソッドを呼び出しているとリジェクトされるか、後述する代替メソッドの結果が帰ってきます)

iOS6.0以降で代替メソッドとして以下の2つが実装されているようです。

- `identifierForVendor`
    - 開発者が同一であれば、同一の端末固有IDが返ってきます
- `AdvertisingIdentifier`
    - 開発者に関わらず、同一の端末固有IDが返ってきます
    - ユーザーが取得の可否を設定可能(恐らくデフォルトで不可)
    - ユーザーが任意のタイミングでリセット可能

![fasdfasdfasdf.png](https://qiita-image-store.s3.amazonaws.com/0/55365/fb3a481f-2df6-de03-48ed-1ee23c64bddc.png)

iOS 12では、設定アプリから[プライバシー]>[広告]と進んでいくと上記の画面になりました。

### Unityの`SystemInfo.deviceUniqueIdentifier`について

- ドキュメントにはデバイス固有のIDが返ってくると書いてある
    - iOSの場合、内部的には`identifierForVendor`を呼んでいる
- UnityのバージョンやiOSのバージョンによって結果が異なる場合がある
    - 詳しくはドキュメントを参照

### 考察

> 1.複数のアプリ間で特定のユーザーを追跡したい場合 (広告などの用途)

基本的に推奨されていない流れだが、`AdvertisingIdentifier`で追跡可能なユーザーのみ追跡するという選択肢はありそう。

>  2.アプリの再インストール時にユーザー情報を復元したい場合

`identifierForVendor`を使えば実現可能だが、Androidではそういった仕組みが恐らくないことに注意が必要。アカウントを用いたユーザーデータの復元が現実的かと思います。

## 参考

【Unity】Unity上でUUIDを作る - Matt02's Note
http://matt02.hatenablog.com/entry/2014/07/26/023635

Unity - Scripting API: SystemInfo.deviceUniqueIdentifier
https://docs.unity3d.com/ScriptReference/SystemInfo-deviceUniqueIdentifier.html

《必見》Unity任せの機種固有ID取得は危険！-Unityアプリの効果計測 | マーケティングを支援するDigital Cloud Platform
https://admage.jp/blog_008_unity-apprication.html

iOS/Androidで端末を識別するIDまとめ | 株式会社アイリッジ
https://iridge.jp/blog/201404/4836/


