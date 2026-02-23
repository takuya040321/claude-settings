---
name: react-testing
description: Reactテストのベストプラクティスとテスト実行。Vitest/JestとTesting Libraryを使ったコンポーネント・フックのテスト作成・実行ガイド。テストを書く必要がある場合、テストを実行する場合、またはテスト関連の質問がある場合に使用。
---

# React Testing

Vitest/JestとTesting Libraryを使用したReactテストのベストプラクティスと実行方法を提供する。

## テスト実行

### Vitest

```bash
# 基本実行
npm run test
npx vitest run

# ウォッチモード
npx vitest

# カバレッジ
npx vitest run --coverage

# 特定のファイル
npx vitest run src/components/Button.test.tsx
```

### Jest

```bash
# 基本実行
npm test
npx jest

# ウォッチモード
npx jest --watch

# カバレッジ
npx jest --coverage

# 特定のテスト
npx jest Button.test.tsx
```

## テストファイル構成

```
src/
├── components/
│   ├── Button.tsx
│   └── Button.test.tsx      # コロケーション
└── hooks/
    ├── useAuth.ts
    └── useAuth.test.ts

# または tests/ ディレクトリに分離
tests/
├── components/
│   └── Button.test.tsx
└── hooks/
    └── useAuth.test.ts
```

## コンポーネントテスト

### 基本パターン

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './Button';

describe('Button', () => {
  it('renders with children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const user = userEvent.setup();
    const handleClick = vi.fn();

    render(<Button onClick={handleClick}>Click me</Button>);
    await user.click(screen.getByRole('button'));

    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

### クエリ優先順位

Testing Libraryの推奨クエリ順序：

```tsx
// 1. getByRole（最優先）- アクセシビリティ
screen.getByRole('button', { name: /submit/i });
screen.getByRole('textbox', { name: /email/i });
screen.getByRole('heading', { level: 1 });

// 2. getByLabelText - フォーム要素
screen.getByLabelText(/email address/i);

// 3. getByPlaceholderText
screen.getByPlaceholderText(/enter your email/i);

// 4. getByText - 静的テキスト
screen.getByText(/welcome/i);

// 5. getByTestId（最終手段）
screen.getByTestId('custom-element');
```

### 非同期テスト

```tsx
import { render, screen, waitFor } from '@testing-library/react';

it('loads and displays data', async () => {
  render(<UserProfile userId="1" />);

  // ローディング状態
  expect(screen.getByText(/loading/i)).toBeInTheDocument();

  // データ表示を待機
  await waitFor(() => {
    expect(screen.getByText(/john doe/i)).toBeInTheDocument();
  });
});

it('shows error on fetch failure', async () => {
  server.use(
    http.get('/api/user', () => {
      return HttpResponse.error();
    })
  );

  render(<UserProfile userId="1" />);

  expect(await screen.findByText(/error/i)).toBeInTheDocument();
});
```

### フォームテスト

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('LoginForm', () => {
  it('submits form with valid data', async () => {
    const user = userEvent.setup();
    const handleSubmit = vi.fn();

    render(<LoginForm onSubmit={handleSubmit} />);

    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /submit/i }));

    expect(handleSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password123',
    });
  });

  it('shows validation errors', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={vi.fn()} />);

    await user.click(screen.getByRole('button', { name: /submit/i }));

    expect(screen.getByText(/email is required/i)).toBeInTheDocument();
  });
});
```

## カスタムフックテスト

### renderHook

```tsx
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { result } = renderHook(() => useCounter());
    expect(result.current.count).toBe(0);
  });

  it('initializes with custom value', () => {
    const { result } = renderHook(() => useCounter(10));
    expect(result.current.count).toBe(10);
  });

  it('increments count', () => {
    const { result } = renderHook(() => useCounter());

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });
});
```

### Context依存フック

```tsx
import { renderHook } from '@testing-library/react';
import { AuthProvider, useAuth } from './auth';

describe('useAuth', () => {
  const wrapper = ({ children }: { children: React.ReactNode }) => (
    <AuthProvider>{children}</AuthProvider>
  );

  it('provides auth context', () => {
    const { result } = renderHook(() => useAuth(), { wrapper });

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
  });

  it('handles login', async () => {
    const { result } = renderHook(() => useAuth(), { wrapper });

    await act(async () => {
      await result.current.login('test@example.com', 'password');
    });

    expect(result.current.isAuthenticated).toBe(true);
  });
});
```

### 非同期フック

```tsx
import { renderHook, waitFor } from '@testing-library/react';
import { useFetch } from './useFetch';

describe('useFetch', () => {
  it('fetches data', async () => {
    const { result } = renderHook(() => useFetch('/api/users'));

    expect(result.current.loading).toBe(true);

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.data).toEqual([{ id: 1, name: 'John' }]);
  });
});
```

## モック・スパイ

### 関数モック

```tsx
import { vi } from 'vitest';
// または import { jest } from '@jest/globals';

// モック関数
const mockFn = vi.fn();
mockFn.mockReturnValue('value');
mockFn.mockResolvedValue('async value');

// 呼び出し検証
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith('arg');
expect(mockFn).toHaveBeenCalledTimes(1);
```

### モジュールモック

```tsx
// Vitest
vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: 1, name: 'John' }),
}));

// Jest
jest.mock('./api', () => ({
  fetchUser: jest.fn().mockResolvedValue({ id: 1, name: 'John' }),
}));
```

### MSW (Mock Service Worker)

```tsx
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: 1, name: 'John' },
      { id: 2, name: 'Jane' },
    ]);
  }),
  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: 3, ...body }, { status: 201 });
  }),
];

const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## 統合テスト

```tsx
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { App } from './App';

describe('App Integration', () => {
  it('completes user flow', async () => {
    const user = userEvent.setup();
    render(<App />);

    // ログイン
    await user.click(screen.getByRole('link', { name: /login/i }));
    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password');
    await user.click(screen.getByRole('button', { name: /submit/i }));

    // ダッシュボードに遷移
    expect(await screen.findByText(/dashboard/i)).toBeInTheDocument();

    // ユーザー一覧
    const userList = screen.getByRole('list', { name: /users/i });
    expect(within(userList).getAllByRole('listitem')).toHaveLength(3);
  });
});
```

## 設定ファイル

### vitest.config.ts

```typescript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
    include: ['**/*.{test,spec}.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
    },
  },
});
```

### jest.config.js

```javascript
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/test/setup.ts'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest',
  },
};
```

### setup.ts

```typescript
import '@testing-library/jest-dom';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

afterEach(() => {
  cleanup();
});
```

## ベストプラクティス

### AAA パターン

```tsx
it('updates user name', async () => {
  // Arrange（準備）
  const user = userEvent.setup();
  const handleUpdate = vi.fn();
  render(<UserForm onUpdate={handleUpdate} />);

  // Act（実行）
  await user.clear(screen.getByLabelText(/name/i));
  await user.type(screen.getByLabelText(/name/i), 'New Name');
  await user.click(screen.getByRole('button', { name: /save/i }));

  // Assert（検証）
  expect(handleUpdate).toHaveBeenCalledWith({ name: 'New Name' });
});
```

### テスト名規約

```tsx
describe('ComponentName', () => {
  describe('when [condition]', () => {
    it('should [expected behavior]', () => {});
  });

  // または
  it('renders correctly', () => {});
  it('calls onClick when button is clicked', () => {});
  it('shows error message when validation fails', () => {});
});
```

### 避けるべきパターン

```tsx
// ❌ 実装詳細のテスト
expect(component.state.isOpen).toBe(true);

// ✅ ユーザー視点のテスト
expect(screen.getByRole('dialog')).toBeVisible();

// ❌ スナップショットの過度な使用
expect(container).toMatchSnapshot();

// ✅ 特定の要素の検証
expect(screen.getByRole('heading')).toHaveTextContent('Title');
```
