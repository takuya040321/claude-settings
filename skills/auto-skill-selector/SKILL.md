---
name: auto-skill-selector
description: ユーザー入力時に自動発動し、セッション履歴・直近メッセージ・プロジェクト設定から適切なスキルを判定してClaudeに推奨するシステム。UserPromptSubmitフックで動作。
---

# Auto Skill Selector

ユーザーの入力内容を分析し、適切なスキルを自動推奨するシステム。

## 概要

- **トリガー**: `UserPromptSubmit` フック
- **入力**: ユーザーのプロンプト、セッション履歴、プロジェクト設定
- **出力**: 推奨スキル（`<system-reminder>` 形式でClaudeコンテキストに追加）

## 処理フロー

1. stdin から JSON 読み込み（prompt, transcript_path, cwd）
2. コンテキスト収集
   - 直近のメッセージを解析
   - transcript.jsonl から直近のやりとりを読み込み
   - cwd配下のCLAUDE.md, package.json, pubspec.yaml等を検出
3. スキルマッチング（スコアリング）
4. 推奨スキル出力

## マッチングロジック（優先度順）

1. **明示的キーワード**: 「PR作成」→ github-pr、「コミット」→ commit
2. **技術スタック検出**: package.json → JS/TS系、pubspec.yaml → Dart系
3. **セッション履歴からの推測**: 直近の話題から関連スキルを推測
4. **ファイル拡張子**: .xlsx → xlsx、.pdf → pdf

## ファイル構成

```
auto-skill-selector/
├── SKILL.md
├── scripts/
│   └── auto_skill_selector.py    # メイン処理
└── references/
    └── skills_registry.json      # スキルメタデータ
```

## フック設定

settings.json の `hooks.UserPromptSubmit` に設定済み。
