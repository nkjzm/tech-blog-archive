---
title: "iPhone->iPhoneの個人的移行手順メモ (二段階認証, Wallet, LINE)"
emoji: "📱"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["iOS"]
published: true
---
## はじめに

iPhoneを移行するたびにやることリストを書き出すのが面倒なので、このページだけみれば分かる状態にしておきたいと思います。

**移行元のiPhoneが必要になる**手順があるので、下取りなど出す場合は注意してください。

### 検証環境

- macOS High Sierra 10.13.5
- iTunes 12.8.0.150
- 移行元iPhone: iPhone 8 Plus
- 移行先iPhone: iPhone XS

## iTunesでバックアップの作成と復元

### 【移行元iPhone】 バックアップの作成

時間の目安: 1時間程度 (作業時間は2,3分)

Macに移行前のiPhoneを繋ぎ、iTunesからバックアップを作成します。

下記現象が起きる時がありますが、待ってたらバックアップ始まりました。
[iTunesバックアップで「iPhoneのバックアップのロックを解除するために入力したパスワードが間違っていました。やり直してください」が表示されたときのポイント](https://did2memo.net/2015/09/27/itunes-backup-backup-lock-password-error/)

余談ですが、iPhoneのバックアップファイルはかなり容量が大きいので、僕は保存先を外付けHDDに変更しています。おすすめです。
[【Mac版】iPhone&iPadのバックアップ保存先をMac本体内から外付HDDに変更する手順 | HYZ STUDIO BLOG（ハイズスタジオブログ）](https://hyzstudioblog.com/technology/486/)

### 【移行先iPhone】 バックアップからの復元

時間の目安: 1時間程度 (作業時間は2,3分)

Macに移行後のiPhoneを繋ぎ、iTunesからバックアップから復元をします。

## LINEの移行

時間の目安: 5分程度

### 【移行元iPhone】 LINEでの設定

友達タブ>左上の設定アイコン>`[アカウント引き継ぎ]`>`[アカウントを引き継ぐ]`のトグルをオンにする

また、事前にメールアドレスとパスワードが設定されていることを確認しておいてください。

### 【移行先iPhone】 LINEのログイン

移行先iPhoneでLINEにログインします。

ログインに成功すると、移行元iPhoneのアプリ情報が全て初期化されるため注意してください。(少しラグがありました)


## Wallet

時間の目安: 10分程度

チケットなどは基本的にバックアップ経由で自動的に移行されると思います。

### Quick Pay / iD

Walletを開き、`[+]`アイコンからクレジットカードの追加を選ぶと、移行元iPhoneで登録されていたカードを登録する画面になります。セキュリティコードを入力すると登録することができます。

### モバイルスイカ

同時に複数の端末上に表示できない仕様なようです。

> 【Suica情報の端末間移動手順】
> ---旧端末にて---
> ① Walletを起動
> ② 設定されたSuicaを選択（1枚ずつ）
> ③ 画面右下の i ボタンをタップ（Apple Watchの場合はSuicaの画面を強く長押し）
> ④ 「情報」タブを選択（Apple Watchの場合は手順④はありません）
> ⑤ 「カードを削除」をタップ　※削除するとiCloudに紐づいたサーバに退避されます。
> ---新端末にて---　Touch ID/Face IDの設定は以下手順の前にお済ませください。
> ⑥ Walletを起動
> ⑦ 右上の + ボタンをタップ
> ⑧ Apple Payの案内画面は「続ける」をタップ
> ⑨ カードの種類「Suica」をタップ
> ⑩ カードを追加で⑤操作より退避されたSuicaが表示されますので「次へ」をタップ（1枚ずつ）

引用元: [【機種変更】Apple PayからApple Payへ（iPhone/Apple Watch→新しい | Suica Apple Pay よくあるご質問](http://appsuica.okbiz.okwave.jp/faq/show/1537?site_domain=default)


## Authenticator(二段階認証アプリ)の移行

時間の目安: 15分程度

このアプリ上での情報は自動的に移行が行われません。
各種サービスから設定しなおす必要があるのですが、その際にログインが必要になる場合があります。
移行前iPhoneの二段階認証アプリを使うか、もし手元にない場合はリカバリーコードから復元してください。
どちらもない場合、サービスによっては復元不可能なものもあるので注意してください。

### Google

以下のページを開き、認証システム アプリの`[スマートフォンを変更]`から設定してください。

2 段階認証プロセス
https://myaccount.google.com/signinoptions/two-step-verification

リカバリーコードは更新されませんでした。

### GitHub

以下のページから設定してください。
https://github.com/settings/two_factor_authentication/intro

GitHubの場合は認証端末を変更した場合にリカバリーコードも更新されるようなので、途中で表示されるコードはしっかり保存するようにしてください。(設定完了後の画面での表示できます)

### Qiita

更新するためには、以下のページから一度二段階認証を無効にして再度設定してください。
https://qiita.com/settings/two_factor_authentication/configure

リカバリーコードも更新されるので、保存しておいてください。

### Trello

https://trello.com/2fa

リカバリーコードは更新されませんでした。
また、Googleアカウント経由でログインする場合、こちらの二段階認証は適用されないようです。

### Discord

解除から再度設定してください。

https://discordapp.com/activity

リカバリーコードも更新されるので保存してください。

### Facebook

https://www.facebook.com/security/2fac/settings/

~~リカバリーコード更新されました。~~
リカバリーコードは更新されませんでした。

### Twitter

`モバイルセキュリティアプリ`を一度offにすると変更することができます

https://twitter.com/settings/account/login_verification

リカバリーコードは更新されませんでした。

## 感想

二段階認証アプリの移行が面倒だったので、あんまり使わないサービスは二段階認証使わなくてもいいかもしれないと思いました。
