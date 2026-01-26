---
name: material-ui
description: MUI/Material UI を使用したReactアプリケーション開発ガイド。コンポーネント実装、テーマカスタマイズ、レイアウト構築をサポート。ユーザーが「MUIで」「Material UIで」「マテリアルUI」「MUIコンポーネント」「MUIテーマ」「MUIレイアウト」「sx prop」「createTheme」「Grid2」などと依頼した場合にトリガー。
---

# Material UI (MUI)

GoogleのMaterial Designを実装したReact UIライブラリ。v5/v6両対応。

## セットアップ

### v5（現行安定版）
```bash
npm install @mui/material @emotion/react @emotion/styled
npm install @mui/icons-material  # アイコン
npm install @mui/x-data-grid     # DataGrid（オプション）
```

### v6（最新）
```bash
npm install @mui/material@next @emotion/react @emotion/styled
npm install @mui/icons-material@next
```

### 基本設定（App.tsx）
```tsx
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: { main: '#1976d2' },
    secondary: { main: '#9c27b0' },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      {/* アプリケーション */}
    </ThemeProvider>
  );
}
```

## 基本パターン

### インポート
```tsx
// 推奨: 名前付きインポート
import { Button, TextField, Box } from '@mui/material';

// アイコン
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
```

### sx prop（インラインスタイル）
```tsx
<Box
  sx={{
    p: 2,              // padding: 16px (8px * 2)
    m: 1,              // margin: 8px
    bgcolor: 'primary.main',
    color: 'white',
    borderRadius: 1,
    '&:hover': { bgcolor: 'primary.dark' },
    // レスポンシブ
    width: { xs: '100%', sm: 400, md: 600 },
  }}
>
  Content
</Box>
```

### styled API
```tsx
import { styled } from '@mui/material/styles';

const StyledButton = styled(Button)(({ theme }) => ({
  backgroundColor: theme.palette.primary.main,
  padding: theme.spacing(2),
  '&:hover': {
    backgroundColor: theme.palette.primary.dark,
  },
}));
```

## v5 vs v6 の違い

| 機能 | v5 | v6 |
|------|-----|-----|
| Grid | `<Grid container item>` | `<Grid2>` 推奨 |
| DatePicker | `@mui/x-date-pickers` | 同じ |
| スタイリング | Emotion (デフォルト) | Pigment CSS 対応 |
| React | 17+ | 18+ 必須 |

### Grid2（v6推奨）への移行
```tsx
// v5: Grid
import Grid from '@mui/material/Grid';
<Grid container spacing={2}>
  <Grid item xs={12} md={6}>...</Grid>
</Grid>

// v6: Grid2（v5でも使用可能）
import Grid from '@mui/material/Grid2';
<Grid container spacing={2}>
  <Grid size={{ xs: 12, md: 6 }}>...</Grid>
</Grid>
```

## ベストプラクティス

### 1. テーマを活用する
ハードコードされた色・サイズを避け、テーマの値を使用する。
```tsx
// ❌ 避ける
<Box sx={{ color: '#1976d2', padding: '16px' }}>

// ✅ 推奨
<Box sx={{ color: 'primary.main', p: 2 }}>
```

### 2. コンポーネントのバリアントを活用
```tsx
// Buttonのバリアント
<Button variant="contained">Primary</Button>
<Button variant="outlined">Secondary</Button>
<Button variant="text">Text</Button>

// TextFieldのバリアント
<TextField variant="outlined" />  // デフォルト
<TextField variant="filled" />
<TextField variant="standard" />
```

### 3. レスポンシブデザイン
```tsx
// ブレークポイント: xs(0), sm(600), md(900), lg(1200), xl(1536)
<Box
  sx={{
    display: { xs: 'none', md: 'block' },  // md以上で表示
    flexDirection: { xs: 'column', sm: 'row' },
  }}
/>
```

### 4. アクセシビリティ
```tsx
// aria-label を適切に設定
<IconButton aria-label="delete">
  <DeleteIcon />
</IconButton>

// フォームのラベル
<TextField
  id="email"
  label="メールアドレス"
  inputProps={{ 'aria-describedby': 'email-helper' }}
/>
<FormHelperText id="email-helper">...</FormHelperText>
```

### 5. パフォーマンス
```tsx
// 動的スタイルはuseMemoで最適化
const dynamicSx = useMemo(() => ({
  bgcolor: isActive ? 'primary.main' : 'grey.300',
}), [isActive]);

// 大量のリストにはvirtualization
import { DataGrid } from '@mui/x-data-grid';
```

## 詳細リファレンス

より詳しい情報は以下のリファレンスを参照してください：

- **コンポーネント詳細**: `references/components.md`
  - Button、TextField、Table、Dialog等の詳細な使用例

- **テーマカスタマイズ**: `references/theming.md`
  - createTheme、パレット、ダークモード、Typography設定

- **レイアウトシステム**: `references/layout.md`
  - Grid/Grid2、Box、Container、Stack、レスポンシブ設計
