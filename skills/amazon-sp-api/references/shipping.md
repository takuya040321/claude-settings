---
name: amazon-sp-api-shipping
description: Amazon SP-API Shipping APIに特化したスキル。配送ラベルの購入・追跡・キャンセルをPython/Node.js/GASで実装。ユーザーが「配送ラベルを作成して」「送料を見積もって」「出荷を追跡して」「Buy Shippingで配送して」などと依頼した場合にトリガー。
---

# Shipping API

配送ラベルの購入・料金見積もり・追跡に特化したAPI（Buy Shipping）。

> **注意:** Shipping API v2が推奨。Merchant Fulfillment API (v0) はレガシー。新規実装ではv2を使用すること。

## 目次

1. [配送料金の取得（getRates）](#配送料金の取得getrates)
2. [配送ラベルの購入（purchaseShipment）](#配送ラベルの購入purchaseshipment)
3. [ワンクリック出荷（oneClickShipment）](#ワンクリック出荷oneclickshipment)
4. [追跡情報の取得（getTracking）](#追跡情報の取得gettracking)
5. [出荷のキャンセル](#出荷のキャンセル)
6. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## 配送料金の取得（getRates）

**エンドポイント:** `POST /shipping/v2/shipments/rates`
**レート制限:** 80リクエスト/秒（バースト: 100）

### Python

```python
import requests

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
HEADERS = {
    "x-amz-access-token": access_token,
    "Content-Type": "application/json",
    "x-amzn-shipping-business-id": "AmazonShipping_JP",
}

response = requests.post(
    f"{BASE_URL}/shipping/v2/shipments/rates",
    json={
        "shipFrom": {
            "name": "出荷元倉庫",
            "addressLine1": "東京都品川区1-1-1",
            "city": "品川区",
            "stateOrRegion": "東京都",
            "postalCode": "140-0001",
            "countryCode": "JP",
            "phoneNumber": "03-1234-5678",
        },
        "shipTo": {
            "name": "山田太郎",
            "addressLine1": "大阪府大阪市北区2-2-2",
            "city": "大阪市北区",
            "stateOrRegion": "大阪府",
            "postalCode": "530-0001",
            "countryCode": "JP",
            "phoneNumber": "06-1234-5678",
        },
        "packages": [
            {
                "dimensions": {
                    "length": 30,
                    "width": 20,
                    "height": 15,
                    "unit": "CM",
                },
                "weight": {
                    "value": 1.5,
                    "unit": "KG",
                },
                "insuredValue": {
                    "value": 3000,
                    "unit": "JPY",
                },
            }
        ],
        "channelDetails": {
            "channelType": "EXTERNAL",
        },
    },
    headers=HEADERS,
)

for rate in response.json().get("payload", {}).get("rates", []):
    print(f"キャリア: {rate['carrierId']} - {rate['carrierName']}")
    print(f"  サービス: {rate['serviceId']} - {rate['serviceName']}")
    print(f"  料金: {rate['totalCharge']['value']} {rate['totalCharge']['unit']}")
    print(f"  配達予定: {rate.get('promise', {}).get('deliveryWindow', {})}")
    print(f"  レートID: {rate['rateId']}")
```

### GAS

```javascript
function getShippingRates(shipFrom, shipTo, packages) {
  const result = spApiRequest('POST', '/shipping/v2/shipments/rates', {
    shipFrom: shipFrom,
    shipTo: shipTo,
    packages: packages,
    channelDetails: { channelType: 'EXTERNAL' },
  });

  return result.payload?.rates || [];
}
```

## 配送ラベルの購入（purchaseShipment）

**エンドポイント:** `POST /shipping/v2/shipments`
**レート制限:** 80リクエスト/秒（バースト: 100）

> **注意:** getRatesで取得したrateIdの有効期限は10分。速やかに購入すること。

### Python

```python
import base64

# getRatesで取得したrateIdを使って購入
rate_id = "rate-xxxxxxxx"

response = requests.post(
    f"{BASE_URL}/shipping/v2/shipments",
    json={
        "requestToken": rate_id,
        "rateId": rate_id,
        "requestedDocumentSpecification": {
            "format": "PDF",
            "size": {"width": 4, "height": 6, "unit": "INCH"},
            "dpi": 300,
            "pageLayout": "DEFAULT",
            "needFileJoining": False,
            "requestedDocumentTypes": ["LABEL"],
        },
    },
    headers={
        **HEADERS,
        "x-amzn-IdempotencyKey": "unique-purchase-key-001",
    },
)

result = response.json().get("payload", {})
shipment_id = result["shipmentId"]
print(f"出荷ID: {shipment_id}")

# ラベルPDFを保存
for doc_detail in result.get("packageDocumentDetails", []):
    for doc in doc_detail.get("packageDocuments", []):
        label_data = base64.b64decode(doc["contents"])
        with open(f"label_{shipment_id}.pdf", "wb") as f:
            f.write(label_data)
        print(f"ラベル保存: label_{shipment_id}.pdf")
```

### Node.js/TypeScript

```typescript
const response = await axios.post(
  `${BASE_URL}/shipping/v2/shipments`,
  {
    requestToken: rateId,
    rateId: rateId,
    requestedDocumentSpecification: {
      format: 'PDF',
      size: { width: 4, height: 6, unit: 'INCH' },
      dpi: 300,
      pageLayout: 'DEFAULT',
      needFileJoining: false,
      requestedDocumentTypes: ['LABEL'],
    },
  },
  {
    headers: {
      ...HEADERS,
      'x-amzn-IdempotencyKey': 'unique-purchase-key-001',
    },
  }
);

const shipmentId = response.data.payload.shipmentId;
console.log(`出荷ID: ${shipmentId}`);
```

## ワンクリック出荷（oneClickShipment）

**エンドポイント:** `POST /shipping/v2/oneClickShipment`
**レート制限:** 80リクエスト/秒（バースト: 100）

料金取得と購入を1ステップで実行。最適なサービスが自動選択される。

### Python

```python
response = requests.post(
    f"{BASE_URL}/shipping/v2/oneClickShipment",
    json={
        "shipFrom": {
            "name": "出荷元倉庫",
            "addressLine1": "東京都品川区1-1-1",
            "city": "品川区",
            "stateOrRegion": "東京都",
            "postalCode": "140-0001",
            "countryCode": "JP",
        },
        "shipTo": {
            "name": "山田太郎",
            "addressLine1": "大阪府大阪市北区2-2-2",
            "city": "大阪市北区",
            "stateOrRegion": "大阪府",
            "postalCode": "530-0001",
            "countryCode": "JP",
        },
        "packages": [
            {
                "dimensions": {"length": 30, "width": 20, "height": 15, "unit": "CM"},
                "weight": {"value": 1.5, "unit": "KG"},
            }
        ],
        "channelDetails": {"channelType": "EXTERNAL"},
        "labelSpecifications": {
            "format": "PDF",
            "size": {"width": 4, "height": 6, "unit": "INCH"},
            "dpi": 300,
        },
    },
    headers=HEADERS,
)

result = response.json().get("payload", {})
print(f"出荷ID: {result['shipmentId']}")
print(f"キャリア: {result.get('carrierId')} - {result.get('carrierName')}")
print(f"合計料金: {result.get('totalCharge', {}).get('value')}")
```

## 追跡情報の取得（getTracking）

**エンドポイント:** `GET /shipping/v2/tracking`
**レート制限:** 80リクエスト/秒（バースト: 100）

### Python

```python
tracking_id = "1234567890"
carrier_id = "YAMATO"

response = requests.get(
    f"{BASE_URL}/shipping/v2/tracking",
    params={
        "trackingId": tracking_id,
        "carrierId": carrier_id,
    },
    headers=HEADERS,
)

tracking = response.json().get("payload", {})
print(f"追跡ID: {tracking.get('trackingId')}")
print(f"ステータス: {tracking.get('summary', {}).get('status')}")
print(f"配達予定: {tracking.get('promisedDeliveryDate')}")

for event in tracking.get("eventHistory", []):
    print(f"  {event['eventTime']}: {event['eventCode']} - {event.get('location', {})}")
```

### GAS

```javascript
function getTracking(trackingId, carrierId) {
  const result = spApiGet('/shipping/v2/tracking', {
    trackingId: trackingId,
    carrierId: carrierId,
  });

  return result.payload || {};
}
```

## 出荷のキャンセル

**エンドポイント:** `PUT /shipping/v2/shipments/{shipmentId}/cancel`
**レート制限:** 80リクエスト/秒（バースト: 100）

### Python

```python
shipment_id = "shipment-xxxxxxxx"

response = requests.put(
    f"{BASE_URL}/shipping/v2/shipments/{shipment_id}/cancel",
    headers=HEADERS,
)

if response.status_code == 200:
    print("出荷キャンセル成功")
```

## スプレッドシート連携（GAS）

### 一括送料見積もり

```javascript
function estimateShippingCosts() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('送料見積もり');
  const data = sheet.getDataRange().getValues();

  const shipFrom = {
    name: '出荷元倉庫',
    addressLine1: '東京都品川区1-1-1',
    city: '品川区',
    stateOrRegion: '東京都',
    postalCode: '140-0001',
    countryCode: 'JP',
  };

  // B列: 配送先郵便番号、C列: 重量(kg)
  for (let i = 1; i < data.length; i++) {
    const postalCode = data[i][1];
    const weight = data[i][2];
    if (!postalCode || !weight) continue;

    try {
      const rates = getShippingRates(
        shipFrom,
        { postalCode: String(postalCode), countryCode: 'JP' },
        [{ weight: { value: weight, unit: 'KG' }, dimensions: { length: 30, width: 20, height: 15, unit: 'CM' } }]
      );

      const cheapest = rates.sort((a, b) =>
        (a.totalCharge?.value || 999999) - (b.totalCharge?.value || 999999)
      )[0];

      sheet.getRange(i + 1, 4).setValue(cheapest?.totalCharge?.value || 'N/A');
      sheet.getRange(i + 1, 5).setValue(cheapest?.carrierName || 'N/A');
      sheet.getRange(i + 1, 6).setValue(cheapest?.serviceName || 'N/A');
    } catch (e) {
      sheet.getRange(i + 1, 4).setValue(`エラー: ${e.message}`);
    }
    Utilities.sleep(100);
  }
}
```

## リファレンス

### サポート対象ビジネスリージョン

| x-amzn-shipping-business-id | リージョン |
|------------------------------|-----------|
| AmazonShipping_JP | 日本 |
| AmazonShipping_US | アメリカ |
| AmazonShipping_UK | イギリス |
| AmazonShipping_IN | インド |
| AmazonShipping_IT | イタリア |
| AmazonShipping_ES | スペイン |
| AmazonShipping_FR | フランス |
| AmazonShipping_UAE | UAE |
| AmazonShipping_SA | サウジアラビア |
| AmazonShipping_EG | エジプト |

### channelType

| 値 | 説明 |
|----|------|
| EXTERNAL | 外部チャネル（自社EC等） |
| AMAZON | Amazon注文 |

### ラベルフォーマット

| format | 説明 |
|--------|------|
| PDF | PDFファイル |
| PNG | PNG画像 |
| ZPL | Zebraプリンタ用 |

### 主要オペレーションとレート制限

| オペレーション | メソッド | パス | レート | バースト |
|---------------|---------|------|--------|---------|
| getRates | POST | /shipping/v2/shipments/rates | 80/秒 | 100 |
| purchaseShipment | POST | /shipping/v2/shipments | 80/秒 | 100 |
| directPurchaseShipment | POST | /shipping/v2/shipments/directPurchase | 80/秒 | 100 |
| oneClickShipment | POST | /shipping/v2/oneClickShipment | 80/秒 | 100 |
| getTracking | GET | /shipping/v2/tracking | 80/秒 | 100 |
| getShipmentDocuments | GET | /shipping/v2/shipments/{id}/documents | 80/秒 | 100 |
| cancelShipment | PUT | /shipping/v2/shipments/{id}/cancel | 80/秒 | 100 |
