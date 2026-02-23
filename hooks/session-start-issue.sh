#!/bin/bash
# SessionStart Hook: セッション開始時にGitHub Issueを新規作成する
# stdinからJSON（session_id, cwd等）を受け取る

# エラー時はstderrに出力してexit 0（Claudeの動作をブロックしない）
trap 'exit 0' ERR

# stdinからJSONを読み取る
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# session_idが取得できない場合はスキップ
if [ -z "$SESSION_ID" ]; then
    echo "session_id が取得できません" >&2
    exit 0
fi

# cwdが取得できない場合はスキップ
if [ -z "$CWD" ]; then
    echo "cwd が取得できません" >&2
    exit 0
fi

# 古い一時ファイル（24時間以上前）を掃除
find /tmp -maxdepth 1 -name "claude-session-issue-*" -mmin +1440 -delete 2>/dev/null

# git管理外のディレクトリの場合はスキップ
if ! git -C "$CWD" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "git管理外のディレクトリのためスキップ: $CWD" >&2
    exit 0
fi

# リポジトリ情報を取得
REPO_INFO=$(git -C "$CWD" remote -v 2>/dev/null | head -2)
if [ -z "$REPO_INFO" ]; then
    REPO_INFO="リモートリポジトリ未設定"
fi

# 現在時刻
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

# ラベルが存在しなければ作成
if ! gh label list --json name -q '.[].name' 2>/dev/null | grep -q "^claude-code-log$"; then
    gh label create "claude-code-log" --description "Claude Codeセッションの作業ログ" --color "7057ff" 2>/dev/null || true
fi

# Issue本文を作成
ISSUE_BODY=$(cat <<EOF
## セッション情報

| 項目 | 値 |
|------|-----|
| セッションID | \`${SESSION_ID}\` |
| 作業ディレクトリ | \`${CWD}\` |
| 開始時刻 | ${TIMESTAMP} |

### リポジトリ情報
\`\`\`
${REPO_INFO}
\`\`\`
EOF
)

# Issue作成
ISSUE_URL=$(gh issue create \
    --title "🤖 Claude Code作業ログ: ${TIMESTAMP}" \
    --body "$ISSUE_BODY" \
    --label "claude-code-log" \
    2>/dev/null)

if [ -z "$ISSUE_URL" ]; then
    echo "Issue作成に失敗しました" >&2
    exit 0
fi

# Issue番号を抽出して一時ファイルに保存
ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -o '[0-9]*$')
if [ -n "$ISSUE_NUMBER" ]; then
    echo "$ISSUE_NUMBER" > "/tmp/claude-session-issue-${SESSION_ID}"
fi

exit 0
