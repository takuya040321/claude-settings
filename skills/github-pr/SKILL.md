---
name: github-pr
description: GitHubプルリクエスト操作。PRの作成、レビュー、コメント、マージなどPR関連の操作を行う場合に使用。ユーザーが「PRを作成して」「PRをレビューして」「PRをマージして」「PRの状態を確認して」などと依頼した場合にトリガー。
---

# GitHub PR

gh CLIを使用したプルリクエスト操作ガイド。

## PR作成

### 基本

```bash
# 対話形式で作成
gh pr create

# タイトルと本文を指定
gh pr create --title "タイトル" --body "本文"

# HEREDOCで本文を指定（複数行）
gh pr create --title "feat: 新機能追加" --body "$(cat <<'EOF'
## Summary
- 機能Aを追加
- 機能Bを改善

## Test plan
- [ ] ユニットテスト実行
- [ ] 手動確認
EOF
)"
```

### オプション

```bash
# ベースブランチを指定
gh pr create --base main

# ドラフトPRとして作成
gh pr create --draft

# レビュアーを指定
gh pr create --reviewer user1,user2

# ラベルを付与
gh pr create --label "enhancement"

# アサインを指定
gh pr create --assignee @me
```

## PR一覧・確認

```bash
# 一覧表示
gh pr list

# 自分が作成したPRのみ
gh pr list --author @me

# レビュー待ちのPR
gh pr list --search "review-requested:@me"

# 特定の状態
gh pr list --state open    # open/closed/merged/all

# PR詳細を表示
gh pr view 123

# WebブラウザでPRを開く
gh pr view 123 --web
```

## PRレビュー

```bash
# 差分を確認
gh pr diff 123

# レビューを送信（承認）
gh pr review 123 --approve

# レビューを送信（変更リクエスト）
gh pr review 123 --request-changes --body "修正点を記載"

# レビューを送信（コメントのみ）
gh pr review 123 --comment --body "確認しました"
```

## PRコメント

```bash
# コメントを追加
gh pr comment 123 --body "コメント内容"

# コメント一覧を取得（API使用）
gh api repos/{owner}/{repo}/pulls/123/comments

# レビューコメント一覧
gh api repos/{owner}/{repo}/pulls/123/reviews
```

## PRマージ

```bash
# マージ（デフォルト: merge commit）
gh pr merge 123

# スカッシュマージ
gh pr merge 123 --squash

# リベースマージ
gh pr merge 123 --rebase

# マージ後にブランチを削除
gh pr merge 123 --delete-branch

# 自動マージを有効化（CI通過後に自動マージ）
gh pr merge 123 --auto --squash
```

## PRチェックアウト

```bash
# PRのブランチをローカルにチェックアウト
gh pr checkout 123

# 別名でチェックアウト
gh pr checkout 123 --branch my-local-branch
```

## PRステータス確認

```bash
# CIステータスを確認
gh pr checks 123

# CIが完了するまで待機
gh pr checks 123 --watch
```

## PR編集

```bash
# タイトルを変更
gh pr edit 123 --title "新しいタイトル"

# ラベルを追加
gh pr edit 123 --add-label "bug"

# レビュアーを追加
gh pr edit 123 --add-reviewer user1

# ベースブランチを変更
gh pr edit 123 --base develop
```

## PR作成手順（推奨）

1. `git status`で変更を確認
2. `git diff main...HEAD`で差分を確認
3. 変更内容を分析し、PRタイトル・本文を作成
4. `gh pr create`でPRを作成
5. `gh pr view`で作成されたPRを確認
