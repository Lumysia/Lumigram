# Lumigram

Lumigram is an unofficial Telegram client for iOS, built on [Telegram for iOS](https://github.com/TelegramMessenger/Telegram-iOS)
and the Telegram API. Its own features live in their own modules under `Lumigram/`, hooked into Telegram's code with
small marked changes, and everything stays on the device: no servers of our own, no accounts, no purchases.

## Branches

- `main` holds the Lumigram commits on the upstream commit they were last rebased onto. Changes go here.
- `lumigram/X.Y` is upstream `master` at Telegram version X.Y with the commits of `main` replayed on top. CI generates
  and force-pushes these branches; don't commit to them.
- `vX.Y-N` tags mark builds: Telegram's version X.Y and build number N.
- `swiftgram/*` keeps the earlier Lumigram, which was based on Swiftgram.

## Building

Lumigram builds like Telegram for iOS: with Bazel, through `build-system/Make/Make.py`, on macOS with the Xcode
version in `versions.json`. `build-system/lumigram-configuration.json` is the configuration CI uses; the values in
`${...}` come from repository secrets.

### Before you start

1. [Get your own api_id](https://core.telegram.org/api/obtaining_api_id). Telegram's sample id only works for testing.
2. Telegram asks third-party apps not to use "Telegram" in their name and not to use its paper plane logo.
3. Read Telegram's [security guidelines](https://core.telegram.org/mtproto/security_guidelines).
4. If you publish an app built from this code, publish your source too (see License).

### Get the code

```
git clone --recursive -j8 https://github.com/Lumysia/Lumigram.git
```

### Configuration

Copy `build-system/template_minimal_development_configuration.json` and fill in your bundle id, api_id, api_hash and
team id. `app_name` sets the name shown on the home screen; it defaults to `Telegram`.

### Xcode project

```
python3 build-system/Make/Make.py \
    --cacheDir="$HOME/telegram-bazel-cache" \
    generateProject \
    --configurationPath=path/to/configuration.json \
    --xcodeManagedCodesigning
```

For a simulator-only build add `--disableProvisioningProfiles`; no code signing is needed then.

### IPA

Create provisioning profiles for the app and its extensions (`build-system/fake-codesigning/profiles` lists them and
their entitlements), put them with your certificates in a codesigning folder, then run:

```
python3 build-system/Make/Make.py \
    --cacheDir="$HOME/telegram-bazel-cache" \
    build \
    --configurationPath=path/to/configuration.json \
    --codesigningInformationPath=path/to/codesigning \
    --buildNumber=100001 \
    --configuration=release_arm64
```

`.github/workflows/lumigram-build.yml` does the same on GitHub's `xcode-27` runner and uploads the result to
TestFlight. Before the app, it compiles the libraries that changed
since the newest release tag (`.github/scripts/compile-check-targets.py`), so a compile error shows up within minutes.

`.github/workflows/lumigram-sync.yml` runs every six hours and on each push to `main`. It replays `main` onto the
upstream `master` with `.github/scripts/replay-series.sh`. If that gives a new commit, it pushes it to
`lumigram/X.Y`, builds it and tags the build. The replay keeps each commit's author, committer and dates, so the same
inputs always give the same commit and an unchanged result means there's nothing to build. A replay that conflicts
outside `.github/fork-owned-files` opens an issue labelled `sync-conflict`. To fix it, rebase `main` onto upstream
`master` and force-push `main`.

To replay locally:

```
git remote add upstream https://github.com/TelegramMessenger/Telegram-iOS.git
git fetch upstream master
.github/scripts/replay-series.sh upstream/master main
```

### Troubleshooting

If Xcode waits on "build-request.json not updated yet", cancel the build and start it again.

If the generated project fails with "Telegram_xcodeproj: no such package" after a restart, generate the project again.

## License

Telegram for iOS is licensed under the GNU General Public License v2.0 or later, and so is Lumigram. See
[LICENSE](LICENSE). Credit for nearly all of this code goes to the Telegram developers; bundled
third-party libraries keep their own licenses.
