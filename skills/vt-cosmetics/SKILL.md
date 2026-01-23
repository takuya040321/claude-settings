---
name: vt-cosmetics
description: VT Cosmetics公式オンラインショップ（https://vtcosmetics.jp/）のHTML構造を熟知したスキル。商品検索・一覧取得、商品詳細取得、カート・購入操作のスクレイピングやブラウザ自動操作に使用。ユーザーが「VT Cosmeticsの商品を検索して」「リードルショットの情報を取得して」「VTサイトから商品データを抽出して」「VTのカートに追加して」などと依頼した場合にトリガー。
---

# VT Cosmetics公式オンラインショップ スキル

VT Cosmetics日本公式サイト（https://vtcosmetics.jp/）のHTML構造とセレクタリファレンス。

## サイト概要

### 技術スタック

| 項目 | 詳細 |
|------|------|
| プラットフォーム | Cafe24（韓国発ECプラットフォーム） |
| 言語 | 日本語（一部韓国語UI残存） |
| チャット | Channel Talk統合 |
| 広告 | Criteo統合 |
| 特徴 | 動的読み込み多用、ブラウザ自動化推奨 |

## URL構造

### 基本URL

| ページ種別 | URL形式 | 例 |
|-----------|---------|-----|
| ショップトップ | `/shop.html` | |
| カテゴリ一覧 | `/product/list.html?cate_no={ID}` | `cate_no=199` |
| カテゴリ（SEO） | `/category/{name}/{ID}/` | `/category/reedle-s/199/` |
| 商品詳細 | `/product/detail.html?product_no={ID}` | `product_no=651` |
| 商品詳細（SEO） | `/product/{name}/{ID}/` | `/product/リードルショット100/651/` |
| 検索結果 | `/product/search.html?keyword={query}` | `keyword=シカ` |
| カート | `/order/basket.html` | |
| ログイン | `/member/login.html` | |
| 会員登録 | `/member/join.html` | |

### ソート・フィルターパラメータ

```
/product/list.html?cate_no={ID}&sort_method={N}&page={P}
```

| パラメータ | 値 | 意味 |
|-----------|-----|------|
| `sort_method` | 5 | 新着順 |
| `sort_method` | 3 | 低価格順 |
| `sort_method` | 4 | 高価格順 |
| `sort_method` | 6 | 人気商品順 |
| `sort_method` | 7 | レビュー順 |
| `sort_method` | 8 | 閲覧数順 |
| `page` | 1, 2, ... | ページ番号 |

## カテゴリ構造

### メインカテゴリ

| カテゴリ | cate_no | URL例 |
|---------|---------|-------|
| CICA | 51 | `/category/cica/51/` |
| CICA VITAL | 100 | `/category/cica-vital/100/` |
| CICA RETI-A | 102 | `/category/cica-reti-a/102/` |
| CICA COLLAGEN | 208 | `/category/cica-collagen/208/` |
| REEDLE S（リードルショット） | 199 | `/category/reedle-s/199/` |
| PDRN+ | 254 | `/category/pdrn/254/` |
| AZ CARE | 286 | `/category/az-care/286/` |

## DOM構造（アクセシビリティツリー）

### ページ全体構造

```
banner           - ヘッダー（ロゴ、検索、ナビゲーション）
main             - メインコンテンツ
  navigation     - パンくずリスト
  heading        - ページタイトル
  list           - 商品一覧
contentinfo      - フッター
```

### 商品カード構造（一覧ページ）

```
listitem
  link [href="/product/detail.html?product_no={ID}"]   # 商品画像リンク
    image "{商品画像}"
  link [href="javascript:"]
    image "カートに入れる"                              # カートボタン
  link [href="javascript:"]
    image "お気に入りに登録する前"                       # お気に入りボタン
  generic "REVIEW {N}"                                 # レビュー数
  checkbox                                             # 商品選択
  link [href="/product/detail.html?product_no={ID}"]
    generic "{商品名}"                                 # 商品名リンク
  generic "{説明文}"                                   # 商品説明
  generic "{価格}"                                     # 販売価格
  generic "{元価格}"                                   # 割引前価格（あれば）
```

### 商品詳細ページ構造

```
main
  heading "{商品名}"                                   # 商品名
  generic "{販売価格}"                                 # 価格
  generic "{内容量}"                                   # 内容量
  combobox [options]                                   # オプション選択
  textbox [type="text"]                               # 数量入力
  link "今すぐ購入"                                    # 購入ボタン
  link "カートに入れる"                                # カートボタン
  link "お気に入り"                                    # お気に入りボタン

# 商品詳細セクション
list
  listitem → generic "製品名" + generic "{製品名}"
  listitem → generic "商品区分" + generic "{区分}"
  listitem → generic "容量および重量" + generic "{容量}"
  listitem → generic "使用期限" + generic "{期限}"
  listitem → generic "生産国"
  listitem → generic "製造販売元" + generic "{メーカー}"
  listitem → generic "{全成分}"                       # 成分表示
  listitem → generic "使用上の注意" + generic "{注意事項}"

# レビューセクション
table
  link "{レビュータイトル}" [href="/article/review/..."]
  generic "{投稿者}"
  generic "{投稿日}"
  generic "{閲覧数}"
  image "{評価}점"
```

### 検索フォーム構造

```
form
  textbox [placeholder="検索ワードを入力してください。"]  # 検索入力
  textbox [type="image"]                                # 検索ボタン（画像型）

# 人気検索語
generic "人気検索語"
  link "#{キーワード}" [href="/product/search.html?keyword={keyword}"]
```

### ソート・フィルター構造

```
list
  link "新着" [href="?cate_no={ID}&sort_method=5"]
  link "低価格" [href="?cate_no={ID}&sort_method=3"]
  link "高価格" [href="?cate_no={ID}&sort_method=4"]
  link "人気商品" [href="?cate_no={ID}&sort_method=6"]
  link "レビュー" [href="?cate_no={ID}&sort_method=7"]
  link "閲覧数" [href="?cate_no={ID}&sort_method=8"]
```

### ページネーション構造

```
list
  listitem → link "1" [href="?page=1"]
  listitem → link "2" [href="?page=2"]
  ...
link [href="?page={N}"]
  image "다음 페이지"                                  # 次ページ（韓国語）
```

### カートページ構造

```
main
  table                                                # カート商品一覧
    row
      cell → checkbox                                  # 商品選択
      cell → image "{商品画像}"
      cell → link "{商品名}"
      cell → generic "{価格}"
      cell → textbox [type="text"]                    # 数量
      cell → generic "{小計}"
      cell → button "削除"
  generic "合計金額"
  generic "{合計}"
  link "注文する"                                      # 注文ボタン
```

## JavaScript操作コード

### 商品一覧の取得

```javascript
// 商品カードを全て取得
const productCards = document.querySelectorAll('li[class*="item"], .prdList li');

const products = [...productCards].map(card => {
  const link = card.querySelector('a[href*="/product/"]');
  const nameEl = card.querySelector('a[href*="/product/"] .name, .prdName');
  const priceEl = card.querySelector('.price, .prdPrice');
  const reviewEl = card.querySelector('[class*="review"], .review');

  const href = link?.href || '';
  const productNo = href.match(/product_no=(\d+)/)?.[1]
    || href.match(/\/product\/[^/]+\/(\d+)/)?.[1];

  return {
    productNo: productNo,
    url: href,
    name: nameEl?.textContent?.trim() || '',
    price: priceEl?.textContent?.trim() || '',
    reviewCount: reviewEl?.textContent?.match(/\d+/)?.[0] || '0'
  };
});
```

### 商品詳細の取得

```javascript
// 商品名
const productName = document.querySelector('h1, .headingArea h2')?.textContent?.trim();

// 価格
const price = document.querySelector('.price, #span_product_price_text')?.textContent?.trim();

// 内容量
const volume = [...document.querySelectorAll('td, .info')]
  .find(el => el.textContent.includes('容量'))?.textContent;

// 商品番号
const productNo = location.href.match(/product_no=(\d+)/)?.[1]
  || location.href.match(/\/product\/[^/]+\/(\d+)/)?.[1];

// 成分
const ingredients = [...document.querySelectorAll('li, td')]
  .find(el => el.textContent.includes('成分'))?.textContent;
```

### 検索の実行

```javascript
// 検索フォームに入力
const searchInput = document.querySelector('input[placeholder*="検索"]');
if (searchInput) {
  searchInput.value = 'リードルショット';
  searchInput.dispatchEvent(new Event('input', { bubbles: true }));

  // フォーム送信
  const form = searchInput.closest('form');
  form?.submit();
}
```

### カートに追加

```javascript
// オプションを選択（あれば）
const optionSelect = document.querySelector('select[id*="option"]');
if (optionSelect) {
  optionSelect.value = optionSelect.options[1]?.value;
  optionSelect.dispatchEvent(new Event('change', { bubbles: true }));
}

// 数量を設定
const qtyInput = document.querySelector('input[name*="quantity"], input[type="text"][value="1"]');
if (qtyInput) {
  qtyInput.value = '2';
  qtyInput.dispatchEvent(new Event('change', { bubbles: true }));
}

// カートボタンをクリック
const cartBtn = [...document.querySelectorAll('a, button')]
  .find(el => el.textContent.includes('カートに入れる'));
if (cartBtn) {
  cartBtn.click();
}
```

### ページネーション

```javascript
// 次のページへ
const nextBtn = document.querySelector('a[href*="page="]:last-child, img[alt*="다음"]')?.closest('a');
if (nextBtn) {
  nextBtn.click();
}

// 特定ページへ
const page3 = [...document.querySelectorAll('a[href*="page="]')]
  .find(el => el.textContent.trim() === '3');
if (page3) {
  page3.click();
}
```

## 注意事項

- **韓国語UI**: ページネーションボタン等が韓国語（「다음 페이지」= 次のページ）
- **動的読み込み**: 商品データは動的に読み込まれることが多い
- **レート制限**: 適切な間隔（1-2秒）を設けてリクエスト
- **認証**: ログイン必須の機能あり（お気に入り、購入など）
- **Cafe24固有**: URLパラメータ形式がCafe24標準

## 関連スキル

- `vt-cosmetics-scraping` - Python/Node.js/GASによるスクレイピング
- `vt-cosmetics-browser` - Claude in Chrome MCPによるブラウザ自動操作
