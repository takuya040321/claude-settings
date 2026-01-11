# Claude Code グローバル設定

このファイルはClaudeへの指示を記載しています。
プロジェクトの内容に応じて、適切なリソースを参照してください。

## Hooks

コード編集時に自動でフォーマット・品質チェックが実行されます。
エラーが検出された場合は、すべてのチェックに合格するまで修正してください。

### 言語別Hooks

プロジェクトで使用している言語に応じて、以下のhooksが自動適用されます:

| 言語 | Hook | 処理内容 |
|------|------|----------|
| Python | `~/.claude/hooks/python/format.sh` | black → ruff → mypy |
| JavaScript/TypeScript | `~/.claude/hooks/javascript/format.sh` | prettier → eslint |
| Dart/Flutter | `~/.claude/hooks/dart/format.sh` | dart format → dart analyze |

### エラー時の対応

hookからエラーがフィードバックされた場合:
1. エラー内容を確認する
2. コードを修正する
3. 再度ファイルを保存する（hookが再実行される）
4. すべてのチェックに合格するまで繰り返す

## Skills

カスタムスキルが定義されている場合は `~/.claude/skills/` を参照してください。

## Plugins

インストール済みプラグインは `~/.claude/plugins/` を参照してください。

## プロジェクト固有の設定

各プロジェクトのルートに `CLAUDE.md` を配置することで、
プロジェクト固有の指示を追加できます。

例:
```markdown
# プロジェクト: MyApp

## 使用技術
- Python 3.11
- FastAPI
- PostgreSQL

## コーディング規約
- 型ヒントを必ず使用すること
- docstringはGoogle形式で記述すること

## Hooks
このプロジェクトでは `~/.claude/hooks/python/` のhooksを使用。
```
