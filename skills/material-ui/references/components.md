# MUI コンポーネントリファレンス

## 入力コンポーネント

### Button

```tsx
import { Button, IconButton, LoadingButton } from '@mui/material';
import { LoadingButton } from '@mui/lab';
import SaveIcon from '@mui/icons-material/Save';

// 基本
<Button variant="contained" color="primary">
  保存
</Button>

// サイズ
<Button size="small">Small</Button>
<Button size="medium">Medium</Button>
<Button size="large">Large</Button>

// アイコン付き
<Button variant="contained" startIcon={<SaveIcon />}>
  保存
</Button>

// IconButton
<IconButton color="primary" aria-label="save">
  <SaveIcon />
</IconButton>

// ローディング状態（@mui/lab）
<LoadingButton
  loading={isLoading}
  loadingPosition="start"
  startIcon={<SaveIcon />}
  variant="contained"
>
  保存中...
</LoadingButton>

// カスタムカラー
<Button
  sx={{
    bgcolor: 'success.main',
    '&:hover': { bgcolor: 'success.dark' },
  }}
>
  カスタム
</Button>
```

### TextField

```tsx
import { TextField, InputAdornment } from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';

// 基本
<TextField
  label="名前"
  variant="outlined"
  fullWidth
  required
  error={!!errors.name}
  helperText={errors.name?.message}
/>

// 複数行
<TextField
  label="コメント"
  multiline
  rows={4}
  maxRows={8}
/>

// アイコン付き
<TextField
  label="検索"
  InputProps={{
    startAdornment: (
      <InputAdornment position="start">
        <SearchIcon />
      </InputAdornment>
    ),
  }}
/>

// パスワード
const [showPassword, setShowPassword] = useState(false);
<TextField
  type={showPassword ? 'text' : 'password'}
  InputProps={{
    endAdornment: (
      <InputAdornment position="end">
        <IconButton onClick={() => setShowPassword(!showPassword)}>
          {showPassword ? <VisibilityOff /> : <Visibility />}
        </IconButton>
      </InputAdornment>
    ),
  }}
/>
```

### Select

```tsx
import {
  Select, MenuItem, FormControl, InputLabel,
  FormHelperText, Autocomplete
} from '@mui/material';

// 基本的なSelect
<FormControl fullWidth error={!!error}>
  <InputLabel id="category-label">カテゴリ</InputLabel>
  <Select
    labelId="category-label"
    value={category}
    label="カテゴリ"
    onChange={(e) => setCategory(e.target.value)}
  >
    <MenuItem value="">
      <em>選択してください</em>
    </MenuItem>
    <MenuItem value="tech">テクノロジー</MenuItem>
    <MenuItem value="design">デザイン</MenuItem>
    <MenuItem value="business">ビジネス</MenuItem>
  </Select>
  {error && <FormHelperText>{error}</FormHelperText>}
</FormControl>

// 複数選択
<Select
  multiple
  value={selectedItems}
  onChange={(e) => setSelectedItems(e.target.value)}
  renderValue={(selected) => selected.join(', ')}
>
  {items.map((item) => (
    <MenuItem key={item} value={item}>
      <Checkbox checked={selectedItems.includes(item)} />
      <ListItemText primary={item} />
    </MenuItem>
  ))}
</Select>

// Autocomplete（検索可能なSelect）
<Autocomplete
  options={countries}
  getOptionLabel={(option) => option.label}
  renderInput={(params) => (
    <TextField {...params} label="国" />
  )}
  onChange={(e, value) => setCountry(value)}
/>
```

### Checkbox / Radio / Switch

```tsx
import {
  Checkbox, Radio, Switch,
  FormControlLabel, FormGroup, RadioGroup
} from '@mui/material';

// Checkbox
<FormGroup>
  <FormControlLabel
    control={<Checkbox checked={checked} onChange={handleChange} />}
    label="利用規約に同意する"
  />
</FormGroup>

// Radio
<RadioGroup value={value} onChange={handleChange}>
  <FormControlLabel value="option1" control={<Radio />} label="オプション1" />
  <FormControlLabel value="option2" control={<Radio />} label="オプション2" />
</RadioGroup>

// Switch
<FormControlLabel
  control={<Switch checked={enabled} onChange={handleToggle} />}
  label="通知を有効にする"
/>
```

## データ表示

### Table

```tsx
import {
  Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, TablePagination, TableSortLabel,
  Paper
} from '@mui/material';

// 基本的なテーブル
<TableContainer component={Paper}>
  <Table>
    <TableHead>
      <TableRow>
        <TableCell>名前</TableCell>
        <TableCell align="right">年齢</TableCell>
        <TableCell align="right">操作</TableCell>
      </TableRow>
    </TableHead>
    <TableBody>
      {rows.map((row) => (
        <TableRow
          key={row.id}
          hover
          sx={{ '&:last-child td': { border: 0 } }}
        >
          <TableCell>{row.name}</TableCell>
          <TableCell align="right">{row.age}</TableCell>
          <TableCell align="right">
            <IconButton size="small">
              <EditIcon />
            </IconButton>
          </TableCell>
        </TableRow>
      ))}
    </TableBody>
  </Table>
</TableContainer>

// ソート可能なヘッダー
<TableCell sortDirection={orderBy === 'name' ? order : false}>
  <TableSortLabel
    active={orderBy === 'name'}
    direction={orderBy === 'name' ? order : 'asc'}
    onClick={() => handleSort('name')}
  >
    名前
  </TableSortLabel>
</TableCell>

// ページネーション
<TablePagination
  component="div"
  count={totalCount}
  page={page}
  onPageChange={handleChangePage}
  rowsPerPage={rowsPerPage}
  onRowsPerPageChange={handleChangeRowsPerPage}
  labelRowsPerPage="表示件数"
/>
```

### DataGrid（@mui/x-data-grid）

```tsx
import { DataGrid, GridColDef } from '@mui/x-data-grid';

const columns: GridColDef[] = [
  { field: 'id', headerName: 'ID', width: 70 },
  { field: 'name', headerName: '名前', width: 150, editable: true },
  { field: 'email', headerName: 'メール', width: 200 },
  {
    field: 'status',
    headerName: 'ステータス',
    width: 120,
    renderCell: (params) => (
      <Chip
        label={params.value}
        color={params.value === 'active' ? 'success' : 'default'}
        size="small"
      />
    ),
  },
  {
    field: 'actions',
    headerName: '操作',
    width: 100,
    sortable: false,
    renderCell: (params) => (
      <IconButton onClick={() => handleEdit(params.row)}>
        <EditIcon />
      </IconButton>
    ),
  },
];

<DataGrid
  rows={rows}
  columns={columns}
  initialState={{
    pagination: { paginationModel: { pageSize: 10 } },
  }}
  pageSizeOptions={[10, 25, 50]}
  checkboxSelection
  disableRowSelectionOnClick
  loading={isLoading}
  autoHeight
/>
```

## フィードバック

### Dialog

```tsx
import {
  Dialog, DialogTitle, DialogContent, DialogContentText,
  DialogActions, Button
} from '@mui/material';

// 確認ダイアログ
<Dialog open={open} onClose={handleClose}>
  <DialogTitle>削除の確認</DialogTitle>
  <DialogContent>
    <DialogContentText>
      このアイテムを削除してもよろしいですか？
      この操作は取り消せません。
    </DialogContentText>
  </DialogContent>
  <DialogActions>
    <Button onClick={handleClose}>キャンセル</Button>
    <Button onClick={handleDelete} color="error" variant="contained">
      削除
    </Button>
  </DialogActions>
</Dialog>

// フォームダイアログ
<Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
  <DialogTitle>ユーザーを追加</DialogTitle>
  <DialogContent>
    <Box sx={{ pt: 1 }}>
      <TextField label="名前" fullWidth sx={{ mb: 2 }} />
      <TextField label="メール" fullWidth />
    </Box>
  </DialogContent>
  <DialogActions>
    <Button onClick={handleClose}>キャンセル</Button>
    <Button variant="contained">追加</Button>
  </DialogActions>
</Dialog>

// フルスクリーン（モバイル対応）
import useMediaQuery from '@mui/material/useMediaQuery';
const fullScreen = useMediaQuery(theme.breakpoints.down('md'));

<Dialog fullScreen={fullScreen} open={open} onClose={handleClose}>
  ...
</Dialog>
```

### Drawer

```tsx
import { Drawer, List, ListItem, ListItemIcon, ListItemText } from '@mui/material';

// 一時的なDrawer（モバイルナビ）
<Drawer
  anchor="left"
  open={drawerOpen}
  onClose={() => setDrawerOpen(false)}
>
  <Box sx={{ width: 250 }}>
    <List>
      {menuItems.map((item) => (
        <ListItem button key={item.text} onClick={() => navigate(item.path)}>
          <ListItemIcon>{item.icon}</ListItemIcon>
          <ListItemText primary={item.text} />
        </ListItem>
      ))}
    </List>
  </Box>
</Drawer>

// 永続的なDrawer（デスクトップサイドバー）
<Drawer
  variant="permanent"
  sx={{
    width: 240,
    '& .MuiDrawer-paper': { width: 240, boxSizing: 'border-box' },
  }}
>
  ...
</Drawer>
```

### Menu

```tsx
import { Menu, MenuItem, ListItemIcon, ListItemText, Divider } from '@mui/material';

const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
const open = Boolean(anchorEl);

<Button onClick={(e) => setAnchorEl(e.currentTarget)}>
  メニュー
</Button>
<Menu
  anchorEl={anchorEl}
  open={open}
  onClose={() => setAnchorEl(null)}
  anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
  transformOrigin={{ vertical: 'top', horizontal: 'right' }}
>
  <MenuItem onClick={handleEdit}>
    <ListItemIcon><EditIcon fontSize="small" /></ListItemIcon>
    <ListItemText>編集</ListItemText>
  </MenuItem>
  <MenuItem onClick={handleDuplicate}>
    <ListItemIcon><ContentCopyIcon fontSize="small" /></ListItemIcon>
    <ListItemText>複製</ListItemText>
  </MenuItem>
  <Divider />
  <MenuItem onClick={handleDelete} sx={{ color: 'error.main' }}>
    <ListItemIcon><DeleteIcon fontSize="small" color="error" /></ListItemIcon>
    <ListItemText>削除</ListItemText>
  </MenuItem>
</Menu>
```

### Snackbar / Alert

```tsx
import { Snackbar, Alert, AlertTitle } from '@mui/material';

// Snackbar with Alert
<Snackbar
  open={snackbar.open}
  autoHideDuration={6000}
  onClose={handleClose}
  anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
>
  <Alert
    onClose={handleClose}
    severity={snackbar.severity}  // 'success' | 'error' | 'warning' | 'info'
    variant="filled"
  >
    {snackbar.message}
  </Alert>
</Snackbar>

// スタンドアロンAlert
<Alert severity="error">
  <AlertTitle>エラー</AlertTitle>
  入力内容に問題があります。確認してください。
</Alert>

<Alert
  severity="success"
  action={
    <Button color="inherit" size="small" onClick={handleUndo}>
      元に戻す
    </Button>
  }
>
  保存しました
</Alert>
```

## サーフェス

### Card

```tsx
import {
  Card, CardHeader, CardMedia, CardContent, CardActions,
  Avatar, Typography
} from '@mui/material';

<Card sx={{ maxWidth: 345 }}>
  <CardHeader
    avatar={<Avatar sx={{ bgcolor: 'primary.main' }}>U</Avatar>}
    title="ユーザー名"
    subheader="2024年1月1日"
    action={
      <IconButton aria-label="settings">
        <MoreVertIcon />
      </IconButton>
    }
  />
  <CardMedia
    component="img"
    height="194"
    image="/images/card-image.jpg"
    alt="Card image"
  />
  <CardContent>
    <Typography variant="body2" color="text.secondary">
      カードの説明テキストがここに入ります。
    </Typography>
  </CardContent>
  <CardActions disableSpacing>
    <IconButton aria-label="like">
      <FavoriteIcon />
    </IconButton>
    <IconButton aria-label="share">
      <ShareIcon />
    </IconButton>
  </CardActions>
</Card>
```

### Paper

```tsx
import { Paper } from '@mui/material';

// 基本
<Paper elevation={3} sx={{ p: 2 }}>
  Content
</Paper>

// アウトライン
<Paper variant="outlined" sx={{ p: 2 }}>
  Outlined
</Paper>

// カスタムelevation
<Paper elevation={0} sx={{ bgcolor: 'grey.100', p: 2 }}>
  Flat
</Paper>
```

### Accordion

```tsx
import {
  Accordion, AccordionSummary, AccordionDetails,
  Typography
} from '@mui/material';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';

// 基本
{faqs.map((faq, index) => (
  <Accordion key={index}>
    <AccordionSummary expandIcon={<ExpandMoreIcon />}>
      <Typography>{faq.question}</Typography>
    </AccordionSummary>
    <AccordionDetails>
      <Typography>{faq.answer}</Typography>
    </AccordionDetails>
  </Accordion>
))}

// Controlled Accordion
const [expanded, setExpanded] = useState<string | false>(false);

<Accordion
  expanded={expanded === 'panel1'}
  onChange={(e, isExpanded) => setExpanded(isExpanded ? 'panel1' : false)}
>
  ...
</Accordion>
```

## ナビゲーション

### Tabs

```tsx
import { Tabs, Tab, Box } from '@mui/material';

const [value, setValue] = useState(0);

<Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
  <Tabs value={value} onChange={(e, newValue) => setValue(newValue)}>
    <Tab label="概要" />
    <Tab label="詳細" />
    <Tab label="設定" />
  </Tabs>
</Box>
<TabPanel value={value} index={0}>概要コンテンツ</TabPanel>
<TabPanel value={value} index={1}>詳細コンテンツ</TabPanel>
<TabPanel value={value} index={2}>設定コンテンツ</TabPanel>

// TabPanelコンポーネント
function TabPanel({ children, value, index }) {
  return (
    <div role="tabpanel" hidden={value !== index}>
      {value === index && <Box sx={{ p: 3 }}>{children}</Box>}
    </div>
  );
}
```

### Breadcrumbs

```tsx
import { Breadcrumbs, Link, Typography } from '@mui/material';
import NavigateNextIcon from '@mui/icons-material/NavigateNext';

<Breadcrumbs separator={<NavigateNextIcon fontSize="small" />}>
  <Link underline="hover" color="inherit" href="/">
    ホーム
  </Link>
  <Link underline="hover" color="inherit" href="/products">
    商品
  </Link>
  <Typography color="text.primary">詳細</Typography>
</Breadcrumbs>
```

### Stepper

```tsx
import { Stepper, Step, StepLabel, StepContent, Button } from '@mui/material';

const steps = ['基本情報', '詳細設定', '確認'];
const [activeStep, setActiveStep] = useState(0);

// 水平Stepper
<Stepper activeStep={activeStep}>
  {steps.map((label) => (
    <Step key={label}>
      <StepLabel>{label}</StepLabel>
    </Step>
  ))}
</Stepper>

// 垂直Stepper（コンテンツ付き）
<Stepper activeStep={activeStep} orientation="vertical">
  {steps.map((step, index) => (
    <Step key={step.label}>
      <StepLabel>{step.label}</StepLabel>
      <StepContent>
        <Typography>{step.description}</Typography>
        <Box sx={{ mt: 2 }}>
          <Button variant="contained" onClick={handleNext}>
            {index === steps.length - 1 ? '完了' : '次へ'}
          </Button>
          <Button disabled={index === 0} onClick={handleBack}>
            戻る
          </Button>
        </Box>
      </StepContent>
    </Step>
  ))}
</Stepper>
```
