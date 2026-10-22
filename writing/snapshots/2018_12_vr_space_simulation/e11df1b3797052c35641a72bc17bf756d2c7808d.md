---
title: "【VR学まとめ】4.3.2 空間のシミュレーション"
emoji: "🥽"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["VR"]
published: true
published_at: 2018-12-22 08:29
---
# はじめに

この記事は[一人VR技術者認定試験 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/vr-engineer)の20日目の記事です。

[バーチャルリアリティ学](https://www.amazon.co.jp/バーチャルリアリティ学-舘-暲/dp/4904490053)の4章「バーチャル世界の構成手法」の内容をまとめていきます。
書籍の方も是非ご購入いただいた上でご利用ください。

# 4 バーチャル世界の構成手法

## 4.3 シミュレーション

### 4.3.1 シミュレーションのためのモデル

- モデルが巨大化すると計算負荷も増大する
- 剛体
    - 位置・向き
    - 速度、角速度
    - 形状
- 柔軟物
    - 剛体に加え、変形情報が必要
    - 計算負荷が大きい
    - 水や空気はもっと大きい

### 4.3.2 空間のシミュレーション

#### (1)  座標・移動モデル

- ユークリッド座標と姿勢(ロール、ピッチ、ヨー)で表現される
- フライトスルー
    - 鳥瞰的視点が重要な場合
- ウォークスルー
    - 都市景観シミュレーション
    - 障害物との衝突などはユースケースに依る
    - 衝突判定にはbounding volumeなどが用いられる(4.3.3参照)

#### (2) 広い範囲の移動、時間遅れ、ハンドリング

- 広大な空間を描画するのは無理なので空間を区切る
    - グリッドベースが簡単
- Level Of Detail (LOD)
    - 遠くからでも見える場合に有用
    - 遠くのものは精密さを落とす

![JPEG image-9BCED788A5BF-1.jpeg](https://qiita-image-store.s3.amazonaws.com/0/55365/5271a28b-49ec-45dd-106a-41218724e448.jpeg)
引用元: [バーチャルリアリティ学](https://www.amazon.co.jp/%E3%83%90%E3%83%BC%E3%83%81%E3%83%A3%E3%83%AB%E3%83%AA%E3%82%A2%E3%83%AA%E3%83%86%E3%82%A3%E5%AD%A6-%E8%88%98-%E6%9A%B2/dp/4904490053)

- scene graph
    - オブジェクトをツリー構造で表現
    - 効率的な管理やレンダリングの取捨選択に用いられる
    - LODも1つのnode

![JPEG image-9BCED788A5BF-2.jpeg](https://qiita-image-store.s3.amazonaws.com/0/55365/e40de468-0667-2484-d5cf-9fa3a61a5a1a.jpeg)
引用元: [バーチャルリアリティ学](https://www.amazon.co.jp/%E3%83%90%E3%83%BC%E3%83%81%E3%83%A3%E3%83%AB%E3%83%AA%E3%82%A2%E3%83%AA%E3%83%86%E3%82%A3%E5%AD%A6-%E8%88%98-%E6%9A%B2/dp/4904490053)

- バーチャル世界の構築
    - CADや3DCGソフトが用いられる
    - カメラやセンサーから再現する手法も


# まとめ

[一人VR技術者認定試験 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/vr-engineer)の21日目は[【VR学まとめ】4.3.3 物体のシミュレーション](https://qiita.com/nkjzm/items/8c2cf43f19ee845b9964)です。
