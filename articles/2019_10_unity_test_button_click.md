---
title: "【Unity】クリック座標を指定してButton/ToggleのOnPointerClick()を発火させる【TestRunner】"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
published_at: 2019-10-31 00:59
---

# はじめに

UnityでUIのテストをする時、直接Canvas上の要素を指定してクリックイベントを発火させたい場合があります。

また、大抵の`Buttun`はクリックのRaycastが当たるコンポート(`Image`)が同一のオブジェクトにアタッチされていますが、`Toggle`や`InputField`などはオブジェクトが分かれていることが多いです。そういった場合にどのようにイベントを伝搬させればよいか調べてみたので、その方法を紹介したいと思います。


今回紹介するソースコード: [ClickTest.cs](https://gist.github.com/nkjzm/1cadb94fe5ea4248ecb3f0b1534202cf)

# アプローチ

UnityがEventSystemで行っている処理をテストスクリプト上で再現します。

## 座標指定でRaycastを飛ばし、ポインターが当たっているオブジェクトを取得する

`EventSystem.current.RaycastAll()`でRaycast先のオブジェクトを全て取得し、Linqで「先頭から」の有効なGameObjectを取得しています。

```cs
// ポインタイベントの作成
var ev = new PointerEventData(EventSystem.current);
ev.position = new Vector2(x, y);

// EventSystem経由でクリック結果を取得
var results = new List<RaycastResult>();
EventSystem.current.RaycastAll(ev, results);
var target = results.Select(r => r.gameObject).First(t => t != null);

// 親階層を辿ってクリックイベントを発火
ExecuteClickHierarchy(target, ev);
```

ただ、ドキュメントをみると少し気になることが書いてあります。

> Casts a ray through the Scene and returns all hits. Note that order is not guaranteed.

[Physics-RaycastAll - Unity スクリプトリファレンス](https://docs.unity3d.com/jp/current/ScriptReference/Physics.RaycastAll.html)

意訳すると「シーンを通してレイを飛ばし、ヒットした全てを返します。**順序が保証されないことに注意してください**」です。先頭から取得するのは誤りかと思いuGUIの実装を見てみましたが、こちらも先頭から取得しているようです。恐らく大丈夫でしょう。

```cs
protected static RaycastResult FindFirstRaycast(List<RaycastResult> candidates)
{
    for (var i = 0; i < candidates.Count; ++i)
    {
        if (candidates[i].gameObject == null)
            continue;

        return candidates[i];
    }
    return new RaycastResult();
}
```

[BaseInputModule.cs (117-127行目)](https://bitbucket.org/Unity-Technologies/ui/src/31cbc456efd5ed74cba398ec1a101a31f66716db/UnityEngine.UI/EventSystem/InputModules/BaseInputModule.cs#lines-117:127)


## 親階層を辿ってクリックイベントを発火させる

先ほど最後に読んでいた`ExecuteClickHierarchy()`の中身を解説していきます。

`GetEventChain()`で親階層のオブジェクトを取得し、`ExecuteEvents.Execute()`が成功するまで実行していく処理になっています。


```cs
static void ExecuteClickHierarchy(GameObject root, BaseEventData eventData)
{
    var transformList = new List<Transform>();
    GetEventChain(root, transformList);

    for (var i = 0; i < transformList.Count; i++)
    {
        var transform = transformList[i];
        ExecuteEvents.EventFunction<IPointerClickHandler> callback = (handler, ev) =>
        {
            handler.OnPointerClick((PointerEventData)ev);
        };
        if (ExecuteEvents.Execute<IPointerClickHandler>(transform.gameObject, eventData, callback))
        {
            return;
        }
    }
    Debug.LogError("クリック失敗");
}

```

これはuGUIでの実装が元になっています。汎用的な作りになっているので、クリックのみに対応させた形です。
[ExecuteEvents.cs (279-290行目)](https://bitbucket.org/Unity-Technologies/ui/src/31cbc456efd5ed74cba398ec1a101a31f66716db/UnityEngine.UI/EventSystem/ExecuteEvents.cs?at=2019.1#lines-279:290)

# 使い方

関数の中でClickを呼び出してください。**Gameビューの解像度に依存することに注意してください。**

```
[UnityTest]
public IEnumerator TestWithEnumeratorPasses()
{
    Click(170, 520);
    Assert.True(GameObject.FindObjectOfType<Toggle>().isOn);
    yield return null;
}
```

ちなみに座標はポインタ座標はエディタ実行時に`EventSystem`のHierarchyビュー上で確認できます。

![Oct-31-2019 00-47-02.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/e183f0e7-60ed-bd6b-452d-632f6912b0ac.gif)
_右下のPositionと書かれた部分の数字がポインタ座標(クリック座標)_


# ソースコード全文

Gist: [ClickTest.cs](https://gist.github.com/nkjzm/1cadb94fe5ea4248ecb3f0b1534202cf)

```cs:ClickTest.cs
using UnityEngine.TestTools;
using NUnit.Framework;
using System.Collections;
using UnityEngine.EventSystems;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Linq;
using UnityEngine.SceneManagement;


public class ClickTest
{
    [SetUp]
    public void SetUp()
    {
        SceneManager.LoadScene("Main");
    }

    [UnityTest]
    public IEnumerator TestWithEnumeratorPasses()
    {
        Click(170, 520);
        Assert.True(GameObject.FindObjectOfType<Toggle>().isOn);
        yield return null;
    }

    void Click(int x, int y)
    {
        // ポインタイベントの作成
        var ev = new PointerEventData(EventSystem.current);
        ev.position = new Vector2(x, y);

        // EventSystem経由でクリック結果を取得
        var results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(ev, results);
        var target = results.Select(r => r.gameObject).First(t => t != null);

        // 階層を辿ってクリックイベントを発火
        ExecuteClickHierarchy(target, ev);
    }

    static void ExecuteClickHierarchy(GameObject root, BaseEventData eventData)
    {
        var transformList = new List<Transform>();
        GetEventChain(root, transformList);

        for (var i = 0; i < transformList.Count; i++)
        {
            var transform = transformList[i];
            ExecuteEvents.EventFunction<IPointerClickHandler> callback = (handler, ev) =>
            {
                handler.OnPointerClick((PointerEventData)ev);
            };
            if (ExecuteEvents.Execute<IPointerClickHandler>(transform.gameObject, eventData, callback))
            {
                return;
            }
        }
        Debug.LogError("クリック失敗");
    }

    static void GetEventChain(GameObject root, IList<Transform> eventChain)
    {
        if (root == null) { return; }

        var t = root.transform;
        while (t != null)
        {
            eventChain.Add(t);
            t = t.parent;
        }
    }
}
```

# 最後に

今回調査に当たってuGUIのソースコードを読んだのですが、イベント関数がどのように呼び出されているかを知ることができてとても勉強になりました。

誤った理解になっている場所があれば指摘してもらえると嬉しいです。

# 参考

- [UnityでuGUIのUIテストを自動化 - Qiita](https://qiita.com/tadokoro/items/e72d6eff5998cb00ab02)
- [Unityアプリを無差別タップで自動テストする - KAYAC engineers' blog](https://techblog.kayac.com/unity-automated-random-tap-test)
  * 最新のブランチだとなぜか該当ファイルが削除されているので、過去のコミットから参照しました: [DebugTapper.cs](https://github.com/hiryma/UnitySamples/blob/16af52d001fcb947f08c657f1d5d233907934d69/AutoTapTest/Assets/Kayac/Debug/DebugTapper.cs)


