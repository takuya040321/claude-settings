---
name: amazon-sp-api-reports
description: Amazon SP-API Reports APIに特化したスキル。各種レポートの作成・取得・スケジュール管理をPython/Node.js/GASで実装。ユーザーが「レポートを取得して」「注文レポートをダウンロードして」「在庫レポートを確認して」「レポートをスケジュールして」などと依頼した場合にトリガー。
---

# Reports API

各種ビジネスレポートの作成・取得・スケジュール管理に特化したAPI。

## 目次

1. [レポート作成・取得ワークフロー](#レポート作成取得ワークフロー)
2. [レポート一覧の取得（getReports）](#レポート一覧の取得getreports)
3. [レポートドキュメントのダウンロード](#レポートドキュメントのダウンロード)
4. [レポートのスケジュール](#レポートのスケジュール)
5. [スプレッドシート連携（GAS）](#スプレッドシート連携gas)

## レポート作成・取得ワークフロー

```
1. createReport → reportId を取得
2. getReport（ポーリング） → processingStatus が DONE になるまで待機
3. getReportDocument → レポートドキュメントURL を取得
4. URLからデータをダウンロード（GZIP圧縮の場合は解凍）
```

### Python

```python
import requests
import time
import gzip
import io

BASE_URL = "https://sellingpartnerapi-fe.amazon.com"
MARKETPLACE_ID = "A1VC38T7YXB528"
HEADERS = {"x-amz-access-token": access_token, "Content-Type": "application/json"}

# 1. レポート作成
create_response = requests.post(
    f"{BASE_URL}/reports/2021-06-30/reports",
    json={
        "reportType": "GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_GENERAL",
        "marketplaceIds": [MARKETPLACE_ID],
        "dataStartTime": "2026-01-01T00:00:00Z",
        "dataEndTime": "2026-01-31T23:59:59Z",
    },
    headers=HEADERS,
)
report_id = create_response.json()["reportId"]

# 2. 処理完了まで待機
while True:
    report = requests.get(
        f"{BASE_URL}/reports/2021-06-30/reports/{report_id}",
        headers=HEADERS,
    ).json()

    status = report["processingStatus"]
    if status == "DONE":
        break
    elif status in ("CANCELLED", "FATAL"):
        raise Exception(f"レポート処理失敗: {status}")

    time.sleep(30)

# 3. レポートドキュメント取得
doc_id = report["reportDocumentId"]
doc = requests.get(
    f"{BASE_URL}/reports/2021-06-30/documents/{doc_id}",
    headers=HEADERS,
).json()

# 4. ダウンロード（GZIP対応）
download_url = doc["url"]
content = requests.get(download_url).content

if doc.get("compressionAlgorithm") == "GZIP":
    content = gzip.decompress(content)

report_text = content.decode("utf-8")
print(report_text[:500])
```

### Node.js/TypeScript

```typescript
import axios from 'axios';
import { gunzipSync } from 'zlib';

const BASE_URL = 'https://sellingpartnerapi-fe.amazon.com';
const HEADERS = { 'x-amz-access-token': accessToken, 'Content-Type': 'application/json' };

// 1. レポート作成
const createRes = await axios.post(
  `${BASE_URL}/reports/2021-06-30/reports`,
  {
    reportType: 'GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_GENERAL',
    marketplaceIds: ['A1VC38T7YXB528'],
    dataStartTime: '2026-01-01T00:00:00Z',
    dataEndTime: '2026-01-31T23:59:59Z',
  },
  { headers: HEADERS }
);
const reportId = createRes.data.reportId;

// 2. ポーリング
let report;
while (true) {
  const res = await axios.get(
    `${BASE_URL}/reports/2021-06-30/reports/${reportId}`,
    { headers: HEADERS }
  );
  report = res.data;
  if (report.processingStatus === 'DONE') break;
  if (['CANCELLED', 'FATAL'].includes(report.processingStatus)) {
    throw new Error(`レポート処理失敗: ${report.processingStatus}`);
  }
  await new Promise((r) => setTimeout(r, 30000));
}

// 3-4. ドキュメント取得 & ダウンロード
const docRes = await axios.get(
  `${BASE_URL}/reports/2021-06-30/documents/${report.reportDocumentId}`,
  { headers: HEADERS }
);
const downloadRes = await axios.get(docRes.data.url, { responseType: 'arraybuffer' });
let content = Buffer.from(downloadRes.data);

if (docRes.data.compressionAlgorithm === 'GZIP') {
  content = gunzipSync(content);
}

console.log(content.toString('utf-8').slice(0, 500));
```

### GAS

```javascript
function createAndGetReport(reportType, startDate, endDate) {
  // 1. レポート作成
  const createResult = spApiRequest('POST', '/reports/2021-06-30/reports', {
    reportType: reportType,
    marketplaceIds: [SP_API_CONFIG.marketplaceId],
    dataStartTime: startDate,
    dataEndTime: endDate,
  });
  const reportId = createResult.reportId;

  // 2. ポーリング（GAS実行制限に注意: 最大6分）
  let report;
  for (let i = 0; i < 10; i++) {
    Utilities.sleep(30000);
    report = spApiGet(`/reports/2021-06-30/reports/${reportId}`);
    if (report.processingStatus === 'DONE') break;
    if (['CANCELLED', 'FATAL'].includes(report.processingStatus)) {
      throw new Error(`レポート処理失敗: ${report.processingStatus}`);
    }
  }

  if (report.processingStatus !== 'DONE') {
    throw new Error('レポート処理タイムアウト');
  }

  // 3-4. ドキュメント取得 & ダウンロード
  const doc = spApiGet(`/reports/2021-06-30/documents/${report.reportDocumentId}`);
  const response = UrlFetchApp.fetch(doc.url);
  let content = response.getBlob();

  if (doc.compressionAlgorithm === 'GZIP') {
    content = Utilities.ungzip(content);
  }

  return content.getDataAsString('UTF-8');
}
```

## レポート一覧の取得（getReports）

**エンドポイント:** `GET /reports/2021-06-30/reports`
**レート制限:** 0.0222リクエスト/秒（バースト: 10）

### Python

```python
response = requests.get(
    f"{BASE_URL}/reports/2021-06-30/reports",
    params={
        "reportTypes": "GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_GENERAL",
        "processingStatuses": "DONE",
        "marketplaceIds": MARKETPLACE_ID,
        "pageSize": 10,
    },
    headers=HEADERS,
)

for report in response.json().get("reports", []):
    print(f"ID: {report['reportId']}")
    print(f"タイプ: {report['reportType']}")
    print(f"ステータス: {report['processingStatus']}")
    print(f"作成日時: {report['createdTime']}")
```

## レポートドキュメントのダウンロード

**エンドポイント:** `GET /reports/2021-06-30/documents/{reportDocumentId}`
**レート制限:** 0.0167リクエスト/秒（バースト: 15）

> **注意:** 署名付きURLは5分で有効期限切れ。取得後速やかにダウンロードすること。

## レポートのスケジュール

**エンドポイント:** `POST /reports/2021-06-30/schedules`
**レート制限:** 0.0222リクエスト/秒（バースト: 10）

### Python

```python
# レポートスケジュール作成
response = requests.post(
    f"{BASE_URL}/reports/2021-06-30/schedules",
    json={
        "reportType": "GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_GENERAL",
        "marketplaceIds": [MARKETPLACE_ID],
        "period": "PT8H",  # 8時間ごと
    },
    headers=HEADERS,
)
schedule_id = response.json()["reportScheduleId"]

# スケジュール一覧取得
schedules = requests.get(
    f"{BASE_URL}/reports/2021-06-30/schedules",
    params={"reportTypes": "GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_GENERAL"},
    headers=HEADERS,
).json()

# スケジュール削除
requests.delete(
    f"{BASE_URL}/reports/2021-06-30/schedules/{schedule_id}",
    headers=HEADERS,
)
```

## スプレッドシート連携（GAS）

### 注文レポートをスプレッドシートに出力

```javascript
function importOrderReport() {
  const endDate = new Date().toISOString();
  const startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();

  const tsvContent = createAndGetReport(
    'GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_GENERAL',
    startDate,
    endDate
  );

  const sheet =
    SpreadsheetApp.getActiveSpreadsheet().getSheetByName('注文レポート') ||
    SpreadsheetApp.getActiveSpreadsheet().insertSheet('注文レポート');
  sheet.clear();

  const lines = tsvContent.split('\n');
  const data = lines.map((line) => line.split('\t'));

  if (data.length > 0) {
    sheet.getRange(1, 1, data.length, data[0].length).setValues(data);
  }
}
```

## リファレンス

### 主要レポートタイプ（セラー向け）

#### 注文レポート

| レポートタイプ | 説明 |
|---------------|------|
| GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_GENERAL | 全注文データ（更新日順） |
| GET_FLAT_FILE_ALL_ORDERS_DATA_BY_ORDER_DATE_GENERAL | 全注文データ（注文日順） |
| GET_FLAT_FILE_ACTIONABLE_ORDER_DATA_SHIPPING | 未出荷注文データ |
| GET_FLAT_FILE_PENDING_ORDERS_DATA | 保留中注文 |

#### 在庫レポート

| レポートタイプ | 説明 |
|---------------|------|
| GET_MERCHANT_LISTINGS_ALL_DATA | 全出品データ |
| GET_MERCHANT_LISTINGS_DATA | アクティブ出品データ |
| GET_MERCHANT_LISTINGS_INACTIVE_DATA | 非アクティブ出品 |
| GET_FLAT_FILE_OPEN_LISTINGS_DATA | オープンリスト |

#### FBAレポート

| レポートタイプ | 説明 |
|---------------|------|
| GET_AMAZON_FULFILLED_SHIPMENTS_DATA_GENERAL | FBA出荷データ |
| GET_AFN_INVENTORY_DATA | FBA在庫データ |
| GET_FBA_MYI_UNSUPPRESSED_INVENTORY_DATA | FBA在庫（非抑制） |
| GET_FBA_REIMBURSEMENTS_DATA | FBA払戻データ |
| GET_FBA_FULFILLMENT_CUSTOMER_SHIPMENT_SALES_DATA | FBA売上データ |

#### 決済・財務レポート

| レポートタイプ | 説明 |
|---------------|------|
| GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE | 決済レポート |
| GET_V2_SETTLEMENT_REPORT_DATA_XML | 決済レポート（XML） |

#### 返品レポート

| レポートタイプ | 説明 |
|---------------|------|
| GET_FLAT_FILE_RETURNS_DATA_BY_RETURN_DATE | 返品データ（返品日順） |
| GET_XML_RETURNS_DATA_BY_RETURN_DATE | 返品データ（XML） |

#### パフォーマンス・分析レポート

| レポートタイプ | 説明 |
|---------------|------|
| GET_SALES_AND_TRAFFIC_REPORT | 売上・トラフィック |
| GET_BRAND_ANALYTICS_SEARCH_TERMS_REPORT | ブランド分析・検索語 |

### 処理ステータス

| ステータス | 説明 |
|-----------|------|
| IN_QUEUE | 処理待ち |
| IN_PROGRESS | 処理中 |
| DONE | 完了 |
| CANCELLED | キャンセル済み |
| FATAL | エラー終了 |

### スケジュール間隔（period）

| 値 | 間隔 |
|----|------|
| PT5M | 5分 |
| PT15M | 15分 |
| PT30M | 30分 |
| PT1H | 1時間 |
| PT2H | 2時間 |
| PT4H | 4時間 |
| PT8H | 8時間 |
| PT12H | 12時間 |
| P1D | 1日 |
| P2D | 2日 |
| P3D | 3日 |
| P84D | 84日 |
| P1W | 1週間 |
| P1M | 1ヶ月 |

### レート制限一覧

| オペレーション | レート | バースト |
|---------------|--------|---------|
| getReports | 0.0222/秒 | 10 |
| createReport | 0.0167/秒 | 15 |
| getReport | 2/秒 | 15 |
| cancelReport | 0.0222/秒 | 10 |
| getReportSchedules | 0.0222/秒 | 10 |
| createReportSchedule | 0.0222/秒 | 10 |
| getReportSchedule | 0.0222/秒 | 10 |
| cancelReportSchedule | 0.0222/秒 | 10 |
| getReportDocument | 0.0167/秒 | 15 |
