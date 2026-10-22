---
title: "Vive Focusでプレイエリア制限(Out of boundary)を解除して歩き回る方法"
emoji: "🥽"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["VR"]
published: true
---
# はじめに

**※2018/11/26更新**

Vive Focusがいよいよ日本でも発売になりましたね！

Vive Focusといえば、なんと言っても「**Surroundings Mode**」が魅力的ですよね！正面についた2つのカメラを使い、ビデオシースルーで現実世界を見ることができます。
([See real surroundings](#Seerealsurroundings)の設定が必要です)

![screenshot-1541755822208.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/f98e1048-86b3-b465-7814-7aa3ce2414ac.jpeg)

白黒ではありますが解像度やFPSはそこそこあります(カメラ性能のソースは見つからず…)。また、二眼なので視差もあり、奥行きを知覚することも可能です。厳密にはカメラと目の位置は一致していないので多少のズレは感じますが、付けていると思ったよりも違和感はありません。物を掴んだり立って移動することも出来ます。

また、取り込んだカメラの映像に加工をすることも可能です。
[Beat Reality](https://skarredghost.com/2018/09/14/the-world-is-your-dancefloor-with-beat-reality/)というアプリを使うと、このように現実世界をサイケデリックなエフェクトがかかった状態で見ることができます。

![screenshot-1541756089641.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/edf09a67-761c-0ba2-05e0-c7847709af78.jpeg)


そんな**Surroundings Mode**ですが、少し離れたところに歩いていくとこんな表示が出ます。

![screenshot-1541755119423.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/c480926b-dde9-d570-c405-0d1ef37cbc4a.jpeg)

> **Out of Boundary**
> Please return to the area, or put on the headset again in clear space to reposition the play area.

「プレイエリアに戻るか、ヘッドセットを外して安全を確かめてから再スタートしてください」という旨のメッセージです。確かにVRコンテンツの体験中、プレイヤーは現実世界の周りの状況が分からないのでこういった警告は必要です。ただ、今回のようにビデオシースルー表示をしている場合は周りの状況が分かるので、もっと移動できてもいいはずです。**なんならVive Focusを付けた状態で生活したいです！**

ということで、今回はプレイエリア制限を解除する方法を紹介したいと思います！

**注意:**
*本来想定された使い方ではないと思うので、自己責任でお願いします。*
*この設定をした後にVRモードを利用する際には注意が必要です。*

# バージョン

Build number
1.52.1405.1 9.0_g CL1044348 release-keys

これ以下のバージョンでは設定項目が存在しない場合があるので、ご注意ください。
アップデートはホーム画面から「Settings」>「System Update」からいけます。

# プレイエリア制限(Out of boundary)を解除する

3つの設定項目があります。
状況に応じて使い分けてください。

| 設定名 | 場所 | デフォルト値(1.52.1405.1以降) | 挙動 |
| --- | --- | --- | --- |
| Passenger mode | Developer options以下 | ON | **ON**にするとポジショントラッキングが無効になる |
| Safety virtual wall | Headset & Space以下 | ON | **OFF**にすると境界線が非表示になる | 
| See real surroundings | Headset & Space以下 | OFF | **ON**にするとビデオシースルーモードを有効になる |

## TL;DR

| 設定名 | ビデオを使わないアプリ | ほとんど移動しないARアプリ | 室内を歩き回るARアプリ | 外を歩き回るARアプリ | 
| --- | --- | --- | --- | --- |
| Passenger mode | **OFF** | **OFF** | **OFF** | **ON** |
| Safety virtual wall | **ON** | **ON** | **OFF** | **OFF** |
| See real surroundings | **OFF** | **ON** | **ON** | **ON** |

## Passenger mode

**ON**にするとポジショントラッキングが無効になる機能です。結果として「Out of Boundary」の警告も出なくなりますが、[Safety virtual wall](#Safetyvirtualwall)で代用できないか検討した上でお使いください。


ホーム画面で、下部のメニューバーより「Settings」を選択します。
![screenshot-1541757667229.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/bbd3c22a-d059-01bf-28de-0a6bfdc04b9d.jpeg)

「More Settings」を選択します。
![screenshot-1541757693524.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/ee24fcf6-0af8-3ddc-0a18-91dcd0686949.jpeg)

Androidっぽい設定画面になるので、下の方の「Developer options」を選択します。この選択肢が表示されていない場合は開発者モードに切り替わっていません。その下の「About device」を選択し、次の画面で「Build number」を数回クリックすると開発者モードになると思います。
![screenshot-1541757753133.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/11ae8e66-ad94-32e2-3060-0c8f7dcd088d.jpeg)

設定を開くとすぐ下に「Passenger mode」があります。このモードを有効にすると、プレイエリア制限が表示されなくなります。
![screenshot-1541754856908.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/262b4529-ab1d-b88a-bff8-073342b3479f.jpeg)

ただし、説明文には以下のように記載されています。

> Locks your position while in a moving vehicle or dark surroundings

「乗り物での移動中や暗所にいる間、ポジションを固定する」という旨です。また、有効にしようとすると次のようなダイアログが表示されます。
![screenshot-1541754890008.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/0f02aeb2-14eb-feca-a3f2-9a434a63045a.jpeg)

> **Turn off positional tracking**
> When positional tracking is turned off, the virtual wall will NOT show. Always be aware of your surroundings when moving around. Are your sure you want to continue?

「**ポジショントラッキングを無効にする** / ポジトラを無効にすると境界線が表示されなくなります。移動する時は常に周囲に注意してください。続けますか？」という旨のテキストです。

つまり、この方法はプレイエリア制限を解除するというよりは、ポジショントラッキング自体を無効にした結果プレイエリアの概念がなくなる、という表現が適切だと思います。実際にこの設定すると、VRモードでは3DoFの動きになります。ポジトラが無効になるので、空間にARオブジェクトを固定することもできなくなります。この点に十分に留意した上でお使いください。

ただし、ビデオシースルーモードにおいても[Safety virtual wall](#Safetyvirtualwall)より優れた点があります。

![screenshot-1543215426793.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/ec251856-ca08-f704-e414-25c15dc6800a.jpeg)

上記警告はトラッキングが外れた場合に表示される警告です。カメラ自体を手で覆ったりすると確認できます。これはビデオシースルーモードであっても全画面に表示されます。野外で使う場合にこの表示が出ると大変危険なので、そういった用途には「Passenger mode」は最適だと思います。

## Safety virtual wall

**OFF**にすると境界線が表示されなくなります。

![screenshot-1543215410585.jpg](https://qiita-image-store.s3.amazonaws.com/0/55365/636a90e9-d264-219f-0a5d-448fb9c23f17.jpeg)

上記のように警告がでるのですが、歩き回るコンテンツを作る場合は十分留意した上で無効にしてしまって良いかと思います。

ただし、トラッキングが外れた場合には全画面で警告が出るので、[Passenger mode](#Passengermode)を参考に最適な設定を検討してください。

## See real surroundings

**ON**にすると、電源ボタンを2回連続で押すとビデオシースルーモードに切り替えられるようになります。特別な理由がなければ**ON**にしておいて良いかと思います。

