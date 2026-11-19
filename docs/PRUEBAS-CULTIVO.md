# Pruebas de metas de cultivo

Las comprobaciones SQL de abajo se ejecutaron en desarrollo. En APEX se probaron el alta, la acumulación de dos sesiones cortas y la pausa del cronómetro al empezar el registro. Usar datos de prueba identificables y no borrar datos reales.

## Base de datos

Conectarse como `LFO_APP_DEV` a una base de desarrollo y ejecutar con SQLcl:

```sql
@db/checks/001_cultivo.sql
```

El script crea sus propios datos y hace rollback al savepoint, sin confirmar ni revertir transacciones anteriores. Ejecutarlo en una sesión dedicada. Debe terminar sin errores; prueba el progreso inicial, minutos inferiores, iguales y superiores al mínimo, sesiones el mismo día, límites de semana, entradas inválidas, exceso del objetivo y separación de metas. La última ejecución verificada terminó correctamente el 13/11/2026.

Con `db/migrations/002_registrar_sesion.sql` aplicada, ejecutar también `@db/checks/002_registrar_sesion.sql`. Requiere al menos una meta existente para obtener un código de persona válido. Comprueba el registro a través de la API interna y revierte sus datos; pasó el 13/11/2026. La API no reemplaza las verificaciones de autorización por cuenta.

Con `db/migrations/003_cuentas_persona.sql` aplicada y al menos una asignación, `@db/checks/004_cuentas_persona.sql` verifica con sesiones APEX temporales una cuenta asignada y el rechazo de una desconocida. Pasó el 13/11/2026. No reemplaza las pruebas de ingreso ni de solicitudes manipuladas con dos cuentas.

Con `db/migrations/010_cultivo_acumulado.sql` aplicada, ejecutar `@db/checks/012_cultivo_acumulado.sql` en una sesión dedicada. La prueba requiere que la persona técnica de prueba indicada en el script no tenga cronómetros y revierte los datos temporales. Comprueba acumulación, múltiplos, descarte del exceso, aislamiento, semana, aviso y cargas sin duplicados. Pasó el 14/11/2026.

## Pantallas

1. Ingresar a la aplicación 100 con una cuenta de prueba. Crear una meta para una semana, con mínimo de 30 minutos y 3 sesiones. Comprobar que se guarde y que la fecha de creación se complete automáticamente. **Probado:** Se creó la meta Leer, 30 minutos, 3 veces para la semana del 16/11/2026.
2. **Probado:** dos sesiones cortas del cronómetro sumaron un cumplimiento; el reloj se pausa al comenzar a registrar. **Pendiente:** comprobar visualmente el aviso cercano al siguiente cumplimiento y sus opciones.
3. **Pendiente en interfaz:** intentar registrar un día fuera de la semana y minutos inválidos; deben rechazarse sin guardar. Comprobar que los registros nuevos acumulan sobrantes y que el historial anterior conserva su cálculo.
   `@db/checks/003_semana_seleccionada.sql` comprobó que dos identificadores de prueba mantienen preferencias independientes. La selección, el filtrado y la persistencia a través de sesiones aún requieren prueba de interfaz.
4. **Pendiente de cuentas y autorización:** con cuentas de Persona B y Persona A, verificar desde las pantallas que cada persona solo puede crear o modificar sus propios datos, incluso si intenta alterar los parámetros de la solicitud. `db/checks/030_aislamiento_metas_semanales.sql` pasó con cuentas temporales para cambios de metas semanales en ambos sentidos y para una cuenta sin vincular; no sustituye el recorrido completo con las cuentas reales. Comprobar que no se puedan editar ni borrar metas sin las reglas de historial y bloqueo definidas.

Las pruebas de interfaz aún no son automáticas. Conservar la meta creada durante la prueba.
