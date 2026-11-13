# Documentación del proyecto

Trabajamos con desarrollo guiado por especificaciones (SDD): describimos el problema y las reglas antes de implementar, y actualizamos el documento cuando aprendemos o decidimos algo nuevo. Una especificación es una herramienta de trabajo, no una promesa de que la funcionalidad ya existe.

## Dónde está cada cosa

- `../LEEME-PRIMERO.md`: estado actual y próximo paso para retomar el proyecto.
- `REGISTRO-DE-AVANCES.md`: historial breve de cambios relevantes y comprobaciones; no reemplaza el estado actual.
- `PRUEBAS-CULTIVO.md`: pasos y resultados conocidos para comprobar el primer flujo de Cultivo.
- `especificaciones/`: alcance, reglas, criterios de aceptación y estado de cada funcionalidad.
- `decisiones/`: decisiones importantes, sus motivos y alternativas, cuando sea útil conservarlas.
- `plantillas/`: modelos breves para escribir especificaciones y decisiones nuevas.
- `historico/`: documentos heredados del proyecto anterior. Pueden contener reglas o tecnología desactualizadas.
- `../db/migrations/`: cambios de base de datos; `../db/checks/`: comprobaciones correspondientes.
- `../AGENTS.md`: instrucciones de trabajo para agentes de código.

## Flujo para una funcionalidad

1. Escribir o actualizar una especificación: problema, alcance, ejemplos, criterios de aceptación y dudas. Facu y Brisa deciden las reglas de producto.
2. Resolver las dudas necesarias para empezar. Si se usa una hipótesis provisional, identificarla y no darla por confirmada.
3. Preparar un plan técnico breve y, cuando corresponda, registrar una decisión relevante. Crear una rama `feat/`, `fix/` o `docs/` una vez que exista el repositorio Git.
4. Implementar en pasos pequeños; ejecutar comprobaciones apropiadas y registrar qué pasó, incluyendo errores o pruebas pendientes.
5. Revisar cambios y secretos antes de subirlos. En el pull request, explicar qué cambia, cómo se verificó y qué queda pendiente. Actualizar el estado en `LEEME-PRIMERO.md`.

## Comprobaciones automáticas

Ejecutar `python3 scripts/check_repository.py` desde la raíz. Revisa archivos sensibles comunes, marcadores de claves privadas y secciones básicas de las especificaciones; no detecta todos los secretos ni verifica que el contenido sea correcto. No imprime contenidos de archivos. GitHub Actions ejecutará la misma revisión en pushes y pull requests una vez creado el repositorio. Las pruebas SQL requieren una base de pruebas y se ejecutan por separado; no están automatizadas en GitHub.

El registro de avances es manual o asistido por Codex: anotar cambios relevantes y resultados reales, no cada mensaje ni cada ejecución. Git aportará el historial detallado de cambios cuando exista el repositorio.

La intervención de IA se documenta con especificaciones, decisiones, cambios y resultados verificables. No hace falta guardar todas las conversaciones ni atribuir a una persona o herramienta validaciones que no hizo.
