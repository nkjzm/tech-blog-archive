---
title: 【Jenkins】特定のジョブを優先実行する【Priority Sorter Plugin】
private: false
tags:
  - Jenkins
updated_at: '2020-06-08T22:07:43+09:00'
id: d47b2e858e98540be02e
organization_url_name: null
slide: false
---
# 初めに

Jenkinsでは`[Jenkinsの管理]->[システムの設定]`より同時ビルド数の設定ができますが、その数を超えた分はビルド待ちとしてビルドキューに溜まっていきます。大抵の場合はスケジュールされた順で問題ないのですが、中には早く完了してほしいビルドや、連続して扱いたいジョブがあったりします。そこで、ビルドキューに優先度付けをする**Priority Sorter**というPluginを紹介します。

# 導入手順と使い方

`[Jenkinsの管理]->[Pluginの管理]->[利用可能]`より`Priority Sorter`を検索してインストールします。

https://plugins.jenkins.io/PrioritySorter/

完了すると、メニューに「Job Priorities」が追加されるので選択して設定していきます。

![afasdfasd.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/011ac00e-ee3a-a486-8849-780a1177feb8.png)

いくつか設定方法あるのですが、ここではView単位で設定します。「Jobs to include」で「Job included in a View」を選択してください。

![キャプチャ.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/14bd08c2-7a18-5186-56f3-32d356898a55.png)

優先度の設定が紛らわしいのですが、**数字が小さいものが優先的に実行**されます。早く実行したいものは小さい数字に設定しましょう。

![aキャプチャ.PNG](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/d4313892-c077-0a01-924e-4753b7521491.png)

ちなみにデフォルトの優先度（初期値は`3`）や優先度の刻み具合は`[Jenkinsの管理]->[システムの設定]`より設定可能でした。

# 参考

[ブログズミ: [Jenkins] 手動実行したビルドを優先実行する](https://srz-zumix.blogspot.com/2015/09/jenkins.html)

