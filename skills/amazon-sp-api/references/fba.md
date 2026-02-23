---
name: amazon-sp-api-fba
description: Amazon SP-API FBA Inventory APIに特化したスキル。FBA在庫の確認、在庫サマリーの取得、FBA入荷プラン作成をPython/Node.js/GASで実装。ユーザーが「在庫を確認して」「FBA在庫数を教えて」「入荷プランを作成して」「在庫レポートを出力して」などと依頼した場合にトリガー。
---

# FBA Inventory API

FBA在庫の管理・確認・入荷プランに特化したAPI。

## 目次

1. [在庫サマリーの取得](#在庫サマリーの取得)
2. [SKU別在庫詳細](#sku別在庫詳細)
3. [FBA入荷プラン作成](#fba入荷プラン作成)
4. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## 在庫サマリーの取得

### Python

```python
from sp_api.api import Inventories
from sp_api.base import Marketplaces

inventory_api = Inventories(credentials=credentials, marketplace=Marketplaces.JP)

# FBA在庫サマリーを取得
response = inventory_api.get_inventory_summary_marketplace(
    details=True,
    granularityType="Marketplace",
    granularityId="A1VC38T7YXB528",
    marketplaceIds=["A1VC38T7YXB528"],
)

for item in response.payload.get("inventorySummaries", []):
    print(f"ASIN: {item['asin']}")
    print(f"SKU: {item['sellerSku']}")
    print(f"在庫数: {item.get('totalQuantity', 0)}")
    print(f"販売可能: {item.get('inventoryDetails', {}).get('fulfillableQuantity', 0)}")
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'getInventorySummaries',
  endpoint: 'fbaInventory',
  query: {
    details: true,
    granularityType: 'Marketplace',
    granularityId: 'A1VC38T7YXB528',
    marketplaceIds: ['A1VC38T7YXB528'],
  },
});

for (const item of response.inventorySummaries || []) {
  console.log(`ASIN: ${item.asin}, SKU: ${item.sellerSku}`);
  console.log(`在庫数: ${item.totalQuantity}`);
}
```

### GAS

```javascript
function getInventorySummaries() {
  const result = spApiGet('/fba/inventory/v1/summaries', {
    details: true,
    granularityType: 'Marketplace',
    granularityId: SP_API_CONFIG.marketplaceId,
    marketplaceIds: SP_API_CONFIG.marketplaceId,
  });

  return result.payload?.inventorySummaries || [];
}
```

## SKU別在庫詳細

### Python

```python
# 特定SKUの在庫を取得
response = inventory_api.get_inventory_summary_marketplace(
    sellerSkus=["YOUR-SKU-001", "YOUR-SKU-002"],
    details=True,
    granularityType="Marketplace",
    granularityId="A1VC38T7YXB528",
    marketplaceIds=["A1VC38T7YXB528"],
)

for item in response.payload.get("inventorySummaries", []):
    details = item.get("inventoryDetails", {})
    print(f"SKU: {item['sellerSku']}")
    print(f"  販売可能: {details.get('fulfillableQuantity', 0)}")
    print(f"  入荷中: {details.get('inboundWorkingQuantity', 0)}")
    print(f"  出荷中: {details.get('inboundShippedQuantity', 0)}")
    print(f"  予約済み: {details.get('reservedQuantity', {}).get('totalReservedQuantity', 0)}")
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'getInventorySummaries',
  endpoint: 'fbaInventory',
  query: {
    sellerSkus: ['YOUR-SKU-001', 'YOUR-SKU-002'].join(','),
    details: true,
    granularityType: 'Marketplace',
    granularityId: 'A1VC38T7YXB528',
    marketplaceIds: ['A1VC38T7YXB528'],
  },
});

for (const item of response.inventorySummaries || []) {
  const details = item.inventoryDetails || {};
  console.log(`SKU: ${item.sellerSku}`);
  console.log(`  販売可能: ${details.fulfillableQuantity || 0}`);
  console.log(`  入荷中: ${details.inboundWorkingQuantity || 0}`);
}
```

### GAS

```javascript
function getInventoryBySku(skus) {
  const result = spApiGet('/fba/inventory/v1/summaries', {
    sellerSkus: skus.join(','),
    details: true,
    granularityType: 'Marketplace',
    granularityId: SP_API_CONFIG.marketplaceId,
    marketplaceIds: SP_API_CONFIG.marketplaceId,
  });

  return result.payload?.inventorySummaries || [];
}
```

## FBA入荷プラン作成

### Python

```python
from sp_api.api import FbaInbound

inbound_api = FbaInbound(credentials=credentials, marketplace=Marketplaces.JP)

# 入荷プランを作成
response = inbound_api.create_inbound_shipment_plan(
    ShipFromAddress={
        "Name": "発送元倉庫",
        "AddressLine1": "東京都渋谷区1-1-1",
        "City": "渋谷区",
        "StateOrProvinceCode": "東京都",
        "PostalCode": "150-0001",
        "CountryCode": "JP",
    },
    InboundShipmentPlanRequestItems=[
        {
            "SellerSKU": "YOUR-SKU-001",
            "ASIN": "B0XXXXXXXX",
            "Quantity": 100,
            "Condition": "NewItem",
        }
    ],
)

for plan in response.payload.get("InboundShipmentPlans", []):
    print(f"プランID: {plan['ShipmentId']}")
    print(f"配送先: {plan['DestinationFulfillmentCenterId']}")
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'createInboundShipmentPlan',
  endpoint: 'fbaInbound',
  body: {
    ShipFromAddress: {
      Name: '発送元倉庫',
      AddressLine1: '東京都渋谷区1-1-1',
      City: '渋谷区',
      StateOrProvinceCode: '東京都',
      PostalCode: '150-0001',
      CountryCode: 'JP',
    },
    InboundShipmentPlanRequestItems: [
      {
        SellerSKU: 'YOUR-SKU-001',
        ASIN: 'B0XXXXXXXX',
        Quantity: 100,
        Condition: 'NewItem',
      },
    ],
  },
});

for (const plan of response.InboundShipmentPlans || []) {
  console.log(`プランID: ${plan.ShipmentId}`);
  console.log(`配送先: ${plan.DestinationFulfillmentCenterId}`);
}
```

### GAS

```javascript
function createInboundPlan(items, shipFromAddress) {
  const body = {
    ShipFromAddress: shipFromAddress || {
      Name: '発送元倉庫',
      AddressLine1: '東京都渋谷区1-1-1',
      City: '渋谷区',
      StateOrProvinceCode: '東京都',
      PostalCode: '150-0001',
      CountryCode: 'JP',
    },
    InboundShipmentPlanRequestItems: items.map((item) => ({
      SellerSKU: item.sku,
      ASIN: item.asin,
      Quantity: item.quantity,
      Condition: 'NewItem',
    })),
  };

  return spApiRequest('POST', '/fba/inbound/v0/plans', body);
}
```

## スプレッドシート連携（GAS）

### 在庫をスプレッドシートに出力

```javascript
function exportInventoryToSheet() {
  const inventories = getInventorySummaries();
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('FBA在庫') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('FBA在庫');

  const headers = ['ASIN', 'SKU', '商品名', '販売可能数', '入荷中', '予約済み', '合計'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = inventories.map((i) => {
    const details = i.inventoryDetails || {};
    return [
      i.asin,
      i.sellerSku,
      i.productName || '',
      details.fulfillableQuantity || 0,
      details.inboundWorkingQuantity || 0,
      details.reservedQuantity?.totalReservedQuantity || 0,
      i.totalQuantity || 0,
    ];
  });

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }

  return rows.length;
}
```

### 在庫アラート設定

```javascript
function checkLowStock(threshold = 10) {
  const inventories = getInventorySummaries();
  const lowStock = inventories.filter((i) => {
    const fulfillable = i.inventoryDetails?.fulfillableQuantity || 0;
    return fulfillable < threshold;
  });

  if (lowStock.length > 0) {
    const message = lowStock
      .map((i) => `${i.sellerSku}: ${i.inventoryDetails?.fulfillableQuantity || 0}個`)
      .join('\n');

    MailApp.sendEmail({
      to: Session.getActiveUser().getEmail(),
      subject: `[FBA在庫アラート] ${lowStock.length}件の商品が低在庫です`,
      body: `以下の商品が閾値(${threshold}個)を下回っています:\n\n${message}`,
    });
  }

  return lowStock;
}
```

## リファレンス

### 在庫詳細フィールド

| フィールド | 説明 |
|-----------|------|
| fulfillableQuantity | 販売可能数 |
| inboundWorkingQuantity | 入荷作業中 |
| inboundShippedQuantity | 出荷済み（FC到着前） |
| inboundReceivingQuantity | 受領中 |
| reservedQuantity | 予約済み（注文確定等） |
| unfulfillableQuantity | 販売不可（返品等） |

### 商品コンディション

| コード | 説明 |
|--------|------|
| NewItem | 新品 |
| NewWithWarranty | 新品（保証付き） |
| NewOEM | 新品（OEM） |
| NewOpenBox | 新品（開封済み） |
| UsedLikeNew | 中古 - ほぼ新品 |
| UsedVeryGood | 中古 - 非常に良い |
| UsedGood | 中古 - 良い |
| UsedAcceptable | 中古 - 可 |
