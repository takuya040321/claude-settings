---
name: basic-design
description: ソフトウェア開発の基本設計書を作成するスキル。画面設計、データ設計（ER図・テーブル定義）、API設計、アーキテクチャ設計を網羅的に出力。ユーザーが「基本設計書を作成して」「画面設計をして」「ER図を作成して」「API設計をして」「システム構成を設計して」などと依頼した場合にトリガー。
---

# 基本設計スキル

## 概要

要件定義に基づき、ソフトウェアの基本設計書を作成する。

**作成可能な成果物:**
- 画面設計（画面一覧、画面遷移図、ワイヤーフレーム）
- データ設計（ER図、テーブル定義書）
- API設計（エンドポイント一覧、リクエスト/レスポンス仕様）
- アーキテクチャ設計（システム構成図、コンポーネント図）

## ワークフロー

```
[入力確認] → [設計方針決定] → [各設計作成] → [整合性確認] → [出力]
```

### Phase 1: 入力確認

以下の情報を確認・収集する：

| 必須項目 | 説明 |
|---------|------|
| 要件定義 | 機能要件・非機能要件の一覧 |
| 技術スタック | フロントエンド、バックエンド、DB |
| 対象範囲 | 作成する設計書の種類 |

要件定義が不明確な場合、`requirements-definition`スキルの使用を提案する。

### Phase 2: 設計方針決定

システム特性に応じた設計方針を決定する。

**アーキテクチャパターン:**
- モノリシック / マイクロサービス
- MVC / クリーンアーキテクチャ / レイヤードアーキテクチャ
- REST API / GraphQL

**命名規則:**
- テーブル名: snake_case（複数形）
- カラム名: snake_case
- API: RESTful命名規則
- 画面ID: SCRN-XXX形式

### Phase 3: 各設計の作成

対象範囲に応じて以下を作成する。詳細は`references/`を参照。

| 設計種別 | リファレンス |
|---------|-------------|
| 画面設計 | `references/screen-design.md` |
| データ設計 | `references/data-design.md` |
| API設計 | `references/api-design.md` |
| アーキテクチャ設計 | `references/architecture-design.md` |

### Phase 4: 整合性確認

設計間の整合性を確認する：

- 画面項目とAPI項目の対応
- APIレスポンスとテーブル項目の対応
- 画面遷移とAPIエンドポイントの対応

---

## 出力フォーマット

### ファイル構成

Mermaid記法の図は専用ファイルに分離し、基本設計書からリンクで参照する。

```
docs/
├── basic-design.md           # 基本設計書（本体）
└── diagrams/                  # 図専用ディレクトリ
    ├── system-architecture.md # システム構成図
    ├── er-diagram.md          # ER図
    ├── screen-flow.md         # 画面遷移図
    ├── sequence-login.md      # シーケンス図（ログイン）
    ├── sequence-order.md      # シーケンス図（注文処理）
    └── ...                    # その他の図
```

### 基本設計書の構成

```markdown
# 基本設計書: {システム名}

## 1. 設計概要
- システム概要
- 設計方針
- 技術スタック
- 前提条件・制約

## 2. アーキテクチャ設計
- [システム構成図](./diagrams/system-architecture.md)
- [コンポーネント図](./diagrams/component-diagram.md)
- 技術選定理由

## 3. 画面設計
- 画面一覧
- [画面遷移図](./diagrams/screen-flow.md)
- 画面レイアウト（主要画面）

## 4. データ設計
- [ER図](./diagrams/er-diagram.md)
- テーブル定義書
- マスターデータ一覧

## 5. API設計
- API一覧
- エンドポイント詳細
- 共通仕様（認証、エラー形式等）
- [ログイン処理シーケンス図](./diagrams/sequence-login.md)

## 6. 非機能設計
- セキュリティ設計
- パフォーマンス設計
- 可用性設計

## 付録
- 用語集
- 参考資料
```

### 図ファイルのフォーマット

各図ファイルは以下の形式で作成する：

```markdown
# {図の名前}

## 概要

{この図が表すものの簡潔な説明}

## 図

\`\`\`mermaid
{Mermaid記法の図}
\`\`\`

## 補足説明

{必要に応じて図の補足説明を記載}

---

[← 基本設計書に戻る](../basic-design.md)
```

---

## Mermaid記法ガイド

設計図はMermaid記法で出力する。

### ER図

**ファイル名**: `diagrams/er-diagram.md`

```markdown
# ER図

## 概要

システムのデータモデルを表すER図。

## 図

\`\`\`mermaid
erDiagram
    users ||--o{ orders : "places"
    orders ||--|{ order_items : "contains"
    products ||--o{ order_items : "included_in"

    users {
        int id PK
        string email UK
        string name
        timestamp created_at
    }
    orders {
        int id PK
        int user_id FK
        string status
        decimal total_amount
    }
\`\`\`

## 補足説明

- `users`: ユーザー情報を管理
- `orders`: 注文情報を管理
- `order_items`: 注文明細を管理

---

[← 基本設計書に戻る](../basic-design.md)
```

### 画面遷移図

**ファイル名**: `diagrams/screen-flow.md`

```markdown
# 画面遷移図

## 概要

システムの画面遷移を表す図。

## 図

\`\`\`mermaid
stateDiagram-v2
    [*] --> ログイン画面
    ログイン画面 --> ダッシュボード: ログイン成功
    ログイン画面 --> パスワードリセット: リセット要求
    ダッシュボード --> 一覧画面: メニュー選択
    一覧画面 --> 詳細画面: 項目選択
    詳細画面 --> 編集画面: 編集ボタン
\`\`\`

---

[← 基本設計書に戻る](../basic-design.md)
```

### システム構成図

**ファイル名**: `diagrams/system-architecture.md`

```markdown
# システム構成図

## 概要

システム全体のアーキテクチャを表す図。

## 図

\`\`\`mermaid
graph TB
    subgraph Client
        Browser[ブラウザ]
        Mobile[モバイルアプリ]
    end

    subgraph Frontend
        CDN[CDN]
        SPA[SPA/Next.js]
    end

    subgraph Backend
        API[API Server]
        Worker[Worker]
    end

    subgraph Data
        DB[(PostgreSQL)]
        Cache[(Redis)]
        Storage[S3]
    end

    Browser --> CDN
    Mobile --> API
    CDN --> SPA
    SPA --> API
    API --> DB
    API --> Cache
    Worker --> DB
    API --> Storage
\`\`\`

---

[← 基本設計書に戻る](../basic-design.md)
```

### シーケンス図

**ファイル名**: `diagrams/sequence-login.md`

```markdown
# ログイン処理シーケンス図

## 概要

ユーザーログイン処理の流れを表すシーケンス図。

## 図

\`\`\`mermaid
sequenceDiagram
    actor User
    participant Frontend
    participant API
    participant DB

    User->>Frontend: ログインフォーム送信
    Frontend->>API: POST /auth/login
    API->>DB: ユーザー検証
    DB-->>API: ユーザー情報
    API-->>Frontend: JWT Token
    Frontend-->>User: ダッシュボード表示
\`\`\`

---

[← 基本設計書に戻る](../basic-design.md)
```

### クラス図

**ファイル名**: `diagrams/class-diagram.md`

```markdown
# クラス図

## 概要

システムの主要クラス構造を表す図。

## 図

\`\`\`mermaid
classDiagram
    class User {
        +int id
        +string email
        +string name
        +create()
        +update()
        +delete()
    }
    class Order {
        +int id
        +int userId
        +string status
        +decimal totalAmount
        +place()
        +cancel()
    }
    class OrderItem {
        +int id
        +int orderId
        +int productId
        +int quantity
    }

    User "1" --> "*" Order : places
    Order "1" --> "*" OrderItem : contains
\`\`\`

---

[← 基本設計書に戻る](../basic-design.md)
```

---

## 図ファイルの命名規則

| 図の種類 | ファイル名パターン | 例 |
|---------|-------------------|-----|
| システム構成図 | `system-architecture.md` | - |
| コンポーネント図 | `component-diagram.md` | - |
| ER図 | `er-diagram.md` | - |
| 画面遷移図 | `screen-flow.md` | - |
| シーケンス図 | `sequence-{処理名}.md` | `sequence-login.md`, `sequence-order.md` |
| クラス図 | `class-diagram.md` または `class-{モジュール名}.md` | `class-user.md` |
| フローチャート | `flow-{処理名}.md` | `flow-checkout.md` |

---

## リファレンス

- `references/screen-design.md` - 画面設計の詳細ガイド
- `references/data-design.md` - データ設計の詳細ガイド
- `references/api-design.md` - API設計の詳細ガイド
- `references/architecture-design.md` - アーキテクチャ設計の詳細ガイド
