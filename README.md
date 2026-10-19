# Zelport Homebrew tap

Rolling Homebrew formula for Zelport App on macOS and Linux, ARM64 and x86-64.
The tap follows Zelport App releases and has no independent release version or
tags.

```sh
brew install zelport/tap/zelport
brew services start zelport
```

Installation does not start Zelport. Run it directly or start the service as
your regular user, without `sudo`. The dashboard is at <http://localhost:8080>.

Do not run two instances with the same port or configuration. A Homebrew service
does not inherit the complete interactive shell environment; configure required
backend tools and SSH agent access explicitly.

Docker, Podman, `sbx`, and system SSH are optional external tools for their
respective service sources and are not bundled.

## Release updates

The scheduled `Update Zelport formula` workflow checks for a new stable Zelport
App release. It downloads and verifies the supported release archives against
the published `SHA256SUMS`, generates the formula from the tagged App template,
and opens a pull request. The workflow can also be run manually for a specific
stable version. The [workflow file](.github/workflows/update-formula.yml) is
authoritative for the schedule and release platform matrix.

Repository writes use a short-lived, current-repository token from the
organization-owned `zelport-automation` GitHub App. Credential provisioning and
rotation are documented in the
[automation registry](https://github.com/zelport/workspace/blob/main/AUTOMATIONS.md).

For a manual fallback, run the same verified updater locally:

```sh
: "${APP_VERSION:?set APP_VERSION to the numeric stable App release}"
python3 scripts/update-formula.py --version "$APP_VERSION"
```

Then run Homebrew style, audit, install and test checks. Never replace bytes at
an existing release URL; use a Homebrew `revision` for packaging-only fixes.

## Local formula test

Use the neutral `0.0.0` release fixture when generating local test archives.
Commit the tap before adding it to Homebrew so Homebrew can clone it.

```sh
brew tap --custom-remote zelport/tap /absolute/path/to/homebrew-tap
python3 scripts/prepare-local-test.py \
  /absolute/path/to/zelport/bin/homebrew/0.0.0 \
  "$(brew --repository zelport/tap)"
brew trust --formula zelport/tap/zelport
brew install zelport
brew test zelport
```

The helper verifies the archives and modifies only the installed tap copy. Never
commit that override. Stop the service before uninstalling; user configuration
is preserved.
