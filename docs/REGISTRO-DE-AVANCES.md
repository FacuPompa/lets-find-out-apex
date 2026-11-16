# Registro de avances

Entradas breves para cambios relevantes. El estado actual y los próximos pasos están en `../LEEME-PRIMERO.md`; las reglas están en las especificaciones. No registrar secretos ni datos personales innecesarios.

## 2026-11-13 — Primera base de Cultivo

- Se creó el modelo SQL de metas y registros de cultivo en el esquema de desarrollo; su comprobación pasó según el estado documentado.
- Pendiente: aplicación y pantallas APEX, autenticación/autorización y correcciones con historial.

## 2026-11-13 — Documentación y flujo de trabajo

- Se organizó la documentación histórica y se escribió una primera especificación a partir de lo ya implementado.
- Se prepararon una plantilla de pull request y comprobaciones locales para GitHub Actions.
- Pendiente: crear el repositorio Git y ejecutar el flujo en GitHub; el flujo no conecta a Oracle ni sustituye las pruebas SQL.
# 13/11/2026 — Formulario de cultivo

Preparado por código el formulario de alta sin operaciones de modificación o borrado. Auditoría compiler-truth y validación live exitosas; importado con autorización en la aplicación 100 y verificado mediante reexportación. Pendiente prueba en navegador. Faltan sesiones, progreso y permisos por persona.

Se probó el alta desde el navegador y se recibió `row created`; SQLcl confirmó que la meta se guardó y recibió fecha de creación automática. Pendientes sesiones, progreso y permisos.

Se repitió con éxito la prueba SQL de Cultivo y se documentaron los pasos existentes y pendientes en `PRUEBAS-CULTIVO.md`. Se corrigió la estructura del plan de pantallas para que pase el control local de documentación. Pendientes: segunda cuenta, autorización por persona, sesiones y progreso, tratamiento seguro del checksum de la exportación, repositorio y ejecución real de GitHub Actions.

Preparada una exportación versionable que omite el checksum de sesión de desarrollo, con respaldo privado fuera del proyecto y una comprobación local para evitar incorporar ese valor literal. Pendiente definir cómo suministrarlo al importar; ver `README.md`.

Primer commit `fba800e` subido a GitHub. La ejecución `43369234347` de GitHub Actions finalizó correctamente; comprueba documentación y patrones básicos de archivos sensibles, no la base de datos ni la interfaz APEX.

Se resumió el estado vigente en `LEEME-PRIMERO.md` y se conservó su versión anterior en `docs/historico/`. Se agregó una herramienta que combina la exportación versionada con el valor privado en una copia temporal y elimina la copia al terminar. Se verificaron limpieza en éxito y fallo, redacción de salida y validación live con APEX; la importación con este procedimiento no se ejecutó. El diagnóstico local de procedencia de metadatos 26.1/26.2 permanece informativo para el validador live.

Se adoptó redacción impersonal para el registro y referencias genéricas a las personas en la documentación. Los identificadores técnicos existentes de la base y de la aplicación se conservan para no alterar datos; su sustitución requiere una migración comprobada. Los nombres también pueden seguir visibles en el historial Git ya publicado.

Se implementó en desarrollo una API interna de registro de sesiones con validación de duración y semana; las pruebas con rollback pasaron para mínimos, registros el mismo día y entradas inválidas. Se importó a desarrollo una página de sesiones y progreso mediante el procedimiento con copia temporal y valor privado; la reexportación confirmó la página y el enlace de navegación. Falta probarla en navegador. La API no implementa permisos por persona y el prototipo no está listo para uso real.

Se probó desde el navegador el registro de una sesión. La consulta del progreso confirmó un registro, un cumplimiento de tres y dos faltantes. Quedan pendientes los demás casos de interfaz y los permisos individuales.

Se comprobó desde la interfaz que una sesión inferior al mínimo deja el progreso en cero; la consulta de la vista confirmó el resultado. Se prepararon e importaron a desarrollo una tabla de progreso, una fecha inicial editable y una selección de semana independiente por cuenta. Pasaron la prueba SQL de aislamiento de preferencias, la auditoría de código y la validación live de APEX; la reexportación confirmó página, menú y filtros. Quedan pendientes las pruebas de navegador y los permisos individuales.


### 13/11/2026 — Imagen de la aplicación

Se preparó la imagen proporcionada como logo del encabezado y del inicio de sesión, conservando el nombre en el encabezado. El archivo se incorporó a los recursos de la aplicación. La auditoría del compilador y la validación live de APEX pasaron; se importó a desarrollo con aprobación y se confirmó el recurso y sus referencias en APEX; las dos metas y las dos sesiones se conservaron. Queda pendiente la comprobación visual en navegador. El repositorio es público y la imagen representa a un personaje de una obra existente.


### 13/11/2026 — Tamaño del logo de inicio de sesión

Se preparó un aumento del logo mediante la variable de tamaño de Universal Theme, de 4 a 6 rem. Pasaron la validación live de APEX y la auditoría independiente del compilador. Se importó a desarrollo con aprobación y se confirmó el CSS guardado en la página. Queda pendiente la comprobación visual.


### 13/11/2026 — Integración de semana y progreso

Se preparó una pantalla de Cultivo con selección de semana, tabla a ancho disponible y registro en la misma página; la selección continúa siendo por cuenta. Se retiró el acceso separado del menú. Se informó que el recorrido anterior funcionó con la nueva cuenta. La auditoría independiente del compilador y la validación live de APEX pasaron; se importó con aprobación y se confirmaron las regiones en APEX. Quedan pendientes las pruebas en navegador.


### 13/11/2026 — Idioma del calendario

Se preparó la configuración regional español de Argentina para el calendario. Se verificó que Oracle considera al lunes el primer día de la semana en ese territorio, y que los cálculos existentes usan lunes ISO. La auditoría independiente del compilador y la validación live de APEX pasaron; se importó con aprobación y se confirmó el idioma configurado. Queda pendiente la prueba visual del calendario.


### 13/11/2026 — Espaciado de progreso

Se informó que la pantalla integrada funciona. Se preparó más espacio en las celdas de progreso y desplazamiento horizontal en pantallas angostas; la validación de APEX pasó, se importó con aprobación y se confirmó la configuración instalada. Queda pendiente la revisión visual.


### 13/11/2026 — Acceso para pruebas externas

Se comprobó que la dirección de la aplicación de desarrollo responde por HTTPS y muestra el inicio de sesión sin una sesión previa. Queda por probar el acceso desde otro dispositivo y crear una cuenta de usuario final para la prueba. Todavía no hay permisos por persona, por lo que corresponde usar datos de ejemplo.


### 13/11/2026 — Vinculación de cuentas

Se preparó la asignación de cuentas APEX a personas existentes y se instaló en desarrollo la tabla y función de resolución, sin modificar las metas. Se vincularon la cuenta de uso y la de administración a la persona existente. Una prueba repetible con sesiones APEX confirmó la resolución y el rechazo de una cuenta sin asignar; las páginas pasaron la validación live de APEX. Se prepararon cambios en las pantallas para derivar la persona en el servidor y restringir las sesiones a metas propias. Se importaron con aprobación y se confirmó que los procesos instalados usan la resolución de persona. Falta comprobar el flujo en navegador y con dos cuentas reales, incluida la manipulación de solicitudes. La segunda cuenta aún no existe.


### 13/11/2026 — Exploración del recorrido completo

Se registró una propuesta inicial de cronómetros por categoría, progreso compartido y cierres personales, semanales y mensuales. Se documentaron reglas abiertas para definir antes de implementar. Se confirmó el funcionamiento del flujo reciente con la cuenta de uso; la prueba entre dos cuentas sigue pendiente.


### 13/11/2026 — Reglas iniciales del nuevo recorrido

Se documentaron los objetivos personales, el cronómetro persistente, el cierre diario corregible, los seis rubros de puntuación y los premios. Se identificó que el conteo propuesto para Cultivo difiere del comportamiento implementado; quedan pendientes las reglas de detalle y la migración.


### 13/11/2026 — Detalle de puntuación y cronómetros

Se documentaron las escalas de puntos de trabajo, estudio, ocio y constancia, y la carga incremental del cronómetro. Se aclaró la acumulación de sobrantes de Cultivo mientras haya cumplimientos pendientes; quedan preguntas sobre límites, saldo y sesiones inferiores al mínimo.


### 13/11/2026 — Reglas de metas y recuento mensual

Se aclaró que las sesiones cortas de Cultivo se guardan y acumulan, que la constancia exige una hora en una misma categoría, que las metas semanales son tareas personales y que el resultado mensual se decide por promedio semanal. Quedan abiertos el cálculo del banco de ocio, el detalle de puntos y la aplicación de los empates.


### 13/11/2026 — Puntos de metas y cierre mensual

Se aclaró que las sesiones de una categoría se suman para constancia, que las metas semanales reparten cinco puntos por igual, que en los empates se conceden premios a ambas personas y que cada semana pertenece al mes de su lunes. Se conservó la tabla de ocio sin inferir reglas adicionales para el saldo.


### 13/11/2026 — Base de cronómetros

Se instaló en desarrollo una base aditiva para cuatro categorías con un cronómetro activo por persona, intervalos persistentes y cargas incrementales. La prueba SQL pasó con rollback y comprobó pausa, reinicio, exclusión de otro cronómetro y ausencia de solapamiento de cargas. Se preparó una pantalla de inicio; la validación live de APEX pasó y la pantalla se importó a desarrollo con aprobación; falta probarla en navegador. La asociación con metas, los colores configurables, objetivos y cierres siguen pendientes.


### 13/11/2026 — Día personal y elección de actividad

Se definió que el día de cada persona permanece abierto hasta su cierre y que el tiempo posterior a medianoche corresponde al día aún abierto. La actividad de Cultivo se elegirá al registrar el cronómetro. Estas reglas todavía no están implementadas.


### 13/11/2026 — Corrección de inicio del cronómetro

Al probar Iniciar se informó una violación de protección del campo interno de categoría. Se preparó desactivar la protección de valor de los tres campos que completa el navegador, manteniendo en servidor la validación de cuenta, acción y categoría. La prueba SQL comprobó el rechazo de acciones y categorías inválidas. La validación live de APEX pasó; se importó con aprobación y se confirmó que los tres campos aceptan valores del navegador. Queda pendiente repetir la prueba de interfaz.


### 13/11/2026 — Pausa al registrar un cronómetro

Se actualizó en desarrollo la lógica para que registrar pause el cronómetro. Si se conserva el contador, el tiempo mostrado queda disponible y volver a iniciar abre un nuevo intervalo; las cargas siguientes no duplican el anterior. La prueba SQL pasó con datos temporales y rollback; falta la prueba en interfaz.


### 13/11/2026 — Vinculación de segunda cuenta

Se confirmó la existencia de la segunda cuenta APEX, se vinculó al identificador de persona existente y se verificó con sesiones APEX que ambas cuentas resuelven personas distintas. Queda pendiente probar el acceso real y los intentos de escritura entre personas desde la aplicación.


### 13/11/2026 — Base del día personal

Se instalaron los días personales y la asociación de intervalos nuevos al día abierto, junto con una vista que resume el tiempo registrado por categoría. Se comprobó con datos temporales que solo existe un día abierto por persona, que permanece abierto al cambiar la fecha y que el resumen suma intervalos sin duplicarlos. Un intervalo previo sigue sin día asociado; no se modificó. La pantalla y el cierre quedan pendientes.


### 13/11/2026 — Cierre de día con reloj activo

Se implementó en desarrollo la base de cierre personal con confirmación del reloj activo, pausa y fotografía de los tiempos registrados. La prueba SQL verificó el rechazo sin confirmación, la pausa al confirmar, la conservación del tiempo pendiente y el rechazo de un segundo cierre; se revirtió. Se preparó una pantalla de resumen con aviso y confirmación; se ejecutó su contenido en una sesión APEX de prueba. La validación live de APEX pasó desde un directorio limpio después de que la comprobación previa excediera su límite al explorar las migraciones. Se importó con aprobación y se confirmaron la navegación, los procesos y la configuración de confirmación en APEX; falta probar la interfaz. La corrección posterior del resumen sigue pendiente.


### 13/11/2026 — Colores por cuenta

Se informó que el cierre del día funciona en la interfaz. Se preparó una pantalla para elegir colores de los cronómetros y guardarlos por cuenta; los valores se validan antes de utilizarlos en CSS. La prueba SQL de aislamiento y la generación del inicio pasaron. La validación live de APEX pasó y se importó con aprobación; se confirmaron los selectores y la navegación. Falta la prueba en navegador.


### 13/11/2026 — Selector de color

Se comprobó por exportación que los cuatro selectores de color quedaron configurados como Color-only Popup y se sincronizó esa configuración en el código local. La página actual ya contiene el cambio; no requiere importación para aplicarlo.


### 13/11/2026 — Confirmaciones de la aplicación

Se creó una guía reutilizable para mensajes y confirmaciones accesibles, y se agregó una regla del proyecto para evitar diálogos nativos. Se preparó el reemplazo de la confirmación del cronómetro por `apex.message.confirm`; se probaron las rutas de confirmar, conservar y error. La confirmación de cierre existente utiliza el mecanismo declarativo de APEX. La validación live pasó, se importó con aprobación y se confirmó que la página usa la confirmación de APEX. Falta la prueba visual.


### 13/11/2026 — Objetivos y progreso de horas

Se instalaron objetivos de horas por cuenta, categoría y semana y una vista de progreso basada en días personales. Se prepararon pantallas de objetivos propios y tablas compartidas. Las pruebas SQL verificaron fracciones, aislamiento, rechazo de valores inválidos, cambio de semana durante la edición y suma de tiempo; el contenido del progreso se ejecutó en una sesión APEX de prueba. La validación live de APEX pasó, se importaron con aprobación y se confirmaron navegación y procesos. Se ejecutó el proceso instalado con una fracción decimal en una sesión de prueba; falta comprobar las pantallas en navegador. El progreso no incluye tiempos sin día ni sesiones manuales de Cultivo y no calcula puntos.


### 14/11/2026 — Revisión de cambios para versionar

Se revisó el estado de la aplicación y se actualizó la documentación para distinguir lo implementado de lo pendiente. Pasaron las once comprobaciones SQL en desarrollo, con sesiones y datos temporales, y la validación live de APEX; no se ejecutaron pruebas automáticas de interfaz. Se verificó que la exportación no contenga el valor privado de protección. La entrega mantiene como pendientes la integración de Cultivo, las correcciones y la comprobación completa de permisos.


### 14/11/2026 — Integración de Cultivo con cronómetro

Se preparó una integración aditiva para asociar el tiempo nuevo del cronómetro a una actividad, acumular también las sesiones manuales nuevas y mantener el cálculo de registros anteriores. La prueba SQL con rollback verificó tiempos cortos, múltiplos, descarte al completar, actividad ajena, semana incorrecta, aviso cercano y ausencia de cargas repetidas. La selección de actividad y la confirmación de APEX pasaron la validación live y se importaron a desarrollo con autorización. Se comprobó que la página y sus procesos existen, que los objetos de base están válidos y que la prueba SQL sigue pasando; falta la comprobación desde el navegador.

Se confirmó en navegador que dos sesiones cortas acumulan un cumplimiento. Se detectó que el cronómetro seguía activo al elegir la actividad; se implementó una pausa al pulsar «Registrar tiempo». Una prueba con sesión temporal y rollback verificó la pausa y la repetición con el reloj ya pausado; la validación live de APEX pasó, se importó a desarrollo con autorización y se confirmó el proceso instalado. Falta comprobarlo desde el navegador.

Se comprobó en navegador que el cronómetro se pausa al comenzar el registro. El aviso de cercanía a otro cumplimiento sigue pendiente de comprobación visual.

### 14/11/2026 — Reinicio de cronómetros

Se instaló en desarrollo un procedimiento que pausa y reinicia un cronómetro, conservando las cargas registradas y la evidencia del tiempo pendiente descartado. La prueba SQL con rollback comprobó el descarte, la conservación de las cargas y el reinicio repetido. El botón con confirmación pasó la validación live de APEX, se importó con autorización y se comprobó el proceso instalado; falta la prueba en navegador.

### 14/11/2026 — Plan y metas semanales

Se desglosaron los pendientes conocidos en un plan revisable. Se instaló una base aditiva de metas semanales por persona y semana; una prueba SQL con rollback verificó el puntaje proporcional, el rechazo de cambios ajenos y la protección ante cambios de semana. La pantalla de alta y cambio de estado pasó la validación live, se importó con autorización y se comprobó que sus procesos y el reinicio de cronómetros siguen instalados. Falta probar en navegador; sigue abierta la regla para semanas sin metas.

Se confirmó en navegador el funcionamiento del reinicio y de las metas semanales. Se informó un aviso de confirmación o salida con aspecto genérico del navegador; falta identificar el recorrido exacto para corregirlo.

Se identificó el aviso como la protección del navegador ante cambios sin guardar. Se validó un ajuste que excluye del detector los campos ocultos internos de Inicio y Cierre y conserva la protección de los formularios. Falta identificar la acción concreta, importar el ajuste y comprobar en navegador si corrige el caso informado.

Se identificó el caso concreto al agregar una meta semanal. La opción de APEX que omite la advertencia al enviar el formulario pasó la validación live y se importó con autorización. Se verificó que el botón y los campos internos tienen la configuración esperada, y que el campo de descripción conserva la protección. Falta comprobar el comportamiento en navegador.

Se informó el mismo aviso al marcar metas como completadas o pendientes. Se configuró el selector para que no cuente como cambio sin guardar, conservando la protección del texto de una meta nueva. La validación live pasó, se importó con autorización y se comprobó la configuración instalada; falta probar en navegador.

### 14/11/2026 — Puntos de trabajo y estudio

Se instaló una función de puntos parciales para trabajo y estudio, con los cortes acordados sin redondear previamente; sin objetivo no asigna puntos. La prueba SQL verificó los límites, fracciones y ausencia de objetivo. La tabla de progreso pasó la validación live, se importó con autorización y se verificó que utiliza la función válida; falta comprobarla en navegador. Constancia, ocio y Cultivo siguen pendientes de puntuación.

Se confirmó la visualización y los puntos en navegador. Se definió el objetivo semanal de horas de Cultivo como la suma del mínimo de cada meta por su frecuencia. La vista nueva pasó una prueba SQL con rollback; las pantallas para eliminar el objetivo independiente y mostrar el calculado pasaron validación live. Falta importar y probarlas; los objetivos independientes anteriores se conservan sin usarse para el cálculo nuevo.

### 16/11/2026 — Objetivo de Cultivo calculado

Se importaron las pantallas de objetivo calculado a desarrollo con autorización. Se verificó que el campo independiente ya no aparece en la configuración, que el progreso usa la vista nueva y que la prueba SQL sigue pasando. Falta comprobar las pantallas en navegador.

Se instaló una base aditiva para reconocer días de constancia mediante horas de trabajo o estudio, con sesiones sumadas por categoría. La prueba SQL verificó que ambas categorías se evalúan por separado. Queda por confirmar a qué semana corresponde un día personal que cruza de domingo a lunes antes de mostrar el puntaje semanal.

Se confirmó que un día personal pertenece a la semana de su fecha, aunque se cierre el lunes siguiente. Se agregó el resumen semanal con un máximo de cinco puntos. La prueba SQL comprobó acumulación de sesiones, categorías separadas y seis días activos con cinco puntos; la pantalla pasó validación live, se importó con autorización y se confirmó que usa la vista válida. Falta prueba en navegador.

Se observó un objetivo de Cultivo con decimales extensos y una diferencia visual de un segundo al restar duraciones. Se preparó una presentación uniforme en horas, minutos y segundos y una resta coherente con los valores visibles. La validación live y la generación de la pantalla con el caso observado pasaron; se importó con autorización y se confirmó la configuración instalada. Falta comprobación visual.

Se confirmó en navegador que el objetivo de Cultivo se muestra en horas y minutos. La puntuación de constancia sigue pendiente de una prueba completa desde la interfaz.

### 16/11/2026 — Progreso compartido de metas semanales

Se preparó la presentación del avance y puntaje de metas semanales de cada persona en el progreso compartido. Una prueba con sesión APEX y datos temporales verificó el resultado proporcional y el caso sin metas para personas distintas; la validación live pasó. Se importó con autorización y se confirmó que la pantalla usa la vista correspondiente. Falta prueba en navegador.

Se confirmó en navegador que tres metas completadas de tres muestran cinco puntos en el progreso semanal.
