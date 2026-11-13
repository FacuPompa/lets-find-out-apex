# Let's Find Out! — Oracle APEX

Aplicación privada para Bri y Facu, en desarrollo con Oracle APEX 26.1 y Oracle Autonomous Database. Este repositorio contiene la especificación, el modelo de datos, pruebas SQL y la exportación APEXlang de desarrollo.

El alta de metas de cultivo ya fue probada. Las pantallas de sesiones y progreso, y los permisos individuales, siguen pendientes. El proyecto todavía no está listo para uso real.

- [Estado y próximos pasos](LEEME-PRIMERO.md)
- [Especificación de metas de cultivo](docs/especificaciones/001-metas-de-cultivo.md)
- [Cómo probar Cultivo](docs/PRUEBAS-CULTIVO.md)
- [Documentación y flujo de trabajo](docs/README.md)

Para revisar el repositorio localmente, ejecutar `python3 scripts/check_repository.py`. Esta comprobación no sustituye las pruebas en Oracle ni detecta todos los secretos.

## Exportación APEX y protección de sesión

La exportación versionada omite deliberadamente el `checksumSalt` de la instalación de desarrollo. El original se conserva fuera del repositorio. No importar esta copia directamente sobre la aplicación existente sin resolver previamente cómo suministrar el valor adecuado para ese entorno: cambiarlo puede invalidar enlaces protegidos ya emitidos. Nunca incorporar ese valor, wallets o credenciales al repositorio.
