---
title: 【Unity】これ以上iOSのSafeAreaで消耗したくない人のため『Unity-SafeAreaCanvas』
tags:
  - Unity
private: false
updated_at: '2018-12-24T05:06:29+09:00'
id: e395e6da9ca46963dba9
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

この記事は[Unity Advent Calendar 2018](https://qiita.com/advent-calendar/2018/unity)17日目の記事の代理投稿です！16日目は@namazuchinさんの[UnityでTwilioを利用して固定電話に架電する](https://blog.ariari.biz/2018/12/16/unity_twilio/)でした。

<blockquote class="twitter-tweet" data-cards="hidden" data-lang="ja"><p lang="ja" dir="ltr">iPhone X/XSのSafeAreaに対応したUnityアセットをリリースしました🎉<br><br>1. iOSでの実行時にCanvasサイズ調整機能<br>2, Unityエディタ上でのプレビュー機能<br>3. GameビューにiPhone X/XS用サイズの追加機能<br><br>ぜひ使ってみてください！<br>nkjzm/Unity-SafeAreaCanvas<a href="https://t.co/If9zYqHrqG">https://t.co/If9zYqHrqG</a> <a href="https://twitter.com/hashtag/Unity?src=hash&amp;ref_src=twsrc%5Etfw">#Unity</a> <a href="https://twitter.com/hashtag/SafeArea?src=hash&amp;ref_src=twsrc%5Etfw">#SafeArea</a> <a href="https://t.co/9EFPkf1qGf">pic.twitter.com/9EFPkf1qGf</a></p>&mdash; Nakaji Kohki / リリカちゃん💜💊 (@nkjzm) <a href="https://twitter.com/nkjzm/status/1064703125678739461?ref_src=twsrc%5Etfw">2018年11月20日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

先日、iPhone X/XSのSafeAreaに対応したOSSをリリースしました。
今回は、使い方の紹介と、実装の解説をしていこうと思います。

リポジトリ: https://github.com/nkjzm/Unity-SafeAreaCanvas

# 使い方

UnityのSafeArea対応に関する記事は、実機での反映のみに言及したものが多いですが、実際に開発する際には、SafeAreaが適用された場合の見え方をプレビューしながら進めたいと感じました。そのため、プレビューと実機対応の両方に対応したのが今回のアセットになります。

![sample (1) (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/edaea012-112c-f0ea-68d0-0cd87d76af67.gif)


1. [Releases](https://github.com/nkjzm/Unity-SafeAreaCanvas/releases)から`SafeAreaCanvas.unitypackage`をダウンロードしてください。
1. プロジェクトに`SafeAreaCanvas.unitypackage`をインポートしてください。
1. シーンに`SafeAreaCanvas/Prefabs/SafeAreaCanvas.prefab`をドラッグしてください。

あとは`SafeAreaCanvas.prefab`の子の`SafeArea`以下にUIなどを作成・配置していけば良いです。
その状態でGameビューのサイズを変更すると、自動的にSafeAreaの余白が更新されます。
また、実機でも同じように動作するはずです。

# 実装

シンプルな実装なのですが、簡単に紹介していきます。

## iOS実機実行時のCanvasサイズ調整機能

```SetCanvasBounds.cs
using UnityEngine;

namespace nkjzm.SafeAreaCanvas
{
    [ExecuteInEditMode()]
    public class SetCanvasBounds : MonoBehaviour
    {
        public RectTransform panel;
        Rect lastSafeArea = new Rect(0, 0, 0, 0);

        void ApplySafeArea(Rect area)
        {
            panel.anchoredPosition = Vector2.zero;
            panel.sizeDelta = Vector2.zero;

            var anchorMin = area.position;
            var anchorMax = area.position + area.size;
            anchorMin.x /= Screen.width;
            anchorMin.y /= Screen.height;
            anchorMax.x /= Screen.width;
            anchorMax.y /= Screen.height;
            panel.anchorMin = anchorMin;
            panel.anchorMax = anchorMax;

            lastSafeArea = area;
        }

        void Update()
        {
            if (panel == null) { return; }

            Rect safeArea = Screen.safeArea;
#if UNITY_EDITOR
            if (Screen.width == 1125 && Screen.height == 2436)
            {
                safeArea.y = 102;
                safeArea.height = 2202;
            }
            if (Screen.width == 2436 && Screen.height == 1125)
            {
                safeArea.x = 132;
                safeArea.y = 63;
                safeArea.height = 1062;
                safeArea.width = 2172;
            }
#endif
            if (safeArea != lastSafeArea)
            {
                ApplySafeArea(safeArea);
            }
        }
    }
}
```
https://github.com/nkjzm/Unity-SafeAreaCanvas/blob/master/Assets/SafeAreaCanvas/Scripts/SetCanvasBounds.cs

`panel`のサイズがSafeAreaのサイズと一致するようになっています。
Unity2017.3くらいから、`Rect safeArea = Screen.safeArea`でsafeAreaのサイズが取得できるようになりました。その値を`ApplySafeArea`関数で`panel`に反映させています。

```cs
void ApplySafeArea(Rect area)
{
    panel.anchoredPosition = Vector2.zero;
    panel.sizeDelta = Vector2.zero;
    var anchorMin = area.position;
    var anchorMax = area.position + area.size;
    anchorMin.x /= Screen.width;
    anchorMin.y /= Screen.height;
    anchorMax.x /= Screen.width;
    anchorMax.y /= Screen.height;
    panel.anchorMin = anchorMin;
    panel.anchorMax = anchorMax;
    lastSafeArea = area;
}
```

UIのAnchorサイズをSafeAreaに合わせて更新しています。Anchorは`Vector2`型で各値が0-1の範囲で表現されています。`RectTransform`の左下が`(0,0)`で右上が(1,1)です(下記画像参照)。Areaの座標を代入した後に`Screen.width`や`Screen.height`で割ることで、0-1に正規化しているイメージです。

<img width="664" alt="スクリーンショット 2018-12-24 4.39.38.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/83f2617c-ffc3-b79b-47f3-025e67bdaaac.png">

ちなみに[Screen.safeArea](https://docs.unity3d.com/ja/current/ScriptReference/Screen-safeArea.html)は[Rect](https://docs.unity3d.com/ja/current/ScriptReference/Rect.html)型として返ってきます。矩形を表現するクラスで、`Vector2`型の`Position`に`x`や`y`などで直接アクセス出来たりする便利なクラスなのですが、`Rect`本来の座標系は左上が原点である点に注意してください。

## Unityエディタ上でのプレビュー機能

上記コードでiPhone X/XSを判定する部分がこちらです(めちゃめちゃハードコーディングですみません)。

```cs
#if UNITY_EDITOR
if (Screen.width == 1125 && Screen.height == 2436)
{
    safeArea.y = 102;
    safeArea.height = 2202;
}
if (Screen.width == 2436 && Screen.height == 1125)
{
    safeArea.x = 132;
    safeArea.y = 63;
    safeArea.height = 1062;
    safeArea.width = 2172;
}
#endif
```
エディタ上では`Screen.safeArea`が値を返してくれないため、自前で値を入れています。大した処理じゃないので`Update()`でやっています(`ApplySafeArea()`は繰り返し呼ばれません)

逆に言うと、エディタプレビュー機能はこんなに短いコードのみで対応しています。簡単ですね。

## GameビューにiPhone X/XS用サイズの追加機能

インポート時、GameビューのサイズにiPhone X/XSの設定を追加する機能を入れています。Build TagetをiOSにしている場合はすでに含まれているので不要なのですが、別プラットフォームの設定で作業をする場合などに便利です。

<img width="354" alt="スクリーンショット 2018-12-24 4.49.55.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/77d2683c-fcbf-22d5-a760-c36d72260de0.png">

実装には[unity-GameViewSizeHelper](https://github.com/anchan828/unity-GameViewSizeHelper)というアセットを利用させていただいています。「ScriptからGameViewSizeを作成、また設定するヘルパークラス」とあり、まさにやりたいことでした。

```GameViewSizeAdder.cs
using UnityEditor;
using UnityEngine;

namespace nkjzm.SafeAreaCanvas
{
    public class GameViewSizeAdder
    {
        [InitializeOnLoadMethod]
        static void Init()
        {
            var wide = new GameViewSizeHelper.GameViewSize
            {
                type = GameViewSizeHelper.GameViewSizeType.FixedResolution,
                width = 2436,
                height = 1125,
                baseText = "iPhone X/XS Landscape"
            };
            var tall = new GameViewSizeHelper.GameViewSize
            {
                type = GameViewSizeHelper.GameViewSizeType.FixedResolution,
                width = 1125,
                height = 2436,
                baseText = "iPhone X/XS Portrait"
            };
            GameViewSizeHelper.AddCustomSize(GameViewSizeGroupType.Standalone, wide);
            GameViewSizeHelper.AddCustomSize(GameViewSizeGroupType.Standalone, tall);
            GameViewSizeHelper.AddCustomSize(GameViewSizeGroupType.Android, wide);
            GameViewSizeHelper.AddCustomSize(GameViewSizeGroupType.Android, tall);
        }
    }
}
```
https://github.com/nkjzm/Unity-SafeAreaCanvas/blob/master/Assets/SafeAreaCanvas/Scripts/Editor/GameViewSizeAdder.cs

`[InitializeOnLoadMethod]`というアトリビュートを使って自動的にサイズ追加をしています。コンパイルが終わった後などにエディタ上で呼び出されるものです。複数回`AddCustomSize`を呼び出していますが、`GameViewSizeHelper`では同一の設定は追加されないようになっているみたいなので、大丈夫でした。ありがたいですね！

iOSと同じプロジェクトで使う可能性が高そうなStandAloneとAndroidの対応を入れています。

# 最後に

[『Unity-SafeAreaCanvas』](https://github.com/nkjzm/Unity-SafeAreaCanvas)は、私がSafeArea対応で消耗した時に作成したアセットです。ぜひ多くの方に使っていただきたいですし、気になった点のIssueやPull Requestもお待ちしております！

[Unity Advent Calendar 2018](https://qiita.com/advent-calendar/2018/unity)18日目の記事は@kaiware007さんの[Thetaのストリーミング映像をリアルタイムにリフレクションさせてみた](http://kaiware007.hatenablog.jp/entry/2018/12/18/012742)です。
