#!/bin/bash
# SubagentStart / SubagentStop Hook: サブエージェント情報をtempファイルにJSONL形式で蓄積する
# stdinからJSON（session_id, hook_event_name, agent_type, agent_id, last_assistant_message）を受け取る

trap 'exit 0' ERR

# stdinからJSONを読み取る
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
EVENT_NAME=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // empty')

# 必須フィールドが取得できない場合はスキップ
if [ -z "$SESSION_ID" ] || [ -z "$EVENT_NAME" ]; then
    exit 0
fi

TEMP_FILE="/tmp/claude-session-toollog-${SESSION_ID}"
TIMESTAMP=$(date "+%H:%M:%S")

if [ "$EVENT_NAME" = "SubagentStart" ]; then
    AGENT_ID=$(echo "$INPUT" | jq -r '.agent_id // empty')
    DETAIL_JSON=$(echo -n "$AGENT_ID" | jq -Rs '.')
    echo "{\"ts\":\"${TIMESTAMP}\",\"type\":\"subagent_start\",\"name\":\"${AGENT_TYPE}\",\"detail\":${DETAIL_JSON}}" >> "$TEMP_FILE"
elif [ "$EVENT_NAME" = "SubagentStop" ]; then
    LAST_MSG=$(echo "$INPUT" | jq -r '.last_assistant_message // empty' | head -c 200)
    DETAIL_JSON=$(echo -n "$LAST_MSG" | jq -Rs '.')
    echo "{\"ts\":\"${TIMESTAMP}\",\"type\":\"subagent_stop\",\"name\":\"${AGENT_TYPE}\",\"detail\":${DETAIL_JSON}}" >> "$TEMP_FILE"
fi

exit 0
