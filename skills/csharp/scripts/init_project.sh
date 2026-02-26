#!/bin/bash
# C# プロジェクト初期化スクリプト
# Usage: init_project.sh <template> <project_name>
# template: console, classlib, webapi, worker

set -e

TEMPLATE="${1:-console}"
PROJECT_NAME="${2:-.}"

# 色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# dotnet CLI チェック
if ! command -v dotnet &> /dev/null; then
    error "dotnet CLI is not installed. Install from: https://dotnet.microsoft.com/download"
fi

# .NETの最新安定版を取得
DOTNET_CHANNEL=$(curl -s https://dotnetcli.azureedge.net/dotnet/release-metadata/releases-index.json 2>/dev/null | jq -r '[."releases-index"[] | select(."support-phase" == "active" or ."support-phase" == "lts")] | sort_by(."channel-version") | last | ."channel-version"' 2>/dev/null)
DOTNET_LATEST_SDK=$(curl -s https://dotnetcli.azureedge.net/dotnet/release-metadata/releases-index.json 2>/dev/null | jq -r '[."releases-index"[] | select(."support-phase" == "active" or ."support-phase" == "lts")] | sort_by(."channel-version") | last | ."latest-sdk"' 2>/dev/null)
# 取得できない場合はフォールバック（最新LTS版）
if [ -z "$DOTNET_CHANNEL" ] || [ "$DOTNET_CHANNEL" = "null" ]; then
    DOTNET_CHANNEL="9.0"
    warn "Could not fetch latest stable version, falling back to $DOTNET_CHANNEL"
fi
if [ -z "$DOTNET_LATEST_SDK" ] || [ "$DOTNET_LATEST_SDK" = "null" ]; then
    DOTNET_LATEST_SDK="${DOTNET_CHANNEL}.100"
fi
DOTNET_MAJOR_MINOR="$DOTNET_CHANNEL"
TARGET_FRAMEWORK="net${DOTNET_MAJOR_MINOR}"
info "Latest stable .NET: $DOTNET_CHANNEL (SDK: $DOTNET_LATEST_SDK, target: $TARGET_FRAMEWORK)"

# テンプレート検証
case "$TEMPLATE" in
    console|classlib|webapi|worker|blazor|mvc|razorpage)
        ;;
    *)
        error "Unknown template: $TEMPLATE. Use: console, classlib, webapi, worker, blazor, mvc, razorpage"
        ;;
esac

# プロジェクト名の正規化
if [ "$PROJECT_NAME" = "." ]; then
    SOLUTION_NAME=$(basename "$(pwd)")
    PROJECT_DIR="."
    IN_PLACE=true
else
    SOLUTION_NAME="$PROJECT_NAME"
    PROJECT_DIR="$PROJECT_NAME"
    IN_PLACE=false
fi

# パッケージ名として使用するために正規化（ハイフンをアンダースコアに）
PACKAGE_NAME="${SOLUTION_NAME//-/_}"

info "Creating C# project: $SOLUTION_NAME (template: $TEMPLATE)"

# プロジェクトディレクトリ作成
if [ "$IN_PLACE" = false ]; then
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    info "Created directory: $PROJECT_DIR"
fi

# ソリューション作成
if [ ! -f "*.sln" ] 2>/dev/null; then
    dotnet new sln -n "$SOLUTION_NAME"
    info "Created solution: $SOLUTION_NAME.sln"
else
    warn "Solution already exists, skipping"
fi

# ディレクトリ構造作成
mkdir -p src docs

# メインプロジェクト作成
if [ ! -d "src/$SOLUTION_NAME" ]; then
    dotnet new "$TEMPLATE" -n "$SOLUTION_NAME" -o "src/$SOLUTION_NAME"
    dotnet sln add "src/$SOLUTION_NAME/$SOLUTION_NAME.csproj"
    info "Created main project: src/$SOLUTION_NAME"
else
    warn "Main project already exists, skipping"
fi

# テストプロジェクト作成
if [ ! -d "src/$SOLUTION_NAME.Tests" ]; then
    dotnet new xunit -n "$SOLUTION_NAME.Tests" -o "src/$SOLUTION_NAME.Tests"
    dotnet sln add "src/$SOLUTION_NAME.Tests/$SOLUTION_NAME.Tests.csproj"
    dotnet add "src/$SOLUTION_NAME.Tests/$SOLUTION_NAME.Tests.csproj" reference "src/$SOLUTION_NAME/$SOLUTION_NAME.csproj"

    # Moqパッケージを追加
    dotnet add "src/$SOLUTION_NAME.Tests/$SOLUTION_NAME.Tests.csproj" package Moq

    info "Created test project: src/$SOLUTION_NAME.Tests"
else
    warn "Test project already exists, skipping"
fi

# global.json 作成
if [ ! -f "global.json" ]; then
    cat > global.json << EOF
{
  "sdk": {
    "version": "$DOTNET_LATEST_SDK",
    "rollForward": "latestFeature"
  }
}
EOF
    info "Created global.json"
fi

# Directory.Build.props 作成
if [ ! -f "Directory.Build.props" ]; then
    cat > Directory.Build.props << EOF
<Project>
  <PropertyGroup>
    <TargetFramework>${TARGET_FRAMEWORK}</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
  </PropertyGroup>
</Project>
EOF
    info "Created Directory.Build.props (target: ${TARGET_FRAMEWORK})"
fi

# .gitignore 作成
if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
## .NET
bin/
obj/
*.user
*.userosscache
*.sln.docstates

## NuGet
*.nupkg
*.snupkg
**/[Pp]ackages/*
!**/[Pp]ackages/build/

## Visual Studio
.vs/
*.suo
*.cache

## JetBrains Rider
.idea/
*.sln.iml

## VSCode
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

## Test Results
[Tt]est[Rr]esult*/
[Bb]uild[Ll]og.*
TestResults/
coverage*/

## OS
.DS_Store
Thumbs.db
EOF
    info "Created .gitignore"
fi

# README.md 作成
if [ ! -f "README.md" ]; then
    cat > README.md << EOF
# $SOLUTION_NAME

## Prerequisites

- .NET SDK ${DOTNET_MAJOR_MINOR} or later

## Build

\`\`\`bash
dotnet build
\`\`\`

## Test

\`\`\`bash
dotnet test
\`\`\`

## Run

\`\`\`bash
dotnet run --project src/$SOLUTION_NAME/$SOLUTION_NAME.csproj
\`\`\`

## Project Structure

\`\`\`
$SOLUTION_NAME/
├── src/
│   ├── $SOLUTION_NAME/          # Main project
│   └── $SOLUTION_NAME.Tests/    # Test project
├── docs/                        # Documentation
├── $SOLUTION_NAME.sln
├── global.json
├── Directory.Build.props
└── README.md
\`\`\`
EOF
    info "Created README.md"
fi

# 依存関係を復元
dotnet restore

echo ""
info "Done! Project structure:"
if command -v tree &> /dev/null; then
    tree -L 3 -I 'bin|obj'
else
    find . -maxdepth 3 -type f \( -name "*.csproj" -o -name "*.sln" -o -name "*.cs" -o -name "*.json" -o -name "*.md" \) | head -20
fi

echo ""
info "Next steps:"
echo "  cd $PROJECT_DIR"
echo "  dotnet build"
echo "  dotnet test"
if [ "$TEMPLATE" = "webapi" ] || [ "$TEMPLATE" = "mvc" ] || [ "$TEMPLATE" = "blazor" ]; then
    echo "  dotnet run --project src/$SOLUTION_NAME/$SOLUTION_NAME.csproj"
else
    echo "  dotnet run --project src/$SOLUTION_NAME/$SOLUTION_NAME.csproj"
fi
