---
title: 【DOTween】ポップにアニメーションするボタンを作る【Unity】
tags:
  - Unity
private: false
updated_at: '2020-01-16T07:54:24+09:00'
id: 8c8b38e45c3e7712cd74
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに


[開発中のアプリ](https://twitter.com/hashtag/%E9%83%BD%E9%81%93%E5%BA%9C%E7%9C%8C%E3%83%AA%E3%83%90%E3%83%BC%E3%82%B7?src=hashtag_click)で[DOTween](http://dotween.demigiant.com/documentation.php)を使った簡単なボタンアニメーションを作ったので紹介します。

![Jan-16-2020 07-46-16.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/4928f7be-8ca0-7be9-2dcb-e7098572bafe.gif)

使用しているUIアセット(有償): [Simple UI - Asset Store](https://assetstore.unity.com/packages/2d/gui/icons/simple-ui-103969)


# コード

使用する場合は以下のスクリプトをプロジェクトにインポートし、`Button`コンポーネントの変わりにアタッチしてください。CC0です。

Gist: [PopButton.cs](https://gist.github.com/nkjzm/b0a4f56d9787b1f6abe1102f496b9348)

```cs:PopButton.cs
using UnityEngine.UI;
using DG.Tweening;
using UnityEngine;

namespace nkjzm
{
    /// <summary>
    /// ポップに押されるボタン
    /// </summary>
    public class PopButton : Button
    {
        Tweener tweener = null;
        new void Start()
        {
            base.Start();

            // ボタンアニメーション
            onClick.AddListener(() =>
            {
                // 再生中のアニメーションを停止/初期化
                if (tweener != null)
                {
                    tweener.Kill();
                    tweener = null;
                    transform.localScale = Vector3.one;
                }
                tweener = transform.DOPunchScale(
                    punch: Vector3.one * 0.1f,
                    duration: 0.2f,
                    vibrato: 1
                ).SetEase(Ease.OutExpo);
            });
        }
    }
}
```

# 余談

ボタン押下時の機能を`AddListener`するとアニメーションの途中で見えなくなってしまう場合があるので、機能によっては`0.2f`秒のラグを入れてあげると良いかもしれません。



