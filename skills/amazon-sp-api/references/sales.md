---
name: amazon-sp-api-sales
description: Amazon SP-API Sales APIに特化したスキル。売上パフォーマンス指標の取得をPython/Node.js/GASで実装。ユーザーが「売上データを取得して」「売上推移を確認して」「注文数の集計をして」「売上メトリクスを取得して」などと依頼した場合にトリガー。
---

# Sales API

売上パフォーマンス指標の取得に特化したAPI。

## 目次

1. [売上メトリクスの取得（getOrderMetrics）](#売上メトリクスの取得getordermetrics)
2. [日別・週別・月別集計](#日別週別月別集計)
3. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## 売上メトリクスの取得（getOrderMetrics）

**エンドポイント:** `GET /sales/v1/orderMetrics`
**レート制限:** 0.5リクエスト/秒（バースト: 15）

### Python

```python
import requests

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
MARKETPLACE_ID = "A1VC38T7YXB528"
HEADERS = {"x-amz-access-token": access_token}

# 日別の売上メトリクスを取得
response = requests.get(
    f"{BASE_URL}/sales/v1/orderMetrics",
    params={
        "marketplaceIds": MARKETPLACE_ID,
        "interval": "2026-01-01T00:00:00Z--2026-01-31T23:59:59Z",
        "granularity": "Day",
        "buyerType": "All",
    },
    headers=HEADERS,
)

for metric in response.json().get("payload", []):
    interval = metric["interval"]
    print(f"期間: {interval}")
    print(f"  注文数: {metric['unitCount']}")
    print(f"  注文金額: {metric['orderItemCount']}")
    print(f"  売上合計: {metric['totalSales']['amount']} {metric['totalSales']['currencyCode']}")
    print(f"  平均単価: {metric['averageUnitPrice']['amount']}")
```

### Node.js/TypeScript

```typescript
const response = await axios.get(
  `${BASE_URL}/sales/v1/orderMetrics`,
  {
    params: {
      marketplaceIds: 'A1VC38T7YXB528',
      interval: '2026-01-01T00:00:00Z--2026-01-31T23:59:59Z',
      granularity: 'Day',
      buyerType: 'All',
    },
    headers: HEADERS,
  }
);

for (const metric of response.data.payload || []) {
  console.log(`期間: ${metric.interval}`);
  console.log(`  注文数: ${metric.unitCount}`);
  console.log(`  売上: ${metric.totalSales.amount} ${metric.totalSales.currencyCode}`);
}
```

### GAS

```javascript
function getOrderMetrics(startDate, endDate, granularity = 'Day') {
  const interval = `${startDate}--${endDate}`;

  const result = spApiGet('/sales/v1/orderMetrics', {
    marketplaceIds: SP_API_CONFIG.marketplaceId,
    interval: interval,
    granularity: granularity,
    buyerType: 'All',
  });

  return result.payload || [];
}
```

## 日別・週別・月別集計

### Python

```python
# 週別集計
response = requests.get(
    f"{BASE_URL}/sales/v1/orderMetrics",
    params={
        "marketplaceIds": MARKETPLACE_ID,
        "interval": "2026-01-01T00:00:00Z--2026-03-31T23:59:59Z",
        "granularity": "Week",
        "buyerType": "All",
    },
    headers=HEADERS,
)

# 月別集計
response = requests.get(
    f"{BASE_URL}/sales/v1/orderMetrics",
    params={
        "marketplaceIds": MARKETPLACE_ID,
        "interval": "2025-01-01T00:00:00Z--2025-12-31T23:59:59Z",
        "granularity": "Month",
        "buyerType": "All",
    },
    headers=HEADERS,
)

# B2Bのみの集計
response = requests.get(
    f"{BASE_URL}/sales/v1/orderMetrics",
    params={
        "marketplaceIds": MARKETPLACE_ID,
        "interval": "2026-01-01T00:00:00Z--2026-01-31T23:59:59Z",
        "granularity": "Day",
        "buyerType": "B2B",
    },
    headers=HEADERS,
)
```

## スプレッドシート連携（GAS）

### 売上ダッシュボード

```javascript
function exportSalesDashboard() {
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('売上ダッシュボード') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('売上ダッシュボード');

  // 過去30日の日別売上
  const endDate = new Date().toISOString();
  const startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();

  const metrics = getOrderMetrics(startDate, endDate, 'Day');

  const headers = ['日付', '注文数', '商品数', '売上合計', '平均単価'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = metrics.map((m) => [
    m.interval.split('T')[0].split('--')[0],
    m.unitCount || 0,
    m.orderItemCount || 0,
    m.totalSales?.amount || 0,
    m.averageUnitPrice?.amount || 0,
  ]);

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }

  // サマリー行
  const totalRow = rows.length + 3;
  sheet.getRange(totalRow, 1).setValue('合計');
  sheet.getRange(totalRow, 2).setFormula(`=SUM(B2:B${rows.length + 1})`);
  sheet.getRange(totalRow, 3).setFormula(`=SUM(C2:C${rows.length + 1})`);
  sheet.getRange(totalRow, 4).setFormula(`=SUM(D2:D${rows.length + 1})`);
  sheet.getRange(totalRow, 5).setFormula(`=AVERAGE(E2:E${rows.length + 1})`);
}

function exportMonthlySales(year) {
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('月別売上') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('月別売上');

  const startDate = `${year}-01-01T00:00:00Z`;
  const endDate = `${year}-12-31T23:59:59Z`;

  const metrics = getOrderMetrics(startDate, endDate, 'Month');

  const headers = ['月', '注文数', '売上合計', '前月比'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = [];
  for (let i = 0; i < metrics.length; i++) {
    const m = metrics[i];
    const sales = m.totalSales?.amount || 0;
    const prevSales = i > 0 ? (metrics[i - 1].totalSales?.amount || 0) : 0;
    const growth = prevSales > 0 ? (((sales - prevSales) / prevSales) * 100).toFixed(1) : '-';

    rows.push([
      m.interval.split('T')[0].split('--')[0],
      m.unitCount || 0,
      sales,
      i > 0 ? `${growth}%` : '-',
    ]);
  }

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
}
```

## リファレンス

### パラメータ

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| marketplaceIds | string | はい | マーケットプレイスID |
| interval | string | はい | 期間（ISO 8601、`--`で区切り） |
| granularity | string | はい | 集計粒度 |
| buyerType | string | いいえ | 購入者タイプ |
| fulfillmentNetwork | string | いいえ | フルフィルメントネットワーク |
| firstDayOfWeek | string | いいえ | 週の開始曜日 |
| asin | string | いいえ | ASIN（特定商品のみ） |
| sku | string | いいえ | SKU（特定商品のみ） |

### granularity

| 値 | 説明 |
|----|------|
| Hour | 時間別 |
| Day | 日別 |
| Week | 週別 |
| Month | 月別 |
| Year | 年別 |
| Total | 期間合計 |

### buyerType

| 値 | 説明 |
|----|------|
| All | 全購入者（デフォルト） |
| B2B | Amazon Businessのみ |
| B2C | 一般消費者のみ |

### レスポンスフィールド

| フィールド | 型 | 説明 |
|-----------|-----|------|
| interval | string | 期間 |
| unitCount | integer | ユニット数 |
| orderItemCount | integer | 注文アイテム数 |
| orderCount | integer | 注文数 |
| totalSales | Money | 売上合計 |
| averageUnitPrice | Money | 平均単価 |
