# GAS スプレッドシート APIリファレンス

## 主要クラス

### SpreadsheetApp

| メソッド | 説明 |
|---------|------|
| `getActiveSpreadsheet()` | アクティブなスプレッドシート |
| `openById(id)` | IDでスプレッドシートを開く |
| `openByUrl(url)` | URLでスプレッドシートを開く |
| `create(name)` | 新規スプレッドシート作成 |

### Spreadsheet

| メソッド | 説明 |
|---------|------|
| `getActiveSheet()` | アクティブなシート |
| `getSheetByName(name)` | 名前でシート取得 |
| `getSheets()` | 全シート取得 |
| `insertSheet(name)` | シート追加 |
| `deleteSheet(sheet)` | シート削除 |
| `getId()` | スプレッドシートID |
| `getUrl()` | URL取得 |

### Sheet

| メソッド | 説明 |
|---------|------|
| `getRange(a1Notation)` | A1形式で範囲取得 |
| `getRange(row, col, numRows, numCols)` | 行列指定で範囲取得 |
| `getDataRange()` | データのある範囲 |
| `getLastRow()` | 最終行番号 |
| `getLastColumn()` | 最終列番号 |
| `appendRow(values)` | 行追加 |
| `insertRows(position, num)` | 行挿入 |
| `deleteRows(position, num)` | 行削除 |
| `getName()` | シート名 |
| `setName(name)` | シート名変更 |
| `protect()` | 保護設定 |
| `hideSheet()` | 非表示 |
| `showSheet()` | 表示 |
| `copyTo(spreadsheet)` | コピー |

### Range

| メソッド | 説明 |
|---------|------|
| `getValue()` | 単一値取得 |
| `getValues()` | 2次元配列で取得 |
| `setValue(value)` | 単一値設定 |
| `setValues(values)` | 2次元配列で設定 |
| `getFormula()` | 数式取得 |
| `setFormula(formula)` | 数式設定 |
| `getRow()` | 行番号 |
| `getColumn()` | 列番号 |
| `getNumRows()` | 行数 |
| `getNumColumns()` | 列数 |
| `offset(row, col)` | オフセット範囲 |
| `clear()` | クリア |
| `clearContent()` | 値のみクリア |
| `clearFormat()` | 書式のみクリア |

#### 書式設定

| メソッド | 説明 |
|---------|------|
| `setBackground(color)` | 背景色 |
| `setFontColor(color)` | 文字色 |
| `setFontFamily(family)` | フォント |
| `setFontSize(size)` | フォントサイズ |
| `setFontWeight(weight)` | 太字（'bold'/'normal'） |
| `setFontStyle(style)` | 斜体（'italic'/'normal'） |
| `setHorizontalAlignment(align)` | 水平位置（'left'/'center'/'right'） |
| `setVerticalAlignment(align)` | 垂直位置（'top'/'middle'/'bottom'） |
| `setNumberFormat(format)` | 数値フォーマット |
| `setBorder(top, left, bottom, right, vertical, horizontal)` | 罫線 |
| `merge()` | セル結合 |

## 制限事項

| 項目 | 制限 |
|------|------|
| 実行時間 | 6分（通常）、30分（トリガー） |
| セル数 | 1000万セル/スプレッドシート |
| シート数 | 200シート/スプレッドシート |
| API呼び出し | 読み書き操作は最小限に |
| UrlFetch | 20,000回/日 |
| メール送信 | 100通/日（無料）、1,500通/日（Workspace） |

## パフォーマンス

- `getValues()`/`setValues()`で一括処理
- ループ内での`getValue()`/`setValue()`を避ける
- `flush()`で変更を即時反映
- `CacheService`で頻繁なAPI呼び出しを削減
