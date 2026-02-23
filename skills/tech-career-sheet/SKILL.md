---
name: tech-career-sheet
description: プロジェクトのコードベースを解析し、技術経歴書（スキルシート）に記載するための情報をMarkdownで出力するスキル。システム名、業種、役割、人数、サーバOS、DB、言語・FW・ツール、担当工程を構造化して抽出・整理。ユーザーが「技術経歴書を作成して」「スキルシートにまとめて」「経歴書用にプロジェクト情報を出力して」「このプロジェクトの技術スタックをまとめて」「職務経歴書の材料を作って」などと依頼した場合にトリガー。
---

# 技術経歴書プロジェクト情報抽出

プロジェクトのコードベースを解析し、技術経歴書に記載する情報をMarkdownで出力する。

## ワークフロー

1. **プロジェクト自動解析** - コードベースから技術情報を検出
2. **ユーザーヒアリング** - 自動検出できない情報を対話で取得
3. **担当工程の推測と確認** - ファイル構成から推測し、ユーザーに確認
4. **Markdown出力** - テンプレートに沿って整形・出力

## Step 1: プロジェクト自動解析

以下のファイルを探索し、技術情報を検出する。

### システム名の検出

優先順位で確認：
- `CLAUDE.md` のプロジェクト名・概要セクション
- `package.json` の `name` / `description`
- `pyproject.toml` の `[project]` セクション
- `README.md` のタイトル
- `.sln` ファイル名
- ディレクトリ名（最終手段）

### 言語の検出

ファイル拡張子の分布を確認：
- `.ts`, `.tsx`, `.js`, `.jsx` → TypeScript / JavaScript
- `.py` → Python
- `.cs` → C#
- `.java` → Java
- `.go` → Go
- `.rb` → Ruby
- `.php` → PHP
- `.dart` → Dart
- `.swift` → Swift
- `.kt` → Kotlin
- その他の拡張子も同様に判定

### フレームワーク・ライブラリの検出

依存管理ファイルから抽出：
- `package.json` → dependencies / devDependencies（React, Next.js, Vue, Express, NestJS等）
- `pyproject.toml` / `requirements.txt` → Django, Flask, FastAPI等
- `Gemfile` → Rails等
- `build.gradle` / `pom.xml` → Spring等
- `*.csproj` → ASP.NET等
- `pubspec.yaml` → Flutter等
- `go.mod` → Goモジュール

### ツールの検出

設定ファイルから抽出：
- `Dockerfile`, `docker-compose.yml` → Docker
- `.github/workflows/` → GitHub Actions
- `Jenkinsfile` → Jenkins
- `.gitlab-ci.yml` → GitLab CI
- `terraform/`, `*.tf` → Terraform
- `ansible/` → Ansible
- `.eslintrc*`, `prettier*` → Linter/Formatter
- `jest.config*`, `vitest.config*`, `pytest.ini` → テストツール

### サーバOSの検出

- `Dockerfile` の `FROM` イメージ（alpine, ubuntu, debian等）
- デプロイ設定ファイル（AWS, GCP, Azure関連）
- `Vagrantfile`

### DBの検出

- ORM設定（Prisma schema, SQLAlchemy models, Entity Framework等）
- マイグレーションファイル
- `docker-compose.yml` のDBサービス定義
- 接続文字列の設定ファイル（値自体は読まない）

## Step 2: ユーザーヒアリング

自動検出できない以下の項目をユーザーに質問する。AskUserQuestionツールを使い、一度に3〜4項目ずつ聞く。

### 必須ヒアリング項目

- **業種**: 金融、製造、小売・EC、医療、物流、教育、不動産、通信、公共、エンタメ、SaaS、その他
- **役割**: PM, PL, SE, PG, インフラエンジニア, テスター, その他
- **チーム人数**: 数値で回答
- **作業期間**: 開始〜終了（例: 2024年4月〜2025年3月）

### 任意ヒアリング項目（自動検出で不足がある場合）

- **作業概要**: プロジェクトの目的・背景を1〜2文で
- **作業内容**: 自身が担当した作業を箇条書きで
- **システム名**: 自動検出結果が不正確な場合
- **サーバOS**: 自動検出できなかった場合
- **DB**: 自動検出できなかった場合

## Step 3: 担当工程の推測と確認

### 推測ロジック

以下のファイル・ディレクトリの存在から担当工程を推測：

| 工程 | 判定根拠 |
|------|---------|
| 要件定義 | `docs/requirements*`, 要件定義書系ファイル |
| 基本設計 | `docs/design*`, 基本設計書系ファイル, ER図 |
| 詳細設計 | `docs/detailed*`, 詳細設計書系ファイル |
| 製造（実装） | ソースコードが存在（ほぼ常にあり） |
| 試験（テスト） | `tests/`, `__tests__/`, `*.test.*`, `*.spec.*`, E2Eテスト |
| 運用・保守 | `docs/operation*`, 運用手順書, 監視設定 |
| 構築・設定 | `Dockerfile`, IaC系ファイル, CI/CD設定 |
| 監視 | 監視ツール設定（Datadog, Prometheus等） |
| 障害対応 | インシデント対応ドキュメント |

### 確認フロー

推測結果をユーザーに提示し、以下を確認：
- 推測が正しいか
- 追加・削除すべき工程がないか
- 各工程で「○」とするか確認

## Step 4: Markdown出力

`assets/template.md` のテンプレートを基に、収集した情報を埋めてMarkdownファイルを出力する。

### 出力ルール

- 担当工程は「○」（担当あり）または「-」（担当なし）で表記
- 言語・FW・ツールはカンマ区切りで列挙
- 該当なしの項目は「-」と記載
- 出力ファイル名: `{プロジェクトディレクトリ名}_career_sheet.md`（プロジェクトルートに出力）

### 出力例

```markdown
# 技術経歴書 - プロジェクト情報

## 基本情報

| 項目 | 内容 |
|------|------|
| システム名 | EC注文管理システム |
| 作業期間 | 2024年4月〜2025年3月 |
| 業種 | 小売・EC |
| 役割 | SE |
| チーム人数 | 5名 |

## 作業概要

ECサイトの注文管理機能のリニューアル開発

## 作業内容

- バックエンドAPIの設計・実装
- DBスキーマ設計
- 単体テスト・結合テストの作成
- CI/CDパイプラインの構築

## 技術スタック

### サーバOS

Amazon Linux 2

### DB

PostgreSQL 15

### 言語

TypeScript, Python

### フレームワーク

Next.js 14, FastAPI

### ツール

Docker, GitHub Actions, Terraform

### その他

AWS (ECS, RDS, S3)

## 担当工程

| 工程 | 担当 |
|------|------|
| 要件定義 | - |
| 基本設計 | ○ |
| 詳細設計 | ○ |
| 製造（実装） | ○ |
| 試験（テスト） | ○ |
| 運用・保守 | - |
| 構築・設定 | ○ |
| 監視 | - |
| 障害対応 | - |
| 補助 | - |
| その他 | - |
```
