#!/usr/bin/env python3
"""Comprobaciones básicas sin dependencias ni conexión a Oracle."""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
SENSITIVE_SUFFIXES = {'.p12', '.sso', '.jks', '.key', '.wallet'}
SENSITIVE_DIRS = {'wallet', '.wallet'}
# Se construye en partes para que el propio verificador no active la búsqueda.
PRIVATE_KEY_MARKER = b'-----BEGIN ' + b'PRIVATE KEY-----'
PRIVATE_KEY_VARIANTS = (PRIVATE_KEY_MARKER, b'-----BEGIN ' + b'RSA PRIVATE KEY-----',
                        b'-----BEGIN ' + b'EC PRIVATE KEY-----',
                        b'-----BEGIN ' + b'OPENSSH PRIVATE KEY-----')
APEX_CHECKSUM_SALT = re.compile(rb'(?im)^\s*checksumSalt\s*:\s*[0-9a-f]{64}\s*$')
REQUIRED_SECTIONS = ('## Objetivo', '## Criterios de aceptación', '## Verificación')
SKIP_DIRS = {'.git', '__pycache__', 'node_modules', '.venv'}


def main():
    errors = []
    for path in ROOT.rglob('*'):
        rel = path.relative_to(ROOT)
        if any(part in SKIP_DIRS for part in rel.parts):
            continue
        if any(part.lower() in SENSITIVE_DIRS for part in rel.parts):
            errors.append(f'Posible wallet: {rel}')
            continue
        if not path.is_file():
            continue
        name = path.name.lower()
        if (path.suffix.lower() in SENSITIVE_SUFFIXES or name.startswith('wallet_')
                or (name.startswith('.env') and name != '.env.example')):
            errors.append(f'Archivo posiblemente sensible: {rel}')
            continue
        try:
            data = path.read_bytes()
        except OSError:
            errors.append(f'No se pudo leer: {rel}')
            continue
        if any(marker in data for marker in PRIVATE_KEY_VARIANTS):
            errors.append(f'Posible clave privada: {rel}')
        if path.suffix.lower() == '.apx' and APEX_CHECKSUM_SALT.search(data):
            errors.append(f'La exportación APEX contiene un checksum de sesión: {rel}')

    specs = sorted((ROOT / 'docs/especificaciones').glob('*.md'))
    if not specs:
        errors.append('No hay especificaciones en docs/especificaciones.')
    for spec in specs:
        content = spec.read_text(encoding='utf-8')
        for section in REQUIRED_SECTIONS:
            if section not in content:
                errors.append(f'{spec.relative_to(ROOT)}: falta {section}')

    if errors:
        print('\n'.join(errors), file=sys.stderr)
        return 1
    print('Comprobaciones básicas correctas. La revisión de secretos no es exhaustiva.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
