# Mermaid記法リファレンス

詳細設計で使用する主要なMermaid記法のリファレンス。

## 目次

1. [クラス図](#クラス図)
2. [シーケンス図](#シーケンス図)
3. [ER図](#er図)
4. [状態遷移図](#状態遷移図)
5. [フローチャート](#フローチャート)

---

## クラス図

### 基本構文

```mermaid
classDiagram
    class ClassName {
        +publicField: Type
        -privateField: Type
        #protectedField: Type
        ~packageField: Type
        +publicMethod(): ReturnType
        -privateMethod(param: Type): void
    }
```

### アクセス修飾子

| 記号 | 意味 |
|------|------|
| `+` | public |
| `-` | private |
| `#` | protected |
| `~` | package/internal |

### 関係性

```mermaid
classDiagram
    %% 継承（汎化）
    Parent <|-- Child : extends

    %% 実装
    Interface <|.. Implementation : implements

    %% 関連
    ClassA --> ClassB : uses

    %% 集約（弱い所有）
    Whole o-- Part : has

    %% コンポジション（強い所有）
    Container *-- Component : contains

    %% 依存
    Client ..> Service : depends
```

| 記法 | 意味 | 説明 |
|------|------|------|
| `<\|--` | 継承 | 子クラスが親クラスを継承 |
| `<\|..` | 実装 | クラスがインターフェースを実装 |
| `-->` | 関連 | クラス間の参照関係 |
| `o--` | 集約 | 弱い所有（ライフサイクル独立） |
| `*--` | コンポジション | 強い所有（ライフサイクル依存） |
| `..>` | 依存 | 一時的な利用関係 |

### 抽象クラス・インターフェース

```mermaid
classDiagram
    class AbstractClass {
        <<abstract>>
        +abstractMethod()* void
    }

    class InterfaceName {
        <<interface>>
        +method() void
    }

    class EnumType {
        <<enumeration>>
        VALUE1
        VALUE2
    }
```

### 多重度

```mermaid
classDiagram
    User "1" --> "*" Order : places
    Order "1" --> "1..*" OrderItem : contains
```

| 記法 | 意味 |
|------|------|
| `1` | 1つ |
| `0..1` | 0または1 |
| `*` | 0以上 |
| `1..*` | 1以上 |
| `n..m` | n以上m以下 |

---

## シーケンス図

### 基本構文

```mermaid
sequenceDiagram
    participant A as Alice
    participant B as Bob

    A->>B: 同期メッセージ
    B-->>A: 応答
    A-)B: 非同期メッセージ
    B--)A: 非同期応答
```

### メッセージタイプ

| 記法 | 説明 |
|------|------|
| `->>` | 同期メッセージ（実線矢印） |
| `-->>` | 同期応答（点線矢印） |
| `-)` | 非同期メッセージ（実線開き矢印） |
| `--)` | 非同期応答（点線開き矢印） |
| `-x` | メッセージ失敗（×印） |

### アクティベーション

```mermaid
sequenceDiagram
    Client->>+Server: リクエスト
    Server->>+DB: クエリ
    DB-->>-Server: 結果
    Server-->>-Client: レスポンス
```

- `+` で開始、`-` で終了
- または `activate`/`deactivate` を使用

### 分岐・ループ

```mermaid
sequenceDiagram
    alt 条件A
        A->>B: 処理A
    else 条件B
        A->>B: 処理B
    end

    opt オプション条件
        A->>B: オプション処理
    end

    loop 繰り返し条件
        A->>B: ループ処理
    end

    par 並列処理
        A->>B: 処理1
    and
        A->>C: 処理2
    end
```

### ノート

```mermaid
sequenceDiagram
    A->>B: メッセージ
    Note right of B: 右側のノート
    Note left of A: 左側のノート
    Note over A,B: 複数参加者にまたがるノート
```

### 番号付け

```mermaid
sequenceDiagram
    autonumber
    A->>B: 最初のメッセージ
    B->>C: 2番目のメッセージ
```

---

## ER図

### 基本構文

```mermaid
erDiagram
    ENTITY {
        type attribute_name PK "コメント"
        type attribute_name FK
        type attribute_name UK
    }
```

### 属性タイプ

| 記号 | 意味 |
|------|------|
| PK | Primary Key |
| FK | Foreign Key |
| UK | Unique Key |

### リレーションシップ

```mermaid
erDiagram
    A ||--o{ B : "1対多（必須-任意）"
    C ||--|{ D : "1対多（必須-必須）"
    E }o--o{ F : "多対多"
    G ||--|| H : "1対1"
```

| 記法 | 意味 |
|------|------|
| `\|\|` | 1（必須） |
| `\|o` | 0または1 |
| `}o` | 0以上 |
| `}\|` | 1以上 |

### 完全な例

```mermaid
erDiagram
    users ||--o{ orders : "places"
    orders ||--|{ order_items : "contains"
    products ||--o{ order_items : "included_in"

    users {
        uuid id PK
        varchar email UK
        varchar name
        timestamp created_at
    }

    orders {
        uuid id PK
        uuid user_id FK
        varchar status
        decimal total
    }

    order_items {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        int quantity
    }

    products {
        uuid id PK
        varchar name
        decimal price
    }
```

---

## 状態遷移図

### 基本構文

```mermaid
stateDiagram-v2
    [*] --> 初期状態
    初期状態 --> 処理中 : イベント
    処理中 --> 完了 : 成功
    処理中 --> エラー : 失敗
    完了 --> [*]
    エラー --> [*]
```

### 複合状態

```mermaid
stateDiagram-v2
    state 親状態 {
        [*] --> 子状態1
        子状態1 --> 子状態2
        子状態2 --> [*]
    }
```

### 分岐・選択

```mermaid
stateDiagram-v2
    state 分岐 <<choice>>
    処理中 --> 分岐
    分岐 --> 成功 : 条件A
    分岐 --> 失敗 : 条件B
```

### 並行状態

```mermaid
stateDiagram-v2
    state 並行処理 {
        [*] --> 処理A
        [*] --> 処理B
        --
        処理A --> [*]
        処理B --> [*]
    }
```

---

## フローチャート

### 基本構文

```mermaid
flowchart TD
    A[開始] --> B{条件}
    B -->|Yes| C[処理1]
    B -->|No| D[処理2]
    C --> E[終了]
    D --> E
```

### 方向

| 記法 | 方向 |
|------|------|
| TD/TB | 上から下 |
| BT | 下から上 |
| LR | 左から右 |
| RL | 右から左 |

### ノード形状

```mermaid
flowchart LR
    A[四角形] --> B(角丸)
    B --> C([スタジアム])
    C --> D[[サブルーチン]]
    D --> E[(データベース)]
    E --> F((円))
    F --> G{ひし形}
    G --> H{{六角形}}
```

### サブグラフ

```mermaid
flowchart TD
    subgraph サーバー
        A[API] --> B[サービス]
    end
    subgraph データ層
        C[(DB)]
    end
    B --> C
```
