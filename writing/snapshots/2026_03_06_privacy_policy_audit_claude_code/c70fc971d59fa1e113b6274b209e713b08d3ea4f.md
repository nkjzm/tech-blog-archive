---
title: "Claude Codeで実コードからApp Storeプライバシー回答を自動生成する"
emoji: "🔒"
type: "tech"
topics: ["ClaudeCode","iOS","AI"]
published: true
---

# はじめに

App Store Connectの「アプリのプライバシー」セクションは質問項目が多く、正確に記入するのが難しいです。SDKが間接的に収集するデータや、Info.plistの権限キーとデータカテゴリの対応関係など、見落としやすいポイントが多くあります。

手動で回答するとミスが生じやすいため、Claude Codeにコードを読ませて推奨回答を生成する仕組みを作りました。今回はその仕組みについて紹介します。

# 仕組みの全体像

`privacy-policy`というリポジトリを作成し、2つの機能をまとめています。

1. **プライバシーポリシーのGit管理 + Notion自動同期** — Markdownで日英2言語を管理し、mainブランチへのpush時にNotionページへ自動同期
2. **Claude Codeカスタムコマンドによるプライバシー監査** — iOSアプリのリポジトリを静的解析し、App Store Connectへの推奨回答を生成

```
privacy-policy/
├── .claude/commands/
│   └── privacy-audit.md               # プライバシー監査カスタムコマンド
├── .github/workflows/sync-notion.yml  # 自動同期ワークフロー
├── app-store-privacy-reference.md     # App Store Connect 質問項目リファレンス
├── audits/                            # アプリ別監査レポート出力先
├── privacy-policy-ja.md               # プライバシーポリシー（日本語）
├── privacy-policy-en.md               # Privacy Policy (English)
└── scripts/
    └── sync-to-notion.sh              # Notion同期スクリプト
```

この記事ではメインとなるプライバシー監査の仕組みを中心に紹介し、Notion同期については最後に概要だけ触れます。

# プライバシーポリシーのGit管理とNotion自動同期

プライバシーポリシーをMarkdownファイルとしてGit管理し、mainブランチへのpush時にGitHub ActionsでNotionページへ自動同期しています。mdファイルがSingle Source of Truthとなるため、Notion側を直接編集する必要がなく、変更履歴もGitで追跡できます。詳細は記事末尾で触れます。

# App Store プライバシー監査の自動化

App Store Connectの「アプリのプライバシー」では、アプリが収集するデータの種類・目的・関連付け・トラッキングの有無を申告する必要があります。全16カテゴリにわたる質問に正確に回答するには、使用しているSDKの挙動やInfo.plistの権限キー、ソースコード上のAPI呼び出しを横断的に把握しなければなりません。

この作業をClaude Codeのカスタムコマンドとして自動化しました。

## 使い方

Claude Codeで以下のように実行します。

```
/privacy-audit LuckeyPanel
```

アプリ名を引数として渡すと、そのリポジトリを対象に静的解析を実行し、`audits/`ディレクトリに監査レポートを出力します。

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

## privacy-audit.md（カスタムコマンド全文）

以下が`.claude/commands/privacy-audit.md`の全文です。このファイルをprivacy-policyリポジトリの`.claude/commands/`に配置することで、`/privacy-audit`コマンドとして使えるようになります。

````markdown
# Privacy Audit — App Store Connect プライバシー調査コマンド

iOSアプリのリポジトリを静的解析し、App Store Connectの「アプリのプライバシー」セクションへの推奨回答を生成する。

## 使用方法

```
/privacy-audit {アプリ名（部分一致可）}
```

例:
```
/privacy-audit luckey
/privacy-audit EverydayGym
/privacy-audit /Users/nkjzm/Projects/EverydayGym
```

---

## 実行手順

以下のステップを順番に実行し、最後に監査レポートを生成すること。

### ステップ1: アプリリスト解決とプロジェクト構造の把握

**アプリリスト解決:**

1. `/Users/nkjzm/Projects/privacy-policy/apps.md` のテーブルを読む
2. 引数と「アプリ名」列および「日本語名」列を大文字小文字無視で部分一致検索する
3. 一致が1件 → そのリポジトリパスを `{リポジトリパス}` として使用する
4. 一致が0件 → 引数をそのままリポジトリパス（絶対パス）として扱う（後方互換）
5. 一致が複数件 → ユーザーに候補を提示して選択を求める

**プロジェクト構造の把握:**

1. `{リポジトリパス}` 直下の `.xcodeproj` または `.xcworkspace` を探してアプリ名を特定する
2. プロジェクトのディレクトリ構造を把握する（`build/`, `Pods/`, `.build/` は無視）
3. `PrivacyInfo.xcprivacy` ファイルの存在を確認する

### ステップ2: リファレンス読み込み

`/Users/nkjzm/Projects/privacy-policy/app-store-privacy-reference.md` を読み込み、調査の判断基準とする。

### ステップ3: 依存ライブラリの特定

以下のファイルを探して読み込む（存在するもののみ）：

- `{リポジトリパス}/Package.resolved` — Swift Package Manager
- `{リポジトリパス}/**/Package.resolved` — SPM（サブディレクトリ含む）
- `{リポジトリパス}/Podfile.lock` — CocoaPods
- `{リポジトリパス}/Cartfile.resolved` — Carthage

検出したSDKをリファレンスの「SDKとプライバシーへの影響マッピング」と照合する。

特に注目するSDK:
- `Firebase/Analytics`, `FirebaseAnalytics`
- `Firebase/Crashlytics`, `FirebaseCrashlytics`
- `Firebase/Auth`, `FirebaseAuth`
- `Google-Mobile-Ads-SDK`, `GoogleMobileAds`
- `AdMob`
- `RevenueCat`
- `Amplitude`
- `Sentry`
- `Intercom`
- `Adjust`, `AppsFlyer`

### ステップ4: Info.plist 権限キーの検出

`{リポジトリパス}` 配下の `Info.plist` を探す（`build/`, `Pods/`, `.build/` は除外）。

以下のキーの有無を確認する：
- `NSCameraUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSPhotoLibraryAddUsageDescription`
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSContactsUsageDescription`
- `NSHealthShareUsageDescription`
- `NSHealthUpdateUsageDescription`
- `NSMotionUsageDescription`
- `NSBluetoothPeripheralUsageDescription`
- `NSBluetoothAlwaysUsageDescription`
- `GADApplicationIdentifier`
- `NSUserTrackingUsageDescription`
- `NSFaceIDUsageDescription`

### ステップ5: PrivacyInfo.xcprivacy の解析

`PrivacyInfo.xcprivacy` が存在する場合、以下を読み取る：
- `NSPrivacyTracking` の値（true/false）
- `NSPrivacyTrackingDomains` のリスト
- `NSPrivacyCollectedDataTypes` の各エントリ（データタイプ、関連付け、トラッキング、目的）

### ステップ6: ソースコード分析

`{リポジトリパス}` 配下の Swift/Objective-Cソースファイルを検索する。
**除外ディレクトリ**: `build/`, `Pods/`, `.build/`, `DerivedData/`

以下のパターンを検索する（各パターンでファイル名と行番号を記録）：

**健康・フィットネス**:
- `HKHealthStore`, `HKQuantityType`, `HKWorkout`, `HKObjectType`
- `CMMotionManager`, `CMPedometer`

**位置情報**:
- `CLLocationManager`, `CLLocation`
- `kCLLocationAccuracyBest`, `requestWhenInUseAuthorization`, `requestAlwaysAuthorization`

**連絡先**:
- `CNContactStore`, `CNContact`

**カメラ・マイク・写真**:
- `AVCaptureSession`, `AVAudioRecorder`
- `PHPhotoLibrary`, `UIImagePickerController`
- `PHAsset`

**Firebase**:
- `Analytics.logEvent`, `Analytics.setUserProperty`
- `Crashlytics.crashlytics()`, `CrashlyticsKit`
- `Auth.auth()`, `FirebaseAuth`
- `Firestore.firestore()`, `Database.database()`

**広告・トラッキング**:
- `GADBannerView`, `GADInterstitialAd`, `GADRewardedAd`
- `GADMobileAds.sharedInstance()`
- `ASIdentifierManager`, `advertisingIdentifier`
- `ATTrackingManager`

**データ永続化**:
- `UserDefaults.standard` （ユーザーデータの保存）
- `CoreData`, `NSManagedObjectContext`
- `Keychain`

**ネットワーク通信**:
- `URLSession.shared.dataTask`
- `Alamofire`, `AF.request`
- `API`, `HTTPClient`, `NetworkManager`（カスタムAPIクライアントの存在確認）

**認証**:
- `Sign in with Apple`, `ASAuthorizationAppleIDProvider`
- `GoogleSignIn`, `GIDSignIn`

**RevenueCat / 課金**:
- `Purchases.shared`, `RevenueCat`
- `SKPaymentQueue`, `StoreKit`

### ステップ7: 結果の統合と推奨回答の生成

ステップ3〜6の結果を統合して、App Store Connectの全データタイプに対して推奨回答を決定する。

判断基準:
- 証拠（SDK/コードパターン）が見つかった場合 → 「収集あり」
- 証拠がない場合 → 「収集なし」
- サーバーサイドの収集が疑われる場合 → 「手動確認必要」としてフラグ

---

## 出力形式

以下の形式で `/Users/nkjzm/Projects/privacy-policy/audits/{app-name}-privacy-audit.md` を生成すること。

```markdown
# {アプリ名} プライバシー監査レポート

監査日: {実行日}
リポジトリ: {リポジトリパス}
監査者: Claude Code (静的解析)

---

## 検出サマリー

### 依存SDK一覧
| SDK | バージョン | プライバシーへの影響 |
|---|---|---|
| {SDK名} | {バージョン} | {影響} |

### Info.plist 権限キー
| キー | 値（説明文） | 対応データカテゴリ |
|---|---|---|
| {キー名} | {値} | {カテゴリ} |

### PrivacyInfo.xcprivacy
- トラッキング: {あり/なし/ファイルなし}
- トラッキングドメイン: {リスト}
- 宣言済みデータタイプ: {リスト}

### ソースコード検出結果
| パターン | 検出ファイル | 判断 |
|---|---|---|
| {パターン} | {ファイル名:行番号} | {データカテゴリへの影響} |

---

## App Store Connect 推奨回答

### データを収集しない
（このセクションには収集なしと判断したカテゴリを列挙）

### 収集するデータ

| カテゴリ | データタイプ | 収集 | 目的 | ユーザーに関連付け | トラッキング | 根拠 |
|---|---|---|---|---|---|---|
| 診断 | クラッシュデータ | あり | アプリの機能 | あり | なし | Firebase Crashlytics検出 |
| ... | ... | ... | ... | ... | ... | ... |

---

## 手動確認が必要な項目

以下は静的解析では判定できないため、開発者による確認が必要：

1. **サーバーサイドのデータ収集**: APIリクエストでサーバーに送信・保存されるデータ
   - 確認方法: バックエンドのデータモデルとAPIエンドポイントを確認
2. {その他、判断が難しかった項目}

---

## 備考

{調査中に気づいた注意点、不確かな判断の理由など}
```

---

## 注意事項

- このコマンドは静的解析のみ実施する。サーバーサイドの収集は検出できない
- 検出されなかったからといって「収集なし」と断定できない場合は、「手動確認が必要な項目」に記載する
- 最終的な App Store Connect への回答はエンジニアが内容を確認した上で行うこと
- AdMobを使用しているアプリは、ATTフレームワークの有無に関わらず「識別子 → デバイスID」の収集を開示することが推奨される
````

## app-store-privacy-reference.md の役割

カスタムコマンドの中で「ステップ2: リファレンス読み込み」として参照されている`app-store-privacy-reference.md`は、AIが判断を行うための知識ベースです。以下の情報をまとめています。

- **全16カテゴリ × データタイプ一覧** — App Store Connectで回答が必要な全項目と、iOSでの典型的な検出パターン
- **SDKとプライバシーへの影響マッピング** — Firebase、AdMob、RevenueCat等の主要SDKが収集するデータの一覧
- **Info.plist権限キーとデータカテゴリの対応表** — `NSCameraUsageDescription`→写真またはビデオ、のような対応関係

このリファレンスがないとAIは一般知識に頼ることになり、SDKのバージョンアップによるデータ収集の変更や、App Storeの質問項目の更新に追従できません。正確な判断基準を手元に持たせることが精度向上のポイントです。

# 実際の出力例

LuckeyPanelというアプリに対して実行した結果から、主要な部分を抜粋します。

## 検出されたSDKと推奨回答

依存ライブラリの解析で以下のSDKが検出されました。

| SDK | プライバシーへの影響 |
|---|---|
| firebase-ios-sdk | Analytics（使用状況データ）、Crashlytics（診断データ）を収集 |
| swift-package-manager-google-mobile-ads | AdMob広告：識別子（デバイスID/IDFA）、広告データ収集 |
| swift-package-manager-google-user-messaging-platform | ATT/GDPR同意フォーム表示 |

これらのSDK情報とソースコード分析の結果を統合し、以下の推奨回答テーブルが生成されます。

| カテゴリ | データタイプ | 収集 | 目的 | ユーザーに関連付け | トラッキング | 根拠 |
|---|---|---|---|---|---|---|
| 識別子 | ユーザーID | あり | アプリの機能 | あり | なし | `Crashlytics.crashlytics().setUserID()` 検出 |
| 識別子 | デバイスID (IDFA) | あり | サードパーティ広告 | あり | あり | AdMob + ATTrackingManager検出 |
| 使用状況データ | 製品の操作記録 | あり | 分析 | あり | なし | Firebase Analytics (`Analytics.logEvent`) 検出 |
| 使用状況データ | 広告データ | あり | サードパーティ広告 | あり | あり | AdMob BannerView検出 |
| 診断 | クラッシュデータ | あり | アプリの機能 | あり | なし | Firebase Crashlytics検出 |

## 手動確認が必要な項目

静的解析では判定できない項目もレポートに記載されます。たとえばLuckeyPanelの場合、以下の指摘がありました。

- `ATTrackingManager.requestTrackingAuthorization`を呼び出しているが、Info.plistに`NSUserTrackingUsageDescription`が見当たらない → Xcode設定またはxcstringsで定義されているか要確認
- `PrivacyInfo.xcprivacy`の`NSPrivacyCollectedDataTypes`が空配列 → Firebase/AdMobを使用しているため、App Store審査前にデータタイプの追加が必要

このように、完全自動化ではなく「AIの出力を人間が確認するフロー」になっています。

<!-- TODO: App Store Connectの画面スクリーンショットを追加 -->

# 工夫したポイント

リファレンスファイル（`app-store-privacy-reference.md`）を別途用意してAIの判断精度を上げた点が大きいです。全16カテゴリのデータタイプ一覧、SDKごとの収集データマッピング、Info.plist権限キーとデータカテゴリの対応表を1ファイルにまとめています。これがないとAIが自身の学習データに頼ることになり、SDKの仕様変更や新しいAPIカテゴリに対応できません。

また、静的解析の限界を明示して「手動確認が必要な項目」セクションを設けています。サーバーサイドでのデータ収集や、Info.plistとコードの不整合など、コードを読むだけでは判定できない項目は人間に判断を委ねる設計にしました。AIに「分からないものは分からないと言わせる」ことで、過信による見落としを防いでいます。

# Notion自動同期のワークフロー

プライバシーポリシーのNotion同期についても簡単に紹介します。

`privacy-policy-ja.md`または`privacy-policy-en.md`を編集してmainブランチにpushすると、GitHub Actionsが自動でNotionページを更新します。同期スクリプトはNotion APIの`Notion-Version: 2025-09-03`で導入されたMarkdown APIを使用しており、既存ページのコンテンツをクリアしてからMarkdownを挿入する2ステップで動作します。

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

英語版と日本語版の2ファイルを結合して1つのNotionページに同期しています。mdファイルがSingle Source of Truthなので、Notion側を直接編集する必要はありません。

# 最後に

Claude Codeのカスタムコマンドを使うことで、App Store Connectのプライバシー回答に必要な情報収集を自動化できました。同じような課題を抱えている方の参考になれば幸いです。

よかったらXのフォローもよろしくお願いします！

https://x.com/nkjzm
