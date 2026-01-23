---
name: vt-cosmetics-scraping
description: VT Cosmetics公式オンラインショップ（https://vtcosmetics.jp/）のスクレイピングに特化したスキル。Python（Playwright）、Node.js/TypeScript（Playwright）、Google Apps Script（UrlFetchApp）によるデータ取得コードを提供。商品一覧取得、商品詳細取得、検索、ページネーション対応。ユーザーが「VTの商品をスクレイピングして」「Pythonでリードルショットのデータを取得して」「GASでVT Cosmeticsの商品を取得して」などと依頼した場合にトリガー。
---

# VT Cosmetics スクレイピングスキル

VT Cosmetics日本公式サイト（https://vtcosmetics.jp/）のスクレイピングコード集。

## 前提条件

### 重要な注意事項

- 利用規約を確認し、スクレイピングが許可されていることを確認
- 適切な間隔（1-2秒）を設けてリクエスト
- User-Agentを適切に設定
- robots.txtを確認

### サイト特性

- Cafe24プラットフォーム（韓国製EC）
- 動的読み込みが多い → Playwright推奨
- 一部韓国語UI（ページネーションボタン等）

## Python（Playwright）

### セットアップ

```bash
pip install playwright
playwright install chromium
```

### 商品一覧の取得

```python
from playwright.sync_api import sync_playwright
import time
import json


def get_product_list(cate_no: int, max_pages: int = 3) -> list[dict]:
    """カテゴリの商品一覧を取得"""
    products = []

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        for page_num in range(1, max_pages + 1):
            url = f"https://vtcosmetics.jp/product/list.html?cate_no={cate_no}&page={page_num}"
            page.goto(url)
            page.wait_for_load_state("networkidle")
            time.sleep(1)  # レート制限対策

            # 商品カードを取得
            items = page.query_selector_all("li[class*='item'], .prdList li")

            for item in items:
                try:
                    link = item.query_selector("a[href*='/product/']")
                    href = link.get_attribute("href") if link else ""

                    name_el = item.query_selector(".name, .prdName, a[href*='/product/'] span")
                    price_el = item.query_selector(".price, .prdPrice")
                    review_el = item.query_selector("[class*='review']")

                    # 商品番号を抽出
                    import re
                    product_no_match = re.search(r"product_no=(\d+)", href)
                    if not product_no_match:
                        product_no_match = re.search(r"/product/[^/]+/(\d+)", href)
                    product_no = product_no_match.group(1) if product_no_match else None

                    products.append({
                        "product_no": product_no,
                        "url": f"https://vtcosmetics.jp{href}" if href.startswith("/") else href,
                        "name": name_el.inner_text().strip() if name_el else "",
                        "price": price_el.inner_text().strip() if price_el else "",
                        "review_count": (
                            re.search(r"\d+", review_el.inner_text()).group()
                            if review_el else "0"
                        ),
                    })
                except Exception as e:
                    print(f"Error parsing item: {e}")
                    continue

            # 次のページがあるか確認
            next_btn = page.query_selector("a[href*='page=']:last-child, img[alt*='다음']")
            if not next_btn:
                break

        browser.close()

    return products


# 使用例: REEDLE Sカテゴリ（cate_no=199）
if __name__ == "__main__":
    products = get_product_list(199, max_pages=2)
    print(json.dumps(products, ensure_ascii=False, indent=2))
```

### 商品詳細の取得

```python
from playwright.sync_api import sync_playwright
import re


def get_product_detail(product_no: int) -> dict:
    """商品詳細を取得"""
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        url = f"https://vtcosmetics.jp/product/detail.html?product_no={product_no}"
        page.goto(url)
        page.wait_for_load_state("networkidle")

        # 商品名
        name = page.query_selector("h1, .headingArea h2")
        name = name.inner_text().strip() if name else ""

        # 価格
        price = page.query_selector(".price, #span_product_price_text")
        price = price.inner_text().strip() if price else ""

        # 内容量
        volume = ""
        volume_els = page.query_selector_all("td, .info li")
        for el in volume_els:
            text = el.inner_text()
            if "容量" in text:
                volume = text
                break

        # 成分
        ingredients = ""
        ingredient_els = page.query_selector_all("li, td")
        for el in ingredient_els:
            text = el.inner_text()
            if "成分" in text or len(text) > 100:  # 成分は長いテキストが多い
                ingredients = text
                break

        # 商品説明
        description = page.query_selector(".description, .prd_detail_basic")
        description = description.inner_text().strip() if description else ""

        # 画像URL
        images = []
        img_els = page.query_selector_all("img[src*='product']")
        for img in img_els:
            src = img.get_attribute("src")
            if src and "thumbnail" not in src.lower():
                images.append(src)

        browser.close()

        return {
            "product_no": product_no,
            "url": url,
            "name": name,
            "price": price,
            "volume": volume,
            "ingredients": ingredients,
            "description": description,
            "images": list(set(images))[:5],  # 重複除去、最大5枚
        }


# 使用例
if __name__ == "__main__":
    detail = get_product_detail(651)  # リードルショット100
    print(detail)
```

### 商品検索

```python
from playwright.sync_api import sync_playwright
import urllib.parse


def search_products(keyword: str, max_pages: int = 2) -> list[dict]:
    """キーワードで商品を検索"""
    products = []
    encoded_keyword = urllib.parse.quote(keyword)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        for page_num in range(1, max_pages + 1):
            url = f"https://vtcosmetics.jp/product/search.html?keyword={encoded_keyword}&page={page_num}"
            page.goto(url)
            page.wait_for_load_state("networkidle")

            items = page.query_selector_all("li[class*='item'], .prdList li")

            for item in items:
                try:
                    link = item.query_selector("a[href*='/product/']")
                    href = link.get_attribute("href") if link else ""
                    name_el = item.query_selector(".name, .prdName")
                    price_el = item.query_selector(".price")

                    products.append({
                        "url": f"https://vtcosmetics.jp{href}" if href.startswith("/") else href,
                        "name": name_el.inner_text().strip() if name_el else "",
                        "price": price_el.inner_text().strip() if price_el else "",
                    })
                except Exception:
                    continue

        browser.close()

    return products


# 使用例
if __name__ == "__main__":
    results = search_products("シカ")
    print(results)
```

## Node.js / TypeScript（Playwright）

### セットアップ

```bash
npm install playwright
npx playwright install chromium
```

### 商品一覧の取得

```typescript
import { chromium, Browser, Page } from 'playwright';

interface Product {
  productNo: string | null;
  url: string;
  name: string;
  price: string;
  reviewCount: string;
}

async function getProductList(cateNo: number, maxPages: number = 3): Promise<Product[]> {
  const products: Product[] = [];
  const browser: Browser = await chromium.launch({ headless: true });
  const page: Page = await browser.newPage();

  for (let pageNum = 1; pageNum <= maxPages; pageNum++) {
    const url = `https://vtcosmetics.jp/product/list.html?cate_no=${cateNo}&page=${pageNum}`;
    await page.goto(url);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000); // レート制限対策

    const items = await page.$$("li[class*='item'], .prdList li");

    for (const item of items) {
      try {
        const link = await item.$("a[href*='/product/']");
        const href = await link?.getAttribute('href') || '';

        const nameEl = await item.$('.name, .prdName');
        const priceEl = await item.$('.price');
        const reviewEl = await item.$("[class*='review']");

        // 商品番号を抽出
        const productNoMatch = href.match(/product_no=(\d+)/) || href.match(/\/product\/[^/]+\/(\d+)/);
        const productNo = productNoMatch ? productNoMatch[1] : null;

        const name = await nameEl?.innerText() || '';
        const price = await priceEl?.innerText() || '';
        const reviewText = await reviewEl?.innerText() || '0';
        const reviewCount = reviewText.match(/\d+/)?.[0] || '0';

        products.push({
          productNo,
          url: href.startsWith('/') ? `https://vtcosmetics.jp${href}` : href,
          name: name.trim(),
          price: price.trim(),
          reviewCount,
        });
      } catch (e) {
        console.error('Error parsing item:', e);
      }
    }

    // 次のページがあるか確認
    const nextBtn = await page.$("a[href*='page=']:last-child, img[alt*='다음']");
    if (!nextBtn) break;
  }

  await browser.close();
  return products;
}

// 使用例
(async () => {
  const products = await getProductList(199, 2); // REEDLE S
  console.log(JSON.stringify(products, null, 2));
})();
```

### 商品詳細の取得

```typescript
import { chromium, Browser, Page } from 'playwright';

interface ProductDetail {
  productNo: number;
  url: string;
  name: string;
  price: string;
  volume: string;
  ingredients: string;
  description: string;
  images: string[];
}

async function getProductDetail(productNo: number): Promise<ProductDetail> {
  const browser: Browser = await chromium.launch({ headless: true });
  const page: Page = await browser.newPage();

  const url = `https://vtcosmetics.jp/product/detail.html?product_no=${productNo}`;
  await page.goto(url);
  await page.waitForLoadState('networkidle');

  // 商品名
  const nameEl = await page.$('h1, .headingArea h2');
  const name = await nameEl?.innerText() || '';

  // 価格
  const priceEl = await page.$('.price, #span_product_price_text');
  const price = await priceEl?.innerText() || '';

  // 内容量
  let volume = '';
  const volumeEls = await page.$$('td, .info li');
  for (const el of volumeEls) {
    const text = await el.innerText();
    if (text.includes('容量')) {
      volume = text;
      break;
    }
  }

  // 成分
  let ingredients = '';
  const ingredientEls = await page.$$('li, td');
  for (const el of ingredientEls) {
    const text = await el.innerText();
    if (text.includes('成分') || text.length > 100) {
      ingredients = text;
      break;
    }
  }

  // 商品説明
  const descEl = await page.$('.description, .prd_detail_basic');
  const description = await descEl?.innerText() || '';

  // 画像URL
  const images: string[] = [];
  const imgEls = await page.$$("img[src*='product']");
  for (const img of imgEls) {
    const src = await img.getAttribute('src');
    if (src && !src.toLowerCase().includes('thumbnail')) {
      images.push(src);
    }
  }

  await browser.close();

  return {
    productNo,
    url,
    name: name.trim(),
    price: price.trim(),
    volume,
    ingredients,
    description: description.trim(),
    images: [...new Set(images)].slice(0, 5),
  };
}

// 使用例
(async () => {
  const detail = await getProductDetail(651);
  console.log(detail);
})();
```

## Google Apps Script（GAS）

### 注意事項

GASの`UrlFetchApp`ではJavaScriptレンダリングができないため、動的コンテンツの取得には限界がある。
静的HTMLから取得可能な情報のみ抽出可能。

### 商品検索

```javascript
/**
 * VT Cosmeticsで商品を検索
 * @param {string} keyword - 検索キーワード
 * @return {Array} 商品リスト
 */
function searchVTProducts(keyword) {
  const encodedKeyword = encodeURIComponent(keyword);
  const url = `https://vtcosmetics.jp/product/search.html?keyword=${encodedKeyword}`;

  const options = {
    method: 'get',
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      'Accept-Language': 'ja,en-US;q=0.9,en;q=0.8',
    },
    muteHttpExceptions: true,
  };

  try {
    const response = UrlFetchApp.fetch(url, options);
    const html = response.getContentText();

    // 簡易的なパース（動的コンテンツは取得不可）
    const products = [];

    // 商品リンクを抽出
    const linkPattern = /href="(\/product\/[^"]+)"/g;
    let match;
    while ((match = linkPattern.exec(html)) !== null) {
      const productUrl = 'https://vtcosmetics.jp' + match[1];
      if (!products.some(p => p.url === productUrl)) {
        products.push({
          url: productUrl,
        });
      }
    }

    return products;
  } catch (e) {
    console.error('Error fetching VT products:', e);
    return [];
  }
}

/**
 * スプレッドシートに結果を出力
 */
function exportVTSearchToSheet() {
  const keyword = 'リードルショット';
  const products = searchVTProducts(keyword);

  const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  sheet.clear();

  // ヘッダー
  sheet.appendRow(['URL']);

  // データ
  products.forEach(product => {
    sheet.appendRow([product.url]);
  });
}
```

### カテゴリ商品一覧の取得（限定的）

```javascript
/**
 * VT Cosmeticsのカテゴリから商品URLを取得
 * @param {number} cateNo - カテゴリ番号
 * @return {Array} 商品URLリスト
 */
function getVTCategoryProducts(cateNo) {
  const url = `https://vtcosmetics.jp/product/list.html?cate_no=${cateNo}`;

  const options = {
    method: 'get',
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    },
    muteHttpExceptions: true,
  };

  try {
    const response = UrlFetchApp.fetch(url, options);
    const html = response.getContentText();

    const products = [];
    const pattern = /\/product\/detail\.html\?product_no=(\d+)/g;
    let match;

    while ((match = pattern.exec(html)) !== null) {
      const productNo = match[1];
      const productUrl = `https://vtcosmetics.jp/product/detail.html?product_no=${productNo}`;

      if (!products.some(p => p.productNo === productNo)) {
        products.push({
          productNo: productNo,
          url: productUrl,
        });
      }
    }

    return products;
  } catch (e) {
    console.error('Error:', e);
    return [];
  }
}

/**
 * REEDLE Sカテゴリの商品をスプレッドシートに出力
 */
function exportReedleSProducts() {
  const products = getVTCategoryProducts(199);

  const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  sheet.clear();
  sheet.appendRow(['商品番号', 'URL']);

  products.forEach(product => {
    sheet.appendRow([product.productNo, product.url]);
  });
}
```

### 商品詳細の取得（基本情報のみ）

```javascript
/**
 * 商品詳細ページから基本情報を取得
 * @param {number} productNo - 商品番号
 * @return {Object} 商品情報
 */
function getVTProductDetail(productNo) {
  const url = `https://vtcosmetics.jp/product/detail.html?product_no=${productNo}`;

  const options = {
    method: 'get',
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    },
    muteHttpExceptions: true,
  };

  try {
    const response = UrlFetchApp.fetch(url, options);
    const html = response.getContentText();

    // タイトル抽出
    const titleMatch = html.match(/<title>([^<]+)<\/title>/);
    const title = titleMatch ? titleMatch[1].replace(' - VT COSMETICS', '').trim() : '';

    // 価格抽出（meta情報から）
    const priceMatch = html.match(/product:price:amount"\s*content="(\d+)"/);
    const price = priceMatch ? priceMatch[1] : '';

    // 画像URL抽出
    const imageMatch = html.match(/og:image"\s*content="([^"]+)"/);
    const imageUrl = imageMatch ? imageMatch[1] : '';

    return {
      productNo: productNo,
      url: url,
      name: title,
      price: price,
      imageUrl: imageUrl,
    };
  } catch (e) {
    console.error('Error:', e);
    return null;
  }
}

/**
 * 複数商品の詳細を取得してスプレッドシートに出力
 * @param {Array} productNos - 商品番号の配列
 */
function exportProductDetails(productNos) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  sheet.clear();
  sheet.appendRow(['商品番号', 'URL', '商品名', '価格', '画像URL']);

  productNos.forEach((productNo, index) => {
    // レート制限対策
    if (index > 0) {
      Utilities.sleep(1500);
    }

    const detail = getVTProductDetail(productNo);
    if (detail) {
      sheet.appendRow([
        detail.productNo,
        detail.url,
        detail.name,
        detail.price,
        detail.imageUrl,
      ]);
    }
  });
}
```

## カテゴリ番号一覧

| カテゴリ | cate_no |
|---------|---------|
| CICA | 51 |
| CICA VITAL | 100 |
| CICA RETI-A | 102 |
| CICA COLLAGEN | 208 |
| REEDLE S | 199 |
| PDRN+ | 254 |
| AZ CARE | 286 |

## 注意事項

- **動的コンテンツ**: GASでは動的に読み込まれるコンテンツは取得不可。Playwright推奨。
- **レート制限**: 1-2秒の間隔を設けてリクエスト
- **User-Agent**: 適切なUser-Agentを設定
- **利用規約**: スクレイピング前に利用規約を確認
- **韓国語UI**: ページネーションボタン等が韓国語（「다음」= 次）

## 関連スキル

- `vt-cosmetics` - 包括的なHTML構造・セレクタリファレンス
- `vt-cosmetics-browser` - Claude in Chrome MCPによるブラウザ自動操作
