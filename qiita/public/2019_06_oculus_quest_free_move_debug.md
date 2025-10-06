---
title: Oculus  Questで空間を自由に移動するデバッグ用スクリプト
tags:
  - Unity
  - VR
  - OculusQuest
private: false
updated_at: '2019-06-18T04:46:48+09:00'
id: 72ff0406e02c1cc7075c
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

VR開発をしていると空間を制約なく自由に移動したい場合が出てくると思います。そういった時に使えるシンプルなデバッグ機能です。エディタ上でも動作します。

![Jun-17-2019 19-47-35.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/bca4f5b8-2eeb-cfb5-ab75-35885f72d2c8.gif)
“[Foggy](https://poly.google.com/view/6lvL96azx5v)” by [Maciek Krol](https://poly.google.com/user/7YToYXuoHjM) is licensed under CC-BY 3.0

Oculus Quest以外でも動作すると思いますが、未確認です。

# 環境

- Unity 2018.3.14f1
- Oculus Integration for Unity - 1.37
  - Oculus Utilities Plugin 1.32.0
- Mac OSX 10.14.4（18E226）

# 使い方

両手共通です。OVRCameraを子に含むオブジェクトに対してアタッチしてください(自身も含む)。

|Touchコントローラー|キーボード|機能|
|:--:|:--:|:--:|
|スティックを前後に倒す|W,Sキー|押している間だけ前進する|
|スティックを左右に倒す|A,Dキー|平行回転する(30度ずつ)|
|人差し指のトリガーを引く|Shiftキー|移動速度が5倍になる|
|中指のトリガーを引く|Alt(option)キー|移動速度が1/5倍になる|
|B,Yボタンを押す|Kキー|上に移動する(1m)|
|A,Xボタンを押す|Jキー|下に移動する(1m)|

# スクリプト

CC0です。(もちろん教えてくれると嬉しい)

Gistにもアップしてあります: [DebugMover.cs](https://gist.github.com/nkjzm/179f477a1de4949a2d08486caebdb55c)

```cs:DebugMover.cs
using UnityEngine;

public class DebugMover : MonoBehaviour
{
    [SerializeField]
    Transform Head = null;
    const float Angle = 30f;
    const float DashSpeed = 5f;
    const float SlowSpeed = 0.2f;

    void Reset()
    {
        Head = GetComponentInChildren<OVRCameraRig>().transform.Find("TrackingSpace/CenterEyeAnchor");
    }

    float Scale
    {
        get
        {
            return IsPressTrigger ? DashSpeed : IsPressGrip ? SlowSpeed : 1f;
        }
    }

    bool IsPressTrigger
    {
        get
        {
            return Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift)
            || OVRInput.Get(OVRInput.Button.PrimaryIndexTrigger) || OVRInput.Get(OVRInput.Button.SecondaryIndexTrigger);
        }
    }
    bool IsPressGrip
    {
        get
        {
            return Input.GetKey(KeyCode.LeftAlt) || Input.GetKey(KeyCode.LeftAlt)
            || OVRInput.Get(OVRInput.Button.PrimaryHandTrigger) || OVRInput.Get(OVRInput.Button.SecondaryHandTrigger);
        }
    }

    void Update()
    {
        // Forward move
        if (Input.GetKey(KeyCode.W) || OVRInput.Get(OVRInput.Button.PrimaryThumbstickUp) || OVRInput.Get(OVRInput.Button.SecondaryThumbstickUp))
        {
            var forward = Head.forward;
            forward.y = 0;
            transform.position += forward.normalized * Time.deltaTime * Scale;
        }
        // Back move
        if (Input.GetKey(KeyCode.S) || OVRInput.Get(OVRInput.Button.PrimaryThumbstickDown) || OVRInput.Get(OVRInput.Button.SecondaryThumbstickDown))
        {
            var forward = Head.forward;
            forward.y = 0;
            transform.position -= forward.normalized * Time.deltaTime * Scale;
        }
        // Left rotate
        if (Input.GetKeyDown(KeyCode.A) || OVRInput.GetDown(OVRInput.Button.PrimaryThumbstickLeft) || OVRInput.GetDown(OVRInput.Button.SecondaryThumbstickLeft))
        {
            transform.Rotate(0, -Angle, 0);
        }
        // Right rotate
        if (Input.GetKeyDown(KeyCode.D) || OVRInput.GetDown(OVRInput.Button.PrimaryThumbstickRight) || OVRInput.GetDown(OVRInput.Button.SecondaryThumbstickRight))
        {
            transform.Rotate(0, Angle, 0);
        }
        // Up move
        if (Input.GetKeyDown(KeyCode.K) || OVRInput.GetDown(OVRInput.Button.Four) || OVRInput.GetDown(OVRInput.Button.Two))
        {
            transform.position += Vector3.up * Scale;
        }
        // Down move
        if (Input.GetKeyDown(KeyCode.J) || OVRInput.GetDown(OVRInput.Button.Three) || OVRInput.GetDown(OVRInput.Button.One))
        {
            transform.position -= Vector3.up * Scale;
        }
    }
}
```

