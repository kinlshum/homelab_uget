# Repository instructions

This repository is the canonical source for the personal `uget` package manager
and Unraid package recipes.

- Keep the client compatible with Bash 4 and standard Unraid utilities.
- Packages must be ordinary Slackware `.txz`/`.tgz` archives usable by
  `installpkg` and `upgradepkg` without `uget`.
- Verify upstream downloads before packaging whenever upstream publishes a
  checksum.
- Never place credentials, SSH keys, host passwords, or API tokens in this
  repository.
- Build output belongs in `dist/` and is not committed except for packages
  explicitly mirrored under `slackware64-current/` for `un-get` compatibility.
- Test shell syntax and package contents before committing.
- Preserve the public command name `uget`.

