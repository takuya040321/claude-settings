---
name: amazon-sp-api-orders
description: Amazon SP-API Orders APIに特化したスキル。注文一覧の取得、注文詳細の取得、注文アイテムの取得、出荷通知（MFN）をPython/Node.js/GASで実装。ユーザーが「注文を取得して」「未出荷注文を確認して」「出荷通知を送って」「注文データをスプレッドシートに出力して」などと依頼した場合にトリガー。
---

# Orders API

注文の取得・管理・出荷通知に特化したAPI。

## 目次

1. [注文一覧の取得](#注文一覧の取得)
2. [注文詳細の取得](#注文詳細の取得)
3. [注文アイテムの取得](#注文アイテムの取得)
4. [出荷通知（MFN）](#出荷通知mfn)
5. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## 注文一覧の取得

### Python

```python
from sp_api.api import Orders
from sp_api.base import Marketplaces
from datetime import datetime, timedelta

orders_api = Orders(credentials=credentials, marketplace=Marketplaces.JP)

# 過去7日間の未出荷注文を取得
created_after = (datetime.now() - timedelta(days=7)).isoformat()
response = orders_api.get_orders(
    CreatedAfter=created_after,
    OrderStatuses=["Unshipped", "PartiallyShipped"],
    MaxResultsPerPage=100,
)

for order in response.payload.get("Orders", []):
    print(f"Order: {order['AmazonOrderId']} - {order['OrderStatus']}")
    print(f"Total: {order.get('OrderTotal', {}).get('Amount', 'N/A')}")
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'getOrders',
  endpoint: 'orders',
  query: {
    MarketplaceIds: ['A1VC38T7YXB528'],
    CreatedAfter: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
    OrderStatuses: ['Unshipped', 'PartiallyShipped'],
    MaxResultsPerPage: 100,
  },
});

for (const order of response.Orders || []) {
  console.log(`Order: ${order.AmazonOrderId} - ${order.OrderStatus}`);
}
```

### GAS

```javascript
function getOrders(daysBack = 7, statuses = ['Unshipped', 'PartiallyShipped']) {
  const createdAfter = new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000).toISOString();

  const result = spApiGet('/orders/v0/orders', {
    MarketplaceIds: SP_API_CONFIG.marketplaceId,
    CreatedAfter: createdAfter,
    OrderStatuses: statuses.join(','),
    MaxResultsPerPage: 100,
  });

  return result.payload?.Orders || [];
}
```

## 注文詳細の取得

### Python

```python
order_id = "123-1234567-1234567"
response = orders_api.get_order(order_id)
order = response.payload

print(f"購入者: {order.get('BuyerInfo', {}).get('BuyerEmail', 'N/A')}")
print(f"配送先: {order.get('ShippingAddress', {}).get('City', 'N/A')}")
print(f"配送先住所: {order.get('ShippingAddress', {}).get('AddressLine1', 'N/A')}")
```

### Node.js/TypeScript

```typescript
const order = await sp.callAPI({
  operation: 'getOrder',
  endpoint: 'orders',
  path: { orderId: '123-1234567-1234567' },
});
```

### GAS

```javascript
function getOrderDetail(orderId) {
  const result = spApiGet(`/orders/v0/orders/${orderId}`);
  return result.payload;
}
```

## 注文アイテムの取得

### Python

```python
order_id = "123-1234567-1234567"
response = orders_api.get_order_items(order_id)

for item in response.payload.get("OrderItems", []):
    print(f"ASIN: {item['ASIN']}")
    print(f"SKU: {item['SellerSKU']}")
    print(f"数量: {item['QuantityOrdered']}")
    print(f"価格: {item.get('ItemPrice', {}).get('Amount', 'N/A')}")
```

### Node.js/TypeScript

```typescript
const items = await sp.callAPI({
  operation: 'getOrderItems',
  endpoint: 'orders',
  path: { orderId: '123-1234567-1234567' },
});

for (const item of items.OrderItems || []) {
  console.log(`${item.ASIN}: ${item.QuantityOrdered}個`);
}
```

### GAS

```javascript
function getOrderItems(orderId) {
  const result = spApiGet(`/orders/v0/orders/${orderId}/orderItems`);
  return result.payload?.OrderItems || [];
}
```

## 出荷通知（MFN）

自社出荷（MFN）注文の出荷完了を通知。

### Python

```python
order_id = "123-1234567-1234567"

shipment = {
    "marketplaceId": "A1VC38T7YXB528",
    "packageDetail": {
        "packageReferenceId": f"pkg-{int(datetime.now().timestamp())}",
        "carrierCode": "YAMATO",
        "trackingNumber": "1234567890",
        "shipDate": datetime.now().isoformat(),
        "orderItems": [
            {"orderItemId": "item-id-123", "quantity": 1}
        ],
    },
}

response = orders_api.confirm_shipment(order_id, shipment)
```

### Node.js/TypeScript

```typescript
await sp.callAPI({
  operation: 'confirmShipment',
  endpoint: 'orders',
  path: { orderId: '123-1234567-1234567' },
  body: {
    marketplaceId: 'A1VC38T7YXB528',
    packageDetail: {
      packageReferenceId: `pkg-${Date.now()}`,
      carrierCode: 'YAMATO',
      trackingNumber: '1234567890',
      shipDate: new Date().toISOString(),
      orderItems: [{ orderItemId: 'item-id-123', quantity: 1 }],
    },
  },
});
```

### GAS

```javascript
function confirmShipment(orderId, orderItemId, trackingNumber, carrierCode = 'YAMATO') {
  const body = {
    marketplaceId: SP_API_CONFIG.marketplaceId,
    packageDetail: {
      packageReferenceId: `pkg-${Date.now()}`,
      carrierCode: carrierCode,
      trackingNumber: trackingNumber,
      shipDate: new Date().toISOString(),
      orderItems: [{ orderItemId: orderItemId, quantity: 1 }],
    },
  };

  return spApiRequest('POST', `/orders/v0/orders/${orderId}/shipmentConfirmation`, body);
}
```

## スプレッドシート連携（GAS）

### 注文をスプレッドシートに出力

```javascript
function exportOrdersToSheet() {
  const orders = getOrders(7, ['Unshipped', 'PartiallyShipped', 'Shipped']);
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Orders') ||
                SpreadsheetApp.getActiveSpreadsheet().insertSheet('Orders');

  const headers = ['注文ID', 'ステータス', '注文日', '合計金額', '通貨', '配送先'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = orders.map(o => [
    o.AmazonOrderId,
    o.OrderStatus,
    o.PurchaseDate,
    o.OrderTotal?.Amount || '',
    o.OrderTotal?.CurrencyCode || '',
    o.ShippingAddress?.City || '',
  ]);

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }

  return rows.length;
}
```

### 注文アイテム詳細を出力

```javascript
function exportOrderItemsToSheet(orderId) {
  const items = getOrderItems(orderId);
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('OrderItems') ||
                SpreadsheetApp.getActiveSpreadsheet().insertSheet('OrderItems');

  const headers = ['注文ID', 'ASIN', 'SKU', '商品名', '数量', '価格'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = items.map(i => [
    orderId,
    i.ASIN,
    i.SellerSKU,
    i.Title,
    i.QuantityOrdered,
    i.ItemPrice?.Amount || '',
  ]);

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
}
```

## リファレンス

### 注文ステータス

| ステータス | 説明 |
|-----------|------|
| Pending | 支払い待ち |
| Unshipped | 未出荷 |
| PartiallyShipped | 一部出荷済み |
| Shipped | 出荷済み |
| Canceled | キャンセル |
| Unfulfillable | 出荷不可 |

### 日本の配送業者コード

| コード | 配送業者 |
|--------|---------|
| YAMATO | ヤマト運輸 |
| SAGAWA | 佐川急便 |
| JP_POST | 日本郵便 |
| SEINO | 西濃運輸 |
| FUKUYAMA | 福山通運 |

### クエリパラメータ

| パラメータ | 説明 |
|-----------|------|
| CreatedAfter | 注文作成日時（ISO 8601） |
| CreatedBefore | 注文作成日時上限 |
| OrderStatuses | ステータスフィルタ |
| FulfillmentChannels | MFN/AFN |
| MaxResultsPerPage | 最大100 |
