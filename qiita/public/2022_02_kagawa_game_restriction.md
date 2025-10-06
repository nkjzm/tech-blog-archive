---
title: 【香川県】App Storeのガイドラインに抵触しない「ゲーム依存症対策条例案」対応を実装してみた【Unity】
tags:
  - iOS
  - Unity
private: false
updated_at: '2025-10-06T21:48:16+09:00'
id: 4b0a6600e16a4eff3dbe
organization_url_name: null
slide: false
ignorePublish: false
---
![タイトルなし3.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/3f8fe2e6-9d10-511e-d1eb-9cdc8b5ac610.gif)

## はじめに

香川県議会による「**ネット・ゲーム依存症対策条例案**」が話題になっています。

これは18歳以下の子どもがネット・ゲーム依存状態になることを防ぐ目的で、ゲームのプレイ時間を平日は60分(休日は90分)までに制限する項目が盛り込まれています。

問題は、ゲームソフトを提供する事業者等に対しても上記の条例に対して協力する義務を課せられる可能性があります。可決されたら**令和2年4月1日より施行**されるため、開発者としては早急に今後必要な対策が気になるところです。

<img width="435" alt="スクリーンショット 2020-01-24 1.02.50.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/4a8a838a-eb47-7623-76c6-608d84824471.png">
出典: [香川県の「ネット・ゲーム依存症対策条例案」【全文】 - ITmedia NEWS](https://www.itmedia.co.jp/news/articles/2001/21/news135.html)

この記事ではiOS向けのApp Storeに配布されるゲームアプリにおいてどういった対応ができるか検討し、Unityを使って実装してみました。

_※ 専門的な法律の知見に基づくものではないので、情報の取り扱いは自己責任でお願いします。_

# 条例により課せられる制限と対応

第１８条２項より下記のような基準になります。(第２条（４）より、「子ども」とは18歳未満の者を指すようです)

- 総利用時間の制限
    - 18歳未満
        - 通常: **1日60分まで**
        - 休日: **1日90分まで** (学校等の休業日)
- 利用時間帯の制限
    - 15歳以下: **21:00まで** (義務教育修了前)
    - 18歳未満: **22:00まで**

ただし、これらはあくまで基準で「子どもの年齢や各家庭の実情等を考慮し、話し合いの上で使用に関するルールづくりをする」という旨の記載があります。正確に準拠するのなら各家庭の状況に応じて規制の強化・緩和を行えるべきかもしれませんが、今回は考慮していません。

###『あなたは香川県民ですか？』は実現可能か

法律的には「[属地主義の原則](https://kotobank.jp/word/%E5%B1%9E%E5%9C%B0%E4%B8%BB%E7%BE%A9-167398)」という考え方があるそうです。これは、法律は定められた領土内に対して適用されるというもので、例えば国内の法律は原則として海外にいる時に適用されません。今回の条例をこの考えに照らし合わせて考えると、適用される人は「**香川県民**」ではなく「**今現在香川県内にいる人**」となりそうです[^1]。

[^1]: 「属地主義の原則」を適用すると香川県外のゲーム事業者に対応の義務はないのではないかという議論もあるようです。

この場合、実装としては**GPSなどを用いたリアルタイムの位置情報**を利用することが好ましいかと思います。

### 年齢に関する情報の取得

条例案の対象になるのは18歳未満の子どもですが、その中でも段階的な利用時間帯の制限があるため、3段階の区別が必要になります。「義務教育修了前の子供については」という記載があるため、年齢よりも中学生以下かどうかで区別する方が好ましそうです。

質問形式による取得の場合、虚偽の情報を入力できてしまう可能性が考えられます。一部マッチングアプリやペイメント系サービスのように本人確認書類等を用いた年齢認証を行う方法もありますが、[こちらの記事](https://www.itmedia.co.jp/news/articles/2001/22/news122.html)によると香川県議会の「自主的な対策を行って欲しい」という旨の説明をしているため、そこまで厳格な対応は必要ないように思います。

余談ですが、韓国のシャットダウン制では住民登録番号を用いた識別が義務付けられており、違反したメーカーは2年以下の懲役、又は1千万ウォン（約75万円）以下の罰金の処罰が下されるそうです。

参考: [韓国最新オンラインゲームレポート　「青少年夜間ゲームシャットダウン制」に揺れる韓国オンラインゲーム業界 - GAME Watch](https://game.watch.impress.co.jp/docs/series/korea/446640.html)

### プレイ時間の制限

単一のゲームでプレイ時間の制限を行うことは難しくないです。アプリの起動時間を計測し、規程の60分を経過した時点でプレイに制限をするような実装になるかと思います。時間帯についても、端末もしくはネットワークを介した現在時刻を取得すれば実現できます。

問題は「**複数のゲームのプレイ時間を合算した制限をかける必要があるのか**」という点です。例えば、一つのゲームを60分間遊んだ後に制限されてしまっても、別のゲームでは制限がかかっていない状態で遊べてしまうような状況が考えられます。

この対策には各事業者毎のゲームにおいてプレイ時間を記録し、ネットワークを介して共有するような仕組み作りが必要なので非常に困難です。少なくとも単一の事業者で対応できるようなことではないため今回は考慮しないものとします。

## App Store Reviewガイドラインに抵触しそうなポイント

[App Store Reviewガイドライン](https://developer.apple.com/jp/app-store/review/guidelines/) (日本語)

個人情報の収集に関する項目で抵触する可能性があり、最悪の場合アプリのリリース審査に通らない場合が考えられます。特に近年のAppleは個人情報の保護に非常に力を入れており、例えば2018年10月からは全てのアプリにプライバシーポリシーが必須となりました。

参考: [予定されているプライバシーポリシー要件の変更について。 - ニュース - App Store Connect - Apple Developer](https://developer.apple.com/jp/app-store-connect/whats-new/?id=100002362)

抵触しないためには「何のために収集するのか」をユーザーにきちんと示すこと、不必要な情報を収集しないこと、また上記のプライバシーポリシーの提出が必要だと思います。

参考: [個人情報を送信するアプリには必然性がいる 〜 17.2対応 - Qiita](https://qiita.com/nofrmm/items/a646291a8c83bbcf3908)

### 「子ども向け」カテゴリの場合

さらに、App Storeの「子ども向け」カテゴリでは、子ども達が安心して遊べるようより厳格な個人情報の保護が求められています (ここでいう「子ども」は11歳以下を指す([参考](https://developer.apple.com/jp/app-store/categories/))))


> 「子ども向け」カテゴリのAppでは、個人を特定できる情報またはデバイス情報を第三者に送信することはできません。また、「子ども向け」カテゴリのAppには、他社製の分析機能や広告を組み込むことはできません。

参考: [1.3 「子ども向け」カテゴリ](https://developer.apple.com/jp/app-store/review/guidelines/#kids-category)


これを見ると一切の個人情報の収集が認められていないように見えますが、法的事項/プレイバシーに関する章には下記のようにも記載されています。

> 多くの理由から、子どもの個人データを扱う場合は厳重な注意が求められます。児童オンラインプライバシー保護法（COPPA）やEU一般Data protection規則（GDPR）のような法律、およびその他の適用される規制または法律をすべて慎重に確認してください。
> Appでは、これらの法律に準拠する目的でのみ生年月日や保護者の連絡先を要求することができます。

参考: [5.1.4 「子ども向け」](https://developer.apple.com/jp/app-store/review/guidelines/#kids)

今回の条例案は「その他の適用される規制または法律」に該当するように思うので、準拠する目的に限定していれば認められそうです。

### 余談: ペアレンタルコントロール

iOS 12以降のペアレンタルコントロールという機能では、保護者がアプリのカテゴリ毎に起動時間の制限をかけることができます。下記の画像のように、ゲームカテゴリに対して制限時間を設定すると、上限時間を超えた場合に該当アプリがグレーアウトする仕様になっています。

![1579951896.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/e31932ab-03f4-0089-5565-01ed9b89ff35.jpeg)

各ゲーム事業者の立場では対応に限界があるので、香川県にお住まいのお子さんにiPhoneを貸与している保護者の方は是非ご活用ください。

参考: [お子様の iPhone、iPad、iPod touch でペアレンタルコントロールを使う - Apple サポート](https://support.apple.com/ja-jp/HT201304)

## 条例に準拠したUnity製サンプル【Udon】

上記を踏まえ、以下のようなダイアログを実装してみました[^2]。

[^2]: ガイドラインを考慮して実装したものですが、リジェクトされないことを保証するものではありません。

GitHub: [nkjzm/Udon](https://github.com/nkjzm/Udon)
![タイトルなし3.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/3f8fe2e6-9d10-511e-d1eb-9cdc8b5ac610.gif)

(Gif画像にはリポジトリには含まれていないフォント([URW MARU GOTHIC](https://jp.designcuts.com/product/greatest-japanese-fonts-bundle/))と画像アセット([Simple UI](https://assetstore.unity.com/packages/2d/gui/icons/simple-ui-103969))を使用しています)

### サンプル(Udon)の使い方

[リポジトリ](https://github.com/nkjzm/Udon)の[Releases](https://github.com/nkjzm/Udon/releases)から最新の`*.unitypackage`をダウンロードし、Unityプロジェクトにインポートしてください。[Google Geocoding API](https://developers.google.com/maps/documentation/geocoding)を使用しているため、別途API Keyの取得が必要です。

```cs
var popup = Instantiate(Prefab, Canvas.transform);
popup.Open(onComplete: flg =>
{
    Debug.Log(flg ? "設定完了" : "未完了");
});
```

表示の際には`Instantiate`メソッドで生成し、`Open()`メソッドを呼んでください。

### ポイント①: 個人情報収集の目的を明記する

ダイアログ内では収集する目的や背景を説明した上で、これ以外の目的にしようしないことを明記しています。また、画面下部にはプライバシーポリシーのリンクも設置しています。

### ポイント②: 年齢の確認

今回の用途では正確な生年月日は必要ないため、どの区分に該当するかどうかのみを質問する形式にしました。入力が容易であるというメリットもあります。

ただし時間の経過で区分が変わった場合に対応できないデメリットがあり、後から登録した区分を変更する機能は子どもが制限を解除するため悪用されるリスクが伴います。ゲームアプリにおいては課金上限額の設定のため年齢確認をすることがありますが、毎回未成年かどうかを質問する例(『[どうぶつの森 ポケットキャンプ](https://ac-pocketcamp.com/ja-JP/site)』)や、生まれた月までを登録して後から変更できない例(下記画像)、変更の際には運営への問い合わせが必要な例(『[荒野行動](https://www.knivesout.jp/)』)などがあるようです。

![622346685927b307757b70011-1495773978.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/48a69cde-5a5a-7d4c-73e4-0be0da5b0ca9.jpeg)

出典: [ブシロードとKLab、『ラブライブ！スクフェス』で年齢別課金上限を設定…未成年者保護のため | Social Game Info](https://gamebiz.jp/?p=185539)

ハイブリットな手法として、として、18歳未満の選択肢を答えた場合のみ「生まれた年と月」を入力してもらうような方法も良いかもしれません。

<img width="591" alt="スクリーンショット 2020-01-26 7.13.34.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/02487400-6579-1d74-7e36-9c622577cad2.png">

### ポイント③: 二つの方法で位置情報を設定する

GPSを用いた位置情報取得では、iOSのシステムダイアログ上でユーザーに権限の許可をしてもらう必要があります。システムダイアログを表示する前に、きちんとユーザーに目的を伝えることが大切です。

<img width="285" alt="スクリーンショット 2020-01-26 7.17.17.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/e38262be-e119-eff9-88a3-87ae516d9b55.png">
_↑ボタン内に確認画面が出る旨を表記しました_

ボタン押下後の画面は下記のようになっています。

![1579991647.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/9cf3876b-55c9-de16-f2ff-6b30bc137968.jpeg)

_↑左が取得が成功した場合、右が取得に失敗した場合_

位置情報の取得が成功した場合、GPSの緯度経度からどの県にいるかを取得し表示しています。

取得に失敗した場合ですが、二通りの状況が考えられます。一つは端末自体で位置情報の使用が許可されていない場合で、「設定」アプリから位置情報を有効にしてもらう必要があります。もう一つはシステムダイアログで許可されなかった場合です。iOSの仕様ではシステムダイアログが表示されるのは「初めてそのアプリで位置情報を使おうとした時」のみで、一度許可されなかった場合は再度ダイアログを表示することはできません。許可してもらうためには先ほどと同様に「設定」アプリからの再設定が必要です。

![sfasdfas.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/ee328846-87d4-6525-6cfb-e47833431e21.png)


GPSでの位置情報取得に加えて、「手動で位置情報を追加する」ボタンも設置しています。

<img width="287" alt="スクリーンショット 2020-01-26 7.18.48.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/9ce3ef11-c442-9e92-929b-18c4cc5e012e.png">

これはガイドラインにある以下の記載に準拠するためのものです。

> 可能であれば、アクセスに同意しないユーザー向けに別の方法を用意してください。たとえば、位置情報の共有に同意しないユーザーには、住所を手動で入力できる機能を用意することができます。

出典: [App Store Reviewガイドライン](https://developer.apple.com/jp/app-store/review/guidelines/)

位置情報の共有を必須にしてしまうとリジェクトされる可能性があるため、こういった対応をしておくとより安心かと思います。

### ポイント④: プレイ制限の情報をユーザーに明示する

入力状況に応じてどんなプレイ制限が適用されるかを、リアルタイムに表示しています。18歳以上、もしくは香川県外にいる場合は、制限がかからない旨が表示されます。

![タイトルなし4.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/9109e3b2-663c-2f3d-6885-61268ce58744.gif)

こうした表示をすることで、制限が適用されるユーザーがきちんと内容を知ることができます。

また「ポイント①: 個人情報収集の目的を明記」を強化する意図もあり、入力された情報がどのように利用されているか示すことでユーザーより安心して使ってもらえるように思いました。

## 実装の解説

香川県かどうかの判定でいくつかのハマりポイントがあったので、簡単に解説したいと思います。

### 位置情報(座標)の取得

UnityでiOSの位置情報を取得する場合は`Input.location`を使います。

まず端末自体の位置情報が有効かどうかを調べるため`Input.location.isEnabledByUser`にアクセスします。ユーザーに位置情報取得の権限を許可してもらうシステムダイアログは`Input.location`のいずれかの機能にアクセスした時点で表示されるため、このタイミングが該当します。

```cs
    // 端末自体の位置情報が有効か
    if (!Input.location.isEnabledByUser)
    {
        LocationSettingWarning.text = $"「設定」アプリから位置情報を有効にしてください";
        LocationSettingWarning.color = Color.red;
        yield break;
    }
```

ちなみにシステムダイアログが表示されるUnityアプリケーション自体はスリープ扱いになるため、入力待ちの非同期処理を書く必要なありません。

次に、`Input.location.status`の値に応じた処理を行います。メソッド全体を示します。

```cs
IEnumerator GetLocation()
{
    // 端末自体の位置情報が有効か
    if (!Input.location.isEnabledByUser)
    {
        LocationSettingWarning.text = $"「設定」アプリから位置情報を有効にしてください";
        LocationSettingWarning.color = Color.red;
        yield break;
    }

    while (true)
    {
        var status = Input.location.status;
        switch (status)
        {
            case LocationServiceStatus.Stopped:
                Input.location.Start();
                break;
            // 位置情報が有効になった場合
            case LocationServiceStatus.Running:
                // Reverse Geocoding APIから件名を取得
                var data = Input.location.lastData;
                StartCoroutine(GetAreaName(data.latitude, data.longitude));
                yield break;
            // ユーザーが位置情報を許可しなかった場合
            case LocationServiceStatus.Failed:
                LocationSettingWarning.text = $"「設定」アプリから位置情報を有効にしてください";
                LocationSettingWarning.color = Color.red;
                yield break;
            default:
                break;
        }
        // 1秒毎に状態を再取得
        yield return new WaitForSeconds(1f);
    }
}
```

はじめは`LocationServiceStatus.Stopped`が返ってくるため`Input.location.Start()`で開始を要求します。成功する場合は`LocationServiceStatus.Initializing`を経て`LocationServiceStatus.Running`が返ってくるため、`Input.location.lastData`から緯度経度の情報を取り出すことができます。ユーザーがパーミッションの許可をしなかったなどの理由で取得に失敗した場合は`LocationServiceStatus.Failed`が返ってくるため、再設定の旨を表示しています。

難しいのが「位置情報の使用が許可されていないこと」を確認するためには、一度上記の処理を試みる必要がある点です。`Input.location`にアクセスした時点でシステムダイアログが表示されてしまうため、状態を確認する前にボタン押下のアクションを挟んでいます。二回目以降で許可されているかどうかを確認するためには初回のシステムダイアログが表示済みかどうかを判断する必要があるため、別途アプリ側で状態を保持する必要がありそうです。

### 緯度経度から「県名」を取得

GoogleのGeocoding APIを使用しています。これは住所の文字列などから位置座標(緯度経度)を取得するためのAPIですが、Reverse geocodingと呼ばれる「緯度経度→住所」の機能も提供されています。

取得するためのURLはこのような形にになります。認証されたAPI Keyを発行する必要がある点に注意してください(無料枠の範囲内で利用可能)。

```cs
var url = $"https://maps.googleapis.com/maps/api/geocode/json?" +
$"latlng={lat},{lng}&result_type=administrative_area_level_1&key={API_KEY}&language=ja";
```

APIを叩くとこんなJSONが返ってきます。

```json
{
   "plus_code" : {
      "compound_code" : "82RV+28 日本、香川県高松市",
      "global_code" : "8Q6P82RV+28"
   },
   "results" : [
      {
         "address_components" : [
            {
               "long_name" : "香川県",
               "short_name" : "香川県",
               "types" : [ "administrative_area_level_1", "political" ]
            },
            {
               "long_name" : "日本",
               "short_name" : "JP",
               "types" : [ "country", "political" ]
            }
         ],
         "formatted_address" : "日本、香川県",
         "geometry" : {
            "bounds" : {
               "northeast" : {
                  "lat" : 34.5646136,
                  "lng" : 134.4474078
               },
               "southwest" : {
                  "lat" : 34.0123081,
                  "lng" : 133.4465942
               }
            },
            "location" : {
               "lat" : 34.2225915,
               "lng" : 134.0199152
            },
            "location_type" : "APPROXIMATE",
            "viewport" : {
               "northeast" : {
                  "lat" : 34.5646136,
                  "lng" : 134.4474078
               },
               "southwest" : {
                  "lat" : 34.0123081,
                  "lng" : 133.4465942
               }
            }
         },
         "place_id" : "ChIJr363rNTcUzURsdqbibLWgS0",
         "types" : [ "administrative_area_level_1", "political" ]
      }
   ],
   "status" : "OK"
}
```

今回の実装では、`JsonUtility`を使って下記のように県名のみを取得しています。

```cs
// 一部処理を抜き出して掲載
IEnumerator GetAreaName(float lat, float lng)
{
    var url = $"https://maps.googleapis.com/maps/api/geocode/json?" +
    $"latlng={lat},{lng}&result_type=administrative_area_level_1&key={API_KEY}&language=ja";
    var request = UnityWebRequest.Get(url);

    yield return request.SendWebRequest();

    var response = JsonUtility.FromJson<Response>(request.downloadHandler.text);
    var prefecture = response.results?[0].address_components?[0].long_name;

    LocationProgress.text = $"あなたの現在地は<color=red>{prefecture}</color>です";
}

[System.Serializable] class Response { public Result[] results; }
[System.Serializable] class Result { public Adress[] address_components; }
[System.Serializable] class Adress { public string long_name; }
```

ちなみにテスト用にInspectorから`TestDummyLocation`にチェックを入れると香川県庁の座標で試せるようになっています。

```cs
if (TestDummyLocation)
{
    // 香川県庁の座標に置き換える
    var lat = 34.340117f;
    var lng = 134.043312f;
    StartCoroutine(GetAreaName(lat, lng));
    yield break;
}
```

参考: [Get Started  |  Geocoding API  |  Google Developers](https://developers.google.com/maps/documentation/geocoding/start)

## 最後に

現在香川県では「ネット・ゲーム依存症対策条例」に対するパブリックコメントを募集しています。対象は香川県民もしくはゲーム事業者のみですが、意見のある方は是非公募してみてください。

[香川県｜香川県ネット・ゲーム依存症対策条例（仮称）素案についてパブリック・コメント（意見公募）を実施します](https://www.pref.kagawa.lg.jp/content/dir1/dir1_1/dir1_1_1/plahfe200120143751.shtml)

## 参考

- [香川県でゲーム規制条例（通称、うどん条例）が成立してから5年がたった｜ゲームキャスト｜note](https://note.com/gamecast/n/n541a8ce32e18)
- [[Unity] Android/iOSで位置情報を取得する - Qiita](https://qiita.com/lycoris102/items/35e338b32105879e0ab9)

