---
name: amazon-sp-api-listings
description: Amazon SP-API Listings APIに特化したスキル。商品出品の登録・更新・削除、価格変更、在庫数更新をPython/Node.js/GASで実装。ユーザーが「商品を出品して」「価格を更新して」「在庫数を変更して」「出品情報を取得して」などと依頼した場合にトリガー。
---

# Listings API

商品出品の登録・更新・削除に特化したAPI。

## 目次

1. [出品情報の取得](#出品情報の取得)
2. [商品の出品登録](#商品の出品登録)
3. [価格の更新](#価格の更新)
4. [在庫数の更新](#在庫数の更新)
5. [出品の削除](#出品の削除)
6. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## 出品情報の取得

### Python

```python
from sp_api.api import ListingsItems
from sp_api.base import Marketplaces

listings_api = ListingsItems(credentials=credentials, marketplace=Marketplaces.JP)

# 特定SKUの出品情報を取得
seller_id = "YOUR_SELLER_ID"
sku = "YOUR-SKU-001"

response = listings_api.get_listings_item(
    sellerId=seller_id,
    sku=sku,
    marketplaceIds=["A1VC38T7YXB528"],
    includedData=["summaries", "attributes", "offers"],
)

item = response.payload
print(f"SKU: {item['sku']}")
print(f"ASIN: {item.get('summaries', [{}])[0].get('asin', 'N/A')}")
print(f"商品名: {item.get('summaries', [{}])[0].get('itemName', 'N/A')}")
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'getListingsItem',
  endpoint: 'listingsItems',
  path: {
    sellerId: 'YOUR_SELLER_ID',
    sku: 'YOUR-SKU-001',
  },
  query: {
    marketplaceIds: ['A1VC38T7YXB528'],
    includedData: ['summaries', 'attributes', 'offers'],
  },
});

console.log(`SKU: ${response.sku}`);
console.log(`ASIN: ${response.summaries?.[0]?.asin}`);
```

### GAS

```javascript
function getListingItem(sku) {
  const props = PropertiesService.getScriptProperties();
  const sellerId = props.getProperty('SELLER_ID');

  const result = spApiGet(`/listings/2021-08-01/items/${sellerId}/${encodeURIComponent(sku)}`, {
    marketplaceIds: SP_API_CONFIG.marketplaceId,
    includedData: 'summaries,attributes,offers',
  });

  return result;
}
```

## 商品の出品登録

### Python

```python
# 既存ASINに対する出品登録
response = listings_api.put_listings_item(
    sellerId=seller_id,
    sku="NEW-SKU-001",
    marketplaceIds=["A1VC38T7YXB528"],
    body={
        "productType": "PRODUCT",
        "requirements": "LISTING",
        "attributes": {
            "condition_type": [{"value": "new_new"}],
            "merchant_suggested_asin": [{"value": "B0XXXXXXXX"}],
            "fulfillment_availability": [
                {
                    "fulfillment_channel_code": "DEFAULT",
                    "quantity": 100,
                }
            ],
            "purchasable_offer": [
                {
                    "currency": "JPY",
                    "our_price": [{"schedule": [{"value_with_tax": 2980}]}],
                }
            ],
        },
    },
)

print(f"Status: {response.payload.get('status')}")
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'putListingsItem',
  endpoint: 'listingsItems',
  path: {
    sellerId: 'YOUR_SELLER_ID',
    sku: 'NEW-SKU-001',
  },
  query: {
    marketplaceIds: ['A1VC38T7YXB528'],
  },
  body: {
    productType: 'PRODUCT',
    requirements: 'LISTING',
    attributes: {
      condition_type: [{ value: 'new_new' }],
      merchant_suggested_asin: [{ value: 'B0XXXXXXXX' }],
      fulfillment_availability: [
        {
          fulfillment_channel_code: 'DEFAULT',
          quantity: 100,
        },
      ],
      purchasable_offer: [
        {
          currency: 'JPY',
          our_price: [{ schedule: [{ value_with_tax: 2980 }] }],
        },
      ],
    },
  },
});
```

### GAS

```javascript
function createListing(sku, asin, price, quantity) {
  const props = PropertiesService.getScriptProperties();
  const sellerId = props.getProperty('SELLER_ID');

  const body = {
    productType: 'PRODUCT',
    requirements: 'LISTING',
    attributes: {
      condition_type: [{ value: 'new_new' }],
      merchant_suggested_asin: [{ value: asin }],
      fulfillment_availability: [
        {
          fulfillment_channel_code: 'DEFAULT',
          quantity: quantity,
        },
      ],
      purchasable_offer: [
        {
          currency: 'JPY',
          our_price: [{ schedule: [{ value_with_tax: price }] }],
        },
      ],
    },
  };

  return spApiRequest(
    'PUT',
    `/listings/2021-08-01/items/${sellerId}/${encodeURIComponent(sku)}`,
    body,
    { marketplaceIds: SP_API_CONFIG.marketplaceId }
  );
}
```

## 価格の更新

### Python

```python
# 価格のみを更新（PATCH）
response = listings_api.patch_listings_item(
    sellerId=seller_id,
    sku="YOUR-SKU-001",
    marketplaceIds=["A1VC38T7YXB528"],
    body={
        "productType": "PRODUCT",
        "patches": [
            {
                "op": "replace",
                "path": "/attributes/purchasable_offer",
                "value": [
                    {
                        "currency": "JPY",
                        "our_price": [{"schedule": [{"value_with_tax": 1980}]}],
                    }
                ],
            }
        ],
    },
)
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'patchListingsItem',
  endpoint: 'listingsItems',
  path: {
    sellerId: 'YOUR_SELLER_ID',
    sku: 'YOUR-SKU-001',
  },
  query: {
    marketplaceIds: ['A1VC38T7YXB528'],
  },
  body: {
    productType: 'PRODUCT',
    patches: [
      {
        op: 'replace',
        path: '/attributes/purchasable_offer',
        value: [
          {
            currency: 'JPY',
            our_price: [{ schedule: [{ value_with_tax: 1980 }] }],
          },
        ],
      },
    ],
  },
});
```

### GAS

```javascript
function updatePrice(sku, newPrice) {
  const props = PropertiesService.getScriptProperties();
  const sellerId = props.getProperty('SELLER_ID');

  const body = {
    productType: 'PRODUCT',
    patches: [
      {
        op: 'replace',
        path: '/attributes/purchasable_offer',
        value: [
          {
            currency: 'JPY',
            our_price: [{ schedule: [{ value_with_tax: newPrice }] }],
          },
        ],
      },
    ],
  };

  return spApiRequest(
    'PATCH',
    `/listings/2021-08-01/items/${sellerId}/${encodeURIComponent(sku)}`,
    body,
    { marketplaceIds: SP_API_CONFIG.marketplaceId }
  );
}
```

## 在庫数の更新

### Python

```python
# 在庫数を更新
response = listings_api.patch_listings_item(
    sellerId=seller_id,
    sku="YOUR-SKU-001",
    marketplaceIds=["A1VC38T7YXB528"],
    body={
        "productType": "PRODUCT",
        "patches": [
            {
                "op": "replace",
                "path": "/attributes/fulfillment_availability",
                "value": [
                    {
                        "fulfillment_channel_code": "DEFAULT",
                        "quantity": 50,
                    }
                ],
            }
        ],
    },
)
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'patchListingsItem',
  endpoint: 'listingsItems',
  path: {
    sellerId: 'YOUR_SELLER_ID',
    sku: 'YOUR-SKU-001',
  },
  query: {
    marketplaceIds: ['A1VC38T7YXB528'],
  },
  body: {
    productType: 'PRODUCT',
    patches: [
      {
        op: 'replace',
        path: '/attributes/fulfillment_availability',
        value: [
          {
            fulfillment_channel_code: 'DEFAULT',
            quantity: 50,
          },
        ],
      },
    ],
  },
});
```

### GAS

```javascript
function updateQuantity(sku, newQuantity) {
  const props = PropertiesService.getScriptProperties();
  const sellerId = props.getProperty('SELLER_ID');

  const body = {
    productType: 'PRODUCT',
    patches: [
      {
        op: 'replace',
        path: '/attributes/fulfillment_availability',
        value: [
          {
            fulfillment_channel_code: 'DEFAULT',
            quantity: newQuantity,
          },
        ],
      },
    ],
  };

  return spApiRequest(
    'PATCH',
    `/listings/2021-08-01/items/${sellerId}/${encodeURIComponent(sku)}`,
    body,
    { marketplaceIds: SP_API_CONFIG.marketplaceId }
  );
}
```

## 出品の削除

### Python

```python
response = listings_api.delete_listings_item(
    sellerId=seller_id,
    sku="YOUR-SKU-001",
    marketplaceIds=["A1VC38T7YXB528"],
)

print(f"Status: {response.payload.get('status')}")
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'deleteListingsItem',
  endpoint: 'listingsItems',
  path: {
    sellerId: 'YOUR_SELLER_ID',
    sku: 'YOUR-SKU-001',
  },
  query: {
    marketplaceIds: ['A1VC38T7YXB528'],
  },
});
```

### GAS

```javascript
function deleteListing(sku) {
  const props = PropertiesService.getScriptProperties();
  const sellerId = props.getProperty('SELLER_ID');

  return spApiRequest(
    'DELETE',
    `/listings/2021-08-01/items/${sellerId}/${encodeURIComponent(sku)}`,
    null,
    { marketplaceIds: SP_API_CONFIG.marketplaceId }
  );
}
```

## スプレッドシート連携（GAS）

### 一括価格更新

```javascript
function bulkUpdatePrices() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('価格更新');
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const skuCol = headers.indexOf('SKU');
  const priceCol = headers.indexOf('新価格');

  const results = [];
  for (let i = 1; i < data.length; i++) {
    const sku = data[i][skuCol];
    const price = data[i][priceCol];

    if (sku && price) {
      try {
        updatePrice(sku, price);
        results.push({ sku, status: '成功' });
      } catch (e) {
        results.push({ sku, status: `エラー: ${e.message}` });
      }
      Utilities.sleep(500); // レート制限対策
    }
  }

  return results;
}
```

### 一括在庫更新

```javascript
function bulkUpdateQuantities() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('在庫更新');
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const skuCol = headers.indexOf('SKU');
  const qtyCol = headers.indexOf('在庫数');

  const results = [];
  for (let i = 1; i < data.length; i++) {
    const sku = data[i][skuCol];
    const quantity = data[i][qtyCol];

    if (sku && quantity !== undefined) {
      try {
        updateQuantity(sku, quantity);
        results.push({ sku, status: '成功' });
      } catch (e) {
        results.push({ sku, status: `エラー: ${e.message}` });
      }
      Utilities.sleep(500);
    }
  }

  return results;
}
```

## リファレンス

### コンディションコード

| コード | 説明 |
|--------|------|
| new_new | 新品 |
| new_open_box | 新品（開封済み） |
| new_oem | 新品（OEM） |
| refurbished_refurbished | 再生品 |
| used_like_new | 中古 - ほぼ新品 |
| used_very_good | 中古 - 非常に良い |
| used_good | 中古 - 良い |
| used_acceptable | 中古 - 可 |
| collectible_like_new | コレクター - ほぼ新品 |
| collectible_very_good | コレクター - 非常に良い |
| collectible_good | コレクター - 良い |
| collectible_acceptable | コレクター - 可 |

### フルフィルメントチャネル

| コード | 説明 |
|--------|------|
| DEFAULT | 自社出荷（MFN） |
| AMAZON_NA / AMAZON_EU / AMAZON_JP | FBA出荷 |

### パッチ操作

| 操作 | 説明 |
|------|------|
| add | 属性を追加 |
| replace | 属性を置換 |
| delete | 属性を削除 |
