---
title: UnityでAssembly Definition Fileを追加したらエディタでのコンパイルは通るがビルドできなくなった人が見るページ
published_at: '2019-08-01 16:56'
private: false
tags:
  - Unity
updated_at: '2019-08-01T16:56:34+09:00'
id: 5994a31bcabfd06e9593
organization_url_name: null
slide: false
---
# はじめに

Assembly Definition Fileの概要は分かっている前提での説明です。

参考: [Unity2017.3のAssembly Definition Filesを適切に設定してコンパイルにかかる時間を削減する - Qiita](https://qiita.com/nkjzm/items/aaad87dc7f7bc9703449)

# 原因

恐らく`Editor`ディレクトリ以下をビルドしようとしていることが原因。

通常Unityでは`Editor`ディレクトリ以下はUnityエディタ上でのみ動作し、ビルドには含まれない扱いになる。実は内部的にEditorディレクト内にAssembly Definition Fileが定義されている状態である。

手動でAssembly Definition Fileを追加した場合、それ以下に含まれる`Editor`ディレクトリではAssembly Definition Fileが作成されなくなることからビルド時にエラーが発生する。

# 解決方法

該当の`Editor`ディレクトリに対し、手動でAssembly Definition Fileを定義してやればいい。

<img width="537" alt="スクリーンショット 2019-08-01 16.33.14.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/01b72d6e-f2a9-0926-b44d-23331eee72ea.png">

気をつけるポイントとしては以下の通りです。

- `Platform`を`Editor`のみにする
    - `Any Platform`のチェックを外した状態で、`Include Platforms`の`Editor`のみにチェックに入れている状態
    - `Any Platform`のチェックが入った状態だと`Exclude Platforms`(対象外のプラットフォーム)の表示になり、全く逆の状態であることに注意
- Assembly Definition Referencesに親のAssembly Definition Fileを追加する
    - これをしないと恐らくエディタ上でもコンパイルエラーが発生する

# 最後に

いちいちコンパイルが走るので、作業量の割に時間がかかって面倒くさいけど、がんばってください


