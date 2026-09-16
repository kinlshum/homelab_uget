#!/bin/bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash -n "$ROOT/uget" "$ROOT"/scripts/*.bash
grep -q $'^# name\tversion\t' "$ROOT/catalog.tsv"
while IFS=$'\t' read -r name version arch build sha url filename description; do
  [ -n "$name" ] || continue
  package="$ROOT/dist/$filename"
  [ -f "$package" ]
  [ "$(sha256sum "$package" | awk '{print $1}')" = "$sha" ]
  tar -tJf "$package" | grep -q '^\./usr/bin/'
done < <(grep -vE '^[[:space:]]*(#|$)' "$ROOT/catalog.tsv")
echo 'uget syntax, catalog, checksums, and package contents passed.'

