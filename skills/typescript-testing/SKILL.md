---
name: typescript-testing
description: TypeScriptテストのベストプラクティスとテスト実行。Vitest/Jestを使ったテストの作成・実行ガイド。テストを書く必要がある場合、テストを実行する場合、またはテスト関連の質問がある場合に使用。
---

# TypeScript Testing

Vitest/Jestを使用したTypeScriptテストの作成と実行ガイドを提供する。

## テスト実行

```bash
# Vitest
npx vitest run              # 全テスト実行
npx vitest run src/user     # 特定ディレクトリ
npx vitest run user.test.ts # 特定ファイル
npx vitest --watch          # ウォッチモード

# Jest
npx jest                    # 全テスト実行
npx jest --watch            # ウォッチモード
npx jest --coverage         # カバレッジ付き
```

## テストファイル構成

```
project/
├── src/
│   ├── services/
│   │   ├── user-service.ts
│   │   └── user-service.test.ts  # コロケーション（推奨）
│   └── utils/
│       └── helpers.ts
└── tests/                        # 統合テスト用
    └── integration/
        └── api.test.ts
```

## 基本パターン

### ユニットテスト

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { UserService } from './user-service';

describe('UserService', () => {
  let service: UserService;

  beforeEach(() => {
    service = new UserService();
  });

  describe('createUser', () => {
    it('should create a user with valid data', async () => {
      const user = await service.createUser({
        name: 'John',
        email: 'john@example.com',
      });

      expect(user).toMatchObject({
        name: 'John',
        email: 'john@example.com',
      });
      expect(user.id).toBeDefined();
    });

    it('should throw error for invalid email', async () => {
      await expect(
        service.createUser({ name: 'John', email: 'invalid' })
      ).rejects.toThrow('Invalid email');
    });
  });
});
```

### モック

```typescript
import { vi, Mock } from 'vitest';
import { fetchUser } from './api';
import { UserService } from './user-service';

// モジュールモック
vi.mock('./api', () => ({
  fetchUser: vi.fn(),
}));

describe('UserService with mocked API', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should return user from API', async () => {
    const mockUser = { id: 1, name: 'John' };
    (fetchUser as Mock).mockResolvedValue(mockUser);

    const service = new UserService();
    const user = await service.getUser(1);

    expect(user).toEqual(mockUser);
    expect(fetchUser).toHaveBeenCalledWith(1);
  });
});
```

### スパイ

```typescript
import { vi } from 'vitest';

it('should call logger on error', async () => {
  const logSpy = vi.spyOn(console, 'error').mockImplementation(() => {});

  await service.doSomethingRisky();

  expect(logSpy).toHaveBeenCalledWith(expect.stringContaining('error'));
  logSpy.mockRestore();
});
```

## 非同期テスト

```typescript
// Promise
it('should resolve with data', async () => {
  const result = await fetchData();
  expect(result).toBeDefined();
});

// エラーのテスト
it('should reject on failure', async () => {
  await expect(failingOperation()).rejects.toThrow('Expected error');
});

// タイムアウト
it('should complete within timeout', async () => {
  const result = await slowOperation();
  expect(result).toBe('done');
}, 10000); // 10秒タイムアウト
```

## マッチャー

```typescript
// 基本
expect(value).toBe(expected);           // 厳密等価
expect(value).toEqual(expected);        // 深い等価
expect(value).toBeTruthy();             // 真値
expect(value).toBeFalsy();              // 偽値
expect(value).toBeNull();               // null
expect(value).toBeDefined();            // undefined以外

// 数値
expect(value).toBeGreaterThan(3);
expect(value).toBeLessThanOrEqual(10);
expect(value).toBeCloseTo(0.3, 5);      // 浮動小数点

// 文字列
expect(value).toMatch(/pattern/);
expect(value).toContain('substring');

// 配列/オブジェクト
expect(array).toContain(item);
expect(array).toHaveLength(3);
expect(obj).toHaveProperty('key');
expect(obj).toMatchObject({ key: 'value' });

// 例外
expect(() => fn()).toThrow();
expect(() => fn()).toThrow('message');
expect(() => fn()).toThrow(CustomError);
```

## テストのベストプラクティス

### AAAパターン

```typescript
it('should calculate total price', () => {
  // Arrange（準備）
  const items = [
    { price: 100, quantity: 2 },
    { price: 50, quantity: 1 },
  ];
  const cart = new Cart(items);

  // Act（実行）
  const total = cart.calculateTotal();

  // Assert（検証）
  expect(total).toBe(250);
});
```

### テストの独立性

```typescript
describe('Cart', () => {
  let cart: Cart;

  // 各テスト前にリセット
  beforeEach(() => {
    cart = new Cart();
  });

  // 各テスト後にクリーンアップ
  afterEach(() => {
    vi.clearAllMocks();
  });
});
```

### 記述的なテスト名

```typescript
// ✅ Good: 振る舞いを記述
it('should return empty array when no items match filter', () => {});
it('should throw ValidationError when email is invalid', () => {});

// ❌ Bad: 実装詳細や曖昧な記述
it('test filter', () => {});
it('works correctly', () => {});
```

## 設定ファイル

### Vitest（vitest.config.ts）

```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
    },
  },
});
```

### Jest（jest.config.js）

```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/*.test.ts'],
  collectCoverageFrom: ['src/**/*.ts'],
};
```
