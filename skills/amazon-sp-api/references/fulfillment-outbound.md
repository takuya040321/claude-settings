---
name: amazon-sp-api-fulfillment-outbound
description: Amazon SP-API Fulfillment Outbound APIに特化したスキル。MCF（マルチチャネルフルフィルメント）注文の作成・管理・追跡をPython/Node.js/GASで実装。ユーザーが「MCF注文を作成して」「FBAマルチチャネルで出荷して」「フルフィルメント注文を追跡して」「FBA在庫を使って出荷して」などと依頼した場合にトリガー。
---

# Fulfillment Outbound API

MCF（マルチチャネルフルフィルメント）注文の作成・管理・追跡に特化したAPI。FBA在庫を使って自社ECサイト等の注文を出荷。

## 目次

1. [フルフィルメントプレビューの取得](#フルフィルメントプレビューの取得)
2. [フルフィルメント注文の作成](#フルフィルメント注文の作成)
3. [注文の追跡・管理](#注文の追跡管理)
4. [注文のキャンセル](#注文のキャンセル)
5. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## フルフィルメントプレビューの取得

**エンドポイント:** `POST /fba/outbound/2020-07-01/fulfillmentOrders/preview`
**レート制限:** 2リクエスト/秒（バースト: 30）

### Python

```python
import requests

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
MARKETPLACE_ID = "A1VC38T7YXB528"
HEADERS = {"x-amz-access-token": access_token, "Content-Type": "application/json"}

response = requests.post(
    f"{BASE_URL}/fba/outbound/2020-07-01/fulfillmentOrders/preview",
    json={
        "marketplaceId": MARKETPLACE_ID,
        "address": {
            "name": "山田太郎",
            "addressLine1": "東京都渋谷区1-1-1",
            "city": "渋谷区",
            "stateOrRegion": "東京都",
            "postalCode": "150-0001",
            "countryCode": "JP",
        },
        "items": [
            {
                "sellerSku": "MY-SKU-001",
                "sellerFulfillmentOrderItemId": "item-001",
                "quantity": 1,
            }
        ],
        "shippingSpeedCategories": ["Standard", "Expedited", "Priority"],
    },
    headers=HEADERS,
)

for preview in response.json().get("payload", {}).get("fulfillmentPreviews", []):
    print(f"配送速度: {preview['shippingSpeedCategory']}")
    print(f"  配送予定: {preview.get('estimatedDeliveryDate')}")
    print(f"  手数料: {preview.get('estimatedFees', [])}")
    print(f"  配送可能: {preview['isFulfillable']}")
```

### GAS

```javascript
function getFulfillmentPreview(address, items) {
  const result = spApiRequest(
    'POST',
    '/fba/outbound/2020-07-01/fulfillmentOrders/preview',
    {
      marketplaceId: SP_API_CONFIG.marketplaceId,
      address: address,
      items: items,
      shippingSpeedCategories: ['Standard', 'Expedited', 'Priority'],
    }
  );

  return result.payload?.fulfillmentPreviews || [];
}
```

## フルフィルメント注文の作成

**エンドポイント:** `POST /fba/outbound/2020-07-01/fulfillmentOrders`
**レート制限:** 2リクエスト/秒（バースト: 30）

### Python

```python
response = requests.post(
    f"{BASE_URL}/fba/outbound/2020-07-01/fulfillmentOrders",
    json={
        "marketplaceId": MARKETPLACE_ID,
        "sellerFulfillmentOrderId": "MCF-2026-0001",
        "displayableOrderId": "EC-2026-0001",
        "displayableOrderDate": "2026-01-15T10:00:00Z",
        "displayableOrderComment": "自社ECサイトからの注文",
        "shippingSpeedCategory": "Standard",
        "destinationAddress": {
            "name": "山田太郎",
            "addressLine1": "東京都渋谷区1-1-1",
            "city": "渋谷区",
            "stateOrRegion": "東京都",
            "postalCode": "150-0001",
            "countryCode": "JP",
            "phone": "03-1234-5678",
        },
        "items": [
            {
                "sellerSku": "MY-SKU-001",
                "sellerFulfillmentOrderItemId": "item-001",
                "quantity": 2,
                "displayableComment": "ワイヤレスイヤホン x2",
            }
        ],
        "notificationEmails": ["seller@example.com"],
    },
    headers=HEADERS,
)

if response.status_code == 200:
    print("MCF注文作成成功")
```

### Node.js/TypeScript

```typescript
const response = await axios.post(
  `${BASE_URL}/fba/outbound/2020-07-01/fulfillmentOrders`,
  {
    marketplaceId: 'A1VC38T7YXB528',
    sellerFulfillmentOrderId: 'MCF-2026-0001',
    displayableOrderId: 'EC-2026-0001',
    displayableOrderDate: '2026-01-15T10:00:00Z',
    displayableOrderComment: '自社ECサイトからの注文',
    shippingSpeedCategory: 'Standard',
    destinationAddress: {
      name: '山田太郎',
      addressLine1: '東京都渋谷区1-1-1',
      city: '渋谷区',
      stateOrRegion: '東京都',
      postalCode: '150-0001',
      countryCode: 'JP',
    },
    items: [
      {
        sellerSku: 'MY-SKU-001',
        sellerFulfillmentOrderItemId: 'item-001',
        quantity: 2,
      },
    ],
  },
  { headers: HEADERS }
);
```

## 注文の追跡・管理

### 注文一覧の取得

**エンドポイント:** `GET /fba/outbound/2020-07-01/fulfillmentOrders`

```python
response = requests.get(
    f"{BASE_URL}/fba/outbound/2020-07-01/fulfillmentOrders",
    params={"queryStartDate": "2026-01-01T00:00:00Z"},
    headers=HEADERS,
)

for order in response.json().get("payload", {}).get("fulfillmentOrders", []):
    print(f"注文ID: {order['sellerFulfillmentOrderId']}")
    print(f"ステータス: {order['fulfillmentOrderStatus']}")
    print(f"配送速度: {order['shippingSpeedCategory']}")
```

### 注文詳細の取得

**エンドポイント:** `GET /fba/outbound/2020-07-01/fulfillmentOrders/{sellerFulfillmentOrderId}`

```python
order_id = "MCF-2026-0001"

response = requests.get(
    f"{BASE_URL}/fba/outbound/2020-07-01/fulfillmentOrders/{order_id}",
    headers=HEADERS,
)

order = response.json().get("payload", {})
print(f"ステータス: {order.get('fulfillmentOrder', {}).get('fulfillmentOrderStatus')}")

for shipment in order.get("fulfillmentShipments", []):
    print(f"出荷ID: {shipment['amazonShipmentId']}")
    print(f"  ステータス: {shipment['fulfillmentShipmentStatus']}")
    for pkg in shipment.get("fulfillmentShipmentPackage", []):
        print(f"  追跡番号: {pkg.get('trackingNumber')}")
```

### 荷物追跡

**エンドポイント:** `GET /fba/outbound/2020-07-01/tracking`

```python
response = requests.get(
    f"{BASE_URL}/fba/outbound/2020-07-01/tracking",
    params={"packageNumber": "1234567890"},
    headers=HEADERS,
)

tracking = response.json().get("payload", {})
print(f"ステータス: {tracking.get('trackingEvents', [])}")
```

## 注文のキャンセル

**エンドポイント:** `PUT /fba/outbound/2020-07-01/fulfillmentOrders/{sellerFulfillmentOrderId}/cancel`

```python
order_id = "MCF-2026-0001"

response = requests.put(
    f"{BASE_URL}/fba/outbound/2020-07-01/fulfillmentOrders/{order_id}/cancel",
    headers=HEADERS,
)

if response.status_code == 200:
    print("MCF注文キャンセル成功")
```

## スプレッドシート連携（GAS）

### MCF注文一覧をスプレッドシートに出力

```javascript
function exportMCFOrders(daysBack = 30) {
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('MCF注文') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('MCF注文');

  const startDate = new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000).toISOString();

  const result = spApiGet('/fba/outbound/2020-07-01/fulfillmentOrders', {
    queryStartDate: startDate,
  });

  const headers = ['注文ID', '表示ID', 'ステータス', '配送速度', '作成日', '配送先'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const orders = result.payload?.fulfillmentOrders || [];
  const rows = orders.map((o) => [
    o.sellerFulfillmentOrderId || '',
    o.displayableOrderId || '',
    o.fulfillmentOrderStatus || '',
    o.shippingSpeedCategory || '',
    o.receivedDate || '',
    o.destinationAddress?.name || '',
  ]);

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
}
```

## リファレンス

### 配送速度カテゴリ

| 値 | 説明 |
|----|------|
| Standard | 通常配送 |
| Expedited | お急ぎ便 |
| Priority | 最優先配送 |
| ScheduledDelivery | 日時指定配送（日本） |

### フルフィルメント注文ステータス

| ステータス | 説明 |
|-----------|------|
| New | 新規 |
| Received | 受付済み |
| Planning | 計画中 |
| Processing | 処理中 |
| Complete | 完了 |
| CompletePartialled | 一部完了 |
| Unfulfillable | 出荷不可 |
| Invalid | 無効 |
| Cancelled | キャンセル済み |

### 出荷ステータス

| ステータス | 説明 |
|-----------|------|
| PENDING | 保留中 |
| SHIPPED | 出荷済み |
| CANCELLED_BY_FULFILLER | フルフィラーがキャンセル |
| CANCELLED_BY_SELLER | セラーがキャンセル |

### 主要オペレーションとレート制限

| オペレーション | メソッド | レート | バースト |
|---------------|---------|--------|---------|
| getFulfillmentPreview | POST | 2/秒 | 30 |
| createFulfillmentOrder | POST | 2/秒 | 30 |
| listAllFulfillmentOrders | GET | 2/秒 | 30 |
| getFulfillmentOrder | GET | 2/秒 | 30 |
| updateFulfillmentOrder | PUT | 2/秒 | 30 |
| cancelFulfillmentOrder | PUT | 2/秒 | 30 |
| getPackageTrackingDetails | GET | 2/秒 | 30 |
| listReturnReasonCodes | GET | 2/秒 | 30 |
| createFulfillmentReturn | PUT | 2/秒 | 30 |
