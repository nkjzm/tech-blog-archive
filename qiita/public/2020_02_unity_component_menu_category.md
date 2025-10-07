---
title: 【Unity】独自コンポーネントをCreate/AddComponentの既存カテゴリ階層に追加する
published_at: '2020-02-07 14:43'
private: false
tags:
  - Unity
updated_at: '2020-02-07T14:43:08+09:00'
id: 9680ac7fa2349793cfa2
organization_url_name: null
slide: false
---
![Feb-07-2020 01-19-36.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/bb0b62ea-9216-21db-d9ed-708419882de6.gif)


## はじめに

以前書いた『[描画負荷がかからない透明なuGUI Imageを作る【Unity】](https://qiita.com/nkjzm/items/e77b004166cc779e13c7)』の中で紹介している`NoRenderImage`というコンポーネントをHierarchyの`Create/UI`以下から追加できるようにしたり、AddComponentの`UI`以下から追加できるようにしました。

新しく追加するだけなら簡単ですが既存のカテゴリに追加する方法が少しだけややこしかったので、簡単に解説します。


## AddComponentの既存カテゴリ階層に追加する

こっちの方が簡単なので先に紹介します。

![https___qiita-image-store.s3.ap-northeast-1.amazonaws.com_0_55365_729374a6-515b-712f-f717-697624aff0f3.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/65b8f35f-ba9b-cb53-3f51-ed4395a22ce9.png)

クラスの先頭に`[AddComponentMenu()]`をつけるだけです。既存カテゴリ以下にしたければ`/`で区切って指定してください。第二引数は表示順ですが、コンポーネントについているAddComponentメニューの方では反映されなくて、メニューバーのComponentの方のみに適用されます。


```cs
[AddComponentMenu("UI/NonRenderImage", 14)]
public class NoRenderImage : Graphic
{
}
```

例えば`RectMask2D`の下に追加したい場合は`RectMask2D`の定義を調べます(コードエディタから辿れます)。

```(抜粋)RectMask2D.cs
namespace UnityEngine.UI
{
    [AddComponentMenu("UI/Rect Mask 2D", 13)]
    [DisallowMultipleComponent]
    [ExecuteAlways]
    [RequireComponent(typeof(RectTransform))]
    public class RectMask2D : UIBehaviour, IClipper, ICanvasRaycastFilter
    {
    }
}
```

`13`が指定されていることが確認できるため、`14`を指定してその直後に表示させることができました。

<img width="625" alt="スクリーンショット 2020-02-07 0.47.42.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/4fcfea09-7491-f5e4-b9da-9195218c6378.png">


ちなみに表示順指定は`int`型なので、連番の中に挟む際の細かい表示順は指定できなさそうです。(`RawImage`が`12`、`Mask`と`RectMask2D`が`13`なので、その間は多分辞書順とかでしか制御できない)

## Createの既存カテゴリ階層に追加する

Hierarchyの`Create/UI`以下などに追加する方法です。Canvasの扱いについても簡単に紹介します。

![https___qiita-image-store.s3.ap-northeast-1.amazonaws.com_0_55365_def184c7-72b3-bc0a-5b16-07910cde11e0.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/a5eb9d18-d10f-29a9-5aa7-e2a35d78fdfa.png)

こちらはコンポーネント自体の指定ではなく、生成するメソッドが登録されているメニューになります。以下のような`static`メソッドを用意し、`[MenuItem()]`アトリビュートを追加します。

```cs
[MenuItem("GameObject/UI/NoRender Image", false, 2003)]
public static void CreateNoRenderImage()
{
    var go = new GameObject("NoRenderImage");
    go.AddComponent<NoRenderImage>();
}
```
_^実行すると`NoRenderImage`がアタッチされたGameObjectが生成されるメソッド_

こちらは第三引数で表示順の指定をします。既存のCreateメソッドは`UnityEditor.UI`の`internal`クラス内にありコードエディタからでは辿れないため、Bitbucket上で公開されているリポジトリから確認します。
[Unity-Technologies / ui / UnityEditor.UI / UI / MenuOptions.cs — Bitbucket](https://bitbucket.org/Unity-Technologies/ui/src/2019.1/UnityEditor.UI/UI/MenuOptions.cs)

```(抜粋)MenuOptions.cs
[MenuItem("GameObject/UI/Raw Image", false, 2002)]
static public void AddRawImage(MenuCommand menuCommand)
{
}
```

例えば`RawImage`は`2002`が指定されているため、直後に表示したい場合は`2003`などを指定すれば良いです。

また、生成時に他のコンポーネントと同様に選択中のGameObject以下に生成するようにしてみましょう。Canvas以下でなかった場合は生成する処理も書きました。

```cs
[MenuItem("GameObject/UI/NoRender Image", false, 2003)]
public static void CreateNoRenderImage()
{
    // 選択状態のGameObjectを取得する
    var parent = Selection.activeGameObject?.transform;
    // 親や祖先にCanvasが存在しない場合
    if (parent == null || parent.GetComponentInParent<Canvas>() == null)
    {
        // 新規Canvasの生成
        var canvas = new GameObject("Canvas");
        canvas.transform.SetParent(parent);
        // Canvasの初期化
        canvas.AddComponent<Canvas>().renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.AddComponent<CanvasScaler>();
        canvas.AddComponent<GraphicRaycaster>();
        // 親の付け替え
        parent = canvas.transform;
    }
    var go = new GameObject("NoRenderImage");
    // RectTransformの初期化
    var rectTransform = go.AddComponent<RectTransform>();
    // 親コンポーネントの指定 (nullの場合はルートになるので問題ない)
    rectTransform.SetParent(parent);
    rectTransform.sizeDelta = s_ImageElementSize;
    rectTransform.anchoredPosition = Vector2.zero;
    // 生成したGameObjectを選択状態にする
    Selection.activeGameObject = go;
    // コンポーネントの追加
    go.AddComponent<NoRenderImage>();
}
```

簡易的ですが、これで他のUIコンポーネントと同様の振る舞いをするようになったと思います。

![Feb-07-2020 01-19-36.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/bb0b62ea-9216-21db-d9ed-708419882de6.gif)
_^生成後のGameObjectが選択状態になる / Canvas下でない場合は生成する_

## スクリプト全文

Gist: [NoRenderImage.cs](https://gist.github.com/nkjzm/2961705cb185ca6749e25860da8999a9)

```cs:NoRenderImage.cs
using UnityEditor;

namespace UnityEngine.UI
{
    /// <summary>
    /// 描画しない透明Imageコンポーネント
    /// </summary>
    [AddComponentMenu("UI/NonRenderImage", 14)]
    public class NoRenderImage : Graphic
    {
        protected override void OnPopulateMesh(VertexHelper vh) { vh.Clear(); }

#if UNITY_EDITOR
        [UnityEditor.CustomEditor(typeof(NoRenderImage))]
        class NonRenderImageEditor : UnityEditor.Editor
        {
            public override void OnInspectorGUI() { }

            private static Vector2 s_ImageElementSize = new Vector2(100f, 100f);

            [MenuItem("GameObject/UI/NoRender Image", false, 2003)]
            public static void CreateNoRenderImage()
            {
                // 選択状態のGameObjectを取得する
                var parent = Selection.activeGameObject?.transform;
                // 親や祖先にCanvasが存在しない場合
                if (parent == null || parent.GetComponentInParent<Canvas>() == null)
                {
                    // 新規Canvasの生成
                    var canvas = new GameObject("Canvas");
                    canvas.transform.SetParent(parent);
                    // Canvasの初期化
                    canvas.AddComponent<Canvas>().renderMode = RenderMode.ScreenSpaceOverlay;
                    canvas.AddComponent<CanvasScaler>();
                    canvas.AddComponent<GraphicRaycaster>();
                    // 親の付け替え
                    parent = canvas.transform;
                }
                var go = new GameObject("NoRenderImage");
                // RectTransformの初期化
                var rectTransform = go.AddComponent<RectTransform>();
                // 親コンポーネントの指定 (nullの場合はルートになるので問題ない)
                rectTransform.SetParent(parent);
                rectTransform.sizeDelta = s_ImageElementSize;
                rectTransform.anchoredPosition = Vector2.zero;
                // 生成したGameObjectを選択状態にする
                Selection.activeGameObject = go;
                // コンポーネントの追加
                go.AddComponent<NoRenderImage>();
            }
        }
#endif
    }
}
```

## 最後に

CreateやAddComponentに追加する記事はいくつかありましたが、既存のカテゴリ階層に追加する方法は見当たらなかったので簡単にまとめてみました。

もし参考になったら「いいね」やTwitterのフォローよろしくお願いします！
Twitter: [@nkjzm](https://twitter.com/nkjzm)


## 参考

【Unity】AddComponentMenuでスクリプトを整理して表示 │ エクスプラボ
https://ekulabo.com/add-component-menu

