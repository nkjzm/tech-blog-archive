---
title: '姿勢推定メモ '
private: false
tags:
  - VR
updated_at: '2018-10-04T17:06:59+09:00'
id: 2714e96c5f289e0c1203
organization_url_name: null
slide: false
---
RGB画像から姿勢推定する技術の話

# OpenPose

https://qiita.com/nnn112358/items/a4490d85dac5827db53b

- 1番有名くらいらしい
- 画像から2Dスケルトンを検出可能
- 複数角度の結果を合わせれば理論上3Dスケルトンも検出可能
- 商用がだめっぽい
- ライセンスがある
https://flintbox.com/public/project/47343/

# DensePose

http://densepose.org/

- 3Dのメッシュ情報を推定可能
- OSSになった
- 配布されている学習モデルが非商用CC

# Human Mesh Recovery

https://akanazawa.github.io/hmr/

- 3Dのメッシュ情報を推定可能

# VNect

http://gvv.mpi-inf.mpg.de/projects/VNect/

- 3Dスケルトンを検出可能
- 学習済みモデルはメールしないともらえない
- tensorflowでやってる人もいるらしい
    - https://github.com/timctho/VNect-tensorflow
    - 学習済みモデルはこっちも個別で交渉

# Mask R-CNN2Go

https://research.fb.com/enabling-full-body-ar-with-mask-r-cnn2go/

- Facebookが作ってる
- **モバイルでも動く** (すごい)
- 公開されてない


