#!/bin/sh
# Regenerates the patch series in patches/ from the working branch in gpu-screen-recorder-official.
# Run this after amending/adding commits on the patched branch (see UPSTREAM.md).
set -e

cd "$(dirname "$0")/.."
ROOT="$(pwd)"
REPO="$ROOT/gpu-screen-recorder-official"
BASE="$(sed -n 's/^.*commit[^0-9a-f]*\([0-9a-f]\{7,40\}\).*/\1/p' UPSTREAM.md | head -1)"
BRANCH="${1:-patched/v4l2-webp}"

if [ -z "$BASE" ]; then
    echo "error: could not determine the base commit from UPSTREAM.md" >&2
    exit 1
fi

cd "$REPO"
if ! git rev-parse --verify --quiet "$BRANCH" >/dev/null; then
    echo "error: branch $BRANCH not found in $REPO" >&2
    exit 1
fi

rm -f "$ROOT"/patches/*.patch
git format-patch "$BASE..$BRANCH" -o "$ROOT/patches/"
echo "Patch series regenerated in patches/:"
ls "$ROOT"/patches/
