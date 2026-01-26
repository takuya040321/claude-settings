---
name: python
description: Python開発の3つの領域（コーディング、テスト、環境設定）を統括する包括スキル。タスクに応じて適切な特化スキルを呼び出す。ユーザーが「Pythonで」「Pythonプロジェクト」「パイソン」などPython開発全般に関わるタスクを依頼した場合にトリガー。
---

# Python 開発ガイド

Python開発の包括的なガイド。タスクに応じて適切な特化スキルを選択する。

## タスク振り分け

### 1. コード作成・品質チェック（python-coding）

以下の場合に`python-coding`スキルを使用：

- Pythonコードの作成・編集
- コードのフォーマット（black）
- リンティング・品質チェック（ruff）
- 型チェック（mypy）
- コーディング規約・ベストプラクティス

**トリガー例**:
- 「Pythonで関数を作成して」
- 「このコードをリファクタリングして」
- 「型ヒントを追加して」

### 2. テスト作成・実行（python-testing）

以下の場合に`python-testing`スキルを使用：

- pytestを使ったテストの作成
- テストの実行・デバッグ
- モック・フィクスチャの設定
- テストカバレッジの計測

**トリガー例**:
- 「テストを書いて」
- 「pytestを実行して」
- 「このクラスのユニットテストを作成して」

### 3. 環境構築・依存管理（python-environment）

以下の場合に`python-environment`スキルを使用（**uvをデフォルトで使用**）：

- pyproject.tomlの作成・編集
- 仮想環境の作成・管理（uv）
- 依存関係の追加・更新・削除
- Pythonバージョン管理（pyenv）
- 開発ツールの設定

**トリガー例**:
- 「新しいPythonプロジェクトを作成して」
- 「pyproject.tomlを作成して」
- 「requestsパッケージを追加して」
- 「仮想環境を作成して」

## クイックリファレンス

### プロジェクト初期化（推奨）

```bash
# uvで新規プロジェクト作成
~/.claude/skills/python-environment/scripts/init_project.sh uv myproject

# 既存ディレクトリで初期化
~/.claude/skills/python-environment/scripts/init_project.sh uv .
```

### コード品質チェック

```bash
# フォーマット・リント・型チェック
~/.claude/skills/python-coding/scripts/check.sh src/
```

### テスト実行

```bash
# テスト実行
~/.claude/skills/python-testing/scripts/run_tests.sh tests/

# カバレッジ付き
~/.claude/skills/python-testing/scripts/run_tests.sh tests/ --cov
```

### 依存関係管理

```bash
# パッケージ追加
uv add requests

# 開発用パッケージ追加
uv add --dev pytest
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

## プロジェクト構成（推奨）

```
project/
├── src/
│   └── mypackage/
│       ├── __init__.py
│       ├── main.py
│       └── utils.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   └── test_main.py
├── pyproject.toml
├── uv.lock
├── README.md
└── .python-version
```

## ワークフロー

### 新規プロジェクト開始

1. `python-environment`でプロジェクト初期化
2. `python-coding`でコード作成
3. `python-testing`でテスト作成・実行
4. `python-coding`で品質チェック

### 既存プロジェクト作業

1. 必要に応じて`python-environment`で依存関係更新
2. `python-coding`でコード編集
3. `python-testing`でテスト実行
4. `python-coding`で品質チェック
