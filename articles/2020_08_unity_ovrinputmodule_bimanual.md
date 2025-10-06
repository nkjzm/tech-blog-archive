---
title: "OVRInputModuleによるuGUI操作を両手に対応させる【Unity】"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "VR"]
published: true
---
# はじめに

![ugui.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/d34f4bcc-c903-5840-ddc5-02d4db12758d.gif)

Oculus環境でuGUIを操作する方法はありますが、両手で同時に操作するためにはスクリプトの修正が必要でした。今回はその方法を簡単にまとめます。

関連: [Oculus QuestでuGUIを操作する - Qiita](https://qiita.com/nkjzm/items/8a62cfab348eacff9167)

# 環境

- Unity 2019.4.3f1
- Oculus Integration 1.13.x（多分）
  - Oculus Utilities Plugin 1.45.0
- Windows 10 Home

少しバージョンが古い点にご注意ください。

# 手順

Oculusのライセンス的に全文貼るのは微妙そうなので、重要な部分だけ差分を書きます。

## OVRInputModule 

一方のコントローラーを使う前提の処理になっているので、コントローラー部分を一般化していきます。

```27-30行目.cs
        // 変更前
        [Tooltip("Object which points with Z axis. E.g. CentreEyeAnchor from OVRCameraRig")]
        public Transform rayTransform;

        // 変更後
        [Tooltip("Object which points with Z axis. E.g. CentreEyeAnchor from OVRCameraRig")]
        public Transform leftRayTransform, rightRayTransform;
        public OVRCursor m_leftCursor, m_rightCursor;
```

```27-30行目.cs
// 変更前
[Tooltip("Object which points with Z axis. E.g. CentreEyeAnchor from OVRCameraRig")]
public Transform rayTransform;

// 変更後
[Tooltip("Object which points with Z axis. E.g. CentreEyeAnchor from OVRCameraRig")]
public Transform leftRayTransform, rightRayTransform;
public OVRCursor m_leftCursor, m_rightCursor;
```

```477行目.cs
// 変更前
ProcessMouseEvent(GetGazePointerData());

// 変更後
ProcessMouseEvent(GetGazePointerData(leftRayTransform, m_leftCursor, OVRInput.Controller.LTouch));
ProcessMouseEvent(GetGazePointerData(rightRayTransform, m_rightCursor, OVRInput.Controller.RTouch));
```

```595行目.cs
// 変更前
virtual protected MouseState GetGazePointerData()

// 変更後
virtual protected MouseState GetGazePointerData(Transform rayTransform, OVRCursor cursor, OVRInput.Controller controller)
```

OVRInputはキーマッピング方式が複数あるため、同じように使えるために使用中のコントローラーを指定する方式に修正します。

参考: [Oculus Questコントローラーが持つ複数のキーマッピングについて - Qiita](https://qiita.com/nkjzm/items/96cd9cddc645c45dd5e5)

```857-860行目.cs
// 変更前
virtual protected PointerEventData.FramePressState GetGazeButtonState()
{
	var pressed = Input.GetKeyDown(gazeClickKey) || OVRInput.GetDown(joyPadClickButton);
	var released = Input.GetKeyUp(gazeClickKey) || OVRInput.GetUp(joyPadClickButton);

// 変更後
virtual protected PointerEventData.FramePressState GetGazeButtonState(OVRInput.Controller controller)
{
	var pressed = Input.GetKeyDown(gazeClickKey) || OVRInput.GetDown(joyPadClickButton, controller);
	var released = Input.GetKeyUp(gazeClickKey) || OVRInput.GetUp(joyPadClickButton, controller);
```

あと数か所コンパイルエラー出ると思うので、いい感じに直してください。

## HandedInputSelector.cs

アクティブなコントローラーに置き換える処理が書いてありましたが、全体的に不要なので以下に置き換えてください。

```変更後.cs
public class HandedInputSelector : MonoBehaviour
{
    OVRCameraRig m_CameraRig;
    [SerializeField] OVRInputModule m_InputModule;
    void Start()
    {
        m_CameraRig = FindObjectOfType<OVRCameraRig>();
        m_InputModule.leftRayTransform = m_CameraRig.leftHandAnchor;
        m_InputModule.rightRayTransform = m_CameraRig.rightHandAnchor;
    }
}
```

## Inspectorから設定

カーソルの参照を設定し直す必要があります。表示したい場合は両手分のカーソルを用意して同じように設定してみてください。

![adfasd.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/1eaf7d71-2419-5d37-8887-31e4d20ccd11.png)


# 最後に

宣伝ですが、 月額制のメンターサービスで初心者向けの開発サポートをしています。分からないことがあれば是非こちらで質問してください！　
https://menta.work/plan/1115






