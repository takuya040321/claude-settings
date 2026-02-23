---
name: react
description: React開発の3つの領域（コーディング、テスト、コンポーネント設計）を統括する包括スキル。タスクに応じて適切な特化リファレンスを参照する。ユーザーが「Reactで」「Reactコンポーネント」「リアクト」などReact開発全般に関わるタスクを依頼した場合にトリガー。
---

# React 開発ガイド

React開発の包括的なガイド。タスクに応じて適切なリファレンスを参照する。

## タスク別リファレンス

| タスク | リファレンス |
|--------|-------------|
| コード作成・品質チェック | [references/coding.md](references/coding.md) |
| テスト作成・実行（Vitest/Jest） | [references/testing.md](references/testing.md) |
| コンポーネント設計・Hooks・状態管理 | [references/components.md](references/components.md) |

### 各領域の概要

- **コーディング** - JSX規約、Hooksルール、Props/型定義、条件付きレンダリング、ESLint設定
- **テスト** - Vitest/Jest、Testing Library、コンポーネントテスト、Hook テスト、MSW
- **コンポーネント設計** - Compound Components、Render Props、HOC、カスタムHooks、状態管理

### コンポーネント設計の詳細リファレンス

| テーマ | リファレンス |
|--------|-------------|
| 高度なコンポーネントパターン | [references/component-patterns.md](references/component-patterns.md) |
| カスタムHooksパターン集 | [references/hooks-patterns.md](references/hooks-patterns.md) |
| 状態管理ガイド | [references/state-management.md](references/state-management.md) |

## コード品質チェック

```bash
# フォーマット・リント・型チェック（typescript-codingのスクリプトを使用）
~/.claude/skills/typescript-coding/scripts/check.sh src/
```

## 推奨ツールスタック

| カテゴリ | ツール | 用途 |
|---------|--------|------|
| ビルドツール | Vite | 高速開発サーバー・ビルド |
| テスト | Vitest + Testing Library | コンポーネントテスト |
| UIライブラリ | shadcn/ui | アクセシブルなUIコンポーネント |
| スタイリング | Tailwind CSS | ユーティリティファーストCSS |
| 状態管理 | Zustand / TanStack Query | クライアント/サーバー状態 |
| フォーム | React Hook Form + Zod | フォームバリデーション |

## 関連スキル

| スキル | 連携内容 |
|--------|---------|
| `typescript-coding` | TypeScript規約・check.shを共有 |
| `typescript-testing` | Vitest/Jestの基本を共有 |
| `frontend-design` | UI/UXデザイン哲学 |
