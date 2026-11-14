# Pruebas de metas de cultivo

Las comprobaciones SQL de abajo se ejecutaron en desarrollo. El alta y un registro de sesión ya se probaron desde APEX; los demás casos de interfaz siguen pendientes. Usar datos de prueba identificables y no borrar datos reales.

## Base de datos

Conectarse como `LFO_APP_DEV` a una base de desarrollo y ejecutar con SQLcl:

```sql
@db/checks/001_cultivo.sql
```

El script crea sus propios datos y hace rollback al savepoint, sin confirmar ni revertir transacciones anteriores. Ejecutarlo en una sesión dedicada. Debe terminar sin errores; prueba el progreso inicial, minutos inferiores, iguales y superiores al mínimo, sesiones el mismo día, límites de semana, entradas inválidas, exceso del objetivo y separación de metas. La última ejecución verificada terminó correctamente el 13/11/2026.

Con `db/migrations/002_registrar_sesion.sql` aplicada, ejecutar también `@db/checks/002_registrar_sesion.sql`. Requiere al menos una meta existente para obtener un código de persona válido. Comprueba el registro a través de la API interna y revierte sus datos; pasó el 13/11/2026. La API no reemplaza las verificaciones de autorización por cuenta.

Con `db/migrations/003_cuentas_persona.sql` aplicada y al menos una asignación, `@db/checks/004_cuentas_persona.sql` verifica con sesiones APEX temporales una cuenta asignada y el rechazo de una desconocida. Pasó el 13/11/2026. No reemplaza las pruebas de ingreso ni de solicitudes manipuladas con dos cuentas.

## Pantallas

1. Ingresar a la aplicación 100 con una cuenta de prueba. Crear una meta para una semana, con mínimo de 30 minutos y 3 sesiones. Comprobar que se guarde y que la fecha de creación se complete automáticamente. **Probado:** Se creó la meta Leer, 30 minutos, 3 veces para la semana del 16/11/2026.
2. **Probado parcialmente:** se registró una sesión desde APEX y la vista confirmó un cumplimiento de tres y dos faltantes. **Pendiente en interfaz:** probar sesiones de 29, 30 y 90 minutos sobre una meta de prueba, verificar dos cumplimientos y luego agregar otra sesión válida para alcanzar tres.
   También se comprobó que una sesión por debajo del mínimo dejó una meta de prueba en cero de tres.
3. **Pendiente en interfaz:** intentar registrar un día fuera de la semana y minutos inválidos; deben rechazarse sin guardar. Comprobar que dos sesiones el mismo día se cuentan por separado y una sesión larga solo cuenta una vez.
   `@db/checks/003_semana_seleccionada.sql` comprobó que dos identificadores de prueba mantienen preferencias independientes. La selección, el filtrado y la persistencia a través de sesiones aún requieren prueba de interfaz.
4. **Pendiente de cuentas y autorización:** con cuentas de Persona B y Persona A, verificar que cada persona solo puede crear o modificar sus propios datos, incluso si intenta alterar los parámetros de la solicitud. Comprobar que no se puedan editar ni borrar metas sin las reglas de historial y bloqueo definidas.

Las pruebas de interfaz aún no son automáticas. Conservar la meta creada durante la prueba.
