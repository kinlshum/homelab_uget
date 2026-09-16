#!/bin/bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
REPO="$ROOT/slackware64-current"
mkdir -p "$REPO"

{
  printf '# name\tversion\tarch\tbuild\tsha256\turl\tfilename\tdescription\n'
  find "$DIST" -maxdepth 1 -name '*.meta' -type f -print0 | sort -z | xargs -0 cat
} > "$ROOT/catalog.tsv"

# Mirror only packages below GitHub's normal per-file limit for legacy un-get.
find "$REPO" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
while IFS= read -r package; do
  [ "$(wc -c < "$package")" -lt 95000000 ] || continue
  name="$(basename "$package" | sed -E 's/-[0-9][^-]*-x86_64-[^-]+\.t[xg]z$//')"
  mkdir -p "$REPO/$name"
  cp "$package" "$REPO/$name/"
done < <(find "$DIST" -maxdepth 1 -type f \( -name '*.txz' -o -name '*.tgz' \) | sort)

(
  cd "$REPO"
  find . -mindepth 1 -printf '%M %n root root %12s %TY-%Tm-%Td %TH:%TM %p\n' | sort > FILE_LIST
  find . -type f ! -name CHECKSUMS.md5 -print0 | sort -z | xargs -0 md5sum > CHECKSUMS.md5
)

