---
title: 【VR学まとめ】4.2.2 視覚レンダリングとモデル
tags:
  - VR
private: false
updated_at: '2018-12-22T06:53:09+09:00'
id: 29bb8495ed25cc2e6212
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

この記事は[一人VR技術者認定試験 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/vr-engineer)の17日目の記事です。

[バーチャルリアリティ学](https://www.amazon.co.jp/バーチャルリアリティ学-舘-暲/dp/4904490053)の4章「バーチャル世界の構成手法」の内容をまとめていきます。
書籍の方も是非ご購入いただいた上でご利用ください。

# 4 バーチャル世界の構成手法

## 4.2 レンダリング

### 4.2.1 レンダリングのためのモデル

体験者の位置や姿勢、バーチャル世界の変化に応じてレンダリングする必要がある。

### 4.2.2 視覚レンダリングとモデル

以下の3つの処理からなる

#### (1) 投影処理

![JPEG image-FCBB93589FF1-1.jpeg](https://qiita-image-store.s3.amazonaws.com/0/55365/624f9a0b-4aad-8684-7713-5fd2f23e1d73.jpeg)
引用元: [バーチャルリアリティ学](https://www.amazon.co.jp/%E3%83%90%E3%83%BC%E3%83%81%E3%83%A3%E3%83%AB%E3%83%AA%E3%82%A2%E3%83%AA%E3%83%86%E3%82%A3%E5%AD%A6-%E8%88%98-%E6%9A%B2/dp/4904490053)

- 視点座標系に変換
- 投影処理によりスクリーン上の座標を求める
    - 透視投影
        - z_sが0の時の(x_s, y_s)が当英語のスクリーン座標
        - z_sはZ値と呼ばれ、Zバッファ法などに使われる

<img width="374" alt="スクリーンショット 2018-12-22 5.59.12.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/bfb7161b-dcda-4cfc-4715-c63c356329ea.png">

#### (2) 陰影消去

![JPEG image-4C64173E7A83-1.jpeg](https://qiita-image-store.s3.amazonaws.com/0/55365/27db8aa9-a1d5-6ba9-3846-70f48e064d3b.jpeg)
引用元: [バーチャルリアリティ学](https://www.amazon.co.jp/%E3%83%90%E3%83%BC%E3%83%81%E3%83%A3%E3%83%AB%E3%83%AA%E3%82%A2%E3%83%AA%E3%83%86%E3%82%A3%E5%AD%A6-%E8%88%98-%E6%9A%B2/dp/4904490053)

- Zバッファ法
    - スクリーンと同じサイズ
    - 大きな値で初期化
    - Zバッファが書き込まれている数値より小さかったら描画しZバッファを更新する

#### (3) 輝度計算

- シェーディング (shading)
    - 物体表面の材質や輝度
- シャドウイング (shadowing)
    - 他の物体に落とす影
- シェーディングの代表的なモデル
    - Iは物体表面の輝度
    - 右辺は環境光成分、拡散反射光成分、鏡面反射光成分

<img width="378" alt="スクリーンショット 2018-12-22 6.01.36.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/ac2bc16d-8084-8764-648c-3c1ec7fb1008.png">

- シャドウイング計算
    - 計算点から光源が可視かどうかで判定
    - 一般に負荷が高い
    - 点光源や平行光源のような単純なものはZバッファを用いて高速計算可能
        - 光源位置に仮想と視点を配置しZバッファを生成しておく(シャドウマップ)
        - 各点の描画時にシャドウマップを参照する

![JPEG image-4C64173E7A83-2.jpeg](https://qiita-image-store.s3.amazonaws.com/0/55365/bcc463ad-7a3f-517e-56b1-e21fcfccd1b1.jpeg)
引用元: [バーチャルリアリティ学](https://www.amazon.co.jp/%E3%83%90%E3%83%BC%E3%83%81%E3%83%A3%E3%83%AB%E3%83%AA%E3%82%A2%E3%83%AA%E3%83%86%E3%82%A3%E5%AD%A6-%E8%88%98-%E6%9A%B2/dp/4904490053)

# まとめ

視覚レンダリングの基本的な流れを理解できました。

[一人VR技術者認定試験 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/vr-engineer)の18日目は[【VR学まとめ】4.2.3 聴覚レンダリングとモデル](https://qiita.com/nkjzm/items/5ae01203c0f93baa9c13)です。
