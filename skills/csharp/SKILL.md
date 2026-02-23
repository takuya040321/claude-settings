---
name: csharp
description: C#開発の4つの領域（コーディング、テスト、環境設定、WebAPI）を統括する包括スキル。タスクに応じて適切な特化リファレンスを参照する。ユーザーが「C#で」「.NETで」「シーシャープ」などC#開発全般に関わるタスクを依頼した場合にトリガー。
---

# C# 開発ガイド

C#開発の包括的なガイド。タスクに応じて適切なリファレンスを参照する。

## タスク別リファレンス

| タスク | リファレンス |
|--------|-------------|
| コード作成・品質チェック | [references/coding.md](references/coding.md) |
| テスト作成・実行（xUnit） | [references/testing.md](references/testing.md) |
| 環境構築・依存管理 | [references/environment.md](references/environment.md) |
| ASP.NET Core WebAPI開発 | [references/aspnet-webapi.md](references/aspnet-webapi.md) |

### 各領域の概要

- **コーディング** - C#規約、nullability、LINQ、async/await、パターンマッチング、DI
- **テスト** - xUnit、Theory、Fixture、Moq、例外テスト、カバレッジ
- **環境** - dotnet new、NuGet管理、ソリューション管理、.NETバージョン
- **WebAPI** - コントローラー設計、ルーティング、DI、ミドルウェア、バリデーション

## スクリプト

```bash
# コード品質チェック（フォーマット・ビルド）
~/.claude/skills/csharp/scripts/check.sh <プロジェクトディレクトリ>

# テスト実行
~/.claude/skills/csharp/scripts/run_tests.sh [テストプロジェクトパス] [--coverage]

# プロジェクト初期化
~/.claude/skills/csharp/scripts/init_project.sh <type> <name>

# 依存関係管理
~/.claude/skills/csharp/scripts/manage_deps.sh <add|remove|list> [パッケージ名]
```

## 推奨ツールスタック

| カテゴリ | ツール | 用途 |
|---------|--------|------|
| SDK | .NET 8.0+ | 開発環境 |
| フォーマット | dotnet format | コード整形 |
| テスト | xUnit | テストフレームワーク |
| モック | Moq | モックライブラリ |
| カバレッジ | coverlet | カバレッジ計測 |

## ワークフロー

### 新規プロジェクト開始

1. `references/environment.md`でプロジェクト初期化
2. `references/coding.md`でコード作成
3. `references/testing.md`でテスト作成・実行

### WebAPI開発

1. `references/environment.md`でWebAPIプロジェクト作成
2. `references/aspnet-webapi.md`でAPI設計・実装
3. `references/testing.md`で統合テスト作成
