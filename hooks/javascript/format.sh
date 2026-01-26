#!/bin/bash
# JavaScript/TypeScript フォーマット・品質・型チェック hook
# prettier → eslint → tsc の順に実行
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

# プロジェクトルートを探す（package.jsonがあるディレクトリ）
find_project_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/package.json" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    echo ""
}

FILE_DIR=$(dirname "$FILE_PATH")
PROJECT_ROOT=$(find_project_root "$FILE_DIR")

# プロジェクトルートが見つからない場合はスキップ
if [ -z "$PROJECT_ROOT" ]; then
    echo "package.json が見つかりません（スキップ）"
    exit 0
fi

HAS_ERROR=0
ERROR_MSG=""

# 1. prettier でフォーマット
echo "[1/3] prettier: フォーマット中..."
if command -v npx &> /dev/null; then
    cd "$PROJECT_ROOT" && npx prettier --write "$FILE_PATH" 2>&1 || true
    echo "prettier: 完了"
else
    echo "prettier: npx が見つかりません（スキップ）" >&2
fi

# 2. eslint で自動修正 + チェック
echo "[2/3] eslint: 品質チェック中..."
if [ -f "$PROJECT_ROOT/node_modules/.bin/eslint" ]; then
    cd "$PROJECT_ROOT"

    # まず --fix で自動修正
    npx eslint --fix "$FILE_PATH" 2>&1 || true

    # 修正後に残っているエラーをチェック
    ESLINT_CHECK=$(npx eslint "$FILE_PATH" 2>&1)
    ESLINT_EXIT=$?

    if [ $ESLINT_EXIT -eq 0 ]; then
        echo "eslint: OK"
    else
        HAS_ERROR=1
        ERROR_MSG="${ERROR_MSG}

=== eslint エラー ===
以下の品質エラーを修正してください:
${ESLINT_CHECK}"
        echo "eslint: エラーあり"
    fi
else
    echo "eslint: プロジェクトにインストールされていません（スキップ）"
fi

# 3. tsc で型チェック（TypeScriptファイルの場合）
echo "[3/3] tsc: 型チェック中..."
EXT="${FILE_PATH##*.}"
if [[ "$EXT" == "ts" || "$EXT" == "tsx" ]]; then
    if [ -f "$PROJECT_ROOT/tsconfig.json" ]; then
        cd "$PROJECT_ROOT"
        TSC_OUTPUT=$(npx tsc --noEmit 2>&1)
        TSC_EXIT=$?

        if [ $TSC_EXIT -eq 0 ]; then
            echo "tsc: OK"
        else
            # エラーメッセージから編集したファイルに関連するエラーのみ抽出
            FILE_BASENAME=$(basename "$FILE_PATH")
            RELEVANT_ERRORS=$(echo "$TSC_OUTPUT" | grep -A2 "$FILE_BASENAME" || echo "$TSC_OUTPUT")

            if [ -n "$RELEVANT_ERRORS" ]; then
                HAS_ERROR=1
                ERROR_MSG="${ERROR_MSG}

=== tsc 型エラー ===
以下の型エラーを修正してください:
${TSC_OUTPUT}"
                echo "tsc: エラーあり"
            fi
        fi
    else
        echo "tsc: tsconfig.json が見つかりません（スキップ）"
    fi
else
    echo "tsc: JavaScriptファイルのためスキップ"
fi

# エラーがあればClaudeにフィードバック
if [ $HAS_ERROR -eq 1 ]; then
    echo "" >&2
    echo "========================================" >&2
    echo "エラーが検出されました。以下を修正してください。" >&2
    echo "修正後、再度チェックが実行されます。" >&2
    echo "すべてのチェックに合格するまで修正を続けてください。" >&2
    echo "========================================" >&2
    echo "$ERROR_MSG" >&2
    exit 2  # exit 2 でClaudeにフィードバック（ブロック）
fi

echo ""
echo "すべてのチェックに合格しました"
exit 0
