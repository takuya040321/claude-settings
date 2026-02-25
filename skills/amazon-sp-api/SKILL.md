---
name: amazon-sp-api
description: Amazon Selling Partner API（SP-API）を使用したマーケットプレイス統合のためのガイド。注文管理、在庫・FBA管理、商品情報管理をPythonまたはNode.jsで実装。ユーザーがSP-APIを使って(1)注文の取得・更新・出荷通知、(2)在庫数の確認・FBA入荷プランの作成、(3)商品登録・価格更新・カタログ情報取得を行う場合にトリガー。
---

# Amazon SP-API

SP-API統合の包括的ガイド。タスクに応じて適切なリファレンスを参照する。

## タスク別リファレンス

| タスク | API | リファレンス |
|--------|-----|-------------|
| 注文の検索・取得・出荷通知 | Orders API v2026-01-01 | [references/orders.md](references/orders.md) |
| 在庫確認・FBA入荷 | FBA Inventory API | [references/fba.md](references/fba.md) |
| 商品登録・価格更新 | Listings API | [references/listings.md](references/listings.md) |
| 商品検索・情報取得 | Catalog API | [references/catalog.md](references/catalog.md) |
| 大量データ一括更新 | Feeds API | [references/feeds.md](references/feeds.md) |
| 価格取得・競合分析 | Product Pricing API | [references/pricing.md](references/pricing.md) |
| レポート作成・取得 | Reports API | [references/reports.md](references/reports.md) |
| イベント通知設定 | Notifications API | [references/notifications.md](references/notifications.md) |
| 財務データ取得 | Finances API | [references/finances.md](references/finances.md) |
| 手数料見積もり | Product Fees API | [references/product-fees.md](references/product-fees.md) |
| 売上メトリクス取得 | Sales API | [references/sales.md](references/sales.md) |
| セラー情報取得 | Sellers API | [references/sellers.md](references/sellers.md) |
| PII情報アクセス | Tokens API | [references/tokens.md](references/tokens.md) |
| MCFマルチチャネル出荷 | Fulfillment Outbound API | [references/fulfillment-outbound.md](references/fulfillment-outbound.md) |
| 配送ラベル購入・追跡 | Shipping API v2 | [references/shipping.md](references/shipping.md) |

### 各APIの概要

- **Orders API v2026-01-01** - 注文の検索（searchOrders）、注文の取得（getOrder）、出荷通知（confirmShipment/v0）、スプレッドシート連携
- **FBA Inventory API** - FBA在庫サマリーの取得、SKU別在庫詳細、FBA入荷プラン作成、在庫アラート設定
- **Listings API** - 商品出品の登録・更新・削除、価格変更、在庫数更新、一括操作
- **Catalog API** - 商品カタログ情報の検索・取得、ASIN情報の取得、JANコード変換、複数ASIN一括取得
- **Feeds API** - 価格一括更新フィード、在庫一括更新フィード、商品一括登録フィード、フィード結果の確認
- **Product Pricing API** - 商品価格取得、競合価格比較、オファー一覧、バッチオファー取得
- **Reports API** - レポート作成・取得・スケジュール、注文/在庫/FBA/決済レポート
- **Notifications API** - 通知サブスクリプション管理、SQS/EventBridge配信設定
- **Finances API** - 財務イベントグループ、注文別財務、取引一覧（v2024-06-19）
- **Product Fees API** - ASIN/SKU別手数料見積もり、一括見積もり、利益計算
- **Sales API** - 売上メトリクス取得、日別/週別/月別集計、B2B/B2C分析
- **Sellers API** - マーケットプレイス参加情報、アカウント情報取得
- **Tokens API** - 制限付きデータトークン（RDT）取得、PII情報アクセス
- **Fulfillment Outbound API** - MCF注文作成・管理・追跡・キャンセル・返品
- **Shipping API v2** - 配送料金見積もり、ラベル購入、追跡、ワンクリック出荷

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

> **注意:** `python-amazon-sp-api` (サードパーティ) は Orders API v2026-01-01 に未対応。
> 公式SDK `amzn-sp-api` (v1.7.0+) または直接HTTPリクエストを推奨。

```bash
pip install amzn-sp-api>=1.7.0
```

```python
import requests

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
MARKETPLACE_ID = "A1VC38T7YXB528"

# 注文の検索（searchOrders）
response = requests.get(
    f"{BASE_URL}/orders/2026-01-01/orders",
    params={
        "marketplaceIds": MARKETPLACE_ID,
        "createdAfter": "2026-01-01T00:00:00Z",
        "fulfillmentStatuses": "UNSHIPPED,PARTIALLY_SHIPPED",
        "includedData": "BUYER,RECIPIENT,PROCEEDS",
    },
    headers={"x-amz-access-token": access_token},
)
```

### Node.js/TypeScript

> **推奨:** `@sp-api-sdk/orders-api-2026-01-01` (Bizon SDK) または Amazon公式SDK。
> `amazon-sp-api` (amz-tools) は v2026-01-01 対応が未確認。

```bash
npm install @sp-api-sdk/orders-api-2026-01-01 @sp-api-sdk/auth
```

```typescript
import { SellingPartnerApiAuth } from '@sp-api-sdk/auth';
import { OrdersApiClient } from '@sp-api-sdk/orders-api-2026-01-01';

const auth = new SellingPartnerApiAuth({
  clientId: 'YOUR_CLIENT_ID',
  clientSecret: 'YOUR_CLIENT_SECRET',
  refreshToken: 'YOUR_REFRESH_TOKEN',
});

const client = new OrdersApiClient({ auth, region: 'fe' });

// 注文の検索（searchOrders）
const response = await client.searchOrders({
  marketplaceIds: ['A1VC38T7YXB528'],
  createdAfter: '2026-01-01T00:00:00Z',
  fulfillmentStatuses: ['UNSHIPPED', 'PARTIALLY_SHIPPED'],
  includedData: ['BUYER', 'RECIPIENT', 'PROCEEDS'],
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

各APIの詳細はリファレンスファイルを参照:

- [Orders API v2026-01-01](references/orders.md) - 注文の検索・取得・出荷通知
- [FBA Inventory API](references/fba.md) - FBA在庫の管理・確認・入荷プラン
- [Listings API](references/listings.md) - 商品出品の登録・更新・削除
- [Catalog API](references/catalog.md) - 商品カタログ情報の検索・取得
- [Feeds API](references/feeds.md) - 大量データの一括更新
- [Product Pricing API](references/pricing.md) - 商品価格・競合価格・オファー情報
- [Reports API](references/reports.md) - レポート作成・取得・スケジュール
- [Notifications API](references/notifications.md) - イベント通知のサブスクリプション管理
- [Finances API](references/finances.md) - 財務イベント・取引情報の取得
- [Product Fees API](references/product-fees.md) - 手数料見積もり
- [Sales API](references/sales.md) - 売上メトリクスの取得・集計
- [Sellers API](references/sellers.md) - セラーアカウント・マーケットプレイス情報
- [Tokens API](references/tokens.md) - 制限付きデータトークン（RDT）・PII情報アクセス
- [Fulfillment Outbound API](references/fulfillment-outbound.md) - MCFマルチチャネル出荷
- [Shipping API v2](references/shipping.md) - 配送ラベル購入・追跡
- [GAS共通設定](references/gas-common.md) - 認証・ヘルパー関数・トリガー設定
- [APIバージョン一覧](references/api-versions.md) - 各APIの現行バージョン
