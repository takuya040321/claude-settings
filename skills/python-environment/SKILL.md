---
name: python-environment
description: Python環境構築・依存管理に特化したスキル。pyproject.tomlの作成・編集、仮想環境管理（venv/uv/poetry）、依存関係の追加・更新・削除、pyenvによるPythonバージョン管理、ツール設定（black/ruff/mypy/pytest）をサポート。ユーザーが「環境を構築して」「pyproject.tomlを作成して」「依存関係を追加して」「venvを作成して」などと依頼した場合にトリガー。
---

# Python Environment

Python開発環境の構築と依存関係管理のガイド。

## プロジェクト初期化

### uv（推奨）

```bash
# 新規プロジェクト作成
~/.claude/skills/python-environment/scripts/init_project.sh uv myproject

# 既存ディレクトリで初期化
~/.claude/skills/python-environment/scripts/init_project.sh uv .
```

### poetry

```bash
~/.claude/skills/python-environment/scripts/init_project.sh poetry myproject
```

### venv（標準ライブラリ）

```bash
~/.claude/skills/python-environment/scripts/init_project.sh venv myproject
```

## 依存関係管理

### 依存関係の追加

```bash
# uv
~/.claude/skills/python-environment/scripts/manage_deps.sh uv add requests pandas

# poetry
~/.claude/skills/python-environment/scripts/manage_deps.sh poetry add requests pandas

# venv/pip
~/.claude/skills/python-environment/scripts/manage_deps.sh pip add requests pandas
```

### 開発用依存関係の追加

```bash
# uv
~/.claude/skills/python-environment/scripts/manage_deps.sh uv add-dev pytest black ruff mypy

# poetry
~/.claude/skills/python-environment/scripts/manage_deps.sh poetry add-dev pytest black ruff mypy
```

### 依存関係の削除

```bash
~/.claude/skills/python-environment/scripts/manage_deps.sh uv remove requests
```

### 依存関係の更新

```bash
~/.claude/skills/python-environment/scripts/manage_deps.sh uv update
```

## pyproject.toml

### 基本構造

```toml
[project]
name = "myproject"
version = "0.1.0"
description = "プロジェクトの説明"
readme = "README.md"
requires-python = ">=3.11"
dependencies = [
    "requests>=2.31.0",
    "pydantic>=2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-cov>=4.0.0",
    "black>=24.0.0",
    "ruff>=0.3.0",
    "mypy>=1.8.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

### ツール設定

```toml
[tool.black]
line-length = 88
target-version = ["py311"]

[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP"]
ignore = ["E501"]

[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_ignores = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
addopts = "-v --tb=short"
```

## 仮想環境

### uv

```bash
# 仮想環境作成（自動）
uv sync

# 仮想環境でコマンド実行
uv run python script.py
uv run pytest
```

### venv

```bash
# 作成
python -m venv .venv

# 有効化
source .venv/bin/activate  # macOS/Linux
.venv\Scripts\activate     # Windows

# 無効化
deactivate
```

### poetry

```bash
# 仮想環境作成
poetry install

# 仮想環境で実行
poetry run python script.py
poetry shell  # シェルを起動
```

## Pythonバージョン管理（pyenv）

```bash
# インストール可能なバージョン一覧
pyenv install --list | grep "^\s*3\."

# インストール
pyenv install 3.12.0

# ローカル設定（プロジェクト単位）
pyenv local 3.12.0

# グローバル設定
pyenv global 3.12.0

# 現在のバージョン確認
pyenv version
```

## プロジェクト構成

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
├── README.md
└── .python-version    # pyenv用
```

## パッケージマネージャ比較

| 機能 | uv | poetry | pip/venv |
|------|-----|--------|----------|
| 速度 | 非常に速い | 普通 | 普通 |
| ロックファイル | uv.lock | poetry.lock | 手動 |
| 仮想環境管理 | 統合 | 統合 | 別途venv |
| pyproject.toml | 対応 | 対応 | 部分対応 |
| 推奨度 | 新規プロジェクト | 既存プロジェクト | レガシー |

## トラブルシューティング

### 依存関係の競合

```bash
# uv: 競合を確認
uv pip check

# 強制再インストール
uv sync --refresh
```

### キャッシュクリア

```bash
# uv
uv cache clean

# poetry
poetry cache clear pypi --all

# pip
pip cache purge
```
