# Repository Instructions

## Verifying Swift package changes

Run `swift test --filter '<test suite or method name>'` from the repository root for focused changes. Run `swift build` and `swift test` for cross-cutting changes or release preparation. The StoreKit purchase and restore tests require a configured Xcode host. See [the demo testing guide](Demo/README.md#purchase-engine-m1-and-tip-jar-ui-m3).

## Publishing a release

Whenever publishing a new version:

1. Update `CHANGELOG.md` before creating or pushing the version tag.
2. Move every change included in the release from `Unreleased` into a section headed `## [X.Y.Z] - YYYY-MM-DD` with the exact tag version and release date.
3. Update documented current-version and installation references.
4. From the repository root, run `python3 scripts/release_notes.py vX.Y.Z` with the intended version and review its output. The [tag release workflow](.github/workflows/release.yml) uses the same validator.
5. Publish the tag only after validation succeeds and the notes describe every included user-facing change.
