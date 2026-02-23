#!/bin/bash
# Stop Hook: Claude応答完了時にIssueコメントを追加する
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

# コメント本文
COMMENT_BODY="### ✅ 応答完了（${TIMESTAMP}）
${MESSAGE_TRUNCATED}"

# Issueにコメントを追加
gh issue comment "$ISSUE_NUMBER" --body "$COMMENT_BODY" >/dev/null 2>&1

exit 0
