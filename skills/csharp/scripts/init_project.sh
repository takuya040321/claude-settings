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
mkdir -p src tests

# メインプロジェクト作成
if [ ! -d "src/$SOLUTION_NAME" ]; then
    dotnet new "$TEMPLATE" -n "$SOLUTION_NAME" -o "src/$SOLUTION_NAME"
    dotnet sln add "src/$SOLUTION_NAME/$SOLUTION_NAME.csproj"
    info "Created main project: src/$SOLUTION_NAME"
else
    warn "Main project already exists, skipping"
fi

# テストプロジェクト作成
if [ ! -d "tests/$SOLUTION_NAME.Tests" ]; then
    dotnet new xunit -n "$SOLUTION_NAME.Tests" -o "tests/$SOLUTION_NAME.Tests"
    dotnet sln add "tests/$SOLUTION_NAME.Tests/$SOLUTION_NAME.Tests.csproj"
    dotnet add "tests/$SOLUTION_NAME.Tests/$SOLUTION_NAME.Tests.csproj" reference "src/$SOLUTION_NAME/$SOLUTION_NAME.csproj"

    # Moqパッケージを追加
    dotnet add "tests/$SOLUTION_NAME.Tests/$SOLUTION_NAME.Tests.csproj" package Moq

    info "Created test project: tests/$SOLUTION_NAME.Tests"
else
    warn "Test project already exists, skipping"
fi

# global.json 作成
if [ ! -f "global.json" ]; then
    DOTNET_VERSION=$(dotnet --version | cut -d. -f1,2)
    cat > global.json << EOF
{
  "sdk": {
    "version": "$(dotnet --version)",
    "rollForward": "latestFeature"
  }
}
EOF
    info "Created global.json"
fi

# Directory.Build.props 作成
if [ ! -f "Directory.Build.props" ]; then
    cat > Directory.Build.props << 'EOF'
<Project>
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
  </PropertyGroup>
</Project>
EOF
    info "Created Directory.Build.props"
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

- .NET 8.0 SDK or later

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
│   └── $SOLUTION_NAME/          # Main project
├── tests/
│   └── $SOLUTION_NAME.Tests/    # Test project
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
