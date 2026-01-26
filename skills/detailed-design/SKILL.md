---
name: detailed-design
description: |
  ソフトウェアシステムの詳細設計書をマークダウン形式で作成するスキル。クラス設計、シーケンス図、API設計、DB設計、エラー処理設計を含む包括的な詳細設計ドキュメントを生成。ユーザーが「詳細設計を作成して」「クラス設計を書いて」「API仕様を設計して」「シーケンス図を作成して」「DB設計をして」「エラー処理を設計して」などと依頼した場合にトリガー。
---

# 詳細設計スキル

ソフトウェアの詳細設計書をマークダウン形式で作成する。

## ワークフロー

1. **要件の確認** - 設計対象の機能・スコープを明確化
2. **全体構造の設計** - クラス構成とモジュール分割
3. **詳細設計の作成** - 各セクションを順番に設計
4. **整合性の確認** - セクション間の整合性をチェック

## 出力構成

詳細設計書は以下のセクションで構成：

```markdown
# [機能名] 詳細設計書

## 1. 概要
## 2. クラス設計
## 3. シーケンス図
## 4. API設計
## 5. データベース設計
## 6. エラー処理設計
## 7. 非機能要件対応
```

## 各セクションの記述ガイド

### 1. 概要

```markdown
## 1. 概要

### 1.1 目的
[この機能が解決する課題・提供する価値]

### 1.2 スコープ
- 対象: [設計対象の範囲]
- 対象外: [設計対象外の範囲]

### 1.3 前提条件
- [前提条件1]
- [前提条件2]

### 1.4 用語定義
| 用語 | 定義 |
|------|------|
| XXX | YYY |
```

### 2. クラス設計

Mermaid記法でクラス図を記述し、各クラスの責務を明記。

```markdown
## 2. クラス設計

### 2.1 クラス図

\`\`\`mermaid
classDiagram
    class ClassName {
        -privateField: Type
        +publicField: Type
        +publicMethod(param: Type): ReturnType
        -privateMethod(): void
    }

    ClassName1 --> ClassName2 : 依存
    ClassName1 o-- ClassName3 : 集約
    ClassName1 *-- ClassName4 : コンポジション
    ClassName1 <|-- ClassName5 : 継承
    ClassName1 ..|> InterfaceName : 実装
\`\`\`

### 2.2 クラス詳細

#### ClassName

| 項目 | 内容 |
|------|------|
| 責務 | [このクラスの責任範囲] |
| 依存 | [依存するクラス・モジュール] |

**フィールド**

| 名前 | 型 | 説明 | 制約 |
|------|-----|------|------|
| fieldName | Type | 説明 | 必須/オプション、バリデーション |

**メソッド**

| 名前 | 引数 | 戻り値 | 説明 |
|------|------|--------|------|
| methodName | param: Type | ReturnType | 処理内容 |
```

### 3. シーケンス図

Mermaid記法でシーケンス図を記述。主要なユースケースごとに作成。

```markdown
## 3. シーケンス図

### 3.1 [ユースケース名]

\`\`\`mermaid
sequenceDiagram
    autonumber
    actor User
    participant Controller
    participant Service
    participant Repository
    participant DB

    User->>Controller: リクエスト
    activate Controller
    Controller->>Service: 処理依頼
    activate Service
    Service->>Repository: データ取得
    activate Repository
    Repository->>DB: クエリ実行
    DB-->>Repository: 結果
    deactivate Repository
    Repository-->>Service: Entity
    Service-->>Controller: DTO
    deactivate Service
    Controller-->>User: レスポンス
    deactivate Controller
\`\`\`

**処理フロー説明**

| # | 処理 | 説明 |
|---|------|------|
| 1 | リクエスト | [詳細説明] |
| 2 | 処理依頼 | [詳細説明] |
```

### 4. API設計

RESTful APIの場合の標準フォーマット。

```markdown
## 4. API設計

### 4.1 エンドポイント一覧

| メソッド | パス | 説明 |
|----------|------|------|
| GET | /api/v1/resources | リソース一覧取得 |
| POST | /api/v1/resources | リソース作成 |
| GET | /api/v1/resources/{id} | リソース詳細取得 |
| PUT | /api/v1/resources/{id} | リソース更新 |
| DELETE | /api/v1/resources/{id} | リソース削除 |

### 4.2 API詳細

#### POST /api/v1/resources

**概要**: リソースを新規作成する

**リクエスト**

| 項目 | 値 |
|------|-----|
| Content-Type | application/json |
| 認証 | Bearer Token |

**リクエストボディ**

\`\`\`json
{
  "name": "string",
  "description": "string",
  "status": "active" | "inactive"
}
\`\`\`

| フィールド | 型 | 必須 | 説明 | 制約 |
|------------|-----|------|------|------|
| name | string | ○ | リソース名 | 1-100文字 |
| description | string | - | 説明 | 最大500文字 |
| status | string | ○ | ステータス | "active" or "inactive" |

**レスポンス**

*成功時 (201 Created)*

\`\`\`json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "status": "active",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
\`\`\`

*エラー時*

| コード | 説明 |
|--------|------|
| 400 | バリデーションエラー |
| 401 | 認証エラー |
| 409 | 重複エラー |
| 500 | サーバーエラー |
```

### 5. データベース設計

```markdown
## 5. データベース設計

### 5.1 ER図

\`\`\`mermaid
erDiagram
    users ||--o{ orders : "has"
    orders ||--|{ order_items : "contains"
    products ||--o{ order_items : "included_in"

    users {
        uuid id PK
        string email UK
        string name
        timestamp created_at
        timestamp updated_at
    }

    orders {
        uuid id PK
        uuid user_id FK
        string status
        decimal total_amount
        timestamp created_at
    }
\`\`\`

### 5.2 テーブル定義

#### users テーブル

| カラム名 | 型 | NULL | デフォルト | 説明 |
|----------|-----|------|------------|------|
| id | UUID | NO | gen_random_uuid() | 主キー |
| email | VARCHAR(255) | NO | - | メールアドレス（UK） |
| name | VARCHAR(100) | NO | - | ユーザー名 |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | 作成日時 |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | 更新日時 |

**インデックス**

| 名前 | カラム | 種別 |
|------|--------|------|
| users_pkey | id | PRIMARY |
| users_email_key | email | UNIQUE |
| idx_users_created_at | created_at | INDEX |

### 5.3 マイグレーション

\`\`\`sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_created_at ON users(created_at);
\`\`\`
```

### 6. エラー処理設計

```markdown
## 6. エラー処理設計

### 6.1 エラー分類

| カテゴリ | HTTPコード | 説明 | 対処 |
|----------|------------|------|------|
| バリデーションエラー | 400 | 入力値不正 | エラー詳細を返却 |
| 認証エラー | 401 | 未認証 | ログイン画面へ誘導 |
| 認可エラー | 403 | 権限不足 | エラーメッセージ表示 |
| リソースなし | 404 | 対象不存在 | 適切なメッセージ表示 |
| 競合エラー | 409 | 重複・競合 | 競合内容を返却 |
| サーバーエラー | 500 | 内部エラー | ログ出力、汎用メッセージ |

### 6.2 エラーレスポンス形式

\`\`\`json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力内容に誤りがあります",
    "details": [
      {
        "field": "email",
        "message": "有効なメールアドレスを入力してください"
      }
    ]
  }
}
\`\`\`

### 6.3 例外クラス設計

\`\`\`mermaid
classDiagram
    class ApplicationException {
        +code: string
        +message: string
        +statusCode: number
    }

    ApplicationException <|-- ValidationException
    ApplicationException <|-- AuthenticationException
    ApplicationException <|-- AuthorizationException
    ApplicationException <|-- NotFoundException
    ApplicationException <|-- ConflictException
\`\`\`
```

### 7. 非機能要件対応

```markdown
## 7. 非機能要件対応

### 7.1 パフォーマンス

| 項目 | 目標値 | 対策 |
|------|--------|------|
| レスポンスタイム | 200ms以下 | インデックス最適化、キャッシュ |
| スループット | 1000req/s | コネクションプール、非同期処理 |

### 7.2 セキュリティ

| 脅威 | 対策 |
|------|------|
| SQLインジェクション | プリペアドステートメント使用 |
| XSS | 出力エスケープ、CSP設定 |
| CSRF | CSRFトークン検証 |

### 7.3 ログ設計

| レベル | 用途 | 出力先 |
|--------|------|--------|
| ERROR | 例外発生時 | ファイル、アラート |
| WARN | 警告事象 | ファイル |
| INFO | 処理開始/終了 | ファイル |
| DEBUG | デバッグ情報 | 開発時のみ |
```

## 設計時の注意事項

1. **一貫性** - 命名規則、フォーマットを統一
2. **トレーサビリティ** - 要件との対応を明確に
3. **実装可能性** - 曖昧さを排除し実装者が迷わない記述
4. **保守性** - 変更しやすい設計を心がける

## 補足資料

- Mermaid記法の詳細：[references/mermaid-syntax.md](references/mermaid-syntax.md)
