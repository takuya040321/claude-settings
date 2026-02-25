---
name: amazon-sp-api-pricing
description: Amazon SP-API Product Pricing APIに特化したスキル。商品価格の取得、競合価格の比較、オファー一覧の取得をPython/Node.js/GASで実装。ユーザーが「商品の価格を調べて」「競合価格を取得して」「最安値を確認して」「Buy Box価格を調べて」などと依頼した場合にトリガー。
---

# Product Pricing API

商品価格・競合価格・オファー情報の取得に特化したAPI。

> **注意:** v0はレガシーバージョン。新規実装ではv2022-05-01（getFeaturedOfferExpectedPriceBatch / getCompetitiveSummary）も検討すること。

## 目次

1. [商品価格の取得（getPricing）](#商品価格の取得getpricing)
2. [競合価格の取得（getCompetitivePricing）](#競合価格の取得getcompetitivepricing)
3. [オファー一覧の取得（getItemOffers）](#オファー一覧の取得getitemoffers)
4. [SKU別オファー取得（getListingOffers）](#sku別オファー取得getlistingoffers)
5. [バッチオファー取得](#バッチオファー取得)
6. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## 商品価格の取得（getPricing）

**エンドポイント:** `GET /products/pricing/v0/price`
**レート制限:** 0.5リクエスト/秒（バースト: 1）

### Python

```python
import requests

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
MARKETPLACE_ID = "A1VC38T7YXB528"

# ASINで価格を取得（最大20件）
response = requests.get(
    f"{BASE_URL}/products/pricing/v0/price",
    params={
        "MarketplaceId": MARKETPLACE_ID,
        "Asins": "B0XXXXXXXX,B0YYYYYYYY",
        "ItemType": "Asin",
        "ItemCondition": "New",
        "OfferType": "B2C",
    },
    headers={"x-amz-access-token": access_token},
)

for product in response.json().get("payload", []):
    status = product.get("status")
    if status == "Success":
        body = product.get("body", {})
        for offer in body.get("offers", []):
            print(f"ASIN: {product['ASIN']}")
            print(f"  出品価格: {offer['ListingPrice']['Amount']} {offer['ListingPrice']['CurrencyCode']}")
            print(f"  配送料: {offer['Shipping']['Amount']}")
            print(f"  チャネル: {offer['FulfillmentChannel']}")
```

### Node.js/TypeScript

```typescript
const response = await sp.callAPI({
  operation: 'getPricing',
  endpoint: 'productPricing',
  query: {
    MarketplaceId: 'A1VC38T7YXB528',
    Asins: 'B0XXXXXXXX,B0YYYYYYYY',
    ItemType: 'Asin',
    ItemCondition: 'New',
    OfferType: 'B2C',
  },
});

for (const product of response.payload || []) {
  if (product.status === 'Success') {
    for (const offer of product.body?.offers || []) {
      console.log(`ASIN: ${product.ASIN}`);
      console.log(`  価格: ${offer.ListingPrice.Amount}`);
      console.log(`  チャネル: ${offer.FulfillmentChannel}`);
    }
  }
}
```

### GAS

```javascript
function getPricing(asins, itemType = 'Asin') {
  const result = spApiGet('/products/pricing/v0/price', {
    MarketplaceId: SP_API_CONFIG.marketplaceId,
    Asins: Array.isArray(asins) ? asins.join(',') : asins,
    ItemType: itemType,
    ItemCondition: 'New',
    OfferType: 'B2C',
  });

  return result.payload || [];
}
```

## 競合価格の取得（getCompetitivePricing）

**エンドポイント:** `GET /products/pricing/v0/competitivePrice`
**レート制限:** 0.5リクエスト/秒（バースト: 1）

### Python

```python
response = requests.get(
    f"{BASE_URL}/products/pricing/v0/competitivePrice",
    params={
        "MarketplaceId": MARKETPLACE_ID,
        "Asins": "B0XXXXXXXX",
        "ItemType": "Asin",
        "CustomerType": "Consumer",
    },
    headers={"x-amz-access-token": access_token},
)

for product in response.json().get("payload", []):
    if product.get("status") == "Success":
        body = product.get("body", {})
        for cp in body.get("competitivePrices", []):
            print(f"ASIN: {product['ASIN']}")
            print(f"  競合タイプ: {cp['CompetitivePriceId']}")
            print(f"  出品価格: {cp['Price']['ListingPrice']['Amount']}")
            print(f"  配送料: {cp['Price']['Shipping']['Amount']}")

        # オファー数
        for count in body.get("numberOfOfferListings", []):
            print(f"  コンディション {count['condition']}: {count['Count']}件")

        # 売上ランキング
        for rank in body.get("salesRankings", []):
            print(f"  カテゴリ {rank['ProductCategoryId']}: #{rank['Rank']}")
```

### GAS

```javascript
function getCompetitivePricing(asins) {
  const result = spApiGet('/products/pricing/v0/competitivePrice', {
    MarketplaceId: SP_API_CONFIG.marketplaceId,
    Asins: Array.isArray(asins) ? asins.join(',') : asins,
    ItemType: 'Asin',
    CustomerType: 'Consumer',
  });

  return result.payload || [];
}
```

## オファー一覧の取得（getItemOffers）

**エンドポイント:** `GET /products/pricing/v0/items/{Asin}/offers`
**レート制限:** 0.5リクエスト/秒（バースト: 1）

### Python

```python
asin = "B0XXXXXXXX"

response = requests.get(
    f"{BASE_URL}/products/pricing/v0/items/{asin}/offers",
    params={
        "MarketplaceId": MARKETPLACE_ID,
        "ItemCondition": "New",
        "CustomerType": "Consumer",
    },
    headers={"x-amz-access-token": access_token},
)

data = response.json().get("payload", {})
summary = data.get("Summary", {})
print(f"最安値: {summary.get('LowestPrices', [])}")
print(f"Buy Box価格: {summary.get('BuyBoxPrices', [])}")
print(f"オファー数: {summary.get('NumberOfOffers', [])}")

for offer in data.get("Offers", []):
    print(f"  セラー: {offer['SellerId']}")
    print(f"  価格: {offer['ListingPrice']['Amount']}")
    print(f"  配送: {offer['Shipping']['Amount']}")
    print(f"  FBA: {offer['IsFulfilledByAmazon']}")
    print(f"  Buy Box: {offer['IsBuyBoxWinner']}")
    print(f"  コンディション: {offer['SubCondition']}")
```

### GAS

```javascript
function getItemOffers(asin) {
  const result = spApiGet(`/products/pricing/v0/items/${asin}/offers`, {
    MarketplaceId: SP_API_CONFIG.marketplaceId,
    ItemCondition: 'New',
    CustomerType: 'Consumer',
  });

  return result.payload || {};
}
```

## SKU別オファー取得（getListingOffers）

**エンドポイント:** `GET /products/pricing/v0/listings/{SellerSKU}/offers`
**レート制限:** 1リクエスト/秒（バースト: 2）

### Python

```python
sku = "MY-SKU-001"

response = requests.get(
    f"{BASE_URL}/products/pricing/v0/listings/{sku}/offers",
    params={
        "MarketplaceId": MARKETPLACE_ID,
        "ItemCondition": "New",
        "CustomerType": "Consumer",
    },
    headers={"x-amz-access-token": access_token},
)

data = response.json().get("payload", {})
for offer in data.get("Offers", []):
    print(f"価格: {offer['ListingPrice']['Amount']}")
    print(f"Buy Box: {offer['IsBuyBoxWinner']}")
```

## バッチオファー取得

**エンドポイント:** `POST /batches/products/pricing/v0/itemOffers`
**レート制限:** 0.1リクエスト/秒（バースト: 1）

### Python

```python
# 複数ASINのオファーを一括取得
batch_request = {
    "requests": [
        {
            "uri": f"/products/pricing/v0/items/{asin}/offers",
            "method": "GET",
            "MarketplaceId": MARKETPLACE_ID,
            "ItemCondition": "New",
            "CustomerType": "Consumer",
        }
        for asin in ["B0XXXXXXXX", "B0YYYYYYYY", "B0ZZZZZZZZ"]
    ]
}

response = requests.post(
    f"{BASE_URL}/batches/products/pricing/v0/itemOffers",
    json=batch_request,
    headers={
        "x-amz-access-token": access_token,
        "Content-Type": "application/json",
    },
)

for resp in response.json().get("responses", []):
    if resp.get("status", {}).get("statusCode") == 200:
        body = resp.get("body", {})
        print(f"ASIN: {body.get('ASIN')}")
        print(f"オファー数: {len(body.get('Offers', []))}")
```

## スプレッドシート連携（GAS）

### 価格比較シート

```javascript
function exportPricingToSheet(asins) {
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('価格比較') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('価格比較');

  const headers = ['ASIN', '最安値', 'Buy Box価格', 'FBA最安値', 'MFN最安値', 'オファー数'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = [];
  for (const asin of asins) {
    try {
      const data = getItemOffers(asin);
      const summary = data.Summary || {};
      const lowestPrices = summary.LowestPrices || [];
      const buyBoxPrices = summary.BuyBoxPrices || [];
      const offers = summary.NumberOfOffers || [];

      const fbaLowest = lowestPrices.find(
        (p) => p.fulfillmentChannel === 'Amazon'
      );
      const mfnLowest = lowestPrices.find(
        (p) => p.fulfillmentChannel === 'Merchant'
      );
      const buyBox = buyBoxPrices.find(
        (p) => p.condition === 'New'
      );
      const totalOffers = offers.reduce(
        (sum, o) => sum + (o.Count || 0), 0
      );

      rows.push([
        asin,
        lowestPrices[0]?.ListingPrice?.Amount || '',
        buyBox?.ListingPrice?.Amount || '',
        fbaLowest?.ListingPrice?.Amount || '',
        mfnLowest?.ListingPrice?.Amount || '',
        totalOffers,
      ]);
    } catch (e) {
      rows.push([asin, `エラー: ${e.message}`, '', '', '', '']);
    }
    Utilities.sleep(2000); // レート制限対策（0.5req/s）
  }

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
}
```

## リファレンス

### パラメータ

| パラメータ | 値 | 説明 |
|-----------|-----|------|
| ItemType | `Asin` | ASINで検索 |
| ItemType | `Sku` | SKUで検索 |
| ItemCondition | `New` | 新品 |
| ItemCondition | `Used` | 中古 |
| ItemCondition | `Collectible` | コレクター品 |
| ItemCondition | `Refurbished` | 再生品 |
| ItemCondition | `Club` | クラブ |
| CustomerType | `Consumer` | 一般消費者（デフォルト） |
| CustomerType | `Business` | Amazon Business |
| OfferType | `B2C` | 一般向け（デフォルト） |
| OfferType | `B2B` | ビジネス向け |

### CompetitivePriceId

| ID | 説明 |
|----|------|
| 1 | 新品Buy Box価格 |
| 2 | 中古Buy Box価格 |

### レート制限一覧

| オペレーション | レート | バースト |
|---------------|--------|---------|
| getPricing | 0.5/秒 | 1 |
| getCompetitivePricing | 0.5/秒 | 1 |
| getListingOffers | 1/秒 | 2 |
| getItemOffers | 0.5/秒 | 1 |
| getItemOffersBatch | 0.1/秒 | 1 |
| getListingOffersBatch | 0.1/秒 | 1 |
