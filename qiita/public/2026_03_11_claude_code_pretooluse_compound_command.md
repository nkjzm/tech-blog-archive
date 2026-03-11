---
title: Claude Codeで複合コマンドによるAllowリスト回避を防ぐ
private: false
tags:
  - ClaudeCode
  - Git
  - 開発環境
updated_at: '2026-03-11T16:39:40+09:00'
id: f7032326b6644492665e
organization_url_name: null
slide: false
---

:::note
この記事は[nkjzm](https://x.com/nkjzm)がClaude Codeと一緒に執筆しました。
:::

# はじめに

Claude Codeのsettings.jsonには`permissions.allow`でAllowリストを設定する機能がありますが、`&&`や`;`で結合された複合コマンドだとプレフィックスマッチが正しく機能しません。Allowリストに登録済みのコマンドでも毎回確認プロンプトが表示されるようになり、自動編集モードが中断されてしまいます。

この記事では、PreToolUseフックを使ってこの問題を回避する方法を紹介します。

👇最終的にこうい形で回避できます

![IMG](https://raw.githubusercontent.com/nkjzm/tech-blog-archive/main/images/2026_03_11_claude_code_pretooluse_compound_command.png)
*複合コマンドを実行しようとすると警告が表示されて、分割して実行されている様子*

# 問題の詳細

`permissions.allow`の設定例：

```json:.claude/settings.json
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)"
    ]
  }
}
```

たとえば`Bash(git add:*)`を許可していても、`cd repo && git add .`という複合コマンドはプレフィックスマッチに失敗し、確認プロンプトが表示されます。CLAUDE.mdで「複合コマンドは使わないこと」と指示することで改善はされますが、忘れられてしまうこともあり不確実でした。

## GitHub Issueでの経緯

この問題にはセキュリティ修正との兼ね合いがあります。元々は[#16180](https://github.com/anthropics/claude-code/issues/16180)（`&&`でコマンドを繋ぐとAllowリストをすり抜けて任意コマンドを実行できてしまうセキュリティ問題）が報告され、v2.1.7で修正されました。しかし、その修正の副作用として安全な複合コマンドまで一律ブロックされるようになったのが現在の状況です。

[#28183](https://github.com/anthropics/claude-code/issues/28183)（個々のコマンドがAllowリストに入っていても複合コマンドだとプロンプトが表示されるという報告）は既存Issueと重複するためクローズされています。根本的な解決策として[#16561](https://github.com/anthropics/claude-code/issues/16561)（複合コマンドを`&&`などで分割して各コンポーネントを個別にAllowリストと照合する機能リクエスト）がありますが、2026年3月時点でまだOPENのままです。

つまり、現時点ではClaude Code本体での対応は行われておらず、ワークアラウンドが必要な状況です。

# PreToolUseフックによる解決

PreToolUseフックは、BashやFileEditなどのツール実行前にスクリプトを割り込ませる仕組みです。フックからの出力で`permissionDecision: "deny"`を返すと、Claude Codeは自動的にコマンドを分割して再実行しようとします。

詳しくは[公式ドキュメント（Hooks Guide）](https://docs.anthropic.com/ja/docs/claude-code/hooks)を参照してください。

## settings.jsonへの設定追加

```json:.claude/settings.json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "node ~/.claude/hooks/no-compound-git.js"
          }
        ]
      }
    ]
  }
}
```

## Node.jsスクリプトの実装

`~/.claude/hooks/no-compound-git.js`に以下のスクリプトを配置します。

```javascript:~/.claude/hooks/no-compound-git.js
#!/usr/bin/env node
const fs = require("fs");
const input = fs.readFileSync(0, "utf8");
const data = JSON.parse(input);
const command = data.tool_input?.command || "";

if (/\bgit\b/.test(command) && /(&&|\|\||;)/.test(command)) {
  console.log(JSON.stringify({
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason:
        "gitコマンドに複合コマンド(&&, ||, ;)を使わないでください。各コマンドを個別に実行してください。"
    }
  }));
}
process.exit(0);
```

標準入力からBashツールへの入力（JSONフォーマット）を受け取り、`git`を含む複合コマンドであれば`permissionDecision: "deny"`を返します。それ以外のコマンドは何も出力せず`process.exit(0)`で終了するため、通常のコマンドには影響しません。

`deny`を受け取ったClaude Codeは理由を読み取り、`cd path`と`git add .`のように自動的にコマンドを分割して個別に再実行します。これによりAllowリストのプレフィックスマッチが正常に機能するようになります。

# 最後に

PreToolUseフックを使うことで、settings.jsonのAllowリストだけでは対応しきれない複合コマンドの問題をカバーできます。同じような課題を抱えている方の参考になれば幸いです。

よかったらXのフォローもよろしくお願いします！

https://x.com/nkjzm

# 参考

- [Claude Code公式: Permissions](https://docs.anthropic.com/ja/docs/claude-code/permissions)
- [Claude Codeで特定のコマンドを禁止する方法](https://zenn.dev/izumin_0401/articles/claude-codespecificcommandprohibitionmethod)
- [--dangerously-skip-permissions を安全に使うHooks設定](https://wasabeef.jp/blog/claude-code-secure-bash)
- [Destructive Git Command Protection](https://github.com/Dicklesworthstone/misc_coding_agent_tips_and_scripts/blob/main/DESTRUCTIVE_GIT_COMMAND_CLAUDE_HOOKS_SETUP.md)
- [claude-code-permissions-hook](https://github.com/kornysietsma/claude-code-permissions-hook)
