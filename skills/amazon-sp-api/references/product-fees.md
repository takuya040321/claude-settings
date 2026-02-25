---
name: amazon-sp-api-product-fees
description: Amazon SP-API Product Fees APIに特化したスキル。商品の手数料見積もりをPython/Node.js/GASで実装。ユーザーが「手数料を計算して」「FBA手数料を調べて」「商品の販売手数料を見積もって」「利益計算のために手数料を取得して」などと依頼した場合にトリガー。
---

# Product Fees API

商品の販売手数料・FBA手数料の見積もりに特化したAPI。

## 目次

1. [ASIN別手数料見積もり](#asin別手数料見積もり)
2. [SKU別手数料見積もり](#sku別手数料見積もり)
3. [一括手数料見積もり](#一括手数料見積もり)
4. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## ASIN別手数料見積もり

**エンドポイント:** `POST /products/fees/v0/items/{Asin}/feesEstimate`
**レート制限:** 1リクエスト/秒（バースト: 2）

### Python

```python
import requests

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
MARKETPLACE_ID = "A1VC38T7YXB528"
HEADERS = {"x-amz-access-token": access_token, "Content-Type": "application/json"}

asin = "B0XXXXXXXX"

response = requests.post(
    f"{BASE_URL}/products/fees/v0/items/{asin}/feesEstimate",
    json={
        "FeesEstimateRequest": {
            "MarketplaceId": MARKETPLACE_ID,
            "IsAmazonFulfilled": True,
            "PriceToEstimateFees": {
                "ListingPrice": {"CurrencyCode": "JPY", "Amount": 3000},
                "Shipping": {"CurrencyCode": "JPY", "Amount": 0},
            },
            "Identifier": f"estimate-{asin}",
            "OptionalFulfillmentProgram": "FBA_CORE",
        }
    },
    headers=HEADERS,
)

result = response.json().get("payload", {}).get("FeesEstimateResult", {})
estimate = result.get("FeesEstimate", {})

print(f"合計手数料: {estimate.get('TotalFeesEstimate', {}).get('Amount')} JPY")

for fee in estimate.get("FeeDetailList", []):
    print(f"  {fee['FeeType']}: {fee['FeeAmount']['Amount']} JPY")
    if fee.get("FeePromotion"):
        print(f"    プロモーション: {fee['FeePromotion']['Amount']} JPY")
```

### Node.js/TypeScript

```typescript
const asin = 'B0XXXXXXXX';

const response = await axios.post(
  `${BASE_URL}/products/fees/v0/items/${asin}/feesEstimate`,
  {
    FeesEstimateRequest: {
      MarketplaceId: 'A1VC38T7YXB528',
      IsAmazonFulfilled: true,
      PriceToEstimateFees: {
        ListingPrice: { CurrencyCode: 'JPY', Amount: 3000 },
        Shipping: { CurrencyCode: 'JPY', Amount: 0 },
      },
      Identifier: `estimate-${asin}`,
      OptionalFulfillmentProgram: 'FBA_CORE',
    },
  },
  { headers: HEADERS }
);

const estimate = response.data.payload?.FeesEstimateResult?.FeesEstimate;
console.log(`合計手数料: ${estimate?.TotalFeesEstimate?.Amount} JPY`);
for (const fee of estimate?.FeeDetailList || []) {
  console.log(`  ${fee.FeeType}: ${fee.FeeAmount.Amount} JPY`);
}
```

### GAS

```javascript
function getFeesEstimateForASIN(asin, price, isAmazonFulfilled = true) {
  const result = spApiRequest(
    'POST',
    `/products/fees/v0/items/${asin}/feesEstimate`,
    {
      FeesEstimateRequest: {
        MarketplaceId: SP_API_CONFIG.marketplaceId,
        IsAmazonFulfilled: isAmazonFulfilled,
        PriceToEstimateFees: {
          ListingPrice: { CurrencyCode: 'JPY', Amount: price },
          Shipping: { CurrencyCode: 'JPY', Amount: 0 },
        },
        Identifier: `estimate-${asin}`,
        OptionalFulfillmentProgram: isAmazonFulfilled ? 'FBA_CORE' : undefined,
      },
    }
  );

  return result.payload?.FeesEstimateResult || {};
}
```

## SKU別手数料見積もり

**エンドポイント:** `POST /products/fees/v0/listings/{SellerSKU}/feesEstimate`
**レート制限:** 1リクエスト/秒（バースト: 2）

### Python

```python
sku = "MY-SKU-001"

response = requests.post(
    f"{BASE_URL}/products/fees/v0/listings/{sku}/feesEstimate",
    json={
        "FeesEstimateRequest": {
            "MarketplaceId": MARKETPLACE_ID,
            "IsAmazonFulfilled": False,
            "PriceToEstimateFees": {
                "ListingPrice": {"CurrencyCode": "JPY", "Amount": 2500},
                "Shipping": {"CurrencyCode": "JPY", "Amount": 500},
            },
            "Identifier": f"estimate-{sku}",
        }
    },
    headers=HEADERS,
)
```

## 一括手数料見積もり

**エンドポイント:** `POST /products/fees/v0/feesEstimate`
**レート制限:** 0.5リクエスト/秒（バースト: 1）

### Python

```python
# 複数商品の手数料を一括取得
items = [
    {"asin": "B0XXXXXXXX", "price": 3000},
    {"asin": "B0YYYYYYYY", "price": 5000},
    {"asin": "B0ZZZZZZZZ", "price": 1500},
]

response = requests.post(
    f"{BASE_URL}/products/fees/v0/feesEstimate",
    json=[
        {
            "FeesEstimateRequest": {
                "MarketplaceId": MARKETPLACE_ID,
                "IsAmazonFulfilled": True,
                "PriceToEstimateFees": {
                    "ListingPrice": {"CurrencyCode": "JPY", "Amount": item["price"]},
                    "Shipping": {"CurrencyCode": "JPY", "Amount": 0},
                },
                "Identifier": f"estimate-{item['asin']}",
                "OptionalFulfillmentProgram": "FBA_CORE",
            },
            "IdType": "ASIN",
            "IdValue": item["asin"],
        }
        for item in items
    ],
    headers=HEADERS,
)

for result in response.json():
    fees_result = result.get("FeesEstimateResult", {})
    status = result.get("Status")
    identifier = fees_result.get("FeesEstimateIdentifier", {}).get("IdValue")
    total = fees_result.get("FeesEstimate", {}).get("TotalFeesEstimate", {}).get("Amount", 0)
    print(f"ASIN: {identifier}, ステータス: {status}, 合計手数料: {total} JPY")
```

## スプレッドシート連携（GAS）

### 手数料一覧をスプレッドシートに出力

```javascript
function exportFeesEstimates() {
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('手数料見積もり') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('手数料見積もり');

  // A列: ASIN, B列: 販売価格 のデータを読み取り
  const dataSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('商品リスト');
  const data = dataSheet.getDataRange().getValues();

  const headers = ['ASIN', '販売価格', '合計手数料', '販売手数料', 'FBA手数料', '手数料率', '利益'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const rows = [];
  for (let i = 1; i < data.length; i++) {
    const asin = data[i][0];
    const price = data[i][1];
    if (!asin || !price) continue;

    try {
      const result = getFeesEstimateForASIN(asin, price, true);
      const estimate = result.FeesEstimate || {};
      const totalFees = estimate.TotalFeesEstimate?.Amount || 0;
      const feeDetails = estimate.FeeDetailList || [];

      const commission = feeDetails.find((f) => f.FeeType === 'ReferralFee')?.FeeAmount?.Amount || 0;
      const fbaFee = feeDetails.find((f) => f.FeeType === 'FBAFees')?.FeeAmount?.Amount || 0;
      const feeRate = price > 0 ? ((totalFees / price) * 100).toFixed(1) : 0;
      const profit = price - totalFees;

      rows.push([asin, price, totalFees, commission, fbaFee, `${feeRate}%`, profit]);
    } catch (e) {
      rows.push([asin, price, `エラー: ${e.message}`, '', '', '', '']);
    }
    Utilities.sleep(1000);
  }

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
}
```

## リファレンス

### リクエストパラメータ

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| MarketplaceId | string | はい | マーケットプレイスID |
| PriceToEstimateFees | object | はい | 見積もり対象価格 |
| Identifier | string | はい | リクエスト追跡用ID |
| IsAmazonFulfilled | boolean | いいえ | FBA利用フラグ |
| OptionalFulfillmentProgram | string | いいえ | FBAプログラム |

### OptionalFulfillmentProgram

| 値 | 説明 |
|----|------|
| FBA_CORE | FBA標準 |
| FBA_SNL | FBA小型・軽量 |
| FBA_EFN | FBA欧州フルフィルメントネットワーク |

### 主要手数料タイプ（FeeDetailList）

| FeeType | 説明 |
|---------|------|
| ReferralFee | 販売手数料（カテゴリ別） |
| FBAFees | FBA配送手数料 |
| VariableClosingFee | カテゴリ別成約料 |
| PerItemFee | アイテム単位手数料 |

### FeesEstimate ステータス

| Status | 説明 |
|--------|------|
| Success | 見積もり成功 |
| ClientError | リクエストエラー |
| ServiceError | サーバーエラー |

### レート制限一覧

| オペレーション | レート | バースト |
|---------------|--------|---------|
| getMyFeesEstimateForSKU | 1/秒 | 2 |
| getMyFeesEstimateForASIN | 1/秒 | 2 |
| getMyFeesEstimates | 0.5/秒 | 1 |
