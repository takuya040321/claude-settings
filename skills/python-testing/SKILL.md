---
name: python-testing
description: Pythonテストのベストプラクティスとテスト実行。pytestを使ったテストの作成・実行ガイド。テストを書く必要がある場合、テストを実行する場合、またはテスト関連の質問がある場合に使用。
---

# Python Testing

pytestを使用したPythonテストのベストプラクティスと実行方法を提供する。

## テスト実行

```bash
# 基本実行
~/.claude/skills/python-testing/scripts/run_tests.sh

# 特定パスのテスト
~/.claude/skills/python-testing/scripts/run_tests.sh tests/unit/

# カバレッジレポート付き
~/.claude/skills/python-testing/scripts/run_tests.sh tests/ --cov
```

### pytest コマンド直接実行

```bash
# 基本
pytest tests/

# 詳細出力
pytest -v tests/

# 特定のテスト関数
pytest tests/test_user.py::test_create_user

# 失敗時に停止
pytest -x tests/

# 失敗したテストのみ再実行
pytest --lf tests/
```

## テストの書き方

### 基本構造

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
```

### Fixture

```python
import pytest

@pytest.fixture
def db_session():
    """データベースセッションを提供。"""
    session = create_session()
    yield session
    session.rollback()
    session.close()

@pytest.fixture(scope="module")
def app():
    """モジュール単位で共有するアプリインスタンス。"""
    return create_app(testing=True)
```

### パラメータ化テスト

```python
@pytest.mark.parametrize("email,expected", [
    ("user@example.com", True),
    ("invalid", False),
    ("", False),
    ("user@", False),
])
def test_validate_email(email: str, expected: bool) -> None:
    """メールバリデーションのパラメータ化テスト。"""
    assert validate_email(email) == expected
```

### 例外テスト

```python
def test_division_by_zero() -> None:
    """ゼロ除算で例外が発生することを確認。"""
    with pytest.raises(ZeroDivisionError):
        divide(10, 0)

def test_invalid_input_message() -> None:
    """例外メッセージを検証。"""
    with pytest.raises(ValueError) as exc_info:
        process_input(-1)
    assert "positive" in str(exc_info.value)
```

### モック

```python
from unittest.mock import Mock, patch

def test_fetch_user_from_api() -> None:
    """APIからユーザー取得をモック。"""
    with patch("myapp.api.requests.get") as mock_get:
        mock_get.return_value.json.return_value = {"id": 1, "name": "John"}
        user = fetch_user(1)
        assert user.name == "John"
        mock_get.assert_called_once()

def test_with_mock_object() -> None:
    """Mockオブジェクトを使用。"""
    mock_repo = Mock()
    mock_repo.get_user.return_value = User(id=1, name="John")

    service = UserService(repo=mock_repo)
    user = service.get_user(1)

    assert user.name == "John"
    mock_repo.get_user.assert_called_with(1)
```

## テストファイル配置

```
project/
├── src/
│   └── myapp/
│       ├── __init__.py
│       ├── models.py
│       └── services.py
└── tests/
    ├── __init__.py
    ├── conftest.py      # 共有fixture
    ├── unit/
    │   ├── __init__.py
    │   ├── test_models.py
    │   └── test_services.py
    └── integration/
        ├── __init__.py
        └── test_api.py
```

### conftest.py

```python
# tests/conftest.py
import pytest

@pytest.fixture(scope="session")
def app():
    """アプリケーション全体で共有するfixture。"""
    return create_test_app()

@pytest.fixture
def client(app):
    """テストクライアント。"""
    return app.test_client()
```

## テスト命名規則

| パターン | 例 |
|---------|-----|
| テストファイル | `test_*.py` または `*_test.py` |
| テストクラス | `Test*` |
| テスト関数 | `test_*` |

## 推奨ツール

| ツール | 用途 |
|--------|------|
| pytest | テストフレームワーク |
| pytest-cov | カバレッジ計測 |
| pytest-mock | モック拡張 |
| pytest-xdist | 並列実行 |
