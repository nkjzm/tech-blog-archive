---
title: 【VR学まとめ】3.4 入力と出力のループ
published_at: '2018-12-22 05:31'
private: false
tags:
  - VR
updated_at: '2018-12-22T05:31:49+09:00'
id: 076f0fcbf74c6e2213a3
organization_url_name: null
slide: false
---
# はじめに

この記事は[一人VR技術者認定試験 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/vr-engineer)の15日目の記事です。

[バーチャルリアリティ学](https://www.amazon.co.jp/バーチャルリアリティ学-舘-暲/dp/4904490053)の3章「バーチャルリアリティ・インターフェース」の内容をまとめていきます。
書籍の方も是非ご購入いただいた上でご利用ください。

# 3 バーチャルリアリティ・インターフェース

## 3.4 入力と出力のループ

- 入力を処理して出力するまでをリアルタイムに回す必要がある
- 更新周波数
    - センサが毎秒何回データ取得できるか
    - ディスプレイが毎秒何回表示を切り替えられるか
    - 人間は10Hz以上で更新される画像を動画として認識する
    - 深部感覚の力覚刺激は視覚より高速な1000Hz以上が望ましい
- 遅れ(ディレイ)
    - 人間が刺激を受けてから行動に起こすまでの時間が0.2s

# まとめ

人間が知覚するための具体的な数値を知ることが出来ました。

[一人VR技術者認定試験 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/vr-engineer)の16日目は[【VR学まとめ】4.1 総論](https://qiita.com/nkjzm/items/be67688ec1969c7bfd65)です。
