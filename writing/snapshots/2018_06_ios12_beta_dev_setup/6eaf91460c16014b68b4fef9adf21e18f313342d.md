---
title: "iOS12betaで開発する時の環境準備の備忘録"
emoji: "📱"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["iOS"]
published: true
---
ARKit2 betaを使うために初めてiOSのbeta版導入したので、その時のメモ
必要条件じゃない可能性もあるけど、一応この通りにすれば動くはず

# iPhoneにiOS 12 betaをインストールする

https://developer.apple.com/download/
上記ページから、「iOS 12 beta」のDownloadリンクをクリック

落ちて来た`iOS_12_Beta_Profile.mobileconfig` をAirDropでiPhoneに渡して認証する。

iOS 12 betaのインストールが始まる (`設定 > 一般 > ソフトウェア・アップデート` で確認できる)

# MacでiOS 12 beta向けのビルドをできるようにする

リリース版のXCodeだとビルドできなかったので、Xcode 10 betaを入れたらビルドできた。

リリースノートによると`macOS 10.13.4`以上が必要 (リリース版のmacOSで満たせるバージョン)
https://download.developer.apple.com/Documentation/Xcode_10_beta_Release_Notes/Xcode_10_Beta_Release_Notes.pdf

ダウンロードはここから
https://developer.apple.com/download/

もしかしたらXCode入れ直さなくても「デバイスサポートファイル」とやらがあればビルドできるかも？
https://qiita.com/yamataku29/items/6fdc9e512b42d7f66386

# 謝辞

教えてくれてありがとう

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">イメージファイルじゃなくて、プロファイルの方ダウンロードしてiPhoneにAirDropで送ればiPhoneにbetaのOTA降ってくるけど。</p>&mdash; iyuto (@iyuto_) <a href="https://twitter.com/iyuto_/status/1007813064085737472?ref_src=twsrc%5Etfw">2018年6月16日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
