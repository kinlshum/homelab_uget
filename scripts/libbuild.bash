#!/bin/bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT/dist"
CACHE="$ROOT/.cache"
ARCH="x86_64"
BUILD="1_uget"
mkdir -p "$DIST" "$CACHE"

download() { curl -fL --retry 4 --connect-timeout 20 -o "$2" "$1"; }

make_slack_package() {
  local stage="$1" output="$2"
  mkdir -p "$stage/install"
  [ -f "$stage/install/slack-desc" ] || printf '%s\n' 'uget: package built by uget' > "$stage/install/slack-desc"
  tar --numeric-owner --owner=0 --group=0 -C "$stage" -cJf "$output" .
}

write_metadata() {
  local name="$1" version="$2" package="$3" description="$4" sha url
  sha="$(sha256sum "$package" | awk '{print $1}')"
  url="https://github.com/kinlshum/uget/releases/download/packages/$(basename "$package")"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$name" "$version" "$ARCH" "$BUILD" "$sha" "$url" "$(basename "$package")" "$description" > "$package.meta"
}

