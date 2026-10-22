---
title: "【C#】リスト中から毎回違う要素をランダムに取り出すためのクラス【UniqueItemPicker.cs】"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["C#", "Unity"]
published: true
---
## はじめに

C#でリスト中から重複せずに要素を取り出した場面があったので、いい感じのクラスを書きました。Unityで使ってますが、ログ出力部分以外はC#でも使えます。CC0なのでよかったら活用してください。

Gist: [UniqueItemPicker.cs](https://gist.github.com/nkjzm/af7149634a11b2912ba19257d8f33bed)

## 使い方

```cs:test.cs
using UnityEngine;

public class test : MonoBehaviour
{
    void Start()
    {
        // 配列を用意する
        var nameList = new string[]
        {
            "なかじ",
            "リリカちゃん",
            "ゴリラ",
        };

        // 配列を渡して初期化
        var enemyNameGenerator = new UniqueItemPicker<string>(nameList);

        // 要素を取り出す
        Debug.Log(enemyNameGenerator.GetUniqueItem());
        Debug.Log(enemyNameGenerator.GetUniqueItem());
        Debug.Log(enemyNameGenerator.GetUniqueItem());
        Debug.Log(enemyNameGenerator.GetUniqueItem()); // null

        // 履歴を削除
        enemyNameGenerator.ResetUsageHistory();

        // 再び取り出せるようになる
        Debug.Log(enemyNameGenerator.GetUniqueItem());
        Debug.Log(enemyNameGenerator.GetUniqueItem());
    }
}
```

### 出力

<img width="332" alt="スクリーンショット 2019-11-19 18.27.02.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/4955e534-6cfb-7fc5-f138-a5a501ab9933.png">

初期化した時の要素を使い終わると`Null`が返ってくる点に注意してください。そうなった場合、`enemyNameGenerator.ResetUsageHistory()`を呼び出すことで再度要素を取得することができます。


## ソースコード

Gist: [UniqueItemPicker.cs](https://gist.github.com/nkjzm/af7149634a11b2912ba19257d8f33bed)

```cs:UniqueItemPicker.cs
using System.Collections.Generic;

/// <summary>
/// リスト中から重複せずに要素を取り出すクラス
/// </summary>
public class UniqueItemPicker<T>
{
    T[] AllItems;
    /// <summary>
    /// コンストラクタ
    /// </summary>
    /// <param name="allItems">取り出したい要素の配列</param>
    public UniqueItemPicker(T[] allItems)
    {
        AllItems = allItems;
        InitIndexList();
    }

    void InitIndexList()
    {
        indexList.Clear();
        for (int i = 0; i < AllItems.Length; i++)
        {
            indexList.Add(i);
        }
    }

    /// <summary>
    ///  リスト中から重複せずに要素を取り出す
    /// </summary>
    public T GetUniqueItem()
    {
        if (indexList.Count == 0)
        {
            UnityEngine.Debug.LogError("要素がありません");
            return default(T);
        }
        return AllItems[GetIndex()];
    }

    List<int> indexList = new List<int>();
    int GetIndex()
    {
        int index = UnityEngine.Random.Range(0, indexList.Count);
        int result = indexList[index];
        indexList.RemoveAt(index);
        return result;
    }

    /// <summary>
    /// 使用履歴を初期化する
    /// </summary>
    public void ResetUsageHistory()
    {
        InitIndexList();
    }
}
```

ジェネリック型で作っているので構造体やクラスも扱えて便利です。型を限定していないので、要素がない時は `default(T)`を返しているところがポイントです。

## 最後に

役に立ったらいいねください！！

