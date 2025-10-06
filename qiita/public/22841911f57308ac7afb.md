---
title: LookingGlassのHoloPlay SDKのマイグレーションメモ(0.1.4->1.0.0)
tags:
  - Unity
private: false
updated_at: '2019-03-31T15:32:03+09:00'
id: 22841911f57308ac7afb
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

LookingGlassの開発に必要なHoloPlay SDKですが、2019.03.30にメジャーバージョンとなる`1.0.0`がリリースされました。

Release & Update Note
https://blog.lookingglassfactory.com/https-blog-lookingglassfactory-com-holoplay-sdk-1-0-0-release-a54abdfc526e

`1.0.0'ではそれまでの最新版`0.1.4`のコードを全て書き直したらしく、互換性がありません。
そこでマイグレーション(移行)の手順のメモを残したいと思います。

# SKDのアップデート

`0.1.4`と`1.0.0`はディレクトリ構成が異なるため、`.unitypackage`で上書きしても古いスクリプトが残ってしまいます。そのため以前の`HoloPlay`ディレクトリ毎削除して後に、新しい`.unitypackage`をインポートしましょう。

# スクリプトの移行

気がついた変更点を列挙します。参考になれば幸いです。

- 名前空間の変更: HoloPlay->LookingGlass
- Quiltクラスがstaticな非MonoBehabiorに変更
- Quiltクラスのいくつかの機能がHoloPlayに移行
    - quilt.tiling->holoplay.quiltSettings
    - quilt.tiling->holoPlay.customQuiltSettings
    - quilt.overrideQuilt->holoplay.overrideQuilt
    - quilt.SetupQuilt()->holoplay.SetupQuilt()
- SetupQuilt()適用前にholoplay.quiltPreset = Quilt.Preset.Customの変更が必要に
- Quilt設定に関する構造体の命名が変更: Quilt.Tiling->Quilt.Settings
    - メンバ変数の命名が変更
        - tileSizeX->viewWidth, tileSizeY->viewHeight
        - tilesX->viewColumns, tilesX->viewRows
- overrideQuiltがTexture型->Texture2D型
- Buttons->ButtonManager

# まとめ

まだしっかり使っていませんが、プレビュー周りなどかなり使いやすくなっているように思いました。Looking Glassはいいぞ

