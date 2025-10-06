---
title: "Curved UIの紹介とハマったこと"
emoji: "🎨"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "VR"]
published: true
---
# Curved UIとは
uGUIのキャンバスをカーブさせられるアセット

Curved UI - VR Ready Solution To Bend / Warp Your Canvas! - アセットストア
https://www.assetstore.unity3d.com/jp/#!/content/53258

## 特徴

- Unityにフィーチャーされてる
    - Unityにチュートリアルがある
        - Unity - Worldspace UI with Curved UI
            - https://unity3d.com/jp/learn/tutorials/topics/vr/worldspace-ui-curved-ui
    - VRエッセンシャルパックにも入ってる
        - Unity - Up to $188 in Free Assets with Your Subscription
            - https://store.unity.com/ja/offer/unity-essentials-packs
    - →**導入を決めやすい**
- uGUIベース
    - Event Systemとかを書き換えてる
    - →**最強の互換性**
- VRサポート
    - Oculus
    - Vive
    - Google VR(cardboard or Daydream)
    - それぞれのコントローラーのインプットまでサポート

## できること

色々カーブさせられる

![0747912d-2948-9d6c-7f32-97f2b0386ca7.jpeg](https://qiita-image-store.s3.amazonaws.com/0/55365/3343b1b1-043d-e31a-29cb-9d6e67081de5.jpeg)


## できないこと

180度を超えるUIにした場合(全周を囲むUIとか)、インタラクションができない
→ uGUIの仕様上の問題らしい

# ハマったこと

## カーブの設定が反映されない

インスペクターで選択するまでカーブしない(実機でも同様)

Google VR SDKのバージョンの問題？

Google VR SDK 1.100.x系ではコンパイルエラー

→ Google VR SDK 1.70.1系で正常に動作
*(一応or laterって書いてあるのに…)*

## 動的に追加した要素がカーブしない

ドキュメントにFAQがあった

CurvedUI 2.3 Documentation - Google ドキュメント
https://docs.google.com/document/d/10hNcvOMissNbGgjyFyV1MS7HwkXXE6270A6Ul8h8pnQ/edit#

> # Elements I add to the canvas via code are not curved. What do?
>When you add elements to the curved canvas during runtime you have to add CurvedUIVertexEffect component to them manually. You can do it with the following line:

>`YourNewObject.AddComponent\<CurvedUIVertexEffect\>();`

> Make sure you add the component after you make the element a child of the canvas. You can also make CurvedUISettings component scan all its children and add necessary components by calling its AddEffectToChildren() function.

`CurvedUIVertexEffect`を追加する方法はうまくいかなかった。

`AddEffectToChildren()`したら動いた。

# その他

Unity 2017.1までのサポートって書いてあるが、Unity2017.2.xでも動作した

Unityのポップアップにしたがってマイグレーションすればok



