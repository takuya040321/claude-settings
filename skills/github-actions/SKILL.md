---
name: github-actions
description: GitHub Actions / CI/CD操作。ワークフローの確認、実行ログの取得、ジョブの再実行などCI/CD関連の操作を行う場合に使用。ユーザーが「CIの状態を確認して」「ワークフローを実行して」「失敗したジョブを再実行して」「ログを見せて」などと依頼した場合にトリガー。
---

# GitHub Actions

gh CLIを使用したGitHub Actions / CI/CD操作ガイド。

## ワークフロー一覧

```bash
# ワークフロー一覧
gh workflow list

# 無効化されたワークフローも含む
gh workflow list --all

# 特定のワークフローの詳細
gh workflow view <workflow-name>
```

## 実行一覧・確認

```bash
# 最近の実行一覧
gh run list

# 特定ブランチの実行
gh run list --branch main

# 特定ワークフローの実行
gh run list --workflow ci.yml

# 失敗した実行のみ
gh run list --status failure

# 実行数を指定
gh run list --limit 20

# 実行の詳細を表示
gh run view <run-id>

# WebブラウザでRun詳細を開く
gh run view <run-id> --web
```

## ログ確認

```bash
# 実行ログを表示
gh run view <run-id> --log

# 失敗したジョブのログのみ
gh run view <run-id> --log-failed

# 特定のジョブのログ
gh run view <run-id> --job <job-id> --log
```

## ワークフロー手動実行

```bash
# ワークフローを手動実行
gh workflow run <workflow-name>

# ブランチを指定して実行
gh workflow run <workflow-name> --ref feature-branch

# 入力パラメータを指定
gh workflow run <workflow-name> -f param1=value1 -f param2=value2

# JSONで入力を指定
gh workflow run <workflow-name> --json < inputs.json
```

## ジョブ再実行

```bash
# 失敗したジョブのみ再実行
gh run rerun <run-id> --failed

# 全ジョブを再実行
gh run rerun <run-id>

# 特定のジョブを再実行
gh run rerun <run-id> --job <job-name>

# デバッグログ有効で再実行
gh run rerun <run-id> --debug
```

## 実行待機・監視

```bash
# 実行が完了するまで待機
gh run watch <run-id>

# 終了コードを返す（CI連携用）
gh run watch <run-id> --exit-status
```

## 実行キャンセル

```bash
# 実行をキャンセル
gh run cancel <run-id>
```

## ワークフロー有効化・無効化

```bash
# ワークフローを無効化
gh workflow disable <workflow-name>

# ワークフローを有効化
gh workflow enable <workflow-name>
```

## アーティファクト

```bash
# アーティファクト一覧
gh run view <run-id>

# アーティファクトをダウンロード
gh run download <run-id>

# 特定のアーティファクトをダウンロード
gh run download <run-id> --name <artifact-name>

# ディレクトリを指定してダウンロード
gh run download <run-id> --dir ./artifacts
```

## キャッシュ管理

```bash
# キャッシュ一覧
gh cache list

# キャッシュ削除
gh cache delete <cache-id>

# キーでキャッシュ削除
gh cache delete --key <cache-key>
```

## トラブルシューティング手順

1. `gh run list`で最近の実行を確認
2. `gh run view <run-id>`で失敗した実行の詳細を確認
3. `gh run view <run-id> --log-failed`で失敗ログを取得
4. 問題を修正してプッシュ、または`gh run rerun <run-id> --failed`で再実行
