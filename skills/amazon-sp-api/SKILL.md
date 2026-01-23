---
name: amazon-sp-api
description: Amazon Selling Partner API（SP-API）を使用したマーケットプレイス統合のためのガイド。注文管理、在庫・FBA管理、商品情報管理をPythonまたはNode.jsで実装。ユーザーがSP-APIを使って(1)注文の取得・更新・出荷通知、(2)在庫数の確認・FBA入荷プランの作成、(3)商品登録・価格更新・カタログ情報取得を行う場合にトリガー。
---

# Amazon SP-API

SP-API統合の包括的ガイド。タスクに応じて特化スキルを使用する。

## タスク別スキルルーティング

| タスク | 使用スキル | コマンド |
|--------|-----------|---------|
| 注文の取得・出荷通知 | Orders API | `/amazon-sp-api-orders` |
| 在庫確認・FBA入荷 | FBA Inventory API | `/amazon-sp-api-fba` |
| 商品登録・価格更新 | Listings API | `/amazon-sp-api-listings` |
| 商品検索・情報取得 | Catalog API | `/amazon-sp-api-catalog` |
| 大量データ一括更新 | Feeds API | `/amazon-sp-api-feeds` |

## 共通設定

### 認証情報

| 項目 | 説明 |
|------|------|
| LWA App ID | Login with Amazon アプリID |
| LWA Client Secret | LWAクライアントシークレット |
| Refresh Token | セラーのリフレッシュトークン |
| Seller ID | セラーID（Listings APIで使用） |

### マーケットプレイスID

| リージョン | マーケットプレイス | ID |
|-----------|-------------------|-----|
| Far East | 日本 (JP) | A1VC38T7YXB528 |
| North America | アメリカ (US) | ATVPDKIKX0DER |
| Europe | イギリス (UK) | A1F83G8C2ARO7P |
| Europe | ドイツ (DE) | A1PA6795UKMFR9 |
| Europe | フランス (FR) | A13V1IB3VIYZZH |

### APIエンドポイント

| リージョン | エンドポイント |
|-----------|---------------|
| Far East (JP) | https://sellingpartnerapi-fe.amazon.com |
| North America | https://sellingpartnerapi-na.amazon.com |
| Europe | https://sellingpartnerapi-eu.amazon.com |

## クイックスタート

### Python

```bash
pip install python-amazon-sp-api
```

```python
from sp_api.api import Orders
from sp_api.base import Marketplaces

credentials = {
    "refresh_token": "YOUR_REFRESH_TOKEN",
    "lwa_app_id": "YOUR_LWA_APP_ID",
    "lwa_client_secret": "YOUR_LWA_CLIENT_SECRET",
}

orders = Orders(credentials=credentials, marketplace=Marketplaces.JP)
response = orders.get_orders(CreatedAfter="2024-01-01")
```

### Node.js/TypeScript

```bash
npm install amazon-sp-api
```

```typescript
import SellingPartner from 'amazon-sp-api';

const sp = new SellingPartner({
  region: 'fe',
  refresh_token: 'YOUR_REFRESH_TOKEN',
  credentials: {
    SELLING_PARTNER_APP_CLIENT_ID: 'YOUR_CLIENT_ID',
    SELLING_PARTNER_APP_CLIENT_SECRET: 'YOUR_CLIENT_SECRET',
  },
});
```

### Google Apps Script (GAS)

GASの詳細設定は [references/gas-common.md](references/gas-common.md) を参照。

```javascript
// スクリプトプロパティに設定: LWA_CLIENT_ID, LWA_CLIENT_SECRET, REFRESH_TOKEN, SELLER_ID

const SP_API_CONFIG = {
  endpoint: 'https://sellingpartnerapi-fe.amazon.com',
  marketplaceId: 'A1VC38T7YXB528',
  tokenUrl: 'https://api.amazon.com/auth/o2/token',
};

function getAccessToken() {
  const cache = CacheService.getScriptCache();
  const cached = cache.get('sp_api_access_token');
  if (cached) return cached;

  const props = PropertiesService.getScriptProperties();
  const response = UrlFetchApp.fetch(SP_API_CONFIG.tokenUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    payload: {
      grant_type: 'refresh_token',
      refresh_token: props.getProperty('REFRESH_TOKEN'),
      client_id: props.getProperty('LWA_CLIENT_ID'),
      client_secret: props.getProperty('LWA_CLIENT_SECRET'),
    },
  });

  const result = JSON.parse(response.getContentText());
  cache.put('sp_api_access_token', result.access_token, 55 * 60);
  return result.access_token;
}
```

## エラーハンドリング

| コード | 原因 | 対処 |
|--------|------|------|
| 400 | リクエスト不正 | パラメータを確認 |
| 401 | 認証失敗 | トークンを再取得 |
| 403 | 権限不足 | アプリの権限を確認 |
| 429 | レート制限 | 指数バックオフでリトライ |
| 500 | サーバーエラー | 時間をおいて再試行 |

## レート制限対策

```python
import time

def call_with_retry(api_func, max_retries=5):
    for attempt in range(max_retries):
        try:
            return api_func()
        except Exception as e:
            if "429" in str(e) and attempt < max_retries - 1:
                time.sleep(2 ** attempt)
            else:
                raise
```

## 詳細リファレンス

各APIの詳細は特化スキルまたはリファレンスファイルを参照:

- [GAS共通設定](references/gas-common.md) - 認証・ヘルパー関数・トリガー設定
- [APIバージョン一覧](references/api-versions.md) - 各APIの現行バージョン
