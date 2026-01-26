# MUI レイアウトシステムリファレンス

## Box

最も基本的なレイアウトコンポーネント。`<div>` のラッパーで sx prop を完全サポート。

```tsx
import { Box } from '@mui/material';

// 基本
<Box sx={{ p: 2, bgcolor: 'background.paper' }}>
  Content
</Box>

// component prop でレンダリング要素を変更
<Box component="section" sx={{ p: 2 }}>
  <Box component="span">Span element</Box>
</Box>

// Flexbox
<Box
  sx={{
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 2,
  }}
>
  <Box>Item 1</Box>
  <Box>Item 2</Box>
</Box>

// レスポンシブ
<Box
  sx={{
    width: { xs: '100%', sm: '50%', md: '33%' },
    display: { xs: 'none', md: 'block' },
    flexDirection: { xs: 'column', sm: 'row' },
  }}
/>
```

## Container

コンテンツを中央寄せし、最大幅を制限するレイアウトコンポーネント。

```tsx
import { Container } from '@mui/material';

// 基本（maxWidth='lg' がデフォルト）
<Container>
  コンテンツ
</Container>

// 最大幅の指定
<Container maxWidth="sm">...</Container>  // max-width: 600px
<Container maxWidth="md">...</Container>  // max-width: 900px
<Container maxWidth="lg">...</Container>  // max-width: 1200px
<Container maxWidth="xl">...</Container>  // max-width: 1536px
<Container maxWidth={false}>...</Container>  // 幅制限なし

// 固定幅モード
<Container fixed>
  ブレークポイントごとに固定幅
</Container>

// パディングなし
<Container disableGutters>
  左右のパディングなし
</Container>
```

## Stack

1次元レイアウト（縦または横）に最適化されたコンポーネント。

```tsx
import { Stack, Divider } from '@mui/material';

// 縦方向（デフォルト）
<Stack spacing={2}>
  <Item>Item 1</Item>
  <Item>Item 2</Item>
  <Item>Item 3</Item>
</Stack>

// 横方向
<Stack direction="row" spacing={2}>
  <Item>Item 1</Item>
  <Item>Item 2</Item>
</Stack>

// レスポンシブ方向
<Stack
  direction={{ xs: 'column', sm: 'row' }}
  spacing={{ xs: 1, sm: 2, md: 4 }}
>
  <Item>Item 1</Item>
  <Item>Item 2</Item>
</Stack>

// 区切り線付き
<Stack
  direction="row"
  divider={<Divider orientation="vertical" flexItem />}
  spacing={2}
>
  <Item>Item 1</Item>
  <Item>Item 2</Item>
  <Item>Item 3</Item>
</Stack>

// 配置
<Stack
  direction="row"
  justifyContent="space-between"
  alignItems="center"
  spacing={2}
>
  <Typography variant="h6">タイトル</Typography>
  <Button>アクション</Button>
</Stack>
```

## Grid（v5）

2次元グリッドレイアウト。12カラムシステム。

```tsx
import Grid from '@mui/material/Grid';

// 基本的な使用
<Grid container spacing={2}>
  <Grid item xs={12}>
    全幅
  </Grid>
  <Grid item xs={12} sm={6}>
    xs: 全幅、sm以上: 半分
  </Grid>
  <Grid item xs={12} sm={6}>
    xs: 全幅、sm以上: 半分
  </Grid>
</Grid>

// 複雑なレイアウト
<Grid container spacing={3}>
  {/* サイドバー */}
  <Grid item xs={12} md={3}>
    <Paper sx={{ p: 2 }}>サイドバー</Paper>
  </Grid>

  {/* メインコンテンツ */}
  <Grid item xs={12} md={9}>
    <Paper sx={{ p: 2 }}>メイン</Paper>
  </Grid>
</Grid>

// ネスト
<Grid container spacing={2}>
  <Grid item xs={12}>
    <Grid container spacing={1}>
      <Grid item xs={4}>A</Grid>
      <Grid item xs={4}>B</Grid>
      <Grid item xs={4}>C</Grid>
    </Grid>
  </Grid>
</Grid>

// 自動幅
<Grid container spacing={2}>
  <Grid item xs="auto">
    コンテンツに合わせた幅
  </Grid>
  <Grid item xs>
    残りのスペースを埋める
  </Grid>
</Grid>

// 配置
<Grid
  container
  direction="row"
  justifyContent="center"
  alignItems="center"
  style={{ minHeight: '100vh' }}
>
  <Grid item>中央配置</Grid>
</Grid>
```

## Grid2（v5.14+ / v6推奨）

Grid の改良版。`item` prop が不要になり、`size` prop で幅を指定。

```tsx
import Grid from '@mui/material/Grid2';

// 基本
<Grid container spacing={2}>
  <Grid size={12}>全幅</Grid>
  <Grid size={6}>半分</Grid>
  <Grid size={6}>半分</Grid>
</Grid>

// レスポンシブ
<Grid container spacing={2}>
  <Grid size={{ xs: 12, sm: 6, md: 4 }}>
    レスポンシブアイテム
  </Grid>
  <Grid size={{ xs: 12, sm: 6, md: 8 }}>
    レスポンシブアイテム
  </Grid>
</Grid>

// 自動幅と残りスペース
<Grid container spacing={2}>
  <Grid size="auto">
    コンテンツ幅
  </Grid>
  <Grid size="grow">
    残りを埋める
  </Grid>
</Grid>

// オフセット
<Grid container spacing={2}>
  <Grid size={6} offset={3}>
    中央寄せ（3カラム分のオフセット）
  </Grid>
</Grid>

// rowSpacing と columnSpacing
<Grid container rowSpacing={2} columnSpacing={4}>
  <Grid size={6}>Item</Grid>
  <Grid size={6}>Item</Grid>
</Grid>
```

### Grid vs Grid2 比較

```tsx
// Grid (v5)
<Grid container spacing={2}>
  <Grid item xs={12} md={6}>Content</Grid>
</Grid>

// Grid2 (v5.14+ / v6)
<Grid container spacing={2}>
  <Grid size={{ xs: 12, md: 6 }}>Content</Grid>
</Grid>
```

## レスポンシブブレークポイント

### デフォルト値

| ブレークポイント | 最小幅 | 説明 |
|-----------------|--------|------|
| xs | 0px | 超小型デバイス（ポートレートモバイル） |
| sm | 600px | 小型デバイス（ランドスケープモバイル） |
| md | 900px | 中型デバイス（タブレット） |
| lg | 1200px | 大型デバイス（デスクトップ） |
| xl | 1536px | 超大型デバイス（大型デスクトップ） |

### sx prop でのレスポンシブ

```tsx
<Box
  sx={{
    // 配列記法（xs, sm, md, lg, xl の順）
    width: [100, 200, 300, 400, 500],

    // オブジェクト記法
    padding: { xs: 1, sm: 2, md: 3 },

    // 特定のブレークポイントのみ
    display: { xs: 'none', md: 'block' },

    // 条件付きスタイル
    flexDirection: { xs: 'column', sm: 'row' },
  }}
/>
```

### useMediaQuery

```tsx
import { useMediaQuery, useTheme } from '@mui/material';

function ResponsiveComponent() {
  const theme = useTheme();

  // up: 指定以上
  const isSmUp = useMediaQuery(theme.breakpoints.up('sm'));      // >= 600px

  // down: 指定未満
  const isSmDown = useMediaQuery(theme.breakpoints.down('sm'));  // < 600px

  // only: 指定のみ
  const isMdOnly = useMediaQuery(theme.breakpoints.only('md'));  // 900-1199px

  // between: 範囲
  const isSmToMd = useMediaQuery(theme.breakpoints.between('sm', 'md'));

  // カスタムクエリ
  const isPortrait = useMediaQuery('(orientation: portrait)');

  return (
    <>
      {isSmDown && <MobileNav />}
      {isSmUp && <DesktopNav />}
    </>
  );
}
```

## 一般的なレイアウトパターン

### ヘッダー + メイン + フッター

```tsx
<Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
  <AppBar position="static">
    <Toolbar>
      <Typography variant="h6">ヘッダー</Typography>
    </Toolbar>
  </AppBar>

  <Container component="main" sx={{ flex: 1, py: 4 }}>
    メインコンテンツ
  </Container>

  <Box component="footer" sx={{ py: 3, bgcolor: 'grey.200' }}>
    <Container>
      <Typography>フッター</Typography>
    </Container>
  </Box>
</Box>
```

### サイドバーレイアウト

```tsx
const drawerWidth = 240;

<Box sx={{ display: 'flex' }}>
  {/* サイドバー */}
  <Drawer
    variant="permanent"
    sx={{
      width: drawerWidth,
      flexShrink: 0,
      '& .MuiDrawer-paper': {
        width: drawerWidth,
        boxSizing: 'border-box',
      },
    }}
  >
    <Toolbar />
    <Box sx={{ overflow: 'auto' }}>
      <List>...</List>
    </Box>
  </Drawer>

  {/* メインコンテンツ */}
  <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
    <Toolbar /> {/* AppBar の高さ分のスペーサー */}
    コンテンツ
  </Box>
</Box>
```

### カードグリッド

```tsx
<Grid container spacing={3}>
  {items.map((item) => (
    <Grid item xs={12} sm={6} md={4} key={item.id}>
      <Card sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
        <CardMedia
          component="img"
          height="200"
          image={item.image}
          alt={item.title}
        />
        <CardContent sx={{ flexGrow: 1 }}>
          <Typography variant="h6">{item.title}</Typography>
          <Typography variant="body2" color="text.secondary">
            {item.description}
          </Typography>
        </CardContent>
        <CardActions>
          <Button size="small">詳細</Button>
        </CardActions>
      </Card>
    </Grid>
  ))}
</Grid>
```

### 中央配置（垂直・水平）

```tsx
// Flexbox
<Box
  sx={{
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    minHeight: '100vh',
  }}
>
  <Paper sx={{ p: 4 }}>中央に配置されたコンテンツ</Paper>
</Box>

// Grid
<Grid
  container
  justifyContent="center"
  alignItems="center"
  sx={{ minHeight: '100vh' }}
>
  <Grid item>
    <Paper sx={{ p: 4 }}>中央に配置されたコンテンツ</Paper>
  </Grid>
</Grid>
```

### Sticky フッター

```tsx
<Box
  sx={{
    display: 'flex',
    flexDirection: 'column',
    minHeight: '100vh',
  }}
>
  <Box component="header">ヘッダー</Box>

  <Box component="main" sx={{ flex: 1 }}>
    メインコンテンツ（短くてもフッターは下に固定）
  </Box>

  <Box component="footer" sx={{ py: 2, bgcolor: 'grey.200' }}>
    フッター
  </Box>
</Box>
```

### 等間隔配置

```tsx
// Stack を使用
<Stack
  direction="row"
  justifyContent="space-evenly"
  alignItems="center"
  sx={{ width: '100%' }}
>
  <Item>1</Item>
  <Item>2</Item>
  <Item>3</Item>
</Stack>

// Flexbox を使用
<Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
  <Box>左</Box>
  <Box>右</Box>
</Box>
```

## sx prop のショートハンド

### スペーシング

| ショートハンド | CSS プロパティ |
|---------------|---------------|
| `m` | margin |
| `mt`, `mr`, `mb`, `ml` | margin-top, -right, -bottom, -left |
| `mx` | margin-left, margin-right |
| `my` | margin-top, margin-bottom |
| `p` | padding |
| `pt`, `pr`, `pb`, `pl` | padding-top, -right, -bottom, -left |
| `px` | padding-left, padding-right |
| `py` | padding-top, padding-bottom |

```tsx
<Box sx={{ m: 2, px: 3, py: 1 }}>
  {/* margin: 16px, padding: 8px 24px */}
</Box>
```

### 色

| ショートハンド | CSS プロパティ |
|---------------|---------------|
| `bgcolor` | background-color |
| `color` | color |

```tsx
<Box sx={{ bgcolor: 'primary.main', color: 'white' }}>
  テーマカラーを使用
</Box>
```

### サイズ

| ショートハンド | CSS プロパティ |
|---------------|---------------|
| `width`, `maxWidth`, `minWidth` | 同名 |
| `height`, `maxHeight`, `minHeight` | 同名 |

```tsx
<Box sx={{ width: 1 }}>    {/* width: 100% */}
<Box sx={{ width: 1/2 }}>  {/* width: 50% */}
<Box sx={{ width: 300 }}>  {/* width: 300px */}
```

### ボーダー

```tsx
<Box
  sx={{
    border: 1,               // border: 1px solid
    borderColor: 'grey.300',
    borderRadius: 2,         // theme.shape.borderRadius * 2
    borderTop: 1,
    borderBottom: 1,
  }}
/>
```

### 表示

```tsx
<Box sx={{ display: { xs: 'none', md: 'block' } }}>
  モバイルで非表示、mdで表示
</Box>
```
