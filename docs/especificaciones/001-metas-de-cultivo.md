# 001 — Metas de cultivo

**Estado:** modelo de base y alta de metas implementados y probados; registro de sesiones, progreso y autorización por persona pendientes. Documento inicial reconstruido a partir de las decisiones y pruebas registradas en `../../LEEME-PRIMERO.md`. No es evidencia de que la especificación se haya escrito antes del código.

## Objetivo y alcance

Permitir que cada persona defina una actividad libre para una semana, indicando duración mínima y cantidad de veces, registre sesiones y consulte su progreso. Ejemplo: caminar al menos 30 minutos, 4 veces; varias sesiones pueden ocurrir el mismo día.

Esta primera entrega cubre duración en minutos. Medidas por capítulos u otras unidades quedan pendientes de diseño. Cultivo no tiene áreas ni comodín.

## Criterios de aceptación

- [x] La base permite guardar una meta con persona, semana, nombre, minutos mínimos y repeticiones positivas.
- [x] Una sesión guarda la meta, el día lógico elegido y los minutos; el día debe pertenecer a la semana de la meta.
- [x] Una sesión igual o superior al mínimo cuenta una vez; una inferior se conserva sin contar. No se acumulan sesiones ni se divide una sesión larga.
- [x] El progreso conserva el número real de cumplimientos y limita el porcentaje mostrado a 100 %.
- [ ] Crear metas, registrar sesiones y consultar progreso desde pantallas APEX.
- [ ] Vincular las metas a cuentas autenticadas y verificar permisos por persona.
- [ ] Definir e implementar cómo se corrigen datos sin perder historial ni alterar retroactivamente cumplimientos.

Las casillas marcadas se refieren únicamente al modelo y la comprobación SQL informados en el registro de estado, no a la aplicación completa.

## Verificación y estado

Aplicación 100 verificada con SQLcl en `LETS_FIND_OUT_DEV` y exportada a `../../applications/let-s-find-out/` con metadata APEXlang `26.1.0+3102`. Usa Oracle APEX Accounts. Facu probó el alta de una meta en la página 2, que fue confirmada en la base. Sesiones, progreso y autorización por persona siguen pendientes. La guía de comprobación y su estado está en `../PRUEBAS-CULTIVO.md`.

`../../db/migrations/001_cultivo.sql` crea el modelo; `../../db/checks/001_cultivo.sql` comprueba sus reglas con datos temporales y rollback. Según `../../LEEME-PRIMERO.md`, la comprobación pasó en el esquema de desarrollo y no quedaron datos de ejemplo. No se repitió esa prueba al crear este documento.

## Decisiones provisionales y preguntas abiertas

- La implementación identifica a las personas como BRI/FACU; todavía no son cuentas ni permisos.
- La semana se identifica por su lunes; el día lógico se elige manualmente. Faltan reglas de edición y restricciones temporales.
- No está definido cómo agregar varias metas de cultivo para el puntaje del rubro.
- Confirmar cómo se resuelven actividades con mínimo por capítulos u otra unidad.
- La app todavía no está lista para uso real: faltan autenticación, autorización e historial de correcciones.
