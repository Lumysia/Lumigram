#!/bin/bash
# Fails when a built IPA still mentions a host this fork removed. Swift keeps
# literals of up to 15 bytes inside instructions, so only longer ones show here.
set -euo pipefail

ipa="$1"
patterns=(
  'api\.swiftgram\.app'
  'my\.swiftgram\.app'
  'translate\.goo'
  'gleapis\.com/transl'
  'raw\.githubusercontent\.com/Swiftgram'
  'Swiftgram/settings'
)

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
unzip -q "$ipa" -d "$work"

found=0
while IFS= read -r -d '' file; do
  text="$(strings -a "$file")"
  for pattern in "${patterns[@]}"; do
    if grep -Eq "$pattern" <<< "$text"; then
      echo "::error::${file#"$work"/} contains $pattern"
      found=1
    fi
  done
done < <(find "$work/Payload" -type f -print0)

[ "$found" -eq 0 ] && echo "No removed host found in $(basename "$ipa")."
exit "$found"
