---
name: html-structure-analyzer
description: WebサイトのHTML構造を解析・ドキュメント化するスキル。ブラウザ自動操作やスクレイピングのためのセレクタ特定、DOM構造の可視化、操作スクリプト生成をサポート。ユーザーが「このサイトのHTML構造を解析して」「セレクタを特定して」「DOM構造を調べて」「スクレイピング用のコードを書いて」などと依頼した場合にトリガー。特定サイト用スキル（例：dhc-online-shop）が存在する場合はそちらを優先使用。
---

# HTML構造解析スキル

WebサイトのHTML/DOM構造を解析し、ブラウザ自動操作やスクレイピングに必要な情報をドキュメント化する。

## 前提条件：既存の特定サイトスキル確認

解析対象サイトに特化したスキルが存在する場合、そちらを優先使用：

| サイト | スキル名 | 対象URL |
|--------|----------|---------|
| DHC公式オンラインショップ | `dhc-online-shop` | `www.dhc.co.jp` |
| VT Cosmetics公式オンラインショップ | `vt-cosmetics` | `vtcosmetics.jp` |

新しいサイトの解析結果は、同様の形式でスキル化を検討。

## 解析ワークフロー

### 1. ページ構造の把握

Claude in Chromeの`read_page`ツールでアクセシビリティツリーを取得：

```
read_page(tabId, filter="all")      # 全要素
read_page(tabId, filter="interactive")  # インタラクティブ要素のみ
read_page(tabId, depth=5)           # 深度制限
read_page(tabId, ref_id="ref_123")  # 特定要素以下
```

### 2. 要素の特定

`find`ツールで自然言語検索：

```
find(tabId, "検索ボックス")
find(tabId, "カートに入れるボタン")
find(tabId, "商品価格")
```

### 3. セレクタの抽出

JavaScriptで詳細なセレクタを取得：

```javascript
// 要素のユニークセレクタを生成
function getSelector(el) {
  if (el.id) return `#${el.id}`;
  if (el.className) {
    const classes = [...el.classList].join('.');
    if (document.querySelectorAll(`.${classes}`).length === 1) {
      return `.${classes}`;
    }
  }
  // 属性ベースのセレクタ
  const attrs = ['name', 'type', 'placeholder', 'data-testid', 'aria-label'];
  for (const attr of attrs) {
    if (el.hasAttribute(attr)) {
      const val = el.getAttribute(attr);
      const sel = `${el.tagName.toLowerCase()}[${attr}="${val}"]`;
      if (document.querySelectorAll(sel).length === 1) return sel;
    }
  }
  // パスベース
  const path = [];
  while (el && el.nodeType === 1) {
    let selector = el.tagName.toLowerCase();
    const siblings = el.parentNode?.querySelectorAll(`:scope > ${selector}`);
    if (siblings?.length > 1) {
      const idx = [...siblings].indexOf(el) + 1;
      selector += `:nth-child(${idx})`;
    }
    path.unshift(selector);
    el = el.parentNode;
  }
  return path.join(' > ');
}
```

## 解析結果のドキュメント形式

### ページ全体構造

```
[ロール] "名前/ラベル"
  [子ロール] "名前"
    ...
```

例：
```
banner          - ヘッダー
  navigation    - メインナビ
  search        - 検索フォーム
main            - メインコンテンツ
  heading       - ページタイトル
  region        - コンテンツセクション
contentinfo     - フッター
```

### 要素詳細

```
要素名: [説明]
├─ セレクタ: [CSS/XPath]
├─ ロール: [ARIAロール]
├─ 属性: [重要な属性]
└─ 子要素: [主な子要素]
```

### URL構造

```
| ページ種別 | URL形式 | 備考 |
|-----------|---------|------|
| トップ | `/` | |
| 一覧 | `/category/{id}` | |
| 詳細 | `/item/{id}` | |
```

## 共通パターン

### Eコマースサイト

```javascript
// 商品カード
const products = document.querySelectorAll('[class*="product"], [class*="item"]');
products.forEach(p => ({
  name: p.querySelector('[class*="name"], [class*="title"]')?.textContent,
  price: p.querySelector('[class*="price"]')?.textContent,
  url: p.querySelector('a')?.href,
  image: p.querySelector('img')?.src
}));

// カートボタン
document.querySelector('[class*="cart"], [class*="add-to-cart"], button[type="submit"]');

// 数量選択
document.querySelector('select[name*="qty"], input[type="number"]');
```

### フォーム

```javascript
// 入力フィールド
document.querySelectorAll('input:not([type="hidden"]), textarea, select');

// 送信ボタン
document.querySelector('button[type="submit"], input[type="submit"]');

// バリデーションメッセージ
document.querySelectorAll('[class*="error"], [class*="validation"], [role="alert"]');
```

### ナビゲーション

```javascript
// メニュー
document.querySelector('nav, [role="navigation"]');

// パンくず
document.querySelector('[class*="breadcrumb"], nav[aria-label*="breadcrumb"]');

// ページネーション
document.querySelector('[class*="pagination"], [class*="pager"]');
```

## 技術スタック検出

```javascript
// フレームワーク検出
const detectStack = () => {
  const stack = [];
  if (window.React || document.querySelector('[data-reactroot]')) stack.push('React');
  if (window.Vue || document.querySelector('[data-v-]')) stack.push('Vue');
  if (window.angular || document.querySelector('[ng-app]')) stack.push('Angular');
  if (window.jQuery || window.$) stack.push('jQuery');
  if (document.querySelector('[class*="wp-"]')) stack.push('WordPress');
  if (document.querySelector('[class*="shopify"]')) stack.push('Shopify');
  return stack;
};
```

## スキル化の推奨

解析結果は、サイト固有のスキルとして保存することを推奨：

```
skills/
└── {site-name}/
    └── SKILL.md
        ├── カテゴリ/URL構造
        ├── DOM構造（アクセシビリティツリー形式）
        ├── セレクタ一覧
        └── 操作スクリプト例
```

`dhc-online-shop`スキルを参照例として使用。

## 注意事項

- 動的コンテンツ（SPA）はページ読み込み後に解析
- iframeは別途解析が必要
- Shadow DOMは通常のセレクタでアクセス不可
- レート制限を考慮した適切な間隔を設ける
