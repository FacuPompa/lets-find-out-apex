# Plan de pantallas de Cultivo — aplicación 100

Estado: el alta, las sesiones y el progreso están implementados en desarrollo y se probaron parcialmente en navegador. Se aplicaron controles por persona; quedan pendientes pruebas completas entre ambas cuentas.

## Objetivo

Definir la composición propuesta para registrar metas y sesiones y consultar su progreso en la aplicación 100. La especificación de producto y los criterios definitivos están en `001-metas-de-cultivo.md`.

- Destino verificado por exportación SQLcl: aplicación 100, `Let's Find Out!`, workspace `LETS_FIND_OUT_DEV`, metadata APEXlang `26.1.0+3102`.
- Carpeta: `applications/let-s-find-out`. Conservar Home, Global Page, Login y autenticación Oracle APEX Accounts de la aplicación original.
- Página 2 existente: alta con Persona, Semana, Actividad, Mínimo en minutos y Veces por semana.
- Página 3 local, `REGISTRAR-CULTIVO`: región con Meta (selector que incluye persona y semana), Día lógico y Minutos; botón Guardar sesión. Región dinámica de progreso con persona, semana, nombre, cumplimientos, objetivo y faltantes, calculados por la vista SQL. El texto de la base se escapa al generar HTML.
- El menú incluye acceso a la página 3. Solo se agregan sesiones; no se editan ni eliminan. Un branch vuelve a la misma página después de guardar.
- La semana de una sesión se consulta a partir de la meta en el servidor. No confiar en un campo oculto para ese dato. Las fechas se convierten con máscara explícita `YYYY-MM-DD`; los valores iniciales usan Buenos Aires y el día lógico sigue siendo elegible.
- Validación en servidor de números positivos y enteros, lunes válido, nombre no vacío y día dentro de la semana. Conservar las restricciones de la base como segunda comprobación.
- Mostrar las sesiones inferiores al mínimo sin contarlas como cumplimiento. El progreso usa `LFO_PROGRESO_CULTIVO_V`; no duplicar su fórmula en la interfaz.
- Tablas/columnas verificadas con `schema_information`; proyección de la vista ejecutada correctamente con SQLcl. Fuente del diseño de datos: `db/migrations/001_cultivo.sql`.
- Sintaxis: skill APEXlang 26.1, contrato `page,region,page-item,button,process,branch-a`, variantes de región estática y contenido dinámico. La página usa controles nativos, tema y plantillas centrales existentes; sin CSS personalizado. El proceso llama la API interna `LFO_REGISTRAR_SESION`.
- Evidencia de herramientas: compiler-truth local proviene del SQLcl instalado, build `26.2.0+3479`, hash `863417236b69`. La exportación original 26.1 pasó su auditoría. Esta evidencia local no sustituye la validación final contra APEX 26.1 de la base.
- La selección Persona B/Persona A es provisional y no aplica propiedad por cuenta. No se implementa aquí la política de objetivos bloqueados ni auditoría de correcciones; validar esas reglas antes del uso real.

## Criterios de aceptación

- El flujo cumple los criterios de `001-metas-de-cultivo.md` y restringe los cambios a la persona autenticada.
- Las operaciones de registro y consulta funcionan desde APEX y se prueban sin alterar datos reales.

## Verificación

Formateo estructural y auditoría de gramática por página, auditoría compiler-truth, validación SQL de las consultas y validación APEXlang contra la base. Después de importar, comprobar desde el navegador: crear una meta, registrar menos del mínimo, igual al mínimo y una sesión larga, y consultar el progreso sin duplicaciones al refrescar. No marcar este recorrido como probado solo porque compile.

## Semana seleccionada y legibilidad (13/11/2026)

Se importó a desarrollo una selección persistente por cuenta, independiente para cada persona, mediante las preferencias de APEX. La página Semana acepta cualquier día y guarda el lunes correspondiente; sin selección se usa el lunes de la semana actual en la zona horaria del proyecto. Una región global muestra la selección. El alta de metas la toma automáticamente; el selector de meta, la validación del registro y el progreso usan la misma semana. El día de sesión inicia en la fecha actual y sigue editable, incluso cuando se está viendo otra semana. El progreso usa una tabla con encabezados y escape HTML. Pasaron la validación APEX, la auditoría y la prueba SQL de aislamiento; quedan pendientes las pruebas de interfaz entre cuentas, recarga, fechas, navegación y selección histórica. La selección de semana no implementa autorización de datos.


## Pantalla integrada (importada a desarrollo)

En Registrar cultivo se reúne la elección persistente de semana, la tabla de progreso a ancho disponible y el formulario de sesión. Se elimina Semana del menú; el alta de metas sigue usando la preferencia de la cuenta. Cambiar semana debe funcionar sin completar el formulario de sesión. En pantallas angostas, la tabla debe permitir desplazamiento horizontal. La versión fue importada a desarrollo; quedan pendientes pruebas de navegador de cada acción, la persistencia y el diseño.
