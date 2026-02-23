---
name: gas-spreadsheet
description: Google Apps Script (GAS) によるスプレッドシート操作の包括的なスキル。スプレッドシートのデータ操作、外部サービス連携、自動化・トリガー設定をサポート。ユーザーがGASでスプレッドシートを操作するコードを書きたい場合に使用。タスクの種類に応じて適切なリファレンスを参照する。
---

# Google Apps Script スプレッドシート

GASでスプレッドシートを操作するための包括的なガイド。タスクに応じて適切なリファレンスを参照する。

## タスク別リファレンス

| タスク | リファレンス |
|--------|-------------|
| データの読み書き・検索・書式設定・集計 | [references/spreadsheet-ops.md](references/spreadsheet-ops.md) |
| Slack/LINE/Gmail/カレンダー/API連携 | [references/external-integration.md](references/external-integration.md) |
| トリガー・バッチ処理・自動化 | [references/automation.md](references/automation.md) |

### 各領域の概要

- **スプレッドシート操作** - データの読み書き、検索、フィルタリング、書式設定、数式、シート管理、集計処理
- **外部サービス連携** - Slack、Discord、LINE通知、Gmail送信、Googleカレンダー、REST API、Drive/Docs連携、Webhook
- **自動化・トリガー** - 時間ベース/イベントトリガー、バッチ処理、データバックアップ、ワークフロー自動化

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

## 詳細リファレンス

- [スプレッドシート操作](references/spreadsheet-ops.md) - データ読み書き・検索・書式設定・集計
- [外部サービス連携](references/external-integration.md) - Slack/LINE/Gmail/API連携
- [自動化・トリガー](references/automation.md) - 定期実行・イベント駆動・バッチ処理
- [APIリファレンス](references/api_reference.md) - SpreadsheetApp API詳細
