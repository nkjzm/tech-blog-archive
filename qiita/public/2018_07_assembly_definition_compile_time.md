---
title: Unity2017.3のAssembly Definition Filesを適切に設定してコンパイルにかかる時間を削減する
tags:
  - C#
  - Unity
private: false
updated_at: '2018-07-30T17:14:07+09:00'
id: aaad87dc7f7bc9703449
organization_url_name: null
slide: false
ignorePublish: false
---

# はじめに

Unity2017.3でAssembly Definition Filesという機能が追加されました。
これは、アセンブリを任意の単位に分割するための機能です。

Unityではコードのコンパイルはアセンブリ単位で行われるのですが、デフォルトでは基本的に単一のアセンブリ(`Assembly-CSharp.csproj`)しか生成されません。そのため、コードを変更するとプロジェクト内の**ほぼ全てのコードがコンパイルの対象**になります。

例えば、ボタンを押した時の挙動を変更した場合でも、その度にライブラリのコードまでコンパイルしなおす必要があり、コンパイルに時間がかかります。さらに、プロジェクトが進むにつれコンパイル対象のコードが増え、**コンパイルにかかる時間は長くなる**傾向にありました。

Assembly Definition Filesではアセンブリを分割することにより、このコンパイルされる範囲を定義することができます。
つまり、上手く活用すればコンパイルにかかる時間を大幅に削減することが可能になるのです。


# Assembly Definition Files

繰り返しになりますが、Unityはデフォルトで`Assembly-CSharp.csproj`というアセンブリを生成します。
これは`Assets`以下の全てのコードを含みます。(ただし`Plugins`や`Editor`など一部の特殊なフォルダを除く([後述](https://qiita.com/splas_boomerang/items/aaad87dc7f7bc9703449#%E7%89%B9%E6%AE%8A%E3%81%AA%E3%83%95%E3%82%A9%E3%83%AB%E3%83%80plugins%E3%82%84editor%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6)))

**Assembly Definition Files**を利用すると、これ細かい単位に分割することができます。

![グループ 1.png](https://qiita-image-store.s3.amazonaws.com/0/55365/53f88191-3925-2899-bc1d-899f88501120.png)
_画像の引用元：`https://blogs.unity3d.com/wp-content/uploads/2017/10/Script-Compilation-Assembly-Definition-Files-manual-edition.pdf`_

## 使い方

利用方法は非常に簡単で、分割したいコードを含むルートディレクトリにファイルを追加するだけです。

まずはスクリプトに現在適用されているアセンブリを確認してみましょう。

<img width="680" alt="スクリーンショット_2018-07-29_16_11_24.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/957dbeff-e808-9860-745d-1ca14f67a9e6.png">

Projectビューでスクリプトを選択すると、Inspecterビューで確認することができます。
デフォルトで生成される`Assembly-CSharp.csproj`が適用されていることが分かります。

### Assembly Definition Filesの作成

Projectビューで分割したいコードを含むルートディレクトリを開き、`Create`から`Assembly Definition`を選択します。右クリックからの`Create>Assembly Definition`とかでも大丈夫です。

<img width="288" alt="スクリーンショット 2018-07-29 16.11.51.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/f208758c-6032-1a01-86c4-49bfb0bd1729.png">

ファイルに任意の名前をつけます。ここで指定した名前がアセンブリ名になります。**他のアセンブリと重複してはいけない点に注意してください。**

<img width="680" alt="スクリーンショット_2018-07-29_16_21_35.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/e3aa334a-f5fc-81b4-aa88-ab085b9ad229.png">

ファイル名とInspecterで確認できる`Name`は別物なので、後から変更する場合は気をつけてください。生成時にファイル名を`Name`が設定されるだけで、アセンブリを定義するのは`Name`の方です。

<img width="680" alt="スクリーンショット_2018-07-29_16_13_43.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/2748d3e4-7218-ea1c-8298-67fc013cba15.png">

Inspecterでスクリプトを選択すると、先ほど作成したアセンブリが適用されていることが確認できると思います。


## 参照関係の定義

注意したいのは、アセンブリを分割すると全体のコンパイル時間は短くなりますが、クラス間の参照は原則同じアセンブリ内でしか行えません。

そこで、他のアセンブリのクラスを参照するためには、参照関係を定義する必要があります。Assembly Definition Filesを選択した状態で、Inspecterから`References`に参照したいアセンブリを追加してください。

![dfasdfas (1).gif](https://qiita-image-store.s3.amazonaws.com/0/55365/65c914a3-9cd6-6614-e8fb-417dde304781.gif)

上記は、先ほど作成したスクリプトから、UniRxを参照するための例です。
_(UniRx 6.1.2ではAssembly Definition Filesが既に定義されています)_

なお、`Assembly-CSharp.csproj`では全てのアセンブリが自動的に参照されてるため、どのクラスでも参照することが可能です。

<img width="957" alt="スクリーンショット 2018-07-29 15.32.12.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/5f3abb4b-0e97-7359-5239-8f3ead7664d6.png">
_`Assembly-CSharp.csproj`の一部のスクショ_

また、循環参照(双方向への参照)はできないようなので注意してください。

## コンパイルの範囲

コンパイルはアセンブリ単位で行われると言いましたが、参照先に変更があった場合、全ての参照元もコンパイルの対象に含まれます。

![Script-Compilation-Assembly-Definition-Files-manual-edition-001.png](https://qiita-image-store.s3.amazonaws.com/0/55365/39316a03-4641-6d6c-3549-6e7381513759.png)

こちらの図をご覧ください。矢印は他のアセンブリへの参照関係を表しています。

例えばMain.dllは他のアセンブリから参照されていません。そのため、Main.dllに変更が加わっても、Main.dllのみがコンパイルの対象となります。

次にThirdParty.dllをみてください。ThirdParty.dllはMain.dllに参照されています。(Main.dllのReferencesにThirdParty.dllが指定されている状態)

そのため、ThirdParty.dllに変更が加わった場合のコンパイルの範囲は、ThirdParty.dllだけでなくMain.dllにも及ぶことになります。

イメージとしては、上流に変更があった場合、下流にも影響が及ぶといった感じです。CanvasGroupと同じような感じです。

通常プロジェクトで最も頻繁に変更が発生するのは下流のMain.dllに当たる部分だと思うので、その部分を小さくすることでコンパイル時間が減っていきます。しかし、アセンブリの分割には参照が一方向になっている必要があります。そのため、コンパイル時間を最適化するためには、疎結合な設計にしておくことが非常に重要です。

## 特殊なフォルダ(`Plugins`や`Editor`)について

Unityでは一部のフォルダは特殊な扱いとなり、事前定義されたアセンブリが適用されています。
[特殊フォルダーとスクリプトのコンパイル順 - Unity マニュアル](https://docs.unity3d.com/ja/current/Manual/ScriptCompileOrderFolders.html)

> Unity​​ gives ​​priority​​ to ​​the ​​assembly​​ definition​ ​files ​​over ​​the​ [​​Predefined​​ Compilation System(ScriptCompileOrderFolders).

[Script-Compilation-Assembly-Definition-Files-manual-edition.pdf](https://blogs.unity3d.com/wp-content/uploads/2017/10/Script-Compilation-Assembly-Definition-Files-manual-edition.pdf)

しかしマニュアルによると、**「あらかじめ定義されている特殊フォルダのコンパイル順よりも、Assembly Definition Filesが優先される」**という記述があります。つまり、`Plugins`や`Editor`が意図通り動作しなくなる可能性があります。

`Plugins`はおそらく問題ないのですが、`Editor`以下は他のプラットフォームではコンパイルされると困る場合が多いかと思います。

そこで、Assembly Definition Filesのプラットフォーム設定を利用した方法で上記の問題を回避します。`Editor`フォルダにAssembly Definition Filesを追加し、Platformsの`Include Platforms`で`Editor`のみを指定した状態にしてください。

![editor.gif](https://qiita-image-store.s3.amazonaws.com/0/55365/4f10e812-fb54-a686-aae5-6d00dcca673c.gif)

注意して欲しいのが、デフォルトの`Any Platform`にチェックが入っている状態だとラベルが`Exclude Platforms`になっています。`Include Platforms`を設定する場合は`Any Platform`をオフにする必要があるので、気をつけてください。

`Any Platform`がオンの状態で、`Editor`以外のプラットフォームを全て選択する方法でも大丈夫かと思います。

## TestRunnerへの適用

TestRunnerを利用している場合にも注意が必要です。

マニュアルによると、TestRunnerの動作には以下のいずれかを満たす必要があります。
- Editorフォルダ以下に入れる
- `test assemblies`を参照したアセンブリに含める

[Unity Test Runner - Unity マニュアル](https://docs.unity3d.com/ja/2018.1/Manual/testing-editortestsrunner.html)

ただし前者は他のAssembly Definition Files以下にある場合動作しないため、注意してください。

<img width="317" alt="スクリーンショット 2018-07-29 17.38.46.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/4ffbb664-c379-5072-1eec-43e359306507.png">

後者の場合は、アセンブリを選択して`Unity References`の`Test Assemblies`にチェックを入れればokです。

<img width="314" alt="スクリーンショット 2018-07-29 17.39.21.png" src="https://qiita-image-store.s3.amazonaws.com/0/55365/6416542f-8874-d756-eaab-8c8b328195d2.png">

ちなみに`PlayMode`の場合は上記のみでokですが、`EditMode`で動作させたい場合は`Editor-only`のアセンブリである必要があります。つまり、上記のような設定になるかと思います。

## ベストプラクティス?

> It​ ​is​ ​highly​ ​recommended​ ​that​ ​you​ ​use​ ​assembly​ ​definition​ ​files​ ​for​ ​all​ ​the​ ​scripts​ ​in​ ​the​ ​Project, or​ ​not​ ​at​ ​all.

https://blogs.unity3d.com/wp-content/uploads/2017/10/Script-Compilation-Assembly-Definition-Files-manual-edition.pdf


プロジェクトの全てのスクリプトにAssembly Definition Filesを使用することか、全く使用しないことが推奨されているようです。
_(訳間違ってたら教えてください)_

## 動作確認環境

- Mac (macOS 10.13.6)
- Unity2018.2.1f1

# 参考

- [【Unity】Assembly Definition Filesという神機能 - テラシュールブログ](http://tsubakit1.hateblo.jp/entry/2018/01/18/212834)
- [【Unity】Unity2017.3で追加されたAssembly Definitionをちょっと触ってみた - Qiita](https://qiita.com/yos316/items/e01c6f66838337d0a5be)
- [Unity Test Runner - Unity マニュアル](https://docs.unity3d.com/ja/2018.1/Manual/testing-editortestsrunner.html)


# 最後に

間違ってる箇所があれば是非ご指摘ください。





