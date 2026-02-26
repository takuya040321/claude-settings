---
name: csharp-environment
description: C#環境構築・依存管理に特化したスキル。dotnet CLIを使用。プロジェクトの作成（dotnet new）、NuGetパッケージの追加・更新・削除、ソリューション管理をサポート。ユーザーが「プロジェクトを作成して」「パッケージを追加して」「ソリューションを作成して」などと依頼した場合にトリガー。
---

# C# Environment

C#開発環境の構築と依存関係管理のガイド。**dotnet CLIを使用する。**

## プロジェクト初期化

```bash
# コンソールアプリ作成
~/.claude/skills/csharp/scripts/init_project.sh console myapp

# クラスライブラリ作成
~/.claude/skills/csharp/scripts/init_project.sh classlib mylibrary

# WebAPI作成
~/.claude/skills/csharp/scripts/init_project.sh webapi myapi

# 既存ディレクトリで初期化
~/.claude/skills/csharp/scripts/init_project.sh console .
```

### 手動でのプロジェクト作成

```bash
# コンソールアプリ
dotnet new console -n MyApp -o src/MyApp

# クラスライブラリ
dotnet new classlib -n MyLibrary -o src/MyLibrary

# WebAPI
dotnet new webapi -n MyApi -o src/MyApi

# テストプロジェクト
dotnet new xunit -n MyApp.Tests -o src/MyApp.Tests
```

## ソリューション管理

```bash
# ソリューション作成
dotnet new sln -n MySolution

# プロジェクトをソリューションに追加
dotnet sln add src/MyApp/MyApp.csproj
dotnet sln add src/MyApp.Tests/MyApp.Tests.csproj

# ソリューションからプロジェクトを削除
dotnet sln remove src/MyApp/MyApp.csproj

# プロジェクト一覧
dotnet sln list
```

## 依存関係管理

```bash
# パッケージ追加
~/.claude/skills/csharp/scripts/manage_deps.sh add Newtonsoft.Json

# バージョン指定で追加
~/.claude/skills/csharp/scripts/manage_deps.sh add Newtonsoft.Json 13.0.3

# パッケージ削除
~/.claude/skills/csharp/scripts/manage_deps.sh remove Newtonsoft.Json

# パッケージ一覧
~/.claude/skills/csharp/scripts/manage_deps.sh list
```

### dotnet コマンド直接実行

```bash
# パッケージ追加
dotnet add package Newtonsoft.Json
dotnet add package Newtonsoft.Json --version 13.0.3

# パッケージ削除
dotnet remove package Newtonsoft.Json

# パッケージ一覧
dotnet list package

# 更新可能なパッケージ確認
dotnet list package --outdated

# すべてのパッケージを最新に更新
dotnet list package --outdated --format json | jq -r '.projects[].frameworks[].topLevelPackages[].id' | xargs -I {} dotnet add package {}
```

## プロジェクト参照

```bash
# プロジェクト参照を追加
dotnet add src/MyApp/MyApp.csproj reference src/MyLibrary/MyLibrary.csproj

# テストプロジェクトからメインプロジェクトを参照
dotnet add src/MyApp.Tests/MyApp.Tests.csproj reference src/MyApp/MyApp.csproj

# 参照一覧
dotnet list reference
```

## .csproj 構成

> **注意**: `TargetFramework` には .NET の最新安定版を使用する。
> 最新安定版は releases-index.json から取得し、例えば `9.0` なら `net9.0` を指定する。

### 基本構造

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <!-- 最新安定版の .NET バージョンを設定 -->
    <TargetFramework>net{MAJOR}.{MINOR}</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
```

### コンソールアプリ

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net{MAJOR}.{MINOR}</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
```

### WebAPI

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net{MAJOR}.{MINOR}</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
```

### テストプロジェクト

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net{MAJOR}.{MINOR}</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <IsPackable>false</IsPackable>
    <IsTestProject>true</IsTestProject>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.*" />
    <PackageReference Include="xunit" Version="2.*" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.*">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
    <PackageReference Include="coverlet.collector" Version="6.*">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\MyApp\MyApp.csproj" />
  </ItemGroup>
</Project>
```

## プロジェクト構成

### 標準構成

```
MySolution/
├── src/
│   ├── MyApp/
│   │   ├── MyApp.csproj
│   │   └── Program.cs
│   ├── MyApp.Core/
│   │   ├── MyApp.Core.csproj
│   │   └── Services/
│   └── MyApp.Tests/
│       ├── MyApp.Tests.csproj
│       └── UnitTests/
├── docs/                  # 設計書・仕様書等のドキュメント
├── MySolution.sln
├── global.json            # .NETバージョン管理
├── Directory.Build.props  # 共通ビルド設定
├── .gitignore
├── .gitattributes
└── README.md
```

### global.json（SDKバージョン管理）

```bash
# .NETの最新安定版で生成する
DOTNET_STABLE=$(curl -s https://dotnetcli.azureedge.net/dotnet/release-metadata/releases-index.json | jq -r '[."releases-index"[] | select(."support-phase" == "active" or ."support-phase" == "lts")] | sort_by(."channel-version") | last | ."latest-sdk"')
# 取得できない場合はフォールバック
if [ -z "$DOTNET_STABLE" ] || [ "$DOTNET_STABLE" = "null" ]; then
    DOTNET_STABLE="9.0.100"
fi
cat > global.json << EOF
{
  "sdk": {
    "version": "$DOTNET_STABLE",
    "rollForward": "latestFeature"
  }
}
EOF
```

### Directory.Build.props（共通設定）

```xml
<Project>
  <PropertyGroup>
    <!-- 最新安定版の .NET バージョンを設定 -->
    <TargetFramework>net{MAJOR}.{MINOR}</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
  </PropertyGroup>
</Project>
```

## .NETバージョン管理

> **重要**: 常に .NET の最新安定版を使用する。インストール済みバージョンに依存しない。

```bash
# 最新安定版の確認方法
curl -s https://dotnetcli.azureedge.net/dotnet/release-metadata/releases-index.json | jq -r \
  '[."releases-index"[] | select(."support-phase" == "active" or ."support-phase" == "lts")] | sort_by(."channel-version") | last | ."channel-version"'

# 取得できない場合のフォールバック: 最新LTS版（net9.0）を使用

# TargetFramework の決定方法
# 最新安定版が "9.0" なら → net9.0
# 最新安定版が "10.0" なら → net10.0

# 新しいプロジェクト作成時（フレームワーク指定は不要、デフォルトで最新が使われる）
dotnet new console
```

## よく使うパッケージ

| カテゴリ | パッケージ | 用途 |
|---------|-----------|------|
| JSON | `System.Text.Json` | 標準JSON（推奨） |
| JSON | `Newtonsoft.Json` | 高機能JSON |
| HTTP | `Microsoft.Extensions.Http` | HttpClient管理 |
| DI | `Microsoft.Extensions.DependencyInjection` | 依存性注入 |
| ログ | `Microsoft.Extensions.Logging` | ログ基盤 |
| ログ | `Serilog` | 構造化ログ |
| ORM | `Microsoft.EntityFrameworkCore` | Entity Framework |
| DB | `Npgsql.EntityFrameworkCore.PostgreSQL` | PostgreSQL |
| DB | `Microsoft.EntityFrameworkCore.SqlServer` | SQL Server |
| 検証 | `FluentValidation` | バリデーション |
| マッピング | `AutoMapper` | オブジェクトマッピング |
| テスト | `Moq` | モックライブラリ |

## トラブルシューティング

```bash
# NuGetキャッシュクリア
dotnet nuget locals all --clear

# パッケージの復元
dotnet restore

# ビルドキャッシュクリア
dotnet clean

# 強制的に再ビルド
dotnet build --no-incremental

# 依存関係の競合確認
dotnet list package --include-transitive
```
