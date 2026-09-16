#!/bin/bash
set -Eeuo pipefail
. "$(dirname "$0")/libbuild.bash"

version="16s"
source_file="$CACHE/lmon${version}.c"
stage="$CACHE/stage-nmon"
package="$DIST/nmon-$version-$ARCH-$BUILD.txz"
rm -rf "$stage"; mkdir -p "$stage/usr/bin" "$stage/install"
download "https://downloads.sourceforge.net/project/nmon/lmon${version}.c" "$source_file"
command -v docker >/dev/null 2>&1 || { echo 'Docker is required to build nmon.' >&2; exit 1; }
# Build in an older glibc userspace and statically link ncurses. This avoids
# inheriting the current GitHub runner's newer ABI or Unraid ncurses revisions.
docker run --rm -v "$ROOT:/work" -w /work debian:12-slim sh -ec '
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq build-essential libncurses-dev >/dev/null
  gcc -O2 -Wall -D JFS -D GETUSER -static -o .cache/stage-nmon/usr/bin/nmon .cache/lmon16s.c -lncursesw -ltinfo -lm -ldl -lpthread
  strip .cache/stage-nmon/usr/bin/nmon
'
printf '%s\n' 'nmon: nmon 16s built as a static x86_64 compatibility binary' > "$stage/install/slack-desc"
make_slack_package "$stage" "$package"
write_metadata nmon "$version" "$package" 'Linux performance monitor (static compatibility build)'
