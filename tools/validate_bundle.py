#!/usr/bin/env python3
"""Checks source/assets consistency. Does not replace flutter analyze or a build."""
import json
from pathlib import Path
import re
import struct
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def main():
    failures = []
    counts = {'xml': 0, 'arb': 0, 'imports': 0, 'assets': 0}
    for path in (ROOT / 'android').rglob('*.xml'):
        try:
            ET.parse(path)
            counts['xml'] += 1
        except ET.ParseError as error:
            failures.append(f'{path.relative_to(ROOT)}: {error}')
    for path in (ROOT / 'lib/localization').glob('*.arb'):
        json.loads(path.read_text())
        counts['arb'] += 1
    generated = 'localization/app_localizations.dart'
    for directory in ['lib', 'test', 'scripts']:
        for path in (ROOT / directory).rglob('*.dart'):
            source = path.read_text()
            if 'package:musify/' in source:
                failures.append(f'Stale package import: {path.relative_to(ROOT)}')
            for target in re.findall(r"package:thigas_music/([^'\"]+)", source):
                counts['imports'] += 1
                if target != generated and not (ROOT / 'lib' / target).is_file():
                    failures.append(f'Missing import: {target}')
    pubspec = (ROOT / 'pubspec.yaml').read_text()
    for asset in re.findall(r'- asset: (\S+)', pubspec):
        path = ROOT / asset
        counts['assets'] += 1
        if not path.is_file():
            failures.append(f'Missing font: {asset}')
        elif path.read_bytes()[:4] not in (b'\x00\x01\x00\x00', b'OTTO'):
            failures.append(f'Invalid font: {asset}')
    for path in (ROOT / 'assets/branding').glob('*.png'):
        data = path.read_bytes()
        counts['assets'] += 1
        if data[:8] != b'\x89PNG\r\n\x1a\n' or not all(struct.unpack('>II', data[16:24])):
            failures.append(f'Invalid image: {path.name}')
    for path in (ROOT / 'android').rglob('AndroidManifest.xml'):
        if 'com.gokadzev.musify' in path.read_text():
            failures.append(f'Stale Manifest package: {path.relative_to(ROOT)}')
    for local_package in re.findall(r'path: \./(packages/\S+)', pubspec):
        if not (ROOT / local_package / 'pubspec.yaml').is_file():
            failures.append(f'Missing local package: {local_package}')
    required = [
        'LICENSE', 'assets/licenses/outfit.txt', 'assets/icons/thigas_music_icon.png',
        'lib/screens/focus_page.dart', '.github/workflows/build-apk.yml',
        'build-apk.bat', 'build-apk.sh',
    ]
    for name in required:
        if not (ROOT / name).is_file():
            failures.append(f'Missing required file: {name}')
    if failures:
        raise SystemExit('\n'.join(failures))
    print('PASS: bundle consistency:', counts)


if __name__ == '__main__':
    main()
