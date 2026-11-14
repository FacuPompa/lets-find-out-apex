# Let's Find Out! - Oracle APEX

Aplicación en desarrollo con Oracle APEX 26.1 y Oracle Autonomous Database. Este repositorio contiene la especificación, el modelo de datos, pruebas SQL y la exportación APEXlang de desarrollo.

En desarrollo hay metas de Cultivo, cronómetros, cierre diario básico y objetivos de horas con progreso semanal. Faltan integrar el cronómetro de Cultivo, permitir correcciones y completar las pruebas de permisos entre cuentas. El proyecto todavía no está listo para uso real.

- [Estado y próximos pasos](LEEME-PRIMERO.md)
- [Especificación de metas de cultivo](docs/especificaciones/001-metas-de-cultivo.md)
- [Cronómetros, progreso y cierres](docs/especificaciones/002-cronometros-y-cierres.md)
- [Cómo probar Cultivo](docs/PRUEBAS-CULTIVO.md)
- [Documentación y flujo de trabajo](docs/README.md)

Para revisar el repositorio localmente, ejecutar `python3 scripts/check_repository.py`. Esta comprobación no sustituye las pruebas en Oracle ni detecta todos los secretos.

## Exportación APEX y protección de sesión

La exportación versionada omite deliberadamente el `checksumSalt` de la instalación de desarrollo. El original se conserva fuera del repositorio. No importar esta copia directamente sobre la aplicación existente: cambiar el valor puede invalidar enlaces protegidos ya emitidos. Consultar el [procedimiento de validación e importación](docs/IMPORTACION-APEX.md). Nunca incorporar ese valor, wallets o credenciales al repositorio.
