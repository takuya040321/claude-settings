# DHC化粧品 セレクタリファレンス（実測値）

2025年1月にClaude in Chromeで実際に検証したDOM構造。

## ページ構造（アクセシビリティツリー）

### 全体構造

| 要素 | 役割 |
|------|------|
| `banner` | ヘッダー |
| `main` | メインコンテンツ |
| `navigation "breadcrumb"` | パンくずリスト |
| `contentinfo` | フッター |

### ヘッダー（banner）

```
banner
  button "サイドメニューを開く"
  link [href="/"] → image "logo"
  list → listitem (カテゴリメニュー)
  search
    combobox [placeholder="キーワードまたは商品番号を入力"]
    button "Clear search keywords" [type="reset"]
    button "Submit search keywords" [type="submit"]
  link "ログイン／新規登録" [href="/login/"]
  navigation "グローバルナビゲーション"
```

## 化粧品カテゴリページ

### ランキングセクション

```
region
  heading "人気商品ランキング"
  tablist
    tab "すべて" [href="#tab-ranking-panel-0100000000"]
    tab "スキンケア" [href="#tab-ranking-panel-0101000000"]
    tab "ベースメーク" [href="#tab-ranking-panel-0102000000"]
    tab "メークアップ" [href="#tab-ranking-panel-0103000000"]
    tab "ボディケア" [href="#tab-ranking-panel-0104000000"]
    tab "ヘアケア・育毛" [href="#tab-ranking-panel-0105000000"]
    tab "アロマ・フレグランス" [href="#tab-ranking-panel-0106000000"]
    tab "メンズ" [href="#tab-ranking-panel-0107000000"]
    tab "お悩みで探す" [href="#tab-ranking-panel-0108000000"]
  tabpanel
    link [href="/goods/{商品ID}.html"]  # 商品カード
```

### カテゴリナビゲーション

```
region
  heading "商品を探す"
  tablist
    tab "カテゴリーから探す" [href="#tab-2col-panel1"]
    tab "お悩みで探す" [href="#tab-2col-panel2-0108000000"]
  tabpanel
    heading "スキンケア"
    link "すべて見る" [href="/cosmetics/skincare/"]
    button "基礎化粧品"
    region → list → listitem  # サブカテゴリ
    button "シリーズ"
    region → list → listitem  # シリーズ一覧
```

### シリーズセクション

```
region
  heading "シリーズを探す"
  tablist
    tab "スキンケア" [href="#tab-series-panel1"]
    tab "メーク" [href="#tab-series-panel2"]
    tab "メークアップ" [href="#tab-series-panel3"]
    tab "ヘアケア・育毛" [href="#tab-series-panel4"]
    tab "メンズ" [href="#tab-series-panel5"]
  tabpanel
    heading "おすすめシリーズ"
    list → listitem → article
```

## 商品カード構造

### 一覧ページの商品カード

```
link [href="/goods/{商品ID}.html"]
  image "{商品名}"                    # alt属性に商品名
  generic "数量限定"                  # バッジ（複数あり得る）
  generic "キャンペーン"
  generic "送料無料"
  generic "新商品"
  generic "ネコポス"
  generic "コンビニ受取"
  generic "{商品名}"                  # テキストとしての商品名
  generic "3,300"                     # 通常価格
  generic "6,600"                     # セット価格（あれば）
  generic "5,940"                     # 販売価格
    generic "円（税込）"
  generic "18%off"                    # 割引率（あれば）
  generic "3月4日まで"                # 期限（あれば）
```

### バッジ一覧

| バッジ | 意味 |
|--------|------|
| `数量限定` | 数量限定商品 |
| `キャンペーン` | キャンペーン中 |
| `送料無料` | 送料無料 |
| `新商品` | 新商品 |
| `ネコポス` | ネコポス対応 |
| `コンビニ受取` | コンビニ受取対応 |
| `通販限定` | 通販限定商品 |

## 商品詳細ページ

### 基本情報

```
main
  textbox [type="hidden"] value="22872M"    # 商品ID
  navigation "breadcrumb"
    list
      listitem → link "HOME" [href="/"]
      listitem → generic "化粧品"
      listitem → generic "スキンケア"
      listitem → generic "基礎化粧品"
      listitem → generic "クレンジング"
  heading "{商品名}"
  generic "医薬部外品 300mL"                 # 規格
  button "総レビュー数 X 件のうち X／5の評価。レビューにジャンプ。"
  generic "化粧品部門"
  generic "{キャッチコピー}"
  button "お気に入りに追加する"
```

### 商品画像

```
generic "{商品名}"                           # 画像コンテナ
  # 内部にimg要素
generic "1/1"                                # 画像インジケーター
button → image "スライド1を表示"
```

### 購入フォーム

```
button "通常購入"                            # バリエーション選択
region
  form
    list
      listitem → generic "数量限定"          # バッジ
      listitem → generic "コンビニ受取"
    generic "3,300"
      generic "円（税込）"
    generic "ネットポイント"
    generic "165"                            # ポイント数
    label                                    # 数量ラベル
    combobox "1"                             # 数量選択
      option "1" (selected)
      option "2"
      ...
      option "30"
    generic "（商品番号：22872）"
    list
      listitem "通常サイズと比べて775円もお得！ 19%OFF相当"
    textbox [type="hidden"] value="22872"    # 商品番号
    button "カートに入れる"                   # または "在庫切れ"

button "2本セット"                           # 別バリエーション
region                                       # 同様の購入フォーム
```

### レビューセクション

```
region
  heading "レビュー"
  # Yotpo統合のレビューコンテンツ
```

## 検索結果ページ

### 構造

```
main
  navigation "breadcrumb"
    list
      listitem → link "HOME"
      listitem → generic "{検索結果}"
  heading "「{キーワード}」に関する検索結果"
  tablist
    tab "すべて"
    tab "商品"
    tab "コンテンツ"
  tabpanel
    list  # フィルター/ソート
  link [href="/goods/300M.html"]             # 商品カード（複数）
  link [href="/goods/23587M.html"]
  ...
  heading "おすすめコンテンツ"
  list → listitem
  region  # レコメンド商品
  complementary
    heading "商品を探す"
```

### 商品カード（検索結果）

```
link [href="/goods/300M.html"]
  image "DHC薬用ディープクレンジングオイル"
  generic "コンビニ受取"
  generic "DHC薬用ディープクレンジングオイル"
  generic "2,717"
  generic "2,037"
  generic "2,717"
    generic "円（税込）"
```

## JavaScript抽出パターン

### 商品一覧の取得

```javascript
// 商品リンクを全て取得
const productLinks = document.querySelectorAll('a[href*="/goods/"][href$=".html"]');

// 商品情報を抽出
const products = [...productLinks].map(link => {
  const img = link.querySelector('img');
  const texts = [...link.querySelectorAll('*')]
    .map(el => el.textContent.trim())
    .filter(t => t);

  // 価格を探す
  const priceMatch = texts.find(t => t.includes('円（税込）'));

  return {
    url: link.href,
    id: link.href.match(/\/goods\/(\w+)\.html/)?.[1],
    name: img?.alt || '',
    imageUrl: img?.src || '',
    price: priceMatch?.match(/(\d[\d,]+)円/)?.[1],
    badges: texts.filter(t =>
      ['キャンペーン', '送料無料', '数量限定', '新商品', 'ネコポス', 'コンビニ受取'].includes(t)
    )
  };
});
```

### カテゴリIDの取得

```javascript
// hidden inputから取得
const categoryId = document.querySelector('input[type="hidden"][value^="01"]')?.value;

// タブのhrefから取得
const tabs = document.querySelectorAll('a[href*="tab-ranking-panel-"]');
const categoryIds = [...tabs].map(tab => {
  const match = tab.href.match(/panel-(\d+)/);
  return { name: tab.textContent, id: match?.[1] };
});
```

### 購入フォームの操作

```javascript
// 数量変更
const qtySelect = document.querySelector('select');
if (qtySelect) {
  qtySelect.value = '3';
  qtySelect.dispatchEvent(new Event('change', { bubbles: true }));
}

// カートに追加
const cartBtn = [...document.querySelectorAll('button')]
  .find(btn => btn.textContent.includes('カートに入れる'));
if (cartBtn && !cartBtn.disabled) {
  cartBtn.click();
}

// 在庫切れチェック
const outOfStock = [...document.querySelectorAll('button')]
  .some(btn => btn.textContent.includes('在庫切れ'));
```

### パンくずリストの取得

```javascript
const breadcrumb = document.querySelector('nav[aria-label="breadcrumb"], [class*="breadcrumb"]');
const items = breadcrumb?.querySelectorAll('a, span');
const path = [...items].map(el => ({
  text: el.textContent.trim(),
  url: el.href || null
}));
```

## カテゴリID一覧

| カテゴリ | ID |
|---------|-----|
| 化粧品（すべて） | 0100000000 |
| スキンケア | 0101000000 |
| ベースメーク | 0102000000 |
| メークアップ | 0103000000 |
| ボディケア | 0104000000 |
| ヘアケア・育毛 | 0105000000 |
| アロマ・フレグランス | 0106000000 |
| メンズ | 0107000000 |
| お悩みで探す | 0108000000 |
