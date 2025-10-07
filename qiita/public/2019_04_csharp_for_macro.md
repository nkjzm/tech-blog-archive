---
title: 競プロでやりがちなC++マクロでfor文を省略するお作法のC#版を考えました
published_at: '2019-04-11 16:38'
private: false
tags:
  - C#
updated_at: '2019-04-11T16:38:39+09:00'
id: 63e97fa8b1d883618c3a
organization_url_name: null
slide: false
---
## C++の省略for文

```cpp
#define rep(i,n) for(int i=(0);i<(n);i++)

int main()
{
    rep(a, 10) rep(b, 10) rep(c, 10){
        if(a + b == c) break;
        cout << a + b + c << endl;
    }
}
```

## 僕が考えたC#の省略for文

```cs
static void Rep(int n, Action<int> action) { for (var i = 0; i < n; ++i) { action(i); } }

public static void Main()
{
    Rep(10, a => Rep(10, b => Rep(10, c =>
    {
        if(a + b == c) return;
        Console.WriteLine(a + b + c);
    })));
}
```

すごい書きやすいかって言われたらそんなことないんですけど、`for(var i=0;i<N;++i)`って書くとループ用変数の`i`が3回も出てくるのがすごく嫌で、多重ループだと書き間違えてても気が付きにくいんですよね。命名で工夫すればいいという話もありますが、この方法なら記述量も少し減るので意外と悪くないかなーという感じです。

C++のマクロと違うポイントとしては、処理の中身がデリゲートなので`break`や`continue`が使えません。~~`break`は`return`で代替出来ますが、`continue`使いたいような状況だと少し不便そうです。~~

## おわりに

意見とか良い方法とかあったら教えてください。
他に思いついたら追記するかもしれないです。

