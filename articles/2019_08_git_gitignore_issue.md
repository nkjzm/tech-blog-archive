---
title: "GitでUntracked filesなのに.gitignore効かない時の原因"
emoji: "🐙"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Git", "Unity"]
published: true
---
# 前提

[gitignore.io](https://gitignore.io/)にて[Unity用.gitignore](https://gitignore.io/api/unity)をインポートしたプロジェクトでの出来事

# 症状

以下の`.csproj.meta`ファイルが`Untracked files`に現れたため`.gitignore`に相対フルパスを追記したが反映されなかった。

- `/Assets/Plugins/Zenject/OptionalExtras/ReflectionBaking/Zenject-ReflectionBaking.csproj.meta`
- `/Assets/Plugins/Zenject/OptionalExtras/Signals/Zenject\-Signals.csproj.meta`

_(UnityでZenjectをインポートした際に含まれていたファイルで、`.csproj`は各環境で生成すれば良いためignoreしていて、同様にUnity内で参照するための`.meta`ファイルもignoreしたという状況。)_

# 原因

上記`.gitignore`内に以下の記述があったため、そちらの設定が優先されていた

```
# Never ignore Asset meta data
!/[Aa]ssets/**/*.meta
```

`!`は明示的にignoreしないことを示すexcludeの記法

# 解決方法

Gitでは`.gitignore`ファイルの記述順で優先度が決まるらしく、上記のexclude記述の後ろに相対フルパスを書いたら無事反映された


# 最後に

「Git gitignore 効かない」とかでググると一度既にcommitされた歴史があるため`$git rm hoge`する必要があるよ、みたいな記事ばかりでこの視点にたどり着けなかったため、備忘録として残しておこうと思いました。



