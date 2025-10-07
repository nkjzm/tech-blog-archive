---
title: Staticメンバーでキャッシュをする(Vector.zeroの例)
published_at: '2018-07-07 16:16'
private: false
tags:
  - C#
  - Unity
updated_at: '2018-07-07T16:16:06+09:00'
id: b471fa904b9073859ee5
organization_url_name: null
slide: false
---
UnityEngineのstaticメンバーの中には、内部で動的な処理が動いているものが存在します。
今回はそういった動的な処理をキャッシュするための実装について調べてみました。

## 内部で動的な処理が動いているものの例

###  GetComponentするパターン

`GameObject.transform`など

#### 参考: 
81ページ目
https://www.slideshare.net/UnityTechnologiesJapan/unity-2016-77897096

内部実装はよく分からない(dllとかで隠蔽されてる?)
https://github.com/MattRix/UnityDecompiled/blob/master/UnityEngine/UnityEngine/GameObject.cs#L14-L19

### newするパターン

- `Color.red` (black, blueなども同様)
- `Vector.zero` (up,rightなども同様)

#### 参考
UnityDecompiled/Color.cs at master · MattRix/UnityDecompiled
https://github.com/MattRix/UnityDecompiled/blob/master/UnityEngine/UnityEngine/Color.cs#L17-L23

## 方法

今回は(0,0,0)のベクトルを取得するZeroGetterをキャッシュする方法を考えます。

```
        public static Vector3 ZeroGetter
        {
            get
            {
                Debug.Log("init");
                return new Vector3(0, 0, 0);
            }
        }
```

### 直接呼び出す

```
        Debug.Log("--- getter");
        for (int i = 0; i < 10; ++i)
        {
            var vec = AbemaTV.VectorUtils.ZeroGetter;
        }
```

#### 結果

<img width="229" alt="85b7631d-629f-2a7d-2d59-740fe6aba1bf.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/1bfea976-f333-b7cc-626d-7b8f2d219856.png">


毎回newされてしまっています。

### 一時変数を用意する

```
        static Vector3? cache;
        public static Vector3 ZeroCache
        {
            get
            {
                return (Vector3)(cache ?? (cache = ZeroGetter));
            }
        }
```

初回アクセス時のみGetterを呼び出す実装です。

```
        Debug.Log("--- cache");
        for (int i = 0; i < 10; ++i)
        {
            var vec = AbemaTV.VectorUtils.ZeroCache;
        }
```

呼びます

#### 結果

<img width="229" alt="c0b85355-14de-d54f-4740-d8d0043782c0.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/89a9b75c-b823-31f3-e852-a8f5cd8fe808.png">


意図通り1回だけ呼ばれました

### 静的メンバーを経由する

```
        public static Vector3 Zero = ZeroGetter;
```

staticメンバー`Zero`に値をキャッシュできないか試してみました。

```
        Debug.Log("--- static member");
        for (int i = 0; i < 10; ++i)
        {
            var vec = AbemaTV.VectorUtils.Zero;
        }
```
呼びます

#### 結果

<img width="225" alt="f617cc6d-6bcd-02a9-cd97-b086ea67b632.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/196e9c9b-7973-85e8-5cfd-7c171fe99fd0.png">


一度だけ呼ばれました。

特徴としては、**初回アクセスより前に呼び出されて**内部的にキャッシュされることです。

(ドキュメントにも書いてありました)
> 静的メンバーは初めてアクセスされる前に初期化されます。
https://docs.microsoft.com/ja-jp/dotnet/csharp/programming-guide/classes-and-structs/static-classes-and-static-class-members


## 結論

**(getterでない)Staticメンバーを通して呼べばキャッシュできる。**

## 余談

ちなみに今回例にした`Vector.zero`に関しては、予め静的メンバーを初期化した値を

```
		private static readonly Vector3 zeroVector = new Vector3(0f, 0f, 0f);
```
https://github.com/MattRix/UnityDecompiled/blob/master/UnityEngine/UnityEngine/Vector3.cs#L19

Getterを使って呼び出しているので、自前でキャッシュを考える必要はなさそうです。

```
		public static Vector3 zero
		{
			get
			{
				return Vector3.zeroVector;
			}
		}
```
https://github.com/MattRix/UnityDecompiled/blob/master/UnityEngine/UnityEngine/Vector3.cs#L103-L109

`Color.red`は毎回newしているので、キャッシュが効くと思います。

```
		public static Color red
		{
			get
			{
				return new Color(1f, 0f, 0f, 1f);
			}
		}
```
https://github.com/MattRix/UnityDecompiled/blob/master/UnityEngine/UnityEngine/Color.cs#L17-L23

## 雑感

> C# では、ローカル変数はスタック上に値を置きます。 この時、変数が「値型」の場合、値すべてがスタック上に置かれます。 一方、「参照型」の場合、実際の値はヒープ上に置かれ、そのヒープ上の場所への参照情報（「ポインター」 ）だけがスタック上に置かれます。
http://ufcpp.net/study/csharp/rm_gc.html

スタック領域はローカル変数に限定した話っぽいので、staticメンバーの値は全てヒープ領域に置かれている…？


## 最後に

認識が間違っている箇所などあればご指摘お待ちしております！！

