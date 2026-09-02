#!/usr/bin/env bash
# Put this workspace, and every app repo under main/, on the same series tag.
#
#   ./bootstrap.sh v1-start    # the state Video 1 starts from
#   ./bootstrap.sh             # re-sync main/ to whatever tag this repo is on
#
# Every video has a `vN-start` and a `vN-end` tag, and the same tag exists in
# this repo and in each app repo that the series has introduced by then. Repos
# that don't carry the tag yet are skipped — they arrive in a later video.
set -euo pipefail

OWNER=rahulpnath

# <github repo>:<folder under main/>
REPOS=(
  "tilt-series-catalog:Shop.Catalog"
  "tilt-series-orders:Shop.Orders"
  "tilt-series-storefront:Shop.Storefront"
  "tilt-series-admin:Shop.Admin"
)

die() { printf '\n✗ %s\n' "$1" >&2; exit 1; }

current_tag() { git describe --tags --exact-match 2>/dev/null || true; }

main() {
  cd "$(dirname "$0")"
  local tag="${1:-}" switched="${2:-}"

  if [ -z "$tag" ]; then
    tag="$(current_tag)"
    [ -n "$tag" ] || die "This workspace isn't on a series tag. Pass one:  ./bootstrap.sh v1-start"
  fi

  # Move this repo onto the tag first, then re-exec: bash reads a script as it
  # runs it, and bootstrap.sh itself differs between tags.
  if [ "$switched" != "--switched" ] && [ "$(current_tag)" != "$tag" ]; then
    git rev-parse -q --verify "refs/tags/$tag" >/dev/null 2>&1 || git fetch --tags --quiet
    git rev-parse -q --verify "refs/tags/$tag" >/dev/null 2>&1 || die "No such tag: $tag"
    git checkout --quiet "$tag" 2>/dev/null || die "Couldn't check out $tag — commit or stash your changes first."
    exec "$0" "$tag" --switched
  fi

  printf '→ %s\n' "$tag"
  mkdir -p main

  for entry in "${REPOS[@]}"; do
    local repo="${entry%%:*}" dir="${entry##*:}"
    local url="https://github.com/$OWNER/$repo.git"

    if ! git ls-remote --tags --exit-code "$url" "refs/tags/$tag" >/dev/null 2>&1; then
      if [ -d "main/$dir" ]; then
        # Left over from a later tag. Not removed automatically — it is your
        # folder, and it may hold work you care about.
        printf '  STALE   %-16s  not part of %s. Remove it:  rm -rf main/%s\n' "$dir" "$tag" "$dir"
      else
        printf '  skip    %-16s  not in %s yet — a later video introduces it\n' "$dir" "$tag"
      fi
      continue
    fi

    if [ -d "main/$dir/.git" ]; then
      git -C "main/$dir" fetch --tags --quiet origin
      git -C "main/$dir" checkout --quiet "$tag" 2>/dev/null \
        || die "main/$dir has local changes — commit or stash them, then re-run."
      printf '  updated %-16s  → %s\n' "$dir" "$tag"
    else
      git clone --quiet "$url" "main/$dir"
      git -C "main/$dir" checkout --quiet "$tag"
      printf '  cloned  %-16s  → %s\n' "$dir" "$tag"
    fi
  done

  printf '\n✅ main/ is at %s. README.md says what to run from here.\n' "$tag"
}

main "$@"
