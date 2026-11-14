# 001 — Metas de cultivo

**Estado:** modelo de base, alta de metas y primera prueba de registro y progreso implementados; pruebas adicionales de interfaz y autorización por persona pendientes. Documento inicial reconstruido a partir de las decisiones y pruebas registradas en `../../LEEME-PRIMERO.md`. No es evidencia de que la especificación se haya escrito antes del código.

## Objetivo y alcance

Permitir que cada persona defina una actividad libre para una semana, indicando duración mínima y cantidad de veces, registre sesiones y consulte su progreso. Ejemplo: caminar al menos 30 minutos, 4 veces; varias sesiones pueden ocurrir el mismo día.

Esta primera entrega cubre duración en minutos. Medidas por capítulos u otras unidades quedan pendientes de diseño. Cultivo no tiene áreas ni comodín.

La semana se elige una vez y se comparte entre las pantallas de cada cuenta; cada persona conserva su selección independiente. Se puede cambiar para consultar otra semana. La selección inicial es la semana actual y el día de la sesión inicia en la fecha actual, pero sigue siendo editable. Cuando el día inicial no pertenece a la semana elegida debe ajustarse antes de guardar. Estas mejoras se validaron e importaron a desarrollo, pero aún no se han probado en navegador.

## Criterios de aceptación

- [x] La base permite guardar una meta con persona, semana, nombre, minutos mínimos y repeticiones positivas.
- [x] Una sesión guarda la meta, el día lógico elegido y los minutos; el día debe pertenecer a la semana de la meta.
- [x] El cálculo histórico cuenta como máximo un cumplimiento por sesión y conserva sin contar las inferiores al mínimo. Los registros nuevos usan la acumulación descrita más abajo.
- [x] El progreso conserva el número real de cumplimientos y limita el porcentaje mostrado a 100 %.
- [ ] Crear metas, registrar sesiones y consultar progreso desde pantallas APEX.
- [ ] Vincular las metas a cuentas autenticadas y verificar permisos por persona.
- [ ] Definir e implementar cómo se corrigen datos sin perder historial ni alterar retroactivamente cumplimientos.
- [ ] Elegir la semana una vez por cuenta y usarla al crear metas, registrar sesiones y consultar progreso.
- [ ] Mostrar el progreso con columnas claras y proponer el día actual al registrar una sesión.

Las casillas marcadas se refieren únicamente al modelo y la comprobación SQL informados en el registro de estado, no a la aplicación completa.

## Verificación y estado

Aplicación 100 verificada con SQLcl en `LETS_FIND_OUT_DEV` y exportada a `../../applications/let-s-find-out/` con metadata APEXlang `26.1.0+3102`. Usa Oracle APEX Accounts. Se probó el alta de una meta en la página 2. La página 3 de sesiones y progreso se probó con una sesión en navegador y el resultado se confirmó en la base; faltan más casos de interfaz y la autorización por persona. La guía de comprobación y su estado está en `../PRUEBAS-CULTIVO.md`.

`../../db/migrations/001_cultivo.sql` crea el modelo; `../../db/checks/001_cultivo.sql` comprueba sus reglas con datos temporales y rollback. Según `../../LEEME-PRIMERO.md`, la comprobación pasó en el esquema de desarrollo y no quedaron datos de ejemplo. No se repitió esa prueba al crear este documento.

## Decisiones provisionales y preguntas abiertas

- La implementación utiliza códigos de persona existentes; todavía no están vinculados a cuentas ni permisos.
- La semana se identifica por su lunes; el día lógico se elige manualmente. Faltan reglas de edición y restricciones temporales.
- No está definido cómo agregar varias metas de cultivo para el puntaje del rubro.
- Confirmar cómo se resuelven actividades con mínimo por capítulos u otra unidad.
- La app todavía no está lista para uso real: faltan pruebas completas de autorización e historial de correcciones.


## Vinculación de cuentas (importada a desarrollo)

La asignación administrativa vincula una cuenta APEX con un código de persona estable; puede actualizarse si cambia el nombre de usuario. La persona se determina en el servidor y no se elige al crear la meta. La selección y el registro de sesiones se limitan a metas de esa persona, incluso ante un identificador modificado en la solicitud. Una cuenta sin asignación no puede crear metas ni registrar sesiones. El progreso compartido continúa visible. Las dos cuentas de uso fueron creadas y vinculadas. La aplicación fue importada a desarrollo; quedan pendientes las pruebas de extremo a extremo y de acceso indebido con dos cuentas reales.


## Integración acumulativa

La migración `010_cultivo_acumulado.sql` agrega registros vinculados sin modificar los anteriores. Las sesiones manuales nuevas y los intervalos nuevos del cronómetro se acumulan por actividad; se contabilizan múltiplos del mínimo hasta alcanzar la meta y el tiempo excedente posterior se conserva para el registro de horas, pero no se recupera para cumplimientos futuros. La vista nueva preserva los resultados de las sesiones anteriores. La elección y escritura comprueban la cuenta y la semana del día personal; el tiempo sin día o de otra semana no se asigna automáticamente. La prueba SQL `012_cultivo_acumulado.sql` pasó con rollback y la aplicación se importó a desarrollo. Se confirmaron en navegador la acumulación y la pausa; falta la prueba visual del aviso cercano.
