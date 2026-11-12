#!/bin/sh
# Applies the patch series in patches/ onto a pristine gpu-screen-recorder-official tree.
# Any local changes and previous applications of the series in the tree are discarded.
set -e

cd "$(dirname "$0")/.."
ROOT="$(pwd)"
REPO="$ROOT/gpu-screen-recorder-official"
BASE="$(sed -n 's/^.*commit[^0-9a-f]*\([0-9a-f]\{7,40\}\).*/\1/p' "$ROOT/UPSTREAM.md" | head -1)"
BRANCH="patched/v4l2-webp"

if [ ! -d "$REPO/.git" ]; then
    echo "error: $REPO is not a git repository. Clone upstream first:" >&2
    echo "  git clone https://repo.dec05eba.com/gpu-screen-recorder gpu-screen-recorder-official" >&2
    exit 1
fi

if [ -z "$BASE" ]; then
    echo "error: could not determine the base commit from UPSTREAM.md" >&2
    exit 1
fi

cd "$REPO"
git checkout -- .
git clean -fdq
git checkout -B "$BRANCH" "$BASE"
git am "$ROOT"/patches/*.patch

echo
echo "Patch series applied. Branch state:"
git --no-pager log --oneline "$BASE..HEAD"
