# Zelport Homebrew tap

Rolling Homebrew formula for Zelport App on macOS and Linux, ARM64 and x86-64.
The tap follows Zelport App releases and has no independent release version or
tags.

```sh
brew install zelport/tap/zelport
brew services start zelport
```

Installation does not start Zelport. Run `zelport` in a terminal or start the
service as your regular user, without `sudo`. Homebrew uses launchd on macOS and
systemd on Linux. The dashboard is available at <http://localhost:8080>.

Do not run two instances with the same port or configuration. A Homebrew service
does not inherit the complete interactive shell environment; configure required
backend tools and SSH agent access explicitly.

## Update the formula

Generate and verify all four App archives before editing this repository:

```sh
make release VERSION=0.10.0
```

Copy `bin/homebrew/0.10.0/Formula/zelport.rb` into `Formula/`, verify that each
formula checksum matches the exact immutable archive, then run Homebrew style,
audit, install and test checks. Never replace bytes at an existing release URL.
The initial formula has no `revision`; packaging-only corrections increment a
numeric Homebrew `revision` without changing the App version.

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

The helper verifies every local archive checksum before modifying only the
installed tap copy. Never commit that local override. Stop any running service
before `brew uninstall zelport`; uninstalling the formula does not remove user
configuration.
