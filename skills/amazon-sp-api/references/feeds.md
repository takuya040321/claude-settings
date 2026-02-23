---
name: amazon-sp-api-feeds
description: Amazon SP-API Feeds APIに特化したスキル。商品情報・価格・在庫の大量一括更新、フィード送信・結果確認をPython/Node.js/GASで実装。ユーザーが「商品を一括登録して」「価格を一括更新して」「在庫を一括更新して」「フィード結果を確認して」などと依頼した場合にトリガー。
---

# Feeds API

大量データの一括更新に特化したAPI。

## 目次

1. [フィードの基本フロー](#フィードの基本フロー)
2. [価格一括更新フィード](#価格一括更新フィード)
3. [在庫一括更新フィード](#在庫一括更新フィード)
4. [商品一括登録フィード](#商品一括登録フィード)
5. [フィード結果の確認](#フィード結果の確認)
6. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## フィードの基本フロー

1. フィードドキュメントを作成（アップロードURL取得）
2. フィードデータをアップロード
3. フィードを送信
4. 処理結果を確認

## 価格一括更新フィード

### Python

```python
from sp_api.api import Feeds
from sp_api.base import Marketplaces
import requests
import json

feeds_api = Feeds(credentials=credentials, marketplace=Marketplaces.JP)

# 1. フィードドキュメントを作成
doc_response = feeds_api.create_feed_document(
    contentType="application/json; charset=UTF-8"
)
document_id = doc_response.payload["feedDocumentId"]
upload_url = doc_response.payload["url"]

# 2. JSON_LISTINGS_FEEDデータを準備
feed_data = {
    "header": {
        "sellerId": "YOUR_SELLER_ID",
        "version": "2.0",
        "issueLocale": "ja_JP"
    },
    "messages": [
        {
            "messageId": 1,
            "sku": "SKU-001",
            "operationType": "PATCH",
            "productType": "PRODUCT",
            "patches": [
                {
                    "op": "replace",
                    "path": "/attributes/purchasable_offer",
                    "value": [{
                        "currency": "JPY",
                        "our_price": [{"schedule": [{"value_with_tax": 1980}]}]
                    }]
                }
            ]
        },
        {
            "messageId": 2,
            "sku": "SKU-002",
            "operationType": "PATCH",
            "productType": "PRODUCT",
            "patches": [
                {
                    "op": "replace",
                    "path": "/attributes/purchasable_offer",
                    "value": [{
                        "currency": "JPY",
                        "our_price": [{"schedule": [{"value_with_tax": 2980}]}]
                    }]
                }
            ]
        }
    ]
}

# 3. データをアップロード
requests.put(upload_url, data=json.dumps(feed_data).encode("utf-8"),
             headers={"Content-Type": "application/json; charset=UTF-8"})

# 4. フィードを送信
feed_response = feeds_api.create_feed(
    feedType="JSON_LISTINGS_FEED",
    marketplaceIds=["A1VC38T7YXB528"],
    inputFeedDocumentId=document_id
)

feed_id = feed_response.payload["feedId"]
print(f"Feed ID: {feed_id}")
```

### Node.js/TypeScript

```typescript
import axios from 'axios';

// 1. フィードドキュメントを作成
const docResponse = await sp.callAPI({
  operation: 'createFeedDocument',
  endpoint: 'feeds',
  body: {
    contentType: 'application/json; charset=UTF-8',
  },
});

const documentId = docResponse.feedDocumentId;
const uploadUrl = docResponse.url;

// 2. JSON_LISTINGS_FEEDデータを準備
const feedData = {
  header: {
    sellerId: 'YOUR_SELLER_ID',
    version: '2.0',
    issueLocale: 'ja_JP',
  },
  messages: [
    {
      messageId: 1,
      sku: 'SKU-001',
      operationType: 'PATCH',
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
  ],
};

// 3. データをアップロード
await axios.put(uploadUrl, JSON.stringify(feedData), {
  headers: { 'Content-Type': 'application/json; charset=UTF-8' },
});

// 4. フィードを送信
const feedResponse = await sp.callAPI({
  operation: 'createFeed',
  endpoint: 'feeds',
  body: {
    feedType: 'JSON_LISTINGS_FEED',
    marketplaceIds: ['A1VC38T7YXB528'],
    inputFeedDocumentId: documentId,
  },
});

console.log(`Feed ID: ${feedResponse.feedId}`);
```

### GAS

```javascript
function submitPriceFeed(priceUpdates) {
  // priceUpdates: [{sku: 'SKU-001', price: 1980}, ...]

  // 1. フィードドキュメントを作成
  const docResult = spApiRequest('POST', '/feeds/2021-06-30/documents', {
    contentType: 'application/json; charset=UTF-8',
  });

  const documentId = docResult.feedDocumentId;
  const uploadUrl = docResult.url;

  // 2. フィードデータを準備
  const props = PropertiesService.getScriptProperties();
  const feedData = {
    header: {
      sellerId: props.getProperty('SELLER_ID'),
      version: '2.0',
      issueLocale: 'ja_JP',
    },
    messages: priceUpdates.map((item, index) => ({
      messageId: index + 1,
      sku: item.sku,
      operationType: 'PATCH',
      productType: 'PRODUCT',
      patches: [
        {
          op: 'replace',
          path: '/attributes/purchasable_offer',
          value: [
            {
              currency: 'JPY',
              our_price: [{ schedule: [{ value_with_tax: item.price }] }],
            },
          ],
        },
      ],
    })),
  };

  // 3. データをアップロード
  UrlFetchApp.fetch(uploadUrl, {
    method: 'PUT',
    contentType: 'application/json; charset=UTF-8',
    payload: JSON.stringify(feedData),
  });

  // 4. フィードを送信
  const feedResult = spApiRequest('POST', '/feeds/2021-06-30/feeds', {
    feedType: 'JSON_LISTINGS_FEED',
    marketplaceIds: [SP_API_CONFIG.marketplaceId],
    inputFeedDocumentId: documentId,
  });

  return feedResult.feedId;
}
```

## 在庫一括更新フィード

### Python

```python
# 在庫更新用のフィードデータ
feed_data = {
    "header": {
        "sellerId": "YOUR_SELLER_ID",
        "version": "2.0",
        "issueLocale": "ja_JP"
    },
    "messages": [
        {
            "messageId": 1,
            "sku": "SKU-001",
            "operationType": "PATCH",
            "productType": "PRODUCT",
            "patches": [
                {
                    "op": "replace",
                    "path": "/attributes/fulfillment_availability",
                    "value": [{
                        "fulfillment_channel_code": "DEFAULT",
                        "quantity": 100
                    }]
                }
            ]
        }
    ]
}
```

### GAS

```javascript
function submitInventoryFeed(inventoryUpdates) {
  // inventoryUpdates: [{sku: 'SKU-001', quantity: 100}, ...]

  const docResult = spApiRequest('POST', '/feeds/2021-06-30/documents', {
    contentType: 'application/json; charset=UTF-8',
  });

  const props = PropertiesService.getScriptProperties();
  const feedData = {
    header: {
      sellerId: props.getProperty('SELLER_ID'),
      version: '2.0',
      issueLocale: 'ja_JP',
    },
    messages: inventoryUpdates.map((item, index) => ({
      messageId: index + 1,
      sku: item.sku,
      operationType: 'PATCH',
      productType: 'PRODUCT',
      patches: [
        {
          op: 'replace',
          path: '/attributes/fulfillment_availability',
          value: [
            {
              fulfillment_channel_code: 'DEFAULT',
              quantity: item.quantity,
            },
          ],
        },
      ],
    })),
  };

  UrlFetchApp.fetch(docResult.url, {
    method: 'PUT',
    contentType: 'application/json; charset=UTF-8',
    payload: JSON.stringify(feedData),
  });

  const feedResult = spApiRequest('POST', '/feeds/2021-06-30/feeds', {
    feedType: 'JSON_LISTINGS_FEED',
    marketplaceIds: [SP_API_CONFIG.marketplaceId],
    inputFeedDocumentId: docResult.feedDocumentId,
  });

  return feedResult.feedId;
}
```

## 商品一括登録フィード

### Python

```python
# 商品登録用のフィードデータ
feed_data = {
    "header": {
        "sellerId": "YOUR_SELLER_ID",
        "version": "2.0",
        "issueLocale": "ja_JP"
    },
    "messages": [
        {
            "messageId": 1,
            "sku": "NEW-SKU-001",
            "operationType": "UPDATE",
            "productType": "PRODUCT",
            "attributes": {
                "condition_type": [{"value": "new_new"}],
                "merchant_suggested_asin": [{"value": "B0XXXXXXXX"}],
                "fulfillment_availability": [{
                    "fulfillment_channel_code": "DEFAULT",
                    "quantity": 50
                }],
                "purchasable_offer": [{
                    "currency": "JPY",
                    "our_price": [{"schedule": [{"value_with_tax": 2980}]}]
                }]
            }
        }
    ]
}
```

## フィード結果の確認

### Python

```python
import time

def wait_for_feed(feed_id, max_wait=600):
    """フィード処理完了を待機"""
    start_time = time.time()

    while time.time() - start_time < max_wait:
        response = feeds_api.get_feed(feed_id)
        status = response.payload["processingStatus"]

        if status in ["DONE", "CANCELLED", "FATAL"]:
            return response.payload

        time.sleep(30)

    raise TimeoutError("Feed processing timeout")

# フィード結果を取得
result = wait_for_feed(feed_id)
print(f"Status: {result['processingStatus']}")

# 結果ドキュメントをダウンロード
if result.get("resultFeedDocumentId"):
    doc_response = feeds_api.get_feed_document(result["resultFeedDocumentId"])
    result_url = doc_response.payload["url"]

    import requests
    result_content = requests.get(result_url).json()
    print(f"処理結果: {result_content}")
```

### Node.js/TypeScript

```typescript
async function waitForFeed(feedId: string, maxWait = 600000): Promise<any> {
  const startTime = Date.now();

  while (Date.now() - startTime < maxWait) {
    const response = await sp.callAPI({
      operation: 'getFeed',
      endpoint: 'feeds',
      path: { feedId },
    });

    if (['DONE', 'CANCELLED', 'FATAL'].includes(response.processingStatus)) {
      return response;
    }

    await new Promise((resolve) => setTimeout(resolve, 30000));
  }

  throw new Error('Feed processing timeout');
}

// 使用例
const result = await waitForFeed(feedId);
console.log(`Status: ${result.processingStatus}`);
```

### GAS

```javascript
function getFeedStatus(feedId) {
  const result = spApiGet(`/feeds/2021-06-30/feeds/${feedId}`);
  return result;
}

function getFeedResult(feedId) {
  const feed = getFeedStatus(feedId);

  if (feed.processingStatus !== 'DONE') {
    return { status: feed.processingStatus, message: '処理中です' };
  }

  if (feed.resultFeedDocumentId) {
    const doc = spApiGet(`/feeds/2021-06-30/documents/${feed.resultFeedDocumentId}`);
    const resultContent = UrlFetchApp.fetch(doc.url).getContentText();
    return JSON.parse(resultContent);
  }

  return { status: 'DONE', message: '結果ドキュメントなし' };
}
```

## スプレッドシート連携（GAS）

### スプレッドシートから一括価格更新

```javascript
function bulkPriceUpdateFromSheet() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('価格更新');
  const data = sheet.getDataRange().getValues();
  const headers = data[0];

  const skuCol = headers.indexOf('SKU');
  const priceCol = headers.indexOf('新価格');

  const updates = [];
  for (let i = 1; i < data.length; i++) {
    const sku = data[i][skuCol];
    const price = data[i][priceCol];
    if (sku && price) {
      updates.push({ sku, price });
    }
  }

  if (updates.length === 0) {
    return 'データがありません';
  }

  const feedId = submitPriceFeed(updates);

  // フィードIDを記録
  sheet.getRange('E1').setValue('フィードID');
  sheet.getRange('E2').setValue(feedId);

  return feedId;
}
```

### スプレッドシートから一括在庫更新

```javascript
function bulkInventoryUpdateFromSheet() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('在庫更新');
  const data = sheet.getDataRange().getValues();
  const headers = data[0];

  const skuCol = headers.indexOf('SKU');
  const qtyCol = headers.indexOf('在庫数');

  const updates = [];
  for (let i = 1; i < data.length; i++) {
    const sku = data[i][skuCol];
    const quantity = data[i][qtyCol];
    if (sku && quantity !== undefined) {
      updates.push({ sku, quantity: parseInt(quantity) });
    }
  }

  if (updates.length === 0) {
    return 'データがありません';
  }

  const feedId = submitInventoryFeed(updates);
  return feedId;
}
```

### フィード結果をスプレッドシートに出力

```javascript
function exportFeedResultToSheet(feedId) {
  const result = getFeedResult(feedId);
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('フィード結果') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('フィード結果');

  sheet.clear();
  sheet.getRange('A1').setValue('フィードID');
  sheet.getRange('B1').setValue(feedId);
  sheet.getRange('A2').setValue('ステータス');
  sheet.getRange('B2').setValue(result.status || result.processingStatus);

  if (result.summary) {
    sheet.getRange('A4').setValue('処理サマリー');
    sheet.getRange('A5:D5').setValues([['成功', '警告', 'エラー', '合計']]);
    sheet.getRange('A6:D6').setValues([
      [
        result.summary.messagesProcessed - result.summary.messagesWithError,
        result.summary.messagesWithWarning || 0,
        result.summary.messagesWithError || 0,
        result.summary.messagesProcessed,
      ],
    ]);
  }
}
```

## リファレンス

### フィードタイプ

| タイプ | 説明 |
|--------|------|
| JSON_LISTINGS_FEED | 商品情報の一括更新（推奨） |
| POST_PRODUCT_DATA | 商品データ（XMLレガシー） |
| POST_INVENTORY_AVAILABILITY_DATA | 在庫更新（XMLレガシー） |
| POST_PRODUCT_PRICING_DATA | 価格更新（XMLレガシー） |

### フィード処理ステータス

| ステータス | 説明 |
|-----------|------|
| QUEUED | キュー待ち |
| IN_PROGRESS | 処理中 |
| DONE | 完了 |
| CANCELLED | キャンセル |
| FATAL | 致命的エラー |

### 操作タイプ

| 操作 | 説明 |
|------|------|
| UPDATE | 新規作成または更新 |
| PATCH | 部分更新 |
| DELETE | 削除 |

### 制限事項

| 項目 | 制限 |
|------|------|
| フィードサイズ | 最大10MB |
| メッセージ数 | 最大10,000件/フィード |
| 同時処理 | 最大30フィード/アカウント |
