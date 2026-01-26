# Claude Code グローバル設定

このファイルはClaudeへの指示を記載しています。
プロジェクトの内容に応じて、適切なリソースを参照してください。

## Hooks

### スキル自動選択（UserPromptSubmit）

ユーザーがプロンプトを送信するたびに `auto-skill-selector` が実行され、入力内容に応じた適切なスキルが自動推奨されます。

### コード品質チェック（PostToolUse）

コード編集時（Edit/Write）に自動でフォーマット・品質チェック・型チェックが実行されます。
エラーが検出された場合は、すべてのチェックに合格するまで修正してください。

| 言語 | 処理内容 |
|------|----------|
| JavaScript/TypeScript | prettier → eslint → tsc |
| Dart/Flutter | dart format → dart analyze |
| Python | `python-coding` スキルで品質チェック |

**重要**: チェックでNGとなった場合、必ず修正し、OKが出るまで繰り返すこと。

## Skills

カスタムスキルは `~/.claude/skills/` に定義されています。
`auto-skill-selector` が入力内容に応じて適切なスキルを自動推奨します。

## Plugins

インストール済みプラグインは `~/.claude/plugins/` を参照してください。


```
