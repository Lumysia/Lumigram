#!/bin/bash
# During a conflicted merge, keeps this fork's side of the files listed in
# .github/fork-owned-files (its version, or its deletion). Exits 1 while
# other conflicts remain.
set -euo pipefail

git rev-parse -q --verify MERGE_HEAD > /dev/null || exit 1

mapfile -t owned < <(grep -v '^\s*#' .github/fork-owned-files | sed '/^\s*$/d')
is_owned() {
  local path="$1" item
  for item in "${owned[@]}"; do [ "$item" = "$path" ] && return 0; done
  return 1
}

while IFS= read -r path; do
  is_owned "$path" || continue
  if git cat-file -e "HEAD:$path" 2>/dev/null; then
    git checkout --ours -- "$path"
    git add -- "$path"
  else
    git rm --quiet --cached -- "$path"
    rm -f -- "$path"
  fi
done < <(git diff --name-only --diff-filter=U)

[ -z "$(git diff --name-only --diff-filter=U)" ]
