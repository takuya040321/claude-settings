---
name: er-diagram-mermaid
description: Mermaid erDiagram記法でER図をマークダウンに記述するスキル。データベース設計の可視化、既存DBのドキュメント化、テーブル関係の図示に使用。ユーザーが「ER図を作成して」「テーブル構造を図にして」「データベース設計を可視化して」「エンティティ関係図を書いて」などと依頼した場合にトリガー。
---

# ER図 Mermaid記法

## クイックスタート

```markdown
```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_ITEM : contains
    PRODUCT ||--o{ ORDER_ITEM : "ordered in"
```
```

## 記法リファレンス

### エンティティと属性

```mermaid
erDiagram
    ENTITY_NAME {
        type attribute_name PK "コメント"
        type attribute_name FK
        type attribute_name UK
        type attribute_name
    }
```

| キー | 意味 |
|------|------|
| PK | 主キー |
| FK | 外部キー |
| UK | ユニークキー |

### データ型

一般的な型表記：

| 型 | 用途 |
|----|------|
| int | 整数 |
| bigint | 大きな整数 |
| varchar | 可変長文字列 |
| text | 長文テキスト |
| boolean | 真偽値 |
| date | 日付 |
| datetime | 日時 |
| timestamp | タイムスタンプ |
| decimal | 小数 |
| json | JSON |
| uuid | UUID |

### リレーションシップ記法

```
||--||  1対1（両側必須）
||--o|  1対1（右側オプション）
|o--o|  1対1（両側オプション）
||--|{  1対多（多側必須）
||--o{  1対多（多側オプション）
|o--|{  1対多（1側オプション、多側必須）
|o--o{  1対多（両側オプション）
}|--|{  多対多（両側必須）
}o--o{  多対多（両側オプション）
```

**記号の意味：**
- `||` : 1（必須）
- `|o` : 0または1（オプション）
- `|{` : 1以上（必須）
- `o{` : 0以上（オプション）

### リレーションシップラベル

```mermaid
erDiagram
    ENTITY_A ||--o{ ENTITY_B : "関係を説明"
```

ラベルは動詞または説明句を使用：
- `places`（発注する）
- `contains`（含む）
- `belongs to`（所属する）
- `has`（持つ）

## 実装パターン

### パターン1: シンプルなブログシステム

```mermaid
erDiagram
    USER {
        int id PK
        varchar name
        varchar email UK
        timestamp created_at
    }
    POST {
        int id PK
        int user_id FK
        varchar title
        text content
        boolean published
        timestamp created_at
    }
    COMMENT {
        int id PK
        int post_id FK
        int user_id FK
        text content
        timestamp created_at
    }

    USER ||--o{ POST : writes
    USER ||--o{ COMMENT : writes
    POST ||--o{ COMMENT : has
```

### パターン2: ECサイト

```mermaid
erDiagram
    CUSTOMER {
        int id PK
        varchar name
        varchar email UK
        varchar phone
    }
    ORDER {
        int id PK
        int customer_id FK
        datetime order_date
        varchar status
        decimal total_amount
    }
    ORDER_ITEM {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
        decimal unit_price
    }
    PRODUCT {
        int id PK
        int category_id FK
        varchar name
        text description
        decimal price
        int stock
    }
    CATEGORY {
        int id PK
        varchar name
        int parent_id FK
    }

    CUSTOMER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_ITEM : contains
    PRODUCT ||--o{ ORDER_ITEM : "ordered in"
    CATEGORY ||--o{ PRODUCT : includes
    CATEGORY |o--o{ CATEGORY : "parent of"
```

### パターン3: 多対多（中間テーブル）

```mermaid
erDiagram
    STUDENT {
        int id PK
        varchar name
    }
    COURSE {
        int id PK
        varchar title
    }
    ENROLLMENT {
        int id PK
        int student_id FK
        int course_id FK
        date enrolled_at
        varchar grade
    }

    STUDENT ||--o{ ENROLLMENT : enrolls
    COURSE ||--o{ ENROLLMENT : "has enrollment"
```

## ベストプラクティス

1. **エンティティ名**: 大文字スネークケース（`USER`, `ORDER_ITEM`）
2. **属性名**: 小文字スネークケース（`user_id`, `created_at`）
3. **主キー**: 各テーブルに`id PK`を定義
4. **外部キー**: `参照先テーブル名_id FK`形式
5. **タイムスタンプ**: `created_at`, `updated_at`を必要に応じて追加
6. **リレーションラベル**: 英語の動詞または日本語の説明を使用

## 出力形式

ER図は以下の形式でマークダウンに記述：

````markdown
## データベース設計

### ER図

```mermaid
erDiagram
    ...
```

### テーブル定義

#### テーブル名

| カラム | 型 | 制約 | 説明 |
|--------|-----|------|------|
| id | int | PK | 主キー |
| ... | ... | ... | ... |
````
