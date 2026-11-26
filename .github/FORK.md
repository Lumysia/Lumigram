# Lumigram

Lumigram is [Swiftgram](https://github.com/Swiftgram/Telegram-iOS) with everything that talked to Swiftgram's own
services taken out. It still uses the Telegram API, like any Telegram client.

What is different, one commit each on top of Swiftgram:

- No Swiftgram server: no Mini App token from the Swiftgram bot at launch, no settings fetched from or posted to
  api.swiftgram.app. Settings live on the device.
- No in-app purchase, receipt upload or bot status query. Pro features are not part of this build.
- Registration dates are estimated on the device from public id/date anchors instead of a server lookup per profile.
- No announcements or strings downloaded from GitHub; the bundled strings are used.
- Translation runs on the device (Apple's Translation framework, iOS 18 and later) by default. Telegram's own service
  can be picked in settings. Nothing is sent to Google.
- The app name comes from `app_name` in the build configuration.

## Builds

- `lumigram-build.yml` builds the app, checks that the removed hosts are gone from the binary and uploads it to
  TestFlight. It reads its configuration and signing material from repository secrets; it has no pull request trigger.
- `lumigram-sync.yml` runs daily: it merges the newest Swiftgram `release/*` branch into `main` and starts a build.
  A merge that needs a person opens an issue labelled `sync-conflict`.
