---
title: 尊厳死に対する事前指示書（リビングウィル）に電子署名をしてみた
private: false
tags:
  - Security
updated_at: '2020-08-30T10:19:23+09:00'
id: 28751a2763dc2e4bb8e3
organization_url_name: null
slide: false
---

# はじめに

日本には尊厳死に関する法律がありませんが、事前に本人が意思表明をしておくことで一定の効力が期待できるそうです。しかし、生死に関わることですので意思表明における信頼性が担保されていることが、本人や家族、医師にとって非常に重要です。

事前指示書の作成には公正証書として記録する方法が一般的なようですが、今回は少し手軽に電子署名を使った方法で試してみました。

# 環境

- macOS 10.15.6
- Adobe Acrobat Pro DC 2019.21.20058.359605

# 手順

## 事前指示書をPDFとして作成する

こちらのページの例文を参考にしました。

[終末期の医療・ケアについての事前指示書の例文 - リビング・ウィルと事前指示書 -書き方と例文-](http://square.umin.ac.jp/~liv-will/new1017.html)

Google Docsにコピペして体裁を整え、自分の意思に合わせて一部内容を修正します。

![FireShot Capture 043 - 終末期の医療・ケアについての事前指示書 - Google ドキュメント - docs.google.com.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/5e523029-50ad-c8e0-fde7-5cca8f02b94b.png)
https://docs.google.com/document/d/14HxZFImTgo-tRsQJ98-kdcl-TNB2qCO6mduE6zJVmDY/edit?usp=sharing

完成したらPDFとして出力しておきます。

## Adobe Acrobat DCで電子署名をする

下記のページを参考に、署名と証明書発行を行いました。

[[基本操作]　PDF ファイルに電子署名を追加する](https://helpx.adobe.com/jp/acrobat/kb/235107.html)

「署名後に文書をロックする」というチェックボックスが表示されますが、これはPDFを読み取り専用にするということです。これにより他の署名を追加できなくなるため、最後に署名する人はチェックを入れておくと良いでしょう。（今回は家族の署名を省略しているので自分でチェックを入れました）

![スクリーンショット 2020-08-30 9.21.50.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/bd3a419b-f526-9a4e-c946-c186a9c1bd52.png)

署名後は再度PDFとして出力します。

## 署名済みの事前指示書を配布する

電子署名の仕組みには公開鍵暗号方式が用いられています。そのため、署名（暗号化）の際に使った鍵ペアから公開鍵を証明書として書き出すことで、信頼性を証明することができます。こちらも、先ほどの記事の手順にそって証明書ファイル(`.fdf`)を出力しておきました。

今回はGoogle Driveを使って配布を行います。ライフサイクルに応じて文章を更新する場合があると思うので、必ずフォルダ単位で共有するようにしたいと思います。

![スクリーンショット 2020-08-30 9.44.21.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/817fd369-7316-804f-6918-4aca2d5fde3f.png)
https://drive.google.com/drive/folders/1pnCqFogXOdPdjUjxZE_dQGZ73lCh6puS?usp=sharing

情報を辿りやすいよう、[Notion上の自分の公開Wiki](https://www.notion.so/nkjzm/f7c58881a3a34a94a0f3e64b8034226d)にもまとめておきます。
![スクリーンショット 2020-08-30 10.14.36.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/be51eaf4-8e5a-96a7-e88a-89375d2c942c.png)
https://www.notion.so/nkjzm/3253c053e2a14bcfb9ed48d4e45e23d3

最後にこのページを家族に共有して終わりです。

## 考えられる脆弱性

電子証明書自体は公開鍵によって証明できますが、署名に使っている鍵ペアは自身のPC上で作成したものであるため公開鍵自体の信頼性は自分で担保する必要があります。そのため、公開鍵毎差し替えらた場合はなりすましや改竄等のリスクがあるといえるでしょう。公開鍵を配布しているGoogle DriveやNotionの扱いには十分に注意する必要がありそうです。

# 最後に

理解が誤っている部分などあれば、ぜひご指摘いただけると嬉しいです。

最後に自己紹介です。普段から自分の人生をインターネットで公開しています。よかったら是非フォローしてください！ 
Twitter: [@nkjzm](https://twitter.com/nkjzm)

