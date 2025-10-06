---
title: SoXを使ったPodcastファイルの最適化
private: false
tags:
  - sox
updated_at: '2020-06-03T23:46:16+09:00'
id: 9bd4b7a064d3056f867a
organization_url_name: null
slide: false
---
# はじめに

[xR.fm](https://xrfm.github.io/)というPodcastをやっているのですが、このご時世でリモートでの収録がメインになりました。そうなると気になるのが会話のラグで、しばし無音区間が生じてしまう状況になりました。そこで、SoX（Sound eXchange, the Swiss Army knife of audio manipulation）というライブラリを使って最適化を行いました。

# コマンド

```bash
# ノイズ除去
$ sox source.wav -n noiseprof noise.prof
$ sox source.wav noise_removed.wav noisered noise.prof 0.2

# コンプレッサ
$ sox noise_removed.wav compressed.wav compand 0.01,1 -90,-90,-70,-70,-60,-20,0,0 -5

# 無音部分の削除
$ sox compressed.wav silence_removed.wav silence -l 1 0.1 1% -1 0.8 15%
```

パラメータ等は調節してご利用ください。

## 結果

冒頭6秒当たり、「パーソナリティのなかじです」に続く「ikkouです」までに、実際はレス待ちの無言時間があったのですが、変換後はその場にいるような速さで聞こえるようになりました。

[第61回「門外不出モラトリアム」 | xR.fm](https://xrfm.github.io/episode/61)

# 参考にした記事

## ノイズ除去

[soxコマンド - memo](https://sites.google.com/site/memo73737/os/linux/soxcommand)

## コンプレッサ

[文化ヒナゲシ制作所雑記帳](http://matosus304.blog106.fc2.com/blog-category-9.html)

[sox - compand - dynamic range compression - Doom9's Forum](https://forum.doom9.org/showthread.php?t=165807)

[音楽ファイル編集コマンド sox の compand オプションを調べてみた - Qiita](https://qiita.com/osamasao/items/ea69a952fc0acb62dfd6)

## 無音部分の削除

[The SoX of Silence](https://digitalcardboard.com/blog/2009/08/25/the-sox-of-silence/)

# 最後に

実際にはMacアプリにして使っています。
ほぼ手間をかけずに音声が劇的に聞きやすくなってとても便利だと思いました。
