---
name: amazon-sp-api-notifications
description: Amazon SP-API Notifications APIに特化したスキル。通知のサブスクリプション管理、配信先（SQS/EventBridge）の設定をPython/Node.js/GASで実装。ユーザーが「通知を設定して」「注文変更の通知を受け取りたい」「価格変動の通知を設定して」「SQS通知を購読して」などと依頼した場合にトリガー。
---

# Notifications API

イベント駆動型の通知サブスクリプション管理に特化したAPI。ポーリングの代わりにリアルタイム通知を受信。

## 目次

1. [通知設定ワークフロー](#通知設定ワークフロー)
2. [配信先の作成（createDestination）](#配信先の作成createdestination)
3. [サブスクリプション管理](#サブスクリプション管理)
4. [通知メッセージの処理](#通知メッセージの処理)
5. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## 通知設定ワークフロー

```
1. createDestination → SQSまたはEventBridgeの配信先を作成
2. createSubscription → 通知タイプごとにサブスクリプションを作成
3. 通知を受信・処理（SQSポーリングまたはEventBridgeルール）
```

> **注意:** Destination/Subscriptionの管理系操作はGrantless（セラー認可不要）で実行可能。

## 配信先の作成（createDestination）

**エンドポイント:** `POST /notifications/v1/destinations`
**レート制限:** 1リクエスト/秒（バースト: 5）
**Grantless:** はい

### Python（SQS）

```python
import requests

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
HEADERS = {"x-amz-access-token": access_token, "Content-Type": "application/json"}

# SQS配信先の作成
response = requests.post(
    f"{BASE_URL}/notifications/v1/destinations",
    json={
        "name": "MyOrderNotificationQueue",
        "resourceSpecification": {
            "sqs": {
                "arn": "arn:aws:sqs:ap-northeast-1:123456789012:sp-api-notifications"
            }
        },
    },
    headers=HEADERS,
)

destination = response.json().get("payload", {})
destination_id = destination["destinationId"]
print(f"配信先ID: {destination_id}")
```

### Python（EventBridge）

```python
response = requests.post(
    f"{BASE_URL}/notifications/v1/destinations",
    json={
        "name": "MyEventBridgeDestination",
        "resourceSpecification": {
            "eventBridge": {
                "accountId": "123456789012",
                "region": "ap-northeast-1",
            }
        },
    },
    headers=HEADERS,
)
```

### Node.js/TypeScript

```typescript
// SQS配信先の作成
const response = await axios.post(
  `${BASE_URL}/notifications/v1/destinations`,
  {
    name: 'MyOrderNotificationQueue',
    resourceSpecification: {
      sqs: {
        arn: 'arn:aws:sqs:ap-northeast-1:123456789012:sp-api-notifications',
      },
    },
  },
  { headers: HEADERS }
);

const destinationId = response.data.payload.destinationId;
```

## サブスクリプション管理

### サブスクリプション作成

**エンドポイント:** `POST /notifications/v1/subscriptions/{notificationType}`
**レート制限:** 1リクエスト/秒（バースト: 5）

```python
# 注文変更通知のサブスクリプション作成
response = requests.post(
    f"{BASE_URL}/notifications/v1/subscriptions/ORDER_CHANGE",
    json={
        "destinationId": destination_id,
        "payloadVersion": "1.0",
        "processingDirective": {
            "eventFilter": {
                "eventFilterType": "ORDER_CHANGE",
                "orderChangeTypes": ["OrderStatusChange"],
                "marketplaceIds": [MARKETPLACE_ID],
            }
        },
    },
    headers=HEADERS,
)
subscription_id = response.json().get("payload", {}).get("subscriptionId")
```

```python
# 価格変動通知（ANY_OFFER_CHANGED）のサブスクリプション
response = requests.post(
    f"{BASE_URL}/notifications/v1/subscriptions/ANY_OFFER_CHANGED",
    json={
        "destinationId": destination_id,
        "payloadVersion": "1.0",
        "processingDirective": {
            "eventFilter": {
                "eventFilterType": "ANY_OFFER_CHANGED",
                "marketplaceIds": [MARKETPLACE_ID],
                "aggregationSettings": {
                    "aggregationTimePeriod": "FiveMinutes",
                },
            }
        },
    },
    headers=HEADERS,
)
```

### サブスクリプション取得

**エンドポイント:** `GET /notifications/v1/subscriptions/{notificationType}`

```python
# 現在のサブスクリプションを確認
response = requests.get(
    f"{BASE_URL}/notifications/v1/subscriptions/ORDER_CHANGE",
    headers=HEADERS,
)
subscription = response.json().get("payload", {})
print(f"サブスクリプションID: {subscription.get('subscriptionId')}")
print(f"配信先ID: {subscription.get('destinationId')}")
```

### サブスクリプション削除

**エンドポイント:** `DELETE /notifications/v1/subscriptions/{notificationType}/{subscriptionId}`
**Grantless:** はい

```python
requests.delete(
    f"{BASE_URL}/notifications/v1/subscriptions/ORDER_CHANGE/{subscription_id}",
    headers=HEADERS,
)
```

### 配信先一覧・削除

```python
# 配信先一覧
destinations = requests.get(
    f"{BASE_URL}/notifications/v1/destinations",
    headers=HEADERS,
).json().get("payload", [])

# 配信先削除
requests.delete(
    f"{BASE_URL}/notifications/v1/destinations/{destination_id}",
    headers=HEADERS,
)
```

## 通知メッセージの処理

### Python（SQSポーリング）

```python
import boto3
import json

sqs = boto3.client("sqs", region_name="ap-northeast-1")
queue_url = "https://sqs.ap-northeast-1.amazonaws.com/123456789012/sp-api-notifications"

while True:
    messages = sqs.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=10,
        WaitTimeSeconds=20,
    ).get("Messages", [])

    for msg in messages:
        body = json.loads(msg["Body"])
        notification_type = body.get("notificationType")
        payload = body.get("payload", {})

        if notification_type == "ORDER_CHANGE":
            order_id = payload.get("OrderChangeNotification", {}).get("AmazonOrderId")
            status = payload.get("OrderChangeNotification", {}).get("OrderStatus")
            print(f"注文 {order_id} のステータスが {status} に変更")

        elif notification_type == "ANY_OFFER_CHANGED":
            asin = payload.get("AnyOfferChangedNotification", {}).get("OfferChangeTrigger", {}).get("ASIN")
            print(f"ASIN {asin} のオファーが変更")

        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=msg["ReceiptHandle"],
        )
```

### Node.js/TypeScript（SQSポーリング）

```typescript
import { SQSClient, ReceiveMessageCommand, DeleteMessageCommand } from '@aws-sdk/client-sqs';

const sqs = new SQSClient({ region: 'ap-northeast-1' });
const queueUrl = 'https://sqs.ap-northeast-1.amazonaws.com/123456789012/sp-api-notifications';

const { Messages = [] } = await sqs.send(
  new ReceiveMessageCommand({
    QueueUrl: queueUrl,
    MaxNumberOfMessages: 10,
    WaitTimeSeconds: 20,
  })
);

for (const msg of Messages) {
  const body = JSON.parse(msg.Body!);
  const notificationType = body.notificationType;

  if (notificationType === 'ORDER_CHANGE') {
    const orderId = body.payload?.OrderChangeNotification?.AmazonOrderId;
    console.log(`注文 ${orderId} が変更`);
  }

  await sqs.send(
    new DeleteMessageCommand({
      QueueUrl: queueUrl,
      ReceiptHandle: msg.ReceiptHandle!,
    })
  );
}
```

## スプレッドシート連携（GAS）

### 通知設定の管理

```javascript
function listSubscriptions(notificationType) {
  const result = spApiGet(`/notifications/v1/subscriptions/${notificationType}`);
  return result.payload || {};
}

function listDestinations() {
  const result = spApiGet('/notifications/v1/destinations');
  return result.payload || [];
}

function exportNotificationSettingsToSheet() {
  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('通知設定') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('通知設定');

  const headers = ['通知タイプ', 'サブスクリプションID', '配信先ID', 'ペイロードバージョン'];
  sheet.clear();
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);

  const notificationTypes = [
    'ANY_OFFER_CHANGED',
    'ORDER_CHANGE',
    'REPORT_PROCESSING_FINISHED',
    'FEED_PROCESSING_FINISHED',
    'FBA_OUTBOUND_SHIPMENT_STATUS',
  ];

  const rows = [];
  for (const type of notificationTypes) {
    try {
      const sub = listSubscriptions(type);
      rows.push([
        type,
        sub.subscriptionId || '未設定',
        sub.destinationId || '',
        sub.payloadVersion || '',
      ]);
    } catch (e) {
      rows.push([type, '未設定', '', '']);
    }
    Utilities.sleep(1000);
  }

  if (rows.length > 0) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
}
```

## リファレンス

### 主要通知タイプ（セラー向け）

| 通知タイプ | 説明 |
|-----------|------|
| ANY_OFFER_CHANGED | Top20オファーの価格変動・Buy Box変更 |
| B2B_ANY_OFFER_CHANGED | B2Bオファーの変動 |
| ORDER_CHANGE | 注文ステータス変更 |
| REPORT_PROCESSING_FINISHED | レポート処理完了 |
| FEED_PROCESSING_FINISHED | フィード処理完了 |
| FBA_OUTBOUND_SHIPMENT_STATUS | FBA出荷ステータス変更 |
| ACCOUNT_STATUS_CHANGED | アカウントステータス変更 |
| LISTINGS_ITEM_STATUS_CHANGE | 出品ステータス変更 |
| LISTINGS_ITEM_ISSUES_CHANGE | 出品の問題変更 |
| PRODUCT_TYPE_DEFINITIONS_CHANGE | 商品タイプ定義変更 |
| ITEM_INVENTORY_EVENT_CHANGE | 在庫イベント変更 |

### EventFilter タイプ

| eventFilterType | 対応通知タイプ | フィルタオプション |
|----------------|---------------|------------------|
| ANY_OFFER_CHANGED | ANY_OFFER_CHANGED | marketplaceIds, aggregationTimePeriod |
| ORDER_CHANGE | ORDER_CHANGE | marketplaceIds, orderChangeTypes |

### orderChangeTypes

| 値 | 説明 |
|----|------|
| OrderStatusChange | 注文ステータスの変更 |
| BuyerRequestedChange | 購入者リクエストの変更 |

### aggregationTimePeriod

| 値 | 説明 |
|----|------|
| FiveMinutes | 5分間隔で集約 |
| TenMinutes | 10分間隔で集約 |

### 配信先タイプ

| タイプ | 設定項目 | 説明 |
|--------|---------|------|
| SQS | arn | Amazon SQSキューのARN |
| EventBridge | accountId, region | AWS EventBridgeの接続先 |

### レート制限一覧

| オペレーション | レート | バースト | Grantless |
|---------------|--------|---------|-----------|
| getSubscription | 1/秒 | 5 | いいえ |
| createSubscription | 1/秒 | 5 | いいえ |
| getSubscriptionById | 1/秒 | 5 | はい |
| deleteSubscriptionById | 1/秒 | 5 | はい |
| getDestinations | 1/秒 | 5 | はい |
| createDestination | 1/秒 | 5 | はい |
| getDestination | 1/秒 | 5 | はい |
| deleteDestination | 1/秒 | 5 | はい |
