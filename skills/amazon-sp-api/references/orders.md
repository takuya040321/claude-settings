---
name: amazon-sp-api-orders
description: Amazon SP-API Orders API v2026-01-01に特化したスキル。注文の検索（searchOrders）、注文詳細の取得（getOrder）、出荷通知（confirmShipment/v0）をPython/Node.js/GASで実装。ユーザーが「注文を取得して」「未出荷注文を確認して」「出荷通知を送って」「注文データをスプレッドシートに出力して」などと依頼した場合にトリガー。
---

# Orders API v2026-01-01

注文の検索・取得・管理に特化したAPI。v0の10オペレーションが **2オペレーション** に集約された。

> **注意:** confirmShipment は v2026-01-01 に含まれず、引き続き `/orders/v0/orders/{orderId}/shipmentConfirmation` を使用する。

## 目次

1. [注文の検索（searchOrders）](#注文の検索searchorders)
2. [注文の取得（getOrder）](#注文の取得getorder)
3. [出荷通知（confirmShipment / v0）](#出荷通知confirmshipment--v0)
4. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## v0 → v2026-01-01 オペレーション対応表

| v0 オペレーション | v2026-01-01 |
|-------------------|-------------|
| getOrders | **searchOrders** |
| getOrder | **getOrder** |
| getOrderItems | **getOrder**（orderItemsが常に含まれる） |
| getOrderBuyerInfo | **getOrder** + `includedData=BUYER` |
| getOrderAddress | **getOrder** + `includedData=RECIPIENT` |
| getOrderItemsBuyerInfo | **getOrder** + `includedData=BUYER` |

## 注文の検索（searchOrders）

`GET /orders/2026-01-01/orders`

### クエリパラメータ

| パラメータ | 型 | 説明 |
|-----------|------|------|
| createdAfter | date-time | 注文作成日時（以降） |
| createdBefore | date-time | 注文作成日時（以前） |
| lastUpdatedAfter | date-time | 最終更新日時（以降） |
| lastUpdatedBefore | date-time | 最終更新日時（以前） |
| fulfillmentStatuses | string[] | フルフィルメントステータスフィルタ |
| marketplaceIds | string[] | マーケットプレイスID（最大50） |
| fulfilledBy | string[] | `MERCHANT` または `AMAZON`（v0の `MFN`/`AFN` に相当） |
| maxResultsPerPage | integer | 最大100（デフォルト100） |
| paginationToken | string | ページネーショントークン（24時間で有効期限切れ） |
| includedData | string[] | 取得するデータを選択（下記参照） |

### includedData パラメータ

| 値 | 説明 |
|----|------|
| BUYER | 購入者情報（名前、メール[FBMのみ]、会社名） |
| RECIPIENT | 配送先住所・配送設定 |
| PROCEEDS | 売上・金額情報 |
| EXPENSE | 費用情報 |
| PROMOTION | プロモーション情報 |
| CANCELLATION | キャンセル情報 |
| FULFILLMENT | フルフィルメント詳細（出荷数量、梱包等） |
| PACKAGES | パッケージ・追跡情報（FBMのみ） |

### Python（直接HTTPリクエスト）

> **注意:** `python-amazon-sp-api` ライブラリは v2026-01-01 に未対応（2026年2月時点）。
> 公式SDK `amzn-sp-api` (v1.7.0+) は対応済み。直接HTTPリクエストまたは公式SDKを使用すること。

```python
import requests
from datetime import datetime, timedelta

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
MARKETPLACE_ID = "A1VC38T7YXB528"

def search_orders(access_token, days_back=7, statuses=None):
    """注文を検索する"""
    if statuses is None:
        statuses = ["UNSHIPPED", "PARTIALLY_SHIPPED"]

    params = {
        "marketplaceIds": MARKETPLACE_ID,
        "createdAfter": (datetime.now() - timedelta(days=days_back)).isoformat(),
        "fulfillmentStatuses": ",".join(statuses),
        "maxResultsPerPage": 100,
        "includedData": "BUYER,RECIPIENT,PROCEEDS,FULFILLMENT",
    }
    headers = {
        "x-amz-access-token": access_token,
        "Content-Type": "application/json",
    }

    response = requests.get(
        f"{BASE_URL}/orders/2026-01-01/orders",
        params=params,
        headers=headers,
    )
    response.raise_for_status()
    data = response.json()

    for order in data.get("orders", []):
        print(f"Order: {order['orderId']} - {order['fulfillment']['fulfillmentStatus']}")
        print(f"Created: {order['createdTime']}")

    return data
```

### Python（公式SDK amzn-sp-api）

```python
# pip install amzn-sp-api>=1.7.0
from amzn_sp_api.orders import OrdersApi
from datetime import datetime, timedelta

orders_api = OrdersApi(credentials=credentials, region="fe")

response = orders_api.search_orders(
    marketplace_ids=["A1VC38T7YXB528"],
    created_after=(datetime.now() - timedelta(days=7)).isoformat(),
    fulfillment_statuses=["UNSHIPPED", "PARTIALLY_SHIPPED"],
    max_results_per_page=100,
    included_data=["BUYER", "RECIPIENT", "PROCEEDS"],
)

for order in response.orders:
    print(f"Order: {order.order_id} - {order.fulfillment.fulfillment_status}")
```

### Node.js/TypeScript（@sp-api-sdk）

```typescript
// npm install @sp-api-sdk/orders-api-2026-01-01 @sp-api-sdk/auth
import { SellingPartnerApiAuth } from '@sp-api-sdk/auth';
import { OrdersApiClient } from '@sp-api-sdk/orders-api-2026-01-01';

const auth = new SellingPartnerApiAuth({
  clientId: 'YOUR_CLIENT_ID',
  clientSecret: 'YOUR_CLIENT_SECRET',
  refreshToken: 'YOUR_REFRESH_TOKEN',
});

const client = new OrdersApiClient({ auth, region: 'fe' });

const response = await client.searchOrders({
  marketplaceIds: ['A1VC38T7YXB528'],
  createdAfter: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
  fulfillmentStatuses: ['UNSHIPPED', 'PARTIALLY_SHIPPED'],
  maxResultsPerPage: 100,
  includedData: ['BUYER', 'RECIPIENT', 'PROCEEDS'],
});

for (const order of response.orders ?? []) {
  console.log(`Order: ${order.orderId} - ${order.fulfillment?.fulfillmentStatus}`);
}
```

### Node.js/TypeScript（直接HTTPリクエスト）

```typescript
const BASE_URL = 'https://sellingpartnerapi-fe.amazon.com';

async function searchOrders(accessToken: string, daysBack = 7) {
  const params = new URLSearchParams({
    marketplaceIds: 'A1VC38T7YXB528',
    createdAfter: new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000).toISOString(),
    fulfillmentStatuses: 'UNSHIPPED,PARTIALLY_SHIPPED',
    maxResultsPerPage: '100',
    includedData: 'BUYER,RECIPIENT,PROCEEDS,FULFILLMENT',
  });

  const response = await fetch(`${BASE_URL}/orders/2026-01-01/orders?${params}`, {
    headers: {
      'x-amz-access-token': accessToken,
      'Content-Type': 'application/json',
    },
  });

  const data = await response.json();
  for (const order of data.orders ?? []) {
    console.log(`Order: ${order.orderId} - ${order.fulfillment?.fulfillmentStatus}`);
  }
  return data;
}
```

### GAS

```javascript
function searchOrders(daysBack = 7, statuses = ['UNSHIPPED', 'PARTIALLY_SHIPPED']) {
  const createdAfter = new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000).toISOString();

  const result = spApiGet('/orders/2026-01-01/orders', {
    marketplaceIds: SP_API_CONFIG.marketplaceId,
    createdAfter: createdAfter,
    fulfillmentStatuses: statuses.join(','),
    maxResultsPerPage: 100,
    includedData: 'BUYER,RECIPIENT,PROCEEDS,FULFILLMENT',
  });

  return result.orders || [];
}
```

### ページネーション

```python
def search_all_orders(access_token, days_back=7, statuses=None):
    """全ページの注文を取得する"""
    all_orders = []
    pagination_token = None

    while True:
        params = {
            "marketplaceIds": MARKETPLACE_ID,
            "createdAfter": (datetime.now() - timedelta(days=days_back)).isoformat(),
            "maxResultsPerPage": 100,
        }
        if statuses:
            params["fulfillmentStatuses"] = ",".join(statuses)
        if pagination_token:
            params["paginationToken"] = pagination_token

        response = requests.get(
            f"{BASE_URL}/orders/2026-01-01/orders",
            params=params,
            headers={"x-amz-access-token": access_token},
        )
        response.raise_for_status()
        data = response.json()

        all_orders.extend(data.get("orders", []))
        pagination_token = data.get("pagination", {}).get("nextToken")

        if not pagination_token:
            break

    return all_orders
```

## 注文の取得（getOrder）

`GET /orders/2026-01-01/orders/{orderId}`

v0では注文詳細・アイテム・購入者情報・配送先を別々のAPIで取得していたが、v2026-01-01ではgetOrder 1回で取得可能。

### includedData による取得データの制御

```
GET /orders/2026-01-01/orders/{orderId}?includedData=BUYER,RECIPIENT,PROCEEDS,FULFILLMENT,PACKAGES
```

### Python（直接HTTPリクエスト）

```python
def get_order(access_token, order_id):
    """注文詳細を取得する（アイテム含む）"""
    params = {
        "includedData": "BUYER,RECIPIENT,PROCEEDS,FULFILLMENT,PACKAGES",
    }
    headers = {
        "x-amz-access-token": access_token,
        "Content-Type": "application/json",
    }

    response = requests.get(
        f"{BASE_URL}/orders/2026-01-01/orders/{order_id}",
        params=params,
        headers=headers,
    )
    response.raise_for_status()
    order = response.json()["order"]

    print(f"注文ID: {order['orderId']}")
    print(f"注文日時: {order['createdTime']}")
    print(f"購入者: {order.get('buyer', {}).get('buyerName', 'N/A')}")
    print(f"配送先: {order.get('recipient', {}).get('deliveryAddress', {}).get('city', 'N/A')}")

    # 注文アイテム（常にレスポンスに含まれる）
    for item in order.get("orderItems", []):
        print(f"  商品: {item['product'].get('title', 'N/A')}")
        print(f"  ASIN: {item['product']['asin']}")
        print(f"  数量: {item['quantityOrdered']}")

    return order
```

### Node.js/TypeScript（@sp-api-sdk）

```typescript
const order = await client.getOrder({
  orderId: '123-1234567-1234567',
  includedData: ['BUYER', 'RECIPIENT', 'PROCEEDS', 'FULFILLMENT', 'PACKAGES'],
});

console.log(`注文ID: ${order.order.orderId}`);
console.log(`購入者: ${order.order.buyer?.buyerName}`);

for (const item of order.order.orderItems ?? []) {
  console.log(`  ASIN: ${item.product?.asin} x ${item.quantityOrdered}`);
}
```

### GAS

```javascript
function getOrderDetail(orderId) {
  const result = spApiGet(`/orders/2026-01-01/orders/${orderId}`, {
    includedData: 'BUYER,RECIPIENT,PROCEEDS,FULFILLMENT,PACKAGES',
  });
  return result.order;
}

function getOrderItems(orderId) {
  // v2026-01-01ではgetOrderのレスポンスにorderItemsが含まれる
  const order = getOrderDetail(orderId);
  return order.orderItems || [];
}
```

## 出荷通知（confirmShipment / v0）

自社出荷（MERCHANT）注文の出荷完了を通知。

> **注意:** confirmShipment は v2026-01-01 には含まれない。引き続き **v0エンドポイント** を使用する。
> `POST /orders/v0/orders/{orderId}/shipmentConfirmation`
> v0の廃止対象に含まれていないため、今後も利用可能。

### Python

```python
def confirm_shipment(access_token, order_id, order_item_id, tracking_number, carrier_code="YAMATO"):
    """出荷通知を送信する（v0エンドポイント）"""
    body = {
        "marketplaceId": MARKETPLACE_ID,
        "packageDetail": {
            "packageReferenceId": f"pkg-{int(datetime.now().timestamp())}",
            "carrierCode": carrier_code,
            "trackingNumber": tracking_number,
            "shipDate": datetime.now().isoformat(),
            "orderItems": [
                {"orderItemId": order_item_id, "quantity": 1}
            ],
        },
    }

    response = requests.post(
        f"{BASE_URL}/orders/v0/orders/{order_id}/shipmentConfirmation",
        json=body,
        headers={
            "x-amz-access-token": access_token,
            "Content-Type": "application/json",
        },
    )
    response.raise_for_status()
    return response.json()
```

### Node.js/TypeScript

```typescript
async function confirmShipment(
  accessToken: string,
  orderId: string,
  orderItemId: string,
  trackingNumber: string,
  carrierCode = 'YAMATO',
) {
  // confirmShipmentはv0エンドポイントを使用
  const body = {
    marketplaceId: 'A1VC38T7YXB528',
    packageDetail: {
      packageReferenceId: `pkg-${Date.now()}`,
      carrierCode,
      trackingNumber,
      shipDate: new Date().toISOString(),
      orderItems: [{ orderItemId, quantity: 1 }],
    },
  };

  const response = await fetch(
    `${BASE_URL}/orders/v0/orders/${orderId}/shipmentConfirmation`,
    {
      method: 'POST',
      headers: {
        'x-amz-access-token': accessToken,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    },
  );

  return response.json();
}
```

### GAS

```javascript
function confirmShipment(orderId, orderItemId, trackingNumber, carrierCode = 'YAMATO') {
  // confirmShipmentはv0エンドポイントを使用
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
  const orders = searchOrders(7, ['UNSHIPPED', 'PARTIALLY_SHIPPED', 'SHIPPED']);
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Orders') ||
                SpreadsheetApp.getActiveSpreadsheet().insertSheet('Orders');

  const headers = ['注文ID', 'ステータス', '注文日時', '購入者', '配送先', 'チャネル'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = orders.map(o => [
    o.orderId,
    o.fulfillment?.fulfillmentStatus || '',
    o.createdTime,
    o.buyer?.buyerName || '',
    o.recipient?.deliveryAddress?.city || '',
    o.fulfillment?.fulfilledBy || '',
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
  const order = getOrderDetail(orderId);
  const items = order.orderItems || [];
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('OrderItems') ||
                SpreadsheetApp.getActiveSpreadsheet().insertSheet('OrderItems');

  const headers = ['注文ID', 'ASIN', 'SKU', '商品名', '数量', 'ステータス'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = items.map(i => [
    orderId,
    i.product?.asin || '',
    i.product?.sellerSku || '',
    i.product?.title || '',
    i.quantityOrdered,
    i.fulfillment?.fulfillmentStatus || '',
  ]);

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
}
```

## リファレンス

### フルフィルメントステータス

| ステータス | 説明 |
|-----------|------|
| PENDING | 支払い待ち |
| UNSHIPPED | 未出荷 |
| PARTIALLY_SHIPPED | 一部出荷済み |
| SHIPPED | 出荷済み |
| CANCELLED | キャンセル |
| UNFULFILLABLE | 出荷不可 |
| PENDING_AVAILABILITY | 在庫待ち |

### fulfilledBy（v0 FulfillmentChannel からの変更）

| v0 | v2026-01-01 | 説明 |
|----|-------------|------|
| MFN | MERCHANT | 自社出荷 |
| AFN | AMAZON | FBA出荷 |

### 主要フィールド名の変更

| v0 | v2026-01-01 |
|----|-------------|
| AmazonOrderId | orderId |
| OrderStatus | fulfillment.fulfillmentStatus |
| PurchaseDate | createdTime |
| LastUpdateDate | lastUpdatedTime |
| OrderTotal.Amount | proceeds 内 |
| ShippingAddress | recipient.deliveryAddress |
| BuyerInfo.BuyerEmail | buyer.buyerEmail |
| FulfillmentChannel | fulfillment.fulfilledBy |
| IsPrime | programs 配列に `PRIME` |
| IsBusinessOrder | programs 配列に `AMAZON_BUSINESS` |

### Order オブジェクト構造

```
orderId*               string          - 注文ID
aliases                Alias[]         - 注文エイリアス
createdTime*           date-time       - 注文作成日時
lastUpdatedTime*       date-time       - 最終更新日時
programs               string[]        - PRIME, AMAZON_BUSINESS, PREORDER等
salesChannel*          SalesChannel    - channelName, marketplaceId, marketplaceName
buyer                  Buyer           - buyerName, buyerEmail(FBMのみ), buyerCompanyName
recipient              Recipient       - deliveryAddress, deliveryPreference
proceeds               OrderProceeds   - 売上情報
fulfillment            OrderFulfillment - fulfillmentStatus, fulfilledBy, shipByWindow等
orderItems*            OrderItem[]     - 注文アイテム（常に含まれる）
packages               OrderPackage[]  - パッケージ情報（FBMのみ、includedData=PACKAGES時）
```

### OrderItem 構造

```
orderItemId*           string          - アイテムID
quantityOrdered*       integer         - 注文数量
product*               ItemProduct     - asin, sellerSku, title, condition等
proceeds               ItemProceeds    - 売上情報（includedData=PROCEEDS時）
expense                ItemExpense     - 費用情報（includedData=EXPENSE時）
promotion              ItemPromotion   - プロモーション情報（includedData=PROMOTION時）
cancellation           ItemCancellation - キャンセル情報（includedData=CANCELLATION時）
fulfillment            ItemFulfillment - フルフィルメント詳細（includedData=FULFILLMENT時）
```

### 日本の配送業者コード

| コード | 配送業者 |
|--------|---------|
| YAMATO | ヤマト運輸 |
| SAGAWA | 佐川急便 |
| JP_POST | 日本郵便 |
| SEINO | 西濃運輸 |
| FUKUYAMA | 福山通運 |

### ライブラリ対応状況（2026年2月時点）

| ライブラリ | v2026-01-01対応 | 備考 |
|-----------|----------------|------|
| amzn-sp-api (Python公式) | ✅ v1.7.0+ | Amazon公式SDK |
| python-amazon-sp-api (サードパーティ) | ❌ 未対応 | v0のみ対応 |
| @sp-api-sdk/orders-api-2026-01-01 (Node.js) | ✅ | Bizon SDK |
| @amazon-sp-api-release (Node.js公式) | ✅ v1.7.0+ | Amazon公式SDK |
| amazon-sp-api (amz-tools) | ❓ 未確認 | v0のみドキュメント化 |

### 移行時の注意事項

- **RDTが不要に:** v2026-01-01ではRestricted Data Tokenが不要。アプリケーションロールでPIIアクセスを制御
- **paginationTokenの有効期限:** 24時間で失効（v0のNextTokenには期限なし）
- **v0の廃止スケジュール:** 2026年1月28日に非推奨化、2027年3月27日に完全廃止
- **confirmShipmentはv0のまま:** v2026-01-01の廃止対象に含まれていない
