#!/bin/bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
command -v docker >/dev/null 2>&1 || { echo 'Docker is required for compatibility tests.' >&2; exit 1; }
runtime="$(mktemp -d)"; trap 'rm -rf "$runtime"' EXIT

for package in "$ROOT"/dist/*.txz; do
  dir="$runtime/$(basename "$package" .txz)"
  mkdir -p "$dir"
  tar -xJf "$package" -C "$dir"
done

for image in alpine:3.20 debian:11-slim debian:12-slim ubuntu:22.04; do
  echo "Runtime compatibility: $image"
  docker run --rm -v "$runtime:/packages:ro" "$image" sh -ec '
    btop=$(find /packages -path "*/usr/bin/btop" | head -n1)
    nmon=$(find /packages -path "*/usr/bin/nmon" | head -n1)
    ffmpeg=$(find /packages -path "*/usr/bin/ffmpeg" | head -n1)
    "$btop" --version >/dev/null
    if [ -e /lib64/ld-linux-x86-64.so.2 ]; then
      "$nmon" -h >/dev/null 2>&1 || test $? -le 1
    fi
    "$ffmpeg" -version >/dev/null
    "$ffmpeg" -hide_banner -encoders 2>/dev/null | grep -q h264_nvenc
    "$ffmpeg" -hide_banner -encoders 2>/dev/null | grep -q hevc_nvenc
  '
done
