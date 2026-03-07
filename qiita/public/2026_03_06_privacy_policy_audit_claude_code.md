---
title: Claude Codeでコード上からApp Store向けのプライバシーポリシーを自動生成する
private: false
tags:
  - ClaudeCode
  - iOS
  - AI
updated_at: '2026-03-07T04:05:45.328Z'
id: null
organization_url_name: null
slide: false
---

:::note
この記事は[nkjzm](https://x.com/nkjzm)がClaude Codeと一緒に執筆しました。
:::

# はじめに

App Store Connectの「アプリのプライバシー」セクションは質問項目が多く、正確に記入するのが難しいです。SDKが間接的に収集するデータや、Info.plistの権限キーとデータカテゴリの対応関係など、見落としやすいポイントが多くあります。

そこで、Claude Codeにコードを読ませることで正確なデータ収集の状況を調査・分析する仕組みを作りました。この情報を元にApp Store Connect向けの推奨回答やプライバシーポリシーの生成を行い、最終的に人間が内容を確認した上で公開するフローになっています。

先日リリースしたこちらのアプリを例に出力例を紹介します。

https://apps.apple.com/jp/app/%E3%83%A9%E3%83%83%E3%82%AD%E3%83%BC%E3%83%91%E3%83%8D%E3%83%AB%E8%A7%A3%E3%81%8F%E3%82%84%E3%81%A4-for-dq7r/id6759818873

今回紹介する仕組みを使ったところ、依存ライブラリの解析で以下のSDKが検出されました。

| SDK | プライバシーへの影響 |
|---|---|
| firebase-ios-sdk | Analytics（使用状況データ）、Crashlytics（診断データ）を収集 |
| swift-package-manager-google-mobile-ads | AdMob広告：ID（デバイスID/IDFA）、広告データ収集 |
| swift-package-manager-google-user-messaging-platform | ATT/GDPR同意フォーム表示 |

これらのSDK情報とソースコード分析の結果を統合し、App Store Connectへの推奨回答テーブルが生成されます。これを見ながらブラウザ上でApp Store Connectの質問項目に回答していくことができます。

![IMG](https://raw.githubusercontent.com/nkjzm/tech-blog-archive/main/images/2026_03_06_privacy.png)

また、生成したプライバシーポリシーの例がこちらです。1つのポリシーで複数のプラットフォームに提出できるよう、App StoreやGoogle Play、GDPRなどのそれぞれの要件を満たすような内容にしています。
https://nkjzm.jp/privacy-policy

# 仕組みの全体像

`privacy-policy`というリポジトリを作成し、プライバシーポリシーに関する機能をまとめています。

- **/privacy-audit** — iOSアプリのリポジトリを静的解析し、App Store Connectの「アプリのプライバシー」セクションへの推奨回答を生成
- **/privacy-label-diff** — 監査レポートとApp Store上の実際のプライバシーラベルを突き合わせて差分を検出
- **/update-policy** — 監査レポートの結果をもとにプライバシーポリシー（ja/en）の更新差分を分析・提示し、承認後に適用
- **プライバシーポリシーの自動公開** — Markdownで日英2言語を管理し、mainブランチへのpush時に公開ページへ自動同期

プロジェクトは下記のような構成になっています

```
privacy-policy/
├── .claude/commands/
│   ├── privacy-audit.md               # プライバシー監査カスタムコマンド
│   ├── privacy-label-diff.md          # プライバシーラベル突き合わせコマンド
│   └── update-policy.md               # ポリシー更新コマンド
├── .github/workflows/sync-notion.yml  # 自動同期ワークフロー
├── app-store-privacy-reference.md     # App Store Connect 質問項目リファレンス
├── privacy-policy-requirements.md     # プライバシーポリシー要件リファレンス
├── apps.md                            # アプリリスト（カスタムコマンドで参照）
├── audits/                            # アプリ別監査レポート出力先
├── privacy-policy-ja.md               # プライバシーポリシー（日本語）
├── privacy-policy-en.md               # Privacy Policy (English)
└── scripts/
    ├── fetch-privacy-label.sh         # プライバシーラベル取得スクリプト
    └── sync-to-notion.sh              # Notion同期スクリプト
```

# /privacy-audit - App Store プライバシー監査の自動化

App Store Connectの「アプリのプライバシー」では、アプリが収集するデータの種類・目的・関連付け・トラッキングの有無を申告する必要があります。全16カテゴリにわたる質問に正確に回答するには、使用しているSDKの挙動やInfo.plistの権限キー、ソースコード上のAPI呼び出しを横断的に把握しなければなりません。

## 監査の流れ

カスタムコマンドは以下の7ステップで監査を行います。

1. **プロジェクト構造の把握** — `.xcodeproj`や`.xcworkspace`からアプリ名を特定し、ディレクトリ構造を把握
2. **リファレンス読み込み** — `app-store-privacy-reference.md`を判断基準として読み込み
3. **依存ライブラリの特定** — `Package.resolved`や`Podfile.lock`からSDKを検出し、リファレンスと照合
4. **Info.plist権限キーの検出** — `NSCameraUsageDescription`や`GADApplicationIdentifier`等の有無を確認
5. **PrivacyInfo.xcprivacyの解析** — トラッキング設定、トラッキングドメイン、宣言済みデータタイプを読み取り
6. **ソースコード分析** — HealthKit、Firebase、AdMob等の使用パターンをSwift/Objective-Cソースから検索
7. **結果統合と推奨回答生成** — 全ステップの結果を統合し、App Store Connectの全データタイプへの推奨回答を決定

証拠が見つかれば「収集あり」、なければ「収集なし」、静的解析で判定できない場合は「手動確認必要」としてフラグを立てます。

## 手動確認が必要な項目

静的解析では判定できない項目もレポートに記載されます。たとえばLuckeyPanelの場合、以下の指摘がありました。

- `google-ads-on-device-conversion-ios-sdk`が依存に含まれており、オンデバイス処理のため外部送信はないとされるが、コンバージョン計測目的の使用箇所を確認すること
- `identifierForVendor`（IDFV）がデバッグ機能のアクセス制御に使用されているが、外部サーバーに送信されていないことの確認が必要

このように、完全自動化ではなく「AIの出力を人間が確認するフロー」になっています。

<!-- TODO: App Store Connectの画面スクリーンショットを追加 -->

# /privacy-label-diff - App Storeプライバシーラベルとの突き合わせ

`/privacy-audit`で生成した監査レポートと、App Store上で実際に申告されているプライバシーラベルを突き合わせるコマンドです。`scripts/fetch-privacy-label.sh`でApp Storeページからプライバシーラベル情報を取得し、監査レポートとの差分を「申告不足」「過剰申告」「属性不一致」の3種類で検出します。結果は監査レポートの末尾に追記されるため、監査→突き合わせの流れで一貫した記録が残ります。

このコマンドはリリース済みのアプリであることが前提となっているため、 `/privacy-audit`とは別コマンドとして用意しました。

# /update-policy - プライバシーポリシーの更新

監査レポートの内容をもとに、プライバシーポリシー（日本語・英語）の更新が必要な箇所を分析するコマンドです。監査レポートの「収集するデータ」テーブルと現行ポリシーのアプリ別セクションを突き合わせ、追加・削除・修正の提案を一覧で提示します。自動適用ではなく、提案を確認した上で承認する設計にしているため、意図しない変更が入ることはありません。

# リファレンスファイルの役割

カスタムコマンドが正確な判断を行うために、2つのリファレンスファイルを用意しています。

`app-store-privacy-reference.md`は`/privacy-audit`が参照する知識ベースで、以下の情報をまとめています。

- **全16カテゴリ × データタイプ一覧** — App Store Connectで回答が必要な全項目と、iOSでの典型的な検出パターン
- **SDKとプライバシーへの影響マッピング** — Firebase、AdMob、RevenueCat等の主要SDKが収集するデータの一覧
- **Info.plist権限キーとデータカテゴリの対応表** — `NSCameraUsageDescription`→写真またはビデオ、のような対応関係

`privacy-policy-requirements.md`は`/update-policy`が参照する要件定義で、プライバシーポリシーが満たすべき条件をプラットフォームごとにまとめています。Apple App StoreのReview Guidelines、Google Playのデータ安全セクション、GDPRの必須要素に加え、日英整合性やポリシーの構造ルールも定義しています。

これらのリファレンスがないとAIは一般知識に頼ることになり、SDKのバージョンアップによるデータ収集の変更や、各プラットフォームの要件更新に追従できません。正確な判断基準を手元に持たせることが精度向上のポイントです。

# プライバシーポリシーの自動公開ワークフロー

プライバシーポリシーはNotion上で管理しており、Wraptasというサービスで静的サイトとして公開しています。

https://nkjzm.jp/privacy-policy

そこで、リポジトリ上で変更したプライバシーポリシーの.mdファイルをGitHubにpushすると、GitHub Actionsが自動でNotionページを更新する仕組みを作りました。同期スクリプトはNotion APIの`Notion-Version: 2025-09-03`で導入されたMarkdown APIを使用しており、既存ページのコンテンツをクリアしてからMarkdownを挿入する2ステップで動作します。

```yaml:sync-notion.yml
name: Sync to Notion

on:
  push:
    branches: [main]
    paths:
      - 'privacy-policy-ja.md'
      - 'privacy-policy-en.md'
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v4
      - run: sudo apt-get install -y jq
      - name: Sync privacy policy (EN + JA) to Notion
        env:
          NOTION_TOKEN: ${{ secrets.NOTION_TOKEN }}
        run: |
          ./scripts/sync-to-notion.sh "${{ secrets.NOTION_PAGE_ID }}" privacy-policy-en.md privacy-policy-ja.md
```

# 最後に

Claude Codeのカスタムスラッシュコマンドを使うことで、App Store Connectのプライバシー回答に必要な情報収集を自動化することができました。同じような課題を抱えている方の参考になれば幸いです。

この仕組みを作るきっかけになった『ラッキーパネル解くやつ for DQ7R』は、ドラゴンクエスト7リイマジンド内に出てくるミニゲームを解くための専用アプリです。トロコンを目指す際にかなりの周回が必要になるので、その手助けとなるアプリになっています。よかったら使ってみてください！

https://apps.apple.com/jp/app/%E3%83%A9%E3%83%83%E3%82%AD%E3%83%BC%E3%83%91%E3%83%8D%E3%83%AB%E8%A7%A3%E3%81%8F%E3%82%84%E3%81%A4-for-dq7r/id6759818873

また、『毎日ジム』という、ジム通いの習慣化をサポートするアプリもリリースしています！エンジニアなら嬉しいGitHub Contribution風のウィジェットに対応していておすすめです！
https://apps.apple.com/jp/app/%E6%AF%8E%E6%97%A5%E3%82%B8%E3%83%A0-%E7%AD%8B%E3%83%88%E3%83%AC%E7%BF%92%E6%85%A3%E3%82%92%E3%81%A4%E3%81%8F%E3%82%8B%E3%82%A2%E3%83%97%E3%83%AA/id6749178514

Xのフォローもよろしくお願いします！

https://x.com/nkjzm


