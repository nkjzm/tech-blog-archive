---
title: SwiftDataでバージョン管理されていないスキーマのマイグレーションを実現する
tags:
  - iOS
  - マイグレーション
  - Swift
  - SwiftData
private: false
updated_at: '2026-01-03T19:25:35+09:00'
id: 9cf2fc3d6cebb3d143b2
organization_url_name: null
slide: false
ignorePublish: false
---

# はじめに

SwiftDataではVersionedSchemaを使うことで、保存するスキーマのバージョン管理を行うことができます。SchemaMigrationPlanと併せて使うことで、スキーマが変更された際にデータベースのマイグレーションを自動的に実行される非常に便利な仕組みを実現できます。

一方で、SwiftDataのスキーマはVersionedSchemaを使わずに利用することもでき、この場合はバージョン管理されていないスキーマ(unversioned)として扱われます。バージョン管理されていないスキーマにはマイグレーションを適用することができないため、既にunversionedでアプリをリリースしていた場合にスキーマ定義を変更できない問題が発生します。

https://x.com/nkjzm/status/2006284539103244551

今回はこの問題を解決するための方法を紹介します。

https://x.com/nkjzm/status/2006304555278180858

もし現在SwiftDataを使い始めたばかりであれば、最初からVersionedSchemaを使っておくことを**強くお勧めします！！**

# 登場するバージョン

- unversioned: バージョン管理されていないスキーマ
- V1: VersionedSchemaとして定義した最初のバージョン。内容はunversionedと同一。
- V2: VersionedSchemaとして定義した2番目のバージョン。内容はV1から変更されている。

# 問題の背景

1. unversionedスキーマをVersionedSchemaに変更することは可能
    - unversionedスキーマと同一のVersionedSchemaを定義すれば、SwiftDataが自動的にマッピングしてくれる
    - computed propertyや修飾子の違いは無視される
2. V1からV2のマイグレーションはSchemaMigrationPlanを使って通常通り実行できる

そのため、unversioned → V1のアプリをリリースし、その後期間を開けた上でV1→V2のマイグレーションを実装したアプリをリリースするという2段階のステップを踏むことで、一見この問題は解決できそうに見えます。

unversioned → V1 の実装イメージ

```swift
// unversionedスキーマ（削除する）
@Model
final class Item {
    var id: String
}

// V1スキーマ
struct SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Item.self]
    }
    @Model
    final class Item {
        var id: String
    }
}

// エイリアス定義
typealias Item = SchemaV1.Item

// ModelContainerの取得
let container = try ModelContainer(
    for: schema,
    configurations: [modelConfiguration]
)
```

V1 → V2 の実装イメージ

```swift
/// V1 → V2の移行プラン
enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    static let migrateV1toV2: MigrationStage = MigrationStage.lightweight(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self
    )
}

// エイリアス定義
typealias Item = SchemaV2.Item

// ModelContainerの取得
let container = try ModelContainer(
    for: schema,
    // MigrationPlanを指定することでV1→V2のマイグレーションが自動実行される
    migrationPlan: MigrationPlan.self,
    configurations: [modelConfiguration]
)
```

しかし、マイグレーションの実行はアプリ起動時のModelContainerの初期化時に行われます。1段階目でリリースされたアプリをアップデートしなかった、もしくは起動しなかったユーザーは2段階目のアップデート時にunversionedスキーマからV2へのマイグレーションを一度に実行する必要があります。

では上記のステップを一度に行おうとするとどうなるでしょう。unversionedスキーマで保存されたデータに対してMigrationPlanを適用すると `CoreData: error: Cannot use staged migration with an unknown model version.` というエラーが発生します。結果としてSwiftDataが既存のデータベースを認識できず、データが壊れたような挙動になってしまいます。

バージョン管理してないスキーマでリリースすると、スキーマの更新ができなくて詰みかけるの、罠すぎないですか…？

# 解決方法：2段階でのModelContainer作成

解決策は、**マイグレーションを2段階に分けて実行する**ことです。

## アプローチ

1. **Step 1**: `MigrationPlan`の指定なしで、一時的なModelContainerで実行
2. **Step 2**: V1 → V2 の移行を通常の`MigrationPlan`で実行

## 実装の全体像

ModelContainerの作成時に2段階移行ロジックを組み込みます。最初に通常のModelContainer作成を試み、失敗した場合に2段階移行を実行しています。

```swift
// ※schemaやmodelConfigurationの初期化は省略
static let container: ModelContainer = {

    do {
        // ========================================
        // Step 1: 通常のModelContainer作成を試行
        // ========================================
        let container = try createModelContainer(
            schema: schema,
            configurations: modelConfiguration
        )
        return container
    } catch {
        // ========================================
        // Step 2: 2段階マイグレーション実行
        // ========================================
        // エラーコード判定は環境依存の可能性があるため、投機的に実行する
        // ※バージョン定義のないモデルを読み込むとCoreDataエラー134504が出力されるが、
        // SwiftDataではなくラップしたCoreDataエラーなので、エラー構造が将来的に変わる可能性を否定できない
        do {

            // Step 2-1: unversioned→V1
            do {
                let v1Container = try ModelContainer(
                    for: Schema(versionedSchema: SchemaV1.self),
                    configurations: [ModelConfiguration(url: storeURL)]
                )
                // mainContextへのアクセスでコンテナの初期化完了を確認する
                // マイグレーション完了はModelContainer初期化時に保証済み
                _ = v1Container.mainContext

                // v1Containerをスコープアウトさせて解放
            } catch {
                throw error
            }

            // Step 2-2: V1→V2
            let container = try createModelContainer(
                schema: schema,
                configurations: modelConfiguration
            )
            return container

        } catch {
            // DBをクリーンにして再作成するフォールバック処理
            return fallbackToCleanDatabase(
                schema: schema,
                modelConfiguration: modelConfiguration,
                storeURL: storeURL
            )
        }
    }
}()

static func createModelContainer(
    schema: Schema,
    configurations: ModelConfiguration
) throws -> ModelContainer {
    let container = try ModelContainer(
        for: schema,
        migrationPlan: MigrationPlan.self,
        configurations: [configurations]
    )
    // 明示的に指定（手動でModelContainerを初期化するとautosaveEnabledがfalseになるらしい）
    container.mainContext.autosaveEnabled = true
    return container
}
```

通常、SwiftDataは`MigrationPlan`に複数バージョンを含めることで、自動的に複数段階の移行を順番に実行できます（例：V1→V2→V3）。

しかし、unversionedからの移行の場合は、この自動処理をそのままでは適用できないため、今回のような手動での2段階処理が必要でした。

# まとめ

SwiftDataでunversionedスキーマから複数段階のマイグレーションを実現する方法を紹介しました。

この手法により、既存ユーザーのデータを保持したまま、スキーマバージョン管理の導入と新しいバージョンへの移行を安全に実施できるはずです。

SwiftDataのマイグレーション機能は強力ですが、unversionedからの移行にはこのような工夫が必要になる場合があります。同じような状況に遭遇した方の参考になれば幸いです。

あと、VersionedSchemaは絶対に最初から使いましょう！！！！！

---

この記事は、筋トレ習慣を作るアプリ『毎日ジム』の開発中に得た知見が元になっています。よかったらぜひ使ってみてください。

https://apps.apple.com/jp/app/id6749178514

また、Xのフォローもよろしくお願いします！

https://twitter.com/nkjzm

# 参考

- [SwiftDataでマイグレーションを行う | ramble - ランブル -](https://ramble.impl.co.jp/7181/)
- [ios - SwiftData Versioning "Cannot use staged migration with an unknown coordinator model version." - Stack Overflow](https://stackoverflow.com/questions/78756798/swiftdata-versioning-cannot-use-staged-migration-with-an-unknown-coordinator-mo)
- [SwiftData sequential migrations](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-create-a-complex-migration-using-versionedschema/)
- [Never use SwiftData without VersionedSchema](https://mertbulan.com/programming/never-use-swiftdata-without-versionedschema)
