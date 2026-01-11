#!/usr/bin/env python3
"""
言語別フォーマットhookルーター
ファイル拡張子に応じて適切な言語hookを呼び出す
"""
import json
import sys
import subprocess
import os
from pathlib import Path

# hooks ディレクトリのパス
HOOKS_DIR = Path(__file__).parent

# 拡張子と言語hookのマッピング
LANGUAGE_MAP = {
    # Python
    '.py': 'python/format.sh',
    '.pyi': 'python/format.sh',

    # JavaScript/TypeScript
    '.js': 'javascript/format.sh',
    '.jsx': 'javascript/format.sh',
    '.ts': 'javascript/format.sh',
    '.tsx': 'javascript/format.sh',
    '.mjs': 'javascript/format.sh',
    '.cjs': 'javascript/format.sh',

    # Dart/Flutter
    '.dart': 'dart/format.sh',
}


def run_hook(hook_script: str, file_path: str) -> tuple[int, str, str]:
    """hookスクリプトを実行"""
    script_path = HOOKS_DIR / hook_script

    if not script_path.exists():
        return 0, "", f"Hook script not found: {script_path}"

    try:
        result = subprocess.run(
            ['bash', str(script_path), file_path],
            capture_output=True,
            text=True,
            timeout=60
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return 1, "", "Hook timed out"
    except Exception as e:
        return 1, "", str(e)


def main():
    # stdin から JSON を読み取る
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    # ファイルパスを取得
    tool_input = input_data.get('tool_input', {})
    file_path = tool_input.get('file_path', '')

    if not file_path:
        sys.exit(0)

    # ファイルが存在しない場合はスキップ
    if not os.path.exists(file_path):
        sys.exit(0)

    # 拡張子を取得
    ext = os.path.splitext(file_path)[1].lower()

    # 対応する言語hookがあるか確認
    hook_script = LANGUAGE_MAP.get(ext)

    if not hook_script:
        # 未対応の拡張子はスキップ
        sys.exit(0)

    # hookを実行
    exit_code, stdout, stderr = run_hook(hook_script, file_path)

    # 出力
    if stdout:
        print(stdout)
    if stderr:
        print(stderr, file=sys.stderr)

    sys.exit(exit_code)


if __name__ == '__main__':
    main()
