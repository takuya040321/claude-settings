---
name: csharp
description: C#開発の4つの領域（コーディング、テスト、環境設定、WebAPI）を統括する包括スキル。タスクに応じて適切な特化スキルを呼び出す。ユーザーが「C#で」「.NETで」「シーシャープ」などC#開発全般に関わるタスクを依頼した場合にトリガー。
---

# C# 開発ガイド

C#開発の包括的なガイド。タスクに応じて適切な特化スキルを選択する。

## タスク振り分け

### 1. コード作成・品質チェック（csharp-coding）

以下の場合に`csharp-coding`スキルを使用：

- C#コードの作成・編集
- コードのフォーマット（dotnet format）
- ビルド・コンパイルエラーチェック
- コーディング規約・ベストプラクティス

**トリガー例**:
- 「C#でクラスを作成して」
- 「このコードをリファクタリングして」
- 「LINQ式に書き換えて」

### 2. テスト作成・実行（csharp-testing）

以下の場合に`csharp-testing`スキルを使用：

- xUnitを使ったテストの作成
- テストの実行・デバッグ
- モック（Moq）の設定
- テストカバレッジの計測

**トリガー例**:
- 「テストを書いて」
- 「dotnet testを実行して」
- 「このクラスのユニットテストを作成して」

### 3. 環境構築・依存管理（csharp-environment）

以下の場合に`csharp-environment`スキルを使用：

- プロジェクトの作成（dotnet new）
- NuGetパッケージの追加・更新・削除
- ソリューション管理
- .NETバージョン管理

**トリガー例**:
- 「新しいC#プロジェクトを作成して」
- 「コンソールアプリを作成して」
- 「Newtonsoftパッケージを追加して」

### 4. ASP.NET Core WebAPI開発（csharp-aspnet-webapi）

以下の場合に`csharp-aspnet-webapi`スキルを使用：

- REST API開発
- コントローラー作成
- 依存性注入（DI）設定
- ミドルウェア設定

**トリガー例**:
- 「WebAPIを作成して」
- 「CRUDエンドポイントを実装して」
- 「コントローラーを追加して」

## クイックリファレンス

### プロジェクト初期化

```bash
# コンソールアプリ作成
~/.claude/skills/csharp-environment/scripts/init_project.sh console myapp

# クラスライブラリ作成
~/.claude/skills/csharp-environment/scripts/init_project.sh classlib mylibrary

# WebAPI作成
~/.claude/skills/csharp-environment/scripts/init_project.sh webapi myapi
```

### コード品質チェック

```bash
# フォーマット・ビルドチェック
~/.claude/skills/csharp-coding/scripts/check.sh .
```

### テスト実行

```bash
# テスト実行
~/.claude/skills/csharp-testing/scripts/run_tests.sh

# カバレッジ付き
~/.claude/skills/csharp-testing/scripts/run_tests.sh --coverage
```

### 依存関係管理

```bash
# パッケージ追加
dotnet add package Newtonsoft.Json

# パッケージ更新
dotnet add package Newtonsoft.Json --version 13.0.3

# パッケージ削除
dotnet remove package Newtonsoft.Json
```

## 推奨ツールスタック

| カテゴリ | ツール | 用途 |
|---------|--------|------|
| SDK | .NET 8.0+ | 開発環境 |
| フォーマット | dotnet format | コード整形 |
| ビルド | dotnet build | コンパイル |
| テスト | xUnit | テストフレームワーク |
| モック | Moq | モックライブラリ |
| カバレッジ | coverlet | カバレッジ計測 |
| パッケージ管理 | NuGet | 依存関係管理 |

## プロジェクト構成（推奨）

### コンソールアプリ / クラスライブラリ

```
MySolution/
├── src/
│   └── MyApp/
│       ├── MyApp.csproj
│       ├── Program.cs
│       └── Services/
│           └── MyService.cs
├── tests/
│   └── MyApp.Tests/
│       ├── MyApp.Tests.csproj
│       └── Services/
│           └── MyServiceTests.cs
├── MySolution.sln
└── README.md
```

### WebAPI

```
MyApi/
├── src/
│   └── MyApi/
│       ├── MyApi.csproj
│       ├── Program.cs
│       ├── Controllers/
│       │   └── UsersController.cs
│       ├── Models/
│       │   └── User.cs
│       ├── Services/
│       │   └── UserService.cs
│       └── appsettings.json
├── tests/
│   └── MyApi.Tests/
│       ├── MyApi.Tests.csproj
│       └── Controllers/
│           └── UsersControllerTests.cs
└── MyApi.sln
```

## ワークフロー

### 新規プロジェクト開始

1. `csharp-environment`でプロジェクト初期化
2. `csharp-coding`でコード作成
3. `csharp-testing`でテスト作成・実行
4. `csharp-coding`で品質チェック

### 既存プロジェクト作業

1. 必要に応じて`csharp-environment`で依存関係更新
2. `csharp-coding`でコード編集
3. `csharp-testing`でテスト実行
4. `csharp-coding`で品質チェック

### WebAPI開発

1. `csharp-environment`でWebAPIプロジェクト作成
2. `csharp-aspnet-webapi`でAPI設計・実装
3. `csharp-testing`で統合テスト作成
4. `csharp-coding`で品質チェック
