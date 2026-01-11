#!/bin/bash
# Dart/Flutter フォーマット hook
# dart format → dart analyze の順に実行
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

# 1. dart format でフォーマット
if command -v dart &> /dev/null; then
    FORMAT_OUTPUT=$(dart format "$FILE_PATH" 2>&1)
    echo "dart format: フォーマット適用"
else
    echo "dart: コマンドが見つかりません" >&2
    exit 0
fi

# 2. dart analyze で静的解析
ANALYZE_OUTPUT=$(dart analyze "$FILE_PATH" 2>&1)
ANALYZE_EXIT=$?

if [ $ANALYZE_EXIT -eq 0 ]; then
    echo "dart analyze: OK"
else
    HAS_ERROR=1
    ERROR_MSG="[dart analyze] 以下のエラーを修正してください:
${ANALYZE_OUTPUT}"
fi

# エラーがあればClaudeにフィードバック
if [ $HAS_ERROR -eq 1 ]; then
    echo "========================================" >&2
    echo "エラーが検出されました。以下を修正してください。" >&2
    echo "修正後、再度フォーマット・静的解析が実行されます。" >&2
    echo "========================================" >&2
    echo "$ERROR_MSG" >&2
    exit 2  # exit 2 でClaudeにフィードバック（ブロック）
fi

echo "すべてのチェックに合格しました"
exit 0
