---
name: amazon-sp-api-finances
description: Amazon SP-API Finances APIに特化したスキル。財務イベント・取引情報の取得をPython/Node.js/GASで実装。ユーザーが「売上金を確認して」「財務データを取得して」「決済情報を確認して」「注文の手数料を調べて」などと依頼した場合にトリガー。
---

# Finances API

財務イベント・取引情報の取得に特化したAPI。

> **注意:** v0（レガシー）とv2024-06-19（最新）の2バージョンが存在。v2024-06-19のlistTransactionsが推奨されるが、v0も引き続き利用可能。

## 目次

1. [財務イベントグループの取得](#財務イベントグループの取得)
2. [注文別の財務イベント取得](#注文別の財務イベント取得)
3. [全財務イベントの取得](#全財務イベントの取得)
4. [取引一覧の取得（v2024-06-19）](#取引一覧の取得v2024-06-19)
5. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## 財務イベントグループの取得

**エンドポイント:** `GET /finances/v0/financialEventGroups`

### Python

```python
import requests
from datetime import datetime, timedelta

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
HEADERS = {"x-amz-access-token": access_token}

# 過去30日の財務イベントグループを取得
start_date = (datetime.utcnow() - timedelta(days=30)).strftime("%Y-%m-%dT%H:%M:%SZ")

response = requests.get(
    f"{BASE_URL}/finances/v0/financialEventGroups",
    params={
        "FinancialEventGroupStartedAfter": start_date,
        "MaxResultsPerPage": 100,
    },
    headers=HEADERS,
)

for group in response.json().get("payload", {}).get("FinancialEventGroupList", []):
    print(f"グループID: {group['FinancialEventGroupId']}")
    print(f"処理ステータス: {group['ProcessingStatus']}")
    print(f"ファンド転送ステータス: {group.get('FundTransferStatus', 'N/A')}")
    print(f"開始日: {group['FinancialEventGroupStart']}")
    print(f"合計金額: {group.get('ConvertedTotal', {}).get('CurrencyAmount', 'N/A')}")
```

### Node.js/TypeScript

```typescript
const response = await axios.get(
  `${BASE_URL}/finances/v0/financialEventGroups`,
  {
    params: {
      FinancialEventGroupStartedAfter: startDate,
      MaxResultsPerPage: 100,
    },
    headers: HEADERS,
  }
);

for (const group of response.data.payload?.FinancialEventGroupList || []) {
  console.log(`グループID: ${group.FinancialEventGroupId}`);
  console.log(`ステータス: ${group.ProcessingStatus}`);
  console.log(`合計: ${group.ConvertedTotal?.CurrencyAmount}`);
}
```

### GAS

```javascript
function listFinancialEventGroups(daysBack = 30) {
  const startDate = new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000).toISOString();

  const result = spApiGet('/finances/v0/financialEventGroups', {
    FinancialEventGroupStartedAfter: startDate,
    MaxResultsPerPage: 100,
  });

  return result.payload?.FinancialEventGroupList || [];
}
```

## 注文別の財務イベント取得

**エンドポイント:** `GET /finances/v0/orders/{orderId}/financialEvents`

### Python

```python
order_id = "250-1234567-1234567"

response = requests.get(
    f"{BASE_URL}/finances/v0/orders/{order_id}/financialEvents",
    headers=HEADERS,
)

events = response.json().get("payload", {}).get("FinancialEvents", {})

# 注文の売上イベント
for event in events.get("ShipmentEventList", []):
    print(f"注文ID: {event['AmazonOrderId']}")
    print(f"出荷日: {event.get('PostedDate', 'N/A')}")
    for item in event.get("ShipmentItemList", []):
        print(f"  SKU: {item['SellerSKU']}")
        print(f"  数量: {item['QuantityShipped']}")
        for charge in item.get("ItemChargeList", []):
            print(f"  {charge['ChargeType']}: {charge['ChargeAmount']['CurrencyAmount']}")
        for fee in item.get("ItemFeeList", []):
            print(f"  {fee['FeeType']}: {fee['FeeAmount']['CurrencyAmount']}")

# 返金イベント
for event in events.get("RefundEventList", []):
    print(f"返金 - 注文ID: {event['AmazonOrderId']}")
```

### GAS

```javascript
function getFinancialEventsByOrder(orderId) {
  const result = spApiGet(`/finances/v0/orders/${orderId}/financialEvents`);
  return result.payload?.FinancialEvents || {};
}
```

## 全財務イベントの取得

**エンドポイント:** `GET /finances/v0/financialEvents`

### Python

```python
# 期間指定で全財務イベントを取得
response = requests.get(
    f"{BASE_URL}/finances/v0/financialEvents",
    params={
        "PostedAfter": "2026-01-01T00:00:00Z",
        "PostedBefore": "2026-01-31T23:59:59Z",
        "MaxResultsPerPage": 100,
    },
    headers=HEADERS,
)

events = response.json().get("payload", {}).get("FinancialEvents", {})

# ページネーション対応
next_token = response.json().get("payload", {}).get("NextToken")
while next_token:
    response = requests.get(
        f"{BASE_URL}/finances/v0/financialEvents",
        params={"NextToken": next_token, "MaxResultsPerPage": 100},
        headers=HEADERS,
    )
    data = response.json().get("payload", {})
    # events をマージ
    next_token = data.get("NextToken")
```

## 取引一覧の取得（v2024-06-19）

**エンドポイント:** `GET /finances/v2024-06-19/transactions`

### Python

```python
# 最新APIで取引一覧を取得
response = requests.get(
    f"{BASE_URL}/finances/2024-06-19/transactions",
    params={
        "postedAfter": "2026-01-01T00:00:00Z",
        "postedBefore": "2026-01-31T23:59:59Z",
        "marketplaceId": MARKETPLACE_ID,
    },
    headers=HEADERS,
)

for transaction in response.json().get("transactions", []):
    print(f"取引タイプ: {transaction.get('transactionType')}")
    print(f"注文ID: {transaction.get('relatedIdentifiers', {}).get('orderId', 'N/A')}")
    print(f"金額: {transaction.get('totalAmount', {})}")
    print(f"投稿日: {transaction.get('postedDate')}")
```

### GAS

```javascript
function listTransactions(startDate, endDate) {
  const result = spApiGet('/finances/2024-06-19/transactions', {
    postedAfter: startDate,
    postedBefore: endDate,
    marketplaceId: SP_API_CONFIG.marketplaceId,
  });

  return result.transactions || [];
}
```

## スプレッドシート連携（GAS）

### 財務サマリーをスプレッドシートに出力

```javascript
function exportFinancialSummary(daysBack = 30) {
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('財務サマリー') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('財務サマリー');

  const headers = ['グループID', '開始日', '終了日', 'ステータス', '合計金額', '通貨'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const groups = listFinancialEventGroups(daysBack);
  const rows = groups.map((g) => [
    g.FinancialEventGroupId,
    g.FinancialEventGroupStart || '',
    g.FinancialEventGroupEnd || '',
    g.ProcessingStatus || '',
    g.ConvertedTotal?.CurrencyAmount || '',
    g.ConvertedTotal?.CurrencyCode || '',
  ]);

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
}

function exportOrderFinancials(orderIds) {
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('注文別財務') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('注文別財務');

  const headers = ['注文ID', 'SKU', '数量', '売上', '手数料', '純利益'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = [];
  for (const orderId of orderIds) {
    try {
      const events = getFinancialEventsByOrder(orderId);
      for (const shipment of events.ShipmentEventList || []) {
        for (const item of shipment.ShipmentItemList || []) {
          const charges = (item.ItemChargeList || []).reduce(
            (sum, c) => sum + (parseFloat(c.ChargeAmount?.CurrencyAmount) || 0), 0
          );
          const fees = (item.ItemFeeList || []).reduce(
            (sum, f) => sum + (parseFloat(f.FeeAmount?.CurrencyAmount) || 0), 0
          );
          rows.push([
            orderId,
            item.SellerSKU || '',
            item.QuantityShipped || 0,
            charges,
            fees,
            charges + fees,
          ]);
        }
      }
    } catch (e) {
      rows.push([orderId, `エラー: ${e.message}`, '', '', '', '']);
    }
    Utilities.sleep(500);
  }

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
}
```

## リファレンス

### 主要財務イベントタイプ

| イベントリスト | 説明 |
|---------------|------|
| ShipmentEventList | 出荷関連イベント（売上） |
| RefundEventList | 返金イベント |
| ServiceFeeEventList | サービス手数料 |
| AdjustmentEventList | 調整イベント |
| SellerDealPaymentEventList | セラーディール支払い |
| ProductAdsPaymentEventList | 広告支払い |
| FBALiquidationEventList | FBA清算 |
| RemovalShipmentEventList | FBA返送 |
| CouponPaymentEventList | クーポン支払い |

### 主要手数料タイプ（ItemFeeList）

| FeeType | 説明 |
|---------|------|
| FBAPerUnitFulfillmentFee | FBA配送手数料（個別） |
| FBAPerOrderFulfillmentFee | FBA配送手数料（注文） |
| Commission | 販売手数料 |
| FBAWeightBasedFee | FBA重量手数料 |
| VariableClosingFee | カテゴリ別成約料 |

### 主要課金タイプ（ItemChargeList）

| ChargeType | 説明 |
|-----------|------|
| Principal | 商品価格 |
| Shipping | 配送料 |
| Tax | 税金 |
| GiftWrap | ギフトラッピング |
| ShippingTax | 配送料税金 |

### ProcessingStatus

| ステータス | 説明 |
|-----------|------|
| Open | 処理中 |
| Closed | 完了 |

### レート制限一覧

| オペレーション | レート | バースト |
|---------------|--------|---------|
| listFinancialEventGroups | 0.5/秒 | 30 |
| listFinancialEventsByGroupId | 0.5/秒 | 30 |
| listFinancialEventsByOrderId | 0.5/秒 | 30 |
| listFinancialEvents | 0.5/秒 | 30 |
| listTransactions (v2024-06-19) | 0.5/秒 | 30 |
