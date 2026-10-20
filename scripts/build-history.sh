#!/usr/bin/env bash
# 构建期脚本（讲师用）：从当前工作区重新生成 git-quest 的完整提交历史。
#
# Phase 4 依赖一段「添加文件 → 删除文件」的历史，这段历史只能靠脚本按顺序制造。
# 脚本会删除并重建本仓库的 .git，所有未推送的提交都会丢失——学生请勿运行。
#
# 用法：bash scripts/build-history.sh --yes-rebuild
#
# 可重复执行：作者、提交时间都是固定的，同样的工作区每次都会产出完全相同的提交编号。

set -euo pipefail

if [ "${1:-}" != "--yes-rebuild" ]; then
  echo "这是讲师构建用脚本，会删除并重建本仓库的 .git。"
  echo "确认要执行，请运行：bash scripts/build-history.sh --yes-rebuild"
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Phase 4 的文件内容，以 base64 保存，保证工作区里搜不到口令明文
XIAOYOU_B64='77u/4oCU4oCUIOWGmee7meWImui/m+mXqOeahOWQjOWtpgoK6Lev6KaB6Ieq5bex6LWw77yM5ZG95Luk6KaB6Ieq5bex5pWy44CCCgpQaGFzZSA0IOWPo+S7pO+8mkhFQlVUe2tlLXhpZS1haS1idX0K'

# ---- 清理 ----
rm -rf .git quest/xiaoyou.txt

git init -q
git symbolic-ref HEAD refs/heads/main
git config user.name "hebut-ai-bot"
git config user.email "hebut-ai-bot@example.com"
git config core.autocrlf false
git config commit.gpgsign false

# 从 2026-10-20 10:00 (+0800) 起，每次提交间隔一小时
T0=1792461600
seq_no=0
commit() {
  local ts=$((T0 + seq_no * 3600))
  seq_no=$((seq_no + 1))
  GIT_AUTHOR_DATE="@$ts +0800" GIT_COMMITTER_DATE="@$ts +0800" \
    git commit -q --no-verify -m "$1"
}

# ---- 按顺序制造历史 ----
git add .gitattributes .gitignore README.md members/_template.md scripts
commit "init: 仓库初始化"

git add quest/phase1
commit "quest: 添加 Phase 1 迷宫"

git add quest/phase2
commit "quest: 添加 Phase 2"

git add quest/phase3
commit "quest: 添加 Phase 3"

printf '%s' "$XIAOYOU_B64" | base64 --decode > quest/xiaoyou.txt
git add quest/xiaoyou.txt
commit "quest: 添加校友寄语"

git add quest/README.md
commit "docs: 补充说明"

git rm -q quest/xiaoyou.txt
commit "quest: 移除校友寄语（内容待核实）"

git add .github
commit "ci: 添加 PR 自动检查与 PR 模板"

git add members/hebut-ai-demo.md
commit "members: 合并课上演示 hebut-ai-demo"

# ---- 自检 ----
if [ -n "$(git status --porcelain)" ]; then
  echo "错误：以下文件没有被纳入任何一次提交，请在脚本里补上："
  git status --short
  exit 1
fi

del_commit="$(git log --format=%h --diff-filter=D -- quest/xiaoyou.txt)"
if [ -z "$del_commit" ] || [ -e quest/xiaoyou.txt ]; then
  echo "错误：Phase 4 的删除提交不存在，或 quest/xiaoyou.txt 仍在工作区"
  exit 1
fi
if ! git show "$del_commit^:quest/xiaoyou.txt" >/dev/null 2>&1; then
  echo "错误：在删除提交的上一次提交里找不到 quest/xiaoyou.txt"
  exit 1
fi
if [ "$(git log -1 --format=%h)" = "$del_commit" ]; then
  echo "错误：删除提交不应是最后一条"
  exit 1
fi

git log --oneline
echo
echo "构建完成。Phase 4 删除提交：$del_commit"
