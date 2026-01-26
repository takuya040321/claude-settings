---
name: react
description: React開発の3つの領域（コーディング、テスト、コンポーネント設計）を統括する包括スキル。タスクに応じて適切な特化スキルを呼び出す。ユーザーが「Reactで」「Reactコンポーネント」「リアクト」などReact開発全般に関わるタスクを依頼した場合にトリガー。
---

# React 開発ガイド

React開発の包括的なガイド。タスクに応じて適切な特化スキルを選択する。

## タスク振り分け

### 1. コード作成・品質チェック（react-coding）

以下の場合に`react-coding`スキルを使用：

- Reactコンポーネントの作成・編集
- JSX/TSXのコーディング
- Hooks の実装
- コードのフォーマット・リンティング
- 型チェック（TypeScript）

**トリガー例**:
- 「Reactでボタンコンポーネントを作成して」
- 「このコンポーネントをリファクタリングして」
- 「型定義を追加して」

### 2. テスト作成・実行（react-testing）

以下の場合に`react-testing`スキルを使用：

- Vitest/Jestを使ったコンポーネントテスト
- Testing Libraryによるユーザー操作テスト
- カスタムフックのテスト
- 統合テストの実行

**トリガー例**:
- 「このコンポーネントのテストを書いて」
- 「カスタムフックをテストして」
- 「テストを実行して」

### 3. コンポーネント設計・UI開発（react-components）

以下の場合に`react-components`スキルを使用：

- コンポーネント設計パターンの選択
- カスタムHooksの設計
- 状態管理の設計
- UIライブラリ（shadcn/ui等）の活用

**トリガー例**:
- 「再利用可能なモーダルを設計して」
- 「カスタムフックを作成して」
- 「状態管理をどうすべきか」

## クイックリファレンス

### プロジェクト作成

```bash
# Vite + React + TypeScript
npm create vite@latest my-app -- --template react-ts
cd my-app
npm install

# shadcn/ui のセットアップ
npx shadcn@latest init
```

### コード品質チェック

```bash
# フォーマット・リント・型チェック（typescript-codingのスクリプトを使用）
~/.claude/skills/typescript-coding/scripts/check.sh src/
```

### テスト実行

```bash
# Vitest
npm run test
npx vitest run

# Jest
npm test
npx jest
```

## 推奨ツールスタック

| カテゴリ | ツール | 用途 |
|---------|--------|------|
| ビルドツール | Vite | 高速開発サーバー・ビルド |
| テスト | Vitest + Testing Library | コンポーネントテスト |
| UIライブラリ | shadcn/ui | アクセシブルなUIコンポーネント |
| スタイリング | Tailwind CSS | ユーティリティファーストCSS |
| 状態管理 | Zustand / TanStack Query | クライアント/サーバー状態 |
| ルーティング | React Router / TanStack Router | SPA ルーティング |
| フォーム | React Hook Form + Zod | フォームバリデーション |

## プロジェクト構成（推奨）

```
project/
├── src/
│   ├── components/
│   │   ├── ui/              # 基本UIコンポーネント
│   │   └── features/        # 機能別コンポーネント
│   ├── hooks/               # カスタムフック
│   ├── lib/                 # ユーティリティ
│   ├── types/               # 型定義
│   ├── App.tsx
│   └── main.tsx
├── tests/
│   └── components/
├── package.json
├── tsconfig.json
├── vite.config.ts
└── vitest.config.ts
```

## ワークフロー

### 新規プロジェクト開始

1. Viteでプロジェクト作成
2. 必要なライブラリをインストール（shadcn/ui, Tailwind CSS等）
3. `react-components`で全体設計
4. `react-coding`でコンポーネント実装
5. `react-testing`でテスト作成

### 既存プロジェクト作業

1. `react-components`で設計確認・修正
2. `react-coding`でコード編集
3. `react-testing`でテスト実行
4. `react-coding`で品質チェック

## 関連スキル

| スキル | 連携内容 |
|--------|---------|
| `typescript-coding` | TypeScript規約・check.shを共有 |
| `typescript-testing` | Vitest/Jestの基本を共有 |
| `frontend-design` | UI/UXデザイン哲学 |
