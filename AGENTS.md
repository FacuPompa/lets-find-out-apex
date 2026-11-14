# Let's Find Out! — APEX

- Al retomar, leer `LEEME-PRIMERO.md`; consultar el plan y contexto histórico para las reglas de producto, no para asumir que el stack Astro sigue vigente.
- Leer `docs/README.md` y la especificación aplicable antes de implementar. Distinguir reglas confirmadas de decisiones provisionales y preguntas abiertas; no presentar supuestos como decisiones confirmadas.
- Para cada funcionalidad, mantener actualizados alcance, criterios verificables y estado de sus comprobaciones. Registrar decisiones relevantes y sus motivos en `docs/decisiones/` cuando aporten valor.
- Nueva implementación en Oracle APEX 26.1.6 y APEXlang; Oracle Autonomous Database Always Free. Conservar el proyecto anterior sin tocarlo.
- Usar las skills oficiales de Oracle para APEXlang 26.1 y Database según corresponda. Verificar conexión y herramientas antes de asumir que hay acceso a la base.
- Mantener secretos y wallets fuera del repositorio y de los mensajes. No depender de `ADMIN` para el trabajo ordinario si el esquema del proyecto es suficiente.
- La convención preferida para ramas es `feat/`, `fix/`, `docs/`, etc., sin prefijo `codex/`.
- Mantener actualizados el estado, las decisiones, los pasos pendientes y las comprobaciones en `LEEME-PRIMERO.md`; no registrar credenciales.
- Para cambios relevantes, agregar una entrada breve en `docs/REGISTRO-DE-AVANCES.md` con fecha, resultado real y pendientes; no incluir conversaciones completas ni secretos.
- Explicar las decisiones en español sencillo; considerar experiencia en TypeScript y Java y aprendizaje de APEX. Avanzar en pasos claros.
- En documentación pública usar referencias genéricas a las personas y redacción impersonal; conservar los identificadores técnicos existentes cuando sean necesarios para que la aplicación funcione. No reescribir la historia Git publicada.

- Para avisos y confirmaciones, reutilizar componentes accesibles de la aplicación o APEX (`apex.message` o confirmaciones declarativas); evitar cuadros nativos del navegador. Aplicar la skill `mensajes-ui` cuando esté disponible.
