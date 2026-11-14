#!/usr/bin/env python3
"""Ejecutar una herramienta APEX con una copia temporal que contiene el valor local."""

import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / 'applications' / 'let-s-find-out'
BACKUP = Path.home() / '.local/share/lets-find-out-apex/private/application-original.apx'
SALT = re.compile(r'(?m)^\s*checksumSalt:\s*([0-9a-fA-F]{64})\s*$')


def main():
    if len(sys.argv) < 3 or sys.argv[1] != '--' or not any('{app}' in x for x in sys.argv[2:]):
        print('Uso: python3 scripts/apex-con-valor-privado.py -- comando ... {app}', file=sys.stderr)
        return 2
    if not BACKUP.is_file() or BACKUP.stat().st_mode & 0o077:
        print('Falta el respaldo privado o sus permisos permiten acceso a otros usuarios.', file=sys.stderr)
        return 2
    matches = SALT.findall(BACKUP.read_text(encoding='utf-8'))
    src = (APP / 'application.apx').read_text(encoding='utf-8')
    if len(matches) != 1 or SALT.search(src) or not src.rstrip().endswith(')'):
        print('La exportación o el respaldo no tienen el formato esperado.', file=sys.stderr)
        return 2
    with tempfile.TemporaryDirectory(prefix='lfo-apex-', ignore_cleanup_errors=False) as tmp:
        os.chmod(tmp, 0o700)
        target = Path(tmp) / 'app'
        shutil.copytree(APP, target)
        code = src.rstrip()
        code = code[:-1] + '    sessionStateProtection {\n        checksumSalt: ' + matches[0] + '\n    }\n)\n'
        (target / 'application.apx').write_text(code, encoding='utf-8')
        args = [arg.replace('{app}', str(target)) for arg in sys.argv[2:]]
        try:
            env = os.environ.copy()
            env['APEXLANG_OUTPUT_ROOT'] = str(Path(tmp) / 'runtime')
            result = subprocess.run(args, check=False, capture_output=True, text=True, env=env)
        except OSError as exc:
            print(f'No se pudo ejecutar la herramienta: {exc.strerror}', file=sys.stderr)
            return 2
        # El compilador podría imprimir el valor en mensajes de error.
        for stream, output in ((sys.stdout, result.stdout), (sys.stderr, result.stderr)):
            stream.write(re.sub(re.escape(matches[0]), '[valor privado omitido]', output, flags=re.IGNORECASE))
        return result.returncode


if __name__ == '__main__':
    raise SystemExit(main())
