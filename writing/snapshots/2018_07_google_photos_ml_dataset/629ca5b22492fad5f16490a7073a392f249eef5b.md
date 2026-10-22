---
title: "Googleフォトの自撮りから約7,500枚の学習データを作る"
emoji: "📚"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["機械学習"]
published: true
---
# はじめに

GWに機械学習したくて自分の顔写真から学習データを作りました。
現在7,555枚あるので、ある程度何かに使えるような気がします。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">僕の学習用顔写真データ(約1,200枚)を無料公開します。改変、商用利用、配布等全て自由です。機械学習等に是非ご活用ください〜。<a href="https://t.co/V5zgNlZ6Sh">https://t.co/V5zgNlZ6Sh</a> <a href="https://t.co/wjsf0shDjQ">pic.twitter.com/wjsf0shDjQ</a></p>&mdash; Nakaji Kohki (@kohki_nakaji) <a href="https://twitter.com/kohki_nakaji/status/990879912453013504?ref_src=twsrc%5Etfw">2018年4月30日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

以下で公開中です。

LearningData_face - Google ドライブ
https://drive.google.com/drive/folders/1riyyDR5E59rvp6BFJK81CkguymsH-fmj


# やり方

1. GooglePhotoから自分のタグがついた画像一覧を表示してダウンロードする
 - 動画が含まれているとDLに時間がかかるから注意
 - 一度にDLできる項目は500件まで
2. このリポジトリのREADMEに従ってExtractコマンドを叩く(内部でOpenCV呼び出してるだけっぽい)
 -  deepfakes/faceswap: Non official project based on original /r/Deepfakes thread. Many thanks to him!
 -  https://github.com/deepfakes/faceswap
3. エラー画像を取り除く
 - 顔写真ではないもの
 - 自分以外の写真
 - 他の人が写り込んでいる写真
