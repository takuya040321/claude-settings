# コンポーネントパターン詳細

react-components スキルの補足リファレンス。

## Controlled / Uncontrolled コンポーネント

### Controlled Component

親が状態を完全に制御する。

```tsx
interface ControlledInputProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
}

function ControlledInput({ value, onChange, placeholder }: ControlledInputProps) {
  return (
    <input
      type="text"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
    />
  );
}

// 親コンポーネント
function Parent() {
  const [name, setName] = useState('');

  return <ControlledInput value={name} onChange={setName} />;
}
```

### Uncontrolled Component

内部で状態を持つ。ref で値にアクセス。

```tsx
interface UncontrolledInputProps {
  defaultValue?: string;
  placeholder?: string;
}

const UncontrolledInput = forwardRef<HTMLInputElement, UncontrolledInputProps>(
  ({ defaultValue, placeholder }, ref) => {
    return (
      <input
        type="text"
        ref={ref}
        defaultValue={defaultValue}
        placeholder={placeholder}
      />
    );
  }
);

// 親コンポーネント
function Parent() {
  const inputRef = useRef<HTMLInputElement>(null);

  const handleSubmit = () => {
    console.log(inputRef.current?.value);
  };

  return (
    <>
      <UncontrolledInput ref={inputRef} defaultValue="initial" />
      <button onClick={handleSubmit}>Submit</button>
    </>
  );
}
```

### ハイブリッドパターン

両方をサポートする柔軟なコンポーネント。

```tsx
interface InputProps {
  value?: string;
  defaultValue?: string;
  onChange?: (value: string) => void;
}

function Input({ value, defaultValue, onChange }: InputProps) {
  const [internalValue, setInternalValue] = useState(defaultValue ?? '');
  const isControlled = value !== undefined;
  const currentValue = isControlled ? value : internalValue;

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    if (!isControlled) {
      setInternalValue(e.target.value);
    }
    onChange?.(e.target.value);
  };

  return (
    <input
      type="text"
      value={currentValue}
      onChange={handleChange}
    />
  );
}
```

## Polymorphic Component

`as` prop でレンダリング要素を変更可能。

```tsx
type AsProp<C extends ElementType> = {
  as?: C;
};

type PropsToOmit<C extends ElementType, P> = keyof (AsProp<C> & P);

type PolymorphicComponentProps<
  C extends ElementType,
  Props = object
> = PropsWithChildren<Props & AsProp<C>> &
  Omit<ComponentPropsWithoutRef<C>, PropsToOmit<C, Props>>;

interface ButtonBaseProps {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
}

type ButtonProps<C extends ElementType = 'button'> = PolymorphicComponentProps<
  C,
  ButtonBaseProps
>;

function Button<C extends ElementType = 'button'>({
  as,
  variant = 'primary',
  size = 'md',
  children,
  ...props
}: ButtonProps<C>) {
  const Component = as || 'button';

  return (
    <Component
      className={cn(
        'rounded font-medium',
        variant === 'primary' && 'bg-blue-500 text-white',
        variant === 'secondary' && 'bg-gray-200',
        size === 'sm' && 'px-2 py-1 text-sm',
        size === 'md' && 'px-4 py-2',
        size === 'lg' && 'px-6 py-3 text-lg'
      )}
      {...props}
    >
      {children}
    </Component>
  );
}

// 使用例
<Button>Default button</Button>
<Button as="a" href="/home">Link button</Button>
<Button as={Link} to="/dashboard">Router Link</Button>
```

## Slot Pattern

children を操作・拡張するパターン。

```tsx
import { Children, cloneElement, isValidElement } from 'react';

interface SlotProps {
  children: ReactNode;
  className?: string;
}

function Slot({ children, className }: SlotProps) {
  if (isValidElement(children)) {
    return cloneElement(children, {
      ...children.props,
      className: cn(children.props.className, className),
    });
  }

  return <>{children}</>;
}

// 使用例：子要素にスタイルを注入
function Trigger({ children }: { children: ReactNode }) {
  return (
    <Slot className="cursor-pointer hover:opacity-80">
      {children}
    </Slot>
  );
}

<Trigger>
  <button className="bg-blue-500">Click me</button>
</Trigger>
// 結果: <button className="bg-blue-500 cursor-pointer hover:opacity-80">
```

## Headless Component

ロジックのみ提供し、UIは利用側が決定。

```tsx
interface UseDisclosureReturn {
  isOpen: boolean;
  onOpen: () => void;
  onClose: () => void;
  onToggle: () => void;
}

function useDisclosure(defaultOpen = false): UseDisclosureReturn {
  const [isOpen, setIsOpen] = useState(defaultOpen);

  return {
    isOpen,
    onOpen: () => setIsOpen(true),
    onClose: () => setIsOpen(false),
    onToggle: () => setIsOpen((prev) => !prev),
  };
}

// Headless Disclosure コンポーネント
interface DisclosureProps {
  children: (props: UseDisclosureReturn) => ReactNode;
  defaultOpen?: boolean;
}

function Disclosure({ children, defaultOpen }: DisclosureProps) {
  const disclosure = useDisclosure(defaultOpen);
  return <>{children(disclosure)}</>;
}

// 使用例：UIは利用側で自由に決定
<Disclosure>
  {({ isOpen, onToggle }) => (
    <div>
      <button onClick={onToggle}>
        {isOpen ? 'Hide' : 'Show'}
      </button>
      {isOpen && <div>Content here</div>}
    </div>
  )}
</Disclosure>
```

## Provider Pattern

Context を使った依存注入。

```tsx
// 型定義
interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isLoading: boolean;
}

// Context 作成
const AuthContext = createContext<AuthContextType | null>(null);

// Provider 実装
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // 初期化時に認証状態を確認
    checkAuth().then(setUser).finally(() => setIsLoading(false));
  }, []);

  const login = async (email: string, password: string) => {
    const user = await authService.login(email, password);
    setUser(user);
  };

  const logout = () => {
    authService.logout();
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
}

// カスタムフック
export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}

// 使用例
function App() {
  return (
    <AuthProvider>
      <Router />
    </AuthProvider>
  );
}

function Profile() {
  const { user, logout } = useAuth();
  return <div>Welcome, {user?.name}</div>;
}
```

## Composition Pattern

小さなコンポーネントを組み合わせる。

```tsx
// 基本コンポーネント
function Card({ children, className }: { children: ReactNode; className?: string }) {
  return <div className={cn('rounded-lg border bg-white', className)}>{children}</div>;
}

function CardHeader({ children }: { children: ReactNode }) {
  return <div className="border-b p-4">{children}</div>;
}

function CardTitle({ children }: { children: ReactNode }) {
  return <h3 className="text-lg font-semibold">{children}</h3>;
}

function CardContent({ children }: { children: ReactNode }) {
  return <div className="p-4">{children}</div>;
}

function CardFooter({ children }: { children: ReactNode }) {
  return <div className="border-t p-4">{children}</div>;
}

// 名前空間として組み立て
Card.Header = CardHeader;
Card.Title = CardTitle;
Card.Content = CardContent;
Card.Footer = CardFooter;

// 使用例
<Card>
  <Card.Header>
    <Card.Title>User Profile</Card.Title>
  </Card.Header>
  <Card.Content>
    <p>User information here</p>
  </Card.Content>
  <Card.Footer>
    <Button>Save</Button>
  </Card.Footer>
</Card>
```

## forwardRef パターン

ref を子コンポーネントに転送。

```tsx
interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, className, ...props }, ref) => {
    const id = useId();

    return (
      <div className="space-y-1">
        {label && (
          <label htmlFor={id} className="text-sm font-medium">
            {label}
          </label>
        )}
        <input
          id={id}
          ref={ref}
          className={cn(
            'w-full rounded border px-3 py-2',
            error && 'border-red-500',
            className
          )}
          {...props}
        />
        {error && <p className="text-sm text-red-500">{error}</p>}
      </div>
    );
  }
);

Input.displayName = 'Input';

// 使用例
function Form() {
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  return <Input ref={inputRef} label="Name" />;
}
```

## パターン選択ガイド

| 要件 | 推奨パターン |
|------|-------------|
| 親が値を制御 | Controlled |
| 内部で状態管理 | Uncontrolled |
| 要素タイプを変更可能に | Polymorphic |
| 関連コンポーネントをグループ化 | Compound/Composition |
| ロジックのみ提供 | Headless |
| アプリ全体で状態共有 | Provider |
| DOM要素にアクセス | forwardRef |
