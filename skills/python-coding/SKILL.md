---
name: python-coding
description: Pythonコーディングのベストプラクティスとコード品質保証。Pythonファイルの作成・編集タスクを完了した際に使用。コーディングタスク終了後にblack/ruff/mypyでフォーマット・品質・型チェックを実行し、すべてのチェックに合格するまで修正を繰り返す。
---

# Python Coding

Pythonコーディングのベストプラクティスとコード品質保証を提供する。

## 必須ワークフロー

Pythonコーディングタスク完了時、必ず以下を実行：

```bash
~/.claude/skills/python-coding/scripts/check.sh <対象ファイルまたはディレクトリ>
```

**重要**: エラーが検出された場合、すべてのエラーを修正し、チェックに合格するまでスクリプトを再実行すること。

## コーディング規約

### 型ヒント

型ヒントは必須。すべての関数・メソッドに適用する。

```python
from typing import Optional
from collections.abc import Callable

def process_data(
    items: list[str],
    callback: Callable[[str], bool],
    options: dict[str, any] | None = None,
) -> list[str]:
    ...
```

- `X | None` を使用（Python 3.10+）
- コレクションは具体的な型を指定: `list[int]`, `dict[str, User]`
- `Any` の使用は最小限に

### Docstring（Google形式）

```python
def fetch_user(user_id: int, include_deleted: bool = False) -> User | None:
    """ユーザー情報を取得する。

    Args:
        user_id: ユーザーの一意識別子。
        include_deleted: 削除済みユーザーも含める場合はTrue。

    Returns:
        ユーザーオブジェクト。見つからない場合はNone。

    Raises:
        ValueError: user_idが0以下の場合。
    """
    ...
```

### 命名規則

| 対象 | スタイル | 例 |
|------|----------|-----|
| モジュール | snake_case | `user_service.py` |
| クラス | PascalCase | `UserService` |
| 関数/変数 | snake_case | `get_user`, `user_name` |
| 定数 | UPPER_SNAKE | `MAX_RETRIES` |
| プライベート | 先頭アンダースコア | `_internal_method` |

### インポート順序

```python
# 1. 標準ライブラリ
import os
from datetime import datetime

# 2. サードパーティ
import requests
from pydantic import BaseModel

# 3. ローカル
from myapp.models import User
```

### フォーマット（black準拠）

- 行の最大長: 88文字
- インデント: スペース4つ
- 文字列: ダブルクォート優先

## エラーハンドリング

```python
# 具体的な例外をキャッチ
try:
    result = risky_operation()
except ValueError as e:
    logger.warning(f"Invalid value: {e}")
    raise
except ConnectionError as e:
    logger.error(f"Connection failed: {e}")
    return None

# カスタム例外
class UserNotFoundError(Exception):
    def __init__(self, user_id: int):
        self.user_id = user_id
        super().__init__(f"User not found: {user_id}")
```

## プロジェクト構成

```
project/
├── src/
│   └── myapp/
│       ├── __init__.py
│       ├── models/
│       ├── services/
│       └── utils/
├── tests/
├── pyproject.toml
└── README.md
```

## チェックツール

| ツール | 用途 |
|--------|------|
| black | コードフォーマット |
| ruff | Linting・品質チェック |
| mypy | 型チェック |
