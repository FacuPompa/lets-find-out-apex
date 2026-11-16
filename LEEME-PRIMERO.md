# Let's Find Out! — continuidad

Actualizado: 14/11/2026. El detalle de las reglas está en las especificaciones de `docs/especificaciones/`; el historial de avances, en `docs/REGISTRO-DE-AVANCES.md`.

## Estado actual

- Aplicación 100 en Oracle APEX 26.1.6, workspace `LETS_FIND_OUT_DEV`, esquema `LFO_APP_DEV`. La conexión SQLcl de desarrollo se llama `lets-find-out-dev`. El proyecto anterior se conserva aparte.
- **Cultivo:** se pueden crear metas, registrar sesiones manuales y asociar tiempo del cronómetro a una actividad. Los nuevos registros acumulan tiempo y pueden contar varios cumplimientos; el historial anterior conserva su cálculo. La acumulación y la pausa se comprobaron en navegador; el aviso cercano sigue pendiente de comprobación visual.
- **Personas:** hay dos cuentas APEX vinculadas a identificadores de persona. El alta y registro comprueban la propiedad y el progreso es compartido; falta probar los controles de extremo a extremo con ambas cuentas. No considerar completo el aislamiento ni usar el prototipo como producto terminado.
- **Cronómetros:** hay cuatro categorías, un reloj activo por persona y registro incremental de intervalos. Registrar pausa el reloj. El tiempo persiste en la base y se puede asociar a actividades de Cultivo. Los colores son configurables por cuenta.
- **Día personal:** los nuevos intervalos se asocian al día abierto, incluso después de medianoche. Se puede revisar y cerrar el día; si hay un reloj activo, se pide confirmación antes de pausarlo. El resumen guardado incluye solo el tiempo registrado; el tiempo pendiente se conserva. La reapertura y las correcciones posteriores aún no están implementadas.
- **Progreso semanal:** cada cuenta puede establecer objetivos de horas por categoría y ver las tablas de ambas personas para su semana seleccionada. Incluye intervalos de cronómetro registrados y asociados a un día, pero no sesiones manuales de Cultivo ni intervalos anteriores sin día. No calcula puntos ni banco de ocio. Faltan pruebas de navegador de estas pantallas.
- Los avisos usan componentes de APEX. La skill local `mensajes-ui` y `AGENTS.md` documentan esta convención.
- El repositorio remoto es público. La imagen proporcionada para el logo se incluye en la aplicación versionada; representa un personaje de una obra existente.
- La exportación versionada omite el `checksumSalt`. El respaldo de desarrollo está fuera del repositorio. Seguir `docs/IMPORTACION-APEX.md`; no publicar valores privados, wallets ni contraseñas.

- Integración de Cultivo: `010_cultivo_acumulado.sql` está instalado en desarrollo y pasó la prueba `012_cultivo_acumulado.sql`. La selección de actividad y el aviso cuando faltan hasta diez minutos para otro cumplimiento desde el segundo se importaron a la aplicación 100. Se comprobó en navegador la acumulación y la pausa al pulsar «Registrar tiempo»; falta probar visualmente el aviso.

## Próximos pasos

1. Probar objetivos, progreso y autorización entre las dos cuentas desde las pantallas.
2. Probar en navegador el aviso cercano a otro cumplimiento de Cultivo.
3. Definir y construir correcciones, reapertura de días y tratamiento del tiempo previo sin día asignado.
4. Acordar los detalles pendientes del banco de ocio, puntuaciones, cierres semanales y recuentos mensuales antes de implementarlos.
5. Mantener actualizados las especificaciones, las pruebas y el registro de avances. Las pruebas SQL deben ejecutarse en una sesión de desarrollo dedicada y conservar los datos existentes.

## Referencias

- `docs/especificaciones/001-metas-de-cultivo.md`: reglas y estado del flujo de Cultivo.
- `docs/especificaciones/002-cronometros-y-cierres.md`: propuesta y estado de cronómetros, progreso y cierres.
- `docs/PRUEBAS-CULTIVO.md`: pruebas del flujo y aislamiento.
- `docs/IMPORTACION-APEX.md`: validación e importación con el valor privado del entorno.
- `AGENTS.md`: instrucciones del proyecto. `python3 scripts/check_repository.py` verifica documentación y patrones básicos de secretos, sin sustituir pruebas ni una revisión completa.
