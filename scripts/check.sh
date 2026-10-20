#!/usr/bin/env bash
# Git Quest 本地自检：核对成员文件里四个 Phase 的口令对了几个。
#
# 用法：
#   bash scripts/check.sh                       # 自动找 members/ 下最近修改的成员文件
#   bash scripts/check.sh members/你的用户名.md  # 指定文件
#
# 本脚本只保存口令的 SHA-256 哈希值，读源码是拿不到答案的。

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Phase 1–4 口令的 SHA-256
HASHES=(
  d6e424493338b458362a41676508f33d49bcfb1009cddf961fcdb7c7c4f52599
  030a17a861332222eb283639529a030e97c891891cb568a4f2fec106665c3209
  422962797673e0eea26d86363fa9daf20c26072dfebba5f1e7b06b1cebddeeab
  0f1c541bf371301621a336a510dbfb35aefe93bb2dbcd35b2e0c52cf3eed29f1
)

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

# ---- 确定要检查的文件 ----
if [ $# -ge 1 ]; then
  if [ -f "$1" ]; then
    file="$1"
  elif [ -f "$ROOT/$1" ]; then
    file="$ROOT/$1"
  else
    echo "找不到文件：$1"
    exit 1
  fi
else
  file=""
  for f in $(ls -t "$ROOT"/members/*.md 2>/dev/null); do
    case "$(basename "$f")" in
      _template.md|hebut-ai-demo.md) continue ;;
    esac
    file="$f"
    break
  done
  if [ -z "$file" ]; then
    echo "members/ 下还没有你的成员文件。"
    echo "先运行：cp members/_template.md members/你的用户名.md"
    exit 1
  fi
fi

echo "检查文件：${file#"$ROOT"/}"
echo

# ---- 从口令表里取出第 N 行的口令 ----
# 表格行形如：| 1 | HEBUT{...} | 我敲的命令 |
# 去掉首尾空白和反引号，兼容 Windows 的 CRLF 换行。
extract() {
  tr -d '\r' < "$file" | awk -F'|' -v p="$1" '
    { n = $2; gsub(/[ \t]/, "", n) }
    n == p { v = $3; gsub(/^[ \t`]+|[ \t`]+$/, "", v); print v; exit }'
}

correct=0
for i in 1 2 3 4; do
  answer="$(extract "$i")"
  if [ -n "$answer" ] && [ "$(printf '%s' "$answer" | sha256)" = "${HASHES[$((i - 1))]}" ]; then
    echo "Phase $i: ✓"
    correct=$((correct + 1))
  else
    echo "Phase $i: ✗"
  fi
done

echo "共 $correct / 4 个口令正确。"
