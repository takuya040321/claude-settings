#!/bin/bash
# C# フォーマット・ビルドチェックスクリプト
# dotnet format → dotnet build の順に実行
# 引数: $1 = プロジェクト/ソリューションパス（省略時はカレントディレクトリ）

set -e

if [ -n "$1" ]; then
    TARGET="$1"
else
    TARGET="."
fi

HAS_ERROR=0
ERROR_MSG=""

echo "=== C# コードチェック開始 ==="
echo "対象: $TARGET"
echo ""

# dotnet CLI が利用可能かチェック
if ! command -v dotnet &> /dev/null; then
    echo "エラー: dotnet CLI がインストールされていません" >&2
    echo ".NET SDK をインストールしてください: https://dotnet.microsoft.com/download" >&2
    exit 1
fi

# .csproj または .sln ファイルを探す
find_project() {
    local dir="$1"
    if [ -f "$dir" ]; then
        echo "$dir"
        return
    fi

    # .sln ファイルを優先
    local sln=$(find "$dir" -maxdepth 1 -name "*.sln" -type f 2>/dev/null | head -1)
    if [ -n "$sln" ]; then
        echo "$sln"
        return
    fi

    # .csproj ファイルを探す
    local csproj=$(find "$dir" -maxdepth 1 -name "*.csproj" -type f 2>/dev/null | head -1)
    if [ -n "$csproj" ]; then
        echo "$csproj"
        return
    fi

    echo "$dir"
}

PROJECT=$(find_project "$TARGET")
echo "プロジェクト: $PROJECT"
echo ""

# 1. dotnet format でコード整形
echo "[1/2] dotnet format: フォーマット中..."
FORMAT_OUTPUT=$(dotnet format "$PROJECT" --verbosity minimal 2>&1) || true
FORMAT_EXIT=$?

if [ $FORMAT_EXIT -ne 0 ]; then
    # フォーマットエラーがあれば報告
    if echo "$FORMAT_OUTPUT" | grep -q "error"; then
        HAS_ERROR=1
        ERROR_MSG="${ERROR_MSG}

=== dotnet format エラー ===
${FORMAT_OUTPUT}"
        echo "dotnet format: エラーあり"
    else
        echo "dotnet format: 完了"
    fi
else
    echo "dotnet format: 完了"
fi

# 2. dotnet build でコンパイルチェック
echo "[2/2] dotnet build: ビルド中..."
BUILD_OUTPUT=$(dotnet build "$PROJECT" --no-restore --verbosity minimal 2>&1) || true
BUILD_EXIT=$?

if [ $BUILD_EXIT -ne 0 ]; then
    HAS_ERROR=1
    # エラー行のみ抽出
    BUILD_ERRORS=$(echo "$BUILD_OUTPUT" | grep -E "(error CS|error MSB|error NU)" || echo "$BUILD_OUTPUT")
    ERROR_MSG="${ERROR_MSG}

=== dotnet build エラー ===
以下のビルドエラーを修正してください:
${BUILD_ERRORS}"
    echo "dotnet build: エラーあり"
else
    # 警告があれば表示
    BUILD_WARNINGS=$(echo "$BUILD_OUTPUT" | grep -E "warning CS" || true)
    if [ -n "$BUILD_WARNINGS" ]; then
        echo "dotnet build: 成功（警告あり）"
        echo ""
        echo "=== 警告 ==="
        echo "$BUILD_WARNINGS"
    else
        echo "dotnet build: 成功"
    fi
fi

echo ""

# 結果出力
if [ $HAS_ERROR -eq 1 ]; then
    echo "========================================"
    echo "エラーが検出されました"
    echo "========================================"
    echo "$ERROR_MSG"
    echo ""
    echo "上記のエラーをすべて修正してください。"
    echo "修正後、再度このスクリプトを実行してください。"
    exit 1
else
    echo "========================================"
    echo "すべてのチェックに合格しました"
    echo "========================================"
    exit 0
fi
