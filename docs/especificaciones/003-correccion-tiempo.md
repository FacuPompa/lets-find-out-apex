# 003 — Corrección de tiempo registrado

**Estado:** la corrección por categoría o actividad y la carga manual están importadas a desarrollo; falta probar los recorridos en navegador.

## Objetivo

Cada persona podrá consultar sus cargas de cronómetro asociadas a un día personal y corregir su duración y categoría. Para asignar una carga a Cultivo se elige una actividad propia de la semana del día personal. Se conserva el registro original y el historial de correcciones; los resúmenes de día, progreso y constancia usan el resultado corregido. Un cierre existente debe reflejar la corrección sin reabrir el día.

El recorrido empieza por elegir una categoría de Trabajo, Estudio u Ocio o una actividad de Cultivo. Se podrán agregar cargas manuales de las tres categorías al día personal abierto, aunque no se haya iniciado un reloj, y corregirlas después. Las sesiones manuales de Cultivo se podrán corregir por actividad y minutos manteniendo la fecha de la sesión y su historial. Si no existe día abierto se crea uno con la fecha actual; se comprueba que la fecha y el día abierto mostrado no hayan cambiado entre mostrar y guardar el formulario.

## Criterios de aceptación

- [ ] Consultar y corregir únicamente cargas propias con día asignado; comprobación de interfaz pendiente.
- [ ] Corregir duración y categoría; para Cultivo, elegir una actividad propia de la semana correspondiente; comprobación de interfaz pendiente.
- [x] Conservar el registro original y cada corrección, sin duplicar cargas ni recuperar excesos de Cultivo previamente descartados; comprobado en SQL.
- [x] Actualizar el resumen diario, la constancia, el progreso de Cultivo y el cierre ya guardado; comprobado en SQL.
- [x] Rechazar versiones desactualizadas y solicitudes a registros o actividades ajenas; comprobado en SQL.
- [ ] Agregar y corregir cargas manuales de Trabajo, Estudio y Ocio; comprobación de interfaz pendiente.
- [ ] Corregir sesiones manuales de Cultivo y conservar su historial; comprobación de interfaz pendiente.

## Verificación

Las pruebas SQL `018_correccion_tiempo.sql`, `019_tiempo_manual.sql` y `020_correccion_cultivo_manual.sql` pasaron con datos temporales y rollback. La pantalla ampliada pasó validación live, se importó a desarrollo y se verificaron sus páginas, procesos y objetos. Falta la prueba en navegador.

No se cambian los intervalos físicos ni se vuelve a registrar tiempo pendiente. Las cargas históricas sin día personal necesitan un recorrido propio y no se asignan automáticamente. Una carga manual de Trabajo, Estudio u Ocio se corrige entre esas categorías; para Cultivo se usa el registro por actividad. Un cambio hacia Cultivo respeta el límite de la meta y el descarte de excesos. La propiedad, la actividad, los valores y las versiones se verifican en el servidor.
