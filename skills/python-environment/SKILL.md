---
name: python-environment
description: Python環境構築・依存管理に特化したスキル。uvをデフォルトで使用。pyproject.tomlの作成・編集、仮想環境管理、依存関係の追加・更新・削除、pyenvによるPythonバージョン管理、ツール設定（black/ruff/mypy/pytest）をサポート。ユーザーが「環境を構築して」「pyproject.tomlを作成して」「依存関係を追加して」「仮想環境を作成して」などと依頼した場合にトリガー。
---

# Python Environment

Python開発環境の構築と依存関係管理のガイド。**uvをデフォルトで使用する。**

## プロジェクト初期化

**uvを使用する（デフォルト）:**

```bash
# 新規プロジェクト作成
~/.claude/skills/python-environment/scripts/init_project.sh uv myproject

# 既存ディレクトリで初期化
~/.claude/skills/python-environment/scripts/init_project.sh uv .
```

> 既存プロジェクトでpoetry/venvが使われている場合のみ、それらを継続使用。

## 依存関係管理

**uvを使用する（デフォルト）:**

```bash
# パッケージ追加
uv add requests pandas

# 開発用パッケージ追加
uv add --dev pytest black ruff mypy

# パッケージ削除
uv remove requests

# 依存関係更新
uv lock --upgrade && uv sync
```

## 仮想環境

**uvを使用する（デフォルト）:**

```bash
# 仮想環境作成と依存関係インストール（自動）
uv sync

# 仮想環境でコマンド実行
uv run python script.py
uv run pytest
uv run black src/
```

> `uv run`で実行すれば仮想環境の有効化は不要。

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

## Pythonバージョン管理（pyenv）

```bash
# インストール可能なバージョン一覧
pyenv install --list | grep "^\s*3\."

# インストール
pyenv install 3.12.0

# ローカル設定（プロジェクト単位）
pyenv local 3.12.0

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
├── uv.lock
├── README.md
└── .python-version
```

## トラブルシューティング

```bash
# 依存関係の競合確認
uv pip check

# 強制再インストール
uv sync --refresh

# キャッシュクリア
uv cache clean
```

## 既存プロジェクト（poetry/venv）

既存プロジェクトでpoetryやvenvが使われている場合のみ以下を使用。

### poetry

```bash
poetry install          # 依存関係インストール
poetry add requests     # パッケージ追加
poetry run python x.py  # 実行
```

### venv/pip

```bash
python -m venv .venv              # 仮想環境作成
source .venv/bin/activate         # 有効化
pip install -r requirements.txt   # インストール
```
