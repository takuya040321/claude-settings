# GAS 外部連携 APIリファレンス

## UrlFetchApp

### fetchオプション

```javascript
UrlFetchApp.fetch(url, {
  method: 'get',              // get, post, put, patch, delete
  contentType: 'application/json',
  headers: {
    'Authorization': 'Bearer TOKEN',
    'X-Custom-Header': 'value'
  },
  payload: JSON.stringify(data), // POSTデータ
  muteHttpExceptions: true,      // エラーでも例外を投げない
  followRedirects: true,         // リダイレクト追従
  validateHttpsCertificates: true,
  escaping: true                 // URLエンコード
});
```

### HTTPResponse

```javascript
const response = UrlFetchApp.fetch(url);

response.getResponseCode();     // HTTPステータスコード
response.getContentText();      // レスポンスボディ（文字列）
response.getContent();          // レスポンスボディ（バイト配列）
response.getHeaders();          // レスポンスヘッダー
response.getBlob();             // Blobオブジェクト
response.getAs(mimeType);       // 指定MIMEタイプで取得
```

### 一括リクエスト

```javascript
const requests = [
  {url: 'https://api1.example.com'},
  {url: 'https://api2.example.com', method: 'post', payload: '...'}
];
const responses = UrlFetchApp.fetchAll(requests);
```

## GmailApp

### メール送信

```javascript
GmailApp.sendEmail(recipient, subject, body, {
  htmlBody: '<h1>HTML</h1>',
  cc: 'cc@example.com',
  bcc: 'bcc@example.com',
  from: 'alias@example.com',    // 送信元エイリアス
  name: '送信者名',
  replyTo: 'reply@example.com',
  noReply: true,                // 返信不可
  attachments: [blob1, blob2],
  inlineImages: {imageKey: blob}
});
```

### メール検索演算子

| 演算子 | 説明 | 例 |
|--------|------|-----|
| `from:` | 送信者 | `from:sender@example.com` |
| `to:` | 宛先 | `to:me` |
| `subject:` | 件名 | `subject:会議` |
| `is:unread` | 未読 | `is:unread` |
| `is:starred` | スター付き | `is:starred` |
| `has:attachment` | 添付あり | `has:attachment` |
| `after:` | 日付以降 | `after:2024/01/01` |
| `before:` | 日付以前 | `before:2024/12/31` |
| `newer_than:` | 期間内 | `newer_than:7d` |
| `older_than:` | 期間外 | `older_than:1m` |
| `label:` | ラベル | `label:仕事` |
| `in:` | フォルダ | `in:inbox`, `in:sent` |

## CalendarApp

### イベント作成

```javascript
const calendar = CalendarApp.getDefaultCalendar();

// 通常イベント
calendar.createEvent(title, startTime, endTime, {
  description: '説明',
  location: '場所',
  guests: 'guest1@example.com,guest2@example.com',
  sendInvites: true
});

// 終日イベント
calendar.createAllDayEvent(title, date, {
  description: '説明'
});

// 繰り返しイベント
const recurrence = CalendarApp.newRecurrence()
  .addDailyRule()
  .times(10);  // 10回

calendar.createEventSeries(title, startTime, endTime, recurrence, {
  description: '説明'
});
```

### 繰り返しルール

```javascript
CalendarApp.newRecurrence()
  .addDailyRule()           // 毎日
  .addWeeklyRule()          // 毎週
  .addMonthlyRule()         // 毎月
  .addYearlyRule()          // 毎年
  .interval(2)              // 2日/週/月/年おき
  .times(10)                // 10回
  .until(endDate)           // 終了日まで
  .onlyOnWeekday(ScriptApp.WeekDay.MONDAY)
  .onlyOnMonthDay(15)       // 毎月15日
```

## DriveApp

### ファイル操作

```javascript
// 作成
DriveApp.createFile(name, content, mimeType);
DriveApp.createFile(blob);

// 取得
DriveApp.getFileById(fileId);
DriveApp.getFilesByName(name);
DriveApp.searchFiles(query);

// File API
file.getId();
file.getName();
file.getUrl();
file.getBlob();
file.getAs(mimeType);
file.makeCopy();
file.moveTo(folder);
file.setTrashed(true);
file.setSharing(access, permission);
```

### フォルダ操作

```javascript
// 取得
DriveApp.getFolderById(folderId);
DriveApp.getFoldersByName(name);
DriveApp.getRootFolder();

// Folder API
folder.createFile(blob);
folder.createFolder(name);
folder.getFiles();
folder.getFolders();
folder.searchFiles(query);
```

### 検索クエリ

| クエリ | 説明 |
|--------|------|
| `title = 'name'` | 名前完全一致 |
| `title contains 'name'` | 名前部分一致 |
| `mimeType = 'application/pdf'` | MIMEタイプ |
| `modifiedDate > '2024-01-01'` | 更新日 |
| `'folderId' in parents` | 親フォルダ |
| `trashed = false` | ゴミ箱以外 |

## PropertiesService

```javascript
// スクリプトプロパティ（全ユーザー共通）
const scriptProps = PropertiesService.getScriptProperties();
scriptProps.getProperty('KEY');
scriptProps.setProperty('KEY', 'VALUE');
scriptProps.deleteProperty('KEY');
scriptProps.getProperties();  // 全取得

// ユーザープロパティ（ユーザーごと）
const userProps = PropertiesService.getUserProperties();

// ドキュメントプロパティ（ドキュメントごと）
const docProps = PropertiesService.getDocumentProperties();
```

## CacheService

```javascript
const cache = CacheService.getScriptCache();

// 取得・設定
cache.get('KEY');
cache.put('KEY', 'VALUE', 600);  // 600秒有効
cache.remove('KEY');

// 一括操作
cache.getAll(['KEY1', 'KEY2']);
cache.putAll({KEY1: 'V1', KEY2: 'V2'}, 600);
cache.removeAll(['KEY1', 'KEY2']);
```

## ContentService（Web App）

```javascript
// JSONレスポンス
ContentService.createTextOutput(JSON.stringify(data))
  .setMimeType(ContentService.MimeType.JSON);

// XMLレスポンス
ContentService.createTextOutput(xmlString)
  .setMimeType(ContentService.MimeType.XML);

// テキストレスポンス
ContentService.createTextOutput('Hello');

// MIMEタイプ
ContentService.MimeType.ATOM
ContentService.MimeType.CSV
ContentService.MimeType.ICAL
ContentService.MimeType.JAVASCRIPT
ContentService.MimeType.JSON
ContentService.MimeType.RSS
ContentService.MimeType.TEXT
ContentService.MimeType.VCARD
ContentService.MimeType.XML
```
