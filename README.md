# Lumigram

Lumigram is an unofficial Telegram client for iOS. It is built on [Swiftgram](https://github.com/Swiftgram/Telegram-iOS),
which in turn is built on [Telegram for iOS](https://github.com/TelegramMessenger/Telegram-iOS), and it uses the
Telegram API like every Telegram app.

It keeps Swiftgram's features that work on the device and removes the parts that talk to Swiftgram's own services:

- No Swiftgram server. The app doesn't ask the Swiftgram bot for a login token at launch, doesn't fetch or upload
  settings, and doesn't unblock the bot if you blocked it. Settings stay on the phone.
- Registration dates are estimated on the device from public user id and date anchors
  ([GetIDs bot data](https://github.com/wjclub/telegram-bot-getids), MIT). Opening a profile sends nothing anywhere.
- Translation uses Apple's on-device Translation framework (iOS 18 and later) by default. Telegram's own translation
  can be chosen in settings. Message text is never sent to Google.
- No announcements or translation strings downloaded from GitHub. The app uses the strings it ships with.
- No in-app purchases, receipt uploads or subscription status checks.
- Passkey sign-in and setup are hidden unless the app's entitlements list a `webcredentials` domain. Swiftgram
  sends passkeys to its own domain, which only works for Swiftgram's app.

Each of these is a separate commit on top of Swiftgram, so they carry over to new Swiftgram releases with few conflicts.

## Branches

- `main` holds the Lumigram commits (the changes above, plus these docs and CI) on the Swiftgram release they were
  last rebased onto. Changes go here.
- `lumigram/X.Y` is Swiftgram's `release/X.Y` with the commits of `main` replayed on top. These branches are generated
  by CI and force-pushed; don't commit to them.
- `vX.Y-N` tags mark builds: Swiftgram's version X.Y and build number N.

## Building

Lumigram builds like Telegram for iOS: with Bazel, through `build-system/Make/Make.py`, on macOS with the Xcode
version in `versions.json`.

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
team id. `app_name` sets the name shown on the home screen; it defaults to `Swiftgram`. `associated_domains` is an
optional list of entitlement entries such as `webcredentials:example.com`; a `webcredentials` domain that serves an
`apple-app-site-association` file for your app turns passkeys on.

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

`.github/workflows/lumigram-build.yml` does the same on GitHub's `xcode-27` runner and checks the built app for the
removed Swiftgram hosts and for leftover "Swiftgram" names.

`.github/workflows/lumigram-sync.yml` runs every six hours and on each push to `main`. It replays `main` onto the
newest Swiftgram release branch with `.github/scripts/replay-series.sh`. If that gives a new commit, it pushes it to
`lumigram/X.Y`, builds it and tags the build. The replay keeps each commit's author, committer and dates, so the same
inputs always give the same commit and an unchanged result means there's nothing to build. A replay that conflicts
outside `.github/fork-owned-files` opens an issue labelled `sync-conflict`. To fix it, rebase `main` onto the new
release and force-push `main`.

To replay locally:

```
git remote add swiftgram https://github.com/Swiftgram/Telegram-iOS.git
git fetch swiftgram 'refs/heads/release/*:refs/remotes/swiftgram/release/*'
.github/scripts/replay-series.sh swiftgram/release/X.Y main
```

### Troubleshooting

If Xcode waits on "build-request.json not updated yet", cancel the build and start it again.

If the generated project fails with "Telegram_xcodeproj: no such package" after a restart, generate the project again.

## License

Telegram for iOS is licensed under the GNU General Public License v2.0 or later, and so are Swiftgram and Lumigram.
See [LICENSE](LICENSE). Credit for nearly all of this code goes to the Telegram and Swiftgram developers; bundled
third-party libraries keep their own licenses.
