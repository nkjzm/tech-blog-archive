---
title: 描画負荷がかからない透明なuGUI Imageを作る【Unity】
tags:
  - Unity
private: false
updated_at: '2025-10-06T21:48:15+09:00'
id: e77b004166cc779e13c7
organization_url_name: null
slide: false
ignorePublish: false
---
## はじめに

uGUIの操作を制限するため手前に透明なImageを重ねることがあると思いますが、そのままでは1枚分の描画負荷がかかってしまいます。その負荷を軽減する方法を紹介します。

## 方法

<img width="421" alt="スクリーンショット 2020-02-06 10.05.10.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/14ad20f7-436f-a560-f4a8-b75dbc952974.png">

Imageと同じGameObjectについているCanvasRendererの`Cull Transparent Mesh`をオンにしてください。

<img width="726" alt="スクリーンショット 2020-02-06 10.33.17.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/ba8a2f1e-433a-f9ce-cabe-de30c62db59d.png">


SceneビューのOverdrawモードで確認すると、設定したImage部分の描画がされていないことが確認できます。

![ダウンロード (1).png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/803fe7b8-7af0-ee68-6abf-cd6ea0a869ae.png)

StatsでもBatchesが増えていないことが確認できます。

ちなみにCanvasRendererの`Cull Transparent Mesh`で全ての描画がなくなるのは全ての画像領域が完全に透明な場合のみです。アルファ値が0.1でも残っていると描画されてしまう点に注意してください。

## おまけ: 最初から描画しないスクリプトを自作する

上記の方法とほぼほぼ同じことができるスクリプトです。途中から意味ないと気がついたのですが、折角なので紹介します。raycastも当たるやつです。

<img width="1142" alt="スクリーンショット 2020-02-06 10.20.18.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/1733e717-b37d-87bd-4c7d-6f87bead074f.png">
_^先ほどと同様にいくつ置いても描画されない_

### スクリプト

Gist: [NoRenderImage.cs](https://gist.github.com/nkjzm/2961705cb185ca6749e25860da8999a9)

```cs:NoRenderImage.cs
using UnityEditor;

namespace UnityEngine.UI
{
    /// <summary>
    /// 描画しない透明Imageコンポーネント
    /// </summary>
    [AddComponentMenu("UI/NonRenderImage", 2004)]
    public class NoRenderImage : Graphic
    {
        protected override void OnPopulateMesh(VertexHelper vh) { vh.Clear(); }

#if UNITY_EDITOR
        [UnityEditor.CustomEditor(typeof(NoRenderImage))]
        class NonRenderImageEditor : UnityEditor.Editor
        {
            public override void OnInspectorGUI() { }

            private static Vector2 s_ImageElementSize = new Vector2(100f, 100f);

            [MenuItem("GameObject/UI/NoRender Image", false, 2004)]
            public static void CreateNoRenderImage()
            {
                var parent = Selection.activeGameObject?.transform;
                if (parent == null || parent.GetComponentInParent<Canvas>() == null)
                {
                    var canvas = new GameObject("Canvas");
                    canvas.transform.SetParent(parent);
                    canvas.AddComponent<Canvas>().renderMode = RenderMode.ScreenSpaceOverlay;
                    canvas.AddComponent<CanvasScaler>();
                    canvas.AddComponent<GraphicRaycaster>();
                    parent = canvas.transform;
                }
                var go = new GameObject("NoRenderImage");
                var rectTransform = go.AddComponent<RectTransform>();
                rectTransform.SetParent(parent);
                rectTransform.sizeDelta = s_ImageElementSize;
                rectTransform.anchoredPosition = Vector2.zero;
                Selection.activeGameObject = go;
                go.AddComponent<NoRenderImage>();
            }
        }
#endif
    }
}
```

メインはこの部分だけです。メッシュ描画のコールバック関数である`OnPopulateMesh`をoverrideして、頂点をクリアしています。これで描画だけがされないGraphicコンポーネントが実現できました。
参考: [ボタンの当たり判定(タッチ範囲)だけ広げる【Unity】【uGUI】 - (:3[kanのメモ帳]](https://kan-kikuchi.hatenablog.com/entry/InvisibleGraphic)

```cs
public class NoRenderImage : Graphic
{
    protected override void OnPopulateMesh(VertexHelper vh) { vh.Clear(); }
}
```

他の部分は便利に使うための記述です。

<img width="415" alt="スクリーンショット 2020-02-06 10.25.39.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/729374a6-515b-712f-f717-697624aff0f3.png">
_^[Add Component]メニューのUIカテゴリから追加できる_

<img width="527" alt="スクリーンショット 2020-02-06 10.26.43.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/def184c7-72b3-bc0a-5b16-07910cde11e0.png">
_^Createメニューからも生成できる_

<img width="190" alt="スクリーンショット 2020-02-06 10.28.07.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/91483570-628b-4ca2-0f80-782917c63e72.png">
_^Canvas以下でない階層で生成すると、自動的にCanvasを作ってくれる_

この辺りは別の記事でまとめておこうと思います。

## 余談

`Text`コンポーネントも描画するテキストがない場合に描画がされないので、それで良い説もありますね。


