# Third-Party Notices

This project builds Docker images that include third-party software.

## Software bundled in images

Library source versions and build options are defined in [Dockerfile](Dockerfile).
Static archives and development headers are confined to build stages.

### FFmpeg

- Upstream source: <https://github.com/FFmpeg/FFmpeg>
- Fork source: <https://github.com/aoirint/FFmpeg>
- Bundled location in runtime image: `/usr/local/bin`
- Version: see `FFMPEG_VERSION` in `Dockerfile` and `ffmpeg_version` in
  `.github/workflows/main.yml`
- License for this build configuration: GNU General Public License version 3
  or later
- Upstream license information: <https://ffmpeg.org/legal.html>

The `ubuntu` and `nvidia` variants build the selected upstream FFmpeg commit. The
`ubuntu-aoirint` variant builds the corresponding fork commit with the
`rtmp_strict_paths` patch. The image retains `LICENSE.md` and `COPYING.GPLv3`
under `/usr/local/share/licenses/ffmpeg/`.

### libvpx

- Version: 1.17.0
- License: BSD-3-Clause and patent grant,
  <https://chromium.googlesource.com/webm/libvpx/+/refs/tags/v1.17.0/LICENSE>.
- Bundled location: statically linked into FFmpeg; `LICENSE` and `PATENTS` are retained in
  `/usr/local/share/licenses/libvpx/`.

### libaom

- Version: 3.15.0
- License: BSD-2-Clause and patent grant,
  <https://aomedia.googlesource.com/aom/+/refs/tags/v3.15.0/LICENSE>.
- Bundled location: statically linked into FFmpeg; `LICENSE` and `PATENTS` are retained in
  `/usr/local/share/licenses/libaom/`.

### libass

- Version: 0.17.5
- License: ISC,
  <https://github.com/libass/libass/blob/0.17.5/COPYING>.
- Bundled location: statically linked into FFmpeg; `COPYING` is retained in
  `/usr/local/share/licenses/libass/`.

### x264

- Source: <https://code.videolan.org/videolan/x264>
- License: GPL-2.0-or-later
- Bundled location: statically linked into FFmpeg; CLI at `/usr/local/bin/x264`.
- Notice: `/usr/local/share/licenses/x264/COPYING`

### LAME

- Source: <https://sourceforge.net/projects/lame/>
- License: LGPL-2.0-or-later
- Bundled location: statically linked into FFmpeg; CLI at `/usr/local/bin/lame`.
- Notice: `/usr/local/share/licenses/lame/COPYING`

### Opus

- Source: <https://github.com/xiph/opus>
- License: BSD-3-Clause
- Bundled location: statically linked into FFmpeg.
- Notice: `/usr/local/share/licenses/opus/COPYING`

### SVT-AV1

- Source: <https://gitlab.com/AOMediaCodec/SVT-AV1>
- License: BSD-3-Clause-Clear
- Bundled location: statically linked into FFmpeg.
- Notice: `/usr/local/share/licenses/svtav1/LICENSE.md`

### dav1d

- Source: <https://code.videolan.org/videolan/dav1d>
- License: BSD-2-Clause
- Bundled location: statically linked into FFmpeg.
- Notice: `/usr/local/share/licenses/dav1d/COPYING`

### VMAF

- Source: <https://github.com/Netflix/vmaf>
- License: BSD-2-Clause Plus Patent
- Bundled location: statically linked into FFmpeg; CLI at `/usr/local/bin/vmaf`.
- Notice: `/usr/local/share/licenses/vmaf/LICENSE`

### nv-codec-headers

- Source: <https://github.com/FFmpeg/nv-codec-headers>
- License: MIT
- Build role: headers used to compile the NVIDIA variant.
- Notice: header notices retained as `/usr/local/share/licenses/nv-codec-headers/*.h.txt`.

CUDA and cuDNN are not bundled in the runtime image; NVIDIA driver libraries are supplied
by the host container runtime.

### Ubuntu runtime packages

Ubuntu runtime packages, including x265, retain their package copyright files under
`/usr/share/doc/`.

## Development dependencies

### aoirint/skills

- Source: <https://github.com/aoirint/skills>
- Virtual paths: `apm-workflow`, `changelog-workflow`, `code-quality-check`,
  `commit-message-quality-check`, `docker-quality-check`,
  `git-worktree-workflow`, `github-actions-quality-check`, `github-workflow`,
  `prose-quality-check`, `security-check`, and
  `domain-architecture-docs-workflow`
- Commit: `0e41c088efb2bdf44ca58564bb5168d119ac9135`
- License: MIT, <https://github.com/aoirint/skills/blob/0e41c088efb2bdf44ca58564bb5168d119ac9135/LICENSE>
- Copyright: Copyright (c) 2026 aoirint

The full license text is available at the linked canonical source. This notice
retains the supplied copyright attribution for the deployed Skill copies.
