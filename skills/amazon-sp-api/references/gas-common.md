# GAS共通設定

## スクリプトプロパティ

GASエディタ → プロジェクトの設定 → スクリプトプロパティに設定:

| プロパティ | 説明 |
|-----------|------|
| LWA_CLIENT_ID | Login with Amazon アプリID |
| LWA_CLIENT_SECRET | LWAクライアントシークレット |
| REFRESH_TOKEN | セラーのリフレッシュトークン |
| SELLER_ID | セラーID |

## 共通設定・ヘルパー関数

```javascript
/**
 * SP-API共通設定
 */
const SP_API_CONFIG = {
  endpoint: 'https://sellingpartnerapi-fe.amazon.com',
  marketplaceId: 'A1VC38T7YXB528',
  tokenUrl: 'https://api.amazon.com/auth/o2/token',
};

/**
 * アクセストークン取得（キャッシュ対応）
 */
function getAccessToken() {
  const cache = CacheService.getScriptCache();
  const cached = cache.get('sp_api_access_token');
  if (cached) return cached;

  const props = PropertiesService.getScriptProperties();
  const response = UrlFetchApp.fetch(SP_API_CONFIG.tokenUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    payload: {
      grant_type: 'refresh_token',
      refresh_token: props.getProperty('REFRESH_TOKEN'),
      client_id: props.getProperty('LWA_CLIENT_ID'),
      client_secret: props.getProperty('LWA_CLIENT_SECRET'),
    },
    muteHttpExceptions: true,
  });

  const result = JSON.parse(response.getContentText());
  if (result.error) throw new Error(`Token error: ${result.error_description}`);

  cache.put('sp_api_access_token', result.access_token, 55 * 60);
  return result.access_token;
}

/**
 * GETリクエスト
 */
function spApiGet(path, params = {}) {
  const accessToken = getAccessToken();
  const queryString = Object.entries(params)
    .filter(([_, v]) => v !== undefined && v !== null)
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
    .join('&');

  const url = `${SP_API_CONFIG.endpoint}${path}${queryString ? '?' + queryString : ''}`;

  const response = UrlFetchApp.fetch(url, {
    method: 'GET',
    headers: { 'x-amz-access-token': accessToken, 'Content-Type': 'application/json' },
    muteHttpExceptions: true,
  });

  return handleResponse(response);
}

/**
 * POST/PUT/PATCHリクエスト
 */
function spApiRequest(method, path, body = null, params = {}) {
  const accessToken = getAccessToken();
  const queryString = Object.entries(params)
    .filter(([_, v]) => v !== undefined && v !== null)
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
    .join('&');

  const url = `${SP_API_CONFIG.endpoint}${path}${queryString ? '?' + queryString : ''}`;

  const options = {
    method: method,
    headers: { 'x-amz-access-token': accessToken, 'Content-Type': 'application/json' },
    muteHttpExceptions: true,
  };

  if (body) options.payload = JSON.stringify(body);

  return handleResponse(UrlFetchApp.fetch(url, options));
}

/**
 * レスポンス処理
 */
function handleResponse(response) {
  const code = response.getResponseCode();
  const content = response.getContentText();

  if (code >= 200 && code < 300) {
    return content ? JSON.parse(content) : {};
  }

  let error;
  try { error = JSON.parse(content); } catch { error = { message: content }; }

  if (code === 429) throw new Error('Rate limit exceeded');
  throw new Error(`API Error ${code}: ${JSON.stringify(error)}`);
}

/**
 * リトライ付きAPIコール
 */
function callWithRetry(apiFunc, maxRetries = 3) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return apiFunc();
    } catch (e) {
      if (e.message.includes('Rate limit') && attempt < maxRetries - 1) {
        Utilities.sleep(Math.pow(2, attempt) * 1000);
      } else {
        throw e;
      }
    }
  }
}
```

## トリガー設定

```javascript
function setupTriggers() {
  ScriptApp.getProjectTriggers().forEach((t) => ScriptApp.deleteTrigger(t));
  ScriptApp.newTrigger('syncOrders').timeBased().everyHours(1).create();
  ScriptApp.newTrigger('syncInventory').timeBased().atHour(6).everyDays(1).create();
}
```

## GAS制限事項

| 制限 | 値 |
|------|-----|
| 実行時間 | 最大6分 |
| URLフェッチ | 100回/実行 |
| トリガー | 20個/プロジェクト |
