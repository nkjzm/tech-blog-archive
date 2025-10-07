---
title: 【Unity】InputFieldの入力中に判定しない拡張Inputクラス(ExclusiveInput)
tags:
  - Unity
private: false
updated_at: '2019-02-11T17:28:00+09:00'
id: fc5a9587187a67e20cdf
organization_url_name: null
slide: false
ignorePublish: false
---
## 概要

`Input`クラスの`GetKeyDown`などはuGUIの`InputField`にテキストを入力中でも判定がされてしまいますが、多くの場合は意図しない入力だと思います。そこで、テキスト入力中には入力判定を返さない拡張クラスを作成しました。

gist: [ExclusiveInput.cs](https://gist.github.com/nkjzm/2ea6ec61c80ea1c06a6bb1b3016ce94f)

## 使い方

`Input`クラスの代わりに`ExclusiveInput`経由で`GetKeyDown`などを呼び出してください。

```cs
void Update()
{
    if (ExclusiveInput.GetKeyDown(KeyCode.A))
    {
        // hoge
    }
    if (ExclusiveInput.GetKeyDown("a"))
    {
        // hoge
    }
}
```

## 対応メソッド

- `bool anyKeyDown`
- `bool anyKey`
- `float GetAxis(string axisName)`
- `float GetAxisRaw(string axisName)`
- `bool GetKey(string name)`
- `bool GetKey(KeyCode key)`
- `bool GetKeyDown(string name)`
- `bool GetKeyDown(KeyCode key)`
- `bool GetKeyUp(KeyCode key)`
- `bool GetKeyUp(string name)`

必要であれば適宜追加してください。

## コード

`EventSystem`クラスで現在フォーカス中のゲームオブジェクトを取得することが出来ます。そこでそのオブジェクトが`InputField`であれば`true`を返す`IsFocusedOnInputField`を実装し、各入力メソッドの前で判定を入れています。

```
public static bool IsFocusedOnInputField
{
    get
    {
        return EventSystem.current?.currentSelectedGameObject?.GetComponent<InputField>() != null;
    }
}
```

コード全文はこちらです。(gist: [ExclusiveInput.cs](https://gist.github.com/nkjzm/2ea6ec61c80ea1c06a6bb1b3016ce94f))

```cs:ExclusiveInput.cs
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace UnityEngine
{
    public class ExclusiveInput
    {
        public static bool IsFocusedOnInputField
        {
            get
            {
                return EventSystem.current?.currentSelectedGameObject?.GetComponent<InputField>() != null;
            }
        }
        //
        // Summary:
        //     Returns true the first frame the user hits any key or mouse button. (Read Only)
        public static bool anyKeyDown
        {
            get
            {
                return !IsFocusedOnInputField && Input.anyKeyDown;
            }
        }
        //
        // Summary:
        //     Is any key or mouse button currently held down? (Read Only)
        public static bool anyKey
        {
            get
            {
                return !IsFocusedOnInputField && Input.anyKey;
            }
        }
        //
        // Summary:
        //     Returns the value of the virtual axis identified by axisName.
        //
        // Parameters:
        //   axisName:
        public static float GetAxis(string axisName)
        {
            return IsFocusedOnInputField ? 0 : Input.GetAxis(axisName);
        }
        //
        // Summary:
        //     Returns the value of the virtual axis identified by axisName with no smoothing
        //     filtering applied.
        //
        // Parameters:
        //   axisName:
        public static float GetAxisRaw(string axisName)
        {
            return IsFocusedOnInputField ? 0 : Input.GetAxisRaw(axisName);
        }
        //
        // Summary:
        //     Returns true while the user holds down the key identified by name.
        //
        // Parameters:
        //   name:
        public static bool GetKey(string name)
        {
            return !IsFocusedOnInputField && Input.GetKey(name);
        }
        //
        // Summary:
        //     Returns true while the user holds down the key identified by the key KeyCode
        //     enum parameter.
        //
        // Parameters:
        //   key:
        public static bool GetKey(KeyCode key)
        {
            return !IsFocusedOnInputField && Input.GetKey(key);
        }
        //
        // Summary:
        //     Returns true during the frame the user starts pressing down the key identified
        //     by name.
        //
        // Parameters:
        //   name:
        public static bool GetKeyDown(string name)
        {
            return !IsFocusedOnInputField && Input.GetKeyDown(name);
        }
        //
        // Summary:
        //     Returns true during the frame the user starts pressing down the key identified
        //     by the key KeyCode enum parameter.
        //
        // Parameters:
        //   key:
        public static bool GetKeyDown(KeyCode key)
        {
            return !IsFocusedOnInputField && Input.GetKeyDown(key);
        }
        //
        // Summary:
        //     Returns true during the frame the user releases the key identified by the key
        //     KeyCode enum parameter.
        //
        // Parameters:
        //   key:
        public static bool GetKeyUp(KeyCode key)
        {
            return !IsFocusedOnInputField && Input.GetKeyUp(key);
        }
        //
        // Summary:
        //     Returns true during the frame the user releases the key identified by name.
        //
        // Parameters:
        //   name:
        public static bool GetKeyUp(string name)
        {
            return !IsFocusedOnInputField && Input.GetKeyUp(name);
        }
    }
}
```

