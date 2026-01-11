# Python ベストプラクティス

## 型ヒント

型ヒントは必須。すべての関数・メソッドに適用する。

```python
from typing import Optional, List, Dict, Any, Union
from collections.abc import Callable, Iterable

def process_data(
    items: List[str],
    callback: Callable[[str], bool],
    options: Optional[Dict[str, Any]] = None,
) -> List[str]:
    """データを処理する。"""
    ...
```

### 型ヒントのガイドライン

- `Optional[X]` は `X | None` と同等（Python 3.10+では後者推奨）
- コレクションは具体的な型を指定: `List[int]`, `Dict[str, User]`
- 複雑な型は `TypeAlias` で定義
- `Any` の使用は最小限に

## Docstring（Google形式）

```python
def fetch_user(user_id: int, include_deleted: bool = False) -> Optional[User]:
    """ユーザー情報を取得する。

    Args:
        user_id: ユーザーの一意識別子。
        include_deleted: 削除済みユーザーも含める場合はTrue。

    Returns:
        ユーザーオブジェクト。見つからない場合はNone。

    Raises:
        ValueError: user_idが0以下の場合。
        ConnectionError: データベース接続に失敗した場合。
    """
    ...
```

## コーディングスタイル

### black/ruff準拠

- 行の最大長: 88文字
- インデント: スペース4つ
- 文字列: ダブルクォート優先

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
import sys
from datetime import datetime

# 2. サードパーティ
import requests
from pydantic import BaseModel

# 3. ローカル
from myapp.models import User
from myapp.utils import helper
```

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
    """ユーザーが見つからない場合の例外。"""
    def __init__(self, user_id: int):
        self.user_id = user_id
        super().__init__(f"User not found: {user_id}")
```

## テスト（pytest）

```python
import pytest
from myapp.services import UserService

class TestUserService:
    """UserServiceのテスト。"""

    @pytest.fixture
    def service(self) -> UserService:
        """テスト用のサービスインスタンス。"""
        return UserService()

    def test_create_user_success(self, service: UserService) -> None:
        """ユーザー作成が成功することを確認。"""
        user = service.create_user("test@example.com")
        assert user.email == "test@example.com"
        assert user.id is not None

    def test_create_user_invalid_email(self, service: UserService) -> None:
        """無効なメールアドレスで例外が発生することを確認。"""
        with pytest.raises(ValueError, match="Invalid email"):
            service.create_user("invalid-email")

    @pytest.mark.parametrize("email,expected", [
        ("user@example.com", True),
        ("invalid", False),
        ("", False),
    ])
    def test_validate_email(self, service: UserService, email: str, expected: bool) -> None:
        """メールバリデーションのパラメータ化テスト。"""
        assert service.validate_email(email) == expected
```

## プロジェクト構成

```
project/
├── src/
│   └── myapp/
│       ├── __init__.py
│       ├── models/
│       ├── services/
│       ├── api/
│       └── utils/
├── tests/
│   ├── conftest.py
│   ├── unit/
│   └── integration/
├── pyproject.toml
├── .python-version
└── README.md
```

## 推奨ツール

| ツール | 用途 |
|--------|------|
| black | コードフォーマット |
| ruff | Linting |
| mypy | 型チェック |
| pytest | テスト |
| pytest-cov | カバレッジ |
