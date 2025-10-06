---
title: Vysor + VLCでOculus Goを録画する
private: false
tags:
  - VR
updated_at: '2018-06-26T09:03:38+09:00'
id: 1dec06e74211fe646145
organization_url_name: null
slide: false
---
# はじめに

Oculus Goではホームのシェアタブから画面を録画する機能が用意されているが、何故かアプリを起動すると録画が停止してしまう。そこで今回はOculus Goの映像をMacに出力し録画する方法を検討してみた。

# 前提

Mac: macOS High Sierra 10.13.5
VLC: 2.2.6
Vysor Pro: 1.9.3

Vysorは有償版でしか試していないので、無償版だと出来ないかも。

# 手順

## Macにミラーリング

以下の記事を参考にした。

Oculus Goの画面をPCに表示させる with Vysor【無線もできた！！！！！！】 - トマシープが学ぶ
http://bibinbaleo.hatenablog.com/entry/2018/05/14/115112

Oculus Goの画面をPCにWirelessでミラーリング表示する - Qiita
https://qiita.com/zinziroge/items/84b06ab47168d68dc962

無償版だと1.5時間のトライアルが付いているが、それを過ぎると解像度が低かったり広告が出たりする。
その場合、用途に合わせて有償版を検討してください。サブスクリプションと買い切り(4kくらい)がある。
http://www.vysor.io/#pricing

## VLCで録画

### Web Video StreamのURLの取得

<img width="509" alt="スクリーンショット_2018-06-26_8_29_57のコピー.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/911c2b26-9a0a-5880-c5b9-0a5113b76e6c.png">

設定ボタンを押して

<img width="487" alt="スクリーンショット_2018-06-26_8_30_09_のコピー.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/6308feac-2b2c-5c36-9368-a77ff1915b8a.png">

下の方にあるWeb Video StreamのURLを取得する。
クリックするとクリップボードにコピーされる。

### VLCの設定

#### URL設定
VLCのメニューより、`ファイル > ネットワークを開く`を選択。(もしくは `⌘ + N`)

URLに先ほどのURLを入力しておく。
この状態で開くを押すと、VLC上でキャプチャした映像が再生される。
_※ただし10秒くらいラグがある。_

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">VLCでStreamingのurl開けた。録画できそう。 <a href="https://t.co/1ayTQa4w1d">pic.twitter.com/1ayTQa4w1d</a></p>&mdash; Nakaji Kohki (@kohki_nakaji) <a href="https://twitter.com/kohki_nakaji/status/1011365600814198786?ref_src=twsrc%5Etfw">2018年6月25日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

#### 録画設定

<img width="624" alt="スクリーンショット_2018-06-26_8_39_09.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/73c5917d-5b40-1194-dd5c-c895e281d6ec.png">

「ソースを開く/ネットワーク」の画面より、「ストリーミング/保存」の項目にチェックを入れる。
その状態で右側の設定ボタンをクリック。

<img width="575" alt="スクリーンショット_2018-06-26_8_39_51.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/f015cb22-8c40-abd8-4200-92a5027d3d71.png">

上記のように設定する。

カプセル化を入力してからファイルの参照を設定すると、適切な拡張子を提示してくれる。順番に注意。

フォーマットはMPEG 4で試したが、ストリーム中に欠損してしまう箇所があった。要検証。
MPEG TSも録画できることを確認した。Quicktimeは確認できなかった。Rawは再生の仕方が分からなかった。

_(コンバートが発生しないフォーマットにすれば良い気がするが、URLの.flvに合致する項目がないように思う)_

オプションとして、「ストリーム出力の表示」にチェックを入れておくと、録画中の画面を表示することができる。

「ロー入力データをダンプ」にチェックを入れるとうまく出力されなかったので、これも注意。

最後にOKボタンを押して設定完了。
ちなみにVLCを再起動するとこの設定はリセットされてしまう。地味にだるいので保持する方法分かる方は教えて欲しいです。

### 録画開始

VLCの「ソースを開く/ネットワーク」の画面より、「開く」をクリックすると録画が開始される。
「ストリーム出力の表示」にチェックを入れている場合、数秒後に映像が表示される。

録画を停止する場合はプレイヤーの停止ボタンをクリックする。
停止ボタンをクリックしても動画ファイルが再生できない場合は、設定を見直した方が良いかも。


# 課題

## ファイルの欠損

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">お、アプリ内画面も録画できた<br>(一部データ欠損してそう) <a href="https://t.co/NxgW4OGTLm">pic.twitter.com/NxgW4OGTLm</a></p>&mdash; Nakaji Kohki (@kohki_nakaji) <a href="https://twitter.com/kohki_nakaji/status/1011371945726640129?ref_src=twsrc%5Etfw">2018年6月25日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

上記の手順により、一応こんな感じで録画が成功した。
ただし、FPSがおかしかったり、途中に欠損したフレームがある。

Mac上で確認するとFPSは正しかったので、うまく変換すればいける気もする。


## 音声の録音

今回の方法だと音声を録音することが出来ない。
そもそもVysorが音声の出力に対応していないので、別の方法を検討する必要がある。

Oculus Goにはイヤホン出力端子があるので、それを拾う方法が一つ考えられる。
また、Vysorと似たようなサービスの「Reflector」を使うと音声も出力できるらしい(未検証)


# さいごに

間違っている箇所や、こうすれば出来るというアドバイスなどお待ちしております！
