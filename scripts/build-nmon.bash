#!/bin/bash
set -Eeuo pipefail
. "$(dirname "$0")/libbuild.bash"

version="16s"
archive="$CACHE/nmon${version}_binaries.tar.gz"
stage="$CACHE/stage-nmon"
package="$DIST/nmon-$version-$ARCH-$BUILD.txz"
rm -rf "$stage"; mkdir -p "$stage/usr/bin" "$stage/install"
download "https://downloads.sourceforge.net/project/nmon/nmon${version}_binaries.tar.gz" "$archive"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
tar -xzf "$archive" -C "$tmp"
# The CentOS 7 build targets Linux 2.6.32 and only GLIBC 2.7, making it the
# broadest official x86_64 binary for current and older Unraid installations.
install -m 755 "$tmp/nmon_X86_CentOS7_${version}" "$stage/usr/bin/nmon"
strip "$stage/usr/bin/nmon" || true
printf '%s\n' 'nmon: official nmon 16s x86_64 compatibility binary' > "$stage/install/slack-desc"
make_slack_package "$stage" "$package"
write_metadata nmon "$version" "$package" 'Linux performance monitor (official compatibility build)'
