# Zelport Homebrew tap

Homebrew distribution for Zelport on macOS and Linux, ARM64 and x86-64.

This tap distributes the Zelport preview release. Preview builds are intended
for evaluation and may change before a stable release.

Install from GitHub:

```sh
brew install zelport/tap/zelport
brew services start zelport
```

Installation alone does not start the application. Run services without sudo.
Homebrew uses launchd on macOS and systemd on Linux. The dashboard is at
http://localhost:8080. To run manually, use `zelport` instead of starting a
service. Do not run two instances using the same port or configuration.

## Update a release

Generate the four archives and formula with `make release VERSION=x.y.z` in the
Zelport repository. Publish the exact archives first, then copy
`bin/homebrew/x.y.z/Formula/zelport.rb` into this repository's `Formula/`
directory. Test and commit the formula. Never replace previously published
archives with new bytes at the same URL.

## Local installation test

The test uses local archives without publishing or changing the source formula.
Commit the repository before tapping it so Homebrew can clone it.

```sh
brew tap --custom-remote zelport/tap /absolute/path/to/homebrew-tap
python3 scripts/prepare-local-test.py \
  /absolute/path/to/zelport/bin/homebrew/0.0.0-homebrew-test \
  "$(brew --repository zelport/tap)"
brew trust --formula zelport/tap/zelport
brew install zelport
brew test zelport
```

The helper validates all archive checksums before changing only the installed
tap's formula to use `file://` URLs. This is a local, uncommitted override.
Do not commit or publish it. Keep the source archives until testing is complete.
The test does not register a service or change user configuration.

After the public tap is available, remove the test installation and local tap
with `brew uninstall zelport` and `brew untap zelport/tap`, then install using
`brew install zelport/tap/zelport`. Stop a service first if you started one.
User configuration is not removed by the formula.
