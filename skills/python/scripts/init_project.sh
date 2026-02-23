#!/bin/bash
# Python プロジェクト初期化スクリプト
# Usage: init_project.sh <manager> <project_name>
# manager: uv, poetry, venv

set -e

MANAGER="${1:-uv}"
PROJECT_NAME="${2:-.}"

# 色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# プロジェクトディレクトリ作成
create_project_dir() {
    if [ "$PROJECT_NAME" != "." ]; then
        mkdir -p "$PROJECT_NAME"
        cd "$PROJECT_NAME"
        info "Created directory: $PROJECT_NAME"
    fi
}

# 基本ディレクトリ構造作成
create_structure() {
    local pkg_name="${PROJECT_NAME//-/_}"
    [ "$pkg_name" = "." ] && pkg_name="mypackage"

    mkdir -p "src/$pkg_name" tests

    # __init__.py
    cat > "src/$pkg_name/__init__.py" << 'EOF'
"""Package initialization."""

__version__ = "0.1.0"
EOF

    # tests/__init__.py
    touch tests/__init__.py

    # tests/conftest.py
    cat > tests/conftest.py << 'EOF'
"""Pytest configuration and shared fixtures."""

import pytest
EOF

    # README.md
    if [ ! -f README.md ]; then
        cat > README.md << EOF
# $pkg_name

## Installation

\`\`\`bash
# Using uv
uv sync

# Using pip
pip install -e .
\`\`\`

## Development

\`\`\`bash
# Run tests
pytest

# Format code
black src tests
ruff check src tests

# Type check
mypy src
\`\`\`
EOF
    fi

    info "Created project structure"
}

# pyproject.toml 作成
create_pyproject() {
    local pkg_name="${PROJECT_NAME//-/_}"
    [ "$pkg_name" = "." ] && pkg_name="mypackage"

    if [ -f pyproject.toml ]; then
        warn "pyproject.toml already exists, skipping"
        return
    fi

    cat > pyproject.toml << EOF
[project]
name = "$pkg_name"
version = "0.1.0"
description = ""
readme = "README.md"
requires-python = ">=3.11"
dependencies = []

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

[tool.hatch.build.targets.wheel]
packages = ["src/$pkg_name"]

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
EOF

    info "Created pyproject.toml"
}

# uv 初期化
init_uv() {
    if ! command -v uv &> /dev/null; then
        error "uv is not installed. Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
    fi

    create_project_dir
    create_structure
    create_pyproject

    # 仮想環境作成と依存関係インストール
    uv sync
    uv pip install -e ".[dev]"

    info "Project initialized with uv"
    info "Run 'uv run python' to use the virtual environment"
}

# poetry 初期化
init_poetry() {
    if ! command -v poetry &> /dev/null; then
        error "poetry is not installed. Install with: curl -sSL https://install.python-poetry.org | python3 -"
    fi

    create_project_dir

    if [ ! -f pyproject.toml ]; then
        poetry init --no-interaction --name "${PROJECT_NAME//-/_}"
    fi

    create_structure

    # 開発依存関係追加
    poetry add --group dev pytest pytest-cov black ruff mypy

    info "Project initialized with poetry"
    info "Run 'poetry shell' to activate the virtual environment"
}

# venv 初期化
init_venv() {
    create_project_dir
    create_structure
    create_pyproject

    # 仮想環境作成
    python -m venv .venv

    # 有効化と依存関係インストール
    source .venv/bin/activate
    pip install --upgrade pip
    pip install -e ".[dev]"

    info "Project initialized with venv"
    info "Run 'source .venv/bin/activate' to activate"
}

# メイン処理
case "$MANAGER" in
    uv)
        init_uv
        ;;
    poetry)
        init_poetry
        ;;
    venv)
        init_venv
        ;;
    *)
        error "Unknown manager: $MANAGER. Use: uv, poetry, or venv"
        ;;
esac

echo ""
info "Done! Project structure:"
if command -v tree &> /dev/null; then
    tree -L 3 -I '__pycache__|*.egg-info|.venv|.git'
else
    ls -la
fi
