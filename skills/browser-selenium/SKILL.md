---
name: browser-selenium
description: Seleniumを使用したブラウザ自動操作スキル。Python/Java/多言語対応。レガシーシステムや特殊要件向け。ユーザーが「Seleniumで自動化して」「Seleniumでスクレイピングして」「Javaでブラウザ操作して」などと依頼した場合にトリガー。
---

# Selenium ブラウザ自動操作

## クイックスタート

### Python

```python
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

options = webdriver.ChromeOptions()
options.add_argument('--headless')
driver = webdriver.Chrome(options=options)

try:
    driver.get('https://example.com')
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, '.loaded'))
    )
    # 操作を実行
finally:
    driver.quit()
```

### Java

```java
import org.openqa.selenium.*;
import org.openqa.selenium.chrome.*;
import org.openqa.selenium.support.ui.*;

ChromeOptions options = new ChromeOptions();
options.addArguments("--headless");
WebDriver driver = new ChromeDriver(options);

try {
    driver.get("https://example.com");
    WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
    wait.until(ExpectedConditions.presenceOfElementLocated(By.cssSelector(".loaded")));
    // 操作を実行
} finally {
    driver.quit();
}
```

## セットアップ

### Python
```bash
pip install selenium webdriver-manager
```

### Java (Maven)
```xml
<dependency>
    <groupId>org.seleniumhq.selenium</groupId>
    <artifactId>selenium-java</artifactId>
    <version>4.18.0</version>
</dependency>
```

## タスク別パターン

### Webスクレイピング（Python）

```python
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def scrape_data(url: str) -> list[dict]:
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    driver = webdriver.Chrome(options=options)

    try:
        driver.get(url)
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, '.item'))
        )

        items = driver.find_elements(By.CSS_SELECTOR, '.item')
        data = []
        for item in items:
            data.append({
                'title': item.find_element(By.CSS_SELECTOR, '.title').text,
                'price': item.find_element(By.CSS_SELECTOR, '.price').text,
            })
        return data
    finally:
        driver.quit()
```

### フォーム入力（Python）

```python
from selenium.webdriver.support.ui import Select

def fill_form(driver):
    # テキスト入力
    driver.find_element(By.NAME, 'username').send_keys('user@example.com')
    driver.find_element(By.NAME, 'password').send_keys('password123')

    # ドロップダウン選択
    select = Select(driver.find_element(By.NAME, 'country'))
    select.select_by_value('JP')

    # チェックボックス
    checkbox = driver.find_element(By.NAME, 'agree')
    if not checkbox.is_selected():
        checkbox.click()

    # 送信
    driver.find_element(By.CSS_SELECTOR, 'button[type="submit"]').click()
```

### ログイン処理（Python）

```python
def login(url: str, email: str, password: str):
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    driver = webdriver.Chrome(options=options)

    try:
        driver.get(url)

        wait = WebDriverWait(driver, 10)
        email_input = wait.until(
            EC.presence_of_element_located((By.NAME, 'email'))
        )

        email_input.send_keys(email)
        driver.find_element(By.NAME, 'password').send_keys(password)
        driver.find_element(By.CSS_SELECTOR, 'button[type="submit"]').click()

        wait.until(EC.url_contains('/dashboard'))

        # クッキーを取得
        cookies = driver.get_cookies()
        return cookies
    finally:
        driver.quit()
```

### スクリーンショット（Python）

```python
# フルページ
driver.save_screenshot('screenshot.png')

# 特定要素
element = driver.find_element(By.CSS_SELECTOR, '.target')
element.screenshot('element.png')
```

## セレクター（Python）

```python
from selenium.webdriver.common.by import By

# ID
driver.find_element(By.ID, 'submit')

# クラス名
driver.find_element(By.CLASS_NAME, 'button')

# CSS セレクター
driver.find_element(By.CSS_SELECTOR, 'div.container > button')

# XPath
driver.find_element(By.XPATH, '//div[@class="item"]')

# 名前属性
driver.find_element(By.NAME, 'username')

# リンクテキスト
driver.find_element(By.LINK_TEXT, '詳細を見る')
driver.find_element(By.PARTIAL_LINK_TEXT, '詳細')

# タグ名
driver.find_element(By.TAG_NAME, 'input')

# 複数要素
driver.find_elements(By.CSS_SELECTOR, '.item')
```

## 待機（Python）

```python
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

wait = WebDriverWait(driver, 10)

# 要素の存在を待機
element = wait.until(
    EC.presence_of_element_located((By.CSS_SELECTOR, '.loaded'))
)

# 要素がクリック可能になるまで待機
button = wait.until(
    EC.element_to_be_clickable((By.CSS_SELECTOR, 'button'))
)

# 要素が表示されるまで待機
visible = wait.until(
    EC.visibility_of_element_located((By.CSS_SELECTOR, '.modal'))
)

# テキストを含むまで待機
wait.until(
    EC.text_to_be_present_in_element((By.CSS_SELECTOR, '.status'), '完了')
)

# URL変更を待機
wait.until(EC.url_contains('/success'))

# 要素が消えるまで待機
wait.until(
    EC.invisibility_of_element_located((By.CSS_SELECTOR, '.spinner'))
)
```

## アクション（Python）

```python
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys

actions = ActionChains(driver)

# ホバー
actions.move_to_element(element).perform()

# ダブルクリック
actions.double_click(element).perform()

# 右クリック
actions.context_click(element).perform()

# ドラッグ＆ドロップ
actions.drag_and_drop(source, target).perform()

# キーボード操作
actions.key_down(Keys.CONTROL).send_keys('a').key_up(Keys.CONTROL).perform()

# スクロール
driver.execute_script('window.scrollTo(0, document.body.scrollHeight)')
```

## JavaScript実行（Python）

```python
# スクリプト実行
driver.execute_script('return document.title')

# 要素を引数として渡す
element = driver.find_element(By.CSS_SELECTOR, '.target')
driver.execute_script('arguments[0].scrollIntoView()', element)

# 非同期スクリプト
driver.execute_async_script('''
    var callback = arguments[arguments.length - 1];
    setTimeout(function() { callback('done'); }, 1000);
''')
```

## デバッグ

```python
# ヘッドフルモードで実行
options = webdriver.ChromeOptions()
# options.add_argument('--headless')  # コメントアウト

# スローモーション（暗黙的待機）
driver.implicitly_wait(5)

# ページソースを取得
print(driver.page_source)

# 現在のURLを取得
print(driver.current_url)

# スクリーンショットでデバッグ
driver.save_screenshot('/tmp/debug.png')
```

## ベストプラクティス

- 明示的待機（`WebDriverWait`）を使用
- 暗黙的待機は最小限に
- `try-finally`でドライバーを確実に終了
- ヘッドレスモードで本番実行
- Page Object Patternでコードを整理
- WebDriver Managerで自動ドライバー管理
