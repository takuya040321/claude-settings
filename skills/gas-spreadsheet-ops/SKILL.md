---
name: gas-spreadsheet-ops
description: GASによるスプレッドシートのデータ操作に特化したスキル。データの読み書き、検索、フィルタリング、書式設定、数式、シート管理、集計処理をサポート。ユーザーが「データを取得して」「セルに書き込んで」「条件で絞り込んで」「集計して」などスプレッドシートのデータ操作を依頼した場合に使用。
---

# GAS スプレッドシート操作

## データの読み取り

### 範囲指定

```javascript
const sheet = SpreadsheetApp.getActiveSheet();

// 単一セル
const value = sheet.getRange('A1').getValue();

// 範囲（2次元配列）
const values = sheet.getRange('A1:C10').getValues();

// 行・列指定（row, col, numRows, numCols）
const values = sheet.getRange(1, 1, 10, 3).getValues();

// データのある範囲を自動取得
const allData = sheet.getDataRange().getValues();

// 最終行・列
const lastRow = sheet.getLastRow();
const lastCol = sheet.getLastColumn();
```

### ヘッダー付きデータの取得

```javascript
function getDataAsObjects(sheet) {
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  return data.slice(1).map(row => {
    const obj = {};
    headers.forEach((h, i) => obj[h] = row[i]);
    return obj;
  });
}
// 結果: [{名前: '田中', 年齢: 30}, ...]
```

## データの書き込み

```javascript
// 単一セル
sheet.getRange('A1').setValue('Hello');

// 範囲（2次元配列）
sheet.getRange('A1:C2').setValues([
  ['名前', '年齢', 'メール'],
  ['田中', 30, 'tanaka@example.com']
]);

// 最終行に追加
sheet.appendRow(['新しいデータ', 100, new Date()]);
```

## 検索・フィルタリング

### 条件検索

```javascript
function findRows(sheet, conditions) {
  const data = sheet.getDataRange().getValues();
  const headers = data[0];

  return data.slice(1).filter(row => {
    return Object.entries(conditions).every(([key, value]) => {
      const colIndex = headers.indexOf(key);
      return colIndex >= 0 && row[colIndex] === value;
    });
  });
}
// 使用例: findRows(sheet, {部署: '営業', ステータス: '完了'})
```

### TextFinder（高速検索）

```javascript
const finder = sheet.createTextFinder('検索文字列')
  .matchCase(true)           // 大文字小文字区別
  .matchEntireCell(true);    // 完全一致

const allMatches = finder.findAll();
finder.replaceAllWith('置換文字列');
```

## 書式設定

```javascript
const range = sheet.getRange('A1:D10');

// 背景色・文字色
range.setBackground('#f0f0f0');
range.setFontColor('#333333');

// フォント
range.setFontWeight('bold');
range.setHorizontalAlignment('center');

// 罫線
range.setBorder(true, true, true, true, true, true);

// 数値フォーマット
range.setNumberFormat('#,##0');       // 3桁区切り
range.setNumberFormat('yyyy/MM/dd');  // 日付
```

### 条件付き書式

```javascript
const rule = SpreadsheetApp.newConditionalFormatRule()
  .whenNumberGreaterThanOrEqualTo(100)
  .setBackground('#90EE90')
  .setRanges([sheet.getRange('B2:B100')])
  .build();

const rules = sheet.getConditionalFormatRules();
rules.push(rule);
sheet.setConditionalFormatRules(rules);
```

## 数式・カスタム関数

```javascript
// 数式を設定
sheet.getRange('D2').setFormula('=SUM(A2:C2)');

// 配列数式
sheet.getRange('E2').setFormula('=ARRAYFORMULA(A2:A100*B2:B100)');

/**
 * カスタム関数（スプレッドシートで =ZEIKOMI(A1) で使用可能）
 * @customfunction
 */
function ZEIKOMI(price, rate = 0.1) {
  return price * (1 + rate);
}
```

## シート管理

```javascript
const ss = SpreadsheetApp.getActiveSpreadsheet();

ss.insertSheet('新しいシート');           // 作成
const sheet = ss.getSheetByName('名前');  // 取得
ss.deleteSheet(sheet);                    // 削除
sheet.copyTo(ss).setName('コピー');       // コピー
sheet.hideSheet();                        // 非表示

// 保護
const protection = sheet.protect();
protection.addEditor('user@example.com');
```

## 集計処理

```javascript
function groupBy(sheet, groupColumn, sumColumn) {
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const groupIdx = headers.indexOf(groupColumn);
  const sumIdx = headers.indexOf(sumColumn);

  const result = {};
  data.slice(1).forEach(row => {
    const key = row[groupIdx];
    result[key] = (result[key] || 0) + Number(row[sumIdx]);
  });
  return result;
}
// 使用例: groupBy(sheet, '部署', '売上')
```

## リファレンス

詳細なAPIリファレンスは[references/api_reference.md](references/api_reference.md)を参照。
