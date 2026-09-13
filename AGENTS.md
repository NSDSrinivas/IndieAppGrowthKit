# Repository Instructions

## Publishing a release

Whenever publishing a new version:

1. Update `CHANGELOG.md` before creating or pushing the version tag.
2. Move every change included in the release from `Unreleased` into a dated section whose version exactly matches the tag without its `v` prefix.
3. Update documented current-version and installation references.
4. Verify that `.github/workflows/release.yml` can extract non-empty notes for the version.
5. Do not publish the tag if its changelog section is missing, empty, or does not describe every included user-facing change.
