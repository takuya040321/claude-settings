---
name: browser-puppeteer
description: Puppeteerを使用したChrome/Chromium特化のブラウザ自動操作スキル。Node.js/TypeScript向け。ユーザーが「Puppeteerで自動化して」「Node.jsでChromeを操作して」「Puppeteerでスクレイピングして」などと依頼した場合にトリガー。
---

# Puppeteer ブラウザ自動操作

## クイックスタート

```typescript
import puppeteer from 'puppeteer';

const browser = await puppeteer.launch({ headless: true });
const page = await browser.newPage();
await page.goto('https://example.com');
await page.waitForNetworkIdle();
// 操作を実行
await browser.close();
```

## セットアップ

```bash
npm install puppeteer
# または軽量版（ブラウザなし）
npm install puppeteer-core
```

## タスク別パターン

### Webスクレイピング

```typescript
import puppeteer from 'puppeteer';

async function scrapeData(url: string): Promise<object[]> {
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();
  await page.goto(url);
  await page.waitForNetworkIdle();

  const data = await page.$$eval('.item', (items) =>
    items.map((item) => ({
      title: item.querySelector('.title')?.textContent,
      price: item.querySelector('.price')?.textContent,
    }))
  );

  await browser.close();
  return data;
}
```

### フォーム入力

```typescript
async function fillForm(page: puppeteer.Page) {
  await page.type('input[name="username"]', 'user@example.com');
  await page.type('input[name="password"]', 'password123');
  await page.select('select[name="country"]', 'JP');
  await page.click('input[name="agree"]');
  await page.click('button[type="submit"]');
  await page.waitForNavigation();
}
```

### ログイン処理

```typescript
async function login(url: string, email: string, password: string) {
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  await page.goto(url);
  await page.waitForSelector('input[name="email"]');

  await page.type('input[name="email"]', email);
  await page.type('input[name="password"]', password);
  await page.click('button[type="submit"]');

  await page.waitForNavigation();

  // クッキーを保存
  const cookies = await page.cookies();

  await browser.close();
  return cookies;
}
```

### スクリーンショット・PDF

```typescript
// フルページスクリーンショット
await page.screenshot({ path: 'screenshot.png', fullPage: true });

// 特定要素
const element = await page.$('.target');
await element?.screenshot({ path: 'element.png' });

// PDF出力
await page.pdf({
  path: 'page.pdf',
  format: 'A4',
  printBackground: true,
});
```

### ページ評価（evaluate）

```typescript
// ページ内でJavaScript実行
const title = await page.evaluate(() => document.title);

// データ抽出
const data = await page.evaluate(() => {
  const items = document.querySelectorAll('.item');
  return Array.from(items).map((item) => ({
    text: item.textContent,
    href: item.getAttribute('href'),
  }));
});

// 引数を渡す
const result = await page.evaluate(
  (selector, attr) => {
    const el = document.querySelector(selector);
    return el?.getAttribute(attr);
  },
  '.link',
  'href'
);
```

## セレクター

```typescript
// 単一要素
const element = await page.$('div.container');

// 複数要素
const elements = await page.$$('.item');

// XPath
const [el] = await page.$x('//div[@class="target"]');

// テキストで検索（XPath使用）
const [button] = await page.$x('//button[contains(text(), "送信")]');

// 待機付き選択
await page.waitForSelector('.loaded');
const loaded = await page.$('.loaded');
```

## 待機

```typescript
// セレクター待機
await page.waitForSelector('.element');

// ネットワークアイドル
await page.waitForNetworkIdle();

// ナビゲーション待機
await page.waitForNavigation();

// 関数が真を返すまで待機
await page.waitForFunction(
  () => document.querySelector('.spinner') === null
);

// タイムアウト設定
await page.waitForSelector('.item', { timeout: 10000 });

// 固定待機（非推奨だが必要な場合）
await page.waitForTimeout(1000);
```

## イベント処理

```typescript
// 新しいページ（ポップアップ）を待機
const [newPage] = await Promise.all([
  new Promise<puppeteer.Page>((resolve) =>
    browser.once('targetcreated', async (target) => {
      const page = await target.page();
      if (page) resolve(page);
    })
  ),
  page.click('a[target="_blank"]'),
]);

// ダイアログ処理
page.on('dialog', async (dialog) => {
  console.log(dialog.message());
  await dialog.accept();
});

// リクエストインターセプト
await page.setRequestInterception(true);
page.on('request', (request) => {
  if (request.resourceType() === 'image') {
    request.abort();
  } else {
    request.continue();
  }
});
```

## デバッグ

```typescript
// ヘッドフルモードで実行
const browser = await puppeteer.launch({
  headless: false,
  slowMo: 500, // 操作を遅延
});

// DevTools自動起動
const browser = await puppeteer.launch({
  headless: false,
  devtools: true,
});

// コンソールログをキャプチャ
page.on('console', (msg) => console.log('PAGE LOG:', msg.text()));

// エラーをキャプチャ
page.on('pageerror', (error) => console.log('PAGE ERROR:', error.message));
```

## ベストプラクティス

- `waitForNetworkIdle()`でページ読み込み完了を待機
- `evaluate()`内でDOM操作を行う（効率的）
- リクエストインターセプトで不要なリソースをブロック
- エラー時はスクリーンショットを保存
- タイムアウトを明示的に設定
- 本番環境では`headless: true`を使用
