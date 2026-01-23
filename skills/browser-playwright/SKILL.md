---
name: browser-playwright
description: Playwrightを使用したブラウザ自動操作スキル。Python/Node.js両対応。Webスクレイピング、フォーム自動入力、E2Eテストに最適。ユーザーが「Playwrightで自動化して」「Pythonでスクレイピングして」「Node.jsでブラウザ操作して」などと依頼した場合にトリガー。
---

# Playwright ブラウザ自動操作

## クイックスタート

### Python

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto('https://example.com')
    page.wait_for_load_state('networkidle')
    # 操作を実行
    browser.close()
```

### Node.js/TypeScript

```typescript
import { chromium } from 'playwright';

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
await page.goto('https://example.com');
await page.waitForLoadState('networkidle');
// 操作を実行
await browser.close();
```

## セットアップ

### Python
```bash
pip install playwright
playwright install chromium
```

### Node.js
```bash
npm install playwright
npx playwright install chromium
```

## タスク別パターン

### Webスクレイピング

**Python**
```python
from playwright.sync_api import sync_playwright

def scrape_data(url: str) -> list[dict]:
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        page.goto(url)
        page.wait_for_load_state('networkidle')

        # 要素を取得
        items = page.locator('.item').all()
        data = []
        for item in items:
            data.append({
                'title': item.locator('.title').text_content(),
                'price': item.locator('.price').text_content(),
            })

        browser.close()
        return data
```

**Node.js**
```typescript
import { chromium, Page } from 'playwright';

async function scrapeData(url: string): Promise<object[]> {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  await page.goto(url);
  await page.waitForLoadState('networkidle');

  const items = await page.locator('.item').all();
  const data = [];
  for (const item of items) {
    data.push({
      title: await item.locator('.title').textContent(),
      price: await item.locator('.price').textContent(),
    });
  }

  await browser.close();
  return data;
}
```

### フォーム入力

**Python**
```python
def fill_form(page):
    page.fill('input[name="username"]', 'user@example.com')
    page.fill('input[name="password"]', 'password123')
    page.select_option('select[name="country"]', 'JP')
    page.check('input[name="agree"]')
    page.click('button[type="submit"]')
    page.wait_for_url('**/dashboard**')
```

**Node.js**
```typescript
async function fillForm(page: Page) {
  await page.fill('input[name="username"]', 'user@example.com');
  await page.fill('input[name="password"]', 'password123');
  await page.selectOption('select[name="country"]', 'JP');
  await page.check('input[name="agree"]');
  await page.click('button[type="submit"]');
  await page.waitForURL('**/dashboard**');
}
```

### E2Eテスト

**Python (pytest)**
```python
import pytest
from playwright.sync_api import Page

def test_login(page: Page):
    page.goto('https://example.com/login')
    page.fill('input[name="email"]', 'test@example.com')
    page.fill('input[name="password"]', 'password')
    page.click('button[type="submit"]')

    assert page.url == 'https://example.com/dashboard'
    assert page.locator('.welcome-message').is_visible()
```

**Node.js (Playwright Test)**
```typescript
import { test, expect } from '@playwright/test';

test('login flow', async ({ page }) => {
  await page.goto('https://example.com/login');
  await page.fill('input[name="email"]', 'test@example.com');
  await page.fill('input[name="password"]', 'password');
  await page.click('button[type="submit"]');

  await expect(page).toHaveURL('https://example.com/dashboard');
  await expect(page.locator('.welcome-message')).toBeVisible();
});
```

### スクリーンショット

**Python**
```python
# フルページ
page.screenshot(path='screenshot.png', full_page=True)

# 特定要素
page.locator('.target').screenshot(path='element.png')

# PDF出力
page.pdf(path='page.pdf', format='A4')
```

## セレクター

```python
# テキストで検索
page.locator('text=ログイン')
page.get_by_text('ログイン')

# ロールで検索
page.get_by_role('button', name='送信')
page.get_by_role('link', name='詳細')

# プレースホルダーで検索
page.get_by_placeholder('メールアドレス')

# ラベルで検索
page.get_by_label('パスワード')

# テストID
page.get_by_test_id('submit-button')

# CSS/XPath
page.locator('div.container > button')
page.locator('//div[@class="item"]')
```

## 待機

```python
# 要素の出現を待機
page.wait_for_selector('.loaded')

# ネットワークアイドル
page.wait_for_load_state('networkidle')

# URL変更を待機
page.wait_for_url('**/success**')

# 条件を待機
page.wait_for_function('document.querySelector(".spinner") === null')

# タイムアウト設定
page.wait_for_selector('.item', timeout=10000)
```

## デバッグ

```python
# ヘッドフルモードで実行
browser = p.chromium.launch(headless=False, slow_mo=500)

# デバッグモード
PWDEBUG=1 python script.py

# トレース記録
context.tracing.start(screenshots=True, snapshots=True)
# ... 操作
context.tracing.stop(path='trace.zip')
```

## ベストプラクティス

- `headless=True`を本番環境で使用
- 適切な待機を追加（`networkidle`、`wait_for_selector`）
- エラー時はスクリーンショットを保存
- コンテキストを使用してセッション分離
- タイムアウトを明示的に設定
