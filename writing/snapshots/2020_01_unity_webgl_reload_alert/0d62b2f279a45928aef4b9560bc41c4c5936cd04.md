---
title: "UnityのWebGLビルドでページ再読み込みやアラートの設定を行うためのプラグイン【WebGLReloaderForUnity】"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
---

![Jan-05-2020 22-48-10.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/f60682c3-78b3-7231-67bd-178601131895.gif)

リポジトリ: [nkjzm/WebGLReloaderForUnity](https://github.com/nkjzm/WebGLReloaderForUnity)

# はじめに

この記事は[Unity #2 Advent Calendar 2019](https://qiita.com/advent-calendar/2019/unity2) 21日目の記事[^1]です。

[^1]: 遅刻してごめんなさい

UnityでWebGL出力したゲームはブラウザ上で動作しているため、ゲーム側からブラウザの挙動を制御したい場合があります。例えば以下のような状況です。

- バトル中にタブを閉じようとした時に警告を出す
- リソースの更新時にページをリロードする。

残念ながら、こうした操作は現行のUnityではサポートされていません。そこで今回は、上記の制御を簡単に扱うことができるプラグインを作成したので、紹介したいと思います。

## 宣伝

このプラグインは『[Crypto Alchemist（クリプトアルケミスト）](https://cryptoalchemist.jp/)』というブロックチェーンゲームの開発過程において作成されました。もうすぐオープンβが予定されているので、良かったらぜひ事前登録等よろしくお願いします！

公式ページ: [Crypto Alchemist（クリプトアルケミスト）](https://cryptoalchemist.jp/)
公式Twitter: [@crypto_alchemi](https://twitter.com/crypto_alchemi)

# 使い方

[リポジトリ](https://github.com/nkjzm/WebGLReloaderForUnity)から最新の[*.unitypackage](https://github.com/nkjzm/WebGLReloaderForUnity/releases/latest)をダウンロードし、自身のUnityプロジェクトにインポートしてください。

使用できるメソッドは以下の通りです。staticメソッドなのでコンポーネントのアタッチ等は必要ありません。

```cs
// ページ離脱時の警告を有効にする
nkjzm.WebGLHandler.EnableBeforeUnloadEvent();
nkjzm.WebGLHandler.EnableBeforeUnloadEvent("離脱時のメッセージ");

// ページ離脱時の警告を無効にする
nkjzm.WebGLHandler.DisableBeforeUnloadEvent();

// ページ離脱時の警告が有効かどうかを返す
nkjzm.WebGLHandler.IsEnabledBeforeUnloadEvent();

// ページ再読み込み
nkjzm.WebGLHandler.Reload();
```

また、プラグイン以下の`Example`フォルダに入っているシーンを実行することで、以下のGifのシーンを試せるようになっています。

![Jan-05-2020 22-48-10.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/f60682c3-78b3-7231-67bd-178601131895.gif)


リソースの読み込み中(下記画像参照)にもアラートを出したい場合について、WebGLビルドでは読み込みが完了するまでC#コードを呼び出すことができません。

<img width="771" alt="スクリーンショット 2020-01-05 23.19.04.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/8a816b4d-aca9-7056-14ad-aefe45c10ad0.png">

そこで、 `WebGLTemplates`の仕組みを使うと解決できます。UnityのWebGL出力時のhtml/cssを指定できる機能です。

<img width="388" alt="スクリーンショット 2020-01-05 23.26.15.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/b886e8fe-3c7c-aa88-5c49-fd73a1460a31.png">

参考: [WebGL テンプレートの使用 - Unity マニュアル](https://docs.unity3d.com/ja/current/Manual/webgl-templates.html)

[GitHubリポジトリ](https://github.com/nkjzm/WebGLReloaderForUnity)以下に初めからアラートが有効になったWebGL Templeteを入れてあるので、良かったらCloneして試してみてください(差分は次章で解説)。


# 実装

```js:BeforeunloadPlugin.jslib
var BeforeunloadPlugin = {
  $funcs: {},
  enableBeforeUnloadEvent: function () {
    enableBeforeUnloadEvent("Do you want to leave this page?");
  },
  enableBeforeUnloadEvent: function (message) {
    window.onbeforeunload = function (e) {
      e.returnValue = message;
      return message;
    }
  },
  disableBeforeUnloadEvent: function () {
    window.onbeforeunload = null;
  },
  isEnabledBeforeUnloadEvent: function () {
    return window.onbeforeunload != null;
  },
  reload: function () {
    location.reload();
  },
}
autoAddDeps(BeforeunloadPlugin, '$funcs');
mergeInto(LibraryManager.library, BeforeunloadPlugin);
```

`.jslib`というUnity専用の拡張子を使っていますが、言語はJavaScriptそのままです。少しだけお作法があるのですが、今回のような標準的な機能を呼び出すだけであればあまり難しいことはないと思います。動作確認の度にWebGL出力する必要があるので、その手間はありました。

`.jslib`については以下の記事でめちゃめちゃ詳しく解説されているので、困ったときは是非みてみてください。

参考: [Unity(WebGL)でC#の関数からブラウザー側のJavaScript関数を呼び出すまたはその逆(JS⇒C#)に関する知見(プラグイン形式[.jslib])](https://qiita.com/gtk2k/items/1c7aa7a202d5f96ebdbf)

```js
  enableBeforeUnloadEvent: function (message) {
    window.onbeforeunload = function (e) {
      e.returnValue = message;
      return message;
    }
  },
```

実装としては、有効にする処理が呼ばれた時に`window.onbeforeunload`というイベントに関数を代入しています。これはブラウザのウィンドウ/タブがUnloadされる直前に呼ばれるコードになります。ブラウザ毎に`e.returnValue`に代入する場合と`return`として返す場合があるので、併記しています。

```js
  disableBeforeUnloadEvent: function () {
    window.onbeforeunload = null;
  },
```

無効にする場合は、イベントに`null`を代入しています。

`WebGLTemplates`を使う場合は、`.jslib`ではなく`index.html`に対して処理を追加しています。

```html
  <script>
    var unityInstance = UnityLoader.instantiate("unityContainer", "%UNITY_WEBGL_BUILD_URL%", { onProgress: UnityProgress });
  </script>
```

デフォルトで上記の記述があるので、下記のように書き換えています。

```html
  <script>
    var unityInstance = UnityLoader.instantiate("unityContainer", "%UNITY_WEBGL_BUILD_URL%", { onProgress: UnityProgress });

    // ページから離脱する時に警告を出す
    window.onbeforeunload = function (e) {
      // ブラウザによってはテキストが反映されない
      e.returnValue = "Do you want to leave this page?";
      return "Do you want to leave this page?";
    }
  </script>
```

# 余談

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">VSCodeでsettings.jsonに&quot;files.associations&quot;を追加すると、.jslib拡張子もJavaScriptとして認識してハイライトしてくれる！最高！！<br><br>参考: <a href="https://t.co/rQTUuICf4B">https://t.co/rQTUuICf4B</a> <a href="https://t.co/ao0p5QbZW6">pic.twitter.com/ao0p5QbZW6</a></p>&mdash; なかじ / リリカちゃん (@nkjzm) <a href="https://twitter.com/nkjzm/status/1201410171441803265?ref_src=twsrc%5Etfw">December 2, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

# 最後に

実装にあたってUnityからJavaScriptのコードを呼び出す方法を学びましたが、意外とシンプルで扱いやすいと感じました。ぜひ参考になれば幸いです。

[Unity #2 Advent Calendar 2019](https://qiita.com/advent-calendar/2019/unity2) 22日目の記事は、@Teach さんの「[Unityエンジニアがサーバーエンジニアに転生した結果、Unityエンジニアとしての実力が向上した話](https://qiita.com/Teach/items/c6ea54201473062bc14a)」です！

