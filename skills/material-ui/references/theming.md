# MUI テーマカスタマイズリファレンス

## createTheme 基本

```tsx
import { createTheme, ThemeProvider } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#1976d2',
      light: '#42a5f5',
      dark: '#1565c0',
      contrastText: '#fff',
    },
    secondary: {
      main: '#9c27b0',
    },
    error: {
      main: '#d32f2f',
    },
    warning: {
      main: '#ed6c02',
    },
    info: {
      main: '#0288d1',
    },
    success: {
      main: '#2e7d32',
    },
    background: {
      default: '#fafafa',
      paper: '#fff',
    },
  },
  typography: {
    fontFamily: '"Noto Sans JP", "Roboto", sans-serif',
    h1: {
      fontSize: '2.5rem',
      fontWeight: 700,
    },
  },
  shape: {
    borderRadius: 8,
  },
  spacing: 8, // デフォルト8px (theme.spacing(2) = 16px)
});
```

## カスタムカラーパレット

### ブランドカラーの追加

```tsx
// テーマ型を拡張
declare module '@mui/material/styles' {
  interface Palette {
    brand: Palette['primary'];
  }
  interface PaletteOptions {
    brand?: PaletteOptions['primary'];
  }
}

// Button のカラーオプションを拡張
declare module '@mui/material/Button' {
  interface ButtonPropsColorOverrides {
    brand: true;
  }
}

const theme = createTheme({
  palette: {
    brand: {
      main: '#ff5722',
      light: '#ff8a50',
      dark: '#c41c00',
      contrastText: '#fff',
    },
  },
});

// 使用
<Button color="brand" variant="contained">
  ブランドカラー
</Button>
```

### カラー生成ユーティリティ

```tsx
import { alpha, darken, lighten } from '@mui/material/styles';

// 透明度を調整
<Box sx={{ bgcolor: (theme) => alpha(theme.palette.primary.main, 0.1) }} />

// 明度を調整
<Box sx={{ bgcolor: (theme) => darken(theme.palette.primary.main, 0.2) }} />
<Box sx={{ bgcolor: (theme) => lighten(theme.palette.primary.main, 0.2) }} />
```

## ダークモード

### 基本実装

```tsx
import { useMemo, useState, createContext, useContext } from 'react';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import useMediaQuery from '@mui/material/useMediaQuery';

// カラーモードコンテキスト
const ColorModeContext = createContext({
  toggleColorMode: () => {},
});

export function useColorMode() {
  return useContext(ColorModeContext);
}

export function ThemeProviderWrapper({ children }) {
  // システム設定を検出
  const prefersDarkMode = useMediaQuery('(prefers-color-scheme: dark)');
  const [mode, setMode] = useState<'light' | 'dark'>(
    prefersDarkMode ? 'dark' : 'light'
  );

  const colorMode = useMemo(
    () => ({
      toggleColorMode: () => {
        setMode((prev) => (prev === 'light' ? 'dark' : 'light'));
      },
    }),
    []
  );

  const theme = useMemo(
    () =>
      createTheme({
        palette: {
          mode,
          ...(mode === 'light'
            ? {
                // ライトモード
                primary: { main: '#1976d2' },
                background: { default: '#fafafa', paper: '#fff' },
              }
            : {
                // ダークモード
                primary: { main: '#90caf9' },
                background: { default: '#121212', paper: '#1e1e1e' },
              }),
        },
      }),
    [mode]
  );

  return (
    <ColorModeContext.Provider value={colorMode}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        {children}
      </ThemeProvider>
    </ColorModeContext.Provider>
  );
}
```

### トグルボタン

```tsx
import { IconButton } from '@mui/material';
import { Brightness4, Brightness7 } from '@mui/icons-material';
import { useTheme } from '@mui/material/styles';
import { useColorMode } from './ThemeProvider';

function DarkModeToggle() {
  const theme = useTheme();
  const { toggleColorMode } = useColorMode();

  return (
    <IconButton onClick={toggleColorMode} color="inherit">
      {theme.palette.mode === 'dark' ? <Brightness7 /> : <Brightness4 />}
    </IconButton>
  );
}
```

## タイポグラフィ

### バリアント設定

```tsx
const theme = createTheme({
  typography: {
    fontFamily: '"Noto Sans JP", "Roboto", "Helvetica", "Arial", sans-serif',

    h1: {
      fontSize: '2.5rem',
      fontWeight: 700,
      lineHeight: 1.2,
      letterSpacing: '-0.01em',
    },
    h2: {
      fontSize: '2rem',
      fontWeight: 700,
      lineHeight: 1.3,
    },
    h3: {
      fontSize: '1.75rem',
      fontWeight: 600,
      lineHeight: 1.4,
    },
    h4: {
      fontSize: '1.5rem',
      fontWeight: 600,
      lineHeight: 1.4,
    },
    h5: {
      fontSize: '1.25rem',
      fontWeight: 600,
      lineHeight: 1.5,
    },
    h6: {
      fontSize: '1rem',
      fontWeight: 600,
      lineHeight: 1.5,
    },
    subtitle1: {
      fontSize: '1rem',
      fontWeight: 500,
      lineHeight: 1.75,
    },
    body1: {
      fontSize: '1rem',
      lineHeight: 1.75,
    },
    body2: {
      fontSize: '0.875rem',
      lineHeight: 1.6,
    },
    button: {
      textTransform: 'none', // 大文字変換を無効化
      fontWeight: 600,
    },
    caption: {
      fontSize: '0.75rem',
      lineHeight: 1.5,
    },
  },
});
```

### レスポンシブフォント

```tsx
const theme = createTheme({
  typography: {
    h1: {
      fontSize: '2rem',
      '@media (min-width:600px)': {
        fontSize: '2.5rem',
      },
      '@media (min-width:900px)': {
        fontSize: '3rem',
      },
    },
  },
});

// または responsiveFontSizes ユーティリティを使用
import { responsiveFontSizes } from '@mui/material/styles';

let theme = createTheme({ /* ... */ });
theme = responsiveFontSizes(theme);
```

### カスタムバリアント追加

```tsx
declare module '@mui/material/styles' {
  interface TypographyVariants {
    poster: React.CSSProperties;
  }
  interface TypographyVariantsOptions {
    poster?: React.CSSProperties;
  }
}

declare module '@mui/material/Typography' {
  interface TypographyPropsVariantOverrides {
    poster: true;
  }
}

const theme = createTheme({
  typography: {
    poster: {
      fontSize: '4rem',
      fontWeight: 800,
      lineHeight: 1.1,
    },
  },
});

// 使用
<Typography variant="poster">大見出し</Typography>
```

## コンポーネントスタイルのオーバーライド

### グローバルデフォルトの設定

```tsx
const theme = createTheme({
  components: {
    // Button
    MuiButton: {
      defaultProps: {
        disableElevation: true, // デフォルトでフラット
        variant: 'contained',
      },
      styleOverrides: {
        root: {
          borderRadius: 8,
          textTransform: 'none',
          fontWeight: 600,
          padding: '8px 16px',
        },
        containedPrimary: {
          '&:hover': {
            boxShadow: '0 4px 12px rgba(25, 118, 210, 0.4)',
          },
        },
      },
    },

    // TextField
    MuiTextField: {
      defaultProps: {
        variant: 'outlined',
        size: 'small',
      },
    },

    // Card
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          boxShadow: '0 2px 8px rgba(0, 0, 0, 0.08)',
        },
      },
    },

    // Paper
    MuiPaper: {
      styleOverrides: {
        root: {
          backgroundImage: 'none', // ダークモードのグラデーションを無効化
        },
      },
    },

    // TableCell
    MuiTableCell: {
      styleOverrides: {
        head: {
          fontWeight: 600,
          backgroundColor: '#f5f5f5',
        },
      },
    },

    // Dialog
    MuiDialog: {
      styleOverrides: {
        paper: {
          borderRadius: 16,
        },
      },
    },

    // CssBaseline (グローバルCSS)
    MuiCssBaseline: {
      styleOverrides: {
        body: {
          scrollbarWidth: 'thin',
          '&::-webkit-scrollbar': {
            width: '8px',
            height: '8px',
          },
          '&::-webkit-scrollbar-thumb': {
            backgroundColor: '#c1c1c1',
            borderRadius: '4px',
          },
        },
      },
    },
  },
});
```

### バリアントの追加

```tsx
const theme = createTheme({
  components: {
    MuiButton: {
      variants: [
        {
          props: { variant: 'dashed' },
          style: {
            border: '2px dashed',
            borderColor: 'currentColor',
          },
        },
        {
          props: { variant: 'dashed', color: 'primary' },
          style: {
            borderColor: '#1976d2',
            color: '#1976d2',
          },
        },
      ],
    },
  },
});

// 型拡張
declare module '@mui/material/Button' {
  interface ButtonPropsVariantOverrides {
    dashed: true;
  }
}

// 使用
<Button variant="dashed" color="primary">
  Dashed Button
</Button>
```

## ブレークポイント

### カスタムブレークポイント

```tsx
const theme = createTheme({
  breakpoints: {
    values: {
      xs: 0,
      sm: 600,
      md: 900,
      lg: 1200,
      xl: 1536,
    },
  },
});

// カスタムブレークポイントの追加
declare module '@mui/material/styles' {
  interface BreakpointOverrides {
    xs: true;
    sm: true;
    md: true;
    lg: true;
    xl: true;
    mobile: true;   // 追加
    tablet: true;   // 追加
    desktop: true;  // 追加
  }
}

const theme = createTheme({
  breakpoints: {
    values: {
      xs: 0,
      sm: 600,
      md: 900,
      lg: 1200,
      xl: 1536,
      mobile: 0,
      tablet: 640,
      desktop: 1024,
    },
  },
});
```

### ブレークポイントの使用

```tsx
import { useTheme, useMediaQuery } from '@mui/material';

function ResponsiveComponent() {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const isTablet = useMediaQuery(theme.breakpoints.between('sm', 'md'));
  const isDesktop = useMediaQuery(theme.breakpoints.up('md'));

  return (
    <Box>
      {isMobile && <MobileView />}
      {isTablet && <TabletView />}
      {isDesktop && <DesktopView />}
    </Box>
  );
}
```

## テーマへのアクセス

### useTheme フック

```tsx
import { useTheme } from '@mui/material/styles';

function MyComponent() {
  const theme = useTheme();

  return (
    <Box
      sx={{
        color: theme.palette.primary.main,
        padding: theme.spacing(2),
      }}
    >
      Content
    </Box>
  );
}
```

### sx prop でのテーマアクセス

```tsx
<Box
  sx={(theme) => ({
    bgcolor: theme.palette.mode === 'dark' ? 'grey.900' : 'grey.100',
    p: theme.spacing(2),
    [theme.breakpoints.up('md')]: {
      p: theme.spacing(4),
    },
  })}
>
  Content
</Box>

// ショートハンド
<Box
  sx={{
    bgcolor: 'primary.main',        // theme.palette.primary.main
    color: 'text.secondary',        // theme.palette.text.secondary
    p: 2,                           // theme.spacing(2)
    borderRadius: 1,                // theme.shape.borderRadius
  }}
/>
```

## 複数テーマの適用

```tsx
import { ThemeProvider, createTheme } from '@mui/material/styles';

const outerTheme = createTheme({
  palette: { primary: { main: '#1976d2' } },
});

const innerTheme = createTheme({
  palette: { primary: { main: '#ff5722' } },
});

function App() {
  return (
    <ThemeProvider theme={outerTheme}>
      <Button color="primary">青いボタン</Button>
      <ThemeProvider theme={innerTheme}>
        <Button color="primary">オレンジのボタン</Button>
      </ThemeProvider>
    </ThemeProvider>
  );
}
```
