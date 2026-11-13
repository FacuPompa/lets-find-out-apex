# Plan de pantallas de Cultivo — aplicación 100

Estado: diseño técnico propuesto para el prototipo; **no implementado en APEX**. Los borradores automáticos no pasaron las auditorías locales y se apartaron fuera del árbol vigente. La aplicación exportada conserva el contenido inicial. Siguiente paso: Facu crea el formulario inicial de meta desde Builder (página 2, `Nueva meta de cultivo`), luego se exportará como evidencia de sintaxis de la instancia. La numeración/composición de páginas de este plan se ajustará a ese recorrido guiado. El detalle del intento y sus límites está en LEEME-PRIMERO.md.

## Objetivo

Definir la composición propuesta para registrar metas y sesiones y consultar su progreso en la aplicación 100. La especificación de producto y los criterios definitivos están en `001-metas-de-cultivo.md`.

- Destino verificado por exportación SQLcl: aplicación 100, `Let's Find Out!`, workspace `LETS_FIND_OUT_DEV`, metadata APEXlang `26.1.0+3102`.
- Carpeta: `applications/let-s-find-out`. Conservar Home, Global Page, Login y autenticación Oracle APEX Accounts de la aplicación original.
- Página 2, `METAS-DE-CULTIVO`: región de alta con Persona, Semana (su lunes), Actividad, Mínimo en minutos, Veces por semana; botón Guardar meta. Debajo, informe clásico de metas y progreso, ordenado por semana descendente, persona, nombre e ID.
- Página 3, `REGISTRAR-CULTIVO`: región con Meta (selector que incluye persona, semana y mínimo), Día lógico y Minutos; botón Guardar sesión. Debajo, informe clásico de sesiones y si cada una alcanza el mínimo.
- Dos entradas en el menú existente, sin enlaces por fila en los informes. Solo altas; no edición ni borrado. Volver a la misma página mediante branch después de guardar para no reenviar el POST al actualizar.
- La semana de una sesión se consulta a partir de la meta en el servidor. No confiar en un campo oculto para ese dato. Las fechas se convierten con máscara explícita `YYYY-MM-DD`; los valores iniciales usan Buenos Aires y el día lógico sigue siendo elegible.
- Validación en servidor de números positivos y enteros, lunes válido, nombre no vacío y día dentro de la semana. Conservar las restricciones de la base como segunda comprobación.
- Mostrar las sesiones inferiores al mínimo sin contarlas como cumplimiento. El progreso usa `LFO_PROGRESO_CULTIVO_V`; no duplicar su fórmula en la interfaz.
- Tablas/columnas verificadas con `schema_information`; proyección de la vista ejecutada correctamente con SQLcl. Fuente del diseño de datos: `db/migrations/001_cultivo.sql`.
- Sintaxis: skill APEXlang 26.1, contrato `page,region,page-item,button,process,branch-a` y `region.column` con `region.type=classicReport`; reglas de informe clásico y contrato de columnas de la misma skill. Controles nativos, tema y plantillas centrales existentes; sin CSS personalizado.
- Evidencia de herramientas: compiler-truth local proviene del SQLcl instalado, build `26.2.0+3479`, hash `863417236b69`. La exportación original 26.1 pasó su auditoría. Esta evidencia local no sustituye la validación final contra APEX 26.1 de la base.
- La selección BRI/FACU es provisional y no aplica propiedad por cuenta. No se implementa aquí la política de objetivos bloqueados ni auditoría de correcciones; validar esas reglas antes del uso real.

## Criterios de aceptación

- El flujo cumple los criterios de `001-metas-de-cultivo.md` y restringe los cambios a la persona autenticada.
- Las operaciones de registro y consulta funcionan desde APEX y se prueban sin alterar datos reales.

## Verificación

Formateo estructural y auditoría de gramática por página, auditoría compiler-truth, validación SQL de las consultas y validación APEXlang contra la base. Después de importar, comprobar desde el navegador: crear una meta, registrar menos del mínimo, igual al mínimo y una sesión larga, y consultar el progreso sin duplicaciones al refrescar. No marcar este recorrido como probado solo porque compile.
