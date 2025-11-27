#!/usr/bin/env python3
"""
update_daily_stats.py

Fetches language statistics from the GitHub API for the authenticated user
(or GITHUB_USERNAME env) and updates the "What I Code Daily" section in
README.md with a neat bar chart.

Uses GITHUB_TOKEN (or GH_TOKEN) for auth.
"""
import os
import re
import requests

# ---------- Config ----------
USERNAME = os.getenv("GITHUB_USERNAME", "Chrinux-AI")
TOKEN = os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
README_PATH = "README.md"
BAR_FULL = "⣿"
BAR_EMPTY = "⣀"
BAR_WIDTH = 25  # total blocks


def get_repos(username: str, token: str | None):
    """Return list of repos (name, langs_url) for user."""
    url = f"https://api.github.com/users/{username}/repos?per_page=100"
    headers = {"Authorization": f"token {token}"} if token else {}
    resp = requests.get(url, headers=headers, timeout=30)
    resp.raise_for_status()
    return [(r["name"], r["languages_url"]) for r in resp.json() if not r["fork"]]


def aggregate_languages(repos, token: str | None):
    """Sum up bytes per language across all repos."""
    headers = {"Authorization": f"token {token}"} if token else {}
    totals: dict[str, int] = {}
    for _, langs_url in repos:
        try:
            resp = requests.get(langs_url, headers=headers, timeout=20)
            if resp.ok:
                for lang, size in resp.json().items():
                    totals[lang] = totals.get(lang, 0) + size
        except Exception:
            pass
    return totals


def make_bar(percent: float) -> str:
    filled = round(percent / 100 * BAR_WIDTH)
    return BAR_FULL * filled + BAR_EMPTY * (BAR_WIDTH - filled)


def build_stats_block(totals: dict[str, int], top_n: int = 5) -> str:
    total_bytes = sum(totals.values()) or 1
    sorted_langs = sorted(totals.items(), key=lambda x: -x[1])[:top_n]
    lines = []
    for lang, b in sorted_langs:
        pct = b / total_bytes * 100
        bar = make_bar(pct)
        lines.append(f"{lang:<16} {bar}   {pct:05.1f}%")
    return "\n".join(lines)


def update_readme(block: str):
    with open(README_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    # Replace code block under "## 📅 What I Code Daily"
    pattern = r"(## 📅 What I Code Daily\s*```text)\n[\s\S]*?(```)"
    replacement = rf"\1\n{block}\n\2"
    new_content, n = re.subn(pattern, replacement, content)

    if n == 0:
        print("Warning: Could not find the 'What I Code Daily' section in README.md")
        return

    with open(README_PATH, "w", encoding="utf-8") as f:
        f.write(new_content)
    print("README.md updated with new language stats.")


def main():
    repos = get_repos(USERNAME, TOKEN)
    print(f"Found {len(repos)} non-fork repos for {USERNAME}")
    totals = aggregate_languages(repos, TOKEN)
    if not totals:
        print("No language data found.")
        return
    block = build_stats_block(totals)
    print("Generated stats:\n", block)
    update_readme(block)


if __name__ == "__main__":
    main()
