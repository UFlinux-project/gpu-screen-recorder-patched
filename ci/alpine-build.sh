#!/bin/sh
# Builds the patched gpu-screen-recorder on Alpine Linux and smoke-tests the binaries.
# Runs as root inside a fresh alpine container with this repository as the working
# directory (see .github/workflows/alpine.yml).
set -eu

apk add --no-cache \
    build-base \
    meson \
    ninja \
    pkgconfig \
    git \
    vulkan-headers \
    ffmpeg-dev \
    libx11-dev \
    libxcomposite-dev \
    libxrandr-dev \
    libxfixes-dev \
    libxdamage-dev \
    wayland-dev \
    libdrm-dev \
    dbus-dev \
    pulseaudio-dev \
    libva-dev \
    libcap-dev \
    mesa-dev \
    pipewire-dev \
    libwebp-dev

# git am in scripts/apply-patches.sh needs a committer identity
git config --global user.email "ci@uflinux.project"
git config --global user.name "CI"

uname -m
echo "==> Cloning upstream gpu-screen-recorder"
git clone --quiet https://repo.dec05eba.com/gpu-screen-recorder gpu-screen-recorder-official

echo "==> Applying patch series"
./scripts/apply-patches.sh

echo "==> Building"
cd gpu-screen-recorder-official
meson setup build --buildtype=release
ninja -C build

echo "==> Checking shared library dependencies"
for bin in gpu-screen-recorder gsr-kms-server gsr-cli; do
    test -x "build/$bin" || { echo "error: build/$bin missing" >&2; exit 1; }
    if ldd "build/$bin" 2>&1 | grep 'not found'; then
        echo "error: unresolved libraries for $bin" >&2
        exit 1
    fi
done

echo "==> Smoke tests"
# gpu-screen-recorder refuses to run as the root user, so test as an unprivileged user
adduser -D -h /tmp tester
su -s /bin/sh tester -c "build/gpu-screen-recorder --version"
build/gsr-cli --help > /dev/null

echo "==> OK"
