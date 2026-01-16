---
title: "Claude Code Skillsを作ってGitHub Actionsのワークフローテストを快適にした話"
emoji: "🤖"
type: "tech"
topics: ["GitHubActions", "ClaudeCode", "CI/CD", "開発環境"]
published: true
---

# はじめに

GitHub Actionsのワークフローを開発している際、「新しく作ったワークフローをテストしたいけど、デフォルトブランチにマージしないと手動実行できない」という問題に直面したことはありませんか？

私もClaude Codeを使った開発の中でこの制限が障壁になっていました。テストのためだけにmainブランチにマージするのは避けたいし、かといってPRで確認したくても動作確認できないというジレンマがありました。

そんな時、Thomas Levesque氏のブログ記事で一時的に`pull_request`トリガーを追加する手法を知り、この手順を自動化するためにClaude Code Agent Skillsを作成しました。今回はその経験について紹介したいと思います。

# GitHub Actionsの制限と解決方法

## 制限

GitHub Actionsには、**デフォルトブランチ（main/master）にマージされていないワークフローは手動実行（workflow_dispatch）できない**という仕様があります。これは新しいワークフローを作成する際の大きな課題となります。

## 課題

- テストのためだけにデフォルトブランチにマージするのは避けたい
- Pull Requestで確認したいが、動作確認できない
- ワークフローのバグを本番環境で発見するリスク

## 解決のアイデア

Thomas Levesque氏のブログ記事で紹介されていた方法は以下の通りです：

1. 一時的に`pull_request`トリガーをワークフローファイルに追加
2. Pull Requestを作成してワークフローを実行させる（これによりGitHubがワークフローを認識）
3. 一時的なトリガーを削除
4. これで手動実行が可能になる

この手順は効果的ですが、毎回手動で行うのは面倒です。そこで、この手順を自動化するためにClaude Code Agent Skillsを作成することにしました。

# Claude Code Agent Skillsとは

Claude Code Agent Skillsは、**Claude Codeに特定のタスクの実行方法を教えるMarkdownファイル**です。

## できること

- PRレビューのテンプレート化
- コミットメッセージの生成ルール
- プロジェクト固有の自動化タスク
- 繰り返し行う複雑な手順の自動化

## 使い方

Agent Skillsには2つの使い方があります：

1. **自動実行**: Claudeが会話の文脈から自動的に適切なSkillを選択して実行
2. **明示的呼び出し**: `/スキル名`で明示的に呼び出し可能

例えば、「GitHub Actionsのワークフローをテストしたい」と伝えれば、Claudeが自動的に適切なSkillを選択して実行してくれます。または、`/test-workflow-on-branch`のように明示的に呼び出すこともできます。

## 公式ドキュメント

- [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
- [Agent Skills - Platform Docs](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [GitHub - anthropics/skills](https://github.com/anthropics/skills)

# test-workflow-on-branchスキルの導入方法

それでは、実際にこのスキルをどうやって使い始めるかを説明します。

## 必要なもの

- `gh` (GitHub CLI)
- `gh auth login`で認証済み
- ワークフローファイルに`workflow_dispatch`トリガーが設定されていること

## 導入手順

1. **ディレクトリを作成**
   ```bash
   mkdir -p ~/.claude/skills/test-workflow-on-branch
   ```

2. **skill.mdファイルを作成**
   次のセクションで紹介する全文を`~/.claude/skills/test-workflow-on-branch/skill.md`に配置します。

3. **Claude Codeを再起動**
   Claude Codeを再起動するか、新しい会話を開始します。

4. **スキルを呼び出し**
   `/test-workflow-on-branch`で呼び出すか、Claudeに「ワークフローをテストしたい」と伝えます。

## skill.mdの配置場所

- **全プロジェクトで使う場合**: `~/.claude/skills/test-workflow-on-branch/skill.md`
- **特定プロジェクトのみ**: `.claude/skills/test-workflow-on-branch/skill.md`

# test-workflow-on-branchスキルの全文

以下が、実際に作成したskill.mdの全文です。このファイルをそのまま使用できます。

```markdown
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
```

このskill.mdファイルには、実行フローの詳細、トラブルシューティング、実装上の注意点がすべて含まれています。Claude Codeはこのファイルを読み込んで、記述された手順に従って作業を進めてくれます。

# 実際の使用例

実際にこのスキルを使ってみると、以下のような流れになります。

## スキルの呼び出し方

Claude Codeで以下のように入力します：

```
/test-workflow-on-branch
```

または、自然言語で：

```
新しいワークフローをテストしたいんだけど
```

すると、Claudeが自動的にこのスキルを選択して実行してくれます。

## 使ってみた感想

このスキルを作成してから、ワークフローのテストが格段に楽になりました。以前は毎回手順を確認しながら手動で実行していたのが、今ではClaudeに任せるだけで完了します。

特に便利だと感じたのは、一時的なトリガーの削除方法を2つ提示してくれる点です。状況に応じて安全な方法を選べるので、安心して作業できます。

# このスキルで工夫したポイント

## 2段階プロセスの設計

新規ワークフローに対応するため、一時的なトリガー追加→削除の流れを明確化しました。各ステップを番号付きで整理することで、Claudeが迷わず実行できるようにしています。

## 選択肢の提示

一時的なトリガー削除方法を2つ提示（revert vs force push）し、それぞれのメリット・デメリットを説明しています。これにより、ユーザーが状況に応じて適切な方法を選択できます。

## 安全性重視

force pushのリスクを明記し、ユーザーに判断を委ねる設計にしました。「実装上の注意点」セクションで、必ずユーザー確認を求めることを明記しています。

# まとめ

Claude Code Agent Skillsを作成することで、GitHub Actionsのワークフローテストという面倒な作業を自動化できました。

Agent Skillsの素晴らしい点は、一度作成すれば何度でも使い回せることです。また、Markdownファイルで管理できるため、バージョン管理や共有も簡単です。

同じような課題を抱えている方の参考になれば幸いです。他にも、こんなSkillsを作ってみたいというアイデアがあれば、ぜひ試してみてください！

# 最後に

この記事は、筋トレ習慣を作るアプリ『毎日ジム』の開発中に得た知見が元になっています。よかったらぜひ使ってみてください。

https://apps.apple.com/jp/app/id6749178514

また、Xのフォローもよろしくお願いします！

https://x.com/nkjzm

# 参考

- [Running a GitHub Actions workflow that doesn't exist yet on the default branch - Thomas Levesque](https://thomaslevesque.com/2024/04/25/running-a-github-actions-workflow-that-doesnt-exist-yet-on-the-default-branch/)
- [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
- [Agent Skills - Platform Docs](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [GitHub - anthropics/skills](https://github.com/anthropics/skills)
- [GitHub CLI - gh workflow run](https://cli.github.com/manual/gh_workflow_run)
