#!/bin/bash
# Python フォーマット・品質・型チェックスクリプト
# black → ruff → mypy の順に実行
# 引数: $1 = ファイルパス（省略時はカレントディレクトリの全.pyファイル）

set -e

if [ -n "$1" ]; then
    TARGET="$1"
else
    TARGET="."
fi

HAS_ERROR=0
ERROR_MSG=""

echo "=== Python コードチェック開始 ==="
echo "対象: $TARGET"
echo ""

# 1. black でコード整形
echo "[1/3] black: フォーマット中..."
if command -v black &> /dev/null; then
    BLACK_OUTPUT=$(black "$TARGET" 2>&1) || true
    echo "black: 完了"
else
    echo "black: コマンドが見つかりません（スキップ）" >&2
fi

# 2. ruff で自動修正 + チェック
echo "[2/3] ruff: 品質チェック中..."
if command -v ruff &> /dev/null; then
    # まず自動修正を試行
    ruff check --fix "$TARGET" 2>&1 || true

    # 修正できないエラーがあるかチェック
    RUFF_CHECK=$(ruff check "$TARGET" 2>&1) || true
    RUFF_EXIT=$?

    if [ -n "$RUFF_CHECK" ] && [ "$RUFF_EXIT" -ne 0 ]; then
        HAS_ERROR=1
        ERROR_MSG="${ERROR_MSG}

=== ruff エラー ===
以下の品質エラーを修正してください:
${RUFF_CHECK}"
        echo "ruff: エラーあり"
    else
        echo "ruff: OK"
    fi
else
    echo "ruff: コマンドが見つかりません（スキップ）" >&2
fi

# 3. mypy で型チェック
echo "[3/3] mypy: 型チェック中..."
if command -v mypy &> /dev/null; then
    MYPY_OUTPUT=$(mypy "$TARGET" --no-error-summary 2>&1) || true
    MYPY_EXIT=$?

    if [ "$MYPY_EXIT" -ne 0 ] && [ -n "$MYPY_OUTPUT" ]; then
        HAS_ERROR=1
        ERROR_MSG="${ERROR_MSG}

=== mypy エラー ===
以下の型エラーを修正してください:
${MYPY_OUTPUT}"
        echo "mypy: エラーあり"
    else
        echo "mypy: OK"
    fi
else
    echo "mypy: コマンドが見つかりません（スキップ）" >&2
fi

echo ""

# 結果出力
if [ $HAS_ERROR -eq 1 ]; then
    echo "========================================"
    echo "エラーが検出されました"
    echo "========================================"
    echo "$ERROR_MSG"
    echo ""
    echo "上記のエラーをすべて修正してください。"
    echo "修正後、再度このスクリプトを実行してください。"
    exit 1
else
    echo "========================================"
    echo "すべてのチェックに合格しました"
    echo "========================================"
    exit 0
fi
