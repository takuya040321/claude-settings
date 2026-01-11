# JavaScript/TypeScript ベストプラクティス

## TypeScript推奨事項

### 型定義

```typescript
// インターフェースを優先（拡張可能）
interface User {
  id: number;
  name: string;
  email: string;
  createdAt: Date;
}

// ユニオン型やマップ型はtypeを使用
type Status = 'pending' | 'active' | 'inactive';
type UserMap = Record<number, User>;

// ジェネリクスの活用
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}
```

### 厳格な型チェック

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

### 型ガード

```typescript
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'name' in obj
  );
}

// 使用例
if (isUser(response.data)) {
  console.log(response.data.name);
}
```

## コーディングスタイル（ESLint/Prettier準拠）

### 命名規則

| 対象 | スタイル | 例 |
|------|----------|-----|
| 変数/関数 | camelCase | `userName`, `getUser` |
| クラス/型 | PascalCase | `UserService`, `ApiResponse` |
| 定数 | UPPER_SNAKE または camelCase | `MAX_RETRIES`, `apiEndpoint` |
| ファイル | kebab-case | `user-service.ts` |
| コンポーネント | PascalCase | `UserProfile.tsx` |

### フォーマット

```javascript
// Prettier設定
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```

## モジュール構成（ES Modules）

```typescript
// 名前付きエクスポートを優先
export function createUser(data: CreateUserInput): User {
  // ...
}

export class UserService {
  // ...
}

// デフォルトエクスポートは避ける（リファクタリングが困難）
// ❌ export default UserService;

// バレルファイル（index.ts）
export { UserService } from './user-service';
export { createUser } from './create-user';
export type { User, CreateUserInput } from './types';
```

## 非同期処理

### async/await

```typescript
// 基本パターン
async function fetchUser(id: number): Promise<User> {
  try {
    const response = await api.get(`/users/${id}`);
    return response.data;
  } catch (error) {
    if (error instanceof ApiError) {
      throw new UserNotFoundError(id);
    }
    throw error;
  }
}

// 並列実行
async function fetchUserWithPosts(id: number): Promise<UserWithPosts> {
  const [user, posts] = await Promise.all([
    fetchUser(id),
    fetchPosts(id),
  ]);
  return { ...user, posts };
}
```

### エラーハンドリング

```typescript
// カスタムエラークラス
class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500
  ) {
    super(message);
    this.name = 'AppError';
  }
}

class UserNotFoundError extends AppError {
  constructor(userId: number) {
    super(`User not found: ${userId}`, 'USER_NOT_FOUND', 404);
  }
}
```

## テスト（Jest/Vitest）

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

// モック
vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: 1, name: 'John' }),
}));
```

## プロジェクト構成

```
project/
├── src/
│   ├── components/     # UIコンポーネント
│   ├── hooks/          # カスタムフック
│   ├── services/       # ビジネスロジック
│   ├── utils/          # ユーティリティ
│   ├── types/          # 型定義
│   └── index.ts
├── tests/
│   ├── unit/
│   └── integration/
├── package.json
├── tsconfig.json
├── eslint.config.js
└── prettier.config.js
```

## 推奨ツール

| ツール | 用途 |
|--------|------|
| TypeScript | 型安全性 |
| ESLint | Linting |
| Prettier | コードフォーマット |
| Vitest/Jest | テスト |
| tsx | TypeScript実行 |
