---
name: dhc-online-shop
description: DHC公式オンラインショップ（https://www.dhc.co.jp/）のHTML構造を熟知したスキル。商品検索・一覧取得、商品詳細取得、カート・購入操作のスクレイピングやブラウザ自動操作に使用。DHCサイトの(1)商品検索・カテゴリ一覧からのデータ取得、(2)商品詳細ページからの情報抽出、(3)カートへの追加・購入フローの自動化、(4)ページネーション遷移を行う場合にトリガー。
---

# DHC公式オンラインショップ - 化粧品特化

DHC公式オンラインショップの化粧品カテゴリに特化したHTML構造とブラウザ自動操作のリファレンス。

## 化粧品カテゴリ構造

### メインカテゴリ

| カテゴリ | URL | カテゴリID |
|---------|-----|-----------|
| 化粧品トップ | `/cosmetics/` | 0100000000 |
| スキンケア | `/cosmetics/skincare/` | 0101000000 |
| ベースメーク | `/cosmetics/base-makeup/` | 0102000000 |
| メークアップ | `/cosmetics/makeup/` | 0103000000 |
| ボディケア | `/cosmetics/body-care/` | 0104000000 |
| ヘアケア・育毛 | `/cosmetics/hair-care/` | 0105000000 |
| アロマ・フレグランス | `/cosmetics/aroma-fragrance/` | 0106000000 |
| メンズ | `/cosmetics/mens-care/` | 0107000000 |
| お悩みで探す | `/cosmetics/cosmetics-by-trouble/` | 0108000000 |

### スキンケア サブカテゴリ

| カテゴリ | URL |
|---------|-----|
| クレンジング | `/cosmetics/skincare/basic-skincare/cleansing/` |
| 洗顔料 | `/cosmetics/skincare/basic-skincare/facial-cleanser/` |
| 化粧水・ミスト | `/cosmetics/skincare/basic-skincare/lotion-and-mist/` |
| ミルク・ジェル | `/cosmetics/skincare/basic-skincare/milk-and-gel/` |
| クリーム・オイル | `/cosmetics/skincare/basic-skincare/creams-and-oils/` |
| 美容液 | `/cosmetics/skincare/basic-skincare/serum/` |
| 日中用美容液 | `/cosmetics/skincare/basic-skincare/daytime-serum/` |
| パック・マスク | `/cosmetics/skincare/basic-skincare/facial-pack/` |
| リップケア | `/cosmetics/skincare/basic-skincare/lip-care/` |

### ベースメーク サブカテゴリ

| カテゴリ | URL |
|---------|-----|
| 化粧下地 | `/cosmetics/base-makeup/base-makeup-lineup/makeup-base/` |
| コンシーラー | `/cosmetics/base-makeup/base-makeup-lineup/concealer/` |
| ファンデーション | `/cosmetics/base-makeup/base-makeup-lineup/foundation/` |
| フェースパウダー | `/cosmetics/base-makeup/base-makeup-lineup/face-powder/` |
| ベースメーク小物 | `/cosmetics/base-makeup/base-makeup-lineup/base-makeup-accessories/` |

### メークアップ サブカテゴリ

| カテゴリ | URL |
|---------|-----|
| アイメイク | `/cosmetics/makeup/eye-makeup/` |
| リップメイク | `/cosmetics/makeup/lip-makeup/` |
| ネイル | `/cosmetics/makeup/nail/` |

## 実際のDOM構造（2025年1月検証済み）

### ページ全体構造

```
banner          - ヘッダー（ナビゲーション、検索、ログイン）
main            - メインコンテンツ
  navigation "breadcrumb" - パンくずリスト
  heading       - ページタイトル
  tablist       - カテゴリタブ
  tabpanel      - 商品一覧
  region        - 各セクション
contentinfo     - フッター
```

### 商品カード構造

```
link [href="/goods/{商品ID}.html"]
  image "商品名"
  generic "バッジ"        # 数量限定, キャンペーン, 送料無料, 新商品, ネコポス, コンビニ受取
  generic "商品名"
  generic "通常価格"      # 例: "3,300"
  generic "セット価格"    # 例: "6,600" (あれば)
  generic "販売価格"      # 例: "5,940"
    generic "円（税込）"
  generic "割引率"        # 例: "18%off" (あれば)
  generic "期限"          # 例: "3月4日まで" (あれば)
```

### ランキングタブ構造

```
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
  link [href="/goods/{商品ID}.html"]  # 商品カード（上記構造）
```

### 商品詳細ページ構造

```
main
  textbox [type="hidden"] value="{商品ID}"   # 商品ID
  navigation "breadcrumb"                     # パンくずリスト
    list
      listitem → link "HOME"
      listitem → generic "化粧品"
      listitem → generic "スキンケア"
      ...
  heading "商品名"
  generic "医薬部外品 300mL"                  # 商品説明
  button "レビューにジャンプ"
  generic "化粧品部門"                        # 部門
  generic "説明文"
  button "お気に入りに追加する"
  button "直営店の在庫を見る"

  # 購入オプション
  button "通常購入"
  region                                      # 購入フォーム
    form
      list
        listitem → generic "数量限定"         # バッジ
        listitem → generic "コンビニ受取"
      generic "3,300"
        generic "円（税込）"
      generic "ネットポイント"
      generic "165"                           # ポイント数
      combobox "1"                            # 数量選択 (1-30)
      generic "（商品番号：22872）"
      button "カートに入れる" / "在庫切れ"

  button "2本セット"                          # バリエーション
  region                                      # 別バリエーションの購入フォーム

  region → heading "レビュー"
```

### 検索フォーム構造

```
search
  combobox [placeholder="キーワードまたは商品番号を入力"]
  button "Clear search keywords" [type="reset"]
  button "Submit search keywords" [type="submit"]
```

### 検索結果ページ構造

```
main
  navigation "breadcrumb"
  heading "「{キーワード}」に関する検索結果"
  tablist                                     # すべて/商品/コンテンツ
  tabpanel
    list                                      # フィルター結果
  link [href="/goods/{商品ID}.html"]          # 商品カード（複数）
  complementary
    heading "商品を探す"                      # サイドバー
```

## URL構造

### 基本URL

| ページ種別 | URL形式 |
|-----------|---------|
| 化粧品トップ | `https://www.dhc.co.jp/cosmetics/` |
| カテゴリ | `/cosmetics/{category}/` |
| 商品詳細 | `/goods/{商品ID}.html` |
| 検索 | `/search?q={キーワード}&prefn1=txProductCategory&prefv1=化粧品` |
| カート | `/cart/` |

### 商品ID形式

- 通常商品: `{数字}M` （例: `22872M`, `300M`）
- セット商品: `{数字}` （例: `64800`）
- 定期便商品: `5{数字}` （例: `522872`）

### 検索パラメータ

```
/search?q={query}&start={offset}&sz={perPage}&prefn1=txProductCategory&prefv1=化粧品
```

- `q`: 検索キーワード
- `start`: 開始位置（0ベース）
- `sz`: 1ページあたり件数（デフォルト20）
- `prefn1=txProductCategory&prefv1=化粧品`: 化粧品カテゴリフィルター

## ブラウザ自動操作（Claude in Chrome）

### 商品を検索

```javascript
// 検索フォームに入力
const searchInput = document.querySelector('input[placeholder*="キーワード"]');
searchInput.value = 'クレンジング';
searchInput.dispatchEvent(new Event('input', { bubbles: true }));

// 検索実行
const submitBtn = document.querySelector('button[type="submit"]');
submitBtn.click();
```

### カテゴリタブを切り替え

```javascript
// スキンケアタブをクリック
const skincareTab = document.querySelector('a[href="#tab-ranking-panel-0101000000"]');
skincareTab.click();
```

### 商品カードから情報を抽出

```javascript
// 全商品リンクを取得
const productLinks = document.querySelectorAll('a[href*="/goods/"][href$=".html"]');
const products = [...productLinks].map(link => {
  const name = link.querySelector('img')?.alt || '';
  const priceEl = [...link.querySelectorAll('*')].find(el =>
    el.textContent.includes('円（税込）')
  );
  return {
    url: link.href,
    id: link.href.match(/\/goods\/(\w+)\.html/)?.[1],
    name: name,
    price: priceEl?.parentElement?.textContent?.match(/(\d[\d,]+)円/)?.[1]
  };
});
```

### カートに追加

```javascript
// カートボタンをクリック
const cartBtn = document.querySelector('button:not([disabled])');
if (cartBtn && cartBtn.textContent.includes('カートに入れる')) {
  cartBtn.click();
}

// 数量を変更
const qtySelect = document.querySelector('select, input[type="number"]');
if (qtySelect) {
  qtySelect.value = '2';
  qtySelect.dispatchEvent(new Event('change', { bubbles: true }));
}
```

### ページネーション

```javascript
// 次へボタン
const nextBtn = [...document.querySelectorAll('a, button')]
  .find(el => el.textContent.includes('次へ'));
if (nextBtn) nextBtn.click();

// 特定ページへ
const page3 = [...document.querySelectorAll('a')]
  .find(el => el.textContent.trim() === '3');
if (page3) page3.click();
```

## 技術的特徴

- **プラットフォーム**: Demandware（Salesforce Commerce Cloud）
- **画像CDN**: `dw/image/v2/BLLL_PRD`
- **トラッキング**: Criteo統合
- **レビュー**: Yotpo統合
- **UI**: タブベースのカテゴリ切り替え、スライダー（Swiper）

## 注意事項

- 動的読み込みが多いため、ブラウザ自動化（Claude in Chrome）推奨
- レート制限に注意（適切な間隔を設ける）
- 在庫切れ商品は `button "在庫切れ"` で表示
- hidden input に商品IDやカテゴリIDが格納されている
