# Let's Find Out! — Nueva versión en Oracle APEX

Actualizado: 13/11/2026.

El usuario decidió iniciar una implementación nueva en Oracle APEX, conservando la versión anterior en `/home/pompa/projects/full/letsFindOut`. No se debe borrar ni modificar la versión anterior sin una petición explícita.

## Estado actual

- Oracle Autonomous Database Always Free, Transaction Processing, Oracle Database 26ai, región São Paulo.
- APEX 26.1.6 verificado como VALID. Workspace `LETS_FIND_OUT_DEV` y esquema `LFO_APP_DEV` creados; el usuario confirmó que puede entrar a APEX.
- El ingreso original por ADB SSO devolvía 502. Se cambió la autenticación de APEX Builder a Database Accounts (`DB`) y se confirmó el acceso. No modificar el método sin necesidad.
- El usuario instaló Oracle SQL Developer para VS Code, descargó un wallet y guardó la conexión `lets-find-out-dev` con el esquema. Test exitoso y SQLcl 26.3 conectado desde VS Code.
- El usuario sincronizó las skills oficiales `apex,db` con SQLcl. Están disponibles en el directorio de skills de Codex. Se emitieron avisos de libssh/gio, pero la sincronización terminó en SUCCESS.
- SQLcl MCP está disponible y probado en esta sesión. Conexión guardada `lets-find-out-dev`, usuario y esquema `LFO_APP_DEV`, SQLcl 26.3.1.0, versión de base reportada por el conector `23.26.4.1.0`, NLS `SPANISH_SPAIN.AL32UTF8`, autocommit desactivado. El ejecutable no está en el PATH de la terminal; el MCP funciona mediante la ruta absoluta de la extensión de VS Code. Revisarla si se actualiza la extensión.
- Facu creó la aplicación **100**, `Let's Find Out!`, en `LETS_FIND_OUT_DEV`. Verificada y exportada a APEXlang en `applications/let-s-find-out/`; incluye la página 2 de alta de metas probada, además de Global Page, Home y Login. Usa Oracle APEX Accounts. No hay infraestructura de producción configurada. Se eligió no contratar servicios pagos.

## Reglas y referencias

`docs/historico/PLAN-DE-ARRANQUE-V1.md` y `docs/historico/lets_find_out_contexto_completo.md` son copias de los documentos del proyecto anterior, útiles como referencia. Sus descripciones de implementación Astro/Supabase y estado técnico son históricas; no representan la arquitectura de esta nueva versión. Cultivo no tiene áreas ni comodín; las actividades de las metas son configurables. Se habla de metas semanales y metas de cultivo, no de misiones.

La organización de documentación y el flujo de trabajo por especificaciones están en `docs/README.md`. La primera especificación es `docs/especificaciones/001-metas-de-cultivo.md`.

Hay una plantilla de pull request y una comprobación local de archivos sensibles y estructura mínima de especificaciones. GitHub Actions está configurado para ejecutar esa comprobación cuando se cree el repositorio; aún no se ejecutó en GitHub. El historial breve de avances está en `docs/REGISTRO-DE-AVANCES.md`.

## Primera entrega: metas de cultivo (13/11/2026)

Facu pidió empezar por crear una actividad con nombre, tiempo mínimo y veces por semana, registrar cumplimientos, recibir guía paso a paso y mantener este archivo actualizado. Este pedido fija el primer recorrido antes del resto del tablero.

### Decisiones para este primer paso

- Cada meta pertenece a Bri o Facu y a una semana identificada por la fecha de su lunes.
- Campos de la meta: nombre libre, mínimo en minutos enteros positivos y repeticiones semanales enteras positivas. No limitar repeticiones a siete: pueden hacerse varias sesiones el mismo día.
- Cada sesión registra meta, semana, día lógico elegido y minutos enteros positivos. Debe pertenecer a la semana de la meta. La fecha lógica no se deduce de la medianoche del servidor.
- Una sesión que alcanza el mínimo suma exactamente un cumplimiento. Las sesiones inferiores se conservan sin sumar; no se acumulan entre sí. Una sesión larga no se divide.
- El progreso muestra registros, cumplimientos, faltantes y porcentaje con tope visual de 100 %. Se conserva el número real de cumplimientos si se supera la meta.
- Por ahora `persona` identifica BRI/FACU; no representa una cuenta autenticada ni aplica permisos. La vinculación a cuentas y la autorización siguen pendientes.
- No se implementó aún bloqueo de objetivos, restricciones temporales de carga ni auditoría de correcciones. Antes de habilitar edición real, resolver el historial y evitar que cambiar el mínimo recalcule retroactivamente cumplimientos. No presentar este prototipo como listo para uso real.
- El puntaje agregado de Cultivo sigue abierto; este paso solo calcula el progreso de cada meta.

### Archivos y estado comprobado

- `db/migrations/001_cultivo.sql`: ejecutado mediante MCP en `LFO_APP_DEV`. Creadas `LFO_METAS_CULTIVO`, `LFO_REGISTROS_CULTIVO`, sus restricciones/índice y `LFO_PROGRESO_CULTIVO_V`. Los bloques permiten reejecución sin borrar datos; no reconcilian definiciones divergentes de objetos preexistentes.
- `db/checks/001_cultivo.sql`: prueba con savepoint y rollback de sus propios datos. Comprueba progreso inicial, sesiones de 29/30/90 minutos con mínimo 30, varias sesiones el mismo día, minutos inválidos, límites de semana, exceso de objetivo y separación entre metas. **Pasó** tras la corrección de cuota confirmada por Facu y verificada mediante MCP. El primer intento había fallado con `ORA-01950`.
- La prueba SQL revierte sus datos; conservar la meta real de Facu creada desde APEX (ID 3).
- Existe la aplicación 100 y su exportación APEXlang (`mmdVersion: 26.1.0+3102`). La página de alta de metas fue probada; faltan sesiones y progreso.
- Git está inicializado en `main` y conectado a `origin`. El primer commit `fba800e` se subió a GitHub y la ejecución de GitHub Actions `43369234347` terminó correctamente el 13/11/2026.

### Cuota resuelta y siguiente paso guiado

1. **Hecho:** Facu ejecutó el cambio administrativo. Se verificó `MAX_BYTES = 104857600` para `LFO_APP_DEV` en `DATA` (100 MiB). La prueba terminó correctamente y ambas tablas quedaron con cero filas tras el rollback. No se recrearon tablas.
2. **Herramientas verificadas:** `help apex` confirma soporte para generate, validate, import y export APEXlang. `apex list` no encontró aplicaciones visibles en la conexión actual. El preflight oficial pasó usando SQLcl en PATH solo para ese proceso; no se modificó la configuración global de la terminal. Comando: `env PATH=/home/pompa/.vscode/extensions/oracle.sql-developer-26.3.1-linux-x64/dbtools/sqlcl/bin:$PATH node tools/apexctl.mjs runtime preflight --db-connection-name lets-find-out-dev --execution-mode path --preflight-only`, desde la carpeta de la skill `apexlang-generation` de 26.1. Esto verifica capacidades, no valida una aplicación concreta. No se encontró build root local `/home/pompa/apex`; el runtime SQLcl sí está disponible.
3. **Hecho:** Facu confirmó Application ID 100. `apex list -applicationid 100` y `apex export -applicationid 100 -exptype APEXLANG -dir /home/pompa/projects/full/letsFindOutApex/applications` confirmaron nombre y workspace. El probe oficial resolvió `applications/let-s-find-out` como única aplicación estándar. El despliegue exportado conserva ID 100. La exportación original pasó compiler-truth audit local.
4. **Intento local y limitación:** se prepararon borradores de páginas 2 y 3 (alta de meta y sesión, informes), pero no pasaron las auditorías locales. El compiler-truth de SQLcl instalado es build `26.2.0+3479`, distinto del metadata de la aplicación 26.1. El auditor devuelve ambigüedad entre columnas 7320 (informe clásico) y 7710 (columnas genéricas); su código considera ambas activas para NATIVE_SQL_REPORT. También trata un `if :P2_PERSONA` dentro del PL/SQL como propiedad. El formateador señala falsos problemas en valores escalares con dos puntos/paréntesis. No se modificaron las skills ni se importó ese código. Los borradores se apartaron a `/tmp/lfo-apex100-drafts/` (temporales, no fuente vigente), y el menú original fue restaurado. La aplicación exportada en `applications/` conserva el contenido original. No afirmar que la validación live falló: todavía no se ejecutó sobre esos borradores.
5. **Hecho:** Facu creó la página 2 `Nueva meta de cultivo` y está en Page Designer. Exportación actualizada en `applications/let-s-find-out/`. Confirmados los labels y `P2_PERSONA` como Select List estático con `Bri`/`BRI` y `Facu`/`FACU`. Facu eliminó `P2_CREADO_EN`; se verificó la ausencia del item y su validación en la exportación. La base tiene default `SYSTIMESTAMP`, pendiente de prueba desde el formulario. La región aún permite altas, modificaciones y borrados: limitar a altas antes de probar. No cargar datos todavía.
6. Exportar nuevamente la página generada por Builder para tener evidencia real de sintaxis 26.1, y continuar con altas de metas, sesiones y progreso. El plan propuesto está en `docs/especificaciones/001-plan-pantallas.md`. Antes de editar con APEXlang, resolver las limitaciones de las auditorías o trabajar sobre contratos inequívocos; no saltar validaciones para importar. La skill `apexlang-generation/SKILL.md` requiere: "Every changed `.apx` must pass compiler-truth audit before live use."
7. Diseñar permisos, bloqueo e historial antes de habilitar uso real de la pareja. Para futuras importaciones APEXlang, validar contra el runtime real y seguir el flujo de la skill correspondiente.

No copiar contraseñas ni el wallet al repositorio. Mantener la guía en pasos cortos y distinguir lo preparado, lo ejecutado, lo probado y lo pendiente.

## Cambio de modalidad y validación del formulario

Facu pidió que el asistente haga los cambios por código en vez de indicarle ajustes manuales. Se preparó en `applications/let-s-find-out/pages/p00002-nueva-meta-de-cultivo.apx` el formulario con solo `add` y fuente `type: tableView` explícita. La auditoría compiler-truth del código pasó y la validación live pasó. Con autorización explícita de Facu, se importó la aplicación 100 en el workspace `LETS_FIND_OUT_DEV` (ID `9513994217514688`); la reexportación posterior confirmó `allowedOperations: add`. El primer intento no importó porque faltaba el ID del workspace; se resolvió y el segundo pasó. El diagnóstico de procedencia de metadatos locales 26.1 frente al compilador 26.2 sigue siendo informativo para el runtime. Pendientes: prueba del formulario en navegador, formulario de sesiones, progreso, permisos y auditoría; no usar el prototipo como app terminada.

Facu probó el formulario en el navegador: recibió `row created` y volvió a Home. Verificado por SQLcl: meta ID 3, FACU, semana 2026-11-16, Leer, mínimo 30 minutos, 3 veces; `CREADO_EN` quedó informado automáticamente. Es un registro creado por Facu: conservarlo. El alta está probada; faltan sesiones, progreso, permisos y auditoría de cambios.

## Orden de trabajo solicitado

Facu pidió terminar el flujo de Cultivo y sus pruebas, documentar cómo probarlo, subirlo a GitHub y verificar GitHub Actions; recién después evaluar herramientas o un agente revisor según problemas concretos. Bri aún no tiene cuenta. Falta vincular cuentas reales a las personas e implementar autorización por persona antes de dar el flujo por terminado. Se volvió a ejecutar la prueba SQL satisfactoriamente; `docs/PRUEBAS-CULTIVO.md` distingue comprobaciones realizadas y pendientes. El chequeo local de repositorio fallaba por secciones ausentes en el plan de pantallas; se corrigieron y ahora pasa. `gh` está autenticado y se configuró el repositorio remoto indicado por Facu. La copia versionable omite el `checksumSalt`; antes de importar debe suministrarse de forma segura el valor del entorno. El verificador detecta valores literales en archivos APEXlang. No se creó ningún agente revisor.

Facu autorizó elegir el nombre de acceso de Bri: se seleccionó `BRI`. Es un nombre previsto, **la cuenta aún no fue creada**; faltan configurar sus credenciales de manera segura y comprobar que pueda iniciar sesión. El nombre de usuario de Facu aún no fue identificado. Mantener la identidad de la persona separada del nombre de acceso para permitir cambios posteriores sin perder sus metas.

## Preparación del primer commit

Facu indicó el remoto `https://github.com/FacuPompa/lets-find-out-apex`, público y sin ramas al consultarlo. La copia versionable de `application.apx` omite el `checksumSalt`; el archivo original se guardó con permisos restringidos fuera del repositorio, en `~/.local/share/lets-find-out-apex/private/application-original.apx`. No importar la copia versionable sobre la aplicación existente hasta disponer de un proceso que suministre el valor correcto; cambiarlo puede invalidar enlaces protegidos. El verificador local detecta valores literales de 64 dígitos hexadecimales en propiedades `checksumSalt` de archivos APEXlang, además de sus comprobaciones anteriores. El primer commit no significa que el flujo de Cultivo esté terminado.
