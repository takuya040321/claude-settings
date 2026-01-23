---
name: browser-automation
description: ブラウザ自動操作のための包括的なガイド。Webスクレイピング、フォーム自動入力、E2Eテスト、業務自動化をサポート。ユーザーが「ブラウザを自動操作して」「Webページからデータを取得して」「フォームに自動入力して」「Webアプリをテストして」などと依頼した場合にトリガー。
---

# ブラウザ自動操作

## 技術選択ガイド

```
ユーザーリクエスト
    │
    ├─ Claude Code内でインタラクティブに操作？
    │   └─ はい → browser-mcp スキル
    │
    └─ いいえ（スクリプト実行）
        │
        ├─ 使用言語は？
        │   │
        │   ├─ Python
        │   │   ├─ 推奨 → browser-playwright (Python)
        │   │   └─ レガシー/特殊要件 → browser-selenium
        │   │
        │   └─ Node.js/TypeScript
        │       ├─ 推奨 → browser-playwright (Node.js)
        │       └─ Chrome特化 → browser-puppeteer
        │
        └─ 用途で選択
            ├─ スクレイピング → Playwright推奨
            ├─ E2Eテスト → Playwright推奨
            ├─ フォーム操作 → Playwright/MCP
            └─ レガシーブラウザ対応 → Selenium
```

## 技術比較

| 技術 | 言語 | 特徴 | 推奨用途 |
|------|------|------|----------|
| Playwright | Python/Node.js | 高速、モダン、マルチブラウザ | スクレイピング、E2Eテスト |
| Puppeteer | Node.js | Chrome特化、軽量 | Chrome限定の自動化 |
| Selenium | Python/Java/他 | 歴史が長い、多言語対応 | レガシーシステム |
| Claude in Chrome MCP | - | Claude Code統合 | インタラクティブ操作 |

## 特化スキルへのナビゲーション

### browser-playwright
**Playwright**（Python/Node.js）によるブラウザ自動操作。スクレイピング、フォーム操作、E2Eテストに最適。

### browser-puppeteer
**Puppeteer**（Node.js）によるChrome/Chromium特化の自動操作。

### browser-selenium
**Selenium**（Python/Java/多言語）による自動操作。レガシーシステムや特殊要件向け。

### browser-mcp
**Claude in Chrome MCP**によるインタラクティブなブラウザ操作。Claude Code内で直接ブラウザを操作。

## 共通ベストプラクティス

### セレクター戦略
```
優先順位：
1. data-testid / data-cy 属性（テスト用）
2. aria-label / role（アクセシビリティ）
3. ID属性
4. CSSセレクター
5. XPath（最後の手段）
```

### 待機戦略
```
推奨：
✅ 要素の出現を待機（明示的待機）
✅ ネットワークアイドルを待機
✅ 特定の条件を待機

避ける：
❌ 固定時間のsleep
❌ 暗黙的待機のみに依存
```

### エラーハンドリング
- タイムアウト時のリトライロジック
- 要素が見つからない場合のフォールバック
- スクリーンショットによるデバッグ

### アンチボット対策への配慮
- 適切な待機時間を設定
- User-Agentの設定
- ヘッドレスモードの検出回避（必要に応じて）
- robots.txtの尊重
