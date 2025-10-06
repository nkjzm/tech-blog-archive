---
title: "GitHub ActionsでiOSアプリのバージョン番号を更新するPull Requestを作成する"
emoji: "📱"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["GitHub", "Xcode", "iOS", "GitHubActions"]
published: true
---

# はじめに

現在開発中の iOS アプリでは、下記のような運用を行っています。

- 前バージョンのリリース申請をしたらすぐにバージョン番号をあげる
- 全ての変更は Pull Request を通して行う

リリースたびに毎回バージョン番号をあげるだけの Pull Request を作成するのは面倒なので、GitHub Actions 化を行いました。その方法について紹介します。

こちらの記事の内容を参考にさせていただきました。

https://qiita.com/tichise/items/cc160125a706585d3ced

# バージョンアップ実行の流れ

1. ブラウザ上で GitHub Actions のページを開き、バージョンアップの種類を選択して実行する。

![スクリーンショット 2025-10-05 17.54.13.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/b78bbb5c-a753-4c6c-9d8d-5358b78cf28a.png)

2. バージョン番号が更新された Pull Request が作成されるので、内容を確認してマージする

![スクリーンショット 2025-10-05 17.56.04.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/b68862c0-7144-4cd2-96cf-4934031addcb.png)

注意事項としては、このワークフローでは全てのターゲットのバージョン番号であることが前提となっています。もし、特定のターゲットだけバージョン番号をあげたい場合は、スクリプトを修正する必要がある点にご注意ください。

# 導入方法

下記の yml ファイルを `.github/workflows` 以下に追加します。初回の実行をするためには default ブランチに追加する必要があります。

`YOUR_PROJECT_NAME`の部分だけ自分のプロジェクト名に変更してください。project.pbxproj を取得するための必要です。(e.g. `YOUR_PROJECT_NAME.xcodeproj/project.pbxproj`)

```yaml:versionup.yml
name: Manual Version up

on:
  workflow_dispatch:
    inputs:
      update_type:
        description: "バージョンアップの種類を選択"
        type: choice
        required: true
        options:
          - patch
          - minor
          - major
        default: "patch"

permissions:
  contents: write
  pull-requests: write

jobs:
  versionup:
    runs-on: ubuntu-latest
    env:
      PROJECT_NAME: YOUR_PROJECT_NAME # プロジェクト名を入力する
    steps:
      - uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          sparse-checkout: |
            ${{ env.PROJECT_NAME }}.xcodeproj/project.pbxproj

      - name: Get Version
        id: get_version
        run: |
          PROJECT_FILE="${{ env.PROJECT_NAME }}.xcodeproj/project.pbxproj"
          CURRENT_VERSION=$(grep "MARKETING_VERSION" $PROJECT_FILE | head -1 | \
            sed 's/.*MARKETING_VERSION = \(.*\);.*/\1/')

          MAJOR=$(echo $CURRENT_VERSION | cut -d. -f1)
          MINOR=$(echo $CURRENT_VERSION | cut -d. -f2)
          PATCH=$(echo $CURRENT_VERSION | cut -d. -f3)

          case "${{ github.event.inputs.update_type }}" in
            major)
              NEW_VERSION="$((MAJOR + 1)).0.0"
              ;;
            minor)
              NEW_VERSION="${MAJOR}.$((MINOR + 1)).0"
              ;;
            patch)
              NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))"
              ;;
          esac
          echo "current_version=$CURRENT_VERSION" >> $GITHUB_OUTPUT
          echo "new_version=$NEW_VERSION" >> $GITHUB_OUTPUT

      - name: Update App Version
        run: |
          PROJECT_FILE="${{ env.PROJECT_NAME }}.xcodeproj/project.pbxproj"
          find . -name "*.pbxproj" -exec sed -i.bak \
            "s/MARKETING_VERSION = .*;/MARKETING_VERSION = ${{ steps.get_version.outputs.new_version }};/g" {} \;
          CURRENT_BUILD=$(grep "CURRENT_PROJECT_VERSION" $PROJECT_FILE | head -1 | \
            sed 's/.*CURRENT_PROJECT_VERSION = \(.*\);.*/\1/')
          NEW_BUILD=$((CURRENT_BUILD + 1))
          find . -name "*.pbxproj" -exec sed -i.bak \
            "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/g" {} \;
          find . -name "*.pbxproj.bak" -delete

      - name: Commit and Push Changes
        run: |
          git config --global user.name "github-actions[bot]"
          git config --global user.email "github-actions[bot]@users.noreply.github.com"
          git fetch -p
          NEW_VERSION="${{ steps.get_version.outputs.new_version }}"
          BRANCH_NAME="release/${NEW_VERSION}"
          git checkout -b $BRANCH_NAME
          git add .
          git commit -m "バージョン番号を${NEW_VERSION}に更新"
          git push origin HEAD

      - name: Create Pull Request
        env:
          GH_TOKEN: ${{ secrets.PERSONAL_ACCESS_TOKEN || secrets.GITHUB_TOKEN }}
        run: |
          CURRENT_VERSION="${{ steps.get_version.outputs.current_version }}"
          NEW_VERSION="${{ steps.get_version.outputs.new_version }}"
          UPDATE_TYPE="${{ github.event.inputs.update_type }}"
          gh pr create \
            --title "バージョン番号を${NEW_VERSION}に更新" \
            --body "$(cat <<EOF
          ## 概要
          バージョン番号を${NEW_VERSION}に更新しました。

          ## 変更内容
          - MARKETING_VERSION: ${CURRENT_VERSION} -> ${NEW_VERSION}

          ## 更新種別
          ${UPDATE_TYPE} バージョンアップ

          ---
          🤖 このPRは GitHub Actions により自動生成されました
          EOF
          )"
```

次に必要な secrets を設定します。`secrets.GITHUB_TOKEN`はデフォルトで用意されているのでですが、Pull Request の作成には権限が足りない場合があるため、別途でトークンを登録する必要があります。

まずは下記から Pull Request の作成権限を持つ Personal Access Token を作成してください。

https://github.com/settings/tokens

classic で作成する場合 repo にチェックを入れれば OK です。強い権限なので、適切に Expiration などを設定してください。

![スクリーンショット 2025-10-05 18.19.49.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55365/821c56b2-564a-447b-a8d1-5cdfbfae030e.png)

次に、生成したトークンを secrets として登録します。リポジトリの Settings > Secrets and variables > Actions から `PERSONAL_ACCESS_TOKEN` という名前で下記の権限を持つトークンを登録してください。

以上で手順は完了です。GitHub Actions のページからワークフローを選択して `Run workflow` を実行してみてください。

# 最後に

今回は GitHub Actions を使って iOS アプリのバージョン番号を更新する Pull Request を自動生成する方法を紹介しました。手動でやっても 5 分程度で終わる作業ですが、自動化することで 1 分未満で完了するようになりました。こうした小さな改善が開発体験の向上につながると思うので、ぜひ試してみてください。

このワークフローを使っている『毎日ジム』は iOS 向けに配信中です。よかったらぜひダウンロードしてみてください。

https://apps.apple.com/jp/app/id6749178514

また、X(Twitter)でも情報発信していますので、よかったらフォローお願いします！

https://x.com/nkjzm
