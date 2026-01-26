#!/bin/bash
# TypeScript/JavaScript フォーマット・品質・型チェックスクリプト
# prettier → eslint → tsc の順に実行
# 引数: $1 = ファイルパス（省略時はカレントディレクトリ）

set -e

if [ -n "$1" ]; then
    TARGET="$1"
else
    TARGET="."
fi

HAS_ERROR=0
ERROR_MSG=""

echo "=== TypeScript/JavaScript コードチェック開始 ==="
echo "対象: $TARGET"
echo ""

# 1. prettier でコード整形
echo "[1/3] prettier: フォーマット中..."
if command -v npx &> /dev/null; then
    PRETTIER_OUTPUT=$(npx prettier --write "$TARGET" 2>&1) || true
    echo "prettier: 完了"
else
    echo "prettier: npx が見つかりません（スキップ）" >&2
fi

# 2. eslint で自動修正 + チェック
echo "[2/3] eslint: 品質チェック中..."
if [ -f "./node_modules/.bin/eslint" ] || command -v eslint &> /dev/null; then
    # まず自動修正を試行
    npx eslint --fix "$TARGET" 2>&1 || true

    # 修正できないエラーがあるかチェック
    ESLINT_CHECK=$(npx eslint "$TARGET" 2>&1) || true
    ESLINT_EXIT=$?

    if [ -n "$ESLINT_CHECK" ] && [ "$ESLINT_EXIT" -ne 0 ]; then
        HAS_ERROR=1
        ERROR_MSG="${ERROR_MSG}

=== eslint エラー ===
以下の品質エラーを修正してください:
${ESLINT_CHECK}"
        echo "eslint: エラーあり"
    else
        echo "eslint: OK"
    fi
else
    echo "eslint: プロジェクトにインストールされていません（スキップ）"
fi

# 3. tsc で型チェック（TypeScriptファイルの場合）
echo "[3/3] tsc: 型チェック中..."
if [ -f "./tsconfig.json" ]; then
    TSC_OUTPUT=$(npx tsc --noEmit 2>&1) || true
    TSC_EXIT=$?

    if [ "$TSC_EXIT" -ne 0 ] && [ -n "$TSC_OUTPUT" ]; then
        HAS_ERROR=1
        ERROR_MSG="${ERROR_MSG}

=== tsc 型エラー ===
以下の型エラーを修正してください:
${TSC_OUTPUT}"
        echo "tsc: エラーあり"
    else
        echo "tsc: OK"
    fi
else
    echo "tsc: tsconfig.json が見つかりません（スキップ）"
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
