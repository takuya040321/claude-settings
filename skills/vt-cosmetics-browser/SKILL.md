---
name: vt-cosmetics-browser
description: VT Cosmetics公式オンラインショップ（https://vtcosmetics.jp/）のブラウザ自動操作に特化したスキル。Claude in Chrome MCPを使用したインタラクティブな商品検索、商品詳細取得、カート操作、購入フローの自動化ガイド。ユーザーが「VTのサイトをブラウザで操作して」「リードルショットをカートに追加して」「VT Cosmeticsで商品を確認して」などと依頼した場合にトリガー。
---

# VT Cosmetics ブラウザ自動操作スキル

Claude in Chrome MCPを使用したVT Cosmetics公式サイト（https://vtcosmetics.jp/）の操作ガイド。

## 前提条件

- Claude in Chrome MCP拡張機能がインストール済み
- ブラウザタブがMCPグループに含まれている

## 基本操作フロー

### 1. セッション開始

```
1. tabs_context_mcp でタブ情報を取得
2. tabs_create_mcp で新規タブを作成（または既存タブを使用）
3. navigate でVT Cosmeticsにアクセス
```

### 2. ナビゲーション

| 操作 | URL |
|------|-----|
| ショップトップ | `https://vtcosmetics.jp/shop.html` |
| REEDLE S（リードルショット） | `https://vtcosmetics.jp/category/reedle-s/199/` |
| CICA | `https://vtcosmetics.jp/category/cica/51/` |
| 検索 | `https://vtcosmetics.jp/product/search.html?keyword={query}` |

## 商品検索

### 検索フォームを使用

```
1. navigate で https://vtcosmetics.jp/ にアクセス
2. find で「検索ワードを入力」を検索
3. form_input で検索キーワードを入力
4. computer (key: "Enter") で検索実行
5. computer (screenshot) で結果を確認
```

### 直接URLで検索

```
navigate: https://vtcosmetics.jp/product/search.html?keyword=リードルショット
```

## 商品一覧の閲覧

### カテゴリページにアクセス

```
1. navigate で https://vtcosmetics.jp/category/reedle-s/199/ にアクセス
2. read_page で商品一覧を取得
3. find で特定の商品を検索
```

### ソート変更

```
1. find で「新着」「人気商品」などのソートリンクを検索
2. computer (left_click) でクリック
```

### ページネーション

```
1. find で「다음 페이지」または「2」「3」などのページリンクを検索
2. computer (left_click) でクリック
3. computer (wait: 2) でページ読み込み待機
```

## 商品詳細の取得

### 商品ページにアクセス

```
1. navigate で https://vtcosmetics.jp/product/detail.html?product_no={ID} にアクセス
   または /product/{商品名}/{ID}/ 形式のURL
2. read_page で商品情報を取得
```

### 取得可能な情報

| 情報 | 取得方法 |
|------|----------|
| 商品名 | `find: "商品名"` または `read_page` でheading要素 |
| 価格 | `find: "価格"` または `read_page` で price クラス要素 |
| 内容量 | `read_page` で「容量」を含むテキスト |
| 成分 | `read_page` で「成分」を含むテキスト |
| レビュー | `read_page` でtable要素（レビュー一覧） |

### JavaScript実行で詳細取得

```javascript
// javascript_tool で実行
const productInfo = {
  name: document.querySelector('h1, .headingArea h2')?.textContent?.trim(),
  price: document.querySelector('.price, #span_product_price_text')?.textContent?.trim(),
  productNo: location.href.match(/product_no=(\d+)/)?.[1],
};
JSON.stringify(productInfo);
```

## カート操作

### カートに追加

```
1. 商品詳細ページにアクセス
2. オプションがある場合:
   - find で「オプション」を検索
   - form_input で値を選択
3. 数量変更（必要な場合）:
   - find で数量入力欄を検索
   - form_input で数量を入力
4. find で「カートに入れる」を検索
5. computer (left_click) でクリック
6. computer (wait: 2) でカート追加処理待機
7. computer (screenshot) で確認
```

### カートを確認

```
1. navigate で https://vtcosmetics.jp/order/basket.html にアクセス
2. read_page でカート内容を取得
```

### カート内の数量変更

```
1. カートページで find で数量入力欄を検索
2. triple_click で選択
3. computer (type) で新しい数量を入力
4. find で「更新」ボタンを検索してクリック
```

### カートから削除

```
1. find で「削除」ボタンを検索
2. computer (left_click) でクリック
3. 確認ダイアログが出る場合は対応
```

## 購入フロー

### 注意事項

- 購入操作は明示的なユーザー許可が必要
- ログインが必要な場合がある
- 決済情報の入力は禁止

### 購入画面への遷移

```
1. カートページで find で「注文する」を検索
2. computer (left_click) でクリック
3. ログイン画面が表示された場合:
   - ユーザーに手動ログインを依頼
4. computer (screenshot) で注文画面を確認
```

## 操作例

### 例1: リードルショットを検索して詳細を取得

```
手順:
1. navigate: https://vtcosmetics.jp/product/search.html?keyword=リードルショット
2. computer: screenshot
3. read_page: tabId
4. find: "リードルショット100"
5. computer: left_click (結果のref)
6. computer: wait 2
7. read_page: tabId （詳細情報取得）
```

### 例2: REEDLE Sカテゴリの商品一覧を取得

```
手順:
1. navigate: https://vtcosmetics.jp/category/reedle-s/199/
2. computer: screenshot
3. read_page: tabId
4. javascript_tool: (商品情報をJSON形式で抽出)
```

```javascript
// javascript_tool で実行
const products = [];
document.querySelectorAll('li[class*="item"], .prdList li').forEach(item => {
  const link = item.querySelector('a[href*="/product/"]');
  const nameEl = item.querySelector('.name, .prdName');
  const priceEl = item.querySelector('.price');
  if (link && nameEl) {
    products.push({
      name: nameEl.textContent.trim(),
      price: priceEl?.textContent?.trim() || '',
      url: link.href,
    });
  }
});
JSON.stringify(products, null, 2);
```

### 例3: 商品をカートに追加

```
手順:
1. navigate: https://vtcosmetics.jp/product/detail.html?product_no=651
2. computer: screenshot
3. find: "カートに入れる"
4. computer: left_click (ref)
5. computer: wait 2
6. computer: screenshot （追加完了確認）
7. navigate: https://vtcosmetics.jp/order/basket.html
8. read_page: tabId （カート内容確認）
```

### 例4: 人気順でソートして閲覧

```
手順:
1. navigate: https://vtcosmetics.jp/category/reedle-s/199/
2. find: "人気商品"
3. computer: left_click (ref)
4. computer: wait 2
5. computer: screenshot
6. read_page: tabId
```

## トラブルシューティング

### ページが読み込まれない

```
- computer: wait 3 で待機時間を増やす
- navigate で再度アクセス
- computer: screenshot で現在の状態を確認
```

### 要素が見つからない

```
- read_page でページ全体の構造を確認
- find のクエリを変更して再検索
- javascript_tool でDOMを直接確認
```

### ポップアップ・モーダルが表示された

```
- find で「閉じる」「×」を検索
- computer: key "Escape" で閉じる
- computer: screenshot で状態確認
```

### 韓国語UIへの対応

ページネーションボタンが韓国語の場合:
- 「다음」= 次へ
- 「이전」= 前へ

```
find: "다음" または find: "次のページ"
```

## カテゴリ番号一覧

| カテゴリ | cate_no | URL |
|---------|---------|-----|
| CICA | 51 | `/category/cica/51/` |
| CICA VITAL | 100 | `/category/cica-vital/100/` |
| CICA RETI-A | 102 | `/category/cica-reti-a/102/` |
| CICA COLLAGEN | 208 | `/category/cica-collagen/208/` |
| REEDLE S | 199 | `/category/reedle-s/199/` |
| PDRN+ | 254 | `/category/pdrn/254/` |
| AZ CARE | 286 | `/category/az-care/286/` |

## 注意事項

- **レート制限**: 操作間に1-2秒の待機を入れる
- **認証**: ログインが必要な機能はユーザーに手動操作を依頼
- **決済**: 決済情報の入力・購入確定は禁止
- **動的コンテンツ**: ページ読み込み後に `wait` で待機が必要な場合あり

## 関連スキル

- `vt-cosmetics` - 包括的なHTML構造・セレクタリファレンス
- `vt-cosmetics-scraping` - Python/Node.js/GASによるスクレイピング
