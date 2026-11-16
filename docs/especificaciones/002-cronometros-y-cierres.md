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
- Una semana tiene seis rubros de hasta cinco puntos: trabajo, estudio, constancia, equilibrio de ocio, metas de cultivo y metas semanales, para un máximo de 30. Constancia se relaciona con una cantidad de días prevista. Gana quien tenga más puntos; un ejemplo informado fue 27 contra 22. Están informadas las tablas de trabajo, estudio, constancia y ocio, así como las reglas de empate; faltan detalles de puntuación de Cultivo y del cierre mensual.
- Cada persona elige un premio semanal y uno mensual que la otra debe darle o realizar si gana. El resultado mensual usa el promedio de puntuaciones semanales: gana quien tenga el promedio más alto. La semana pertenece al mes de su lunes. En un empate semanal ambas personas reciben su premio semanal; en uno mensual ambas reciben el premio de esa semana y el del mes. Falta precisar a qué semana se refiere el premio semanal en el empate mensual y el mecanismo de cierre.
- La semana se presenta con sus fechas de inicio y fin y se muestra el día actual.
- Las reglas nuevas de Cultivo difieren de la versión actual, que cuenta como máximo una vez cada sesión y permite guardar sesiones inferiores al mínimo sin sumarlas. No cambiar datos ni recálculos históricos sin acordar la migración.

### Reglas de puntuación informadas

- **Trabajo y estudio:** calcular el porcentaje registrado respecto del objetivo semanal individual. 100 % o más: 5 puntos; 80–menos de 100 %: 4; 60–menos de 80 %: 3; 40–menos de 60 %: 2; mayor que 0–menos de 40 %: 1; cero: 0. Propuesta por confirmar: evaluar el porcentaje sin redondear antes de aplicar los cortes.

Se preparó ese cálculo sin redondear previamente y con puntos sin asignar si falta el objetivo; la función pasó sus pruebas SQL. La tabla con puntos parciales pasó validación live y se importó a desarrollo; falta probarla en navegador. El tratamiento sin objetivo queda sujeto a la definición final del cierre.
- **Constancia:** un día activo requiere al menos una hora de trabajo o estudio. Cinco o más días activos: 5 puntos; de cero a cuatro días: tantos puntos como días. Trabajo y estudio no se suman entre sí: al menos una categoría debe alcanzar una hora. Se suman las sesiones de una misma categoría durante el día. El día cuenta para la semana de su fecha personal, aunque se cierre al día siguiente; el resumen semanal se probó en SQL y la pantalla se importó a desarrollo. Falta prueba en navegador.
- **Ocio:** saldo cero o positivo: 5 puntos; hasta una hora de deuda: 4; entre una y dos horas: 3; entre dos y tres: 2; entre tres y cinco: 1; más de cinco: 0. Se trata del saldo de un banco de ocio. La tabla indicada debe respetarse; el ejemplo de cálculo del saldo no quedó confirmado y no debe tratarse como una regla decidida. Los límites entre tramos se interpretarán de manera consistente y se validarán al implementar.
- **Cultivo:** los sobrantes se acumulan para otra sesión si quedan cumplimientos pendientes de esa actividad; si no quedan, se descartan para el conteo. Las sesiones inferiores al mínimo se pueden guardar y acumular; falta definir cómo puntuar las metas.
- **Carga repetida:** si se conserva el cronómetro después de registrar, queda pausado con el tiempo visible; al iniciarlo otra vez, las cargas posteriores registran solo el intervalo nuevo; cada intervalo debe contarse una sola vez.
- **Metas semanales:** son tareas personales concretas, por ejemplo terminar un curso o preparar la estructura de un proyecto. Se reparte el total de cinco puntos por igual entre las metas: si hay tres, cada una vale 5/3 puntos; si hay una, vale cinco. Falta definir qué ocurre si no se definen metas y el redondeo mostrado.

La base de metas semanales se instaló en desarrollo y su prueba SQL pasó. La pantalla permite agregar metas propias, marcarlas como completadas o pendientes y muestra el cálculo con dos decimales; la base conserva el valor proporcional sin redondearlo. Cuando no hay metas se muestra que no hay metas, sin asignar un puntaje. La pantalla se comprobó en navegador.

Se muestra además la cantidad completada y el puntaje de cada persona en el progreso compartido, o «Sin metas» cuando no tiene ninguna. Pasó una prueba con datos temporales y se confirmó en navegador el resultado de tres metas completadas de tres.

El cálculo es determinista y no requiere un agente de inteligencia artificial. Todavía no está implementado.

## Criterios de aceptación

- [ ] Acordar las reglas de cronómetros, objetivos, edición y cierres.
- [ ] Definir cómo se calcula la semana ganada y su recuento mensual.
- [ ] Acordar un recorrido y una primera entrega verificables.
- [ ] Preservar los datos existentes o acordar explícitamente su migración.

## Verificación

La migración `db/migrations/004_cronometros.sql` está instalada en desarrollo, con pausa automática al registrar. `db/checks/005_cronometros.sql` pasó con rollback: un cronómetro activo por persona, cargas incrementales, ausencia de solapamiento, pausa y reinicio. La pantalla de inicio pasó la validación live y fue importada a desarrollo; requiere más pruebas de navegador. Las migraciones 005–007 crean días personales y asocian nuevos intervalos al día abierto; `db/checks/006_dias_personales.sql` y `db/checks/005_cronometros.sql` verificaron continuidad y resumen con rollback. El historial anterior queda sin día asignado hasta acordar su incorporación. La base del cierre está instalada y la pantalla de resumen pasó la validación live y se importó a desarrollo; se informó que funciona en navegador; quedan pendientes más casos. Se guarda una fotografía de lo registrado; el tiempo sin registrar se conserva pendiente y queda fuera de esa fotografía. La edición posterior y su reflejo en el resumen aún no están implementados. Se importaron objetivos y progreso semanal para tiempo de cronómetros asociado a días personales; falta comprobar las pantallas en navegador. Todavía no integra los intervalos con las actividades de Cultivo. Los colores configurables y el cierre básico fueron importados a desarrollo; falta la prueba visual de colores.

## Preguntas abiertas

- ¿Cómo se comprueba el funcionamiento y la reanudación del cronómetro en varios dispositivos?
- ¿Cómo se configura y calcula el banco de ocio a partir del objetivo personal?
- ¿Cómo se reflejan en el progreso los intervalos de cronómetro asociados a una actividad de Cultivo y se preserva el historial existente?
- ¿Cómo se asigna el tiempo cuando se cierra un día con un cronómetro activo y cómo se asigna un día personal que cruza de semana?
- ¿Qué se confirma en un cierre diario? ¿Se puede reabrir, corregir o añadir tiempo? ¿Qué pasa con un cronómetro activo?
- ¿Cómo se confirma el cierre semanal y cuál es la semana cuyo premio se concede en un empate mensual?
- ¿Se pueden editar, eliminar o corregir registros y objetivos? ¿Cómo se conserva el historial?
- ¿Qué datos son compartidos y cuáles privados? ¿Qué ocurre al renombrar una cuenta?
- ¿Cómo se guardan y restablecen los colores y cómo se garantiza legibilidad?


### Objetivos y progreso de horas (importados a desarrollo)

Cada persona puede establecer por semana sus horas objetivo para trabajo, estudio, ocio y Cultivo; se admiten fracciones y objetivos sin definir. El guardado usa la identidad autenticada y rechaza el cambio si la semana seleccionada cambió mientras se editaba. El progreso comparte dos tablas, suma intervalos registrados por su día personal y compara con objetivos; no representa puntos ni calcula el banco de ocio. Los intervalos anteriores sin día y las sesiones manuales de Cultivo no están incluidos. Las páginas se importaron a desarrollo. Pasaron las pruebas SQL con datos temporales, la validación live y una ejecución del proceso instalado con una fracción decimal; falta probarlas en navegador.


### Registro acumulativo de Cultivo (en preparación)

Se preparó la elección de actividad al registrar el cronómetro, la acumulación de tiempos nuevos manuales y cronometrados, y el aviso de cercanía al siguiente cumplimiento. Los registros anteriores conservan su cálculo. Las pruebas SQL cubren acumulación, múltiplos, descarte al completar, cuenta y semana, advertencia y cargas repetidas; faltan validación e importación de pantallas y pruebas de navegador.
