# Upstream base

This patch series is based on **GPU Screen Recorder v6.1.7**, upstream commit:

    upstream commit: 6da8168b693186a54e5ee7d0ecbd3a92a1127882
    repository:      https://repo.dec05eba.com/gpu-screen-recorder

The pristine upstream checkout lives in `gpu-screen-recorder-official/` (kept on the
base commit; the patch series is applied on top of it by `scripts/apply-patches.sh`).

# Patch series

| Patch | Description |
|-------|-------------|
| 0001 | Add V4L2 mem2mem codec capability probe |
| 0002 | Add V4L2 mem2mem video encoder backend |
| 0003 | Build: add v4l2_encoder option and ffmpeg v4l2m2m support |
| 0004 | Add v4l2 video codec, encoder and -v4l2-device option |
| 0005 | Wire v4l2 mem2mem encoder into codec selection |
| 0006 | Wire v4l2 mem2mem encoder into the codec open path |
| 0007 | --info: report v4l2 mem2mem encoders |
| 0008 | Add webp screenshot support |
| 0009 | Docs: document v4l2 encoder and webp screenshots |

Patches 0001-0003 add the standalone v4l2 pieces (probe, encoder backend, build wiring).
Patches 0004-0007 integrate them into codec selection, the codec open path and `--info`.
Patch 0008 (webp screenshots) is independent of the v4l2 work. Patch 0009 only touches docs.

# Updating to a new upstream version

1. Fetch the new upstream release into `gpu-screen-recorder-official`:
   `git -C gpu-screen-recorder-official fetch origin <new-tag-or-commit>`
2. Check out the new base: `git -C gpu-screen-recorder-official checkout --detach <new-base>`
3. Re-apply the series: `git -C gpu-screen-recorder-official am < patches/*.patch`
   (or `git checkout -b patched/v4l2-webp <new-base> && git am ../patches/*.patch`)
4. Resolve conflicts. The patch most likely to conflict is 0005, which modifies
   `select_video_codec_with_fallback` in `src/recorder/codec_select.c` — the largest
   upstream function touched by the series. All other patches are either additive
   (new files, new switch cases, new options) or touch small, stable functions.
5. Update the base commit recorded above.
6. Regenerate the series if you rebased on a working branch: `./scripts/make-patches.sh`

When upstream adds a new video codec or encoder backend, mirror what the corresponding
`*_vulkan` entries do — the v4l2 entries deliberately follow the vulkan pattern
(`video_codec_is_v4l2` mirrors `video_codec_is_vulkan`).
