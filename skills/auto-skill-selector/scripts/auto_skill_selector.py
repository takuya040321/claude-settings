#!/usr/bin/env python3
"""
Auto Skill Selector - UserPromptSubmit Hook

ユーザーの入力内容を分析し、適切なスキルを自動推奨する。
"""

import json
import os
import re
import sys
from pathlib import Path


def load_skills_registry() -> list[dict]:
    """スキルレジストリを読み込む"""
    # シンボリックリンク経由で実行される場合を考慮して.resolve()を使用
    registry_path = Path(__file__).resolve().parent.parent / "references" / "skills_registry.json"
    if not registry_path.exists():
        return []
    with open(registry_path, encoding="utf-8") as f:
        data = json.load(f)
    return data.get("skills", [])


def detect_tech_stack(cwd: str) -> set[str]:
    """プロジェクトの技術スタックを検出"""
    tech_stack = set()
    cwd_path = Path(cwd)

    # Python
    if (cwd_path / "pyproject.toml").exists() or (cwd_path / "requirements.txt").exists():
        tech_stack.add("python")

    # Node.js / JavaScript / TypeScript
    if (cwd_path / "package.json").exists():
        tech_stack.add("nodejs")
        tech_stack.add("javascript")
        pkg_path = cwd_path / "package.json"
        try:
            with open(pkg_path, encoding="utf-8") as f:
                pkg = json.load(f)
            deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}
            if "typescript" in deps:
                tech_stack.add("typescript")
            if "react" in deps or "next" in deps:
                tech_stack.add("react")
            if "vue" in deps:
                tech_stack.add("vue")
            if "svelte" in deps:
                tech_stack.add("svelte")
            if "tailwindcss" in deps:
                tech_stack.add("tailwind")
            if "playwright" in deps or "@playwright/test" in deps:
                tech_stack.add("playwright")
        except (json.JSONDecodeError, OSError):
            pass

    # Dart / Flutter
    if (cwd_path / "pubspec.yaml").exists():
        tech_stack.add("dart")
        tech_stack.add("flutter")

    # GAS
    if (cwd_path / ".clasp.json").exists() or (cwd_path / "appsscript.json").exists():
        tech_stack.add("gas")
        tech_stack.add("javascript")

    return tech_stack


def get_recent_context(transcript_path: str, limit: int = 5) -> str:
    """直近のセッション履歴からコンテキストを取得"""
    if not transcript_path or not Path(transcript_path).exists():
        return ""

    context_parts = []
    try:
        with open(transcript_path, encoding="utf-8") as f:
            lines = f.readlines()

        # 直近N件のメッセージを取得
        recent_messages = []
        for line in reversed(lines):
            if len(recent_messages) >= limit:
                break
            try:
                entry = json.loads(line.strip())
                if entry.get("type") == "user":
                    msg = entry.get("message", {})
                    if isinstance(msg, dict):
                        content = msg.get("content", "")
                        if isinstance(content, str) and content:
                            recent_messages.append(content)
            except json.JSONDecodeError:
                continue

        context_parts = list(reversed(recent_messages))
    except OSError:
        pass

    return " ".join(context_parts)


def calculate_skill_score(
    skill: dict,
    prompt: str,
    tech_stack: set[str],
    context: str,
) -> tuple[float, str]:
    """スキルのマッチスコアを計算"""
    score = 0.0
    reasons = []
    prompt_lower = prompt.lower()
    context_lower = context.lower()

    # キーワードマッチ（最優先）
    for keyword in skill.get("keywords", []):
        keyword_lower = keyword.lower()
        if keyword_lower in prompt_lower:
            # 完全なキーワードマッチは高スコア
            if re.search(rf"\b{re.escape(keyword_lower)}\b", prompt_lower):
                score += 10.0
                reasons.append(f"キーワード「{keyword}」が一致")
            else:
                score += 5.0
                reasons.append(f"キーワード「{keyword}」を含む")

    # 技術スタックマッチ
    skill_tech = set(skill.get("tech_stack", []))
    matched_tech = tech_stack & skill_tech
    if matched_tech:
        score += 3.0 * len(matched_tech)
        reasons.append(f"技術スタック「{', '.join(matched_tech)}」が一致")

    # ファイルパターン（プロンプト内でファイル名に言及している場合）
    for pattern in skill.get("file_patterns", []):
        if pattern.startswith("."):
            # 拡張子パターン
            ext = pattern.lower()
            if ext in prompt_lower or ext in context_lower:
                score += 4.0
                reasons.append(f"ファイル形式「{pattern}」に言及")

    # セッション履歴からのコンテキストマッチ（低優先度）
    if context:
        for keyword in skill.get("keywords", []):
            if keyword.lower() in context_lower:
                score += 1.0
                reasons.append(f"履歴に「{keyword}」の話題あり")
                break

    reason = reasons[0] if reasons else ""
    return score, reason


def select_skill(prompt: str, cwd: str, transcript_path: str) -> tuple[str | None, str]:
    """最適なスキルを選択"""
    skills = load_skills_registry()
    if not skills:
        return None, ""

    tech_stack = detect_tech_stack(cwd)
    context = get_recent_context(transcript_path)

    # 各スキルのスコアを計算
    scored_skills = []
    for skill in skills:
        score, reason = calculate_skill_score(skill, prompt, tech_stack, context)
        if score > 0:
            scored_skills.append((skill["name"], score, reason))

    if not scored_skills:
        return None, ""

    # スコア順にソート
    scored_skills.sort(key=lambda x: x[1], reverse=True)

    # 最高スコアが閾値以上なら推奨
    best_skill, best_score, best_reason = scored_skills[0]
    if best_score >= 5.0:  # 閾値
        return best_skill, best_reason

    return None, ""


def main() -> None:
    """メイン処理"""
    try:
        # stdinからJSON読み込み
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # JSONパースエラーは無視して終了
        sys.exit(0)

    prompt = input_data.get("prompt", "")
    cwd = input_data.get("cwd", os.getcwd())
    transcript_path = input_data.get("transcript_path", "")

    if not prompt:
        sys.exit(0)

    # スキル選択
    skill_name, reason = select_skill(prompt, cwd, transcript_path)

    if skill_name:
        # 推奨スキルを出力（Claudeコンテキストに追加される）
        output = f"<system-reminder>推奨スキル: /{skill_name} - {reason}</system-reminder>"
        print(output)

    sys.exit(0)


if __name__ == "__main__":
    main()
