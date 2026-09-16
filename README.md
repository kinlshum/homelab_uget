# uget

`uget` is a small personal package manager for the Kraken, Unraid, and Unmini
Unraid servers. It installs normal Slackware packages, verifies SHA-256
checksums, persists packages on the USB boot device, and restores them after an
Unraid reboot.

It is intentionally smaller than a general package manager. Existing `un-get`
can remain installed during migration. Packages in `slackware64-current/` also
provide the `FILE_LIST` and `CHECKSUMS.md5` files expected by `un-get`.

## Install on an Unraid server

```bash
curl -fsSL https://raw.githubusercontent.com/kinlshum/uget/main/uget \
  -o /tmp/uget
chmod +x /tmp/uget
/tmp/uget bootstrap
uget update
uget profile kraken
```

Use `unraid` or `unmini` instead of `kraken` on the other servers.

`bootstrap` stores the client at `/boot/custom/uget/bin/uget`, links it into
`/usr/local/sbin`, and adds a small managed block to `/boot/config/go`. Thirty
seconds after boot, `uget boot-sync` retries until networking is ready, pulls the
new catalog, upgrades changed binaries, installs newly-added profile packages,
and restores the verified cache. If GitHub is unreachable, it uses the last
verified cached packages so boot is not blocked.

## Commands

```text
uget update                 Download the current signed-by-hash catalog
uget search [text]          Search available packages
uget install PKG...         Download, verify, persist, and install packages
uget upgrade [PKG...]       Upgrade installed packages (all when omitted)
uget remove PKG...          Remove packages after confirmation
uget list                   Show uget-managed packages
uget profile NAME           Apply common + host package profiles
uget restore                Restore cached packages without networking
uget boot-sync              Update, upgrade, and restore (automatic at boot)
uget verify                 Verify persistent package checksums
uget doctor                 Show ownership/path conflicts and prerequisites
uget bootstrap              Install persistent client and /boot/config/go hook
uget unget-source           Print/add the legacy un-get source line
```

## Package ownership policy

1. Check Unraid and the custom repository first.
2. Homebrew may be used to prototype a missing tool.
3. Add and test a reproducible `uget` package.
4. Only after the `uget` package passes on the servers, unlink or remove the
   Homebrew copy so one tool has one production owner.

FFmpeg is built from the official BtbN GPL static archive. The package test
checks that H.264 and HEVC NVENC encoders are present; a server with an NVIDIA
GPU should additionally perform a real encode smoke test.

## Existing un-get compatibility

Add the following line to `/boot/config/plugins/un-get/sources.list`:

```text
https://raw.githubusercontent.com/kinlshum/uget/main/slackware64-current uget
```

Or run `uget unget-source --add`. Large assets such as FFmpeg are installed by
`uget` from GitHub Releases rather than the raw Git repository.

## Automated builds

The GitHub Actions workflow runs daily and on demand. It builds `btop`, `nmon`,
and BtbN FFmpeg, validates package contents, tests the static binaries across
Alpine, Debian 11, Debian 12, and Ubuntu 22.04 userspaces, publishes them on the
stable `packages` release, and updates the catalog only when artifacts change.

These are user-space executables, so one static x86_64 package supports the
three current servers; separate packages per kernel are unnecessary. Unraid 7.0
uses the Linux 6.6 line and later Unraid 7 releases use Linux 6.12 or newer. A
future kernel module or driver must instead be compiled separately for every
exact Unraid kernel release.
