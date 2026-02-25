---
name: amazon-sp-api-tokens
description: Amazon SP-API Tokens APIに特化したスキル。制限付きデータトークン（RDT）の取得によるPII（個人情報）へのアクセスをPython/Node.js/GASで実装。ユーザーが「購入者情報を取得して」「配送先住所を取得して」「PII情報にアクセスして」「RDTトークンを取得して」などと依頼した場合にトリガー。
---

# Tokens API

制限付きデータトークン（RDT）の取得によるPII（個人情報）アクセスに特化したAPI。

## 目次

1. [RDT取得ワークフロー](#rdt取得ワークフロー)
2. [注文のPII取得用RDT](#注文のpii取得用rdt)
3. [レポートのPII取得用RDT](#レポートのpii取得用rdt)
4. [RDTを使ったAPI呼び出し](#rdtを使ったapi呼び出し)
5. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## RDT取得ワークフロー

```
1. createRestrictedDataToken → RDTを取得
2. RDTを x-amz-access-token ヘッダーに設定（通常のアクセストークンの代わり）
3. 制限付きオペレーションを呼び出し → PII情報が含まれるレスポンスを取得
```

> **注意:** RDTの有効期限は1時間。期限切れの場合は再取得が必要。

## 注文のPII取得用RDT

**エンドポイント:** `POST /tokens/2021-03-01/restrictedDataToken`
**レート制限:** 1リクエスト/秒（バースト: 10）

### Python

```python
import requests

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
HEADERS = {"x-amz-access-token": access_token, "Content-Type": "application/json"}

# 特定注文の購入者情報・配送先住所を取得するためのRDT
response = requests.post(
    f"{BASE_URL}/tokens/2021-03-01/restrictedDataToken",
    json={
        "restrictedResources": [
            {
                "method": "GET",
                "path": "/orders/2026-01-01/orders/250-1234567-1234567",
                "dataElements": ["buyerInfo", "shippingAddress"],
            }
        ]
    },
    headers=HEADERS,
)

rdt = response.json()["restrictedDataToken"]
expires_in = response.json()["expiresIn"]  # 秒数（通常3600）
print(f"RDT取得成功（有効期限: {expires_in}秒）")
```

### Python（複数注文のバルクRDT）

```python
# 複数の制限リソースをまとめてRDT取得
response = requests.post(
    f"{BASE_URL}/tokens/2021-03-01/restrictedDataToken",
    json={
        "restrictedResources": [
            {
                "method": "GET",
                "path": "/orders/2026-01-01/orders",
                "dataElements": ["buyerInfo", "shippingAddress"],
            },
            {
                "method": "GET",
                "path": "/orders/2026-01-01/orders/{orderId}/items",
                "dataElements": ["buyerInfo"],
            },
        ]
    },
    headers=HEADERS,
)

rdt = response.json()["restrictedDataToken"]
```

### Node.js/TypeScript

```typescript
const response = await axios.post(
  `${BASE_URL}/tokens/2021-03-01/restrictedDataToken`,
  {
    restrictedResources: [
      {
        method: 'GET',
        path: '/orders/2026-01-01/orders/250-1234567-1234567',
        dataElements: ['buyerInfo', 'shippingAddress'],
      },
    ],
  },
  { headers: HEADERS }
);

const rdt = response.data.restrictedDataToken;
const expiresIn = response.data.expiresIn;
```

### GAS

```javascript
function getRestrictedDataToken(restrictedResources) {
  const result = spApiRequest('POST', '/tokens/2021-03-01/restrictedDataToken', {
    restrictedResources: restrictedResources,
  });

  return result.restrictedDataToken;
}

function getRDTForOrders() {
  return getRestrictedDataToken([
    {
      method: 'GET',
      path: '/orders/2026-01-01/orders',
      dataElements: ['buyerInfo', 'shippingAddress'],
    },
  ]);
}
```

## レポートのPII取得用RDT

### Python

```python
# PII含有レポートのダウンロード用RDT
report_document_id = "amzn1.tortuga.xxxxxxxx"

response = requests.post(
    f"{BASE_URL}/tokens/2021-03-01/restrictedDataToken",
    json={
        "restrictedResources": [
            {
                "method": "GET",
                "path": f"/reports/2021-06-30/documents/{report_document_id}",
            }
        ]
    },
    headers=HEADERS,
)

rdt = response.json()["restrictedDataToken"]
```

## RDTを使ったAPI呼び出し

### Python

```python
# RDTを使って注文の購入者情報を取得
order_id = "250-1234567-1234567"

# 1. RDT取得
rdt_response = requests.post(
    f"{BASE_URL}/tokens/2021-03-01/restrictedDataToken",
    json={
        "restrictedResources": [
            {
                "method": "GET",
                "path": f"/orders/2026-01-01/orders/{order_id}",
                "dataElements": ["buyerInfo", "shippingAddress"],
            }
        ]
    },
    headers=HEADERS,
)
rdt = rdt_response.json()["restrictedDataToken"]

# 2. RDTを使ってオーダーを取得（通常のアクセストークンの代わりにRDTを使用）
order_response = requests.get(
    f"{BASE_URL}/orders/2026-01-01/orders/{order_id}",
    params={
        "marketplaceIds": MARKETPLACE_ID,
        "includedData": "BUYER,RECIPIENT,FULFILLMENT",
    },
    headers={"x-amz-access-token": rdt},
)

order = order_response.json()
buyer = order.get("buyer", {})
recipient = order.get("recipient", {})

print(f"購入者名: {buyer.get('name', 'N/A')}")
print(f"購入者メール: {buyer.get('email', 'N/A')}")
print(f"配送先名前: {recipient.get('name', 'N/A')}")
print(f"配送先住所: {recipient.get('address', {})}")
```

### GAS

```javascript
function getOrderWithPII(orderId) {
  // 1. RDT取得
  const rdt = getRestrictedDataToken([
    {
      method: 'GET',
      path: `/orders/2026-01-01/orders/${orderId}`,
      dataElements: ['buyerInfo', 'shippingAddress'],
    },
  ]);

  // 2. RDTを使ってAPI呼び出し
  const url =
    SP_API_CONFIG.endpoint +
    `/orders/2026-01-01/orders/${orderId}?marketplaceIds=${SP_API_CONFIG.marketplaceId}&includedData=BUYER,RECIPIENT`;

  const response = UrlFetchApp.fetch(url, {
    method: 'GET',
    headers: { 'x-amz-access-token': rdt },
  });

  return JSON.parse(response.getContentText());
}
```

## スプレッドシート連携（GAS）

### 注文の配送先情報をスプレッドシートに出力

```javascript
function exportOrderPIIToSheet(orderIds) {
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('配送先情報') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('配送先情報');

  const headers = ['注文ID', '購入者名', 'メール', '配送先名前', '郵便番号', '都道府県', '住所'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = [];
  for (const orderId of orderIds) {
    try {
      const order = getOrderWithPII(orderId);
      const buyer = order.buyer || {};
      const recipient = order.recipient || {};
      const address = recipient.address || {};

      rows.push([
        orderId,
        buyer.name || '',
        buyer.email || '',
        recipient.name || '',
        address.postalCode || '',
        address.stateOrRegion || '',
        [address.addressLine1, address.addressLine2, address.addressLine3]
          .filter(Boolean)
          .join(' '),
      ]);
    } catch (e) {
      rows.push([orderId, `エラー: ${e.message}`, '', '', '', '', '']);
    }
    Utilities.sleep(1000);
  }

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
}
```

## リファレンス

### RDTが必要な主要オペレーション

| API | オペレーション | dataElements |
|-----|---------------|-------------|
| Orders API | getOrders, getOrder | buyerInfo, shippingAddress |
| Orders API | getOrderItems | buyerInfo |
| Orders API | getOrderAddress | shippingAddress |
| Orders API | getOrderBuyerInfo | buyerInfo |
| Reports API | getReportDocument | （PII含有レポート） |
| Merchant Fulfillment | getShipment, createShipment | （全フィールド） |
| Shipping API | getShipment | （全フィールド） |

### dataElements

| 値 | 説明 |
|----|------|
| buyerInfo | 購入者の名前・メールアドレス |
| shippingAddress | 配送先住所 |

### restrictedResources構造

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| method | string | はい | HTTPメソッド（GET） |
| path | string | はい | APIパス |
| dataElements | string[] | いいえ | アクセスするデータ要素 |

### 必要なロール

以下のいずれかのロールが必要:
- Amazon Fulfillment
- Buyer Communication
- Finance and Accounting
- Inventory and Order Tracking
- Product Listing
