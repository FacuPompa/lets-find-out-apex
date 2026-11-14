# Validar e importar APEXlang

La copia versionada de `applications/let-s-find-out` no contiene el valor privado que protege enlaces de la aplicación 100. El respaldo de desarrollo está fuera del repositorio, en `~/.local/share/lets-find-out-apex/private/application-original.apx`, con permisos solo para su propietario. Nunca imprimirlo, copiarlo al repositorio ni importar una aplicación sin comprobar el valor del entorno de destino. El respaldo corresponde a desarrollo; no reutilizarlo para otro entorno.

`scripts/apex-con-valor-privado.py` extrae el valor del respaldo, crea un directorio temporal privado, prepara allí una copia de la aplicación y ejecuta el comando indicado sustituyendo `{app}` por la ruta temporal. Cuando el comando termina, borra la copia temporal. La salida capturada reemplaza el valor privado si la herramienta lo imprime. Si el proceso se interrumpe de forma abrupta, revisar y eliminar cualquier directorio privado `/tmp/lfo-apex-*` que haya quedado. El script no cambia la instalación ni importa por sí mismo.

Para validar en desarrollo con las herramientas actuales (ajustar la ruta de SQLcl si cambia la extensión):

```bash
env PATH=$HOME/.vscode/extensions/oracle.sql-developer-26.3.1-linux-x64/dbtools/sqlcl/bin:$PATH \
  python3 scripts/apex-con-valor-privado.py -- \
  node $HOME/.codex/skills/apex/apexlang/26.1/apexlang-generation/tools/apexctl.mjs \
  runtime validate --app-path '{app}' --db-connection-name lets-find-out-dev \
  --execution-mode path \
  --workspaceid 9513994217514688 --artifact-dir '{app}/../artifacts' \
  --report-path '{app}/../validation.json'
```

Para importar, seguir el flujo de la skill APEXlang 26.1: validar primero y obtener la elección explícita posterior a la comprobación; después usar `runtime roundtrip` con `--import-intent validate-and-import`, `--target-resolution-mode update-existing`, el ID de workspace correcto y la misma sustitución `{app}`. Comprobar el destino y la ausencia de cambios ajenos antes de la importación. El comando deberá revalidar en la misma sesión de importación. Después, verificar la aplicación desde APEX y actualizar el estado. No incluir el valor privado en logs, errores, commits o capturas.

Estado: la copia temporal se creó y limpió tanto en ejecución normal como ante un fallo controlado; se comprobó la redacción del valor y la propagación del código de error. El 13/11/2026 pasaron la validación live y la importación a desarrollo con este procedimiento; la página importada se confirmó mediante reexportación. La prueba en navegador está pendiente. El runtime señaló incidencias en el chequeo local y las trató como informativas frente a la validación live exitosa.
