#!/bin/bash
# UserPromptSubmit Hook: ユーザープロンプトをIssueコメントとして追加する
# stdinからJSON（prompt, session_id等）を受け取る

trap 'exit 0' ERR

# stdinからJSONを読み取る
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

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

# プロンプトが空の場合はスキップ
if [ -z "$PROMPT" ]; then
    exit 0
fi

# プロンプトを先頭500文字に切り詰め
PROMPT_TRUNCATED=$(echo "$PROMPT" | head -c 500)
if [ ${#PROMPT} -gt 500 ]; then
    PROMPT_TRUNCATED="${PROMPT_TRUNCATED}..."
fi

# 現在時刻
TIMESTAMP=$(date "+%H:%M:%S")

# コメント本文
COMMENT_BODY=$(cat <<EOF
### 📝 ユーザー入力（${TIMESTAMP}）
> $(echo "$PROMPT_TRUNCATED" | sed 's/$/  /' | sed 's/^/> /' | tail -n +2 | sed '1i\'"$PROMPT_TRUNCATED" | head -1)
EOF
)

# 複数行対応のコメント本文を作成
QUOTED_PROMPT=$(echo "$PROMPT_TRUNCATED" | sed 's/^/> /')
COMMENT_BODY="### 📝 ユーザー入力（${TIMESTAMP}）
${QUOTED_PROMPT}"

# Issueにコメントを追加
gh issue comment "$ISSUE_NUMBER" --body "$COMMENT_BODY" >/dev/null 2>&1

exit 0
