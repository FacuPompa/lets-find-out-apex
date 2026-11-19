# Let's Find Out! — continuidad

Actualizado: 18/11/2026. El detalle de las reglas está en las especificaciones de `docs/especificaciones/`; el historial de avances, en `docs/REGISTRO-DE-AVANCES.md`.

## Estado actual

- Aplicación 100 en Oracle APEX 26.1.6, workspace `LETS_FIND_OUT_DEV`, esquema `LFO_APP_DEV`. La conexión SQLcl de desarrollo se llama `lets-find-out-dev`. El proyecto anterior se conserva aparte.
- **Cultivo:** se pueden crear metas, registrar sesiones manuales y asociar tiempo del cronómetro a una actividad. Los nuevos registros acumulan tiempo y pueden contar varios cumplimientos; el historial anterior conserva su cálculo. La acumulación y la pausa se comprobaron en navegador; el aviso cercano sigue pendiente de comprobación visual.
- **Personas:** hay dos cuentas APEX vinculadas a identificadores de persona. El alta y registro comprueban la propiedad y el progreso es compartido; falta probar los controles de extremo a extremo con ambas cuentas. No considerar completo el aislamiento ni usar el prototipo como producto terminado.
- **Cronómetros:** hay cuatro categorías, un reloj activo por persona y registro incremental de intervalos. Registrar pausa el reloj. El tiempo persiste en la base y se puede asociar a actividades de Cultivo. Los colores son configurables por cuenta.
- **Día personal:** los nuevos intervalos se asocian al día abierto, incluso después de medianoche. Se puede revisar y cerrar el día; si hay un reloj activo, se pide confirmación antes de pausarlo. El resumen guardado incluye solo el tiempo registrado; el tiempo pendiente se conserva. Se importó la corrección del día anterior sin reabrirlo, incluyendo cargas manuales y Cultivo. El lunes no se corrige el domingo y no se modifican semanas ya cerradas. Pasaron pruebas SQL y se comprobó una carga y su corrección en navegador.
- **Progreso semanal:** cada cuenta puede establecer objetivos de horas por categoría y ver las tablas de ambas personas para su semana seleccionada. Incluye cargas manuales de Trabajo, Estudio y Ocio, intervalos de cronómetro asociados a un día y sesiones manuales nuevas de Cultivo vinculadas al día anterior; no incluye sesiones manuales anteriores de Cultivo ni intervalos anteriores sin día. Calcula los seis rubros y muestra un total provisional cuando están definidos todos los objetivos y metas. Falta comprobar los cálculos nuevos en navegador.
- Los avisos usan componentes de APEX. La skill local `mensajes-ui` y `AGENTS.md` documentan esta convención.
- El repositorio remoto es público. La imagen proporcionada para el logo se incluye en la aplicación versionada; representa un personaje de una obra existente.
- La exportación versionada omite el `checksumSalt`. El respaldo de desarrollo está fuera del repositorio. Seguir `docs/IMPORTACION-APEX.md`; no publicar valores privados, wallets ni contraseñas.

- Integración de Cultivo: `010_cultivo_acumulado.sql` está instalado en desarrollo y pasó la prueba `012_cultivo_acumulado.sql`. La selección de actividad y el aviso cuando faltan hasta diez minutos para otro cumplimiento desde el segundo se importaron a la aplicación 100. Se comprobó en navegador la acumulación y la pausa al pulsar «Registrar tiempo»; falta probar visualmente el aviso.
- Reinicio de cronómetros: se instaló en desarrollo `011_reiniciar_cronometro.sql`, pasó `013_reiniciar_cronometro.sql` y se comprobó en navegador. El reinicio descarta el tiempo pendiente, registra ese descarte y conserva las cargas ya guardadas.
- Metas semanales: se instaló `012_metas_semanales.sql`, pasó `014_metas_semanales.sql` y se comprobó en navegador el alta y cambio de estado con puntaje proporcional. Sin metas no se muestra puntaje, hasta acordar esa regla.
- Progreso de metas semanales: se muestra en el resumen compartido la cantidad de metas completadas y los puntos de cada persona. Una prueba con datos temporales verificó 1 de 3 y el caso sin metas; se confirmó en navegador que 3 de 3 muestran 5 puntos.
- Confirmaciones: se identificó el aviso nativo del navegador sobre cambios sin guardar en las metas semanales. Se importaron ajustes para el botón que guarda, el selector de metas y los campos internos de Inicio y Cierre, conservando la protección del texto nuevo. Falta comprobar en navegador que el aviso ya no aparezca al completar o dejar pendiente una meta.
- Puntos de trabajo y estudio: `013_puntos_horas.sql` está instalado y `015_puntos_horas.sql` pasó los cortes y objetivos fraccionarios. La tabla de progreso con puntos parciales se comprobó en navegador. Una categoría sin objetivo no muestra puntos.
- Objetivo de horas de Cultivo: se calcula como suma de mínimos por frecuencia de cada meta, separado por persona y semana. `014_objetivo_cultivo.sql` está instalado y `016_objetivo_cultivo.sql` pasó. Se comprobó en navegador la presentación del objetivo calculado. Los valores antiguos cargados por separado se conservan pero ya no se usan en la tabla.
- Constancia: `015_constancia_diaria.sql` y `017_constancia_diaria.sql` implementan y prueban el criterio por categoría y la suma semanal con tope de cinco puntos. El día cuenta para la semana de su fecha personal, aunque se cierre después de medianoche. La pantalla de progreso pasó validación live y se importó; falta prueba en navegador.
- Progreso: se corrigió una presentación con demasiados decimales en el objetivo derivado de Cultivo y una diferencia visual de un segundo al restar duraciones. La corrección se importó y se confirmó en navegador el formato del objetivo.
- Corrección de tiempo: la versión de `docs/especificaciones/003-correccion-tiempo.md` se importó a desarrollo. Permite elegir categoría o actividad, agregar tiempo manual de Trabajo, Estudio u Ocio y corregir sesiones manuales de Cultivo. Pasaron las pruebas SQL y la validación live; se informó que los recorridos funcionan en navegador. Las cargas antiguas sin día requieren otro recorrido.
- Cierre semanal: cada persona confirma su semana independientemente; se exige al menos una meta semanal y una actividad de Cultivo. `021_cierre_semanal.sql` y la pantalla se importaron tras pasar `023_cierre_semanal.sql` y `024_cierre_semanal_pendientes.sql`. Guardan historial, premio opcional y comparación cuando ambas personas confirman; los cambios posteriores exigen reconfirmar si alteran los puntos. Se comprobó el cierre en navegador; falta probar la comparación con ambas cuentas y definir la regla definitiva para objetivos de horas ausentes. La primera versión también requiere objetivos de Trabajo, Estudio y Ocio y bloquea si hay tiempo pendiente de la semana.
- Redondeo: se acordó redondear cada rubro al entero más cercano (0,50 hacia arriba) antes de sumar. La base pasó su prueba y las pantallas se validaron e importaron; falta comprobarlas en navegador.
- Recuento mensual: la semana pertenece al mes de su lunes; solo se comparan semanas confirmadas por ambas personas y con puntos vigentes. El resultado final requiere todas las semanas del mes y compara promedios redondeados. `022_estado_cierres_semanales.sql` y `023_progreso_mensual.sql` están instalados; pasaron `025_progreso_mensual.sql` y `026_premios_mensuales.sql`. Se comprobó en navegador que noviembre muestra sus cinco semanas, los pendientes y los puntos de una semana, y que ambas cuentas pueden guardar su premio mensual. Falta comprobar la comparación completa con ambas cuentas en navegador.
- El selector mensual muestra los doce meses del año actual. Por ahora no permite elegir años anteriores; los datos históricos permanecen guardados.
- La prueba `027_resultados_mensuales.sql` comprobó con datos temporales un ganador para cada persona, empate, cierre faltante y cierre desactualizado; todo se revirtió. La comparación real en navegador se observará durante el uso.
- Correcciones del día anterior: `024_correcciones_dia_anterior.sql` está instalado y `028_correcciones_dia_anterior.sql` pasó con rollback. La app pasó validación live y se importó. Se comprobó en navegador la carga y corrección de Ocio; la base confirmó que el día permanece cerrado y el resumen refleja la corrección. Falta comprobar el recorrido de Cultivo en navegador. Los registros históricos no se reasignan.
- Navegación: el menú lateral agrupa las pantallas en Tiempo, Metas y Progreso, con iconos diferenciados. Se validó, importó y comprobó visualmente en desarrollo.

## Próximos pasos

El detalle de tareas conocidas está en `docs/PLAN-DE-TRABAJO.md`; es una lista revisable y no una estimación de duración.

1. Probar objetivos, progreso y autorización entre las dos cuentas desde las pantallas.
2. Probar en navegador el aviso cercano a otro cumplimiento de Cultivo.
3. Comprobar el recorrido de correcciones del día anterior y definir el tratamiento del tiempo previo sin día asignado.
4. Acordar los detalles pendientes del banco de ocio, puntuaciones, cierres semanales y recuentos mensuales antes de implementarlos.
5. Mantener actualizados las especificaciones, las pruebas y el registro de avances. Las pruebas SQL deben ejecutarse en una sesión de desarrollo dedicada y conservar los datos existentes.

## Referencias

- `docs/especificaciones/001-metas-de-cultivo.md`: reglas y estado del flujo de Cultivo.
- `docs/especificaciones/002-cronometros-y-cierres.md`: propuesta y estado de cronómetros, progreso y cierres.
- `docs/PRUEBAS-CULTIVO.md`: pruebas del flujo y aislamiento.
- `docs/IMPORTACION-APEX.md`: validación e importación con el valor privado del entorno.
- `AGENTS.md`: instrucciones del proyecto. `python3 scripts/check_repository.py` verifica documentación y patrones básicos de secretos, sin sustituir pruebas ni una revisión completa.
