---
name: react-coding
description: Reactコーディングのベストプラクティスとコード品質保証。Reactコンポーネント（.tsx, .jsx）の作成・編集タスクを完了した際に使用。コーディングタスク終了後にtypescript-codingのcheck.shでフォーマット・品質・型チェックを実行し、すべてのチェックに合格するまで修正を繰り返す。
---

# React Coding

Reactコーディングのベストプラクティスとコード品質保証を提供する。

## 必須ワークフロー

Reactコーディングタスク完了時、必ず以下を実行：

```bash
~/.claude/skills/typescript-coding/scripts/check.sh <対象ファイルまたはディレクトリ>
```

**重要**: エラーが検出された場合、すべてのエラーを修正し、チェックに合格するまでスクリプトを再実行すること。

## コンポーネント規約

### ファイル命名

| 対象 | スタイル | 例 |
|------|----------|-----|
| コンポーネント | PascalCase | `UserProfile.tsx` |
| フック | camelCase + use接頭辞 | `useAuth.ts` |
| ユーティリティ | camelCase | `formatDate.ts` |
| 型定義 | types.ts or .d.ts | `types.ts` |

### コンポーネント構造

```tsx
// 1. インポート
import { useState, useCallback } from 'react';
import { Button } from '@/components/ui/button';
import type { UserProps } from './types';

// 2. 型定義（またはインポート）
interface Props {
  user: User;
  onUpdate: (user: User) => void;
}

// 3. コンポーネント（名前付きエクスポート推奨）
export function UserCard({ user, onUpdate }: Props) {
  // 3a. State
  const [isEditing, setIsEditing] = useState(false);

  // 3b. 派生値
  const displayName = user.firstName + ' ' + user.lastName;

  // 3c. イベントハンドラ
  const handleSave = useCallback(() => {
    onUpdate(user);
    setIsEditing(false);
  }, [user, onUpdate]);

  // 3d. 早期リターン
  if (!user) {
    return null;
  }

  // 3e. レンダリング
  return (
    <div className="p-4 border rounded">
      <h2>{displayName}</h2>
      <Button onClick={handleSave}>Save</Button>
    </div>
  );
}
```

## JSX 規約

### 条件付きレンダリング

```tsx
// 三項演算子（シンプルな場合）
{isLoading ? <Spinner /> : <Content />}

// 論理AND（falsy値に注意）
{items.length > 0 && <List items={items} />}

// 早期リターン（複雑な条件）
if (isLoading) return <Spinner />;
if (error) return <Error message={error} />;
return <Content />;
```

### リスト描画

```tsx
// keyは安定した一意の値を使用
{items.map((item) => (
  <ListItem key={item.id} item={item} />
))}

// インデックスをkeyにするのは最終手段
{items.map((item, index) => (
  <StaticItem key={index} item={item} />
))}
```

### イベントハンドラ

```tsx
// インラインは避ける（再レンダリングの原因）
// ❌
<button onClick={() => handleClick(id)}>Click</button>

// useCallbackを使用
// ✅
const handleItemClick = useCallback(() => {
  handleClick(id);
}, [id, handleClick]);

<button onClick={handleItemClick}>Click</button>
```

## Hooks ルール

### 基本ルール

1. **トップレベルでのみ呼び出す** - ループ、条件、ネスト関数内で呼ばない
2. **Reactコンポーネント/カスタムHook内でのみ呼び出す**

```tsx
// ❌ 条件付きHook呼び出し
if (isLoggedIn) {
  const [user] = useState(null);
}

// ✅ 常にトップレベルで呼び出す
const [user, setUser] = useState<User | null>(null);
```

### useEffect

```tsx
// 依存配列を正確に指定
useEffect(() => {
  fetchUser(userId);
}, [userId]); // userIdが変わった時のみ実行

// クリーンアップ関数
useEffect(() => {
  const subscription = subscribe(userId);
  return () => {
    subscription.unsubscribe();
  };
}, [userId]);

// 空の依存配列 = マウント時のみ
useEffect(() => {
  initializeApp();
}, []);
```

### useCallback / useMemo

```tsx
// useCallback: 関数のメモ化
const handleSubmit = useCallback((data: FormData) => {
  submitForm(data);
}, [submitForm]);

// useMemo: 計算結果のメモ化
const sortedItems = useMemo(() => {
  return items.sort((a, b) => a.name.localeCompare(b.name));
}, [items]);

// 過度な最適化は避ける
// 単純な計算やプリミティブ値にはuseMemo不要
```

## Props と型定義

### Props 型

```tsx
// インターフェースを使用
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}

// デフォルト値
export function Button({
  variant = 'primary',
  size = 'md',
  disabled = false,
  onClick,
  children,
}: ButtonProps) {
  // ...
}
```

### Children の型

```tsx
// React.ReactNode: あらゆるレンダリング可能な値
interface CardProps {
  children: React.ReactNode;
}

// React.ReactElement: React要素のみ
interface WrapperProps {
  children: React.ReactElement;
}

// 関数（Render Props）
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
}
```

### イベントハンドラの型

```tsx
interface FormProps {
  onSubmit: (e: React.FormEvent<HTMLFormElement>) => void;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  onClick: (e: React.MouseEvent<HTMLButtonElement>) => void;
}
```

## フォルダ構成パターン

### 機能ベース（推奨）

```
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   └── index.ts
│   │   ├── hooks/
│   │   │   └── useAuth.ts
│   │   ├── api/
│   │   │   └── authApi.ts
│   │   └── index.ts
│   └── users/
│       ├── components/
│       ├── hooks/
│       └── index.ts
├── components/
│   └── ui/           # 共通UIコンポーネント
├── hooks/            # 共通フック
├── lib/              # ユーティリティ
└── types/            # 共通型
```

### バレルエクスポート

```tsx
// features/auth/components/index.ts
export { LoginForm } from './LoginForm';
export { RegisterForm } from './RegisterForm';

// features/auth/index.ts
export * from './components';
export * from './hooks';
```

## ESLint 設定（React向け）

```javascript
// eslint.config.js
import js from '@eslint/js';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    plugins: {
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
    },
    rules: {
      ...reactHooks.configs.recommended.rules,
      'react-refresh/only-export-components': [
        'warn',
        { allowConstantExport: true },
      ],
    },
  }
);
```

## チェックツール

| ツール | 用途 |
|--------|------|
| Prettier | コードフォーマット |
| ESLint + eslint-plugin-react-hooks | Linting・Hooksルール |
| TypeScript (tsc) | 型チェック |
