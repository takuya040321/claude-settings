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
| JavaScript/TypeScript | `~/.claude/hooks/javascript/format.sh` | prettier → eslint |
| Dart/Flutter | `~/.claude/hooks/dart/format.sh` | dart format → dart analyze |

**注**: Pythonは`python-coding`スキルで品質チェックを実行します。

### エラー時の対応

hookからエラーがフィードバックされた場合:
1. エラー内容を確認する
2. コードを修正する
3. 再度ファイルを保存する（hookが再実行される）
4. すべてのチェックに合格するまで繰り返す

## Rules

コーディング規約やベストプラクティスは `~/.claude/rules/` を参照してください。

| ディレクトリ | 内容 |
|-------------|------|
| `rules/common/` | コミットルール（Conventional Commits） |
| `rules/javascript/` | JavaScript/TypeScriptベストプラクティス |
| `rules/dart/` | Dart/Flutterベストプラクティス |

**注**: Pythonは`python-coding`スキルを参照してください。

コード作成時やコミット時に、該当する言語のルールを参照すること。

## Skills

カスタムスキルが定義されている場合は `~/.claude/skills/` を参照してください。

### Python関連スキル

| スキル | 説明 |
|--------|------|
| `python-coding` | コーディングベストプラクティス + 品質チェック（black/ruff/mypy） |
| `python-testing` | pytestを使ったテスト作成・実行ガイド |

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

## スキル
このプロジェクトでは `python-coding` と `python-testing` スキルを使用。
```
