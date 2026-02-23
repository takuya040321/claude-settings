# 状態管理ガイド

react-components スキルの補足リファレンス。

## 状態の種類と配置

| 状態の種類 | 配置 | ツール |
|-----------|------|--------|
| UIローカル状態 | コンポーネント内 | useState, useReducer |
| 共有UI状態 | 最近共通祖先 | Context, Zustand |
| サーバー状態 | キャッシュ | TanStack Query, SWR |
| URL状態 | URL | React Router, TanStack Router |
| フォーム状態 | フォーム | React Hook Form, Formik |

## TanStack Query

サーバー状態管理のスタンダード。

### セットアップ

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5分
      retry: 1,
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router />
    </QueryClientProvider>
  );
}
```

### 基本的なクエリ

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// データ取得
function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const res = await fetch('/api/users');
      if (!res.ok) throw new Error('Failed to fetch');
      return res.json();
    },
  });
}

// 単一リソース
function useUser(userId: string) {
  return useQuery({
    queryKey: ['users', userId],
    queryFn: () => fetchUser(userId),
    enabled: !!userId, // userIdがある時のみ実行
  });
}

// 使用例
function UserList() {
  const { data: users, isLoading, error } = useUsers();

  if (isLoading) return <Spinner />;
  if (error) return <Error message={error.message} />;

  return (
    <ul>
      {users.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

### ミューテーション

```tsx
function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: CreateUserInput) => {
      const res = await fetch('/api/users', {
        method: 'POST',
        body: JSON.stringify(data),
      });
      return res.json();
    },
    onSuccess: () => {
      // キャッシュを無効化
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}

// 使用例
function CreateUserForm() {
  const { mutate, isPending } = useCreateUser();

  const handleSubmit = (data: CreateUserInput) => {
    mutate(data);
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* フォーム内容 */}
      <button disabled={isPending}>
        {isPending ? 'Creating...' : 'Create'}
      </button>
    </form>
  );
}
```

### Optimistic Updates

```tsx
function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: updateUser,
    onMutate: async (newUser) => {
      // 進行中のクエリをキャンセル
      await queryClient.cancelQueries({ queryKey: ['users', newUser.id] });

      // 以前の値を保存
      const previousUser = queryClient.getQueryData(['users', newUser.id]);

      // 楽観的に更新
      queryClient.setQueryData(['users', newUser.id], newUser);

      return { previousUser };
    },
    onError: (err, newUser, context) => {
      // エラー時はロールバック
      queryClient.setQueryData(
        ['users', newUser.id],
        context?.previousUser
      );
    },
    onSettled: (data, error, variables) => {
      // 常に再フェッチ
      queryClient.invalidateQueries({ queryKey: ['users', variables.id] });
    },
  });
}
```

## Zustand

シンプルな状態管理ライブラリ。

### 基本的なストア

```tsx
import { create } from 'zustand';

interface CounterState {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

const useCounterStore = create<CounterState>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));

// 使用例
function Counter() {
  const count = useCounterStore((state) => state.count);
  const increment = useCounterStore((state) => state.increment);

  return (
    <div>
      <p>{count}</p>
      <button onClick={increment}>+</button>
    </div>
  );
}
```

### 永続化

```tsx
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface SettingsState {
  theme: 'light' | 'dark';
  setTheme: (theme: 'light' | 'dark') => void;
}

const useSettingsStore = create<SettingsState>()(
  persist(
    (set) => ({
      theme: 'light',
      setTheme: (theme) => set({ theme }),
    }),
    {
      name: 'settings-storage',
    }
  )
);
```

### セレクタで最適化

```tsx
// 必要な値だけ購読
const count = useCounterStore((state) => state.count);
const { increment, decrement } = useCounterStore((state) => ({
  increment: state.increment,
  decrement: state.decrement,
}));

// shallow を使って複数値
import { useShallow } from 'zustand/react/shallow';

const { count, total } = useCounterStore(
  useShallow((state) => ({
    count: state.count,
    total: state.total,
  }))
);
```

## Jotai

アトミックな状態管理。

### 基本的なアトム

```tsx
import { atom, useAtom, useAtomValue, useSetAtom } from 'jotai';

// プリミティブアトム
const countAtom = atom(0);

// 派生アトム（読み取り専用）
const doubleCountAtom = atom((get) => get(countAtom) * 2);

// 書き込み可能な派生アトム
const incrementAtom = atom(
  null,
  (get, set) => set(countAtom, get(countAtom) + 1)
);

// 使用例
function Counter() {
  const [count, setCount] = useAtom(countAtom);
  const doubleCount = useAtomValue(doubleCountAtom);
  const increment = useSetAtom(incrementAtom);

  return (
    <div>
      <p>Count: {count}</p>
      <p>Double: {doubleCount}</p>
      <button onClick={increment}>+</button>
    </div>
  );
}
```

### 非同期アトム

```tsx
const userAtom = atom(async () => {
  const response = await fetch('/api/user');
  return response.json();
});

function User() {
  const user = useAtomValue(userAtom);
  return <div>{user.name}</div>;
}

// Suspense でラップ
<Suspense fallback={<Spinner />}>
  <User />
</Suspense>
```

## React Router URL状態

URLをシングルソースオブトゥルースとして使用。

### useSearchParams

```tsx
import { useSearchParams } from 'react-router-dom';

function ProductList() {
  const [searchParams, setSearchParams] = useSearchParams();

  const page = Number(searchParams.get('page')) || 1;
  const category = searchParams.get('category') || 'all';
  const sortBy = searchParams.get('sort') || 'name';

  const handlePageChange = (newPage: number) => {
    setSearchParams((prev) => {
      prev.set('page', String(newPage));
      return prev;
    });
  };

  const handleFilterChange = (newCategory: string) => {
    setSearchParams((prev) => {
      prev.set('category', newCategory);
      prev.set('page', '1'); // フィルタ変更時はページをリセット
      return prev;
    });
  };

  return (
    <div>
      <Filters category={category} onChange={handleFilterChange} />
      <ProductGrid page={page} category={category} sortBy={sortBy} />
      <Pagination page={page} onChange={handlePageChange} />
    </div>
  );
}
```

### カスタムフック化

```tsx
function useQueryParams<T extends Record<string, string>>(
  defaults: T
): [T, (updates: Partial<T>) => void] {
  const [searchParams, setSearchParams] = useSearchParams();

  const params = useMemo(() => {
    const result = { ...defaults };
    for (const key of Object.keys(defaults)) {
      const value = searchParams.get(key);
      if (value !== null) {
        result[key as keyof T] = value as T[keyof T];
      }
    }
    return result;
  }, [searchParams, defaults]);

  const setParams = useCallback(
    (updates: Partial<T>) => {
      setSearchParams((prev) => {
        for (const [key, value] of Object.entries(updates)) {
          if (value === null || value === undefined) {
            prev.delete(key);
          } else {
            prev.set(key, String(value));
          }
        }
        return prev;
      });
    },
    [setSearchParams]
  );

  return [params, setParams];
}

// 使用例
function ProductList() {
  const [params, setParams] = useQueryParams({
    page: '1',
    category: 'all',
    sort: 'name',
  });

  return (
    <div>
      <button onClick={() => setParams({ page: '2' })}>
        Next Page
      </button>
    </div>
  );
}
```

## React Hook Form

フォーム状態管理。

### 基本的な使用

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'At least 8 characters'),
});

type FormData = z.infer<typeof schema>;

function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    await login(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <input {...register('email')} placeholder="Email" />
        {errors.email && <p>{errors.email.message}</p>}
      </div>

      <div>
        <input
          {...register('password')}
          type="password"
          placeholder="Password"
        />
        {errors.password && <p>{errors.password.message}</p>}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
}
```

### shadcn/ui との統合

```tsx
import { useForm } from 'react-hook-form';
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';

function LoginForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { email: '', password: '' },
  });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input placeholder="email@example.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Password</FormLabel>
              <FormControl>
                <Input type="password" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit">Login</Button>
      </form>
    </Form>
  );
}
```

## 状態管理選択フローチャート

```
状態はサーバーから来る？
├─ Yes → TanStack Query / SWR
└─ No
    ├─ URLに反映すべき？
    │   └─ Yes → useSearchParams / TanStack Router
    └─ No
        ├─ 単一コンポーネント内？
        │   └─ Yes → useState / useReducer
        └─ No
            ├─ 複数コンポーネントで共有？
            │   ├─ 少数のコンポーネント → Context + useReducer
            │   └─ 多数のコンポーネント → Zustand / Jotai
            └─ フォーム？
                └─ Yes → React Hook Form
```

## ベストプラクティス

1. **状態を最小限に**: 派生可能な値は保存しない
2. **状態を適切な場所に**: 必要な最も近い場所に配置
3. **不変性を保つ**: 直接変更せず新しいオブジェクトを作成
4. **正規化**: ネストしたデータは ID でフラット化
5. **分離**: UI状態とサーバー状態は別管理
