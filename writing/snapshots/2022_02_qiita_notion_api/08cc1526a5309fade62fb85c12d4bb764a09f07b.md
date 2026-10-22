---
title: "Qiita API v2で自分の記事一覧を取得しNotion APIでデータベースに記録する【Unity】"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "Notion"]
published: true
---

この記事は 2022/02 に Qiita に投稿された記事を再投稿しています。

# はじめに

私は自分の行ってきたコミュニティ活動をNotionでまとめて記録しています。

ページ

https://nkjzm.jp/a268d0d886cc4360ad770a6709aa83ae

スクショ
![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/4028f3df-24bb-6724-498c-5a51e680bb57.png)

各活動を管理しているウェブサービスが終了しても記録を参照することが出来ますし、どんなことをやってきたのか横断的に見られて気に入っているのですが、更新作業を行っていたところちょっとした問題が発生しました。いつの間にか自分の書いた技術記事が「100」を超えており、手動で追加していくのはかなり大変だと思いました。

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/28bb38e1-4bdd-2e09-b17c-49843224255f.png)


そこで今回は API の勉強がてらに Qiita API と Notion APIの連携を試してみたので、簡単に紹介したいと思います。

# 環境

- Unity 2020.3.26f1
- Qiita API v2
- Notion API Beta

やることとしては API 叩いて繋ぎこむだけなのですが、JSONのパースなどが必要だったので使い慣れたUnityを使いました。

逆にこういう時って何使うのがいいんですかね・・？何かおすすめの言語や環境などあればぜひ教えてください！（コメントでも [Twitter @nkjzm](https://twitter.com/nkjzm)宛てでも！）

# 実装

## Qiita API

こちらの記事をみて実装しました。特にハマることもなく簡単でした。

https://qiita.com/charon/items/1d27a0dde1eeafe38910

デフォルトで取得できる記事数が20件なので、それ以上取得する場合はパラメータ指定する必要があるみたいです。最大100件だったので、ページ指定で複数回呼ぶことで解決しています。

```.cs
    private async UniTask<List<Data>> GetQiita(int page)
    {
        // 100剣ずつ取得
        var url = $"https://qiita.com/api/v2/authenticated_user/items?page={page}&per_page=100";

        // 省略
```


## Notion API

原罪βなのでそのうち仕様変わるかも。こちらのページを参考に実装しました。

https://qiita.com/thomi40/items/fe2a828746f31ad827ba

データベースへのアイテム追加はページの追加扱いになっている点がミソです。プロパティの扱いが結構大変だったのですが、APIドキュメントとにらめっこしたり、返ってくるエラーメッセージから（xxというKeyが必要らしい・・）みたいな情報を読み取ってトライエラーしました。苦しかった・・

https://notion-group.readmepreview.com/reference/property-value-object

## Unityでのjsonの扱いについて

今回はUnity標準の JsonUtility ではなく、Json.NET を採用しました。

理由は Qiita API のレスポンスとして返ってくる json のルートが配列になっているためです。Json Utility は未対応です。

その他の選択肢として Utf8Json などもありましたが、最近はしばらく更新がなかったりするので今度あまり使う場面なさそうかな～と思い Json.NETを試してみました。（ちなみに以前は結構使ってて大変お世話になりましたmm）

https://github.com/neuecc/Utf8Json

確かどこかのバージョンからUnityでの標準で利用できるようになっているはずです。使い方は下記の記事が参考になりました。

https://qiita.com/yun_bow/items/f20bd38ded1a27e658f6

若干詰まったこととして、ルート配列の場合は初めに `JArray` でパースする必要がありました。ご注意ください。

```.cs
        var json = request.downloadHandler.text;
        JArray jsonArray = JArray.Parse(json);
        foreach (var jToken in jsonArray)
        {
            var jo = JObject.Parse(jToken.ToString());
            list.Add(new Data
            {
                title = jo["title"].ToString(),
                dateTime = DateTime.Parse(jo["created_at"].ToString()),
                url = jo["url"].ToString()
            });
        }
```

## コード

今回書いたコードです、すごい汚いです。

```.cs
using System;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using UnityEngine;
using UnityEngine.Networking;

public class Controller : MonoBehaviour
{
    private const string QiitaAccessToken = "ほげほげ";
    private const string NotionAccessToken = "ふがふが";
    private const string DatabaseId = "ぐるぐる";

    // 100件単位で取得するので 上の桁だけ正しく更新すること
    private const int PostCount = 150;

    void Start() => Action();

    public async void Action()
    {
        var list = await GetQiita();
        foreach (var data in list)
        {
            AddNotion(data.title, data.dateTime, data.url);
        }
    }

    private class Data
    {
        public string title;
        public DateTime dateTime;
        public string url;
    }

    private async UniTask<List<Data>> GetQiita()
    {
        var list = new List<Data>();
        var pageCount = Mathf.CeilToInt(PostCount / 100f);
        for (int i = 0; i < pageCount; i++)
        {
            list.AddRange(await GetQiita(i + 1));
        }

        return list;
    }

    private async UniTask<List<Data>> GetQiita(int page)
    {
        // 100剣ずつ取得
        var request =
            UnityWebRequest.Get($"https://qiita.com/api/v2/authenticated_user/items?page={page}&per_page=100");
        request.SetRequestHeader("Authorization", $"Bearer {QiitaAccessToken}");

        await request.SendWebRequest();

        if (request.result != UnityWebRequest.Result.Success)
        {
            Debug.LogError(request.error);
            return null;
        }

        var json = request.downloadHandler.text;
        Debug.Log(json);
        JArray jsonArray = JArray.Parse(json);
        var list = new List<Data>();

        foreach (var jToken in jsonArray)
        {
            var jo = JObject.Parse(jToken.ToString());
            list.Add(new Data
            {
                title = jo["title"].ToString(),
                dateTime = DateTime.Parse(jo["created_at"].ToString()),
                url = jo["url"].ToString()
            });
        }

        return list;
    }

    private async void AddNotion(string title, DateTime dateTime, string url)
    {
        // ref: https://notion-group.readmepreview.com/reference/property-object
        string strData = dateTime.ToString("yyyy-MM-dd");

        JObject jsonObj = new JObject
        {
            ["parent"] = new JObject
            {
                ["database_id"] = DatabaseId
            },
            ["properties"] = new JObject
            {
                ["title"] = new JObject
                {
                    ["title"] = new JArray
                    {
                        new JObject
                        {
                            ["text"] = new JObject
                            {
                                ["content"] = title
                            }
                        }
                    }
                },
                ["Date"] = new JObject
                {
                    ["date"] = new JObject
                    {
                        ["start"] = strData
                    }
                },
                ["Tags"] = new JObject
                {
                    ["select"] = new JObject
                    {
                        ["name"] = "記事投稿"
                    }
                },
                ["URL"] = new JObject
                {
                    ["url"] = url
                },
            },
        };
        string jsonStr = JsonConvert.SerializeObject(jsonObj, Formatting.None);
        byte[] postData = System.Text.Encoding.UTF8.GetBytes(jsonStr);

        var request = new UnityWebRequest("https://api.notion.com/v1/pages", UnityWebRequest.kHttpVerbPOST)
        {
            uploadHandler = new UploadHandlerRaw(postData),
            downloadHandler = new DownloadHandlerBuffer()
        };
        request.SetRequestHeader("Authorization", $"Bearer {NotionAccessToken}");
        request.SetRequestHeader("Content-Type", "application/json");
        request.SetRequestHeader("Notion-Version", "2021-08-16");

        await request.SendWebRequest();

        if (request.result != UnityWebRequest.Result.Success)
        {
            Debug.LogError(request.error);
            return;
        }

        Debug.Log($"ok: {title}");
    }
}
```

# 最後に

こういう効率化あるあるなんですけど、初めてのAPI使ったりJSONのパースでトライエラーしているうちに2時間が経ちました。また記事書いてたのでかれこれ3時間くらい経っています。~~手動でNotionに登録して言った方が早かったんじゃ・・・~~ なんてことを思ったりもしましたが、楽しかったのでＯＫです！！！！！！！！


よかったら Twitter のフォローもよろしくお願いします！→ [@nkjzm](https://twitter.com/nkjzm)




