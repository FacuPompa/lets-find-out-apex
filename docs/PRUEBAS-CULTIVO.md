# Pruebas de metas de cultivo

Las comprobaciones SQL de abajo existen y se ejecutaron en desarrollo. Las pruebas de sesiones y progreso desde APEX son el recorrido previsto y todavía no están disponibles hasta construir esas pantallas. Usar datos de prueba identificables y no borrar datos reales.

## Base de datos

Conectarse como `LFO_APP_DEV` a una base de desarrollo y ejecutar con SQLcl:

```sql
@db/checks/001_cultivo.sql
```

El script crea sus propios datos y hace rollback al savepoint, sin confirmar ni revertir transacciones anteriores. Ejecutarlo en una sesión dedicada. Debe terminar sin errores; prueba el progreso inicial, minutos inferiores, iguales y superiores al mínimo, sesiones el mismo día, límites de semana, entradas inválidas, exceso del objetivo y separación de metas. La última ejecución verificada terminó correctamente el 13/11/2026.

## Pantallas

1. Ingresar a la aplicación 100 con una cuenta de prueba. Crear una meta para una semana, con mínimo de 30 minutos y 3 sesiones. Comprobar que se guarde y que la fecha de creación se complete automáticamente. **Probado:** Facu creó Leer, 30 minutos, 3 veces para la semana del 16/11/2026.
2. **Pendiente de implementación:** registrar sesiones de 29, 30 y 90 minutos el mismo día lógico de esa semana. Consultar el progreso: tres registros, dos cumplimientos y un faltante. Registrar otra sesión de 30 minutos: tres cumplimientos y cero faltantes.
3. **Pendiente de implementación:** intentar registrar un día fuera de la semana y minutos inválidos; deben rechazarse sin guardar. Comprobar que dos sesiones el mismo día se cuentan por separado y una sesión larga solo cuenta una vez.
4. **Pendiente de cuentas y autorización:** con cuentas de Bri y Facu, verificar que cada persona solo puede crear o modificar sus propios datos, incluso si intenta alterar los parámetros de la solicitud. Comprobar que no se puedan editar ni borrar metas sin las reglas de historial y bloqueo definidas.

Las pruebas de interfaz aún no son automáticas. No borrar la meta que Facu creó durante su prueba.
