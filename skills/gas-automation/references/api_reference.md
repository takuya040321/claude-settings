# GAS 自動化 APIリファレンス

## ScriptApp トリガーAPI

### トリガー作成

```javascript
// 時間ベース
ScriptApp.newTrigger('functionName')
  .timeBased()
  .everyMinutes(n)     // 1, 5, 10, 15, 30
  .everyHours(n)       // 1-24
  .everyDays(n)        // 1-31
  .everyWeeks(n)       // 1-4
  .onWeekDay(day)      // ScriptApp.WeekDay.MONDAY等
  .onMonthDay(day)     // 1-31
  .atHour(hour)        // 0-23
  .nearMinute(minute)  // 0, 15, 30, 45
  .after(milliseconds) // n秒後に1回
  .atDate(year, month, day)
  .at(date)
  .inTimezone(timezone)
  .create();

// スプレッドシート
ScriptApp.newTrigger('functionName')
  .forSpreadsheet(ss)
  .onOpen()
  .onChange()
  .onEdit()
  .onFormSubmit()
  .create();

// フォーム
ScriptApp.newTrigger('functionName')
  .forForm(form)
  .onFormSubmit()
  .onOpen()
  .create();

// ドキュメント
ScriptApp.newTrigger('functionName')
  .forDocument(doc)
  .onOpen()
  .create();

// カレンダー
ScriptApp.newTrigger('functionName')
  .forUserCalendar(email)
  .onEventUpdated()
  .create();
```

### トリガー管理

```javascript
// 全トリガー取得
ScriptApp.getProjectTriggers();

// トリガー情報
trigger.getHandlerFunction();
trigger.getEventType();
trigger.getTriggerSource();
trigger.getTriggerSourceId();
trigger.getUniqueId();

// 削除
ScriptApp.deleteTrigger(trigger);
```

## イベントオブジェクト

### onEdit(e)

```javascript
e.range          // 編集されたRange
e.value          // 新しい値
e.oldValue       // 古い値（単一セル時のみ）
e.source         // Spreadsheet
e.user           // User（インストーラブルのみ）
e.authMode       // 認証モード
e.triggerUid     // トリガーUID（インストーラブルのみ）
```

### onChange(e)

```javascript
e.changeType     // EDIT, INSERT_ROW, INSERT_COLUMN,
                 // REMOVE_ROW, REMOVE_COLUMN,
                 // INSERT_GRID, REMOVE_GRID, FORMAT, OTHER
e.source         // Spreadsheet
e.user           // User
```

### onFormSubmit(e)

```javascript
e.values         // 回答の配列
e.namedValues    // {質問名: [回答]} オブジェクト
e.range          // 回答が入力されたRange
e.source         // Spreadsheet
e.response       // FormResponse（フォームトリガー時）
```

### onOpen(e)

```javascript
e.source         // Spreadsheet/Document/Form
e.user           // User（インストーラブルのみ）
e.authMode       // 認証モード
```

### doGet(e) / doPost(e)

```javascript
e.parameter      // {key: value} クエリパラメータ
e.parameters     // {key: [values]} 複数値対応
e.queryString    // 生のクエリ文字列
e.contentLength  // コンテンツ長（POSTのみ）
e.postData       // POSTデータ（POSTのみ）
e.postData.contents  // ボディ文字列
e.postData.type      // MIMEタイプ
e.postData.length    // 長さ
e.pathInfo       // パス情報
```

## LockService

```javascript
// ロック取得
const lock = LockService.getScriptLock();     // スクリプト全体
const lock = LockService.getDocumentLock();   // ドキュメントごと
const lock = LockService.getUserLock();       // ユーザーごと

// ロック操作
lock.tryLock(timeoutInMillis);  // 試行（成功: true、失敗: false）
lock.waitLock(timeoutInMillis); // 待機（タイムアウトで例外）
lock.hasLock();                 // ロック保持確認
lock.releaseLock();             // 解放
```

## Utilities

### 日時

```javascript
Utilities.formatDate(date, 'Asia/Tokyo', 'yyyy/MM/dd HH:mm:ss');
Utilities.parseDate(string, 'Asia/Tokyo', 'yyyy/MM/dd');
```

### エンコード

```javascript
Utilities.base64Encode(data);
Utilities.base64Decode(encoded);
Utilities.base64EncodeWebSafe(data);
Utilities.base64DecodeWebSafe(encoded);
```

### ハッシュ

```javascript
Utilities.computeDigest(
  Utilities.DigestAlgorithm.MD5,
  data
);
// DigestAlgorithm: MD2, MD5, SHA_1, SHA_256, SHA_384, SHA_512
```

### UUID

```javascript
Utilities.getUuid();
```

### スリープ

```javascript
Utilities.sleep(milliseconds);  // 最大300000ms（5分）
```

### ZIP

```javascript
Utilities.zip(blobs, name);
Utilities.unzip(blob);
```

### Blob

```javascript
Utilities.newBlob(data, contentType, name);
```

## 制限事項

| 項目 | 通常実行 | トリガー実行 |
|------|---------|------------|
| 実行時間 | 6分 | 30分 |
| トリガー数 | 20個/ユーザー/スクリプト |
| トリガー実行 | 90分/日 |
| メール送信 | 100通/日（無料） |
| UrlFetch | 20,000回/日 |
| カレンダー作成 | 5,000イベント/日 |
| ドキュメント作成 | 250/日 |

## タイムゾーン

```javascript
// スクリプトプロジェクトのタイムゾーン
Session.getScriptTimeZone();

// トリガーのタイムゾーン
ScriptApp.newTrigger('func')
  .timeBased()
  .atHour(9)
  .everyDays(1)
  .inTimezone('Asia/Tokyo')
  .create();
```

主なタイムゾーン:
- `Asia/Tokyo` - 日本
- `America/New_York` - 東部時間
- `America/Los_Angeles` - 太平洋時間
- `Europe/London` - 英国
- `UTC` - 協定世界時
