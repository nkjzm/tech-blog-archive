---
title: マージ前のGitHub Actionsをテスト実行するClaude Code Skillsの紹介
tags:
  - CI
  - GitHubActions
  - ClaudeCode
private: false
updated_at: '2026-01-19T22:10:43+09:00'
id: 2644e8fc8db0f5375951
organization_url_name: null
slide: false
ignorePublish: false
---

# はじめに

GitHub Actionsのワークフローを新規に追加する際の困りごとについて紹介します。

普段の開発では全てのコード変更はPull Requestを通じて行うのですが、ワークフローの新規追加の場合は

- Pull Request作成時点で動作確認が完了している状態にしたい
- workflow_dispatchを使って動作確認する方法があるが、デフォルトブランチにマージされていないとUI上から実行できない仕様がある

というジレンマに遭遇します。ワークアラウンドとして一度空のワークフローをマージし、その後にPull Requestで修正を加えて動作確認を行う方法をよく使っていましたが、冗長なレビューが発生するなどの問題がありました。

そんな時に下記のブログ記事に出会い、一時的に`pull_request`トリガーを追加する手法を知りました。今回は、この手順を自動化するためにClaude Code Agent Skillsを作成したので、その方法について紹介したいと思います。

https://thomaslevesque.com/2024/04/25/running-a-github-actions-workflow-that-doesnt-exist-yet-on-the-default-branch/

# アプローチ

ブログ記事で紹介されていた方法は以下の通りです

1. 一時的に`pull_request`トリガーをワークフローファイルに追加
2. Pull Requestを作成してワークフローを実行させる（これによりGitHubがワークフローを認識でき、ghコマンドからの実行が可能になる）
3. 一時的なトリガーを削除

実際に試してみて使えることが分かったのですが、毎回Claude Codeに
URLを渡して実行してもらうのはすこし面倒です。そこで、この手順を自動化するためにClaude Code Agent Skillsを作成することにしました。

# Claude Code Agent Skillsとは

Claude Code Agent Skillsは、**Claude Codeに特定のタスクの実行方法を教えるMarkdownファイル**です。PRレビューのテンプレート化やコミットメッセージの生成ルール、繰り返し行う複雑な手順の自動化などに使えます。

Claudeが会話の文脈から自動的に適切なSkillを選択して実行するほか、`/test-workflow-on-branch`のように明示的に呼び出すこともできます。

詳しくは[公式ドキュメント](https://code.claude.com/docs/ja/skills)を参照してください。

# 作成した `test-workflow-on-branch` スキル

以下が実際に作成したskill.mdの全文です。このファイルをユーザールートかプロジェクトルートの`.claude/skills/test-workflow-on-branch/skill.md`に配置することで使えるようになります。

````markdown
---
name: test-workflow-on-branch
description: GitHub Actionsのワークフローを現在のブランチで実行するスキル。デフォルトブランチにまだマージされていないワークフローファイルを動作確認する際に使用。workflow_dispatchトリガーを持つワークフローの実行をサポート。
---

# Test Workflow on Branch

まだデフォルトブランチにマージされていないGitHub Actionsのワークフローを、現在のブランチで実行するためのスキル。

## 背景

GitHub Actionsは通常、デフォルトブランチ（main/master）に存在するワークフローファイルのみがUIから手動実行できます。新しいワークフローを作成してテストしたい場合、この制限が問題になります。

このスキルは [Thomas Levesque氏のブログ記事](https://thomaslevesque.com/2024/04/25/running-a-github-actions-workflow-that-doesnt-exist-yet-on-the-default-branch/) で紹介されている手法を実装しています。

## 前提条件

- `gh` (GitHub CLI) がインストール済み
- `gh auth login` で認証済み
- ワークフローファイルに `workflow_dispatch` トリガーが設定されている

## 実行フロー（新しいワークフローファイルの場合）

### ステップ1: ワークフローファイルを作成

1. **`workflow_dispatch` トリガーのみでワークフローファイルを作成**
   ```yaml
   name: My Workflow

   on:
     workflow_dispatch:
       inputs:
         example_input:
           description: 'Example input'
           required: false
           default: 'default value'

   jobs:
     # ジョブ定義
   ```

2. **変更をコミット**
   ```bash
   git add .github/workflows/<workflow-file-name.yml>
   git commit -m "Add new workflow"
   ```

### ステップ2: 一時的に `pull_request` トリガーを追加

3. **`pull_request` トリガーを追加（一時的）**
   ```yaml
   name: My Workflow

   on:
     workflow_dispatch:
       inputs:
         example_input:
           description: 'Example input'
           required: false
           default: 'default value'
     pull_request:  # 一時的に追加（GitHubに認識させるため）

   jobs:
     # ジョブ定義
   ```

4. **変更をコミット＆プッシュ**
   ```bash
   git add .github/workflows/<workflow-file-name.yml>
   git commit -m "Add temporary pull_request trigger for GitHub recognition"
   CURRENT_BRANCH=$(git branch --show-current)
   git push -u origin $CURRENT_BRANCH
   ```

### ステップ3: Pull Requestを作成

5. **Pull Requestを作成**
   ```bash
   gh pr create --title "Add new workflow" --body "Testing new workflow" --draft
   ```

   **重要**: PRを作成することで、`pull_request`トリガーによりワークフローが実行され、
   GitHubがワークフローを認識してActionsタブに表示されるようになる

6. **ワークフローが実行されたことを確認**
   ```bash
   gh run list --workflow=<workflow-file-name.yml> --limit 1
   ```

### ステップ4: 一時的なトリガーを削除

7. **ユーザーに削除方法を確認**

   一時的に追加した`pull_request`トリガーを削除する方法を2つ提示：

   **方法A: revertコミットを作成（安全・推奨）**
   - 利点: 履歴が保持される、安全
   - 欠点: コミット履歴に一時的な変更が残る

   ```bash
   # 直前のコミット（pull_requestトリガー追加）をrevert
   git revert HEAD
   git push
   ```

   **方法B: コミットを削除してforce push（履歴をクリーンに）**
   - 利点: コミット履歴がクリーン
   - 欠点: force pushが必要、他の人がpullしている場合は問題になる

   ```bash
   # 直前のコミット（pull_requestトリガー追加）を削除
   git reset --soft HEAD~1

   # ファイルを元の状態に戻す
   git checkout HEAD -- .github/workflows/<workflow-file-name.yml>

   # 変更をコミット
   git add .github/workflows/<workflow-file-name.yml>
   git commit -m "Remove temporary pull_request trigger"

   # force push（注意: 他の人がpullしている場合は使用しない）
   git push --force-with-lease
   ```

### ステップ5: ワークフローを手動実行

8. **現在のブランチでワークフローを手動実行**
   ```bash
   CURRENT_BRANCH=$(git branch --show-current)
   gh workflow run <workflow-file-name.yml> --ref $CURRENT_BRANCH
   ```

   成功すると「Created workflow_dispatch event for <workflow-file-name.yml>」と表示される

9. **実行状況を確認**
   ```bash
   gh run list --workflow=<workflow-file-name.yml> --limit 1

   # または、実行の詳細を確認
   gh run watch
   ```

### inputsを指定して実行する場合

```bash
CURRENT_BRANCH=$(git branch --show-current)
gh workflow run <workflow-file-name.yml> \
  --ref $CURRENT_BRANCH \
  -f input1=value1 \
  -f input2=value2
```

## トラブルシューティング

### "HTTP 404: Not Found" エラー

ワークフローファイルが見つからない場合、以下を確認してください：

1. **PRが作成されているか確認**
   ```bash
   gh pr list --head $(git branch --show-current)
   ```

   PRが存在しない場合は、PRを作成してください：
   ```bash
   gh pr create --title "Test workflow" --body "Testing workflow" --draft
   ```

2. **`pull_request` トリガーが追加されているか確認**

   新しいワークフローファイルの場合、一時的に `pull_request` トリガーを追加する必要があります。
   これにより、PR作成時にワークフローが実行され、GitHubがワークフローを認識します。

3. **GitHubの同期を待つ**

   PRを作成してワークフローが実行された後、GitHubがワークフローを認識するまで数秒〜数十秒かかることがあります。

4. **ワークフローファイルがプッシュされているか確認**
   ```bash
   gh browse .github/workflows/<workflow-file-name.yml> --branch $(git branch --show-current)
   ```

### "workflow not found" エラー

ワークフローファイルに `workflow_dispatch` トリガーが設定されているか確認してください。

### 認証エラー

```bash
gh auth login
```
を実行して認証し直してください。

### 実行が開始されない

以下のコマンドでワークフローの実行状況を確認：
```bash
gh run list --limit 5
```

## 実装上の注意点

- このスキルを使用する際は、必ずユーザーにワークフローファイル名を確認してから実行すること
- ワークフローの inputs が必要な場合は、ユーザーに確認してから `-f` オプションで指定すること
- 実行後は、実行IDやURLをユーザーに提示すること
- 一時的な `pull_request` トリガーの削除方法は、必ずユーザーに確認してから実行すること（ステップ4参照）
````

# 実際の使用イメージ

以下のように動作します。

![](https://raw.githubusercontent.com/nkjzm/tech-blog-archive/main/images/2026_01_16_claude_code_skills_github_actions_img1.png)

画像のように文脈を判断して自動的に読み込んでくれますが、`/test-workflow-on-branch`で明示的に呼び出すことも可能です。

# 工夫したポイント

ブログの手順は自然言語で書かれているため、作業に必要なステップが明示されていませんでした。そこで、一度pull_requestトリガーを追加してPull Requestを作成するステップなどを細かく分けて、Claudeが迷わず実行できるように工夫しました。

また、動作確認の際にはpull_requestトリガーを追加してpushする関係で、commit履歴が汚れてしまう問題があります。これを解決するために、revert以外にreset+force pushで履歴をクリーンに保つ方法も提示するようにしています（勝手にやられると嫌な操作なので確認するようにもしています）

# 最後に

Claude Code Agent Skillsを作成することで、GitHub Actionsのワークフローをテストする際のハック手法を自動化することができました。同じような課題を抱えている方の参考になれば幸いです。

よかったらXのフォローもよろしくお願いします！

https://x.com/nkjzm
