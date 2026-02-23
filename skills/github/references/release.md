---
name: github-release
description: GitHubリリース・タグ管理。リリースの作成、リリースノート生成、アセットアップロードなどリリース関連の操作を行う場合に使用。ユーザーが「リリースを作成して」「リリースノートを生成して」「タグを作成して」「アセットをアップロードして」などと依頼した場合にトリガー。
---

# GitHub Release

gh CLIを使用したリリース・タグ管理ガイド。

## リリース作成

### 基本

```bash
# 対話形式で作成
gh release create v1.0.0

# タイトルと本文を指定
gh release create v1.0.0 --title "v1.0.0" --notes "リリースノート"

# HEREDOCでリリースノートを指定
gh release create v1.0.0 --title "v1.0.0 - 初回リリース" --notes "$(cat <<'EOF'
## 新機能
- 機能Aを追加
- 機能Bを追加

## バグ修正
- 問題Xを修正

## 破壊的変更
- API v1は非推奨になりました
EOF
)"
```

### 自動リリースノート生成

```bash
# 前回リリースからの変更を自動でリリースノート化
gh release create v1.0.0 --generate-notes

# タイトルを指定して自動生成
gh release create v1.0.0 --title "v1.0.0" --generate-notes

# 前回リリースを明示的に指定
gh release create v1.0.0 --generate-notes --notes-start-tag v0.9.0
```

### オプション

```bash
# ドラフトとして作成
gh release create v1.0.0 --draft

# プレリリースとして作成
gh release create v1.0.0 --prerelease

# 最新リリースとしてマーク
gh release create v1.0.0 --latest

# 最新としてマークしない
gh release create v1.0.0 --latest=false

# 特定のコミット/ブランチからタグを作成
gh release create v1.0.0 --target main

# Discussion を作成
gh release create v1.0.0 --discussion-category "Announcements"
```

## アセットのアップロード

```bash
# リリース作成時にアセットを添付
gh release create v1.0.0 ./dist/app.zip ./dist/app.tar.gz

# アセットに表示名を付ける
gh release create v1.0.0 './dist/app.zip#Application (Windows)'

# 既存リリースにアセットを追加
gh release upload v1.0.0 ./dist/new-asset.zip

# 同名ファイルを上書き
gh release upload v1.0.0 ./dist/app.zip --clobber
```

## リリース一覧・確認

```bash
# 一覧表示
gh release list

# 件数を指定
gh release list --limit 20

# ドラフトを除外
gh release list --exclude-drafts

# プレリリースを除外
gh release list --exclude-pre-releases

# リリース詳細を表示
gh release view v1.0.0

# WebブラウザでReleaseを開く
gh release view v1.0.0 --web

# 最新リリースを表示
gh release view --latest
```

## リリース編集

```bash
# タイトルを変更
gh release edit v1.0.0 --title "新しいタイトル"

# リリースノートを変更
gh release edit v1.0.0 --notes "新しいリリースノート"

# ドラフトを公開
gh release edit v1.0.0 --draft=false

# プレリリースに変更
gh release edit v1.0.0 --prerelease

# 最新リリースとしてマーク
gh release edit v1.0.0 --latest

# タグを変更
gh release edit v1.0.0 --tag v1.0.1
```

## リリース削除

```bash
# リリースを削除（タグは残る）
gh release delete v1.0.0

# 確認なしで削除
gh release delete v1.0.0 --yes

# タグも一緒に削除
gh release delete v1.0.0 --cleanup-tag
```

## アセットダウンロード

```bash
# 全アセットをダウンロード
gh release download v1.0.0

# 特定のアセットをダウンロード
gh release download v1.0.0 --pattern "*.zip"

# ディレクトリを指定
gh release download v1.0.0 --dir ./downloads

# 最新リリースからダウンロード
gh release download --latest
```

## セマンティックバージョニング

| バージョン | 説明 |
|-----------|------|
| `v1.0.0` | メジャー.マイナー.パッチ |
| `v1.0.0-alpha` | アルファ版 |
| `v1.0.0-beta.1` | ベータ版 |
| `v1.0.0-rc.1` | リリース候補 |

## リリースフロー（推奨）

1. `gh release list`で既存リリースを確認
2. バージョン番号を決定（セマンティックバージョニング）
3. `gh release create --generate-notes --draft`でドラフト作成
4. リリースノートを確認・編集
5. `gh release edit --draft=false`で公開

## タグ操作（Git）

```bash
# タグ一覧
git tag

# 注釈付きタグを作成
git tag -a v1.0.0 -m "Version 1.0.0"

# タグをプッシュ
git push origin v1.0.0

# 全タグをプッシュ
git push origin --tags

# タグを削除（ローカル）
git tag -d v1.0.0

# タグを削除（リモート）
git push origin --delete v1.0.0
```
