---
title: "【Unity】コマンドライン引数で単一ビルドに複数ビルドの振る舞いをさせる"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
published_at: 2018-08-18 23:30
---

# はじめに

この記事は[Unityゆるふわサマーアドベントカレンダー 2018](https://qiita.com/splas_boomerang/items/e6619fb1e6dd92fd231f)の18日目です！
(あと2枠余っているのでぜひ！)

あるUntiyプロジェクトからビルドしたアプリを、複数の設定で立ち上げたい場合がありました。
例えば、起動直後のシーンを異なるものにしたり、デバッグモードで起動したいような場合です。

コマンドライン引数とショートカット（エイリアス)を利用することで、単一のビルドで複数のビルドがあるような振る舞いに出来るので、その方法を紹介したいと思います。

製品として出すようなものへの使用は難しいと思うので、あくまで開発効率化の方法としてご覧ください。

# 手順

Windowsを例に紹介しますがMacでも同様のことが可能です。

## 動作環境

Unity2018.2.1f1
Windows

## コマンドライン引数で設定を変える

ビルドの起動時にスペース区切りで任意の引数を与えることができます。
test.exeがあるディレクトリでコマンドラインを開き、以下のようにすることで`-mode`と`1`という引数を渡すことができます。

```
./test.exe -mode 1
```

この引数をUnityで取得するためには、`System.Environment.GetCommandLineArgs()`というメソッドを利用します。以下はサンプルです。

``` Test.cs
public class Test : MonoBehaviour
{
    void Start()
    {
        string[] args = System.Environment.GetCommandLineArgs();
        for (int i = 0; i < args.Length; ++i)
        {
            switch (args[i])
            {
                case "-mode":
                    int mode = 0;
                    if (i + 1 < args.Length && int.TryParse(args[i + 1], out mode))
                    {
                        // do something
                    }
                    break;
            }
        }
    }
}
```

今回の例では`-mode`の後ろに値(`1`)を入力する形にしました。こうすることで、コマンドライン引数の順序に依存せずに値を指定できるようになります。順番が決まっているようなら、`./test.exe 1`というような指定でも良いかと思います。

また、コマンドライン引数を渡さずに起動する場合もあると思うので、渡されなかった場合の挙動は想定しておいた方が良いと思います。

## コマンドライン引数付きのショートカット(エイリアス)の作成

毎回コマンドラインを叩くのは面倒だと思うで、ショートカットを作っておくと便利です。
ビルドしなおしてもパスが変わらなければ大丈夫なので、初めに一度作って置くだけです。

まずExplorerでビルドのあるフォルダを開きます。
world-client.exeの上で右クリックをしてショートカットを作成を選択します。

ショートカット上で右クリック→プロパティを開くと、「リンク先」という項目にビルドのパスが書かれているので、そこにコマンドライン引数を追加していきます。
スペース区切りで任意のコマンドライン引数を設定しましょう。

ショートカットの名前は、設定を表すものにしておくと良いかと思います。


# おまけ：便利そうな起動時のコマンドライン引数

フルスクリーンにするかどうかの指定
例: `-screen-fullscreen false`

ウィンドウサイズの指定
例: `-screen-height 114 -screen-width 514`

スクリーンの品質の指定
例: `-screen-quality Beautiful`

同時に起動できるインスタンスを1つにする指定
例: `-single-instance`


参考：[コマンドライン引数 - Unity マニュアル](https://docs.unity3d.com/ja/current/Manual/CommandLineArguments.html)


