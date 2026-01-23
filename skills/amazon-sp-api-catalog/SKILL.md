---
name: amazon-sp-api-catalog
description: Amazon SP-API Catalog APIに特化したスキル。商品カタログ情報の検索・取得、ASIN情報の取得、商品属性の確認をPython/Node.js/GASで実装。ユーザーが「商品を検索して」「ASIN情報を取得して」「商品の詳細を教えて」「カタログ情報を調べて」などと依頼した場合にトリガー。
---

# Catalog API

商品カタログ情報の検索・取得に特化したAPI。

## 目次

1. [商品検索](#商品検索)
2. [ASIN詳細の取得](#asin詳細の取得)
3. [複数ASIN一括取得](#複数asin一括取得)
4. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## 商品検索

### Python

```python
from sp_api.api import CatalogItems
from sp_api.base import Marketplaces

catalog_api = CatalogItems(credentials=credentials, marketplace=Marketplaces.JP)

# キーワードで商品を検索
response = catalog_api.search_catalog_items(
    keywords="ワイヤレスイヤホン",
    marketplaceIds=["A1VC38T7YXB528"],
    includedData=["summaries", "images", "salesRanks"],
    pageSize=10,
)

for item in response.payload.get("items", []):
    summary = item.get("summaries", [{}])[0]
    print(f"ASIN: {item['asin']}")
    print(f"商品名: {summary.get('itemName', 'N/A')}")
    print(f"ブランド: {summary.get('brand', 'N/A')}")
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'searchCatalogItems',
  endpoint: 'catalogItems',
  query: {
    keywords: 'ワイヤレスイヤホン',
    marketplaceIds: ['A1VC38T7YXB528'],
    includedData: ['summaries', 'images', 'salesRanks'],
    pageSize: 10,
  },
});

for (const item of response.items || []) {
  const summary = item.summaries?.[0] || {};
  console.log(`ASIN: ${item.asin}`);
  console.log(`商品名: ${summary.itemName}`);
  console.log(`ブランド: ${summary.brand}`);
}
```

### GAS

```javascript
function searchCatalog(keywords, pageSize = 10) {
  const result = spApiGet('/catalog/2022-04-01/items', {
    keywords: keywords,
    marketplaceIds: SP_API_CONFIG.marketplaceId,
    includedData: 'summaries,images,salesRanks',
    pageSize: pageSize,
  });

  return result.items || [];
}
```

## ASIN詳細の取得

### Python

```python
asin = "B0XXXXXXXX"

response = catalog_api.get_catalog_item(
    asin=asin,
    marketplaceIds=["A1VC38T7YXB528"],
    includedData=["summaries", "attributes", "dimensions", "images", "salesRanks"],
)

item = response.payload
summary = item.get("summaries", [{}])[0]
dimensions = item.get("dimensions", [{}])[0]

print(f"ASIN: {item['asin']}")
print(f"商品名: {summary.get('itemName', 'N/A')}")
print(f"ブランド: {summary.get('brand', 'N/A')}")
print(f"メーカー: {summary.get('manufacturer', 'N/A')}")
print(f"カラー: {summary.get('color', 'N/A')}")
print(f"サイズ: {summary.get('size', 'N/A')}")

if dimensions:
    pkg = dimensions.get("package", {})
    print(f"パッケージ: {pkg.get('length', {}).get('value', 'N/A')} x "
          f"{pkg.get('width', {}).get('value', 'N/A')} x "
          f"{pkg.get('height', {}).get('value', 'N/A')}")
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'getCatalogItem',
  endpoint: 'catalogItems',
  path: { asin: 'B0XXXXXXXX' },
  query: {
    marketplaceIds: ['A1VC38T7YXB528'],
    includedData: ['summaries', 'attributes', 'dimensions', 'images', 'salesRanks'],
  },
});

const summary = response.summaries?.[0] || {};
console.log(`ASIN: ${response.asin}`);
console.log(`商品名: ${summary.itemName}`);
console.log(`ブランド: ${summary.brand}`);
```

### GAS

```javascript
function getCatalogItem(asin) {
  const result = spApiGet(`/catalog/2022-04-01/items/${asin}`, {
    marketplaceIds: SP_API_CONFIG.marketplaceId,
    includedData: 'summaries,attributes,dimensions,images,salesRanks',
  });

  return result;
}
```

## 複数ASIN一括取得

### Python

```python
# 識別子（ASIN/EAN/UPC等）で検索
response = catalog_api.search_catalog_items(
    identifiers=["B0XXXXXXXX", "B0YYYYYYYY"],
    identifiersType="ASIN",
    marketplaceIds=["A1VC38T7YXB528"],
    includedData=["summaries", "images"],
)

for item in response.payload.get("items", []):
    print(f"ASIN: {item['asin']}")
    print(f"商品名: {item.get('summaries', [{}])[0].get('itemName', 'N/A')}")
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'searchCatalogItems',
  endpoint: 'catalogItems',
  query: {
    identifiers: ['B0XXXXXXXX', 'B0YYYYYYYY'].join(','),
    identifiersType: 'ASIN',
    marketplaceIds: ['A1VC38T7YXB528'],
    includedData: ['summaries', 'images'],
  },
});

for (const item of response.items || []) {
  console.log(`ASIN: ${item.asin}`);
}
```

### GAS

```javascript
function getCatalogItemsByIdentifiers(identifiers, type = 'ASIN') {
  const result = spApiGet('/catalog/2022-04-01/items', {
    identifiers: identifiers.join(','),
    identifiersType: type,
    marketplaceIds: SP_API_CONFIG.marketplaceId,
    includedData: 'summaries,images',
  });

  return result.items || [];
}
```

## JANコード・EANからASINを検索

### Python

```python
# JANコード（EAN）からASINを検索
response = catalog_api.search_catalog_items(
    identifiers=["4901234567890"],
    identifiersType="EAN",
    marketplaceIds=["A1VC38T7YXB528"],
    includedData=["summaries"],
)

for item in response.payload.get("items", []):
    print(f"JAN: 4901234567890 → ASIN: {item['asin']}")
```

### GAS

```javascript
function janToAsin(janCode) {
  const result = spApiGet('/catalog/2022-04-01/items', {
    identifiers: janCode,
    identifiersType: 'EAN',
    marketplaceIds: SP_API_CONFIG.marketplaceId,
    includedData: 'summaries',
  });

  return result.items?.[0]?.asin || null;
}
```

## スプレッドシート連携（GAS）

### 商品情報をスプレッドシートに出力

```javascript
function exportCatalogToSheet(asins) {
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('カタログ') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('カタログ');

  const headers = ['ASIN', '商品名', 'ブランド', 'メーカー', 'カラー', 'サイズ', '画像URL'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = [];
  for (const asin of asins) {
    try {
      const item = getCatalogItem(asin);
      const summary = item.summaries?.[0] || {};
      const image = item.images?.[0]?.images?.[0]?.link || '';

      rows.push([
        asin,
        summary.itemName || '',
        summary.brand || '',
        summary.manufacturer || '',
        summary.color || '',
        summary.size || '',
        image,
      ]);
    } catch (e) {
      rows.push([asin, `エラー: ${e.message}`, '', '', '', '', '']);
    }
    Utilities.sleep(500); // レート制限対策
  }

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }

  return rows.length;
}
```

### JANコードからASIN変換

```javascript
function convertJanToAsin() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('JAN変換');
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const janCol = headers.indexOf('JANコード');
  const asinCol = headers.indexOf('ASIN');

  for (let i = 1; i < data.length; i++) {
    const jan = data[i][janCol];
    if (jan && !data[i][asinCol]) {
      try {
        const asin = janToAsin(String(jan));
        if (asin) {
          sheet.getRange(i + 1, asinCol + 1).setValue(asin);
        }
      } catch (e) {
        sheet.getRange(i + 1, asinCol + 1).setValue(`エラー: ${e.message}`);
      }
      Utilities.sleep(500);
    }
  }
}
```

## リファレンス

### 識別子タイプ

| タイプ | 説明 |
|--------|------|
| ASIN | Amazon標準識別番号 |
| EAN | 国際商品番号（JANコード含む） |
| UPC | 統一商品コード（北米） |
| ISBN | 書籍用国際標準番号 |
| JAN | 日本商品コード（EANと同等） |
| SKU | 出品者独自のSKU |

### includedDataオプション

| オプション | 説明 |
|-----------|------|
| summaries | 商品概要（名前、ブランド等） |
| attributes | 詳細属性 |
| dimensions | 寸法・重量 |
| images | 商品画像 |
| salesRanks | 売上ランキング |
| productTypes | 商品タイプ情報 |
| relationships | バリエーション関係 |
| identifiers | 識別子（JAN/EAN等） |

### ページネーション

```python
# 次ページを取得
next_token = response.payload.get("pagination", {}).get("nextToken")
if next_token:
    next_response = catalog_api.search_catalog_items(
        keywords="ワイヤレスイヤホン",
        marketplaceIds=["A1VC38T7YXB528"],
        pageToken=next_token,
    )
```

```javascript
// GAS: ページネーション対応
function searchCatalogAll(keywords, maxPages = 5) {
  let allItems = [];
  let nextToken = null;

  for (let page = 0; page < maxPages; page++) {
    const params = {
      keywords: keywords,
      marketplaceIds: SP_API_CONFIG.marketplaceId,
      includedData: 'summaries',
      pageSize: 20,
    };
    if (nextToken) params.pageToken = nextToken;

    const result = spApiGet('/catalog/2022-04-01/items', params);
    allItems = allItems.concat(result.items || []);

    nextToken = result.pagination?.nextToken;
    if (!nextToken) break;

    Utilities.sleep(500);
  }

  return allItems;
}
```
