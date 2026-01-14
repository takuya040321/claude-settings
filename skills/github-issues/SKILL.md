---
name: github-issues
description: GitHub Issues操作。Issueの作成、管理、ラベル付け、アサインなどIssue関連の操作を行う場合に使用。ユーザーが「Issueを作成して」「Issueの一覧を見せて」「Issueをクローズして」「ラベルを付けて」などと依頼した場合にトリガー。
---

# GitHub Issues

gh CLIを使用したIssue操作ガイド。

## Issue作成

### 基本

```bash
# 対話形式で作成
gh issue create

# タイトルと本文を指定
gh issue create --title "タイトル" --body "本文"

# HEREDOCで本文を指定（複数行）
gh issue create --title "バグ報告: ログインエラー" --body "$(cat <<'EOF'
## 概要
ログイン時にエラーが発生する

## 再現手順
1. ログインページを開く
2. 認証情報を入力
3. 送信ボタンをクリック

## 期待される動作
正常にログインできる

## 実際の動作
500エラーが表示される
EOF
)"
```

### オプション

```bash
# ラベルを付与
gh issue create --label "bug"

# 複数ラベル
gh issue create --label "bug,priority:high"

# アサインを指定
gh issue create --assignee @me

# マイルストーンを指定
gh issue create --milestone "v1.0"

# プロジェクトに追加
gh issue create --project "Roadmap"
```

## Issue一覧・確認

```bash
# 一覧表示
gh issue list

# 自分にアサインされたIssue
gh issue list --assignee @me

# 特定のラベル
gh issue list --label "bug"

# 状態でフィルタ
gh issue list --state open     # open/closed/all

# 検索クエリ
gh issue list --search "is:open label:bug"

# 件数指定
gh issue list --limit 50

# Issue詳細を表示
gh issue view 123

# WebブラウザでIssueを開く
gh issue view 123 --web
```

## Issueコメント

```bash
# コメントを追加
gh issue comment 123 --body "コメント内容"

# エディタでコメントを作成
gh issue comment 123 --editor

# HEREDOCでコメント
gh issue comment 123 --body "$(cat <<'EOF'
調査結果:
- 原因はXXXでした
- 修正PRを作成します
EOF
)"
```

## Issue編集

```bash
# タイトルを変更
gh issue edit 123 --title "新しいタイトル"

# 本文を変更
gh issue edit 123 --body "新しい本文"

# ラベルを追加
gh issue edit 123 --add-label "enhancement"

# ラベルを削除
gh issue edit 123 --remove-label "bug"

# アサインを追加
gh issue edit 123 --add-assignee user1

# アサインを削除
gh issue edit 123 --remove-assignee user1

# マイルストーンを設定
gh issue edit 123 --milestone "v1.0"

# プロジェクトに追加
gh issue edit 123 --add-project "Roadmap"
```

## Issueクローズ・リオープン

```bash
# Issueをクローズ
gh issue close 123

# 理由を付けてクローズ
gh issue close 123 --comment "修正完了"

# 完了としてクローズ
gh issue close 123 --reason completed

# 対応しないとしてクローズ
gh issue close 123 --reason "not planned"

# Issueを再オープン
gh issue reopen 123

# コメント付きで再オープン
gh issue reopen 123 --comment "再調査が必要"
```

## Issue削除

```bash
# Issueを削除（元に戻せない）
gh issue delete 123

# 確認なしで削除
gh issue delete 123 --yes
```

## Issue転送

```bash
# 別リポジトリへ転送
gh issue transfer 123 owner/other-repo
```

## Issueピン留め

```bash
# Issueをピン留め
gh issue pin 123

# ピン留め解除
gh issue unpin 123
```

## Issue検索（高度）

```bash
# 複合検索
gh issue list --search "is:open is:issue label:bug assignee:@me"

# 作成日でフィルタ
gh issue list --search "created:>2024-01-01"

# 更新日でフィルタ
gh issue list --search "updated:>2024-01-01"

# コメント数でフィルタ
gh issue list --search "comments:>5"
```

## Issue管理フロー（推奨）

1. `gh issue list`で現在のIssue状況を確認
2. 新規Issueは適切なラベルとアサインを付けて作成
3. 作業開始時にコメントで宣言
4. 完了時は関連PRを紐付けてクローズ
