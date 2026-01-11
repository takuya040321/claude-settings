#!/bin/bash
# Python フォーマット hook
# black → ruff → mypy の順に実行
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

# 1. black でコード整形
if command -v black &> /dev/null; then
    BLACK_OUTPUT=$(black "$FILE_PATH" 2>&1)
    echo "black: フォーマット適用"
else
    echo "black: コマンドが見つかりません" >&2
fi

# 2. ruff で自動修正
if command -v ruff &> /dev/null; then
    RUFF_OUTPUT=$(ruff check --fix "$FILE_PATH" 2>&1)
    RUFF_EXIT=$?

    # --fix で修正できないエラーがあるかチェック
    RUFF_CHECK=$(ruff check "$FILE_PATH" 2>&1)
    if [ $? -ne 0 ] && [ -n "$RUFF_CHECK" ]; then
        HAS_ERROR=1
        ERROR_MSG="${ERROR_MSG}

[ruff] 以下の品質エラーを修正してください:
${RUFF_CHECK}"
    else
        echo "ruff: OK"
    fi
else
    echo "ruff: コマンドが見つかりません" >&2
fi

# 3. mypy で型チェック
if command -v mypy &> /dev/null; then
    MYPY_OUTPUT=$(mypy "$FILE_PATH" --no-error-summary 2>&1)
    MYPY_EXIT=$?

    if [ $MYPY_EXIT -eq 0 ]; then
        echo "mypy: OK"
    else
        HAS_ERROR=1
        ERROR_MSG="${ERROR_MSG}

[mypy] 以下の型エラーを修正してください:
${MYPY_OUTPUT}"
    fi
else
    echo "mypy: コマンドが見つかりません" >&2
fi

# エラーがあればClaudeにフィードバック
if [ $HAS_ERROR -eq 1 ]; then
    echo "========================================" >&2
    echo "エラーが検出されました。以下を修正してください。" >&2
    echo "修正後、再度フォーマット・品質・型チェックが実行されます。" >&2
    echo "========================================" >&2
    echo "$ERROR_MSG" >&2
    exit 2  # exit 2 でClaudeにフィードバック（ブロック）
fi

echo "すべてのチェックに合格しました"
exit 0
