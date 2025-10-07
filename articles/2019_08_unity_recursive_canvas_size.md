---
title: "【Unity】再帰的に親のCanvasサイズを取得する"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity"]
published: true
published_at: 2019-08-13 11:34
---
# TL;DR

大体の場合は`rectTransform.rect.size`を使えばいい

# はじめに

uGUIで要素の大きさを取得する方法は2つあります。

- [RectTransform.sizeDelta](https://docs.unity3d.com/ja/current/ScriptReference/RectTransform-sizeDelta.html)
    - アンカー間の距離と比較した`RectTransform`のサイズ
    - アンカーが一致していれば要素のサイズと同じ
    - アンカーが離れている場合(Stretch)は親との相対距離
- [RectTransform.rect](https://docs.unity3d.com/ja/current/ScriptReference/RectTransform-rect.html)
    - Transform のローカル空間で計算された矩形 

大体の場合は`rectTransform.rect.size`を使えばいいのですが、[何らかの影響](https://twitter.com/nkjzm/status/1161088350050123776)で取得できない場合がありました。uGUIでAnchorが一致していない場合(=Stretch)は親の座標から相対的にサイズが決定するため、再帰的に自身の大きさを取得するコードを書いてみました。

# コード

```cs
    static Vector2 GetRectSize(RectTransform self)
    {
        var parent = self.parent as RectTransform;
        if (parent == null)
        {
            return new Vector2(self.rect.width, self.rect.height);
        }
        // 枝切り処理。これはない方がよい場合もある。
        if (parent.anchorMin == parent.anchorMax)
        {
            return parent.sizeDelta;
        }
        var parentSize = GetRectSize(parent);
        var anchor = self.anchorMax - self.anchorMin;
        var width = (parentSize.x * anchor.x) + self.sizeDelta.x;
        var height = (parentSize.y * anchor.y) + self.sizeDelta.y;
        return new Vector2(width, height);
    }
```

# 最後に

あんまり使うことないと思いますが、折角書いたのでよかったら使ってください…。CC0です。

