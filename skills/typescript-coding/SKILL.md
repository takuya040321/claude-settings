---
name: typescript-coding
description: TypeScript/JavaScriptコーディングのベストプラクティスとコード品質保証。TypeScript/JavaScriptファイル（.ts, .tsx, .js, .jsx, .mjs, .cjs）の作成・編集タスクを完了した際に使用。コーディングタスク終了後にprettier/eslint/tscでフォーマット・品質・型チェックを実行し、すべてのチェックに合格するまで修正を繰り返す。
---

# TypeScript Coding

TypeScript/JavaScriptコーディングのベストプラクティスとコード品質保証を提供する。

## 必須ワークフロー

TypeScriptコーディングタスク完了時、必ず以下を実行：

```bash
~/.claude/skills/typescript-coding/scripts/check.sh <対象ファイルまたはディレクトリ>
```

**重要**: エラーが検出された場合、すべてのエラーを修正し、チェックに合格するまでスクリプトを再実行すること。

## コーディング規約

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

tsconfig.jsonで以下を有効化：

```json
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
```

### 命名規則

| 対象 | スタイル | 例 |
|------|----------|-----|
| 変数/関数 | camelCase | `userName`, `getUser` |
| クラス/型 | PascalCase | `UserService`, `ApiResponse` |
| 定数 | UPPER_SNAKE または camelCase | `MAX_RETRIES`, `apiEndpoint` |
| ファイル | kebab-case | `user-service.ts` |
| コンポーネント | PascalCase | `UserProfile.tsx` |

### モジュール構成（ES Modules）

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

## チェックツール

| ツール | 用途 |
|--------|------|
| Prettier | コードフォーマット |
| ESLint | Linting・品質チェック |
| TypeScript (tsc) | 型チェック |
