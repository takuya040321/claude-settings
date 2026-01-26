#!/bin/bash
# C# テスト実行スクリプト
# dotnet test を使用してテストを実行
# 引数: $1 = テストプロジェクトパス（省略時はソリューション全体）
#       --coverage でカバレッジレポート

set -e

# デフォルト値
TEST_PATH=""
COVERAGE=false
FILTER=""
VERBOSITY="normal"

# 色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# オプション解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --coverage)
            COVERAGE=true
            shift
            ;;
        --filter)
            FILTER="$2"
            shift 2
            ;;
        --verbose|-v)
            VERBOSITY="detailed"
            shift
            ;;
        --quiet|-q)
            VERBOSITY="minimal"
            shift
            ;;
        *)
            if [ -z "$TEST_PATH" ]; then
                TEST_PATH="$1"
            fi
            shift
            ;;
    esac
done

# dotnet CLI チェック
if ! command -v dotnet &> /dev/null; then
    error "dotnet CLI is not installed. Install from: https://dotnet.microsoft.com/download"
fi

echo "=== C# テスト実行 ==="
if [ -n "$TEST_PATH" ]; then
    echo "対象: $TEST_PATH"
else
    echo "対象: ソリューション全体"
fi
echo ""

# テストコマンド構築
TEST_CMD="dotnet test"

if [ -n "$TEST_PATH" ]; then
    TEST_CMD="$TEST_CMD \"$TEST_PATH\""
fi

TEST_CMD="$TEST_CMD --verbosity $VERBOSITY"

if [ -n "$FILTER" ]; then
    TEST_CMD="$TEST_CMD --filter \"$FILTER\""
    info "フィルタ: $FILTER"
fi

# カバレッジオプション
if [ "$COVERAGE" = true ]; then
    info "カバレッジレポートを生成します..."

    # coverlet が使用可能かチェック
    TEST_CMD="$TEST_CMD --collect:\"XPlat Code Coverage\""

    # レポート出力先
    RESULTS_DIR="./TestResults"
    mkdir -p "$RESULTS_DIR"

    TEST_CMD="$TEST_CMD --results-directory \"$RESULTS_DIR\""
fi

# テスト実行
info "テストを実行中..."
echo ""

eval $TEST_CMD
EXIT_CODE=$?

echo ""

# カバレッジレポートの処理
if [ "$COVERAGE" = true ] && [ $EXIT_CODE -eq 0 ]; then
    # 最新のカバレッジファイルを見つける
    COVERAGE_FILE=$(find ./TestResults -name "coverage.cobertura.xml" -type f -printf '%T+ %p\n' 2>/dev/null | sort -r | head -1 | cut -d' ' -f2-)

    if [ -n "$COVERAGE_FILE" ]; then
        info "カバレッジファイル: $COVERAGE_FILE"

        # reportgenerator が利用可能な場合はHTMLレポートを生成
        if command -v reportgenerator &> /dev/null; then
            REPORT_DIR="./TestResults/CoverageReport"
            reportgenerator "-reports:$COVERAGE_FILE" "-targetdir:$REPORT_DIR" "-reporttypes:Html"
            info "HTMLレポート: $REPORT_DIR/index.html"
        else
            warn "reportgenerator がインストールされていません"
            echo "  インストール: dotnet tool install -g dotnet-reportgenerator-globaltool"
        fi
    fi
fi

# 結果表示
if [ $EXIT_CODE -eq 0 ]; then
    echo "========================================"
    echo -e "${GREEN}すべてのテストに合格しました${NC}"
    echo "========================================"
else
    echo "========================================"
    echo -e "${RED}テストに失敗しました${NC}"
    echo "========================================"
fi

exit $EXIT_CODE
