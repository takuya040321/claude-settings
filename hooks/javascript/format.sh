#!/bin/bash
# JavaScript/TypeScript フォーマット hook
# prettier → eslint の順に実行
# エラー時はClaudeにフィードバックして自動修正させる
# 引数: $1 = ファイルパス

FILE_PATH="$1"

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# ファイル存在チェック
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

HAS_ERROR=0
ERROR_MSG=""

# 1. prettier でフォーマット
if command -v npx &> /dev/null; then
    PRETTIER_OUTPUT=$(npx prettier --write "$FILE_PATH" 2>&1)
    echo "prettier: フォーマット適用"
else
    echo "prettier: npx が見つかりません" >&2
fi

# 2. eslint で自動修正（プロジェクトにインストールされている場合）
if [ -f "$(dirname "$FILE_PATH")/node_modules/.bin/eslint" ] || [ -f "./node_modules/.bin/eslint" ]; then
    # まず --fix で自動修正
    npx eslint --fix "$FILE_PATH" 2>&1

    # 修正後に残っているエラーをチェック
    ESLINT_CHECK=$(npx eslint "$FILE_PATH" 2>&1)
    ESLINT_EXIT=$?

    if [ $ESLINT_EXIT -eq 0 ]; then
        echo "eslint: OK"
    else
        HAS_ERROR=1
        ERROR_MSG="[eslint] 以下のエラーを修正してください:
${ESLINT_CHECK}"
    fi
else
    echo "eslint: プロジェクトにインストールされていません（スキップ）"
fi

# エラーがあればClaudeにフィードバック
if [ $HAS_ERROR -eq 1 ]; then
    echo "========================================" >&2
    echo "エラーが検出されました。以下を修正してください。" >&2
    echo "修正後、再度フォーマット・品質チェックが実行されます。" >&2
    echo "========================================" >&2
    echo "$ERROR_MSG" >&2
    exit 2  # exit 2 でClaudeにフィードバック（ブロック）
fi

echo "すべてのチェックに合格しました"
exit 0
