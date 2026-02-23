# GAS スプレッドシート操作 APIリファレンス

## Range API詳細

### データ取得

```javascript
// 単一値
range.getValue()

// 2次元配列（行×列）
range.getValues()

// 数式
range.getFormula()
range.getFormulas()

// 表示値（フォーマット適用後）
range.getDisplayValue()
range.getDisplayValues()
```

### データ設定

```javascript
// 単一値
range.setValue(value)

// 2次元配列
range.setValues([[v1, v2], [v3, v4]])

// 数式
range.setFormula('=SUM(A1:A10)')
range.setFormulas([['=A1+B1'], ['=A2+B2']])

// R1C1形式
range.setFormulaR1C1('=SUM(R[-5]C:RC)')
```

### TextFinder API

```javascript
const finder = sheet.createTextFinder('検索語');

// オプション
finder.matchCase(true);              // 大文字小文字区別
finder.matchEntireCell(true);        // 完全一致
finder.matchFormulaText(true);       // 数式内検索
finder.useRegularExpression(true);   // 正規表現
finder.ignoreDiacritics(true);       // アクセント無視

// 検索実行
finder.findNext();    // 次を検索
finder.findPrevious(); // 前を検索
finder.findAll();     // 全検索

// 置換
finder.replaceWith('置換語');
finder.replaceAllWith('置換語');
```

## 条件付き書式

### ビルダーAPI

```javascript
SpreadsheetApp.newConditionalFormatRule()
  // 条件
  .whenCellEmpty()
  .whenCellNotEmpty()
  .whenNumberBetween(min, max)
  .whenNumberEqualTo(value)
  .whenNumberGreaterThan(value)
  .whenNumberGreaterThanOrEqualTo(value)
  .whenNumberLessThan(value)
  .whenNumberLessThanOrEqualTo(value)
  .whenNumberNotBetween(min, max)
  .whenNumberNotEqualTo(value)
  .whenTextContains(text)
  .whenTextDoesNotContain(text)
  .whenTextEqualTo(text)
  .whenTextStartsWith(text)
  .whenTextEndsWith(text)
  .whenDateAfter(date)
  .whenDateBefore(date)
  .whenDateEqualTo(date)
  .whenFormulaSatisfied(formula)

  // 書式
  .setBackground(color)
  .setFontColor(color)
  .setBold(true)
  .setItalic(true)
  .setStrikethrough(true)
  .setUnderline(true)

  // 範囲
  .setRanges([range1, range2])

  // ビルド
  .build()
```

## データ検証

```javascript
const rule = SpreadsheetApp.newDataValidation()
  .requireValueInList(['選択肢1', '選択肢2'], true)
  .setAllowInvalid(false)
  .setHelpText('ヘルプテキスト')
  .build();

range.setDataValidation(rule);

// 検証ルール種類
.requireCheckbox()
.requireCheckbox(checkedValue, uncheckedValue)
.requireDate()
.requireDateAfter(date)
.requireDateBefore(date)
.requireDateBetween(start, end)
.requireDateEqualTo(date)
.requireDateNotBetween(start, end)
.requireDateOnOrAfter(date)
.requireDateOnOrBefore(date)
.requireFormulaSatisfied(formula)
.requireNumberBetween(start, end)
.requireNumberEqualTo(number)
.requireNumberGreaterThan(number)
.requireNumberGreaterThanOrEqualTo(number)
.requireNumberLessThan(number)
.requireNumberLessThanOrEqualTo(number)
.requireNumberNotBetween(start, end)
.requireNumberNotEqualTo(number)
.requireTextContains(text)
.requireTextDoesNotContain(text)
.requireTextEqualTo(text)
.requireTextIsEmail()
.requireTextIsUrl()
.requireValueInList(values, showDropdown)
.requireValueInRange(range, showDropdown)
```

## フィルタ・ソート

```javascript
// フィルタ作成
const filter = range.createFilter();

// 列にフィルタ条件設定
const criteria = SpreadsheetApp.newFilterCriteria()
  .whenTextContains('検索語')
  .build();
filter.setColumnFilterCriteria(1, criteria);

// フィルタ削除
sheet.getFilter().remove();

// ソート
range.sort(1);              // 1列目昇順
range.sort({column: 1, ascending: false}); // 降順
range.sort([{column: 1}, {column: 2, ascending: false}]); // 複合
```

## 数値フォーマット

| フォーマット | 例 | 結果 |
|-------------|-----|------|
| `#,##0` | 1234567 | 1,234,567 |
| `#,##0.00` | 1234.5 | 1,234.50 |
| `0%` | 0.75 | 75% |
| `0.00%` | 0.756 | 75.60% |
| `¥#,##0` | 1000 | ¥1,000 |
| `$#,##0.00` | 1000 | $1,000.00 |
| `yyyy/MM/dd` | Date | 2024/01/15 |
| `yyyy年M月d日` | Date | 2024年1月15日 |
| `HH:mm:ss` | Date | 14:30:00 |
| `yyyy/MM/dd HH:mm` | Date | 2024/01/15 14:30 |
