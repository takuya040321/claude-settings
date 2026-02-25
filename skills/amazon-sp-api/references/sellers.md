---
name: amazon-sp-api-sellers
description: Amazon SP-API Sellers APIに特化したスキル。セラーアカウント情報・マーケットプレイス参加情報の取得をPython/Node.js/GASで実装。ユーザーが「セラー情報を確認して」「参加マーケットプレイスを確認して」「アカウント情報を取得して」などと依頼した場合にトリガー。
---

# Sellers API

セラーアカウント情報・マーケットプレイス参加情報の取得に特化したAPI。

## 目次

1. [マーケットプレイス参加情報の取得](#マーケットプレイス参加情報の取得)
2. [アカウント情報の取得](#アカウント情報の取得)
3. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## マーケットプレイス参加情報の取得

**エンドポイント:** `GET /sellers/v1/marketplaceParticipations`
**レート制限:** 0.016リクエスト/秒（バースト: 15）

### Python

```python
import requests

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
HEADERS = {"x-amz-access-token": access_token}

response = requests.get(
    f"{BASE_URL}/sellers/v1/marketplaceParticipations",
    headers=HEADERS,
)

for participation in response.json().get("payload", []):
    marketplace = participation.get("marketplace", {})
    mp_participation = participation.get("participation", {})

    print(f"マーケットプレイスID: {marketplace['id']}")
    print(f"  名前: {marketplace['name']}")
    print(f"  国コード: {marketplace['countryCode']}")
    print(f"  デフォルト言語: {marketplace['defaultLanguageCode']}")
    print(f"  デフォルト通貨: {marketplace['defaultCurrencyCode']}")
    print(f"  ドメイン: {marketplace['domainName']}")
    print(f"  出品停止中: {mp_participation.get('hasSuspendedListings', False)}")
    print(f"  参加中: {mp_participation.get('isParticipating', False)}")
```

### Node.js/TypeScript

```typescript
const response = await axios.get(
  `${BASE_URL}/sellers/v1/marketplaceParticipations`,
  { headers: HEADERS }
);

for (const p of response.data.payload || []) {
  const mp = p.marketplace;
  const participation = p.participation;
  console.log(`${mp.name} (${mp.id})`);
  console.log(`  国: ${mp.countryCode}, 通貨: ${mp.defaultCurrencyCode}`);
  console.log(`  参加中: ${participation.isParticipating}`);
  console.log(`  出品停止: ${participation.hasSuspendedListings}`);
}
```

### GAS

```javascript
function getMarketplaceParticipations() {
  const result = spApiGet('/sellers/v1/marketplaceParticipations');
  return result.payload || [];
}
```

## アカウント情報の取得

**エンドポイント:** `GET /sellers/v1/account`

### Python

```python
response = requests.get(
    f"{BASE_URL}/sellers/v1/account",
    headers=HEADERS,
)

account = response.json().get("payload", {})
print(f"セラーID: {account.get('sellerId')}")
print(f"ビジネスタイプ: {account.get('businessType')}")
```

## スプレッドシート連携（GAS）

### マーケットプレイス情報をスプレッドシートに出力

```javascript
function exportMarketplaceInfo() {
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('マーケットプレイス') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('マーケットプレイス');

  const headers = ['ID', '名前', '国コード', 'ドメイン', '通貨', '言語', '参加中', '出品停止'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const participations = getMarketplaceParticipations();
  const rows = participations.map((p) => {
    const mp = p.marketplace || {};
    const part = p.participation || {};
    return [
      mp.id || '',
      mp.name || '',
      mp.countryCode || '',
      mp.domainName || '',
      mp.defaultCurrencyCode || '',
      mp.defaultLanguageCode || '',
      part.isParticipating ? 'はい' : 'いいえ',
      part.hasSuspendedListings ? 'はい' : 'いいえ',
    ];
  });

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
}
```

## リファレンス

### レスポンスフィールド（marketplace）

| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | string | マーケットプレイスID |
| name | string | マーケットプレイス名 |
| countryCode | string | 国コード（JP, US等） |
| defaultLanguageCode | string | デフォルト言語 |
| defaultCurrencyCode | string | デフォルト通貨 |
| domainName | string | ドメイン名 |

### レスポンスフィールド（participation）

| フィールド | 型 | 説明 |
|-----------|-----|------|
| isParticipating | boolean | マーケットプレイスに参加中か |
| hasSuspendedListings | boolean | 出品停止中のリスティングがあるか |

### 主要マーケットプレイスID

| 国 | ID | ドメイン |
|----|-----|---------|
| 日本 | A1VC38T7YXB528 | amazon.co.jp |
| アメリカ | ATVPDKIKX0DER | amazon.com |
| カナダ | A2EUQ1WTGCTBG2 | amazon.ca |
| イギリス | A1F83G8C2ARO7P | amazon.co.uk |
| ドイツ | A1PA6795UKMFR9 | amazon.de |
| フランス | A13V1IB3VIYZZH | amazon.fr |
| イタリア | APJ6JRA9NG5V4 | amazon.it |
| スペイン | A1RKKUPIHCS9HS | amazon.es |
| オーストラリア | A39IBJ37TRP1C6 | amazon.com.au |
