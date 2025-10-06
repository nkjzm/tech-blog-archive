---
title: 【Unity】テスト対象のプレハブを名前で検索するUtilityメソッド
tags:
  - Unity
private: false
updated_at: '2021-12-09T23:57:39+09:00'
id: 9124a48c1dcba1e7194c
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

この記事は『[Unity Advent Calendar 2021](https://qiita.com/advent-calendar/2021/unity)』の9日目の記事です！

さて、みなさんはUnityでテスト書いてますか？！テストいいですよね！！！！テストを書いたことがないという方は、ぜひ昨日8日のアドカレ記事「[ゆるく使うUnityTest](https://am1tanaka.hatenablog.com/entry/yuru-unitytest-2021)」（by @am1tanakaさん）を読んでみてください！（めちゃくちゃ丁寧に書かれた良い記事でした👏）

今日はそんなテストを書くときに使えるかもしれない、ちょっと便利なUtilityメソッドを紹介したいと思います！！！

# 環境

- Windows 10 Home (19043.1348)
- Unity 2020.3.11f1
- Unity Test Framework 1.1.30

# テスト対象のプレハブを名前で検索する

さて、Unityでテストを書いていると、`MonoBehaviour`の機能を使った処理のテストや、プレハブのバリデーションを行いたい場合が出てくると思います。例えばこんなクラスがあったとして

```cs:HogeClass.cs
namespace nkjzm.Tests
{
    public class TestHogeClass : MonoBehaviour {}
}
```

素直に書くとこんな感じでしょうか。

```cs:TestHogeClass.cs
namespace nkjzm.Tests
{
    public class TestHogeClass
    {
        private HogeClass targetPrefab;
        protected HogeClass target;
        protected string FilePath = "Assets/Fuga/Piyo/hogehoge"

        [OneTimeSetUp]
        public void OneTimeSetup() => targetPrefab = AssetDatabase.LoadAssetAtPath<HogeClass>(FilePath);

        [SetUp]
        public void Setup() => target = UnityEngine.Object.Instantiate(targetPrefab);

        [Test]
        public void 存在する() => Assert.IsNotNull(target);
    }
}
```

悪くはないのですが、テスト対象のプレハブをAssets以下の相対パスで指定している点が気になります。ディレクトリの構成を変えるとテストが通らなくなってしまいます。Packageとして配布する時にも少し困りそうです。

```cs
protected string FilePath = "Assets/Fuga/Piyo/hogehoge"

[OneTimeSetUp]
public void OneTimeSetup() => targetPrefab = AssetDatabase.LoadAssetAtPath<HogeClass>(FilePath);
```

そこで今回はここ部分をUtilsクラスとして書き出してみました。以下のような形で使用できます。

```cs
protected string FileName= "hogehoge"

[OneTimeSetUp]
public void OneTimeSetup() => targetPrefab = Utils.LoadPrefab<HogeClass>(FileName);
```

ちょっと地味なのですが、パス指定を省略できるようになりました！！


## コード

```cs:Utils.cs
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace nkjzm.Tests
{
    /// <summary>
    /// テスト用のUtilityクラス
    /// </summary>
    public static class Utils
    {
        /// <summary>
        /// 対象のプレハブを読み込む
        /// </summary>
        /// <param name="fileName">対象プレハブのファイル名（拡張子不要）</param>
        /// <typeparam name="T">対象プレハブの型名</typeparam>
        /// <returns>プレハブの参照（見つからなかった場合はnullを返す）</returns>
        public static T LoadPrefab<T>(string fileName) where T : Object
        {
            var filePath = AssetDatabase.FindAssets($"{fileName} t:Prefab")
                .Select(AssetDatabase.GUIDToAssetPath)
                .FirstOrDefault(str => Path.GetFileNameWithoutExtension(str) == fileName);
            return AssetDatabase.LoadAssetAtPath<T>(filePath);
        }
    }
}
```

## 解説

`AssetDatabase.FindAssets()`を使用しているところがポイントです。UnityエディタのProjectsウィンドウにある検索と同様にフィルタリング機能が利用できるので、引数の文字列に`t:Prefab`を追加しています。これで指定した名前を含むプレハブのみを検索してくれます。

https://docs.unity3d.com/ScriptReference/AssetDatabase.FindAssets.html

ただし少し注意する点があって、このメソッドは部分一致の検索結果を配列で返すメソッドになっています。

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/ccadf64a-328e-2f29-fd4b-958cacb8d443.png)

そこで`.FirstOrDefault(str => Path.GetFileNameWithoutExtension(str) == fileName)`という処理で完全一致するオブジェクトを返すようにしています。これで大抵の場合は目的のプレハブを呼び出せるようになりました！

## テスト用Utilsクラスのテスト

テスト用のUtilsクラスについてもテストを書いてみました。
![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/846943a7-d984-c2fe-9eeb-1286724598a1.png)

テストのための機能をテストするのは不思議な感じがしましたが、この部分に不具合があればテストが意図せず通らない可能性もあるので、テストコードで動作を保証することはかなり自然で意義があると感じました。
（アドバイスくれた [@tsgcpp](https://twitter.com/tsgcpp)さん、ありがとうございました！）

折角なのでこちらのテストコードも載せておこうと思います。

```cs:TestUtils.cs
using NUnit.Framework;
using UnityEditor;
using UnityEngine;

namespace nkjzm.Tests
{
    public class TestUtils
    {
        private const string DummyFileName = "Dummy";
        private const string DummyFileName2 = "Dummy2";
        private const string AssetsRoot = "Assets";
        private static string DummyFilePath(string fileName) => $"{AssetsRoot}/{fileName}.prefab";
        private static string DummyFolderPath(string fileName) => $"{AssetsRoot}/{fileName}";


        [OneTimeSetUp]
        public void OneTimeSetUp()
        {
            // テスト用にいくつかダミーファイルを生成
            // ダミーファイル
            var gameObject = new GameObject();
            PrefabUtility.SaveAsPrefabAsset(gameObject, DummyFilePath(DummyFileName));
            PrefabUtility.SaveAsPrefabAsset(gameObject, DummyFilePath(DummyFileName2));
            // ダミーファイルと同名のダミーフォルダー
            AssetDatabase.CreateFolder(AssetsRoot, DummyFileName);
        }

        [OneTimeTearDown]
        public void OneTimeTearDown()
        {
            // 生成したダミーファイルの削除
            AssetDatabase.DeleteAsset(DummyFilePath(DummyFileName));
            AssetDatabase.DeleteAsset(DummyFilePath(DummyFileName2));
            AssetDatabase.DeleteAsset(DummyFolderPath(DummyFileName));
        }

        [Test]
        public void 対象ファイルを読み込める1()
        {
            var target = Utils.LoadPrefab<GameObject>(DummyFileName);
            Assert.IsNotNull(target);
            Assert.AreEqual(DummyFileName, target.name);
        }

        [Test]
        public void 対象ファイルを読み込める2()
        {
            var target = Utils.LoadPrefab<GameObject>(DummyFileName2);
            Assert.IsNotNull(target);
            Assert.AreEqual(DummyFileName2, target.name);
        }

        [Test]
        public void 継承元の型指定でファイルを読み込める()
        {
            var target = Utils.LoadPrefab<Object>(DummyFileName);
            Assert.IsNotNull(target);
        }

        [Test]
        public void 誤った型名を指定するとNullが返る()
        {
            var target = Utils.LoadPrefab<Material>(DummyFileName);
            Assert.IsNull(target);
        }

        [Test]
        public void パスにnullを渡すとNullが返る()
        {
            var target = Utils.LoadPrefab<GameObject>(null);
            Assert.IsNull(target);
        }

        [Test]
        public void パスに空文字を渡すとNullが返る()
        {
            var target = Utils.LoadPrefab<GameObject>(string.Empty);
            Assert.IsNull(target);
        }
    }
}
```

# 最後に

今日はテストのちょっとした小ネタの紹介してみました！みなさんも一緒にテストを書いて快適で保守性の高い効率的な開発をしていきましょう！！！Twitterやってるので良かったらフォローしてください！→ [@nkjzm](https://twitter.com/nkjzm)


この記事は『[Unity Advent Calendar 2021](https://qiita.com/advent-calendar/2021/unity)』の9日目の記事でした。
明日は @choromeさんの「チェスを題材にDDDしてUnityで動かしてみた話」です。お楽しみに！

# 参考

https://www.urablog.xyz/entry/2021/10/11/130000

https://gomafrontier.com/unity/4507
