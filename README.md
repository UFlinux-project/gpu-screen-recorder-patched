# gpu-screen-recorder-patched

GPU screen recorder with patches for uflinux and exotic systems.

[GPU Screen Recorder](https://github.com/dec05eba/gpu-screen-recorder) with a patch series that
adds support for single board computers and other "exotic" devices, plus webp screenshots.

The patches are maintained as a git patch series (`patches/`) on top of a pinned upstream
release — see [UPSTREAM.md](./UPSTREAM.md) for the base commit and the update procedure.

## What the patches add

### V4L2 mem2mem hardware encoding (`-encoder v4l2`)

Devices like the Raspberry Pi, Radxa Dragon or other Rockchip boards have no GPU-accelerated
encoder (no nvenc/vaapi/vulkan); their hardware encoders are exposed as **V4L2 mem2mem**
devices (`/dev/videoN`, e.g. the `bcm2835-codec` or `rkvenc` drivers). The patch series adds
an encoder backend that uses ffmpeg's `h264_v4l2m2m`/`hevc_v4l2m2m` encoders, working the same
way as the existing GPU-specific backends:

* Frames are converted to NV12 on the GPU and uploaded to the encoder (CPU copy; a
  `TODO(dmabuf)` seam is left for a zero-copy path).
* Only h264 and hevc are supported (that is all v4l2m2m encoders on these boards provide).
* Selection behavior:
  * `-encoder v4l2` uses the v4l2 encoder explicitly (`-v4l2-device /dev/video11` pins the
    node; otherwise the first encoder node found is used, same as ffmpeg).
  * With no `-encoder` flag, the v4l2 encoder is used **automatically only when no official
    backend (nvenc/vaapi/vulkan) is usable** and a supported v4l2 encoder node exists.
  * `-encoder cpu` and `-fallback-cpu-encoding` keep working as before.
* `gpu-screen-recorder --info` lists `h264_v4l2`/`hevc_v4l2` when a v4l2 encoder is present.

Note: pinning a device with `-v4l2-device` requires ffmpeg with the small `video_device`
option patch included in this repo (applied automatically with `-Dffmpeg_static=true`);
with an unpatched system ffmpeg the first encoder node is always used and a warning is logged.

### WebP screenshots

`gpu-screen-recorder -w screen -o screenshot.webp` saves a webp screenshot. libwebp
(`libwebp.so.7`) is loaded at runtime, like libturbojpeg is for jpeg; there is no fallback,
so webp fails with a clear error when libwebp is not installed.

## Repository layout

```
patches/                       the patch series (git format-patch)
gpu-screen-recorder-official/  pristine upstream checkout (see UPSTREAM.md for the base commit)
scripts/apply-patches.sh       reset the tree and apply the series with git am
scripts/make-patches.sh        regenerate patches/ from a working branch
scripts/build.sh               apply the series and build with meson
```

## Usage

Apply the series and build:

```sh
./scripts/build.sh                       # system ffmpeg
./scripts/build.sh -Dffmpeg_static=true  # bundled ffmpeg (includes the video_device patch)
```

Or apply the patches yourself onto any upstream checkout of the pinned version:

```sh
git am patches/*.patch
```

Both features can be disabled at build time with `-Dv4l2_encoder=false` and
`-Dwebp_screenshots=false`.

## Runtime requirements

* ffmpeg with the v4l2m2m encoders (any distro ffmpeg built with `--enable-v4l2-m2m`;
  Debian/Ubuntu and Fedora builds have it) — only needed for recording on v4l2-encoding boards.
* libwebp — only needed for webp screenshots.
