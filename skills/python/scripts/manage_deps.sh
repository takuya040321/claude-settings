#!/bin/bash
# Python 依存関係管理スクリプト
# Usage: manage_deps.sh <manager> <action> [packages...]
# manager: uv, poetry, pip
# action: add, add-dev, remove, update, list

set -e

MANAGER="${1:-uv}"
ACTION="${2:-list}"
shift 2 2>/dev/null || true
PACKAGES="$@"

# 色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# uv 操作
manage_uv() {
    if ! command -v uv &> /dev/null; then
        error "uv is not installed"
    fi

    case "$ACTION" in
        add)
            [ -z "$PACKAGES" ] && error "No packages specified"
            info "Adding packages: $PACKAGES"
            uv add $PACKAGES
            ;;
        add-dev)
            [ -z "$PACKAGES" ] && error "No packages specified"
            info "Adding dev packages: $PACKAGES"
            uv add --dev $PACKAGES
            ;;
        remove)
            [ -z "$PACKAGES" ] && error "No packages specified"
            info "Removing packages: $PACKAGES"
            uv remove $PACKAGES
            ;;
        update)
            info "Updating dependencies"
            if [ -n "$PACKAGES" ]; then
                uv lock --upgrade-package $PACKAGES
            else
                uv lock --upgrade
            fi
            uv sync
            ;;
        list)
            info "Installed packages:"
            uv pip list
            ;;
        sync)
            info "Syncing dependencies"
            uv sync
            ;;
        *)
            error "Unknown action: $ACTION. Use: add, add-dev, remove, update, list, sync"
            ;;
    esac
}

# poetry 操作
manage_poetry() {
    if ! command -v poetry &> /dev/null; then
        error "poetry is not installed"
    fi

    case "$ACTION" in
        add)
            [ -z "$PACKAGES" ] && error "No packages specified"
            info "Adding packages: $PACKAGES"
            poetry add $PACKAGES
            ;;
        add-dev)
            [ -z "$PACKAGES" ] && error "No packages specified"
            info "Adding dev packages: $PACKAGES"
            poetry add --group dev $PACKAGES
            ;;
        remove)
            [ -z "$PACKAGES" ] && error "No packages specified"
            info "Removing packages: $PACKAGES"
            poetry remove $PACKAGES
            ;;
        update)
            info "Updating dependencies"
            if [ -n "$PACKAGES" ]; then
                poetry update $PACKAGES
            else
                poetry update
            fi
            ;;
        list)
            info "Installed packages:"
            poetry show
            ;;
        sync)
            info "Installing dependencies"
            poetry install
            ;;
        *)
            error "Unknown action: $ACTION. Use: add, add-dev, remove, update, list, sync"
            ;;
    esac
}

# pip 操作
manage_pip() {
    # 仮想環境のpipを使用
    local PIP="pip"
    if [ -f ".venv/bin/pip" ]; then
        PIP=".venv/bin/pip"
    fi

    case "$ACTION" in
        add)
            [ -z "$PACKAGES" ] && error "No packages specified"
            info "Adding packages: $PACKAGES"
            $PIP install $PACKAGES

            # requirements.txtに追記
            for pkg in $PACKAGES; do
                if ! grep -q "^${pkg}" requirements.txt 2>/dev/null; then
                    echo "$pkg" >> requirements.txt
                fi
            done
            info "Updated requirements.txt"
            ;;
        add-dev)
            [ -z "$PACKAGES" ] && error "No packages specified"
            info "Adding dev packages: $PACKAGES"
            $PIP install $PACKAGES

            # requirements-dev.txtに追記
            for pkg in $PACKAGES; do
                if ! grep -q "^${pkg}" requirements-dev.txt 2>/dev/null; then
                    echo "$pkg" >> requirements-dev.txt
                fi
            done
            info "Updated requirements-dev.txt"
            ;;
        remove)
            [ -z "$PACKAGES" ] && error "No packages specified"
            info "Removing packages: $PACKAGES"
            $PIP uninstall -y $PACKAGES

            # requirements*.txtから削除
            for pkg in $PACKAGES; do
                if [ -f requirements.txt ]; then
                    sed -i.bak "/^${pkg}/d" requirements.txt && rm -f requirements.txt.bak
                fi
                if [ -f requirements-dev.txt ]; then
                    sed -i.bak "/^${pkg}/d" requirements-dev.txt && rm -f requirements-dev.txt.bak
                fi
            done
            ;;
        update)
            info "Updating dependencies"
            if [ -n "$PACKAGES" ]; then
                $PIP install --upgrade $PACKAGES
            elif [ -f requirements.txt ]; then
                $PIP install --upgrade -r requirements.txt
            else
                warn "No requirements.txt found"
            fi
            ;;
        list)
            info "Installed packages:"
            $PIP list
            ;;
        sync)
            info "Installing from requirements"
            [ -f requirements.txt ] && $PIP install -r requirements.txt
            [ -f requirements-dev.txt ] && $PIP install -r requirements-dev.txt
            ;;
        freeze)
            info "Freezing requirements"
            $PIP freeze > requirements-lock.txt
            info "Created requirements-lock.txt"
            ;;
        *)
            error "Unknown action: $ACTION. Use: add, add-dev, remove, update, list, sync, freeze"
            ;;
    esac
}

# メイン処理
case "$MANAGER" in
    uv)
        manage_uv
        ;;
    poetry)
        manage_poetry
        ;;
    pip|venv)
        manage_pip
        ;;
    *)
        error "Unknown manager: $MANAGER. Use: uv, poetry, or pip"
        ;;
esac

info "Done!"
