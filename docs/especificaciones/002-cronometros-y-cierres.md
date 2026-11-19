# 002 — Cronómetros, progreso y cierres

**Estado:** cronómetros, integración con Cultivo, pantallas iniciales y cierre diario básico importados a desarrollo. Puntuación y correcciones pendientes.

## Objetivo

Reproducir el recorrido compartido de registrar tiempo durante el día, consultar el avance de cada persona y realizar cierres diarios y semanales, con un recuento mensual.

## Alcance

La propuesta incluye una página de bienvenida con cronómetros para trabajo, estudio, ocio y cultivo; colores distintos configurables; una página de progreso con la semana, el día, los objetivos y el avance de ambas personas; y un cierre diario que cada persona confirma a su propio ritmo. También se plantea el cierre semanal y un recuento mensual de semanas ganadas.

La propuesta es una dirección de producto, no una decisión de reconstruir o borrar lo existente. La secuencia de entregas y la reutilización de componentes y datos se decidirán después de aclarar las reglas.

## Reglas y ejemplos

- Cada persona puede tener un cronómetro activo a la vez. Continúa contando si se cierra el navegador o se bloquea el dispositivo. Debe permitir pausa y carga; el mecanismo y la recuperación en varios dispositivos aún deben definirse.
- Cada persona elige sus propios objetivos de trabajo, estudio y ocio, sus metas de Cultivo y sus metas semanales. El ocio tiene un objetivo estimado; por ejemplo, cinco horas para almuerzos con descanso. La tabla de puntos de ocio está informada; falta confirmar cómo se determina el saldo.
- El objetivo semanal de horas de Cultivo se deriva de las metas de esa persona: se suma para cada actividad su mínimo por sesión multiplicado por su frecuencia. Por ejemplo, 30 minutos cuatro veces suman dos horas. El cambio se importó a desarrollo; falta probarlo en navegador.
- Cultivo conserva actividades individuales con tiempo mínimo y frecuencia. La actividad se elige al registrar el tiempo, no al iniciar el cronómetro. Una sesión inferior al mínimo se puede guardar y acumular con sesiones posteriores; no cuenta como cumplimiento hasta alcanzar el mínimo. Un tiempo equivalente al doble exacto cuenta dos veces; los sobrantes se acumulan mientras queden cumplimientos pendientes de la actividad. Se preparó un aviso antes de registrar si faltan hasta diez minutos para el siguiente cumplimiento, desde el segundo y mientras queden cumplimientos pendientes.
- Al registrar, el cronómetro queda pausado. Después de registrar se pregunta si se desea reiniciar; si se conserva el contador, mantiene el número mostrado y hay que pulsar Iniciar para seguir. Las cargas siguientes incluyen solo el intervalo nuevo.
- En Cultivo, al pulsar «Registrar tiempo» se pausa antes de elegir la actividad, de modo que el tiempo dedicado a completar el formulario no se suma. Si se abandona la selección, el reloj queda pausado y se puede volver a iniciar. La pausa se comprobó en navegador.
- Se agregó un botón de reinicio para cada cronómetro: con confirmación, pausa el reloj, descarta el tiempo pendiente y conserva las cargas anteriores. El descarte queda registrado en la base. Se comprobó su funcionamiento en navegador.
- El cierre diario es personal, guarda un resumen y permite correcciones posteriores. Cada día personal permanece abierto hasta que su persona lo cierre; el tiempo posterior a medianoche sigue contando para ese día abierto. Se puede cerrar más tarde que la otra persona. Si un cronómetro está activo, se indica cuál es y se pide confirmación antes de pausarlo y cerrar. Falta precisar cómo se actualiza el resumen tras una corrección.
- Una semana tiene seis rubros de hasta cinco puntos: trabajo, estudio, constancia, equilibrio de ocio, metas de cultivo y metas semanales, para un máximo de 30. Gana quien tenga más puntos; un ejemplo informado fue 27 contra 22. Cada persona confirma por separado y debe tener al menos una meta semanal y una actividad de Cultivo. La primera versión requiere también objetivos de Trabajo, Estudio y Ocio y que no haya tiempo pendiente en la semana; falta definir qué hacer si un objetivo de horas no aplica.
- Cada persona elige un premio semanal y uno mensual que la otra debe darle o realizar si gana. El resultado mensual usa el promedio de puntuaciones semanales, redondeado al entero más cercano antes de comparar. La semana pertenece al mes de su lunes. El resultado mensual se declara cuando ambas personas han confirmado todas las semanas que empezaron ese mes. En un empate semanal ambas personas reciben su premio semanal; en uno mensual ambas reciben el premio de esa semana y el del mes. Falta precisar a qué semana se refiere el premio semanal en el empate mensual.

Se preparó un recuento que muestra cada semana, promedios parciales y premios mensuales por persona. Solo incluye en los promedios las semanas con ambas confirmaciones vigentes; si cambian los puntajes, esas semanas dejan de ser comparables hasta volver a confirmarlas. La comparación final espera todos los cierres. La pantalla se validó e importó a desarrollo; falta prueba en navegador.
- La semana se presenta con sus fechas de inicio y fin y se muestra el día actual.
- Las reglas nuevas de Cultivo difieren de la versión actual, que cuenta como máximo una vez cada sesión y permite guardar sesiones inferiores al mínimo sin sumarlas. No cambiar datos ni recálculos históricos sin acordar la migración.

### Reglas de puntuación informadas

- **Trabajo y estudio:** calcular el porcentaje registrado respecto del objetivo semanal individual. 100 % o más: 5 puntos; 80–menos de 100 %: 4; 60–menos de 80 %: 3; 40–menos de 60 %: 2; mayor que 0–menos de 40 %: 1; cero: 0. Propuesta por confirmar: evaluar el porcentaje sin redondear antes de aplicar los cortes.

Se preparó ese cálculo sin redondear previamente y con puntos sin asignar si falta el objetivo; la función pasó sus pruebas SQL. La tabla con puntos parciales pasó validación live y se importó a desarrollo; falta probarla en navegador. El tratamiento sin objetivo queda sujeto a la definición final del cierre.
- **Constancia:** un día activo requiere al menos una hora de trabajo o estudio. Cinco o más días activos: 5 puntos; de cero a cuatro días: tantos puntos como días. Trabajo y estudio no se suman entre sí: al menos una categoría debe alcanzar una hora. Se suman las sesiones de una misma categoría durante el día. El día cuenta para la semana de su fecha personal, aunque se cierre al día siguiente; el resumen semanal se probó en SQL y la pantalla se importó a desarrollo. Falta prueba en navegador.
- **Ocio:** el saldo es el objetivo menos el tiempo registrado. Si no se excede, son 5 puntos; el exceso de hasta una hora da 4; más de una y hasta dos horas, 3; más de dos y hasta tres, 2; más de tres y hasta cinco, 1; más de cinco, 0.
- **Cultivo:** se suman los cumplimientos de todas las actividades y se dividen por la suma de frecuencias previstas; esa proporción se multiplica por cinco. Se limita cada actividad a su objetivo. Los sobrantes se acumulan para otra sesión si quedan cumplimientos pendientes; si no quedan, se descartan para el conteo. Las sesiones inferiores al mínimo se guardan y acumulan.

Se prepararon y probaron estos cálculos y un total semanal provisional. Si faltan objetivos de trabajo, estudio u ocio, metas de Cultivo o metas semanales, no se muestra el total hasta acordar qué corresponde hacer en esos casos. Cada rubro se redondea al entero más cercano: desde 0,50 hacia arriba; por debajo hacia abajo. El total suma los rubros ya redondeados. La presentación se validó e importó a desarrollo; falta comprobarla en navegador.
- **Carga repetida:** si se conserva el cronómetro después de registrar, queda pausado con el tiempo visible; al iniciarlo otra vez, las cargas posteriores registran solo el intervalo nuevo; cada intervalo debe contarse una sola vez.
- **Metas semanales:** son tareas personales concretas, por ejemplo terminar un curso o preparar la estructura de un proyecto. Se reparte el total de cinco puntos por igual entre las metas: si hay tres, cada una vale 5/3 puntos; si hay una, vale cinco. Falta definir qué ocurre si no se definen metas y el redondeo mostrado.

La base de metas semanales se instaló en desarrollo y su prueba SQL pasó. La pantalla permite agregar metas propias y marcarlas como completadas o pendientes. Se preparó la presentación del puntaje redondeado al entero más cercano. Cuando no hay metas se muestra que no hay metas, sin asignar un puntaje. La pantalla anterior se comprobó en navegador.

Se muestra además la cantidad completada y el puntaje de cada persona en el progreso compartido, o «Sin metas» cuando no tiene ninguna. Pasó una prueba con datos temporales y se confirmó en navegador el resultado de tres metas completadas de tres.

El cálculo es determinista y no requiere un agente de inteligencia artificial. Todavía no está implementado.

## Criterios de aceptación

- [ ] Acordar las reglas de cronómetros, objetivos, edición y cierres.
- [ ] Definir cómo se calcula la semana ganada y su recuento mensual.
- [ ] Acordar un recorrido y una primera entrega verificables.
- [ ] Preservar los datos existentes o acordar explícitamente su migración.

## Verificación

La base de cronómetros, días personales y cierre diario está instalada y sus pruebas SQL pasaron. El cierre guarda el tiempo registrado y conserva pendiente el tiempo sin registrar. Las correcciones posteriores de cargas con día asignado actualizan el resumen cerrado; la reapertura queda pendiente. Cultivo integra los intervalos con actividades, y el progreso muestra puntos parciales de trabajo, estudio, constancia y metas semanales. El historial anterior sin día sigue pendiente de asignación. La comprobación integral del aislamiento entre cuentas reales sigue pendiente. Ver `LEEME-PRIMERO.md` para el estado vigente y `REGISTRO-DE-AVANCES.md` para el historial de pruebas.

## Preguntas abiertas

- ¿Cómo se comprueba el funcionamiento y la reanudación del cronómetro en varios dispositivos?
- ¿Qué puntaje corresponde a Trabajo, Estudio u Ocio si no se configuró un objetivo de horas?
- ¿Cómo se incorporan al progreso de horas las sesiones manuales de Cultivo y los intervalos anteriores sin día?
- ¿Cómo se reabre un día cerrado y se agregan registros para ese día?
- ¿Cuál es la semana cuyo premio semanal se concede en un empate mensual?
- ¿Se pueden editar, eliminar o corregir registros y objetivos? ¿Cómo se conserva el historial?
- ¿Qué datos son compartidos y cuáles privados? ¿Qué ocurre al renombrar una cuenta?
- ¿Cómo se guardan y restablecen los colores y cómo se garantiza legibilidad?


### Objetivos y progreso de horas (importados a desarrollo)

Cada persona establece por semana sus horas objetivo de trabajo, estudio y ocio; el objetivo de Cultivo se deriva de sus actividades. El guardado usa la identidad autenticada y rechaza cambios si se seleccionó otra semana durante la edición. El progreso compartido incluye puntos parciales y tiempos con día personal; no calcula el banco de ocio y no incluye intervalos anteriores sin día ni sesiones manuales de Cultivo.


### Registro acumulativo de Cultivo (importado a desarrollo)

Se implementaron la elección de actividad al registrar el cronómetro, la acumulación de tiempos nuevos y el aviso de cercanía. Los registros anteriores conservan su cálculo. Pasaron pruebas SQL, validación live e importación; se comprobó la acumulación en navegador y queda pendiente la prueba visual del aviso.
