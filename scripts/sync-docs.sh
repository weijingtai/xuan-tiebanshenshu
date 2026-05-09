#!/usr/bin/env bash
# 同步 weijingtai/docs 上游到本地 docs/，并叠加 docs-overrides/。
# 详见 docs/superpowers/specs/2026-05-08-docs-framework-init-design.md

set -euo pipefail

UPSTREAM_URL="https://github.com/weijingtai/docs.git"
UPSTREAM_REF="master"
PRESERVE_DIRS=("previous_archived")    # docs/ 下需要在同步中保留的子目录

REPO_ROOT="$(git rev-parse --show-toplevel)"
DOCS_DIR="$REPO_ROOT/docs"
OVERRIDES_DIR="$REPO_ROOT/docs-overrides"

# 1. 检查 docs/ 是否干净（包含 untracked，防止手动新建的文件被静默覆盖）
if [ -d "$DOCS_DIR" ]; then
  dirty="$(git -C "$REPO_ROOT" status --porcelain -- "$DOCS_DIR" || true)"
  if [ -n "$dirty" ]; then
    echo "错误：docs/ 有未提交或未跟踪改动。请先 commit 或处理后再同步。" >&2
    echo "$dirty" >&2
    exit 1
  fi
fi

# 2. 临时目录 + trap
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/preserved"

# 3. 保留 PRESERVE_DIRS
for d in "${PRESERVE_DIRS[@]}"; do
  if [ -d "$DOCS_DIR/$d" ]; then
    mv "$DOCS_DIR/$d" "$TMP_DIR/preserved/$d"
    echo "保留 docs/$d"
  fi
done

# 4-5. 浅克隆上游 + 去 .git
echo "克隆 $UPSTREAM_URL ($UPSTREAM_REF) ..."
git clone --depth=1 --branch "$UPSTREAM_REF" "$UPSTREAM_URL" "$TMP_DIR/upstream"
rm -rf "$TMP_DIR/upstream/.git"

# 6-7. 重置本地 docs/，拷贝上游
rm -rf "$DOCS_DIR"
mkdir -p "$DOCS_DIR"
cp -R "$TMP_DIR/upstream/." "$DOCS_DIR/"

# 8. 恢复 PRESERVE_DIRS
for d in "${PRESERVE_DIRS[@]}"; do
  if [ -d "$TMP_DIR/preserved/$d" ]; then
    mv "$TMP_DIR/preserved/$d" "$DOCS_DIR/$d"
    echo "恢复 docs/$d"
  fi
done

# 9. 叠加 docs-overrides/
if [ -d "$OVERRIDES_DIR" ] && [ -n "$(ls -A "$OVERRIDES_DIR" 2>/dev/null || true)" ]; then
  echo "叠加 docs-overrides/ ..."
  cp -R "$OVERRIDES_DIR/." "$DOCS_DIR/"
fi

echo "同步完成。请运行 'git diff --stat docs/' 检查变更后提交。"
