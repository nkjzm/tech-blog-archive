---
title: "Unity 2019.1xのPackage ManagerにおけるGitHubリポジトリとの関係"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
published_at: 2019-07-17 02:25
---
## はじめに

Package Managerのことをわかったつもりで分かってなかったので、自分用のふわっとしたまとめです。バージョンによってガンガン状況が変わると思うのでご注意ください。

## 前提

- Unity2018.3あたりからGitHubのURL指定でPackageを導入できるようになった
    - ref: [PackageManagerで自作ライブラリを作成する方法 - Qiita](https://qiita.com/frost224/items/9832625f9f1671dd033b)
- PackageManagerを使って利用するライブラリが登場しはじめている
    - ref: https://github.com/5argon/NotchSolution

### 動作確認環境

- macOS 10.14.4（18E226）
- Unity 2019.1.9f1


## Packageの導入方法

インポートしたいUnityプロジェクトのルートから`/Packages/manifest.json`を開く

`dependencies`に`[package名]: [GitHubのURL]`を追加する。

```json:manifest.json
{
  "dependencies": {
    "com.e7.notch-solution": "git://github.com/5argon/NotchSolution.git",
    ...
  }
}
```

この状態でUnityエディタを開くとPackageの再読込が走り、Packagesに該当アセットが追加される。

<img width="942" alt="スクリーンショット 2019-07-17 1.07.21.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/8c443c03-c39a-0853-01f1-848f79898d26.png">


PackageManagerのウィンドウに表示されている情報は、配布Packageのルートにある`package.json`に記述されている内容。(ref: https://github.com/5argon/NotchSolution/blob/master/package.json)

## Packageのバージョン指定

GitHub経由でインストールしたPackageのバージョン指定はGUI上から行うことが出来ない。

`manifest.json`を開き直すとバージョンに関する記述が追加されている。

```json:manifest.json
{
  "dependencies": {
    "com.e7.notch-solution": "git://github.com/5argon/NotchSolution.git",
    ...
  },
  "lock": {
    "com.e7.notch-solution": {
      "hash": "357f59ce20808dcd161dbb2c493e87fa74d193c7",
      "revision": "HEAD"
    }
  }
}
```

`hash`にかかれている`357f59ce20808dcd161dbb2c493e87fa74d193c7`はコミットのハッシュ値となっている。(ref: https://github.com/5argon/NotchSolution/commit/dd22b4bc702e2bd48851186df7417861ba2c71e2)

以前のバージョンを使用したい場合は、該当するコミットを見つけてきて`hash`の値を書き換えることで再度読み込みが走り、バージョンが切り替わる。(ref: https://github.com/5argon/NotchSolution/commit/357f59ce20808dcd161dbb2c493e87fa74d193c7)

<img width="816" alt="スクリーンショット 2019-07-17 1.27.39.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/a53ec087-3981-c0ed-f201-f39607ad71c5.png">

## 最後に

微妙に物足りない感じですが、`.unitypackage`との比べてライブラリのバージョン依存が明確になるところは結構大きな利点かなと感じました。現状だとPackage間の依存等を定義出来ない等のデメリットも多く残っていますが、なんとか使える段階ではあると思いました。

他の手段として、少し煩雑ではありますがnpmjsクローンを自前で立てることで大体のことは解決できるみたいです(ref: [Unity 2019.1 で Unity Package Manager が 90% くらい民主化された件について - もんりぃ is undefined.](https://monry.hatenablog.com/entry/2019/04/17/024205))。併せてご検討ください。

