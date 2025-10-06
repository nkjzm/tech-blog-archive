---
title: 【Unity】ビルドしたアプリの実行時エラーをSlackに通知する
tags:
  - Unity
  - Slack
private: false
updated_at: '2025-10-06T21:48:16+09:00'
id: e27a6805fbf4e472c1d5
organization_url_name: null
slide: false
ignorePublish: false
---
## はじめに

![ダウンロード (2).png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/a189b784-5b3b-a48f-1bbf-dfb25b30ee49.png)

リモートで実行時のエラーを確認できる機能があると便利だなーと思い、簡単に実装してみました。インターネットに繋がっていればプラットフォームによらずに使えて便利な方法です。開発環境とかだと気軽に導入できると思うので、良かったら参考にしてみてください。

## 環境

- Windows 10 Home
- Unity 2019.2.17f1

## 手順

こちらの記事を参考に、[Incoming Webhooks]を導入してください。現在は[Integrations]でなく[Apps]という名称になっています。画面に従いポストするチャンネルや、投稿するbotのアイコンを設定しておいてください。また、この画面に表示される`Webhook URL`は今後使うのでメモしておいてください。
[Slack API (Incoming Webhooks) が簡単すぎた - Psycho Frame](http://docs.hatenablog.jp/entry/slack-Incoming-webhooks)

次にUnity側でエラーログをフックしていきます。`Application.logMessageReceived`に対してイベントを登録することで、ログ出力のタイミングに処理を差し込むことができます。
参考: [Application-logMessageReceived - Unity スクリプトリファレンス](https://docs.unity3d.com/ja/current/ScriptReference/Application-logMessageReceived.html)

今回はその仕組みを利用して、こんな感じのコンポーネントを作成してあげます。これを通知させたいシーン上でアタッチしておいてください(用途に応じて`DontDestroyOnLoad`や通常のクラス化などすると良いかと思います)。

```cs:SlackNotificatior.cs
// 動作確認していないコードなのでご了承ください
using System;
using UnityEngine;
using System.Collections;
using UnityEngine.Networking;

public sealed class SlackNotificatior : MonoBehaviour
{
	void Awake()
	{
		Application.logMessageReceived += OutputLogMessage;
	}

	void OnDestroy()
	{
		Application.logMessageReceived -= OutputLogMessage;
	}

	void OutputLogMessage(string text, string stackTrace, LogType type)
	{
// Editorでエラーログを通知していたらきりがないので除外する
#if !UNITY_EDITOR
			if (type == LogType.Error || type == LogType.Exception)
			{
				PostText(text, type.ToString());
			}
#endif
	}

	// TODO: ここにWebhook URLを入れる
	const string url = "";
	public void PostText(string text, string type)
	{
		var data = new PostData()
		{
			username = Application.platform.ToString(),
			color = "#D00000",
			fields = new PostData.Field[] { new PostData.Field() { title = type, value = text } }
		};
		var json = JsonUtility.ToJson(data);
		StartCoroutine(Post(url, json));
	}

	IEnumerator Post(string url, string json)
	{
		var postData = System.Text.Encoding.UTF8.GetBytes(json);
		var request = new UnityWebRequest(url, "POST");
		request.uploadHandler = (UploadHandler)new UploadHandlerRaw(postData);
		request.downloadHandler = (DownloadHandler)new DownloadHandlerBuffer();
		request.SetRequestHeader("Content-Type", "application/json");
		yield return request.SendWebRequest();
	}

	[Serializable]
	class PostData
	{
		public string username;
		public string color;
		public Field[] fields;
		[Serializable] public class Field { public string title; public string value; }
	}
}
```

後半ではjsonをWebhook URLに投げる処理を書いてあります。[Incoming Webhooks]のページに載っている[Attachment Formatting]を参考に、いい感じにフォーマットすることができます。赤いバーが出るとそれっぽいですよね。

![ダウンロード (1).png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/9112f302-5de4-4e84-1663-4f332bdefe5f.png)

ポイントとして、botの名前部分に実行環境を入れています。こうすることでクロスプラットフォーム開発でもどの環境でのエラーかどうかを区別することができるようになります。その他ビルドや端末の情報を埋め込んでも良いと思います。

## 参考

[UnityからSlack投稿する - Qiita](https://qiita.com/iwaken71/items/bbc5bde1f0eb05a2a9b0)

