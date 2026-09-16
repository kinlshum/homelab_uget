#!/bin/bash
set -Eeuo pipefail
. "$(dirname "$0")/libbuild.bash"

tag="$(curl -fsSL https://api.github.com/repos/aristocratos/btop/releases/latest | jq -r .tag_name)"
version="${tag#v}"
archive="$CACHE/btop-$version.tar.gz"
stage="$CACHE/stage-btop"
package="$DIST/btop-$version-$ARCH-$BUILD.txz"
rm -rf "$stage"; mkdir -p "$stage/usr/bin" "$stage/usr/share/btop/themes"
download "https://github.com/aristocratos/btop/releases/download/$tag/btop-x86_64-unknown-linux-musl.tar.gz" "$archive"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
tar -xzf "$archive" -C "$tmp"
binary="$(find "$tmp" -type f -name btop -perm -111 | head -n1)"
[ -n "$binary" ] || { echo 'btop binary not found' >&2; exit 1; }
install -m 755 "$binary" "$stage/usr/bin/btop"
themes="$(find "$tmp" -type d -name themes | head -n1)"
[ -z "$themes" ] || cp -R "$themes"/. "$stage/usr/share/btop/themes/"
mkdir -p "$stage/install"
printf '%s\n' 'btop: resource monitor from aristocratos/btop static musl release' > "$stage/install/slack-desc"
make_slack_package "$stage" "$package"
write_metadata btop "$version" "$package" 'Resource monitor (official static musl build)'

