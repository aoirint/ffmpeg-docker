# Third-Party Notices

This project builds Docker images that include third-party software.

## Software bundled in images

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

### Other linked libraries

Source versions and build options are defined in [Dockerfile](Dockerfile).
The runtime image retains the following notices under `/usr/local/share/licenses/`:

| Library | Source | License | Notice |
| --- | --- | --- | --- |
| x264 | <https://code.videolan.org/videolan/x264> | GPL-2.0-or-later | `x264/COPYING` |
| LAME | <https://sourceforge.net/projects/lame/> | LGPL-2.0-or-later | `lame/COPYING` |
| Opus | <https://github.com/xiph/opus> | BSD-3-Clause | `opus/COPYING` |
| SVT-AV1 | <https://gitlab.com/AOMediaCodec/SVT-AV1> | BSD-3-Clause-Clear | `svtav1/LICENSE.md` |
| dav1d | <https://code.videolan.org/videolan/dav1d> | BSD-2-Clause | `dav1d/COPYING` |
| VMAF | <https://github.com/Netflix/vmaf> | BSD-2-Clause Plus Patent | `vmaf/LICENSE` |
| nv-codec-headers (NVIDIA variant) | <https://github.com/FFmpeg/nv-codec-headers> | MIT | `nv-codec-headers/*.h.txt` (header notices) |

Ubuntu runtime packages, including x265, retain their package copyright files under
`/usr/share/doc/`. Static archives and development headers are confined to build stages.
CUDA and cuDNN are not bundled in the runtime image; NVIDIA driver libraries are supplied
by the host container runtime.

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
