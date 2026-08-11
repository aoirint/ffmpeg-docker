# Third-Party Notices

This project builds Docker images that include third-party software.

## FFmpeg

- Upstream source: <https://github.com/FFmpeg/FFmpeg>
- Fork source: <https://github.com/aoirint/FFmpeg>
- Bundled location in image: `/usr/local/bin` and `/usr/local/lib`
- Version: see `FFMPEG_VERSION` in `Dockerfile` and `ffmpeg_version` in
  `.github/workflows/main.yml`
- License for this build configuration: GNU General Public License version 3
  or later
- Upstream license information: <https://ffmpeg.org/legal.html>

The `ubuntu` and `nvidia` variants build the selected upstream FFmpeg tag. The
`ubuntu-aoirint` variant builds the corresponding fork tag with the
`rtmp_strict_paths` patch. The image retains `LICENSE.md` and `COPYING.GPLv3`
under `/usr/local/share/licenses/ffmpeg/`.

## aoirint/skills

- Source: <https://github.com/aoirint/skills>
- Virtual paths: `apm-workflow`, `changelog-workflow`, `code-quality-check`,
  `commit-message-quality-check`, `docker-quality-check`,
  `git-worktree-workflow`, `github-actions-quality-check`, `github-workflow`,
  `prose-quality-check`, `security-check`, and
  `software-documentation-maintenance`
- Commit: `f4aa56f4abffb1448c24c04ea4ae4463f5721d10`
- License: MIT, <https://github.com/aoirint/skills/blob/f4aa56f4abffb1448c24c04ea4ae4463f5721d10/LICENSE>
- Copyright: Copyright (c) 2026 aoirint

The full license text is available at the linked canonical source. This notice
retains the supplied copyright attribution for the deployed Skill copies.
