# Working on Lumigram

Lumigram is Telegram for iOS plus a small set of our own features. Upstream (TelegramMessenger/Telegram-iOS) moves
fast, so every change is written to survive the next upstream release with as few conflicts as possible. Read the
root `CLAUDE.md` for how Telegram's code is built and organised.

- Feature code lives in modules under `Lumigram/`, never inside `submodules/`. `LumigramCore` has no dependencies:
  the settings store `LumigramSettings` (one UserDefaults key per setting, in the app group; nothing in Postbox) and
  small pure helpers. Low-level Telegram modules and the notification service import it, so it changes only when a
  setting is added. Everything else, including anything that needs Telegram's modules, goes in `LumigramUI`, which
  only `TelegramUI` and `PeerInfoScreen` import.
- A change inside Telegram's code is a hook of one to five lines that calls into our modules, marked
  `// MARK: Lumigram` (or `# MARK: Lumigram` in BUILD files). `git grep "MARK: Lumigram"` lists every hook.
- Following Telegram comes before features. A feature that needs bigger hooks, several hooks across Telegram's
  modules, or `LumigramUI` imported by another Telegram module isn't worth carrying.
- No Postbox schema changes, and nothing restored that upstream deleted.
- A new setting is a `LumigramSettings.Key` plus a row in `LumigramUI`'s section list. Every option does something;
  no placeholders.
- Text a user sees goes through `LumigramStrings` with English and Chinese.
- Telegram's API terms apply: no ghost mode or read-state tampering, nothing that keeps self-destructing or deleted
  content, sponsored messages stay, no Telegram logo, no "Telegram" in the app name.
- One feature per commit, Conventional Commits, English. Before pushing, check every changed call site against the
  real upstream signatures: CI is the only compiler and a full build takes over an hour.
- Comments only for a reason the code can't show.
