#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PY'
import re, zipfile, pathlib
root = pathlib.Path('.')
toc = (root / 'GoodDuel' / 'GoodDuel.toc').read_text()
version = re.search(r'^## Version:\s*(\S+)', toc, re.M).group(1)
(root / 'dist').mkdir(exist_ok=True)
out = root / 'dist' / f'GoodDuel-{version}.zip'
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for p in sorted((root / 'GoodDuel').rglob('*')):
        if p.is_file():
            z.write(p, p.as_posix())
print('built', out)
for i in zipfile.ZipFile(out).infolist():
    print(f'  {i.file_size:>6}  {i.filename}')
PY
