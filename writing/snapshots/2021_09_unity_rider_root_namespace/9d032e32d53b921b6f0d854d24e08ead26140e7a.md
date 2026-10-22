---
title: "【Unity】プロジェクトのルートの名前空間を指定する【Rider】"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
---
# はじめに

Riderの標準機能でルートの名前空間を指定した時に、設定が初期化されてしまう問題が発生しました。今回はその対処方法について紹介します。

恐らく他のエディタでも共通する話なのですが、今回はRiderを使っている前提で話します。


# 環境

- macOS 11.4（20F71）
- Unity 2020.3.11f1
    - JetBrains Rider Editor 3.0.7
- JetBrains Rider 2021.1.5

# 背景（発生した問題について）

Riderのコードインスペクションには、ディレクトリ構造と名前空間の不一致を検出してくれる機能があります。
![スクリーンショット 2021-09-30 13.14.36.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/4f68a57c-7e10-4b8e-13db-5ae42a0f69e8.png)

便利な機能なのですが、ディレクトリ構造と名前空間は必ずしも一致しません。プラットフォーム固有のディレクトリを省きたい事情や、C#のガイドラインに沿った下記のような名前空間にしたい場合があります。

```
<Company>.(<Product>|<Technology>)[.<Feature>][.<Subnamespace>]
```

https://docs.microsoft.com/ja-jp/dotnet/standard/design-guidelines/names-of-namespaces

そこでRiderには以下のように名前空間を調整する機能があるのですが、前者に関しては何故かコンパイルのタイミングなどで設定が初期化されてしまう問題がありました。

- ルートの名前空間を指定する
- 名前空間要素にしないディレクトリを指定する

https://pleiades.io/help/rider/Refactorings__Adjust_Namespaces.html


# 解決方法

該当プロジェクトの Assembly Definition Asset（asmdefファイル）の「Root Namespace」で指定すればOKです。

![スクリーンショット 2021-09-30 12.52.56.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/3bfb4afb-ae4d-92ff-ec2e-8a126435363f.png)

Assembly Definition Assetについては各自で調べてください。設定されていないプロジェクト（csproj）に関しては、やはりコンパイルの度にリセットされてしまうようです。

原因なのですが、Unityマニュアルを見ると対象となるcsprojはUnity側で制御しているような説明があります。恐らくこの辺りの仕組みが原因なのではないでしょうか

> Unity は自動的に Visual Studio .sln および .csproj ファイルを作成および維持します。誰が Unity 内でファイルを追加、名前変更、移動、削除を行なっても、Unity は .sln および .csproj ファイルを生成します。Visual Studio からのソリューションにもファイルを追加できます。Unity はこれらの新しいファイルをインポートし、次に Unity がプロジェクトファイルを再度作成すると、この新しいファイルを含めて、プロジェクトファイルを作成します。

https://docs.unity3d.com/ja/2018.4/Manual/VisualStudioIntegration.html

# 最後に

（RiderはUnityを前提としたIDEなのに、なんでこの挙動について書いてないんだろう・・・？）

Twitterやっているのでフォローしてくれると嬉しいです！

https://twitter.com/nkjzm


# 追記

Unity 2020.2 の新機能に書いてあることを教えてもらいました！

> アセンブリ定義の設定で Root Namespace が利用可能に
C# の名前空間は、コードを整理する効率的な方法を提供し、クラスの命名に関して他のパッケージやライブラリとの衝突を回避できます。Root Namespace が asmdef インスペクターの新しいフィールドとして利用できるようになり、Unity や Visual Studio と Rider で新しいスクリプトを作成するときに名前空間を自動的に追加するために使用されます。


https://unity.com/ja/releases/2020-2/programmer-tools#root-namespace-available-assembly-definition-settings
