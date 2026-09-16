#!/bin/bash
set -Eeuo pipefail
. "$(dirname "$0")/libbuild.bash"

asset="ffmpeg-master-latest-linux64-gpl.tar.xz"
base="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest"
archive="$CACHE/$asset"
checksums="$CACHE/ffmpeg-checksums.sha256"
stage="$CACHE/stage-ffmpeg-btbn"
download "$base/checksums.sha256" "$checksums"
download "$base/$asset" "$archive"
expected="$(awk -v f="$asset" '$2==f || $2=="*"f {print $1}' "$checksums")"
[ -n "$expected" ] || { echo 'Upstream FFmpeg checksum not found' >&2; exit 1; }
printf '%s  %s\n' "$expected" "$archive" | sha256sum -c -
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
tar -xJf "$archive" -C "$tmp"
ffmpeg_bin="$(find "$tmp" -type f -path '*/bin/ffmpeg' | head -n1)"
[ -n "$ffmpeg_bin" ] || { echo 'ffmpeg binary not found' >&2; exit 1; }
version="$($ffmpeg_bin -version | awk 'NR==1 {print $3}' | tr '-' '_')"
package="$DIST/ffmpeg-btbn-$version-$ARCH-$BUILD.txz"
rm -rf "$stage"; mkdir -p "$stage/usr/bin" "$stage/install"
for binary in ffmpeg ffprobe ffplay; do
  source_bin="$(find "$tmp" -type f -path "*/bin/$binary" | head -n1)"
  [ -z "$source_bin" ] || install -m 755 "$source_bin" "$stage/usr/bin/$binary"
done
"$stage/usr/bin/ffmpeg" -hide_banner -encoders 2>/dev/null | grep -q h264_nvenc
"$stage/usr/bin/ffmpeg" -hide_banner -encoders 2>/dev/null | grep -q hevc_nvenc
printf '%s\n' 'ffmpeg-btbn: FFmpeg GPL static build from BtbN with NVENC encoders' > "$stage/install/slack-desc"
make_slack_package "$stage" "$package"
write_metadata ffmpeg-btbn "$version" "$package" 'BtbN FFmpeg GPL static build with NVENC'

