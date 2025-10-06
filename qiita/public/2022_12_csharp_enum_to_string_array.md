---
title: 【C#】Enumから任意の文字列配列への変換を安全に行う【Unity】
tags:
  - C#
  - Unity
private: false
updated_at: '2022-12-19T08:17:16+09:00'
id: cfa45ca106d7aa4bc74d
organization_url_name: mydearest
slide: false
ignorePublish: false
---
# はじめに

この記事は[Unity Advent Calendar 2022-2](https://qiita.com/advent-calendar/2022/unity)の10日目の記事です。

Unityを使っていると、Enumで定義された型を選択させる場合に対応するラベル文字列の配列を定義する場合があります。

```エディタ拡張のPopupでEnumを選択させる例.cs
public enum Type { Item1, Item2, Item3, }

var list = new[] { "アイテム1", "アイテム2", "アイテム3", };
type = (Type)EditorGUILayout.Popup("ラベル", (int)type, list);
```

要素名をそのまま表示されるよりも分かりやすくなる一方で、型と文字列配列は順番(index)のみで紐づいているため、Enumの要素を追加した場合などに不具合に繋がるリスクがあります。

そこで、今回はEnumで定義された型をスマートに文字列配列に変換する方法を考えてみました。

# 方法

Enumの全要素を配列にした後に、switch式で文字列に変換する処理を書きました。

```.cs
list = Enum.GetValues(typeof(Type)).Cast<Type>().Select(type => type switch
{
    Type.Item1 => "アイテム1",
    Type.Item2 => "アイテム2",
    Type.Item3 => "アイテム3",
    _ => throw new ArgumentOutOfRangeException(nameof(type), type, null),
}).ToArray();
```

この方法では要素と文字列の順番が必ず紐づきますし、定義されていない文字列があった場合に実行時エラーとなります（冒頭の例で要素を追加した場合、エラーは発生しません）。

また、IDE側で定義漏れの警告を表示することもできるので検知がしやすくなっていると思います。

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/ab8aa76b-fb1c-bee1-629c-e7ee591212b0.png)
_Riderで警告表示をさせた例_


# おまけ：ジェネリックメソッドとして定義する

そのままだと少し煩雑に見えるので、ジェネリックメソッドで定義しておくと少しだけすっきりします。

```.cs
/// <summary> Enumの全要素を列挙した文字列配列を返す</summary>
private static string[] ConvertStrings<TState>(Func<TState, string> selector) where TState : Enum
    => Enum.GetValues(typeof(TState)).Cast<TState>().Select(selector).ToArray();

// Before
var list = Enum.GetValues(typeof(Type)).Cast<Type>().Select(type => type switch
{
    Type.Item1 => "アイテム1",
    Type.Item2 => "アイテム2",
    Type.Item3 => "アイテム3",
    _ => throw new ArgumentOutOfRangeException(nameof(type), type, null),
}).ToArray();

// After
var list2 = ConvertStrings<Type>(type => type switch
{
    Type.Item1 => "アイテム1",
    Type.Item2 => "アイテム2",
    Type.Item3 => "アイテム3",
    _ => throw new ArgumentOutOfRangeException(nameof(type), type, null),
});
```

# 最後に

エディタ拡張のPopupやuGUIのDropdownなど、地味にこういう変換をしたい場面がでてくるので、書き方覚えておけるといいかなと思いました。

よかったら Twitter のフォローよろしくお願いします！→ @nkjzm


