---
title: "【Unity】Riderで1行<summary>を挿入するためのキーマクロとショートカットを割り当てる"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
---
# はじめに

RiderでXML Documentを書く時、クラスやメソッド定義の上の行で`///`と入力すると下記のようなテンプレートを挿入してくれると思います。

```cs
/// <summary>
/// ここにテキストを書く
/// </summary>
public void Hoge() 
{
    // TODO: Implement
}
```

この機能は大変便利なのですが、僕は下記のように書きたい場合があります。

```cs
/// <summary> ここにテキストを書く </summary>
public void Hoge() 
{
    // TODO: Implement
}
```

今回はこれをキーマクロとショートカットで簡単に実現するための方法を紹介します。

## 参考

こちらの記事にある方法を、画像付きで紹介している形になります。

[neue cc - どう書く。ドキュメントコメント。](http://neue.cc/2009/08/05_183.html)


# Riderで1行summaryをショートカットで挿入する方法

## 環境

- macOSX Catalina 10.15.3
- Rider 2019.2.4 (有償版)

## マクロの作成

始めにキーボード操作をマクロとして記録します。

参考: [マクロ - 公式ヘルプ | JetBrains Rider](https://pleiades.io/help/rider/Using_Macros_in_the_Editor.html)


`[Edit]->[Macros]->[Start Macro Recording]` で記録を開始し、エディタ上で1行summaryを次のように入力します。

記録されるのはキーボード操作のみで、マウス操作は含まれないことに注意してください。また、使いやすさを考えた場合、最終的なカーソルの位置がドキュメントコメントの開始位置にくるようにすると良さそうです。

![fdsfasdfads.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/bedb2af4-3f0c-c639-5f5a-aca652cdda59.gif)

実際に記録された操作は次のようになります。

<img width="409" alt="スクリーンショット 2020-03-19 6.44.16.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/0e947dc7-ec3d-484a-c2e1-c3cda5e9aea6.png">

EditorBackSpace: `⌫`
EditorRightWithSelection: `⇧+←`

入力が終わったら`[Edit]->[Macros]->[Stop Macro Recording]`で記録を終了します。任意の名前を付けて保存してください。(e.g.`Add single line summary`)

正しく記録できたか確認します。エディタ上で空行にカーソルを合わせた状態で、`[Edit]->[Macros]->[任意の名前]`を選択してください。

![Mar-19-2020 06-58-58 (1).gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/f9daf5ba-5531-74ca-9485-eeb627f7c5b0.gif)

次のように正しく再生されれば完了です。

## ショートカットの割当

次の先ほど作成したマクロにショートカットを割り当てて行きます。`⌘+,`で設定画面を開き、`Keymap`を選択します。

<img width="760" alt="スクリーンショット 2020-03-19 7.02.33.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/fb878b88-c263-5806-8362-f7bb2f3690bf.png">

`Macros`というフォルダの中に、先ほど作成したマクロが追加されていると思います。項目をダブルクリックし、`Add keyboard Shotcut`を選択します。

<img width="307" alt="スクリーンショット 2020-03-19 7.03.40.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/d0c60025-e902-5310-b573-55cc2daad846.png">

この状態で割り当てたいキーの組み合わせを入力します。被ってしまった場合はこのように警告をしてくれるので、重複しない組み合わせを探しましょう。私は`⌘+⌥+I`にしました。

大丈夫そうならOKを押し、設定ウィンドウの`Save`をクリックします。

先ほどと同様にエディタ上で割り当てたショートカットを入力し、正しく再生されたら完了です。

## 補足

XML Docmentの設定は`[Preferences]->[Editor]->[Code Style]->[C#]`の`[XML Documentation]`タブにあります。中のテキストの前後にスペースを含めたい場合などはここから設定が必要です (`Spaces after start-tag and before end-tag otherwise`) 

<img width="839" alt="スクリーンショット 2020-03-19 7.08.17.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/7787f85d-5157-a151-b6e7-06f7d528d123.png">

また、設定の共有機能でキーマクロは共有されない点に注意してください。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">Rider、同じアカウントでログインするとIDE設定を共有してくれる機能あるじゃん、すこだ…。 <a href="https://t.co/yjZxnY42Kh">pic.twitter.com/yjZxnY42Kh</a></p>&mdash; なかじ / リリカちゃん (@nkjzm) <a href="https://twitter.com/nkjzm/status/1240385843686019072?ref_src=twsrc%5Etfw">March 18, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>


# 最後に

キーマクロはじめて使ったけど楽しそうな機能なので活用していきたいです。

よかったらTwitter([@nkjzm](https://twitter.com/nkjzm))のフォローや「**LGTM**」よろしくお願いします！


# 追記

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">【Unity】Riderで1行&lt;summary&gt;を挿入するためのキーマクロとショートカットを割り当てる <a href="https://t.co/2sATvsVoiS">https://t.co/2sATvsVoiS</a> <a href="https://twitter.com/hashtag/Qiita?src=hash&amp;ref_src=twsrc%5Etfw">#Qiita</a><br><br>マクロよりLive Template使ったほうが楽そうな気がする👀</p>&mdash; su10@ハイパーカジュアルゲーム開発 (@su10_dev) <a href="https://twitter.com/su10_dev/status/1244575561160093702?ref_src=twsrc%5Etfw">March 30, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
