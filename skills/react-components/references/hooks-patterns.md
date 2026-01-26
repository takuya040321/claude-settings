# カスタムHooksパターン集

react-components スキルの補足リファレンス。

## useDebounce

入力値のデバウンス処理。

```tsx
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
}

// 使用例：検索入力
function SearchInput() {
  const [query, setQuery] = useState('');
  const debouncedQuery = useDebounce(query, 300);

  useEffect(() => {
    if (debouncedQuery) {
      searchApi(debouncedQuery);
    }
  }, [debouncedQuery]);

  return (
    <input
      value={query}
      onChange={(e) => setQuery(e.target.value)}
      placeholder="Search..."
    />
  );
}
```

## useThrottle

値のスロットリング。

```tsx
function useThrottle<T>(value: T, interval: number): T {
  const [throttledValue, setThrottledValue] = useState<T>(value);
  const lastUpdated = useRef<number>(Date.now());

  useEffect(() => {
    const now = Date.now();

    if (now >= lastUpdated.current + interval) {
      lastUpdated.current = now;
      setThrottledValue(value);
    } else {
      const timer = setTimeout(() => {
        lastUpdated.current = Date.now();
        setThrottledValue(value);
      }, interval - (now - lastUpdated.current));

      return () => clearTimeout(timer);
    }
  }, [value, interval]);

  return throttledValue;
}
```

## useClickOutside

要素外クリックの検知。

```tsx
function useClickOutside<T extends HTMLElement>(
  handler: () => void
): RefObject<T> {
  const ref = useRef<T>(null);

  useEffect(() => {
    const listener = (event: MouseEvent | TouchEvent) => {
      if (!ref.current || ref.current.contains(event.target as Node)) {
        return;
      }
      handler();
    };

    document.addEventListener('mousedown', listener);
    document.addEventListener('touchstart', listener);

    return () => {
      document.removeEventListener('mousedown', listener);
      document.removeEventListener('touchstart', listener);
    };
  }, [handler]);

  return ref;
}

// 使用例：ドロップダウン
function Dropdown() {
  const [isOpen, setIsOpen] = useState(false);
  const ref = useClickOutside<HTMLDivElement>(() => setIsOpen(false));

  return (
    <div ref={ref}>
      <button onClick={() => setIsOpen(true)}>Open</button>
      {isOpen && <div className="dropdown-menu">Menu content</div>}
    </div>
  );
}
```

## useIntersectionObserver

要素の可視性を監視。

```tsx
interface UseIntersectionObserverOptions {
  threshold?: number | number[];
  root?: Element | null;
  rootMargin?: string;
  freezeOnceVisible?: boolean;
}

function useIntersectionObserver(
  options: UseIntersectionObserverOptions = {}
): [RefCallback<Element>, IntersectionObserverEntry | undefined] {
  const {
    threshold = 0,
    root = null,
    rootMargin = '0px',
    freezeOnceVisible = false,
  } = options;

  const [entry, setEntry] = useState<IntersectionObserverEntry>();
  const [node, setNode] = useState<Element | null>(null);

  const frozen = entry?.isIntersecting && freezeOnceVisible;

  useEffect(() => {
    if (!node || frozen) return;

    const observer = new IntersectionObserver(
      ([entry]) => setEntry(entry),
      { threshold, root, rootMargin }
    );

    observer.observe(node);

    return () => observer.disconnect();
  }, [node, threshold, root, rootMargin, frozen]);

  return [setNode, entry];
}

// 使用例：遅延ロード
function LazyImage({ src, alt }: { src: string; alt: string }) {
  const [ref, entry] = useIntersectionObserver({
    threshold: 0.1,
    freezeOnceVisible: true,
  });

  return (
    <div ref={ref}>
      {entry?.isIntersecting ? (
        <img src={src} alt={alt} />
      ) : (
        <div className="h-48 w-full bg-gray-200" />
      )}
    </div>
  );
}
```

## usePrevious

前回の値を保持。

```tsx
function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>();

  useEffect(() => {
    ref.current = value;
  }, [value]);

  return ref.current;
}

// 使用例：値の変化を比較
function Counter({ count }: { count: number }) {
  const prevCount = usePrevious(count);

  return (
    <div>
      <p>Current: {count}</p>
      <p>Previous: {prevCount}</p>
      <p>
        {count > (prevCount ?? 0) ? 'Increased' : 'Decreased or same'}
      </p>
    </div>
  );
}
```

## useWindowSize

ウィンドウサイズの監視。

```tsx
interface WindowSize {
  width: number;
  height: number;
}

function useWindowSize(): WindowSize {
  const [size, setSize] = useState<WindowSize>({
    width: typeof window !== 'undefined' ? window.innerWidth : 0,
    height: typeof window !== 'undefined' ? window.innerHeight : 0,
  });

  useEffect(() => {
    const handleResize = () => {
      setSize({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return size;
}

// 使用例
function ResponsiveComponent() {
  const { width } = useWindowSize();

  if (width < 768) {
    return <MobileView />;
  }
  return <DesktopView />;
}
```

## useEventListener

イベントリスナーの管理。

```tsx
function useEventListener<K extends keyof WindowEventMap>(
  eventName: K,
  handler: (event: WindowEventMap[K]) => void,
  element?: Window | HTMLElement | null
): void {
  const savedHandler = useRef(handler);

  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  useEffect(() => {
    const targetElement = element ?? window;

    const eventListener = (event: Event) => {
      savedHandler.current(event as WindowEventMap[K]);
    };

    targetElement.addEventListener(eventName, eventListener);

    return () => {
      targetElement.removeEventListener(eventName, eventListener);
    };
  }, [eventName, element]);
}

// 使用例：キーボードショートカット
function App() {
  useEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      closeModal();
    }
    if (e.metaKey && e.key === 'k') {
      e.preventDefault();
      openCommandPalette();
    }
  });

  return <div>...</div>;
}
```

## useAsync

非同期操作の状態管理。

```tsx
interface AsyncState<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
}

type AsyncFunction<T, Args extends unknown[]> = (...args: Args) => Promise<T>;

function useAsync<T, Args extends unknown[]>(
  asyncFunction: AsyncFunction<T, Args>
): [AsyncState<T>, (...args: Args) => Promise<void>] {
  const [state, setState] = useState<AsyncState<T>>({
    data: null,
    loading: false,
    error: null,
  });

  const execute = useCallback(
    async (...args: Args) => {
      setState({ data: null, loading: true, error: null });

      try {
        const data = await asyncFunction(...args);
        setState({ data, loading: false, error: null });
      } catch (error) {
        setState({
          data: null,
          loading: false,
          error: error instanceof Error ? error : new Error('Unknown error'),
        });
      }
    },
    [asyncFunction]
  );

  return [state, execute];
}

// 使用例
function UserProfile({ userId }: { userId: string }) {
  const [{ data: user, loading, error }, fetchUser] = useAsync(
    async (id: string) => {
      const response = await fetch(`/api/users/${id}`);
      return response.json();
    }
  );

  useEffect(() => {
    fetchUser(userId);
  }, [userId, fetchUser]);

  if (loading) return <Spinner />;
  if (error) return <Error message={error.message} />;
  if (!user) return null;

  return <div>{user.name}</div>;
}
```

## useCopyToClipboard

クリップボードへのコピー。

```tsx
interface CopyState {
  copied: boolean;
  error: Error | null;
}

function useCopyToClipboard(): [CopyState, (text: string) => Promise<void>] {
  const [state, setState] = useState<CopyState>({
    copied: false,
    error: null,
  });

  const copy = useCallback(async (text: string) => {
    try {
      await navigator.clipboard.writeText(text);
      setState({ copied: true, error: null });

      // 2秒後にリセット
      setTimeout(() => {
        setState((prev) => ({ ...prev, copied: false }));
      }, 2000);
    } catch (error) {
      setState({
        copied: false,
        error: error instanceof Error ? error : new Error('Copy failed'),
      });
    }
  }, []);

  return [state, copy];
}

// 使用例
function CopyButton({ text }: { text: string }) {
  const [{ copied }, copy] = useCopyToClipboard();

  return (
    <button onClick={() => copy(text)}>
      {copied ? 'Copied!' : 'Copy'}
    </button>
  );
}
```

## useOnMount / useOnUnmount

マウント/アンマウント時の処理。

```tsx
function useOnMount(callback: EffectCallback): void {
  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(callback, []);
}

function useOnUnmount(callback: () => void): void {
  const callbackRef = useRef(callback);
  callbackRef.current = callback;

  useEffect(() => {
    return () => callbackRef.current();
  }, []);
}

// 使用例
function Component() {
  useOnMount(() => {
    console.log('Mounted');
    analytics.trackPageView();
  });

  useOnUnmount(() => {
    console.log('Unmounting');
    cleanup();
  });

  return <div>...</div>;
}
```

## useInterval

setInterval のフック化。

```tsx
function useInterval(callback: () => void, delay: number | null): void {
  const savedCallback = useRef(callback);

  useEffect(() => {
    savedCallback.current = callback;
  }, [callback]);

  useEffect(() => {
    if (delay === null) return;

    const id = setInterval(() => savedCallback.current(), delay);
    return () => clearInterval(id);
  }, [delay]);
}

// 使用例：カウントダウン
function Countdown({ seconds }: { seconds: number }) {
  const [remaining, setRemaining] = useState(seconds);

  useInterval(
    () => setRemaining((r) => r - 1),
    remaining > 0 ? 1000 : null
  );

  return <div>{remaining}s</div>;
}
```

## Hooks 設計原則

1. **単一責任**: 1つのフックは1つのことだけを行う
2. **構成可能**: 小さなフックを組み合わせて大きなフックを作る
3. **宣言的**: 何をするかを記述し、どうするかは隠蔽
4. **テスト可能**: renderHook でテストできる設計に
5. **型安全**: ジェネリクスを活用して型推論を効かせる
