#!/bin/bash
# C# 依存関係管理スクリプト
# Usage: manage_deps.sh <action> [package] [version] [--project <path>]
# action: add, remove, list, outdated

set -e

ACTION="${1:-list}"
PACKAGE="$2"
VERSION="$3"
PROJECT=""

# 色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# オプション解析
shift 2 2>/dev/null || true
while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            PROJECT="$2"
            shift 2
            ;;
        *)
            # バージョンかもしれない
            if [ -z "$VERSION" ] && [[ $1 =~ ^[0-9] ]]; then
                VERSION="$1"
            fi
            shift
            ;;
    esac
done

# dotnet CLI チェック
if ! command -v dotnet &> /dev/null; then
    error "dotnet CLI is not installed. Install from: https://dotnet.microsoft.com/download"
fi

# プロジェクトファイルを見つける
find_project() {
    if [ -n "$PROJECT" ]; then
        echo "$PROJECT"
        return
    fi

    # .csproj ファイルを探す
    local csproj=$(find . -maxdepth 2 -name "*.csproj" -type f 2>/dev/null | head -1)
    if [ -n "$csproj" ]; then
        echo "$csproj"
        return
    fi

    echo ""
}

case "$ACTION" in
    add)
        if [ -z "$PACKAGE" ]; then
            error "Package name is required. Usage: manage_deps.sh add <package> [version]"
        fi

        PROJECT_FILE=$(find_project)
        if [ -z "$PROJECT_FILE" ]; then
            error "No .csproj file found. Specify with --project"
        fi

        info "Adding package: $PACKAGE"
        if [ -n "$VERSION" ]; then
            dotnet add "$PROJECT_FILE" package "$PACKAGE" --version "$VERSION"
            info "Added $PACKAGE@$VERSION to $PROJECT_FILE"
        else
            dotnet add "$PROJECT_FILE" package "$PACKAGE"
            info "Added $PACKAGE (latest) to $PROJECT_FILE"
        fi
        ;;

    remove)
        if [ -z "$PACKAGE" ]; then
            error "Package name is required. Usage: manage_deps.sh remove <package>"
        fi

        PROJECT_FILE=$(find_project)
        if [ -z "$PROJECT_FILE" ]; then
            error "No .csproj file found. Specify with --project"
        fi

        info "Removing package: $PACKAGE"
        dotnet remove "$PROJECT_FILE" package "$PACKAGE"
        info "Removed $PACKAGE from $PROJECT_FILE"
        ;;

    list)
        info "Listing packages..."
        echo ""

        if [ -f "*.sln" ] 2>/dev/null || ls *.sln 1>/dev/null 2>&1; then
            # ソリューションがある場合
            dotnet list package
        else
            # 個別プロジェクト
            PROJECT_FILE=$(find_project)
            if [ -n "$PROJECT_FILE" ]; then
                dotnet list "$PROJECT_FILE" package
            else
                warn "No .csproj or .sln file found"
            fi
        fi
        ;;

    outdated)
        info "Checking for outdated packages..."
        echo ""

        if [ -f "*.sln" ] 2>/dev/null || ls *.sln 1>/dev/null 2>&1; then
            dotnet list package --outdated
        else
            PROJECT_FILE=$(find_project)
            if [ -n "$PROJECT_FILE" ]; then
                dotnet list "$PROJECT_FILE" package --outdated
            else
                warn "No .csproj or .sln file found"
            fi
        fi
        ;;

    update)
        if [ -z "$PACKAGE" ]; then
            # すべてのパッケージを更新
            info "Updating all outdated packages..."

            # 各プロジェクトの古いパッケージを更新
            for csproj in $(find . -name "*.csproj" -type f 2>/dev/null); do
                info "Checking $csproj..."
                outdated=$(dotnet list "$csproj" package --outdated --format json 2>/dev/null | jq -r '.projects[].frameworks[].topLevelPackages[]?.id' 2>/dev/null || true)

                if [ -n "$outdated" ]; then
                    for pkg in $outdated; do
                        info "Updating $pkg in $csproj"
                        dotnet add "$csproj" package "$pkg" || warn "Failed to update $pkg"
                    done
                fi
            done

            info "Update complete"
        else
            # 特定のパッケージを更新
            PROJECT_FILE=$(find_project)
            if [ -z "$PROJECT_FILE" ]; then
                error "No .csproj file found. Specify with --project"
            fi

            info "Updating package: $PACKAGE"
            if [ -n "$VERSION" ]; then
                dotnet add "$PROJECT_FILE" package "$PACKAGE" --version "$VERSION"
            else
                dotnet add "$PROJECT_FILE" package "$PACKAGE"
            fi
            info "Updated $PACKAGE"
        fi
        ;;

    restore)
        info "Restoring packages..."
        dotnet restore
        info "Restore complete"
        ;;

    *)
        echo "Usage: manage_deps.sh <action> [package] [version] [--project <path>]"
        echo ""
        echo "Actions:"
        echo "  add <package> [version]  - Add a NuGet package"
        echo "  remove <package>         - Remove a NuGet package"
        echo "  list                     - List installed packages"
        echo "  outdated                 - Show outdated packages"
        echo "  update [package]         - Update packages (all or specific)"
        echo "  restore                  - Restore all packages"
        echo ""
        echo "Options:"
        echo "  --project <path>         - Specify the project file"
        exit 1
        ;;
esac
