---
name: react-components
description: Reactコンポーネント設計とUI開発のベストプラクティス。コンポーネント設計パターン、カスタムHooksの作成、状態管理の設計、UIライブラリ活用のガイド。ユーザーが「再利用可能なコンポーネント」「カスタムフックを作成して」「状態管理をどうすべきか」などと依頼した場合にトリガー。
---

# React Components

Reactコンポーネント設計とUI開発のベストプラクティスを提供する。

詳細なパターンは `references/` を参照：
- `component-patterns.md` - 高度なコンポーネントパターン
- `hooks-patterns.md` - カスタムHooksパターン集
- `state-management.md` - 状態管理ガイド

## コンポーネント設計パターン

### Presentational / Container

```tsx
// Presentational: 見た目のみ
interface UserCardProps {
  name: string;
  email: string;
  avatarUrl: string;
}

export function UserCard({ name, email, avatarUrl }: UserCardProps) {
  return (
    <div className="rounded-lg border p-4">
      <img src={avatarUrl} alt={name} className="h-16 w-16 rounded-full" />
      <h3 className="text-lg font-bold">{name}</h3>
      <p className="text-gray-600">{email}</p>
    </div>
  );
}

// Container: ロジック担当
export function UserCardContainer({ userId }: { userId: string }) {
  const { data: user, isLoading } = useUser(userId);

  if (isLoading) return <Skeleton />;
  if (!user) return null;

  return <UserCard name={user.name} email={user.email} avatarUrl={user.avatarUrl} />;
}
```

### Compound Components

```tsx
interface TabsContextType {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const TabsContext = createContext<TabsContextType | null>(null);

function Tabs({ children, defaultTab }: { children: ReactNode; defaultTab: string }) {
  const [activeTab, setActiveTab] = useState(defaultTab);

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

function TabList({ children }: { children: ReactNode }) {
  return <div className="flex border-b">{children}</div>;
}

function Tab({ value, children }: { value: string; children: ReactNode }) {
  const context = useContext(TabsContext);
  if (!context) throw new Error('Tab must be used within Tabs');

  const isActive = context.activeTab === value;

  return (
    <button
      className={cn('px-4 py-2', isActive && 'border-b-2 border-blue-500')}
      onClick={() => context.setActiveTab(value)}
    >
      {children}
    </button>
  );
}

function TabPanel({ value, children }: { value: string; children: ReactNode }) {
  const context = useContext(TabsContext);
  if (!context) throw new Error('TabPanel must be used within Tabs');

  if (context.activeTab !== value) return null;
  return <div className="p-4">{children}</div>;
}

// 使用例
Tabs.List = TabList;
Tabs.Tab = Tab;
Tabs.Panel = TabPanel;

<Tabs defaultTab="tab1">
  <Tabs.List>
    <Tabs.Tab value="tab1">Tab 1</Tabs.Tab>
    <Tabs.Tab value="tab2">Tab 2</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel value="tab1">Content 1</Tabs.Panel>
  <Tabs.Panel value="tab2">Content 2</Tabs.Panel>
</Tabs>
```

### Render Props

```tsx
interface MouseTrackerProps {
  render: (position: { x: number; y: number }) => ReactNode;
}

function MouseTracker({ render }: MouseTrackerProps) {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    const handleMove = (e: MouseEvent) => {
      setPosition({ x: e.clientX, y: e.clientY });
    };
    window.addEventListener('mousemove', handleMove);
    return () => window.removeEventListener('mousemove', handleMove);
  }, []);

  return <>{render(position)}</>;
}

// 使用例
<MouseTracker render={({ x, y }) => <p>Position: {x}, {y}</p>} />
```

### Higher-Order Component (HOC)

```tsx
function withAuth<P extends object>(Component: ComponentType<P>) {
  return function AuthenticatedComponent(props: P) {
    const { isAuthenticated, isLoading } = useAuth();

    if (isLoading) return <Spinner />;
    if (!isAuthenticated) return <Redirect to="/login" />;

    return <Component {...props} />;
  };
}

// 使用例
const ProtectedDashboard = withAuth(Dashboard);
```

## カスタムHooks

### useToggle

```tsx
function useToggle(initialValue = false): [boolean, () => void] {
  const [value, setValue] = useState(initialValue);
  const toggle = useCallback(() => setValue((v) => !v), []);
  return [value, toggle];
}

// 使用例
const [isOpen, toggleOpen] = useToggle(false);
```

### useFetch

```tsx
interface UseFetchResult<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
  refetch: () => void;
}

function useFetch<T>(url: string): UseFetchResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error('Fetch failed');
      const json = await response.json();
      setData(json);
    } catch (e) {
      setError(e instanceof Error ? e : new Error('Unknown error'));
    } finally {
      setLoading(false);
    }
  }, [url]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return { data, loading, error, refetch: fetchData };
}
```

### useForm

```tsx
function useForm<T extends Record<string, unknown>>(initialValues: T) {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});

  const handleChange = useCallback((
    e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setValues((prev) => ({ ...prev, [name]: value }));
  }, []);

  const reset = useCallback(() => {
    setValues(initialValues);
    setErrors({});
  }, [initialValues]);

  return { values, errors, setErrors, handleChange, reset };
}
```

### useLocalStorage

```tsx
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = useCallback((value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  }, [key, storedValue]);

  return [storedValue, setValue] as const;
}
```

### useMediaQuery

```tsx
function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() => {
    if (typeof window === 'undefined') return false;
    return window.matchMedia(query).matches;
  });

  useEffect(() => {
    const mediaQuery = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);

    mediaQuery.addEventListener('change', handler);
    return () => mediaQuery.removeEventListener('change', handler);
  }, [query]);

  return matches;
}

// 使用例
const isMobile = useMediaQuery('(max-width: 768px)');
```

## 状態管理

### useState（ローカル状態）

```tsx
// シンプルな状態
const [count, setCount] = useState(0);

// オブジェクト状態
const [form, setForm] = useState({ name: '', email: '' });
setForm((prev) => ({ ...prev, name: 'John' }));
```

### useReducer（複雑な状態）

```tsx
type State = { count: number; step: number };
type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'setStep'; payload: number };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + state.step };
    case 'decrement':
      return { ...state, count: state.count - state.step };
    case 'setStep':
      return { ...state, step: action.payload };
    default:
      return state;
  }
}

const [state, dispatch] = useReducer(reducer, { count: 0, step: 1 });
```

### Context（グローバル状態）

```tsx
interface ThemeContextType {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  const toggleTheme = useCallback(() => {
    setTheme((t) => (t === 'light' ? 'dark' : 'light'));
  }, []);

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
}
```

### Zustand（軽量ストア）

```tsx
import { create } from 'zustand';

interface CounterStore {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

const useCounterStore = create<CounterStore>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));

// 使用例
function Counter() {
  const { count, increment, decrement } = useCounterStore();
  return (
    <div>
      <p>{count}</p>
      <button onClick={increment}>+</button>
      <button onClick={decrement}>-</button>
    </div>
  );
}
```

## UIライブラリ連携

### shadcn/ui

```bash
# 初期化
npx shadcn@latest init

# コンポーネント追加
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add dialog
```

```tsx
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

function MyComponent() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Title</CardTitle>
      </CardHeader>
      <CardContent>
        <Button variant="outline">Click me</Button>
      </CardContent>
    </Card>
  );
}
```

### Tailwind CSS

```tsx
// cn ユーティリティ
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// 使用例
function Button({ className, variant, ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        'rounded-md px-4 py-2 font-medium',
        variant === 'primary' && 'bg-blue-500 text-white',
        variant === 'secondary' && 'bg-gray-200 text-gray-800',
        className
      )}
      {...props}
    />
  );
}
```

## 設計チェックリスト

### コンポーネント

- [ ] 単一責任の原則に従っているか
- [ ] Props は明確で最小限か
- [ ] デフォルト値は適切か
- [ ] エラー状態を考慮しているか
- [ ] ローディング状態を考慮しているか
- [ ] アクセシビリティ対応しているか

### カスタムHooks

- [ ] `use` プレフィックスがついているか
- [ ] 副作用のクリーンアップは適切か
- [ ] 依存配列は正しいか
- [ ] 戻り値の型は明確か
- [ ] エラーハンドリングしているか

### 状態管理

- [ ] 状態の配置は適切か（ローカル/グローバル）
- [ ] 状態の更新は不変か
- [ ] 不要な再レンダリングがないか
- [ ] 派生状態は useMemo で計算しているか
