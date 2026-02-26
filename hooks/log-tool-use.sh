#!/bin/bash
# PostToolUse Hook: ツール使用情報をtempファイルにJSONL形式で蓄積する
# stdinからJSON（session_id, tool_name, tool_input）を受け取る

trap 'exit 0' ERR

# stdinからJSONを読み取る
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# 必須フィールドが取得できない場合はスキップ
if [ -z "$SESSION_ID" ] || [ -z "$TOOL_NAME" ]; then
    exit 0
fi

TEMP_FILE="/tmp/claude-session-toollog-${SESSION_ID}"
TIMESTAMP=$(date "+%H:%M:%S")

# ツール名に応じてdetailを抽出
case "$TOOL_NAME" in
    Read|Write|Edit)
        DETAIL=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
        ;;
    Bash)
        DETAIL=$(echo "$INPUT" | jq -r '.tool_input.command // empty' | head -c 100)
        ;;
    Grep)
        DETAIL=$(echo "$INPUT" | jq -r '.tool_input.pattern // empty')
        ;;
    Glob)
        DETAIL=$(echo "$INPUT" | jq -r '.tool_input.pattern // empty')
        ;;
    Skill)
        DETAIL=$(echo "$INPUT" | jq -r '.tool_input.skill // empty')
        ;;
    Task)
        SUBAGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // empty')
        DESCRIPTION=$(echo "$INPUT" | jq -r '.tool_input.description // empty')
        DETAIL="${SUBAGENT_TYPE}: ${DESCRIPTION}"
        ;;
    WebFetch)
        DETAIL=$(echo "$INPUT" | jq -r '.tool_input.url // empty')
        ;;
    WebSearch)
        DETAIL=$(echo "$INPUT" | jq -r '.tool_input.query // empty')
        ;;
    *)
        DETAIL=""
        ;;
esac

# JSONエスケープしてJSONLレコードを追記
DETAIL_JSON=$(echo -n "$DETAIL" | jq -Rs '.')
echo "{\"ts\":\"${TIMESTAMP}\",\"type\":\"tool\",\"name\":\"${TOOL_NAME}\",\"detail\":${DETAIL_JSON}}" >> "$TEMP_FILE"

exit 0
