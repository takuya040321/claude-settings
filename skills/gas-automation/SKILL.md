---
name: gas-automation
description: GASによる自動化・トリガー設定に特化したスキル。時間ベースのトリガー（定期実行）、イベントトリガー（編集時、フォーム送信時）、バッチ処理、データバックアップ、ワークフロー自動化をサポート。ユーザーが「毎日実行して」「編集されたら通知して」「フォーム送信時に処理して」「自動でバックアップして」などの自動化を依頼した場合に使用。
---

# GAS 自動化・トリガー

## トリガーの種類

| トリガー | 説明 | ユースケース |
|---------|------|-------------|
| 時間主導型 | 指定時刻/間隔で実行 | 日次レポート、定期バックアップ |
| スプレッドシート | 編集時、変更時、開いた時 | データ検証、ログ記録 |
| フォーム送信時 | Googleフォーム送信時 | 自動返信、通知 |
| カレンダー | イベント更新時 | スケジュール同期 |
| インストーラブル | プログラムで作成 | 動的トリガー管理 |

## 時間主導型トリガー

### UIから設定

トリガー → トリガーを追加 → 時間主導型を選択

### プログラムで作成

```javascript
// 毎日特定時刻に実行
function createDailyTrigger() {
  ScriptApp.newTrigger('dailyTask')
    .timeBased()
    .atHour(9)
    .everyDays(1)
    .create();
}

// 毎時実行
function createHourlyTrigger() {
  ScriptApp.newTrigger('hourlyTask')
    .timeBased()
    .everyHours(1)
    .create();
}

// 毎週月曜日
function createWeeklyTrigger() {
  ScriptApp.newTrigger('weeklyTask')
    .timeBased()
    .onWeekDay(ScriptApp.WeekDay.MONDAY)
    .atHour(10)
    .create();
}

// 毎月1日
function createMonthlyTrigger() {
  ScriptApp.newTrigger('monthlyTask')
    .timeBased()
    .onMonthDay(1)
    .atHour(9)
    .create();
}
```

## イベントトリガー

### スプレッドシート編集時

```javascript
// シンプルトリガー（権限不要、制限あり）
function onEdit(e) {
  const range = e.range;
  const value = e.value;
  const oldValue = e.oldValue;
  const sheet = range.getSheet();

  // 特定列の編集時のみ処理
  if (range.getColumn() === 3) { // C列
    range.offset(0, 1).setValue(new Date()); // D列に日時記録
  }
}

// インストーラブルトリガー（フル権限）
function createEditTrigger() {
  ScriptApp.newTrigger('onSheetEdit')
    .forSpreadsheet(SpreadsheetApp.getActive())
    .onEdit()
    .create();
}

function onSheetEdit(e) {
  // UrlFetchApp等も使用可能
}
```

### フォーム送信時

```javascript
function createFormTrigger() {
  ScriptApp.newTrigger('onFormSubmit')
    .forSpreadsheet(SpreadsheetApp.getActive())
    .onFormSubmit()
    .create();
}

function onFormSubmit(e) {
  const responses = e.namedValues; // {質問名: [回答]}
  const row = e.range.getRow();

  // メール通知
  const email = responses['メールアドレス'][0];
  const name = responses['お名前'][0];
  GmailApp.sendEmail(email, '送信完了', `${name}様、ありがとうございます。`);
}
```

## トリガー管理

```javascript
// 全トリガー取得
const triggers = ScriptApp.getProjectTriggers();

// 特定関数のトリガー削除
function deleteTriggers(functionName) {
  ScriptApp.getProjectTriggers().forEach(trigger => {
    if (trigger.getHandlerFunction() === functionName) {
      ScriptApp.deleteTrigger(trigger);
    }
  });
}

// 全トリガー削除
function deleteAllTriggers() {
  ScriptApp.getProjectTriggers().forEach(trigger => {
    ScriptApp.deleteTrigger(trigger);
  });
}
```

## バッチ処理

### 大量データ処理（6分制限対策）

```javascript
function batchProcess() {
  const props = PropertiesService.getScriptProperties();
  const startRow = Number(props.getProperty('BATCH_ROW') || 2);
  const batchSize = 100;

  const sheet = SpreadsheetApp.getActiveSheet();
  const lastRow = sheet.getLastRow();

  if (startRow > lastRow) {
    props.deleteProperty('BATCH_ROW');
    console.log('処理完了');
    return;
  }

  const endRow = Math.min(startRow + batchSize - 1, lastRow);
  const data = sheet.getRange(startRow, 1, endRow - startRow + 1, 5).getValues();

  // 処理
  data.forEach((row, i) => {
    // 各行の処理
  });

  // 次回開始位置を保存
  props.setProperty('BATCH_ROW', String(endRow + 1));

  // 残りがあれば次のトリガーを作成
  if (endRow < lastRow) {
    ScriptApp.newTrigger('batchProcess')
      .timeBased()
      .after(1000) // 1秒後
      .create();
  }
}
```

### 進捗管理

```javascript
function processWithProgress() {
  const sheet = SpreadsheetApp.getActiveSheet();
  const data = sheet.getDataRange().getValues();
  const total = data.length - 1;
  let processed = 0;

  data.slice(1).forEach((row, i) => {
    // 処理
    processed++;

    // 100件ごとに進捗更新
    if (processed % 100 === 0) {
      console.log(`進捗: ${processed}/${total} (${Math.round(processed/total*100)}%)`);
    }
  });
}
```

## データバックアップ

```javascript
function backupSheet() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const backupFolder = DriveApp.getFolderById('バックアップフォルダID');

  // スプレッドシートをコピー
  const timestamp = Utilities.formatDate(new Date(), 'Asia/Tokyo', 'yyyyMMdd_HHmmss');
  const copy = DriveApp.getFileById(ss.getId()).makeCopy(
    `${ss.getName()}_backup_${timestamp}`,
    backupFolder
  );

  // 古いバックアップを削除（30日以上前）
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - 30);

  const files = backupFolder.getFiles();
  while (files.hasNext()) {
    const file = files.next();
    if (file.getDateCreated() < cutoff) {
      file.setTrashed(true);
    }
  }
}

// 日次バックアップトリガー
function setupDailyBackup() {
  ScriptApp.newTrigger('backupSheet')
    .timeBased()
    .atHour(2)
    .everyDays(1)
    .create();
}
```

## ワークフロー自動化

### 承認フロー

```javascript
function onStatusChange(e) {
  const sheet = e.range.getSheet();
  if (sheet.getName() !== '申請' || e.range.getColumn() !== 5) return; // E列=ステータス

  const row = e.range.getRow();
  const status = e.value;
  const applicant = sheet.getRange(row, 2).getValue(); // B列=申請者
  const email = sheet.getRange(row, 3).getValue();     // C列=メール

  switch (status) {
    case '承認':
      GmailApp.sendEmail(email, '申請が承認されました', `${applicant}様、申請が承認されました。`);
      break;
    case '却下':
      GmailApp.sendEmail(email, '申請が却下されました', `${applicant}様、申請が却下されました。`);
      break;
  }
}
```

## ロック機構（同時実行制御）

```javascript
function exclusiveProcess() {
  const lock = LockService.getScriptLock();

  try {
    // 30秒間ロック取得を試行
    if (!lock.tryLock(30000)) {
      console.log('ロック取得失敗');
      return;
    }

    // 排他処理
    // ...

  } finally {
    lock.releaseLock();
  }
}
```

## リファレンス

詳細なAPIリファレンスは[references/api_reference.md](references/api_reference.md)を参照。
