---
name: gas-external-integration
description: GASによる外部サービス連携に特化したスキル。Slack、Discord、LINE通知、Gmail送信、Googleカレンダー連携、外部API（REST）呼び出し、他のGoogleサービス（Drive、Docs）連携、Webhookの送受信をサポート。ユーザーが「Slackに通知して」「メールを送って」「APIを叩いて」「Driveにファイルを保存して」などの外部連携を依頼した場合に使用。
---

# GAS 外部サービス連携

## HTTP リクエスト（UrlFetchApp）

### 基本パターン

```javascript
// GET
const response = UrlFetchApp.fetch('https://api.example.com/data');
const data = JSON.parse(response.getContentText());

// POST
const response = UrlFetchApp.fetch('https://api.example.com/data', {
  method: 'post',
  contentType: 'application/json',
  payload: JSON.stringify({key: 'value'}),
  headers: {
    'Authorization': 'Bearer YOUR_TOKEN'
  },
  muteHttpExceptions: true  // エラーでも例外を投げない
});

// レスポンス処理
const statusCode = response.getResponseCode();
const body = JSON.parse(response.getContentText());
```

## Slack連携

### Incoming Webhook

```javascript
function sendToSlack(message, channel = '#general') {
  const webhookUrl = PropertiesService.getScriptProperties()
    .getProperty('SLACK_WEBHOOK_URL');

  const payload = {
    channel: channel,
    text: message,
    username: 'GAS Bot'
  };

  UrlFetchApp.fetch(webhookUrl, {
    method: 'post',
    contentType: 'application/json',
    payload: JSON.stringify(payload)
  });
}
```

### Block Kit（リッチメッセージ）

```javascript
function sendSlackBlocks(title, fields) {
  const webhookUrl = PropertiesService.getScriptProperties()
    .getProperty('SLACK_WEBHOOK_URL');

  const blocks = [
    {type: 'header', text: {type: 'plain_text', text: title}},
    {type: 'section', fields: fields.map(f => ({
      type: 'mrkdwn',
      text: `*${f.label}*\n${f.value}`
    }))}
  ];

  UrlFetchApp.fetch(webhookUrl, {
    method: 'post',
    contentType: 'application/json',
    payload: JSON.stringify({blocks})
  });
}
```

## LINE Notify

```javascript
function sendToLine(message) {
  const token = PropertiesService.getScriptProperties()
    .getProperty('LINE_NOTIFY_TOKEN');

  UrlFetchApp.fetch('https://notify-api.line.me/api/notify', {
    method: 'post',
    headers: {'Authorization': 'Bearer ' + token},
    payload: {message: message}
  });
}
```

## Discord Webhook

```javascript
function sendToDiscord(message, embedTitle = null) {
  const webhookUrl = PropertiesService.getScriptProperties()
    .getProperty('DISCORD_WEBHOOK_URL');

  const payload = embedTitle
    ? {embeds: [{title: embedTitle, description: message}]}
    : {content: message};

  UrlFetchApp.fetch(webhookUrl, {
    method: 'post',
    contentType: 'application/json',
    payload: JSON.stringify(payload)
  });
}
```

## Gmail連携

```javascript
// メール送信
GmailApp.sendEmail(
  'to@example.com',
  '件名',
  '本文（プレーンテキスト）',
  {
    htmlBody: '<h1>HTML本文</h1>',
    cc: 'cc@example.com',
    bcc: 'bcc@example.com',
    attachments: [file.getAs(MimeType.PDF)],
    name: '送信者名'
  }
);

// メール検索
const threads = GmailApp.search('from:sender@example.com is:unread', 0, 10);
threads.forEach(thread => {
  const messages = thread.getMessages();
  messages.forEach(msg => {
    console.log(msg.getSubject(), msg.getPlainBody());
  });
});
```

## Googleカレンダー連携

```javascript
const calendar = CalendarApp.getDefaultCalendar();

// イベント作成
const event = calendar.createEvent(
  'ミーティング',
  new Date('2024-01-15 10:00'),
  new Date('2024-01-15 11:00'),
  {
    description: '詳細説明',
    location: '会議室A',
    guests: 'guest@example.com'
  }
);

// イベント取得
const events = calendar.getEvents(
  new Date('2024-01-01'),
  new Date('2024-01-31')
);
events.forEach(e => console.log(e.getTitle(), e.getStartTime()));
```

## Google Drive連携

```javascript
// ファイル作成
const file = DriveApp.createFile('test.txt', 'コンテンツ', MimeType.PLAIN_TEXT);

// フォルダ操作
const folder = DriveApp.getFolderById('フォルダID');
folder.createFile(blob);
file.moveTo(folder);

// ファイル検索
const files = DriveApp.searchFiles('title contains "レポート"');
while (files.hasNext()) {
  const file = files.next();
  console.log(file.getName(), file.getUrl());
}

// スプレッドシートをPDFで保存
const ss = SpreadsheetApp.getActiveSpreadsheet();
const pdf = ss.getAs(MimeType.PDF);
folder.createFile(pdf);
```

## Google Docs連携

```javascript
// ドキュメント作成
const doc = DocumentApp.create('新しいドキュメント');
const body = doc.getBody();
body.appendParagraph('タイトル').setHeading(DocumentApp.ParagraphHeading.HEADING1);
body.appendParagraph('本文テキスト');

// テンプレートから生成
function createFromTemplate(templateId, replacements) {
  const template = DriveApp.getFileById(templateId);
  const copy = template.makeCopy();
  const doc = DocumentApp.openById(copy.getId());
  const body = doc.getBody();

  Object.entries(replacements).forEach(([key, value]) => {
    body.replaceText(`{{${key}}}`, value);
  });

  doc.saveAndClose();
  return copy;
}
```

## Webhook受信（Web App）

```javascript
// doGet: GETリクエストの処理
function doGet(e) {
  const params = e.parameter;
  // 処理
  return ContentService.createTextOutput(JSON.stringify({status: 'ok'}))
    .setMimeType(ContentService.MimeType.JSON);
}

// doPost: POSTリクエストの処理
function doPost(e) {
  const data = JSON.parse(e.postData.contents);
  // 処理
  return ContentService.createTextOutput(JSON.stringify({status: 'ok'}))
    .setMimeType(ContentService.MimeType.JSON);
}
```

デプロイ手順: デプロイ → 新しいデプロイ → ウェブアプリ → アクセス権限を設定

## プロパティ管理（認証情報）

```javascript
// スクリプトプロパティ（設定: プロジェクト設定 → スクリプトプロパティ）
const props = PropertiesService.getScriptProperties();
const apiKey = props.getProperty('API_KEY');
props.setProperty('API_KEY', 'new_value');

// ユーザープロパティ（ユーザーごと）
const userProps = PropertiesService.getUserProperties();
```

## リファレンス

詳細なAPIリファレンスは[references/api_reference.md](references/api_reference.md)を参照。
