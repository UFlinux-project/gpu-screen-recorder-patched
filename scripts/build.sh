#!/bin/sh
# Applies the patch series and builds the result.
# Extra arguments are passed to `meson setup`, e.g.:
#   ./scripts/build.sh -Dffmpeg_static=true
set -e

cd "$(dirname "$0")/.."
./scripts/apply-patches.sh

cd gpu-screen-recorder-official
rm -rf build
meson setup build --buildtype=release "$@"
meson compile -C build

echo
echo "Built: $(pwd)/build/gpu-screen-recorder"
