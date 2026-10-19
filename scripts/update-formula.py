#!/usr/bin/env python3
"""Update the Zelport formula from a verified public GitHub release."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import tempfile
from urllib.request import Request, urlopen


REPOSITORY = "zelport/zelport"
FORMULA = Path(__file__).resolve().parents[1] / "Formula/zelport.rb"
PLATFORMS = (
    ("darwin", "macos", "arm64", "arm"),
    ("darwin", "macos", "amd64", "intel"),
    ("linux", "linux", "arm64", "arm"),
    ("linux", "linux", "amd64", "intel"),
)
STABLE_VERSION = re.compile(
    r"(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)"
)
CHECKSUM = re.compile(r"([0-9a-f]{64})  ([A-Za-z0-9._-]+)")


def download(url):
    request = Request(url, headers={"User-Agent": "zelport-homebrew-updater"})
    with urlopen(request, timeout=60) as response:
        return response.read()


def parse_checksums(data):
    checksums = {}
    for line in data.decode("utf-8").splitlines():
        match = CHECKSUM.fullmatch(line)
        if not match:
            raise ValueError(f"invalid SHA256SUMS line: {line!r}")
        digest, name = match.groups()
        if name in checksums:
            raise ValueError(f"duplicate SHA256SUMS entry: {name}")
        checksums[name] = digest
    return checksums


def version_tuple(version):
    if not STABLE_VERSION.fullmatch(version):
        raise ValueError(f"release version is not stable semver: {version}")
    return tuple(int(part) for part in version.split("."))


def render_formula(template, version, checksums):
    downloads = []
    current_os = None
    for goos, brew_os, goarch, brew_arch in PLATFORMS:
        if brew_os != current_os:
            if current_os is not None:
                downloads.append("  end")
            downloads.append(f"  on_{brew_os} do")
            current_os = brew_os
        name = f"zelport_{version}_{goos}_{goarch}.tar.gz"
        if name not in checksums:
            raise ValueError(f"release checksum is missing: {name}")
        downloads.extend(
            [
                f"    on_{brew_arch} do",
                f'      url "https://github.com/{REPOSITORY}/releases/download/v{version}/{name}"',
                f'      sha256 "{checksums[name]}"',
                "    end",
            ]
        )
    downloads.append("  end")
    if template.count("@VERSION@") != 1 or template.count("@DOWNLOADS@") != 1:
        raise ValueError("Homebrew template must contain each placeholder exactly once")
    return template.replace("@VERSION@", version).replace(
        "@DOWNLOADS@", "\n".join(downloads)
    )


def release(version):
    suffix = f"tags/v{version}" if version else "latest"
    metadata = json.loads(
        download(f"https://api.github.com/repos/{REPOSITORY}/releases/{suffix}")
    )
    tag = metadata.get("tag_name", "")
    if not tag.startswith("v"):
        raise ValueError("release tag must start with v")
    selected = tag[1:]
    version_tuple(selected)
    if version and selected != version:
        raise ValueError(f"release tag {tag} does not match requested version {version}")
    if metadata.get("draft") or metadata.get("prerelease"):
        raise ValueError("release must be public and stable")
    names = {asset.get("name") for asset in metadata.get("assets", [])}
    required = {"SHA256SUMS"}
    required.update(
        f"zelport_{selected}_{goos}_{goarch}.tar.gz"
        for goos, _, goarch, _ in PLATFORMS
    )
    missing = required - names
    if missing:
        raise ValueError(f"release assets are missing: {sorted(missing)}")
    return selected


def write_output(name, value):
    output = os.environ.get("GITHUB_OUTPUT")
    if output:
        with open(output, "a", encoding="utf-8") as stream:
            stream.write(f"{name}={value}\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", help="stable version without the v prefix")
    args = parser.parse_args()
    if args.version:
        version_tuple(args.version)

    version = release(args.version)
    current = re.search(
        r'^  version "([^"]+)"$', FORMULA.read_text(encoding="utf-8"), re.MULTILINE
    )
    if not current:
        raise ValueError("current formula does not declare a version")
    if version_tuple(version) < version_tuple(current.group(1)):
        raise ValueError(
            f"refusing to downgrade formula from {current.group(1)} to {version}"
        )

    release_base = f"https://github.com/{REPOSITORY}/releases/download/v{version}"
    checksums = parse_checksums(download(f"{release_base}/SHA256SUMS"))
    for goos, _, goarch, _ in PLATFORMS:
        name = f"zelport_{version}_{goos}_{goarch}.tar.gz"
        digest = hashlib.sha256(download(f"{release_base}/{name}")).hexdigest()
        if digest != checksums.get(name):
            raise ValueError(f"published archive checksum does not match: {name}")

    template = download(
        f"https://raw.githubusercontent.com/{REPOSITORY}/v{version}/"
        "packaging/homebrew/zelport.rb.in"
    ).decode("utf-8")
    formula = render_formula(template, version, checksums)
    changed = formula != FORMULA.read_text(encoding="utf-8")
    if changed:
        with tempfile.NamedTemporaryFile(
            "w", encoding="utf-8", dir=FORMULA.parent, delete=False
        ) as stream:
            stream.write(formula)
            temporary = Path(stream.name)
        temporary.replace(FORMULA)

    write_output("changed", str(changed).lower())
    write_output("version", version)
    print(f"Formula is {'updated to' if changed else 'already at'} Zelport {version}")


if __name__ == "__main__":
    main()
