#!/bin/bash
set -Eeuo pipefail
. "$(dirname "$0")/libbuild.bash"

version="16p"
source_file="$CACHE/lmon${version}.c"
stage="$CACHE/stage-nmon"
package="$DIST/nmon-$version-$ARCH-$BUILD.txz"
rm -rf "$stage"; mkdir -p "$stage/usr/bin" "$stage/install"
download "https://downloads.sourceforge.net/project/nmon/lmon${version}.c" "$source_file"
command -v docker >/dev/null 2>&1 || { echo 'Docker is required to build static nmon.' >&2; exit 1; }
docker run --rm -v "$ROOT:/work" -w /work alpine:3.20 sh -ec '
  apk add --no-cache build-base ncurses-dev ncurses-static >/dev/null
  gcc -O2 -Wall -D JFS -D GETUSER -static -o .cache/stage-nmon/usr/bin/nmon .cache/lmon16p.c -lncursesw -ltinfo -lm
  strip .cache/stage-nmon/usr/bin/nmon
'
printf '%s\n' 'nmon: Linux performance monitor built from official SourceForge source' > "$stage/install/slack-desc"
make_slack_package "$stage" "$package"
write_metadata nmon "$version" "$package" 'Linux performance monitor'
