---
name: python
description: Python開発の3つの領域（コーディング、テスト、環境設定）を統括する包括スキル。タスクに応じて適切な特化リファレンスを参照する。ユーザーが「Pythonで」「Pythonプロジェクト」「パイソン」などPython開発全般に関わるタスクを依頼した場合にトリガー。
---

# Python 開発ガイド

Python開発の包括的なガイド。タスクに応じて適切なリファレンスを参照する。

## タスク別リファレンス

| タスク | リファレンス |
|--------|-------------|
| コード作成・品質チェック | [references/coding.md](references/coding.md) |
| テスト作成・実行（pytest） | [references/testing.md](references/testing.md) |
| 環境構築・依存管理（uv） | [references/environment.md](references/environment.md) |

### 各領域の概要

- **コーディング** - 型ヒント、Docstring、命名規則、エラーハンドリング、black/ruff/mypy
- **テスト** - pytest、Fixture、パラメータ化、モック、カバレッジ
- **環境** - uv（デフォルト）、pyproject.toml、仮想環境、pyenv、ツール設定

## スクリプト

```bash
# コード品質チェック（black → ruff → mypy）
~/.claude/skills/python/scripts/check.sh <対象ファイルまたはディレクトリ>

# テスト実行
~/.claude/skills/python/scripts/run_tests.sh [テストパス] [--cov]

# プロジェクト初期化
~/.claude/skills/python/scripts/init_project.sh uv <プロジェクト名>

# 依存関係管理
~/.claude/skills/python/scripts/manage_deps.sh <add|remove|list> [パッケージ名]
```

## 推奨ツールスタック

| カテゴリ | ツール | 用途 |
|---------|--------|------|
| パッケージ管理 | uv | 依存関係管理・仮想環境 |
| フォーマット | black | コード整形 |
| リンティング | ruff | 品質チェック |
| 型チェック | mypy | 静的型検査 |
| テスト | pytest | テストフレームワーク |
| バージョン管理 | pyenv | Pythonバージョン切替 |

## ワークフロー

### 新規プロジェクト開始

1. `references/environment.md`でプロジェクト初期化
2. `references/coding.md`でコード作成
3. `references/testing.md`でテスト作成・実行
4. `references/coding.md`で品質チェック
