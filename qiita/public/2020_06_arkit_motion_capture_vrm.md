---
title: ARKit 3のMotion CaptureでVRMを動かす【Unity】
tags:
  - Unity
  - VR
private: false
updated_at: '2025-10-06T21:48:16+09:00'
id: d4379d5fd018de67a082
organization_url_name: null
slide: false
ignorePublish: false
---
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
# はじめに

この記事は[VTuber Tech #1 Advent Calendar 2019](https://qiita.com/advent-calendar/2019/vtuber) 1日目の記事です。

さて、iOSのARKit 3でMotion Captureの機能が追加されました。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">ARKit 3 Motion Captureを、ネイティブの公式サンプルとUnity ARFundationのサンプルで比較してみた。<br><br>体幹では大体同じくらいの精度が出ている気がする。あと横向きだと画面外でも認識する範囲がでかい。 <a href="https://t.co/zRlrgWgNSl">pic.twitter.com/zRlrgWgNSl</a></p>&mdash; なかじ / リリカちゃん (@nkjzm) <a href="https://twitter.com/nkjzm/status/1200988393414389760?ref_src=twsrc%5Etfw">December 1, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

UnityではARを扱うためのフリームワークである[AR Foundation](https://unity.com/ja/unity/features/arfoundation)でARKit 3の機能が使えるということで、早速試してみました。今回はVRM形式のウチの子『[リリカちゃん](https://hub.vroid.com/characters/6874596705216592350)』をARKit 3を使って動かして行こうと思います。

## 環境

- macOS Catalina (10.15)
- iOS 13.1.3
- Unity 2020.1.0a14.1541
- [Unity-Technologies/arfoundation-samples](https://github.com/Unity-Technologies/arfoundation-samples)
    - [2019.12.01時点の最新masterブランチ](https://github.com/Unity-Technologies/arfoundation-samples/commit/08ea9e8f9dc010012ddeb836b8b1dae7cdd380bf)
- [vrm-c/UniVRM v0.53.0](https://github.com/vrm-c/UniVRM/releases/tag/v0.53.0)

ARKitにはいくつかの制約があり、Motion Captureを含む以下の機能の使用にはA12チップを搭載したデバイスである必要があります。つまりiPhone XS/XR以降の端末でしか使えません。

- People Occlusion
- Motion capture
- フロントカメラ/バックカメラの同時使用
- 複数フェイストラッキング

> People Occlusion and the use of motion capture, simultaneous front and back camera, and multiple face tracking are supported on devices with A12/A12X Bionic chips, ANE, and TrueDepth Camera.

参考: [ARKit 3 - Augmented Reality - Apple Developer](https://developer.apple.com/augmented-reality/arkit/)

また、Motion Captureはバックカメラでしか動作しないようです。

> When ARKit identifies a person in the back camera feed, it calls session(_:didAdd:), passing you an ARBodyAnchor you can use to track the body's movement.

参考: [ARBodyTrackingConfiguration - ARKit | Apple Developer Documentation](https://developer.apple.com/documentation/arkit/arbodytrackingconfiguration)

また、AR Foundationについてもはまりどころがありました。

macOS CatalinaにおけるUnityの既知のバグで、iOS向けのビルドの描画がおかしくなる問題がありました。

[Can't launch ARCollaborationData iOS · Issue #325 · Unity-Technologies/arfoundation-samples](https://github.com/Unity-Technologies/arfoundation-samples/issues/325)

こちらで示されているIssue Trackerによると2020.1以降で修正済みということで、今回はα版ですがUnity 2020.1.0a14.1541を使って実装してみました。
https://issuetracker.unity3d.com/issues/ios


# アプローチ

[Unity-Technologies/arfoundation-samples](https://github.com/Unity-Technologies/arfoundation-samples)をベースに実装しました。

## 上手くいかなかった方法

読み飛ばしてもらって問題ないです。`m_HumanBodyManager.humanBodiesChanged`から取得できる関節情報を直接Humanoid方に流し込む方法を試しました。コードはこんな感じ。

```cs:HumanoidTracker.cs
// VRM生成部分は省略
public class HumanoidTracker : MonoBehaviour
{
    [SerializeField] ARHumanBodyManager m_HumanBodyManager;

    private Animator _animator;

    void OnEnable()
    {
        m_HumanBodyManager.humanBodiesChanged += OnHumanBodiesChanged;
    }

    void OnDisable()
    {
        if (m_HumanBodyManager != null)
        {
            m_HumanBodyManager.humanBodiesChanged -= OnHumanBodiesChanged;
        }
    }

    private void Update()
    {
        var origin = FindObjectOfType<BoneController>()?.GetComponent<Animator>();
        if (_animator == null || origin == null)
        {
            return;
        }

        var originalHandler = new HumanPoseHandler(origin.avatar, origin.transform);
        var targetHandler = new HumanPoseHandler(_animator.avatar, _animator.transform);

        HumanPose humanPose = new HumanPose();
        originalHandler.GetHumanPose(ref humanPose);
        targetHandler.SetHumanPose(ref humanPose);

        _animator.rootPosition = origin.rootPosition;
        _animator.rootRotation = origin.rootRotation;
    }

    void OnHumanBodiesChanged(ARHumanBodiesChangedEventArgs eventArgs)
    {
        if (_animator == null)
        {
            return;
        }

        foreach (var humanBody in eventArgs.updated)
        {
            SetHumanBoneTransformToHumanoidPoses(humanBody);
        }
    }

    void SetHumanBoneTransformToHumanoidPoses(ARHumanBody body)
    {
        if (!body.joints.IsCreated)
        {
            return;
        }

        var bones = Enum.GetValues(typeof(HumanBodyBones)) as HumanBodyBones[];
        foreach (HumanBodyBones bone in bones)
        {
            if (bone < 0 || bone >= HumanBodyBones.LastBone)
            {
                continue;
            }

            var joint = HumanoidUtils.GetXRHumanBodyJoint(body, bone);
            Transform t = _animator.GetBoneTransform(bone);
            if (t != null)
            {
                t.localPosition = joint.localPose.position;
                t.localRotation = joint.localPose.rotation;
            }
        }
    }
}
```

前半はほぼサンプルコードそのままで、注目して欲しいのは後半の`SetHumanBoneTransformToHumanoidPoses`メソッドです。Unity標準Humanoidアバターのボーン構造である`HumanBodyBones`を`foreach`で回して、ジョイントの値を取得しています。

```cs
void SetHumanBoneTransformToHumanoidPoses(ARHumanBody body)
{
    if (!body.joints.IsCreated)
    {
        return;
    }

    var bones = Enum.GetValues(typeof(HumanBodyBones)) as HumanBodyBones[];
    foreach (HumanBodyBones bone in bones)
    {
        if (bone < 0 || bone >= HumanBodyBones.LastBone)
        {
            continue;
        }

        var joint = HumanoidUtils.GetXRHumanBodyJoint(body, bone);
        Transform t = _animator.GetBoneTransform(bone);
        if (t != null)
        {
            t.localPosition = joint.localPose.position;
            t.localRotation = joint.localPose.rotation;
        }
    }
}
```

ARKit 3で取得できるジョイントは約90関節で、対するHumanoid型は訳54関節なので、対応付けをする必要があります。エディタ上で比較しながら対応させるメソッドを書きました。

```cs:HumanoidUtils.cs
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public static class HumanoidUtils
{
    // 3D joint skeleton
    enum JointIndices
    {
        Invalid = -1,
        Root = 0, // parent: <none> [-1]
        Hips = 1, // parent: Root [0]
        LeftUpLeg = 2, // parent: Hips [1]
        LeftLeg = 3, // parent: LeftUpLeg [2]
        LeftFoot = 4, // parent: LeftLeg [3]
        LeftToes = 5, // parent: LeftFoot [4]
        LeftToesEnd = 6, // parent: LeftToes [5]
        RightUpLeg = 7, // parent: Hips [1]
        RightLeg = 8, // parent: RightUpLeg [7]
        RightFoot = 9, // parent: RightLeg [8]
        RightToes = 10, // parent: RightFoot [9]
        RightToesEnd = 11, // parent: RightToes [10]
        Spine1 = 12, // parent: Hips [1]
        Spine2 = 13, // parent: Spine1 [12]
        Spine3 = 14, // parent: Spine2 [13]
        Spine4 = 15, // parent: Spine3 [14]
        Spine5 = 16, // parent: Spine4 [15]
        Spine6 = 17, // parent: Spine5 [16]
        Spine7 = 18, // parent: Spine6 [17]
        LeftShoulder1 = 19, // parent: Spine7 [18]
        LeftArm = 20, // parent: LeftShoulder1 [19]
        LeftForearm = 21, // parent: LeftArm [20]
        LeftHand = 22, // parent: LeftForearm [21]
        LeftHandIndexStart = 23, // parent: LeftHand [22]
        LeftHandIndex1 = 24, // parent: LeftHandIndexStart [23]
        LeftHandIndex2 = 25, // parent: LeftHandIndex1 [24]
        LeftHandIndex3 = 26, // parent: LeftHandIndex2 [25]
        LeftHandIndexEnd = 27, // parent: LeftHandIndex3 [26]
        LeftHandMidStart = 28, // parent: LeftHand [22]
        LeftHandMid1 = 29, // parent: LeftHandMidStart [28]
        LeftHandMid2 = 30, // parent: LeftHandMid1 [29]
        LeftHandMid3 = 31, // parent: LeftHandMid2 [30]
        LeftHandMidEnd = 32, // parent: LeftHandMid3 [31]
        LeftHandPinkyStart = 33, // parent: LeftHand [22]
        LeftHandPinky1 = 34, // parent: LeftHandPinkyStart [33]
        LeftHandPinky2 = 35, // parent: LeftHandPinky1 [34]
        LeftHandPinky3 = 36, // parent: LeftHandPinky2 [35]
        LeftHandPinkyEnd = 37, // parent: LeftHandPinky3 [36]
        LeftHandRingStart = 38, // parent: LeftHand [22]
        LeftHandRing1 = 39, // parent: LeftHandRingStart [38]
        LeftHandRing2 = 40, // parent: LeftHandRing1 [39]
        LeftHandRing3 = 41, // parent: LeftHandRing2 [40]
        LeftHandRingEnd = 42, // parent: LeftHandRing3 [41]
        LeftHandThumbStart = 43, // parent: LeftHand [22]
        LeftHandThumb1 = 44, // parent: LeftHandThumbStart [43]
        LeftHandThumb2 = 45, // parent: LeftHandThumb1 [44]
        LeftHandThumbEnd = 46, // parent: LeftHandThumb2 [45]
        Neck1 = 47, // parent: Spine7 [18]
        Neck2 = 48, // parent: Neck1 [47]
        Neck3 = 49, // parent: Neck2 [48]
        Neck4 = 50, // parent: Neck3 [49]
        Head = 51, // parent: Neck4 [50]
        Jaw = 52, // parent: Head [51]
        Chin = 53, // parent: Jaw [52]
        LeftEye = 54, // parent: Head [51]
        LeftEyeLowerLid = 55, // parent: LeftEye [54]
        LeftEyeUpperLid = 56, // parent: LeftEye [54]
        LeftEyeball = 57, // parent: LeftEye [54]
        Nose = 58, // parent: Head [51]
        RightEye = 59, // parent: Head [51]
        RightEyeLowerLid = 60, // parent: RightEye [59]
        RightEyeUpperLid = 61, // parent: RightEye [59]
        RightEyeball = 62, // parent: RightEye [59]
        RightShoulder1 = 63, // parent: Spine7 [18]
        RightArm = 64, // parent: RightShoulder1 [63]
        RightForearm = 65, // parent: RightArm [64]
        RightHand = 66, // parent: RightForearm [65]
        RightHandIndexStart = 67, // parent: RightHand [66]
        RightHandIndex1 = 68, // parent: RightHandIndexStart [67]
        RightHandIndex2 = 69, // parent: RightHandIndex1 [68]
        RightHandIndex3 = 70, // parent: RightHandIndex2 [69]
        RightHandIndexEnd = 71, // parent: RightHandIndex3 [70]
        RightHandMidStart = 72, // parent: RightHand [66]
        RightHandMid1 = 73, // parent: RightHandMidStart [72]
        RightHandMid2 = 74, // parent: RightHandMid1 [73]
        RightHandMid3 = 75, // parent: RightHandMid2 [74]
        RightHandMidEnd = 76, // parent: RightHandMid3 [75]
        RightHandPinkyStart = 77, // parent: RightHand [66]
        RightHandPinky1 = 78, // parent: RightHandPinkyStart [77]
        RightHandPinky2 = 79, // parent: RightHandPinky1 [78]
        RightHandPinky3 = 80, // parent: RightHandPinky2 [79]
        RightHandPinkyEnd = 81, // parent: RightHandPinky3 [80]
        RightHandRingStart = 82, // parent: RightHand [66]
        RightHandRing1 = 83, // parent: RightHandRingStart [82]
        RightHandRing2 = 84, // parent: RightHandRing1 [83]
        RightHandRing3 = 85, // parent: RightHandRing2 [84]
        RightHandRingEnd = 86, // parent: RightHandRing3 [85]
        RightHandThumbStart = 87, // parent: RightHand [66]
        RightHandThumb1 = 88, // parent: RightHandThumbStart [87]
        RightHandThumb2 = 89, // parent: RightHandThumb1 [88]
        RightHandThumbEnd = 90, // parent: RightHandThumb2 [89]
    }

    public static XRHumanBodyJoint GetXRHumanBodyJoint(ARHumanBody body, HumanBodyBones bone)
    {
        switch (bone)
        {
            case HumanBodyBones.Hips:
                return body.joints[(int)JointIndices.Hips];
            case HumanBodyBones.LeftUpperLeg:
                return body.joints[(int)JointIndices.LeftUpLeg];
            case HumanBodyBones.RightUpperLeg:
                return body.joints[(int)JointIndices.RightUpLeg];
            case HumanBodyBones.LeftLowerLeg:
                return body.joints[(int)JointIndices.LeftLeg];
            case HumanBodyBones.RightLowerLeg:
                return body.joints[(int)JointIndices.RightLeg];
            case HumanBodyBones.LeftFoot:
                return body.joints[(int)JointIndices.LeftFoot];
            case HumanBodyBones.RightFoot:
                return body.joints[(int)JointIndices.RightFoot];
            case HumanBodyBones.Spine:
                return body.joints[(int)JointIndices.Spine1];
            case HumanBodyBones.Chest:
                return body.joints[(int)JointIndices.Spine6];
            case HumanBodyBones.UpperChest:
                return body.joints[(int)JointIndices.Spine7];
            case HumanBodyBones.Neck:
                return body.joints[(int)JointIndices.Neck1];
            case HumanBodyBones.Head:
                return body.joints[(int)JointIndices.Head];
            case HumanBodyBones.LeftShoulder:
                return body.joints[(int)JointIndices.LeftShoulder1];
            case HumanBodyBones.RightShoulder:
                return body.joints[(int)JointIndices.RightShoulder1];
            case HumanBodyBones.LeftUpperArm:
                return body.joints[(int)JointIndices.LeftArm];
            case HumanBodyBones.RightUpperArm:
                return body.joints[(int)JointIndices.RightArm];
            case HumanBodyBones.LeftLowerArm:
                return body.joints[(int)JointIndices.LeftForearm];
            case HumanBodyBones.RightLowerArm:
                return body.joints[(int)JointIndices.RightForearm];
            case HumanBodyBones.LeftHand:
                return body.joints[(int)JointIndices.LeftHand];
            case HumanBodyBones.RightHand:
                return body.joints[(int)JointIndices.RightHand];
            case HumanBodyBones.LeftToes:
                return body.joints[(int)JointIndices.LeftToes];
            case HumanBodyBones.RightToes:
                return body.joints[(int)JointIndices.RightToes];
            case HumanBodyBones.LeftEye:
                return body.joints[(int)JointIndices.LeftEye];
            case HumanBodyBones.RightEye:
                return body.joints[(int)JointIndices.RightEye];
            case HumanBodyBones.Jaw:
                return body.joints[(int)JointIndices.Jaw];
            case HumanBodyBones.LeftThumbProximal:
                return body.joints[(int)JointIndices.LeftHandThumbStart];
            case HumanBodyBones.LeftThumbIntermediate:
                return body.joints[(int)JointIndices.LeftHandThumb1];
            case HumanBodyBones.LeftThumbDistal:
                return body.joints[(int)JointIndices.LeftHandThumb2];
            case HumanBodyBones.LeftIndexProximal:
                return body.joints[(int)JointIndices.LeftHandIndex1];
            case HumanBodyBones.LeftIndexIntermediate:
                return body.joints[(int)JointIndices.LeftHandIndex2];
            case HumanBodyBones.LeftIndexDistal:
                return body.joints[(int)JointIndices.LeftHandIndex3];
            case HumanBodyBones.LeftMiddleProximal:
                return body.joints[(int)JointIndices.LeftHandMid1];
            case HumanBodyBones.LeftMiddleIntermediate:
                return body.joints[(int)JointIndices.LeftHandMid2];
            case HumanBodyBones.LeftMiddleDistal:
                return body.joints[(int)JointIndices.LeftHandMid3];
            case HumanBodyBones.LeftRingProximal:
                return body.joints[(int)JointIndices.LeftHandRing1];
            case HumanBodyBones.LeftRingIntermediate:
                return body.joints[(int)JointIndices.LeftHandRing2];
            case HumanBodyBones.LeftRingDistal:
                return body.joints[(int)JointIndices.LeftHandRing3];
            case HumanBodyBones.LeftLittleProximal:
                return body.joints[(int)JointIndices.LeftHandPinky1];
            case HumanBodyBones.LeftLittleIntermediate:
                return body.joints[(int)JointIndices.LeftHandPinky2];
            case HumanBodyBones.LeftLittleDistal:
                return body.joints[(int)JointIndices.LeftHandPinky3];
            case HumanBodyBones.RightThumbProximal:
                return body.joints[(int)JointIndices.RightHandThumbStart];
            case HumanBodyBones.RightThumbIntermediate:
                return body.joints[(int)JointIndices.RightHandThumb1];
            case HumanBodyBones.RightThumbDistal:
                return body.joints[(int)JointIndices.RightHandThumb2];
            case HumanBodyBones.RightIndexProximal:
                return body.joints[(int)JointIndices.RightHandIndex1];
            case HumanBodyBones.RightIndexIntermediate:
                return body.joints[(int)JointIndices.RightHandIndex2];
            case HumanBodyBones.RightIndexDistal:
                return body.joints[(int)JointIndices.RightHandIndex3];
            case HumanBodyBones.RightMiddleProximal:
                return body.joints[(int)JointIndices.RightHandMid1];
            case HumanBodyBones.RightMiddleIntermediate:
                return body.joints[(int)JointIndices.RightHandMid2];
            case HumanBodyBones.RightMiddleDistal:
                return body.joints[(int)JointIndices.RightHandMid3];
            case HumanBodyBones.RightRingProximal:
                return body.joints[(int)JointIndices.RightHandRing1];
            case HumanBodyBones.RightRingIntermediate:
                return body.joints[(int)JointIndices.RightHandRing2];
            case HumanBodyBones.RightRingDistal:
                return body.joints[(int)JointIndices.RightHandRing3];
            case HumanBodyBones.RightLittleProximal:
                return body.joints[(int)JointIndices.RightHandPinky1];
            case HumanBodyBones.RightLittleIntermediate:
                return body.joints[(int)JointIndices.RightHandPinky2];
            case HumanBodyBones.RightLittleDistal:
                return body.joints[(int)JointIndices.RightHandPinky3];
            default:
                return body.joints[(int)JointIndices.Invalid];
        }
    }
}
```

これを動かした結果がこれ。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">ARKit 3のモーションキャプチャデータをVRMに流し込んだ結果です😇 <a href="https://t.co/97fe6oMYqZ">pic.twitter.com/97fe6oMYqZ</a></p>&mdash; なかじ / リリカちゃん (@nkjzm) <a href="https://twitter.com/nkjzm/status/1201101156094640128?ref_src=twsrc%5Etfw">December 1, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

原因はよく考えたら当たり前で、サンプルに含まれているモデルと、使用したVRMのボーン構造が異なるからです。Animatorで用いるリグ構造は親のボーンを基準として相対姿勢で表現するため、異なるボーン構造のモデルには適用できません。`XRHumanBodyJoint`で取得できる値には、親ボーンからの相対姿勢を取得する`LocalPose`の他に、ルートボーンからの相対姿勢を表す`AnchorPose`があるのすが、こちらも各関節の角度が一致しているモデルでないと使用できません。ただし、その差分を計測できれば可能性はありそうでした。

しかし、Issueによるとこの値はARKit 3の生の値ではないらしいです。そのため頑張って対応しても今後変更される可能性があり、あまり分が良い方法ではなさそうです。

参考: [Example Rig for 3D Human Skeleton - Unity Forum](https://forum.unity.com/threads/example-rig-for-3d-human-skeleton.696512/)

そこで、次の方法を試しました。

## 上手く行った方法

ほぼこのツイートの通りにしたら上手くいきました。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">AR FoundationのHuman Body Trackingを標準のスケルトンじゃなくて任意のHumanoidモデルに適用するヤツできた。結局標準のスケルトンがHumanoidじゃないのが問題なので、一旦FbxExporterでFBXにしてHumanoid Rigにして、Humanoidになったスケルトンから任意のモデルにHumanPoseを毎フレコピーすればOK</p>&mdash; 海行プログラム (@kaigyoPG) <a href="https://twitter.com/kaigyoPG/status/1179642078600392709?ref_src=twsrc%5Etfw">October 3, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

具体的には

1. Package Managerで「FBX Exporter」をInstall
2. `Assets/Prefabs/Robot/ControlledRobot.prefab`の上で右クリック
3. `Convert To FBX Linked Prefab`を選択肢、Convertする
4. 出力されたfbxを選択
5. インスペクターでRigタブに切り替え、`Animation Type`を`Humanoid`に変更
6. Configureを選択
7. 大体いい感じに自動で設定してくれているが、数カ所おかしいので以下のように修正(Hierarchy Viewからドラッグアンドドロップで設定しないと親がおかしいと怒られた)
  <img width="519" alt="スクリーンショット 2019-12-02 0.07.44.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/8f8d9cf0-c8a8-d502-16c2-5d93fc976123.png">
  <img width="517" alt="スクリーンショット 2019-12-02 0.07.49.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/73923002-1d53-82eb-8d6f-3d9904f1178b.png">
  <img width="518" alt="スクリーンショット 2019-12-02 0.07.55.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/71b41fc1-abdb-2d1b-93db-d303fe9ff79d.png">
7. Applyして終了
8. プレハブして`BoneController`をアタッチ
9. `Human Body Tracking`の`Skelton Prefab`に上記プレハブを設定
10. 以下のスクリプトをアタッチして完成

```cs:HumanoidTracker.cs
using System.IO;
using UnityEngine;
using VRM;

public class HumanoidTracker : MonoBehaviour
{
    private Animator _animator;

    private void Start()
    {
        ImportVRMAsync();
    }

    private void Update()
    {
        var origin = FindObjectOfType<BoneController>()?.GetComponent<Animator>();
        if (_animator == null || origin == null)
        {
            return;
        }

        var originalHandler = new HumanPoseHandler(origin.avatar, origin.transform);
        var targetHandler = new HumanPoseHandler(_animator.avatar, _animator.transform);

        HumanPose humanPose = new HumanPose();
        originalHandler.GetHumanPose(ref humanPose);
        targetHandler.SetHumanPose(ref humanPose);

        _animator.rootPosition = origin.rootPosition;
        _animator.rootRotation = origin.rootRotation;
    }

    private void ImportVRMAsync()
    {
        //VRMファイルのパスを指定します
        var path = $"{Application.streamingAssetsPath}/lyrica_chloma.vrm";

        //ファイルをByte配列に読み込みます
        var bytes = File.ReadAllBytes(path);

        //VRMImporterContextがVRMを読み込む機能を提供します
        var context = new VRMImporterContext();

        // GLB形式でJSONを取得しParseします
        context.ParseGlb(bytes);

        // VRMのメタデータを取得
        var meta = context.ReadMeta(false); //引数をTrueに変えるとサムネイルも読み込みます

        //読み込めたかどうかログにモデル名を出力してみる
        Debug.LogFormat("meta: title:{0}", meta.Title);

        //非同期処理で読み込みます
        context.LoadAsync(_ => OnLoaded(context));
    }

    private void OnLoaded(VRMImporterContext context)
    {
        //読込が完了するとcontext.RootにモデルのGameObjectが入っています
        var root = context.Root;

        _animator = root.GetComponent<Animator>();
        root.transform.position = new Vector3(0, -1, 1);
        root.transform.rotation = Quaternion.Euler(0, 180f, 0);
        _animator.applyRootMotion = true;

        //メッシュを表示します
        context.ShowMeshes();
    }
}
```

参考: [UniVRMを使ってVRMモデルをランタイムロードする方法](https://qiita.com/sh_akira/items/8155e4b69107c2a7ede6)

やっていることはさっきよりシンプルです。サンプルに含まれているモデルをHumanoid型として扱えるようになったので、Humanoid型としてVRMに値を流し込んでいます。その際に`HumanPoseHandler`を経由する必要がある点に注意してください。

```cs
private void Update()
{
    var origin = FindObjectOfType<BoneController>()?.GetComponent<Animator>();
    if (_animator == null || origin == null)
    {
        return;
    }

    var originalHandler = new HumanPoseHandler(origin.avatar, origin.transform);
    var targetHandler = new HumanPoseHandler(_animator.avatar, _animator.transform);

    HumanPose humanPose = new HumanPose();
    originalHandler.GetHumanPose(ref humanPose);
    targetHandler.SetHumanPose(ref humanPose);

    _animator.rootPosition = origin.rootPosition;
    _animator.rootRotation = origin.rootRotation;
}
```

参考: [ランタイムでAvatarを生成してアニメーションに利用する - e.blog](http://edom18.hateblo.jp/entry/2017/12/09/105126)

上記の実装をした結果がこんな感じです。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">iOSのARKit 3を使うと、自分のアバターに「踊ってみた動画」を振りコピしてもらうこともできる。すごくない……？？？？<br><br>動画: <a href="https://t.co/bsL7mOw5rN">https://t.co/bsL7mOw5rN</a> <a href="https://twitter.com/hashtag/ARKit?src=hash&amp;ref_src=twsrc%5Etfw">#ARKit</a> <a href="https://twitter.com/hashtag/VRoid?src=hash&amp;ref_src=twsrc%5Etfw">#VRoid</a> <a href="https://t.co/QOZimglSNK">pic.twitter.com/QOZimglSNK</a></p>&mdash; なかじ / リリカちゃん (@nkjzm) <a href="https://twitter.com/nkjzm/status/1201139983446200321?ref_src=twsrc%5Etfw">December 1, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

大分いい感じですね。ルート位置をロボットモデルと同じように変更する方法が分かってないので、わかる人がいたら教えて欲しいです。

## 最後に

いろいろ遠回りをしてしまいましたが、Humanoid型は異なる階層構造の人型モデルを同じように扱えることが分かりました。現状だと精度の面や使いやすさの面で難はありますが、デファクトの機能でモーキャプが簡単に扱えるのは面白いですね。

明日以降の[VTuber Tech #1 Advent Calendar 2019](https://qiita.com/advent-calendar/2019/vtuber)も是非お楽しみに！


