---
title: "Unity用のパッケージ(アセット)を配布する時のお作法"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["GitHub", "Unity"]
published: true
published_at: 2018-08-05 21:55
---

# はじめに

この記事は[Unityゆるふわサマーアドベントカレンダー 2018](https://qiita.com/splas_boomerang/items/e6619fb1e6dd92fd231f)の5日目です！
(まだ枠余っているので、興味があったらぜひご参加ください)

今回は自分で作ったパッケージを配布する時の話です。主にコード系アセットについてです。

Unityは他の開発環境と違いパッケージを配布の仕組みが整っていない印象があります。というのも、現状だと外から持ってきたコードはプロジェクトのコードと区別されず、利用する側がそれぞれ管理することになると思います。

そのため、Unityで自前のパッケージを配布する際にはこうなっていて欲しいという話をします。有益なアセットを提供してくれていることを理解した上で、こうするともっと良いと思うという話です。参考にしていただけると幸いです。

## 参考にしたアセット

- UniRx
    - https://assetstore.unity.com/packages/tools/integration/unirx-reactive-extensions-for-unity-17276
    - https://github.com/neuecc/UniRx
- Google VR SDK for Unity
    - https://github.com/googlevr/gvr-unity-sdk
- Zenject
    - https://assetstore.unity.com/packages/tools/integration/zenject-dependency-injection-ioc-17758
    - https://github.com/svermeulen/Zenject
- Oculus Lipsync Unity
    - https://developer.oculus.com/downloads/package/oculus-lipsync-unity/
- Cubism SDK For Unity Components
    - https://github.com/Live2D/CubismUnityComponents
- Final IK
    - https://assetstore.unity.com/packages/tools/animation/final-ik-14290

(中身を知ってるアセット挙げただけですが参考までに)

# Unity用パッケージを配布する方法

1. GitHub
2. AssetStore
3. ウェブサイト

個人的にはGitHubでの配布が1番ありがたいです。理由としてはpull requestで開発の動向を追えることや、issueで問題についての把握することが出来るためです。

また、Asset Storeは唯一公式で用意されているパッケージ配布の仕組みです。
雑感ですが、GitHubでも配信されているアセットの場合、AssetStoreで配布されている方はバージョンが古いことがあるので気をつけてください。(反映が遅いのか開発者が更新しわすれているのか不明)

企業系のSDKなどはウェブサイトから直接`.unitypackage`を落とす形式もあったりします。

# アセットを配布する時のお作法

ポイントとしては以下かと思います。

- (重複しないパッケージ名を決めておく)
- ディレクトリを分ける
- namespaceをつける
- サンプルを含める
- ReadMe.txtを含める
- ライセンスを明記する
- Assembly Definition Filesを含める
- `.unitypackage`として配布する

## (重複しないパッケージ名を決めておく)

ディレクトリ名やnamespaceに使用します。

## ディレクトリを分ける

出来るだけ一つのディレクトリにまとめましょう。
(時々直下に色々置いてあるアセット見かけるので）

```
Assets/
　├　HogePackage/
　│　└　Scripts/
　│　　　└　Foo/
　│　└　Samples/
　│　└　Resources/
　│　└　Editor/
　└　Plugins/
```

上記のような構成が多いと思います。`Plugins`だけは`Assets`フォルダの直下でないと動作しないため、`HogePackage`ディレクトリに含めることができません。`Resources`や`Editor`は任意の場所に複数配置して問題ないので、`HogePackage`に含めるようにしてください。

参考：[特殊なフォルダー名 - Unity マニュアル](https://docs.unity3d.com/jp/current/Manual/SpecialFolders.html)

また、最近だと`Plugins`以下に全て配置する構成もよく見る気がします。(UniRxとかZenject)

```
Assets/
　└　Plugins/
　 　└　HogePackage/
  　 　└　Scripts/
　 　  　　└　Foo/
　　   └　Samples/
```

この方法だと`Plugins`と`HogePackage`を一つのディレクトリに入れられるので管理がしやすいです。`Plugins`は本来ネイティブプラグインを呼び出すためのディレクトリなので想定されている用途とは異なりそうですが、特に問題もないように思います。

### 余談：個人的なプロジェクトでのディレクトリ管理

```
Assets/
　├ Externals/
　│　└ Asset01/
　│　└ Asset02/
　├ MyProjectName/
　│　└ Scripts/
　│　└ Scenes/
　└　Plugins/
　 　└ Asset03/
```

直下に`Externals`というフォルダをおいて、この中に外部アセットは全ていれます。
インポートとアップデート以外直接変更をしないと決めることで、プロジェクトのコードを区別をしています。

## namespaceをつける

他のスクリプトのクラス名と衝突を起こさないよう、明示的に名前空間を分けると良いと思います。


`<Company>.(<Product>|<Technology>)[.<Feature>][.<Subnamespace>]`
参考：[名前空間の名前](https://msdn.microsoft.com/ja-jp/library/ms229026(v=vs.100).aspx)

.NETのデザインガイドラインに寄ると、上記の書き方が一般的なようです。(e.g.`using Live2D. Cubism `)


Unityのアセットだと`<Company>`は付いていないことも多いような気がします。(e.g.`using UniRx`,`using Zenjectなど)`


## サンプルを含める

> - アセットがどのように動くのかを体感できるようにサンプルシーンを同梱してください

[アセットストアへの出品 – Unity公式 Asset Portal](http://assetstore.info/guide/)

アセットストアで配布する時のガイドラインに記述があるため、含めた方が好ましいように思います。

```
Assets/
　└　HogePackage/
　 　└　Scripts/
　 　　　└　Foo/
　 　└　Samples/
```

サンプルをGit管理したくないという状況があると思うので、取り除きやすいディレクトリ構成になっていると良いかと思います。アセットルート直下のディレクトリにまとめると良いでしょう。(たまにサンプル消すとコンパイルエラーでるアセットがあってつらい)

個人的に、サンプルディレクトリ以下の構成は機能ごとのディレクトリにscriptとsceneが入っているものが好きです。

また命名はこの辺りが多いと思います。
- Samples
- Examples
- DEMO

## ReadMe.txtを含める

> - ドキュメントや ReadMe.txt をメインフォルダの直下に同梱してください
>   - 記載例：セットアップ方法、導入方法、利用方法、バージョン履歴など

[アセットストアへの出品 – Unity公式 Asset Portal](http://assetstore.info/guide/)

これもガイドラインで言及されている内容です。特にバージョンに関しては、現在プロジェクトに導入されているものが分からなくなることが多いので、明記されていると非常にありがたいと感じます。(Gitのコミットメッセージとか追えば分かるという話かもしれないですが、ベストプラクティスが分からない…)

僕が知っている中では、UniRxの`ReadMe.txt`が1番要件を満たしているように思います。
https://github.com/neuecc/UniRx/blob/master/Assets/Plugins/UniRx/ReadMe.txt

## ライセンスを明記する

配布するプラットフォームごとにデフォルトのライセンスがあるのですが、明記してあった方が利用者としてはありがたいです。
再配布を前提とする場合は、ディレクトリ内に`License.txt`も入れておくと良いかと思います。

### AssetStoreのライセンス

適切に入手したものであればかなり自由なライセンスになっています。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">「アセットは安心して自由に改変して、自分の作品に組み込んでビルドしたデータは配布OK」ですよ♪<br>■改変FAQ<br>「サービス類のSDKは改変NG」<br>「上記以外は自由に改変OK」<br><br>■配布FAQ<br>「アセットが簡単に取り出せる形態での配布はNG」<br>「ビルドしたアプリとかは配布OK」</p>&mdash; UnityAssetStoreJapan (@AssetStore_JP) <a href="https://twitter.com/AssetStore_JP/status/721912153200955397?ref_src=twsrc%5Etfw">2016年4月18日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

アセットによっては追加でライセンスが設定されていることがあるので、注意してください。
参考：[Unity開発で便利なAsset Store！アセットのライセンスについて – アイデアクラウド | 東京のWEB・アプリ・VR・IoTのクリエイティブスタジオ](https://ideacloud.tokyo/develop-days/development/assetstore_180126.html)

### GitHubのライセンス

明記されていない場合、**No License**という扱いになります。

No License | Choose a License
https://choosealicense.com/no-permission/

その場合かなり限定的な利用しかできなくなってしまうため、GitHubで配布する場合は出来るだけライセンスを設定するようにしましょう。

状況に適したライセンスを提案してくれるページが用意されているので、活用してください。
[Choose an open source license | Choose a License](https://choosealicense.com/)

## Assembly Definition Filesを含める

配布するパッケージは基本的にそのパッケージ単体で疎結合になっていると思います。
そのため、明示的にコンパイルの範囲を限定することができる**Assembly Definition Files**を含めておくと好ましいです。

拙筆ですが解説記事を書いているのでよろしければ参考にしてみてください。
[Unity2017.3のAssembly Definition Filesを適切に設定してコンパイルにかかる時間を削減する - Qiita](https://qiita.com/splas_boomerang/items/aaad87dc7f7bc9703449)

## `.unitypackage`として配布する

他の人が導入しやすいように`.unitypackage`として書き出して配布してください。

`.meta`ファイルの仕組みを上手く使うと、パッケージのアップデートもスムーズに行えます。
[Unityの.metaファイルとは何なのか？ - Qiita](https://qiita.com/4_mio_11/items/91ebcdd30398af607373)

GitHubの場合はリリース機能を活用すると良いでしょう。

これはGitのタグ毎に明示的に配布するバージョンを分けることができる機能で、バージョン毎にバイナリファイルを添付することができます。`.unitypackage`はバイナリファイルに該当するので、この方法が最も適切かと思います。
[GitHubのリリース機能を使う - Qiita](https://qiita.com/todogzm/items/db9f5f2cedf976379f84)

別の方法としては、リポジトリの直下に`.unitypackage`を置いているパターンも見かけます。この方法で配布する場合、`.gitignore`に`.unitypackage`が含まれている場合があるので、注意してください。

# 最後に

上記は僕が利用する際に望むことなので、誤った内容を含んでいる可能性があります。
ぜひ何か気になったら気軽にご指摘いただけると幸いです。

[Unityゆるふわサマーアドベントカレンダー 2018](https://qiita.com/splas_boomerang/items/e6619fb1e6dd92fd231f)もよろしくお願いします！

# 余談：PackageManagerについて

Unity2018くらいから公式でPackageManagerという仕組みが導入され、かなり便利そうです。

具体的には、

- Unityのコア以外の必要な機能だけをPackageとしてインストールできる
- `Assets`フォルダとは別のフォルダで管理される
- 使用しているアセットとバージョンはメタデータとして管理される
    - つまりGitリポジトリなどにバイナリやコードを含めなくて良い

という感じでかなり良いのですが、現時点では公式アセットしか使えません。

自作アセットとかでも使えるようになると最高だと思うのですが、マニュアルなどをみてもそういう話は見受けられなかったので、あまり期待した方がいいかもしれません。

## 参考

- [Unity Package Manager | Package Manager UI website](https://docs.unity3d.com/Packages/com.unity.package-manager-ui@1.8/manual/index.html#PackManManifestsPackage)
- [Package Managerとは【Unity】 - (:3[kanのメモ帳]](http://kan-kikuchi.hatenablog.com/entry/PackageManager)
- [Unity Package Managerについて - Qiita](https://qiita.com/k7a/items/cc5d09bc1000551b203f)
