---
title: "【Unity】Oculus向けのEventSystemをEditor上から操作できる形に置き換える"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "VR"]
published: true
published_at: 2019-11-05 03:32
---
# はじめに

[Oculus Integration](https://assetstore.unity.com/packages/tools/integration/oculus-integration-82022)を用いたVRアプリケーションの開発でuGUIを使う時、通常のEventSystemなどをOculus向けのものに置き換えて使用します。

参考: [Oculus QuestでuGUIを操作する - Qiita](https://qiita.com/nkjzm/items/8a62cfab348eacff9167)

大きな変更なくVRでuGUI操作ができるのは大変便利なのですが、その代わりにEditor上で再生した時にuGUIの操作が効かなくなってしまう問題があります。そこで今回は、**Editorで再生した時のみ**uGUIを通常のEventSystemに置き換える方法を紹介したいと思います。

# 環境

- Unity 2019.1.9f1
- Oculus Integration for Unity 1.39.0
- Mac OSX 10.14.6（18G87）
- Oculus Go (実機で影響がないことを確認)

# アプローチ

`[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]`を使います。これはゲーム開始時にメソッドが呼び出されるようにするアトリビュートで、シーン上に配置しなくても実行される機能を持ちます。これを付けたスクリプトを`Editor`以下に配置することで、Editor上でのみ呼び出されるデバッグ機能を実現できます。注意としては、プロジェクトにインポートされているだけでどのシーンからでも必ず呼び出されてしまうのでお気をつけください。

参考: [【Unity】ゲームの起動後 Awakeより前にメソッドを実行する - テラシュールブログ](http://tsubakit1.hateblo.jp/entry/2016/07/29/073000)

では実際にEditor上で操作できる形に置き換えていくわけですが、具体的には以下の差分があります。

|アタッチ場所|通常|Oculus Integration|
|---|---|---|
|EventSystem|StandaloneInputModule|OVRInputModule|
|Canvas|GraphicRaycaster|OVRRaycaster|

これをランタイム上で置き換えていきます。

まず判定条件として、VR用のシーンであるかどうかを判断するため`OVRCameraRig`の有無を確認します。

```cs
// VR用シーンでなさそうならreturn
if (GameObject.FindObjectOfType<OVRCameraRig>() == null) { return; }
```

次にEventSytemを置き換えます。

1. `EventSystem`を検索
2. 同じGameObjectについている`OVRInputModule`を無効化
3. 同じGameObjectに対して`StandaloneInputModule`をアタッチ

```cs
// OVRInputModuleを無効 かつ StandaloneInputModuleを有効に
var eventSystem = GameObject.FindObjectOfType<EventSystem>();
if (eventSystem.GetComponent<StandaloneInputModule>() == null)
{
    eventSystem.GetComponent<OVRInputModule>().enabled = false;
    eventSystem.gameObject.AddComponent<StandaloneInputModule>();
    Debug.Log("変換成功: OVRInputModule -> StandaloneInputModule");
}
```

最後に各Canvasに`GraphicRaycaster`を付けていきます。`Find~`系メソッドでは非アクティブなコンポーネントなどを習得できない場合があるため、`Resources.FindObjectsOfTypeAll()`を使って検索をします。Linqを使ってシーン上のものだけに絞り込みます。

```cs
// Project中の全Canvasコンポーネントの中からAssets以下でないもの(=Hierarchy上のもの)を全て習得
var canvases = Resources.FindObjectsOfTypeAll<Canvas>()
.Where(c => AssetDatabase.GetAssetOrScenePath(c).Contains(".unity")).ToArray();
```

検索したCanvasに`GraphicRaycaster`が付いていれば有効に、なければ追加します。ポイントは`raycaster`の型比較で、`GetComponent<GraphicRaycaster>()`では`OVRRaycaster`も習得できてしまうため、継承された型でないことを確認する必要がありました。`raycaster.GetType() == typeof(GraphicRaycaster)`とすれば大丈夫です。

```cs
// GraphicRaycasterがあれば有効に、なければ追加
// OVRRaycasterは競合しないので特にdisableにしていない
foreach (var canvas in canvases)
{
    var raycasters = canvas.gameObject.GetComponents<GraphicRaycaster>().ToList();
    if (raycasters.Exists(r => r.GetType() == typeof(GraphicRaycaster)))
    {
        raycasters.ForEach(r => r.enabled = true);
    }
    else
    {
        canvas.gameObject.AddComponent<GraphicRaycaster>();
        Debug.Log($"変換成功: GraphicRaycaster added to {canvas.name}");
    }
}
```


コメントにもありますが、`OVRRaycaster`は`GraphicRaycaster`と競合しないことを確認したので特に無効にする操作はしていません。


## 2019.09.17追記: `SceneManager.sceneLoaded`でシーン毎の呼び出しの追加

`[RuntimeInitializeOnLoadMethod]`だけだと実行一回につき1度しか再生されないため、`SceneManager.sceneLoaded += OnSceneLoaded`を追加しました。これにより新たなシーンが読み込まれる度に実行されるようになりました。初期シーンのみは今までと同じように直接実行する形です。

```cs
[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
static void Init()
{
    Replace();
    SceneManager.sceneLoaded += OnSceneLoaded;
}
static void OnSceneLoaded(Scene scene, LoadSceneMode mode)
{
    Replace();
}
```

## 2019.11.05追記: asyncで監視する仕組みの追加

`SceneManager.sceneLoaded += OnSceneLoaded`ではシーン中で動的に追加されるCanvasに対応できないため、asyncで監視する実装を追加しました。コメントアウトで方式を切り替える使い方を想定しています。

```cs
[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
static void Init()
{
    Replace();

    // [①/②]のどちらかをコメントアウトして使ってください

    // ① 毎秒監視したい場合
    ReplaceAsync();

    // ② シーン初期値のみの呼び出しで良い場合
    // SceneManager.sceneLoaded += OnSceneLoaded;
}
```

監視用メソッドはこんな感じで、実行中のみ1秒間に1度変換メソッドを呼び出しています。また、これに伴いメソッドの分割も行いました。

``` .cs
/// <summary> 非同期でシーン上を監視する変換メソッド </summary>
static async Task ReplaceAsync()
{
    // アプリが実行中のみループ
    while (Application.isPlaying)
    {
        ReplaceEventSystem();

        // 1秒に1回実行する
        await Task.Delay(1000);
    }
}
```

# 導入方法

以下のスクリプトを`Editor`以下に入れてください。

Gist: [ReplaceEventSystems.cs](https://gist.github.com/nkjzm/628fb02260bc60597584679beafb2c5e)

```cs:ReplaceEventSystems.cs
using System.Linq;
using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

/// <summary>
/// エディタ上でのアプリ起動時に自動実行されるデバッグ用スクリプト
/// VRアプリ向けになっているEventSystemをEditor上からも操作できる形に組み替える
/// </summary>
public class ReplaceEventSystems
{
    const float InitialHeight = 1.6f;

    /// <summary> 初期化メソッド </summary>

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    static void Init()
    {
        // VR用シーンでなさそうならreturn
        if (GameObject.FindObjectOfType<OVRCameraRig>() == null) { return; }

        Replace();

        // [①/②]のどちらかをコメントアウトして使ってください

        // ① 毎秒監視したい場合
        ReplaceAsync();

        // ② シーン初期値のみの呼び出しで良い場合
        // SceneManager.sceneLoaded += OnSceneLoaded;
    }

    /// <summary> シーン読み込み完了時に呼び出されるメソッド </summary>
    static void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        Replace();
    }

    /// <summary> シーン上のVR向け設定を変換するメソッド </summary>
    static void Replace()
    {
        // カメラ位置の調整
        var ovrManager = GameObject.FindObjectOfType<OVRManager>();
        if (ovrManager != null && ovrManager.trackingOriginType == OVRManager.TrackingOrigin.FloorLevel)
        {
            Camera.main.transform.position += Vector3.up * InitialHeight;
        }
        // カメラにキーボード操作用コンポーネントを追加(必要なければ消してください)
        // Camera.main.gameObject.AddComponent<EditorCamera>();

        ReplaceEventSystem();
    }

    /// <summary> EventSystemに関するシーン上のVR向け設定を変換するメソッド </summary>
    static void ReplaceEventSystem()
    {
        // OVRInputModuleを無効 かつ StandaloneInputModuleを有効に
        var eventSystem = GameObject.FindObjectOfType<EventSystem>();
        if (eventSystem.GetComponent<StandaloneInputModule>() == null)
        {
            eventSystem.GetComponent<OVRInputModule>().enabled = false;
            eventSystem.gameObject.AddComponent<StandaloneInputModule>();
            Debug.Log("変換成功: OVRInputModule -> StandaloneInputModule");
        }

        // Project中の全Canvasコンポーネントの中からAssets以下でないもの(=Hierarchy上のもの)を全て習得
        var canvases = Resources.FindObjectsOfTypeAll<Canvas>()
        .Where(c => AssetDatabase.GetAssetOrScenePath(c).Contains(".unity")).ToArray();
        // GraphicRaycasterがあれば有効に、なければ追加
        // OVRRaycasterは競合しないので特にdisableにしていない
        foreach (var canvas in canvases)
        {
            var raycasters = canvas.gameObject.GetComponents<GraphicRaycaster>().ToList();
            if (raycasters.Exists(r => r.GetType() == typeof(GraphicRaycaster)))
            {
                raycasters.ForEach(r => r.enabled = true);
            }
            else
            {
                canvas.gameObject.AddComponent<GraphicRaycaster>();
                Debug.Log($"変換成功: GraphicRaycaster added to {canvas.name}");
            }
        }
    }

    /// <summary> 非同期でシーン上を監視する変換メソッド </summary>
    static async Task ReplaceAsync()
    {
        // アプリが実行中のみループ
        while (Application.isPlaying)
        {
            ReplaceEventSystem();

            // 1秒に1回実行する
            await Task.Delay(1000);
        }
    }
}
```


`EditorCamera.cs`はGameビュー上で視点をキーボード操作するためのスクリプトです。必要なら入れてください。MonoBehabiourを継承しているため、`Editor`以下に入れると動作しません。

Gist: [EditorCamera.cs](https://gist.github.com/nkjzm/c7a4c645f20593a5ce38bc91776cbeb0)

```cs:EditorCamera.cs
using UnityEngine;

/// <summary>
/// Editor上でCameraをキーボード操作するための
/// </summary>
public class EditorCamera : MonoBehaviour
{
    const float Angle = 30f;
    const float Speed = 0.25f;

    bool IsShift { get { return Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift); } }
    bool shouldRotateLeft { get { return !IsShift && (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.A)); } }
    bool shouldRotateRight { get { return !IsShift && (Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.D)); } }
    bool shouldMoveforwad { get { return !IsShift && (Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.W)); } }
    bool shouldMoveBack { get { return !IsShift && (Input.GetKeyDown(KeyCode.DownArrow) || Input.GetKeyDown(KeyCode.S)); } }
    bool shouldMoveLeft { get { return IsShift && (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.A)); } }
    bool shouldMoveRight { get { return IsShift && (Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.D)); } }
    bool shouldMoveUp { get { return IsShift && (Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.W)); } }
    bool shouldMoveDown { get { return IsShift && (Input.GetKeyDown(KeyCode.DownArrow) || Input.GetKeyDown(KeyCode.S)); } }

    void Update()
    {
        // [←|A]キーで左回転
        if (shouldRotateLeft) { transform.Rotate(0, -Angle, 0); }
        // [→|D]キーで右回転
        if (shouldRotateRight) { transform.Rotate(0, Angle, 0); }
        // [↑|W]キーで前方移動
        if (shouldMoveforwad) { transform.position += transform.forward.normalized * Speed; }
        // [↓|S]キーで後方移動
        if (shouldMoveBack) { transform.position -= transform.forward.normalized * Speed; }
        // [Shift+(←|A)]キーで左方移動
        if (shouldMoveLeft) { transform.position -= transform.right.normalized * Speed; }
        // [Shift+(→|D)]キーで右方移動
        if (shouldMoveRight) { transform.position += transform.right.normalized * Speed; }
        // [Shift+(↑|W)]キーで上方移動
        if (shouldMoveUp) { transform.position += transform.up.normalized * Speed; }
        // [Shift+(↓|S)]キーで下方移動
        if (shouldMoveDown) { transform.position -= transform.up.normalized * Speed; }
    }
}
```

# 最後に

これで実機ビルドに影響を出さず、Editor上でも快適にuGUIのデバッグができるようになりました。

逆にOculus Go開発されている方ってどうしてるんでしょうか？ もし他の良いやり方があれば是非教えてほしいです🙏


