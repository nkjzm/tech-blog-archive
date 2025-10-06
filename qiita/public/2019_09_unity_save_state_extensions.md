---
title: 【Unity】既存のSliderやToggleの状態を簡易的に保存する拡張メソッド【SaveStateExtensions】
tags:
  - Unity
private: false
updated_at: '2025-10-06T21:48:16+09:00'
id: 62f3bce82ed2d75833c0
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

![20190925-024041.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/7b16027c-bd08-4427-f8d2-9384082bb19d.png)

設定画面など、スライダーやチェックボックス(Toggle)を扱うことがあります。多分ソースコードはこんな感じになっています。

```cs:ConfigController.cs
using UnityEngine;
using UnityEngine.UI;

namespace hoge
{
    public class ConfigController : MonoBehaviour
    {
        [SerializeField] Toggle BGMToggle, SEToggle, VoiceToggle;
        [SerializeField] Slider BGMSlider, SESlider, VoiceSlder;
        [SerializeField] InputField MemoInputField;
        [SerializeField] AudioSource BGMSource, SESource, VoiceSource;

        void Update()
        {
            // AudioSourceのミュート状態を制御
            BGMSource.mute = BGMToggle.isOn;
            SESource.mute = SEToggle.isOn;
            VoiceSource.mute = VoiceToggle.isOn;

            // AudioSourceの音量を制御
            BGMSource.volume = BGMSlider.value;
            SESource.volume = SESlider.value;
            VoiceSource.volume = VoiceSlder.value;
        }
    }
}
```

これらは多くの場合、アプリが終了しても保持しておく必要があると思うので、今回は拡張メソッドを使って実現してみました。

# 使い方

まず[SaveStateExtensions.cs](https://gist.github.com/nkjzm/156499eee0717a2728f958fd6224ceb4)をDLし、プロジェクト内にインポートします。

次に保存したいコンポーネントに対して、`Start()`内などで以下の様に呼び出してあげるだけです。


```cs
void Start()
{
    // Toggleの場合
    BGMToggle.SaveState("BGMToggle");
    SEToggle.SaveState("SEToggle");
    VoiceToggle.SaveState("VoiceToggle");

    // Sliderの場合
    BGMSlider.SaveState("BGMSlider");
    SESlider.SaveState("SESlider");
    VoiceSlder.SaveState("VoiceSlder");

    // InputFieldの場合
    MemoInputField.SaveState("MemoInputField");
}
```

引数の`key`だけは重複しないように気を付けて下さい。(`nameof(BGMToggle)`を渡してもいいかも)


# アプローチ

ソースコード全文はこのようになっています。

Gits: [SaveStateExtensions.cs](https://gist.github.com/nkjzm/156499eee0717a2728f958fd6224ceb4)

```cs:SaveStateExtensions.cs
using UnityEngine;
using UnityEngine.UI;

public static class SaveStateExtensions
{
    public static void SaveState(this Toggle toggle, string key)
    {
        key = $"{new System.Diagnostics.StackFrame(1).GetMethod().ReflectedType}+{key}";
        Debug.Log(key);
        toggle.isOn = PlayerPrefs.GetInt(key, 0) == 1;
        toggle.onValueChanged.AddListener(isOn => PlayerPrefs.SetInt(key, isOn ? 1 : 0));
    }
    public static void SaveState(this Slider slider, string key)
    {
        key = $"{new System.Diagnostics.StackFrame(1).GetMethod().Name}+{key}";
        slider.value = PlayerPrefs.GetFloat(key, 0f);
        slider.onValueChanged.AddListener(value => PlayerPrefs.SetFloat(key, value));
    }
    public static void SaveState(this InputField inputField, string key)
    {
        key = $"{new System.Diagnostics.StackFrame(1).GetMethod().Name}+{key}";
        inputField.text = PlayerPrefs.GetString(key, string.Empty);
        inputField.onValueChanged.AddListener(value => PlayerPrefs.SetString(key, value));
    }
    public static void SaveState(this Dropdown dropdown, string key)
    {
        key = $"{new System.Diagnostics.StackFrame(1).GetMethod().Name}+{key}";
        dropdown.value = PlayerPrefs.GetInt(key, 0);
        dropdown.onValueChanged.AddListener(value => PlayerPrefs.SetInt(key, value));
    }
}
```

`SaveStateToggle`を例に見てみると、やっていることは①`PlayerPrefs.GetInt()`で取得した値を`Toggle`の初期値として代入し、②`Toggle`の変更が合った場合のイベント(`toggle.onValueChanged`)内で`PlayerPrefs.SetInt()`を呼んでいます。

```cs
public static void SaveStateToggle(this Toggle toggle, string key)
{
    key = $"{new System.Diagnostics.StackFrame(1).GetMethod().ReflectedType}+{key}";
    toggle.isOn = PlayerPrefs.GetInt(key, 0) == 1;
    toggle.onValueChanged.AddListener(isOn => PlayerPrefs.SetInt(key, isOn ? 1 : 0));
}
```

少し工夫しているのか`key`の生成で、`System.Diagnostics.StackFrame(1).GetMethod().ReflectedType`を使って呼び出し元のクラス名を先頭に追加しています。先の例では`"hoge.ConfigController+BGMToggle"`が`key`になる形です。こうすることによって、このメソッドを多くの場所で利用しても`key`の衝突が起きにくくしています。

# 最後に

今回は保存に`PlayerPrefs`を使っていますが、異常終了時には正しく保存されない場合があります。(`PlayerPrefs.Save();`で明示的に保存することもできます)

あくまで簡易的なものですので、その点に気をつけてぜひご活用ください。



