# Let's Find Out! — Plan de arranque v1

**Estado:** base acordada el 31 de julio de 2026; actualizada con Persona A el 11 de noviembre de 2026.
**Lectura:** este archivo describe el producto previsto en el proyecto anterior. Consultar `../../LEEME-PRIMERO.md` y las especificaciones actuales para saber qué está vigente e implementado hoy.

**Propósito:** convertir el sistema actual de seguimiento en una web-app privada, compartida y agradable de usar a diario. Este documento es la fuente de verdad para arrancar diseño y desarrollo; el Notion original queda como referencia histórica y de ideas.

---

## 1. Qué se va a construir

Una **web-app privada para Persona B y Persona A**, usable desde celular y computadora, que permite registrar tiempo, sesiones y metas semanales; muestra el progreso del duelo durante la semana; y calcula el cierre semanal y mensual.

No es una app genérica de productividad ni una planilla corporativa. Debe sentirse como un tablero cozy de videojuego retro: compartido, cálido, un poco absurdo y competitivo sin ser punitivo.

### Objetivo de la primera versión

Que cualquiera de los dos pueda, en pocos segundos:

1. iniciar o cargar una actividad;
2. ver el progreso propio y el del otro;
3. entender de dónde salen los cálculos;
4. cerrar juntos una semana el domingo por la noche.

---

## 2. Principios de producto

- Se mide principalmente el **cumplimiento de objetivos personales**, no quién acumuló más horas.
- El ocio elegido no es un error; el ocio fuga se registra para hacerlo visible.
- Las horas y los resultados concretos se registran por separado: las horas van en categorías y las metas semanales representan entregables medibles.
- La app calcula de forma automática y transparente; no vigila ni intenta detectar trampas.
- Se puede corregir un error, pero toda corrección relevante deja historial.
- La estética debe invitar a abrir la app, sin ocultar datos o reglas.

---

## 3. Reglas activas v1

### 3.1 Ciclo semanal y objetivos

- La semana va de **lunes al despertar** a **domingo al dormirse**.
- El día lógico no termina a las 00:00: cada persona lo cierra al irse a dormir. Un registro de madrugada puede asignarse al día anterior.
- Objetivos, metas semanales y premios se preparan desde el domingo anterior.
- Se pueden editar hasta el **lunes a las 12:00**. Luego quedan bloqueados.
- Cada persona modifica únicamente sus propios objetivos y registros.

### 3.2 Rebalanceo entre Trabajo y Estudio

Cada persona puede hacer **un único rebalanceo semanal** entre las metas de Trabajo y Estudio hasta el **miércoles a las 23:59**.

- El total combinado debe mantenerse.
- Debe escribirse un motivo breve.
- Se guarda el valor anterior, el nuevo, la fecha y el motivo.
- Después de ese momento no se puede modificar.

Ejemplo: pasar de Trabajo 15 h + Estudio 30 h a Trabajo 20 h + Estudio 25 h por una entrega laboral prioritaria.

### 3.3 Semanas o días excepcionales

- Si un día se complica, se reorganizan las actividades en los días restantes: la app no necesita “mover” nada automáticamente.
- Si varios días alteran de forma importante la semana, Persona B y Persona A pueden acordar bajar objetivos para esa semana.
- Toda excepción debe guardar una explicación y el cambio de objetivos. No debe parecer un ajuste silencioso de último momento.

### 3.4 Categorías

| Categoría | Definición activa |
| --- | --- |
| Trabajo | Actividad que avanza un proyecto o tarea importante y deja un resultado específico o verificable. |
| Estudio | Actividad con intención de aprendizaje buscado, para trabajo, facultad o desarrollo personal. |
| Ocio elegido | Descanso o diversión elegida conscientemente, no ligada a Trabajo o Estudio. |
| Ocio fuga | Ocio no elegido conscientemente, donde se pierde la noción del tiempo. |
| Cultivo | Actividad intencional de desarrollo o cuidado personal. Categoría única, sin áreas ni comodín. |

Una actividad compartida se registra para ambos con la duración completa. Ejemplo: dos horas de película juntos consumen dos horas de ocio elegido de cada uno.

### 3.5 Registro y cronómetro

- Un minuto es la duración mínima registrable.
- Las duraciones se guardan en minutos exactos y se muestran como horas/minutos.
- Hay un solo cronómetro activo por persona.
- El cronómetro se inicia al comenzar la actividad real y se pausa manualmente ante una distracción. Si alguien se olvidó de pausarlo, lo corrige al finalizar.
- Debe existir carga manual de registros.
- Como regla normal, un registro se puede agregar o corregir hasta el día lógico anterior.
- La app guarda la fuente (`cronómetro` o `manual`) y el historial de creación/cambios: qué se modificó, valor anterior, valor nuevo, fecha/hora y motivo.
- Una misma franja de tiempo no debe registrarse en dos categorías temporales distintas.

### 3.6 Banco de ocio

```text
ocio computable = ocio elegido + (ocio fuga × 1,5)
exceso de ocio = máximo(0, ocio computable − ocio base)
extra productivo = máximo(0, trabajo real − meta trabajo)
                  + máximo(0, estudio real − meta estudio)
saldo = extra productivo − exceso de ocio
```

- Las horas extra de Trabajo y Estudio compensan el exceso de ocio sin tope.
- El ocio base no usado no genera puntos ni se acumula para la semana siguiente.
- Cultivo no consume ocio ni compensa el saldo de ocio.

### 3.7 Constancia

Un día activo de Constancia requiere al menos **60 minutos combinados de Trabajo y Estudio**. Cultivo no cuenta para Constancia en v1.

### 3.8 Cultivo

- Se mide por cumplimientos de metas de cultivo. Cada meta define actividad, mínimo por cumplimiento y cantidad de repeticiones semanales.
- Cada persona crea sus actividades: nombre libre, duración mínima por cumplimiento en minutos y repeticiones semanales. La interfaz actual usa tiempo; la posibilidad de medir por capítulos se mencionó antes, pero no forma parte de este formulario.
- Ejemplo: entrenar (4), mínimo 30 minutos, requiere cuatro sesiones que cumplan ese mínimo. Pueden hacerse el mismo día. Una sesión larga no se divide automáticamente en varias repeticiones.
- Cultivo no se clasifica en áreas y no existe pendiente obligatorio ni comodín.
- Se utiliza el nombre **metas de cultivo**, separado de **metas semanales**.
- Cada registro que alcanza el mínimo cuenta una repetición; uno que no lo alcanza no cuenta como cumplimiento.
- Se muestra progreso por meta. Falta confirmar cómo se agregan varias metas de cultivo para calcular el puntaje de ese rubro (por repeticiones totales o promedio de cumplimiento por meta).

### 3.9 Metas semanales

- Una meta semanal debe ser específica y medible; no puede ser abstracta.
- Tipos soportados: completar/no completar, cantidad, duración, progreso manual y subtareas.
- Puede vincularse a Trabajo o Estudio; los registros vinculados actualizan su avance automáticamente.
- No se agregan metas semanales nuevas durante una semana activa.

### 3.10 Puntaje semanal (30 puntos)

Cada área vale hasta 5 puntos:

| Área | Máximo |
| --- | ---: |
| Trabajo | 5 |
| Estudio | 5 |
| Cultivo | 5 |
| Constancia | 5 |
| Equilibrio del ocio | 5 |
| Metas semanales | 5 |
| **Total** | **30** |

Para Trabajo, Estudio, Cultivo y Metas semanales se usa la misma escala de cumplimiento:

| Cumplimiento | Puntos |
| --- | ---: |
| 100% o más | 5 |
| 80–99% | 4 |
| 60–79% | 3 |
| 40–59% | 2 |
| 1–39% | 1 |
| 0% | 0 |

Equilibrio de ocio:

| Saldo | Puntos |
| --- | ---: |
| 0 o positivo | 5 |
| Hasta −1 h | 4 |
| Entre −1 y −2 h | 3 |
| Entre −2 y −3 h | 2 |
| Entre −3 y −5 h | 1 |
| Menos de −5 h | 0 |

### 3.11 Cierres y resultados

- Durante la semana se muestra el progreso y el puntaje estimado apenas se carga un resultado.
- Persona B y Persona A cierran juntos la semana el domingo por la noche, normalmente en llamada.
- El cierre puede tener una animación o ceremonia visual, pero los cálculos deben estar visibles antes de cerrarlo.
- Desempates semanales: mayor promedio de cumplimiento de Trabajo + Estudio; menor ocio fuga; más días activos; mejor saldo; piedra, papel o tijera.
- Si el empate persiste, ambos pueden ganar el premio cooperativo o resolverlo según el premio acordado.
- El resultado mensual es el promedio de los puntajes de todas las semanas.

---

## 4. Alcance de la primera versión

### Incluye

- Dos cuentas privadas, Persona B y Persona A, dentro del mismo espacio compartido.
- Crear y activar una semana con objetivos, metas semanales, Cultivo y premios.
- Cronómetro persistente con pausa manual y recuperación al volver a abrir la app.
- Registro manual, edición e historial de cambios.
- Registro de actividad compartida para ambos.
- Tablero de progreso propio y comparación visible.
- Cálculo de horas, ocio, constancia, Cultivo, metas semanales y puntos.
- Cierre semanal compartido e historial básico de semanas cerradas.
- Diseño responsive, priorizando el uso en celular.

### Se deja para una versión posterior

- Pomodoro.
- Cola de enfoque / to-do diaria.
- Música integrada.
- Frases motivacionales y de cierre.
- Notificaciones.
- Estadísticas avanzadas, rachas y logros.
- Avatares configurables, mascotas, sonidos y animaciones complejas.
- Exportar el resultado como imagen.
- Widgets y modo offline avanzado.

---

## 5. Pantallas principales

### Duelo

Primera pantalla y centro de operaciones. Debe mostrar:

- cronómetro activo propio y del otro;
- progreso propio y comparativo;
- metas semanales;
- Cultivo;
- premio semanal;
- un acceso directo para registrar una actividad.

### Registrar / cronómetro

Flujo mínimo:

```text
Elegir categoría
→ escribir actividad opcional
→ vincular proyecto o meta semanal opcional
→ iniciar / pausar / finalizar
→ revisar duración
→ guardar
→ actualizar tablero y cálculos
```

También tiene el botón `+ Agregar registro` para carga manual.

### Semana

- Metas de Trabajo, Estudio y ocio base.
- Banco de ocio explicado y saldo actual.
- Fila de Constancia por día.
- Progreso de las metas de cultivo, sin desglose por áreas.
- Metas semanales y avance.
- Puntaje parcial desglosado, no sólo el total.

### Cierre e historial

- Comparación de los seis rubros.
- Ganador/a, desempate si corresponde y premios.
- Historial semanal y resumen mensual.

---

## 6. Dirección visual

- Pixel art cozy, romántico y retro game.
- Gatos/avatares para Persona B y Persona A; corazones, nubes, pasto, flores, honguitos y fuego como elementos de escena.
- El tablero debe sentirse como videojuego, pero los números permanecen legibles.
- Textos, tablas, botones y barras se implementan como interfaz web. Las ilustraciones y decoraciones pueden producirse con cualquier herramienta adecuada.
- Actualización del 11/11/2026: el diseño no depende de que Persona B prepare Canva, PNG o bocetos. Al retomar, el asistente puede proponer y desarrollar la dirección visual con Persona A. Se mantiene la estética de gatos y pixel art.
- Antes de programar, preparar cuatro referencias visuales: Duelo, Registrar, Semana y Cierre.

---

## 7. Arquitectura técnica elegida para el arranque

```text
Interfaz web: Astro + React + TypeScript + Tailwind CSS
Base de datos, cuentas y sincronización: Supabase
Publicación: Vercel
Código e historial: GitHub
Instalación tipo app: PWA, después de estabilizar el flujo principal
```

Actualización del 11/11/2026: Astro reemplaza a Next.js. React mantiene los componentes interactivos y Tailwind CSS define los estilos. Supabase cubrirá datos y cuentas; Vercel, publicación. No se agrega un backend separado en otro lenguaje. Servicios externos todavía sin conectar.

### Criterios técnicos

- La aplicación necesita datos online compartidos: no se puede depender sólo del almacenamiento del navegador.
- Cada cálculo debe derivarse de registros y objetivos guardados; no se deben guardar totales manuales que puedan desincronizarse.
- El cronómetro guarda inicio, pausas y fin reales; así puede recuperarse aunque se cierre la pestaña.
- La base debe registrar auditoría para correcciones y cambios de objetivos.
- La privacidad se resuelve con autenticación y acceso exclusivo a la pareja.

### Entidades mínimas

```text
Usuario
Espacio compartido (pareja)
Semana
Objetivos semanales
Registro de tiempo
Meta de cultivo
Sesión de Cultivo
Meta semanal y subtareas
Premio
Cierre semanal / puntaje
Historial de cambios
```

---

## 8. Orden recomendado de trabajo

1. Pasar este documento a “reglas activas” y resolver cualquier matiz antes de programar.
2. Proponer el tablero principal en desktop y su adaptación móvil; revisarlo con Persona A y extender la dirección a las otras pantallas. No esperar diseños externos de Persona B.
3. Crear el proyecto, repositorio y servicios de datos/publicación.
4. Construir un recorrido completo mínimo: iniciar sesión → crear semana → cargar un registro manual → ver progreso actualizado.
5. Agregar cronómetro y edición con auditoría.
6. Agregar banco de ocio, Constancia, Cultivo, metas semanales y puntaje.
7. Construir cierre semanal e historial.
8. Probar una semana real entre Persona B y Persona A; ajustar fricción y reglas antes de sumar gamificación.
9. Recién después agregar PWA, Pomodoro, música, logros y animaciones.

---

## 9. Criterios de aceptación antes de usarla en serio

- Persona B y Persona A pueden usarla desde sus teléfonos y ven los mismos datos.
- Un registro nuevo actualiza las barras y el puntaje sin recargar manualmente.
- El cronómetro no pierde una sesión por cerrar la pestaña.
- Ocio fuga aplica exactamente el multiplicador 1,5.
- Una actividad compartida se contabiliza completa para ambos.
- Los cambios muestran auditoría clara.
- Los cálculos de cada rubro se pueden entender desde la pantalla, sin consultar código.
- El cierre semanal reproduce los resultados esperados de una semana real de prueba.
- La app se siente liviana y agradable de abrir, no como una obligación extra.

---

## 10. Pendientes que no bloquean el arranque

- Decidir el período exacto en que se permite reabrir una semana ya cerrada.
- Definir el formato visual definitivo de la ceremonia de cierre.
- El día lógico se cierra manualmente al dormir; no introducir un corte horario obligatorio.
- Elegir posteriormente el tipo de inicio de sesión más cómodo para ambos.

Estos puntos no impiden diseñar ni construir el flujo principal, siempre que la base conserve historial de cambios.
