# Registro de avances

Entradas breves para cambios relevantes. El estado actual y los próximos pasos están en `../LEEME-PRIMERO.md`; las reglas están en las especificaciones. No registrar secretos ni datos personales innecesarios.

## 2026-11-13 — Primera base de Cultivo

- Se creó el modelo SQL de metas y registros de cultivo en el esquema de desarrollo; su comprobación pasó según el estado documentado.
- Pendiente: aplicación y pantallas APEX, autenticación/autorización y correcciones con historial.

## 2026-11-13 — Documentación y flujo de trabajo

- Se organizó la documentación histórica y se escribió una primera especificación a partir de lo ya implementado.
- Se prepararon una plantilla de pull request y comprobaciones locales para GitHub Actions.
- Pendiente: crear el repositorio Git y ejecutar el flujo en GitHub; el flujo no conecta a Oracle ni sustituye las pruebas SQL.
# 13/11/2026 — Formulario de cultivo

Preparado por código el formulario de alta sin operaciones de modificación o borrado. Auditoría compiler-truth y validación live exitosas; importado con autorización de Facu en la aplicación 100 y verificado mediante reexportación. Pendiente prueba en navegador. Faltan sesiones, progreso y permisos por persona.

Facu probó el alta desde el navegador y recibió `row created`; SQLcl confirmó que la meta se guardó y recibió fecha de creación automática. Pendientes sesiones, progreso y permisos.

Se repitió con éxito la prueba SQL de Cultivo y se documentaron los pasos existentes y pendientes en `PRUEBAS-CULTIVO.md`. Se corrigió la estructura del plan de pantallas para que pase el control local de documentación. Pendientes: cuenta de Bri, autorización por persona, sesiones y progreso, tratamiento seguro del checksum de la exportación, repositorio y ejecución real de GitHub Actions.

Preparada una exportación versionable que omite el checksum de sesión de desarrollo, con respaldo privado fuera del proyecto y una comprobación local para evitar incorporar ese valor literal. Pendiente definir cómo suministrarlo al importar; ver `README.md`.

Primer commit `fba800e` subido a GitHub. La ejecución `43369234347` de GitHub Actions finalizó correctamente; comprueba documentación y patrones básicos de archivos sensibles, no la base de datos ni la interfaz APEX.
