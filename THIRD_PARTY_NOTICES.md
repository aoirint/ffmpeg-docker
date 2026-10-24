# Third-Party Notices

This project builds Docker images that include third-party software.

## Software bundled in images

### FFmpeg

- Upstream source: <https://github.com/FFmpeg/FFmpeg>
- Fork source: <https://github.com/aoirint/FFmpeg>
- Bundled location in image: `/usr/local/bin` and `/usr/local/lib`
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
- Bundled location: static library in `/usr/local/lib`; `LICENSE` and `PATENTS` are retained in
  `/usr/local/share/licenses/libvpx/`.

### libaom

- Version: 3.15.0
- License: BSD-2-Clause and patent grant,
  <https://aomedia.googlesource.com/aom/+/refs/tags/v3.15.0/LICENSE>.
- Bundled location: static library in `/usr/local/lib`; `LICENSE` and `PATENTS` are retained in
  `/usr/local/share/licenses/libaom/`.

### libass

- Version: 0.17.5
- License: ISC,
  <https://github.com/libass/libass/blob/0.17.5/COPYING>.
- Bundled location: static library in `/usr/local/lib`; `COPYING` is retained in
  `/usr/local/share/licenses/libass/`.

Library source commits and build options are defined in [Dockerfile](Dockerfile).

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
