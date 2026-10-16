#!/usr/bin/env python3
"""Use verified local release archives in an installed test tap only."""
import argparse
import hashlib
from pathlib import Path
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('release', type=Path)
parser.add_argument('installed_tap', type=Path)
args = parser.parse_args()
release = args.release.resolve()
tap = args.installed_tap.resolve()
source = Path(__file__).resolve().parents[1]
if tap == source:
    parser.error('Use the installed test tap, not this source repository')
formula = (release / 'Formula/zelport.rb').read_text()
pattern = r'url "(https://github.com/zelport/zelport/releases/download/[^"\n]+)"\s+sha256 "([0-9a-f]{64})"'
matches = re.findall(pattern, formula)
if len(matches) != 4:
    parser.error('Expected exactly four release archives')
for url, checksum in matches:
    archive = release / url.rsplit('/', 1)[1]
    if hashlib.sha256(archive.read_bytes()).hexdigest() != checksum:
        parser.error(f'Checksum mismatch: {archive.name}')
    formula = formula.replace(url, archive.as_uri())
target = tap / 'Formula/zelport.rb'
if not target.is_file():
    parser.error('Tap zelport/tap before preparing the local test')
if target.read_text() != (source / 'Formula/zelport.rb').read_text():
    parser.error('Installed formula differs from source. Refusing to overwrite it')
target.write_text(formula)
print(f'Local test URLs written to {target}')
