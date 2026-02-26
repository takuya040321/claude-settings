#!/bin/bash
# Stop Hook: Claude応答完了時にIssueコメントを追加する（サマリー付き）
# stdinからJSON（stop_hook_active, last_assistant_message, session_id等）を受け取る

trap 'exit 0' ERR

# stdinからJSONを読み取る
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
LAST_MESSAGE=$(echo "$INPUT" | jq -r '.last_assistant_message // empty')

# session_idが取得できない場合はスキップ
if [ -z "$SESSION_ID" ]; then
    exit 0
fi

# 一時ファイルからIssue番号を読み取る
ISSUE_FILE="/tmp/claude-session-issue-${SESSION_ID}"
if [ ! -f "$ISSUE_FILE" ]; then
    exit 0
fi

ISSUE_NUMBER=$(cat "$ISSUE_FILE")
if [ -z "$ISSUE_NUMBER" ]; then
    exit 0
fi

# last_assistant_messageが空の場合はスキップ
if [ -z "$LAST_MESSAGE" ]; then
    exit 0
fi

# メッセージを先頭300文字に切り詰め
MESSAGE_TRUNCATED=$(echo "$LAST_MESSAGE" | head -c 300)
if [ ${#LAST_MESSAGE} -gt 300 ]; then
    MESSAGE_TRUNCATED="${MESSAGE_TRUNCATED}..."
fi

# 現在時刻
TIMESTAMP=$(date "+%H:%M:%S")

# サマリー構築
SUMMARY=""
TEMP_FILE="/tmp/claude-session-toollog-${SESSION_ID}"

if [ -f "$TEMP_FILE" ] && [ -s "$TEMP_FILE" ]; then
    # 1. 発動スキル
    SKILLS=$(jq -r 'select(.type=="tool" and .name=="Skill") | .detail' "$TEMP_FILE" 2>/dev/null | sort -u)
    if [ -n "$SKILLS" ]; then
        SUMMARY="${SUMMARY}
#### 🎯 発動スキル"
        while IFS= read -r skill; do
            SUMMARY="${SUMMARY}
- \`${skill}\`"
        done <<< "$SKILLS"
        SUMMARY="${SUMMARY}
"
    fi

    # 2. 使用ツール（回数降順）
    TOOL_COUNTS=$(jq -r 'select(.type=="tool") | .name' "$TEMP_FILE" 2>/dev/null | sort | uniq -c | sort -rn)
    if [ -n "$TOOL_COUNTS" ]; then
        SUMMARY="${SUMMARY}
#### 🔧 使用ツール
| ツール | 回数 |
|--------|------|"
        while IFS= read -r line; do
            COUNT=$(echo "$line" | awk '{print $1}')
            NAME=$(echo "$line" | awk '{print $2}')
            SUMMARY="${SUMMARY}
| ${NAME} | ${COUNT} |"
        done <<< "$TOOL_COUNTS"
        SUMMARY="${SUMMARY}
"
    fi

    # 3. 変更ファイル
    CHANGED_FILES=$(jq -r 'select(.type=="tool" and (.name=="Edit" or .name=="Write")) | .detail' "$TEMP_FILE" 2>/dev/null | sort -u)
    if [ -n "$CHANGED_FILES" ]; then
        SUMMARY="${SUMMARY}
#### 📝 変更ファイル"
        while IFS= read -r file; do
            SUMMARY="${SUMMARY}
- \`${file}\`"
        done <<< "$CHANGED_FILES"
        SUMMARY="${SUMMARY}
"
    fi

    # 4. 実行コマンド（最大10件）
    COMMANDS=$(jq -r 'select(.type=="tool" and .name=="Bash") | .detail' "$TEMP_FILE" 2>/dev/null | head -10)
    if [ -n "$COMMANDS" ]; then
        SUMMARY="${SUMMARY}
#### 💻 実行コマンド
\`\`\`
${COMMANDS}
\`\`\`
"
    fi

    # 5. サブエージェント
    SUBAGENT_COUNTS=$(jq -r 'select(.type=="subagent_start") | .name' "$TEMP_FILE" 2>/dev/null | sort | uniq -c | sort -rn)
    if [ -n "$SUBAGENT_COUNTS" ]; then
        SUMMARY="${SUMMARY}
#### 🤖 サブエージェント"
        while IFS= read -r line; do
            COUNT=$(echo "$line" | awk '{print $1}')
            NAME=$(echo "$line" | awk '{print $2}')
            SUMMARY="${SUMMARY}
- ${NAME} (${COUNT}回)"
        done <<< "$SUBAGENT_COUNTS"
        SUMMARY="${SUMMARY}
"
    fi

    # tempファイルをクリーンアップ
    rm -f "$TEMP_FILE"
fi

# コメント本文を構築
if [ -n "$SUMMARY" ]; then
    COMMENT_BODY="### ✅ 応答完了（${TIMESTAMP}）

<details>
<summary>📊 作業サマリー</summary>
${SUMMARY}
</details>

${MESSAGE_TRUNCATED}"
else
    COMMENT_BODY="### ✅ 応答完了（${TIMESTAMP}）
${MESSAGE_TRUNCATED}"
fi

# Issueにコメントを追加
gh issue comment "$ISSUE_NUMBER" --body "$COMMENT_BODY" >/dev/null 2>&1

exit 0
