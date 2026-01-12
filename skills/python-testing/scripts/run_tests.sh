#!/bin/bash
# Python テスト実行スクリプト
# pytest を使用してテストを実行
# 引数: $1 = テストパス（省略時はtests/またはカレントディレクトリ）
#       $2 = オプション（--cov でカバレッジレポート）

set -e

# デフォルトのテストパスを設定
if [ -n "$1" ]; then
    TEST_PATH="$1"
elif [ -d "tests" ]; then
    TEST_PATH="tests"
else
    TEST_PATH="."
fi

# オプション解析
PYTEST_OPTS="-v"
COVERAGE=false

for arg in "$@"; do
    case $arg in
        --cov)
            COVERAGE=true
            ;;
    esac
done

echo "=== Python テスト実行 ==="
echo "対象: $TEST_PATH"
echo ""

# pytest が利用可能かチェック
if ! command -v pytest &> /dev/null; then
    echo "エラー: pytest がインストールされていません" >&2
    echo "pip install pytest でインストールしてください" >&2
    exit 1
fi

# テスト実行
if [ "$COVERAGE" = true ]; then
    if command -v pytest-cov &> /dev/null || python -c "import pytest_cov" 2>/dev/null; then
        echo "カバレッジレポート付きで実行..."
        pytest $PYTEST_OPTS --cov --cov-report=term-missing "$TEST_PATH"
    else
        echo "警告: pytest-cov がインストールされていません。通常のテストを実行します。" >&2
        pytest $PYTEST_OPTS "$TEST_PATH"
    fi
else
    pytest $PYTEST_OPTS "$TEST_PATH"
fi

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "========================================"
    echo "すべてのテストに合格しました"
    echo "========================================"
else
    echo "========================================"
    echo "テストに失敗しました"
    echo "========================================"
fi

exit $EXIT_CODE
