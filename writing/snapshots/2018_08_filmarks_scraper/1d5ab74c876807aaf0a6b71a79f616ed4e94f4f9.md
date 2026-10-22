---
title: "Filmarksから特定ユーザーの観た映画一覧を取得するスクリプト"
emoji: "📱"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["GoogleAppsScript"]
published: true
published_at: 2018-08-01 11:37
---
# 出来ること

Filmarksから特定ユーザーの観た映画一覧を取得し、Googleスプレッドシートに書き込めるコードを書きました。

![スクショ.png](https://qiita-image-store.s3.amazonaws.com/0/55365/9eb92726-2711-c92a-1d16-35edbbc37d41.png)
https://github.com/nkjzm/MovieLogGetterFromFilmarks

## 注意

- スクレイピングは使い方次第で違法となる可能性がある技術です。利用される際は十分に配慮ください。
- また、紹介した方法を使ってなんらかの不利益を被った場合でも、私は一切に責任を負いませんのでご了承ください。

# 使い方

1. SpreadSheetから「ツール」>「スクリプトエディタ」を選択し、コード.gsの内容をコピペします。
1. スプレッドシートを再度開いた後に「B1」にFilmarksのユーザーidを入力し、メニューより「フィルマークの映画一覧取得」をクリックしてください。
1. 権限周りでダイアログが出ると思いますが、無理やり進めると実行できます
1. 成功すると「実行しています」と表示され、数秒後に反映されると思います。

# 実装

```js:コード.gs
function onOpen() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet();
  var entries = [
    {
      name : "フィルマークの映画一覧取得",
      functionName : "myFunction"
    }
  ];
  sheet.addMenu("スクリプト実行", entries);
};

function myFunction () {
  var sheetData = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();

  var userId = sheetData.getRange(1, 2).getValue();

  var pageLenght = getPageCount(userId);

  var index = 2;
  for(var page = 1; page <= pageLenght; ++page)
  {
    var url = 'https://filmarks.com/users/' + userId + '?page=' + page;

    Logger.log(url);
    
    var response = UrlFetchApp.fetch(url);
    var myRegexp = /<h3 class=\"c-movie-card__title\">([\s\S]*?)<\/span><\/p><\/div><div class=\"c-movie-card__right\">/gi;
    var elems = response.getContentText().match(myRegexp);

    for(var i in elems) {
      var elem = elems[i];
      var col = parseInt(index);
      sheetData.getRange(col, 1).setValue(getRegexpedText(elem,/<h3 class=\"c-movie-card__title\">([\s\S]*?)<span>/gi));
      sheetData.getRange(col, 2).setValue(getRegexpedText(elem,/<span>([\s\S]*?)<\/span>/gi));
      sheetData.getRange(col, 3).setValue(getRegexpedText(elem,/<div class=\"c-rating__score\">([\s\S]*?)<\/div>/gi));
      sheetData.getRange(col, 4).setValue(getRegexpedText(elem,/<p class=\"c-movie-card__review\"><span>([\s\S]*?)<\/span>/gi));
      ++index;
    }
  }
}

function getRegexpedText(text, regexp)
{
  Logger.log(text)
  var elems = text.match(regexp);
  var regexpedText = elems[0];  
  regexpedText = removeTags(regexpedText);
  return regexpedText;
}

function getPageCount(userId)
{
  var url = 'https://filmarks.com/users/' + userId;
  
  var response = UrlFetchApp.fetch(url);
  var myRegexp = /<span class=\"p-users-navi__count\">([\s\S]*?)<\/span>/gi;
  var elems = response.getContentText().match(myRegexp);

  var itemCount = elems[0];
  itemCount = removeTags(itemCount)
  var pageCount = Math.ceil(parseInt(itemCount) / 36);
  return pageCount;
}

function removeTags(text)
{
  text = text.replace(/(^\s+)|(\s+$)/g, "");
  text = text.replace(/<\/?[^>]+>/gi, "");
  return text;
}
```

# 関連

- [Filmarks](https://filmarks.com/)
- [GASのコードをGithub管理するChrome拡張が便利 - Qiita](https://qiita.com/splas_boomerang/items/d384896d01ac3ff6f91c)
