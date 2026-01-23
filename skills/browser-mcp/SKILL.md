---
name: browser-mcp
description: Claude in Chrome MCPを使用したインタラクティブなブラウザ操作スキル。Claude Code内で直接ブラウザを操作。ユーザーが「このページを操作して」「ブラウザで確認して」「Webページをスクリーンショットして」「フォームに入力して」などと依頼した場合にトリガー。
---

# Claude in Chrome MCP ブラウザ操作

## 概要

Claude in Chrome MCPは、Claude Code内でブラウザを直接操作するためのツール群。スクリプト不要でインタラクティブにWebページを操作可能。

## 基本ワークフロー

```
1. tabs_context_mcp でタブ情報を取得
2. tabs_create_mcp で新規タブを作成（または既存タブを使用）
3. navigate でURLに移動
4. read_page / find で要素を特定
5. computer / form_input でアクション実行
6. computer (screenshot) で結果を確認
```

## 利用可能なツール

### タブ管理
| ツール | 用途 |
|--------|------|
| `tabs_context_mcp` | タブ情報取得（最初に必ず実行） |
| `tabs_create_mcp` | 新規タブ作成 |
| `navigate` | URL移動、戻る/進む |

### ページ読み取り
| ツール | 用途 |
|--------|------|
| `read_page` | アクセシビリティツリー取得 |
| `find` | 自然言語で要素検索 |
| `get_page_text` | テキストコンテンツ抽出 |

### 操作
| ツール | 用途 |
|--------|------|
| `computer` | クリック、入力、スクロール等 |
| `form_input` | フォーム要素への入力 |
| `javascript_tool` | JavaScript実行 |

### デバッグ
| ツール | 用途 |
|--------|------|
| `read_console_messages` | コンソールログ取得 |
| `read_network_requests` | ネットワークリクエスト取得 |

## タスク別パターン

### Webページの閲覧・情報取得

```
1. tabs_context_mcp(createIfEmpty: true)
2. tabs_create_mcp() で新規タブ作成
3. navigate(url: "https://example.com", tabId: xxx)
4. computer(action: "screenshot", tabId: xxx) で確認
5. get_page_text(tabId: xxx) でテキスト抽出
```

### 要素のクリック

```
1. read_page(tabId: xxx, filter: "interactive") で要素一覧取得
2. find(query: "ログインボタン", tabId: xxx) で要素を検索
3. computer(action: "left_click", ref: "ref_xxx", tabId: xxx)
   または
   computer(action: "left_click", coordinate: [x, y], tabId: xxx)
```

### フォーム入力

```
1. read_page(tabId: xxx) でフォーム要素を確認
2. form_input(ref: "ref_xxx", value: "入力値", tabId: xxx)
3. computer(action: "left_click", ref: "ref_submit", tabId: xxx)
```

### スクロール

```
# 下にスクロール
computer(action: "scroll", scroll_direction: "down", coordinate: [x, y], tabId: xxx)

# 要素までスクロール
computer(action: "scroll_to", ref: "ref_xxx", tabId: xxx)
```

### スクリーンショット

```
# 全体スクリーンショット
computer(action: "screenshot", tabId: xxx)

# 特定領域を拡大
computer(action: "zoom", region: [x0, y0, x1, y1], tabId: xxx)
```

### JavaScript実行

```
javascript_tool(
  action: "javascript_exec",
  text: "document.querySelector('.target').textContent",
  tabId: xxx
)
```

## computerアクション一覧

| アクション | 説明 | 必須パラメータ |
|-----------|------|---------------|
| `left_click` | 左クリック | coordinate または ref |
| `right_click` | 右クリック | coordinate または ref |
| `double_click` | ダブルクリック | coordinate または ref |
| `triple_click` | トリプルクリック | coordinate または ref |
| `type` | テキスト入力 | text |
| `key` | キー押下 | text |
| `scroll` | スクロール | scroll_direction, coordinate |
| `scroll_to` | 要素までスクロール | ref |
| `screenshot` | スクリーンショット | - |
| `zoom` | 領域拡大 | region |
| `wait` | 待機 | duration |
| `hover` | ホバー | coordinate または ref |
| `left_click_drag` | ドラッグ | start_coordinate, coordinate |

## ベストプラクティス

### セッション開始時
- 必ず`tabs_context_mcp`を最初に実行
- 新しい会話では新規タブを作成

### 要素の特定
- `read_page`でアクセシビリティツリーを確認
- `find`で自然言語検索
- `ref`を使用してクリック（座標より安定）

### 待機
- `computer(action: "wait", duration: 2)`で待機
- ネットワークリクエスト完了を確認

### エラー時
- `computer(action: "screenshot")`で状態確認
- `read_console_messages`でエラー確認
- 2-3回失敗したらユーザーに確認

## 注意事項

- アラート/ダイアログが表示されるとブロックされる
- ログイン情報は入力しない（ユーザーに依頼）
- センシティブな操作は確認を取る
- robots.txtを尊重
