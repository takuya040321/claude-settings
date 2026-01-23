---
name: gas-spreadsheet
description: Google Apps Script (GAS) によるスプレッドシート操作の包括的なスキル。スプレッドシートのデータ操作、外部サービス連携、自動化・トリガー設定をサポート。ユーザーがGASでスプレッドシートを操作するコードを書きたい場合に使用。タスクの種類に応じて特化スキルを呼び出す：(1) データ操作 → gas-spreadsheet-ops、(2) 外部連携 → gas-external-integration、(3) 自動化 → gas-automation。
---

# Google Apps Script スプレッドシート

## 概要

GASでスプレッドシートを操作するための包括的なガイド。タスクに応じて適切な特化スキルを選択。

## タスク振り分け

### 1. スプレッドシート操作（gas-spreadsheet-ops）

以下の場合に`gas-spreadsheet-ops`スキルを使用：

- データの読み書き、検索、フィルタリング
- セルの書式設定、条件付き書式
- 数式の設定、カスタム関数の作成
- シートの作成、削除、保護
- データの集計、ピボット的処理

### 2. 外部サービス連携（gas-external-integration）

以下の場合に`gas-external-integration`スキルを使用：

- Slack、Discord、LINEへの通知
- Gmail送信、Googleカレンダー連携
- 外部APIとの連携（REST API）
- 他のGoogleサービス（Drive、Docs）との連携
- Webhookの送受信

### 3. 自動化・トリガー（gas-automation）

以下の場合に`gas-automation`スキルを使用：

- 時間ベースのトリガー（定期実行）
- イベントトリガー（編集時、フォーム送信時）
- バッチ処理、一括更新
- データバックアップの自動化
- ワークフロー自動化

## 共通パターン

### スプレッドシートの取得

```javascript
// アクティブなスプレッドシート
const ss = SpreadsheetApp.getActiveSpreadsheet();
const sheet = ss.getActiveSheet();

// IDで指定
const ss = SpreadsheetApp.openById('スプレッドシートID');

// URLで指定
const ss = SpreadsheetApp.openByUrl('URL');
```

### エラーハンドリング

```javascript
function safeExecute(fn) {
  try {
    return fn();
  } catch (e) {
    console.error(`Error: ${e.message}`);
    // 必要に応じて通知
    return null;
  }
}
```

### ログ出力

```javascript
// 開発時のデバッグ
console.log('Debug:', data);
Logger.log('Log:', data);

// 実行ログの確認: 表示 → ログ
```

## ベストプラクティス

1. **バッチ処理**: `getValues()`/`setValues()`で一括操作（ループでの`getValue()`は避ける）
2. **キャッシュ活用**: `CacheService`で頻繁なAPI呼び出しを削減
3. **実行時間制限**: 6分制限を意識し、長時間処理は分割
4. **権限スコープ**: 必要最小限の権限を使用

## リファレンス

詳細なAPIリファレンスは[references/api_reference.md](references/api_reference.md)を参照。
