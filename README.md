# Lumigram

Lumigram is an unofficial Telegram client for iOS: [Telegram for iOS](https://github.com/TelegramMessenger/Telegram-iOS)
with a few changes of our own, kept small so it can follow every Telegram release. Everything stays on the device: no
servers of our own, no accounts, no purchases.

## What's different

- Its own name, icons and intro.
- Chats and voice messages are translated and transcribed on the device, without Premium.
- A Lumigram page in Settings with a handful of options: seconds in message times, send with Return, the deletion
  animation, hiding the stories bar, IDs and mutual contacts on profiles, quieter notifications, link previews and
  asking before calls.
- Passkeys work with Lumigram's own domain.

Lumigram doesn't try to match other clients feature for feature. Options that would need bigger changes inside
Telegram's code are left out, because each one makes following Telegram slower; the code's own history has the
ones we tried and dropped.

## Releases

There is one Lumigram release per Telegram release on the App Store. Telegram publishes the source of each App Store
version as a `release-X.Y` tag, usually within a couple of days; `.github/workflows/lumigram-sync.yml` checks the
App Store daily, takes the newest tag at or below its version and replays `main` onto it with
`.github/scripts/replay-series.sh`. The result is `lumigram/X.Y`, which CI builds and uploads to TestFlight. Pushes
to `main` are built the same way, on the current release.

- `main` holds the Lumigram commits on the upstream release they were last rebased onto. Changes go here.
- `lumigram/X.Y` is upstream `release-X.Y` with the commits of `main` replayed on top. CI generates and
  force-pushes it; don't commit to it.
- `vX.Y-N` tags mark builds (Telegram's version X.Y, build number N); `vX.Y` marks the release build of X.Y.
- `swiftgram/*` keeps the earlier Lumigram, which was based on Swiftgram.

The replay keeps each commit's author, committer and dates, so the same inputs give the same commit and nothing is
built twice. A replay that conflicts outside `.github/fork-owned-files` opens an issue labelled `sync-conflict`; to
fix it, rebase `main` onto the new release tag and force-push `main`.

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
TestFlight. Before the app, it compiles the libraries that changed since the newest build
(`.github/scripts/compile-check-targets.py`), so a compile error shows up within minutes.

To replay locally:

```
git remote add upstream https://github.com/TelegramMessenger/Telegram-iOS.git
git fetch upstream master tag release-X.Y
.github/scripts/replay-series.sh release-X.Y main
```

### Troubleshooting

If Xcode waits on "build-request.json not updated yet", cancel the build and start it again.

If the generated project fails with "Telegram_xcodeproj: no such package" after a restart, generate the project again.

## License

Telegram for iOS is licensed under the GNU General Public License v2.0 or later, and so is Lumigram. See
[LICENSE](LICENSE). Credit for nearly all of this code goes to the Telegram developers; bundled
third-party libraries keep their own licenses.
