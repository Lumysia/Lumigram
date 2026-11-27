#!/bin/bash
# Replays this fork's patch series (the commits of SERIES_TIP that no Swiftgram
# branch has) onto UPSTREAM_REF and leaves HEAD detached at the result.
#
# Each commit keeps its author and committer, so the same upstream tip and the
# same series always give the same commit ids: an unchanged result means there
# is nothing new to build. A conflict over a file the fork deleted, or one listed
# in .github/fork-owned-files, keeps the fork's side; any other conflict stops
# with exit 1 and the conflicting files on stdout. Other failures exit with
# another non-zero code. Replayed commits are never signed, so a local replay
# gives the same ids as CI.
#
# Usage: replay-series.sh UPSTREAM_REF SERIES_TIP
set -euo pipefail

upstream="$1"
tip="$2"
owned_list="$(git show "$tip:.github/fork-owned-files" | grep -v '^\s*#' | sed '/^\s*$/d')"

is_owned() {
  local path="$1" item
  while IFS= read -r item; do
    # Entries are shell patterns: * matches any characters, / included.
    # shellcheck disable=SC2053
    [[ "$path" == $item ]] && return 0
    # shellcheck disable=SC2295
    [[ "$item" == */ && "$path" == $item* ]] && return 0
  done <<< "$owned_list"
  return 1
}

keep_fork_side() {
  local commit="$1" path conflicted
  # Read the list first: a git diff running alongside git add would race for index.lock.
  mapfile -t conflicted < <(git diff --name-only --diff-filter=U)
  for path in "${conflicted[@]}"; do
    if ! git cat-file -e "$commit:$path" 2>/dev/null; then
      git rm --quiet -- "$path" 2>/dev/null || git rm --quiet --cached -- "$path"
    elif is_owned "$path"; then
      git checkout --theirs -- "$path"
      git add -- "$path"
    fi
  done
}

mapfile -t series < <(git rev-list --reverse --no-merges "$tip" --not --remotes=swiftgram)
[ "${#series[@]}" -gt 0 ] || { echo "No fork commits found on $tip." >&2; exit 2; }

git checkout --quiet --detach "$upstream"
for commit in "${series[@]}"; do
  GIT_COMMITTER_NAME="$(git log -1 --format=%cn "$commit")"
  GIT_COMMITTER_EMAIL="$(git log -1 --format=%ce "$commit")"
  GIT_COMMITTER_DATE="$(git log -1 --format=%cI "$commit")"
  export GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_COMMITTER_DATE
  if ! git -c commit.gpgsign=false cherry-pick --keep-redundant-commits "$commit" > /dev/null 2>&1; then
    keep_fork_side "$commit"
    if [ -n "$(git diff --name-only --diff-filter=U)" ]; then
      echo "Conflict replaying $(git log -1 --format='%h %s' "$commit"):"
      git diff --name-only --diff-filter=U
      git cherry-pick --abort
      exit 1
    fi
    git -c commit.gpgsign=false -c core.editor=true cherry-pick --continue > /dev/null
  fi
done
echo "Replayed ${#series[@]} commits onto $upstream: $(git rev-parse HEAD)" >&2
