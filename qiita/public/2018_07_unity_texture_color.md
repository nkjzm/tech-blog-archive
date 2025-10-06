---
title: Unityでインポートしたテクスチャの色味がおかしい
private: false
tags:
  - Android
  - Unity
updated_at: '2018-07-07T16:05:01+09:00'
id: 1acc5c06bcd8fb7c1165
organization_url_name: null
slide: false
---
# 現象

![31a9e421-61a3-6ef4-c7cf-f85b63d34c59.png](https://qiita-image-store.s3.amazonaws.com/0/55365/d5a56837-3a0e-69ba-d1c8-4b904471bd5b.png)

左が本来の画像の色、右がUnity上での画像の色(少し紫がかって見える)

# 解決方法

Android向けのビルド設定になっていたので、Texture Import SettingのDefaultのFormatで色数の少ない形式になっていた(多分)。

<img width="469" alt="627805b1-01bd-74ef-2179-6075f8932f6f.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/53afabf7-25bf-7db8-ff53-da24a3b019c1.png">


Autoになっているところは、おそらくプラットフォーム毎にデフォルト値が設定されているような気がする。

<img width="477" alt="8b0ba176-7b19-a30c-f46e-efa2232ff9c0.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/78e2d971-8a01-f94e-9ba8-9ba1f8024a63.png">


プラットフォーム毎のOverride設定で色数の多いformatにしたら解決した。

