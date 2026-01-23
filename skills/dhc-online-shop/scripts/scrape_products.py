#!/usr/bin/env python3
"""DHC公式オンラインショップ 化粧品カテゴリ スクレイピングスクリプト

Usage:
    python scrape_products.py --search "クレンジング" --pages 3
    python scrape_products.py --category skincare --pages 5
    python scrape_products.py --subcategory cleansing --pages 2
    python scrape_products.py --product-url "https://www.dhc.co.jp/goods/22872M.html"
"""

import argparse
import json
import re
import time
from dataclasses import asdict, dataclass
from typing import Any
from urllib.parse import urlencode, urljoin

import requests
from bs4 import BeautifulSoup

BASE_URL = "https://www.dhc.co.jp"

# 化粧品メインカテゴリ
COSMETICS_CATEGORIES = {
    "cosmetics": "/cosmetics/",
    "skincare": "/cosmetics/skincare/",
    "base-makeup": "/cosmetics/base-makeup/",
    "makeup": "/cosmetics/makeup/",
    "body-care": "/cosmetics/body-care/",
    "hair-care": "/cosmetics/hair-care/",
}

# スキンケアサブカテゴリ
SKINCARE_SUBCATEGORIES = {
    "cleansing": "/cosmetics/skincare/basic-skincare/cleansing/",
    "facial-cleanser": "/cosmetics/skincare/basic-skincare/facial-cleanser/",
    "lotion": "/cosmetics/skincare/basic-skincare/lotion-and-mist/",
    "milk-gel": "/cosmetics/skincare/basic-skincare/milk-and-gel/",
    "cream-oil": "/cosmetics/skincare/basic-skincare/creams-and-oils/",
    "serum": "/cosmetics/skincare/basic-skincare/serum/",
    "daytime-serum": "/cosmetics/skincare/basic-skincare/daytime-serum/",
    "facial-pack": "/cosmetics/skincare/basic-skincare/facial-pack/",
    "lip-care": "/cosmetics/skincare/basic-skincare/lip-care/",
}

# ベースメークサブカテゴリ
BASE_MAKEUP_SUBCATEGORIES = {
    "makeup-base": "/cosmetics/base-makeup/base-makeup-lineup/makeup-base/",
    "concealer": "/cosmetics/base-makeup/base-makeup-lineup/concealer/",
    "foundation": "/cosmetics/base-makeup/base-makeup-lineup/foundation/",
    "face-powder": "/cosmetics/base-makeup/base-makeup-lineup/face-powder/",
    "accessories": "/cosmetics/base-makeup/base-makeup-lineup/base-makeup-accessories/",
}

# メークアップサブカテゴリ
MAKEUP_SUBCATEGORIES = {
    "eye-makeup": "/cosmetics/makeup/eye-makeup/",
    "lip-makeup": "/cosmetics/makeup/lip-makeup/",
    "nail": "/cosmetics/makeup/nail/",
}

# 全サブカテゴリ
ALL_SUBCATEGORIES = {
    **SKINCARE_SUBCATEGORIES,
    **BASE_MAKEUP_SUBCATEGORIES,
    **MAKEUP_SUBCATEGORIES,
}

# カテゴリID
CATEGORY_IDS = {
    "cosmetics": "0100000000",
    "skincare": "0101000000",
    "base-makeup": "0102000000",
    "makeup": "0103000000",
    "body-care": "0104000000",
    "hair-care": "0105000000",
}

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "ja,en-US;q=0.9,en;q=0.8",
}


@dataclass
class CosmeticsProduct:
    """化粧品商品データ"""

    product_id: str
    name: str
    url: str
    price: int | None = None
    price_tax_included: int | None = None
    campaign_price: int | None = None
    discount_rate: str | None = None
    image_url: str | None = None
    description: str | None = None
    ingredients: str | None = None
    category: str | None = None
    subcategory: str | None = None
    badges: list[str] | None = None


def fetch_page(url: str, delay: float = 1.0) -> BeautifulSoup:
    """ページを取得してBeautifulSoupオブジェクトを返す"""
    time.sleep(delay)
    response = requests.get(url, headers=HEADERS, timeout=30)
    response.raise_for_status()
    return BeautifulSoup(response.text, "html.parser")


def extract_product_id(url: str) -> str | None:
    """URLから商品IDを抽出"""
    match = re.search(r"/goods/(\w+)\.html", url)
    return match.group(1) if match else None


def extract_price(text: str) -> int | None:
    """テキストから価格を抽出"""
    match = re.search(r"([\d,]+)円", text)
    if match:
        return int(match.group(1).replace(",", ""))
    return None


def extract_tax_included_price(text: str) -> int | None:
    """テキストから税込価格を抽出"""
    match = re.search(r"([\d,]+)円（税込）", text)
    if match:
        return int(match.group(1).replace(",", ""))
    return None


def extract_discount_rate(text: str) -> str | None:
    """テキストから割引率を抽出"""
    match = re.search(r"(\d+)%オフ", text)
    return f"{match.group(1)}%" if match else None


def extract_badges(soup: BeautifulSoup) -> list[str]:
    """商品のバッジ（キャンペーン、送料無料等）を抽出"""
    badges = []
    badge_keywords = ["キャンペーン", "送料無料", "新商品", "数量限定", "通販限定", "ネコポス", "コンビニ受取"]
    text = soup.get_text()
    for keyword in badge_keywords:
        if keyword in text:
            badges.append(keyword)
    return badges


def search_cosmetics(query: str, page: int = 1, per_page: int = 20) -> list[CosmeticsProduct]:
    """化粧品カテゴリで検索"""
    start = (page - 1) * per_page
    params = {
        "q": query,
        "start": start,
        "sz": per_page,
        "prefn1": "txProductCategory",
        "prefv1": "化粧品",
    }
    url = f"{BASE_URL}/search?{urlencode(params)}"

    soup = fetch_page(url)
    products = []

    for link in soup.select('a[href*="/goods/"]'):
        href = link.get("href", "")
        if not href.endswith(".html"):
            continue

        product_id = extract_product_id(href)
        if not product_id:
            continue

        name = link.get_text(strip=True)
        if not name:
            continue

        full_url = urljoin(BASE_URL, href)

        img = link.find("img")
        image_url = img.get("src") if img else None

        products.append(
            CosmeticsProduct(
                product_id=product_id,
                name=name,
                url=full_url,
                image_url=image_url,
                category="化粧品",
            )
        )

    return products


def get_search_total_count(query: str) -> int:
    """検索結果の総件数を取得"""
    params = {"q": query, "prefn1": "txProductCategory", "prefv1": "化粧品"}
    url = f"{BASE_URL}/search?{urlencode(params)}"
    soup = fetch_page(url)
    text = soup.get_text()
    match = re.search(r"(\d+)件", text)
    return int(match.group(1)) if match else 0


def get_product_detail(url: str) -> CosmeticsProduct | None:
    """商品詳細ページから情報を取得"""
    soup = fetch_page(url)

    product_id = extract_product_id(url)
    if not product_id:
        return None

    # JSON-LDから構造化データを取得
    json_ld = soup.find("script", type="application/ld+json")
    structured_data: dict[str, Any] = {}
    if json_ld:
        try:
            structured_data = json.loads(json_ld.string)
        except json.JSONDecodeError:
            pass

    # 商品名
    name = structured_data.get("name", "")
    if not name:
        h1 = soup.find("h1")
        name = h1.get_text(strip=True) if h1 else ""

    # 価格
    text = soup.get_text()
    price_tax_included = extract_tax_included_price(text)
    discount_rate = extract_discount_rate(text)

    # キャンペーン価格
    campaign_price = None
    if discount_rate:
        # 割引後価格を探す
        prices = re.findall(r"([\d,]+)円（税込）", text)
        if len(prices) >= 2:
            campaign_price = int(prices[1].replace(",", ""))

    # 画像
    image_url = None
    img = soup.select_one('img[src*="dw/image/v2/BLLL_PRD"]')
    if img:
        image_url = img.get("src")

    # 説明
    description = structured_data.get("description", "")

    # 成分
    ingredients = None
    ingredients_section = soup.find(string=re.compile("成分・原材料"))
    if ingredients_section:
        parent = ingredients_section.find_parent()
        if parent:
            next_sibling = parent.find_next_sibling()
            if next_sibling:
                ingredients = next_sibling.get_text(strip=True)

    # バッジ
    badges = extract_badges(soup)

    # カテゴリ（パンくずから）
    category = None
    subcategory = None
    breadcrumb = soup.select(".breadcrumb a, [class*='breadcrumb'] a")
    if len(breadcrumb) >= 2:
        category = breadcrumb[1].get_text(strip=True)
    if len(breadcrumb) >= 3:
        subcategory = breadcrumb[2].get_text(strip=True)

    return CosmeticsProduct(
        product_id=product_id,
        name=name,
        url=url,
        price_tax_included=price_tax_included,
        campaign_price=campaign_price,
        discount_rate=discount_rate,
        image_url=image_url,
        description=description,
        ingredients=ingredients,
        category=category,
        subcategory=subcategory,
        badges=badges,
    )


def scrape_category(category: str, pages: int = 1) -> list[CosmeticsProduct]:
    """カテゴリページから商品一覧を取得"""
    if category not in COSMETICS_CATEGORIES:
        raise ValueError(f"Unknown category: {category}. Available: {list(COSMETICS_CATEGORIES.keys())}")

    url = f"{BASE_URL}{COSMETICS_CATEGORIES[category]}"
    soup = fetch_page(url)
    products = []

    for link in soup.select('a[href*="/goods/"]'):
        href = link.get("href", "")
        if not href.endswith(".html"):
            continue

        product_id = extract_product_id(href)
        if not product_id:
            continue

        name = link.get_text(strip=True)
        full_url = urljoin(BASE_URL, href)

        img = link.find("img")
        image_url = img.get("src") if img else None

        products.append(
            CosmeticsProduct(
                product_id=product_id,
                name=name,
                url=full_url,
                image_url=image_url,
                category=category,
            )
        )

    return products


def scrape_subcategory(subcategory: str, pages: int = 1) -> list[CosmeticsProduct]:
    """サブカテゴリページから商品一覧を取得"""
    if subcategory not in ALL_SUBCATEGORIES:
        raise ValueError(f"Unknown subcategory: {subcategory}. Available: {list(ALL_SUBCATEGORIES.keys())}")

    url = f"{BASE_URL}{ALL_SUBCATEGORIES[subcategory]}"
    soup = fetch_page(url)
    products = []

    for link in soup.select('a[href*="/goods/"]'):
        href = link.get("href", "")
        if not href.endswith(".html"):
            continue

        product_id = extract_product_id(href)
        if not product_id:
            continue

        name = link.get_text(strip=True)
        full_url = urljoin(BASE_URL, href)

        img = link.find("img")
        image_url = img.get("src") if img else None

        products.append(
            CosmeticsProduct(
                product_id=product_id,
                name=name,
                url=full_url,
                image_url=image_url,
                subcategory=subcategory,
            )
        )

    return products


def list_categories() -> None:
    """利用可能なカテゴリとサブカテゴリを表示"""
    print("=== 化粧品メインカテゴリ ===")
    for key, path in COSMETICS_CATEGORIES.items():
        print(f"  {key}: {BASE_URL}{path}")

    print("\n=== スキンケア サブカテゴリ ===")
    for key, path in SKINCARE_SUBCATEGORIES.items():
        print(f"  {key}: {BASE_URL}{path}")

    print("\n=== ベースメーク サブカテゴリ ===")
    for key, path in BASE_MAKEUP_SUBCATEGORIES.items():
        print(f"  {key}: {BASE_URL}{path}")

    print("\n=== メークアップ サブカテゴリ ===")
    for key, path in MAKEUP_SUBCATEGORIES.items():
        print(f"  {key}: {BASE_URL}{path}")


def main() -> None:
    parser = argparse.ArgumentParser(description="DHC化粧品スクレイパー")
    parser.add_argument("--search", type=str, help="検索キーワード（化粧品カテゴリ内）")
    parser.add_argument(
        "--category", type=str, choices=list(COSMETICS_CATEGORIES.keys()), help="化粧品カテゴリ"
    )
    parser.add_argument(
        "--subcategory", type=str, choices=list(ALL_SUBCATEGORIES.keys()), help="サブカテゴリ"
    )
    parser.add_argument("--product-url", type=str, help="商品詳細URL")
    parser.add_argument("--pages", type=int, default=1, help="取得ページ数")
    parser.add_argument("--output", type=str, help="出力ファイル（JSON）")
    parser.add_argument("--list-categories", action="store_true", help="利用可能なカテゴリを表示")

    args = parser.parse_args()

    if args.list_categories:
        list_categories()
        return

    products: list[CosmeticsProduct] = []

    if args.product_url:
        product = get_product_detail(args.product_url)
        if product:
            products = [product]

    elif args.search:
        for page in range(1, args.pages + 1):
            page_products = search_cosmetics(args.search, page=page)
            products.extend(page_products)
            print(f"Page {page}: {len(page_products)} products found")

    elif args.subcategory:
        products = scrape_subcategory(args.subcategory, pages=args.pages)
        print(f"Subcategory {args.subcategory}: {len(products)} products found")

    elif args.category:
        products = scrape_category(args.category, pages=args.pages)
        print(f"Category {args.category}: {len(products)} products found")

    else:
        parser.print_help()
        return

    # 出力
    result = [asdict(p) for p in products]

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print(f"Saved {len(products)} products to {args.output}")
    else:
        print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
