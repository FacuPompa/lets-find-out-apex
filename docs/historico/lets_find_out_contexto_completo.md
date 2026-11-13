# Let's Find Out! — Documento de contexto completo para Codex

> **Referencia histórica. Actualización del 11/11/2026:** las menciones a misiones se reemplazan por **metas semanales**. Cultivo ya no tiene áreas, pendiente obligatorio ni comodín; se habla de **metas de cultivo**. Cada meta de cultivo define actividad, mínimo de duración o cantidad y repeticiones semanales; varias pueden cumplirse el mismo día. Los modelos de datos, ejemplos y propuestas de abajo conservan el contexto original y no son especificación vigente. Para implementar, consultar `../../LEEME-PRIMERO.md` y las especificaciones actuales.

## 1. Identidad del proyecto

**Nombre completo:**

> Duelo de Pareja: ¿Quién hizo más cosas? ¿Hicieron cosas? ¿Qué hicieron? Let’s Find Out!

El nombre está inspirado en el programa ficticio de *BoJack Horseman*:

> Hollywoo Stars and Celebrities: What Do They Know? Do They Know Things?? Let’s Find Out!

**Nombres cortos posibles:**

- Let’s Find Out!
- Find Out
- Duelo de Pareja

**Participantes actuales:**

- Bri
- Facu

---

## 2. Qué es Let’s Find Out!

Let’s Find Out! es una dinámica de pareja gamificada para:

- reducir la procrastinación;
- hacer visible en qué se usa el tiempo;
- equilibrar trabajo, estudio y ocio;
- sostener hábitos;
- completar resultados concretos;
- reservar espacio para crecimiento o cultivo personal;
- convertir el seguimiento en algo divertido y compartido.

La competencia no busca premiar simplemente a quien acumula más horas. Cada persona puede tener objetivos distintos y compite principalmente contra sus propios compromisos.

La lógica es:

1. Cada semana, Bri y Facu definen objetivos.
2. Durante el día registran actividades.
3. La app calcula progreso, faltantes y excedentes.
4. Al final de la semana se calculan puntos.
5. El mes se cierra usando los resultados semanales.
6. Hay premios semanales y mensuales.

---

## 3. Problema original

Bri y Facu tienden a procrastinar tareas importantes.

La primera idea fue medir tiempo de:

- trabajo;
- estudio;
- ocio.

Después el sistema se refinó porque aparecieron varios problemas:

- Trabajo + estudio casi siempre podía superar al ocio sin esfuerzo.
- No todo el ocio es igual.
- Ver una película elegida no es lo mismo que perder una hora scrolleando.
- Una persona puede tener más tiempo disponible que la otra.
- Acumular horas no garantiza terminar resultados.
- Leer, entrenar o practicar un hobby compiten mal contra actividades de recompensa inmediata si todo se considera ocio.
- Los objetivos no deben cambiarse retroactivamente para acomodar resultados.

---

## 4. Principios del sistema

### 4.1. Objetivos personales

Cada persona puede tener metas distintas.

La competencia mide cumplimiento, no horas brutas.

### 4.2. El ocio no es un fracaso

Cada persona tiene horas base de ocio semanal.

Ese ocio puede usarse sin compensación ni culpa.

### 4.3. Ocio elegido y ocio fuga son diferentes

La intención define la categoría.

- Ocio elegido: descanso o entretenimiento decidido.
- Ocio fuga: tiempo que se escapó sin intención.

### 4.4. Horas y resultados se miden por separado

- Las horas muestran dedicación.
- Las misiones muestran entregables o resultados.
- El puntaje combina varias dimensiones.

### 4.5. Flexibilidad sin manipulación

Las reglas pueden ajustarse, sobre todo en semanas de prueba, pero no conviene modificar objetivos después de conocer el resultado final.

---

## 5. Categorías de actividad

## 5.1. Trabajo (`T`)

Actividades que hacen avanzar directamente un proyecto o producen un resultado concreto.

### Bri

- Dar clases de Pilates.
- Preparar clases.
- Grabar contenido.
- Editar videos.
- Editar fotos.
- Diseñar carruseles o publicaciones.
- Escribir o estructurar videos.
- Investigar específicamente para un video en desarrollo.
- Publicar contenido.
- Trabajar para clientes.
- Enviar mails.
- Organizar proyectos concretos.

### Facu

- Programar.
- Desarrollar funcionalidades.
- Corregir errores.
- Resolver tareas laborales.
- Diseñar arquitectura.
- Investigar una solución puntual y aplicarla.

**Regla:**

> Si produce o hace avanzar algo concreto, es Trabajo.

---

## 5.2. Estudio (`E`)

Actividades cuyo objetivo principal es aprender.

### Bri

- Leer libros tomando apuntes.
- Hacer cursos.
- Estudiar edición, comunicación o creación de contenido.
- Investigar temas todavía no ligados a una pieza concreta.
- Hacer seminarios.

### Facu

- Hacer cursos de programación.
- Aprender lenguajes.
- Leer documentación.
- Resolver ejercicios.
- Estudiar materias de facultad.

**Regla:**

> Si el objetivo principal es aprender, es Estudio.

---

## 5.3. Ocio elegido (`OE`)

Descanso o entretenimiento decidido conscientemente.

Ejemplos:

- anime;
- películas;
- series;
- videojuegos;
- YouTube por entretenimiento;
- redes durante un tiempo decidido;
- actividades recreativas.

### Actividades compartidas

Si Bri y Facu ven algo o juegan juntos durante dos horas:

- Bri suma 2 horas.
- Facu suma 2 horas.

No se divide el tiempo.

---

## 5.4. Ocio fuga (`OF`)

Tiempo de procrastinación o entretenimiento no decidido.

Ejemplos:

- entrar unos minutos a redes y quedarse mucho más;
- scrollear antes de empezar una tarea;
- saltar entre aplicaciones;
- seguir jugando mucho más de lo elegido;
- mirar videos automáticamente.

**Regla:**

> La actividad no define la categoría. La intención y el control sobre el tiempo sí.

---

## 5.5. Cultivo personal (`S`)

Categoría separada del ocio para proteger actividades valiosas que suelen perder frente al entretenimiento inmediato.

### Áreas

#### Cuerpo

- entrenar;
- correr;
- bicicleta intencional para entrenar;
- caminar como actividad física;
- movilidad.

No cuenta un traslado cotidiano.

#### Mente

- leer ficción o no ficción;
- meditar;
- journaling;
- escribir reflexiones;
- prácticas de introspección.

#### Hobbies

- pintar;
- dibujar;
- hacer velas;
- practicar guitarra;
- escribir por gusto;
- cocinar como actividad creativa;
- hobbies no laborales.

#### Cuidado personal y entornos

- skincare intencional;
- mascarillas;
- automimos;
- ordenar profundamente una habitación;
- limpiar el espacio de trabajo;
- limpiar toda la casa;
- reorganizar ambientes.

No cuentan tareas rutinarias mínimas.

#### Pendiente obligatorio

Una sesión adicional que puede ubicarse en cualquiera de las áreas.

No es opcional.

---

## 6. Sesiones de Cultivo personal

Cultivo se mide por sesiones, no principalmente por horas.

Cada persona define:

- meta total semanal;
- distribución por áreas.

### Ejemplo real de Bri

| Área | Objetivo |
|---|---:|
| Cuerpo | 2 |
| Mente | 3 |
| Hobbies | 1 |
| Cuidado personal y entornos | 1 |
| Pendiente obligatorio | 1 |
| Total | 8 |

### Reglas

- La sesión debe ser real e intencional.
- Puede registrarse duración.
- Una actividad larga normalmente cuenta como una sesión.
- Una actividad excepcionalmente grande podría valer dos si se acuerda antes.
- No se pueden dividir sesiones artificialmente.
- Puede aparecer una actividad espontánea durante la semana.
- La categoría debe decidirse antes o durante la actividad, no retroactivamente.

### Mínimos sugeridos

| Actividad | Mínimo |
|---|---:|
| Entrenamiento, correr o bici | 30 min |
| Lectura, guitarra o hobby | 20 min |
| Journaling | 15 min |
| Meditación | 10 min |
| Skincare o automimo | 20 min |
| Limpieza u orden | 30 min |

Los mínimos deberían ser configurables.

---

## 7. Tiempo neutro

No todo debe competir.

Ejemplos:

- dormir;
- comer;
- bañarse;
- trasladarse;
- trámites;
- higiene básica;
- tareas domésticas rutinarias;
- recuperación médica.

---

## 8. Registro diario

Formato actual de WhatsApp:

```text
T 1:20 editar vlog
E 0:45 curso
OE 2:00 película
OF 0:30 redes
S Mente 1/3
MS editar fotos
```

Códigos:

- `T`: Trabajo
- `E`: Estudio
- `OE`: Ocio elegido
- `OF`: Ocio fuga
- `S`: sesión de Cultivo
- `MS`: misión semanal completada

### Día lógico

El día termina cuando la persona se va a dormir, no necesariamente a las 00:00.

La app debe permitir asignar un registro de madrugada al día anterior.

---

## 9. Cronómetro integrado

La app debe incluir cronómetro.

### Flujo

1. Elegir categoría.
2. Escribir actividad opcional.
3. Elegir proyecto o misión relacionada.
4. Iniciar.
5. Pausar o finalizar.
6. Confirmar o editar.
7. Guardar.
8. Actualizar automáticamente todos los cálculos.

### Requisitos

- Un solo cronómetro activo por persona.
- Persistir aunque se cierre la pestaña.
- Recuperarse si se pierde conexión.
- Guardar hora de inicio real.
- Permitir pausas.
- Funcionar muy bien en celular.
- Idealmente ser PWA.

---

## 10. Registro manual

Botón principal:

> + Agregar registro

Campos:

- persona;
- fecha;
- día lógico;
- categoría;
- duración;
- descripción;
- proyecto;
- misión relacionada;
- fuente: cronómetro o manual;
- actividad compartida.

### Registrar para ambos

Debe existir una opción para crear el mismo registro para Bri y Facu.

---

## 11. Objetivos semanales

Cada persona define:

- horas de Trabajo;
- horas de Estudio;
- horas base de ocio;
- días de Constancia;
- sesiones de Cultivo;
- distribución de Cultivo;
- misiones;
- premio semanal;
- premio mensual.

### Ajuste entre Trabajo y Estudio

Durante semanas de prueba se permitió mover horas entre ambas.

Regla recomendada:

- se puede ajustar antes de una fecha límite;
- el total combinado no puede reducirse;
- guardar historial;
- después se bloquean.

---

## 12. Banco de ocio

### Fórmula

```text
ocio_computable = ocio_elegido + ocio_fuga * 1.5
```

### Exceso

```text
exceso_ocio = max(0, ocio_computable - ocio_base)
```

### Extra productivo

```text
extra_trabajo = max(0, trabajo_real - objetivo_trabajo)
extra_estudio = max(0, estudio_real - objetivo_estudio)
extra_productivo = extra_trabajo + extra_estudio
```

### Saldo

```text
saldo = extra_productivo - exceso_ocio
```

### Reglas

- Las horas básicas no compensan ocio.
- Solo compensan las horas por encima del objetivo.
- La deuda puede existir durante la semana.
- La deuda no se arrastra automáticamente.
- Cultivo no consume ocio.
- Cultivo no compensa ocio.

---

## 13. Constancia

Definición actual:

> Día activo = al menos una hora total de Trabajo o Estudio.

Debe ser configurable.

Cultivo no cuenta actualmente como día activo, salvo futura decisión.

---

## 14. Misiones semanales

Las misiones son resultados concretos.

### Ejemplos de Bri

- Publicar mínimo 3 cosas.
- Hacer 3 horas netas de edición del vlog 00.
- Avanzar una investigación al menos 4 horas.
- Editar fotos y videos del casamiento y subirlos al grupo.

### Ejemplos de Facu

- Caminar hasta Ediro.
- Entender Codex.
- Terminar clases de facultad.
- Sacar S con Vayne.
- Conseguir un negocio interesado.

### Tipos que la app debería soportar

1. Booleanas.
2. Por cantidad.
3. Por tiempo.
4. Por progreso manual.
5. Con subtareas.

### Relación con registros

Un registro puede sumar automáticamente a una misión.

---

## 15. Puntaje semanal

Versión actual propuesta:

| Área | Máximo |
|---|---:|
| Trabajo | 5 |
| Estudio | 5 |
| Cultivo personal | 5 |
| Constancia | 5 |
| Equilibrio del ocio | 5 |
| Misiones | 5 |
| Total | 30 |

### Trabajo y Estudio

| Cumplimiento | Puntos |
|---|---:|
| 100% o más | 5 |
| 80–99% | 4 |
| 60–79% | 3 |
| 40–59% | 2 |
| 1–39% | 1 |
| 0% | 0 |

### Equilibrio

| Saldo | Puntos |
|---|---:|
| 0 o positivo | 5 |
| Hasta -1 h | 4 |
| Entre -1 y -2 h | 3 |
| Entre -2 y -3 h | 2 |
| Entre -3 y -5 h | 1 |
| Menos de -5 h | 0 |

### Misiones

Conviene calcular por porcentaje porque la cantidad puede variar.

### Cultivo

La lógica aún está abierta.

Recomendación:

- porcentaje total de sesiones define puntaje base;
- para 5/5 deben cumplirse mínimos por área;
- si falta un área obligatoria, limitar máximo a 4;
- si faltan varias, limitar máximo a 3.

Debe ser configurable.

---

## 16. Cierre semanal

Momento oficial de “Let’s Find Out!”.

Debe mostrar:

- puntaje de Bri;
- puntaje de Facu;
- ganador;
- Trabajo;
- Estudio;
- Constancia;
- ocio elegido;
- ocio fuga;
- ocio computable;
- saldo;
- Cultivo;
- misiones;
- premio.

### Títulos secundarios opcionales

- Mayor constancia.
- Menor ocio fuga.
- Más horas productivas.
- Mayor mejora.
- Más sesiones de Cultivo.
- Víctima principal de Instagram.
- Criatura que más cosas hizo un martes.

---

## 17. Desempates

### Semanal

1. Mayor promedio de cumplimiento de Trabajo y Estudio.
2. Menor ocio fuga.
3. Más días activos.
4. Mejor saldo.
5. Piedra, papel o tijera al mejor de tres.

### Mensual

1. Más semanas ganadas.
2. Más categorías perfectas.
3. Menor ocio fuga mensual.
4. Más días activos.
5. Mayor mejora.
6. Piedra, papel o tijera al mejor de cinco.

---

## 18. Cierre mensual

Se usa el promedio de puntajes semanales.

Debe mostrar:

- promedio mensual;
- semanas ganadas;
- evolución;
- totales;
- ganador;
- premio.

---

## 19. Premios

Cada persona define su premio.

### Semanales

- elegir película;
- elegir comida;
- café o merienda;
- masaje;
- elegir plan;
- asistencia creativa;
- liberarse de una tarea menor.

### Mensuales

- salida a comer;
- cita organizada;
- regalo con presupuesto;
- día del ganador;
- actividad especial.

### Cooperativo

Si ambos superan cierto promedio, desbloquean algo juntos.

---

## 20. Reglas generales

1. El cronómetro empieza cuando empieza la actividad real.
2. Se pausa si se abandona más de cinco minutos.
3. No se duplica tiempo entre categorías.
4. Trabajo debe generar avance.
5. Estudio debe tener intención de aprendizaje.
6. Registrar durante el día o al cierre.
7. No cambiar objetivos después de conocer resultados.
8. Las horas extra no dan puntos infinitos.
9. Dormir menos no es estrategia válida.
10. Mentir al cronómetro es fraude deportivo doméstico.
11. El día lógico termina al dormir.
12. Las actividades compartidas se registran completas.
13. Ocio fuga vale x1.5.
14. Cultivo no consume ocio.
15. Las misiones deben tener criterio claro.
16. Actividades espontáneas de Cultivo pueden agregarse.
17. Cambios grandes de reglas deberían aplicar desde la semana siguiente.
18. El sistema debe motivar, no castigar.

---

## 21. Concepto de la app

La app debe sentirse como:

- centro de operaciones;
- marcador;
- videojuego retro;
- tablero semanal;
- espacio compartido de pareja;
- herramienta que da ganas de dejar abierta mientras trabajan.

No debe parecer una planilla empresarial.

---

## 22. Estética

Dirección visual:

- pixel art;
- cozy;
- retro game;
- colorida;
- romántica;
- competitiva sin agresividad;
- dos avatares;
- gatos;
- corazones;
- cielo;
- nubes;
- pasto;
- flores;
- honguitos.

### Pantalla inicial

Texto:

- Duelo de Pareja
- ¿Quién hizo más cosas? ¿Hicieron cosas? ¿Qué hicieron?
- Let’s Find Out!
- BRI
- FACU
- START

---

## 23. Pantalla principal

Dos tarjetas:

- Bri.
- Facu.

Cada una con:

- avatar;
- puntaje;
- Trabajo;
- Estudio;
- Constancia;
- Ocio;
- Cultivo;
- Misiones;
- saldo;
- faltantes;
- excedentes.

### Barras

Ejemplo:

```text
Trabajo
19 h 13 min / 20 h
Faltan 47 min
```

Si se supera:

```text
Objetivo cumplido
+1 h 20 min extra
```

### Banco de ocio

Mostrar:

- ocio base;
- ocio elegido;
- ocio fuga;
- penalización;
- ocio computable;
- disponible;
- deuda;
- compensación.

### Constancia

Fila de días.

### Cultivo

Mostrar:

- total;
- progreso por área;
- pendiente obligatorio;
- faltantes.

---

## 24. Objetivo diario

Función opcional:

- meta productiva;
- tarea principal;
- misión a avanzar;
- sesión de Cultivo.

No suma un sistema de puntos aparte.

---

## 25. To-do list

Nombre posible:

> Cola de enfoque

Máximo sugerido: 3 tareas principales.

Cada tarea puede iniciar el cronómetro.

No construir un gestor de proyectos enorme.

---

## 26. Historial y estadísticas

### Semanal

- totales;
- puntos;
- ganador;
- misiones;
- Cultivo;
- registros.

### Mensual

- promedio;
- semanas ganadas;
- evolución;
- ganador.

### Patrones futuros

- días más productivos;
- horas de mayor fuga;
- tiempo por proyecto;
- cumplimiento;
- sesiones por área;
- objetivos demasiado fáciles o difíciles.

---

## 27. MVP

1. Perfiles Bri y Facu.
2. Objetivos semanales.
3. Cronómetro.
4. Registro manual.
5. Categorías.
6. Actividades compartidas.
7. Barras de progreso.
8. Banco de ocio.
9. Constancia.
10. Misiones.
11. Cultivo.
12. Puntaje automático.
13. Edición y eliminación.
14. Cierre semanal.
15. Historial básico.
16. Responsive.
17. Persistencia.
18. Recuperación del cronómetro.

---

## 28. Segunda versión

- objetivos diarios;
- cola de enfoque;
- historial mensual;
- premios;
- desempates automáticos;
- notificaciones;
- estadísticas;
- rachas;
- logros;
- avatares;
- modo foco;
- exportación;
- calendario.

---

## 29. Versión avanzada

- mascota;
- animaciones;
- escena que cambia;
- vela o fuego durante sesiones;
- ceremonia automática;
- logros absurdos;
- trofeos;
- temas desbloqueables;
- sonidos;
- widgets;
- exportar cierre como imagen.

---

## 30. Modelo de datos sugerido

```ts
type User = {
  id: string
  name: string
  avatarUrl?: string
  timezone: string
}
```

```ts
type Week = {
  id: string
  startDate: string
  endDate: string
  status: "draft" | "active" | "closed"
  lockedAt?: string
  closedAt?: string
}
```

```ts
type WeeklyGoals = {
  id: string
  weekId: string
  userId: string
  workTargetMinutes: number
  studyTargetMinutes: number
  leisureBaseMinutes: number
  activeDaysTarget: number
  cultivationTotalTarget: number
  cultivationTargets: {
    body: number
    mind: number
    hobbies: number
    careAndEnvironment: number
    mandatoryFlexible: number
  }
}
```

```ts
type TimeEntryCategory =
  | "work"
  | "study"
  | "chosen_leisure"
  | "leisure_escape"
```

```ts
type TimeEntry = {
  id: string
  userId: string
  weekId: string
  logicalDate: string
  category: TimeEntryCategory
  description?: string
  missionId?: string
  startedAt?: string
  endedAt?: string
  durationMinutes: number
  source: "timer" | "manual"
  sharedActivityId?: string
}
```

```ts
type CultivationArea =
  | "body"
  | "mind"
  | "hobbies"
  | "care_environment"
  | "mandatory_flexible"
```

```ts
type CultivationSession = {
  id: string
  userId: string
  weekId: string
  logicalDate: string
  area: CultivationArea
  description: string
  durationMinutes?: number
  countsAsMandatoryFlexible?: boolean
}
```

```ts
type MissionType =
  | "boolean"
  | "count"
  | "duration"
  | "manual_progress"
  | "subtasks"
```

```ts
type Mission = {
  id: string
  weekId: string
  userId: string
  title: string
  description?: string
  type: MissionType
  targetCount?: number
  targetMinutes?: number
  currentCount?: number
  currentMinutes?: number
  completed: boolean
}
```

```ts
type WeeklyScore = {
  weekId: string
  userId: string
  workPoints: number
  studyPoints: number
  cultivationPoints: number
  consistencyPoints: number
  leisureBalancePoints: number
  missionPoints: number
  totalPoints: number
}
```

---

## 31. Funciones de cálculo

```ts
function pointsFromRatio(ratio: number): number {
  if (ratio >= 1) return 5
  if (ratio >= 0.8) return 4
  if (ratio >= 0.6) return 3
  if (ratio >= 0.4) return 2
  if (ratio > 0) return 1
  return 0
}
```

```ts
const computedLeisure =
  chosenLeisureMinutes + escapeLeisureMinutes * 1.5
```

```ts
const leisureExcess = Math.max(
  0,
  computedLeisure - leisureBaseMinutes
)
```

```ts
const extraWork = Math.max(
  0,
  workMinutes - workTargetMinutes
)
```

```ts
const extraStudy = Math.max(
  0,
  studyMinutes - studyTargetMinutes
)
```

```ts
const balance =
  extraWork + extraStudy - leisureExcess
```

```ts
function leisurePoints(balanceMinutes: number): number {
  if (balanceMinutes >= 0) return 5
  if (balanceMinutes >= -60) return 4
  if (balanceMinutes >= -120) return 3
  if (balanceMinutes >= -180) return 2
  if (balanceMinutes >= -300) return 1
  return 0
}
```

---

## 32. Casos límite

- Registro después de medianoche.
- Cronómetro olvidado.
- Registro compartido.
- Cambio de categoría.
- Objetivos bloqueados.
- Misión parcial.
- Ocio fuga con medios minutos.
- Enfermedad o recuperación.
- Sesión espontánea.
- Misión ambigua.
- Una actividad que avanza misión y Cultivo.
- Edición o eliminación accidental.
- Pérdida de conexión.
- Dos dispositivos abiertos.

---

## 33. Ejemplo real de semana actual de Bri

Objetivos:

- Trabajo: 20 h.
- Estudio: 7 h.
- Ocio base: 12 h.
- Cultivo: 8 sesiones.
- Misiones: 4.
- Constancia: 5 días.

Misiones:

- Publicar mínimo 3 cosas.
- 3 horas de edición del vlog 00.
- 4 horas de investigación.
- Editar fotos y videos del casamiento y subirlos al grupo.

Cultivo:

- Cuerpo 2.
- Mente 3.
- Hobbies 1.
- Cuidado y entornos 1.
- Pendiente 1.

Progreso conocido:

- Trabajo: 19 h 13 min.
- Estudio: 2 h 08 min.
- Ocio computable: aproximadamente 6 h 18 min.
- Constancia: 4 días.
- Cultivo:
  - Cuerpo 2/2.
  - Mente 1/3.
  - Hobbies 0/1.
  - Cuidado y entornos 1/1.
  - Pendiente 0/1.
- Misiones:
  - Casamiento completada.
  - Las demás pendientes o en progreso.

---

## 34. Navegación sugerida

### Inicio

- tablero;
- cronómetro;
- progreso;
- banco de ocio;
- misiones;
- Cultivo.

### Hoy

- plan diario;
- tareas;
- registros;
- cierre.

### Semana

- objetivos;
- puntaje;
- misiones;
- Cultivo;
- resultados parciales.

### Historial

- semanas;
- meses;
- ganadores;
- estadísticas.

### Configuración

- participantes;
- multiplicador de fuga;
- definición de día activo;
- cierre;
- puntaje;
- categorías;
- premios.

---

## 35. Prioridades de producto

### Muy importante

- registro rápido;
- cronómetro confiable;
- mobile first;
- cálculos transparentes;
- edición fácil;
- poca fricción.

### Importante

- estética;
- sensación de juego;
- progreso compartido;
- historial;
- privacidad.

### No prioritario

- IA;
- chat;
- red social;
- monetización;
- gestor de proyectos complejo.

---

## 36. Tono del producto

Debe sentirse:

- divertido;
- íntimo;
- absurdo;
- cálido;
- competitivo;
- flexible;
- no moralista;
- no corporativo;
- no punitivo.

El enemigo es la procrastinación, no la otra persona.

---

## 37. Decisiones abiertas

1. Fórmula exacta de Cultivo.
2. Si Cultivo cuenta para Constancia.
3. Cómo manejar días de enfermedad.
4. Si Trabajo y Estudio pueden intercambiarse siempre.
5. Cuándo bloquear objetivos.
6. Si ocio base no usado da algún beneficio.
7. Si hay máximo de compensación.
8. Si una sesión larga vale dos.
9. Cómo puntuar misiones variables.
10. Si se modifican misiones a mitad de semana.
11. Si habrá resumen automático.
12. Si será solo para Bri y Facu.
13. Tipo de login.
14. Stack técnico.
15. Base de datos.
16. Notificaciones.
17. Exportación.
18. Widgets.

---

## 38. Recomendación de desarrollo

### Fase 1

PWA responsive con:

- autenticación;
- dos perfiles;
- objetivos;
- cronómetro;
- registro manual;
- sincronización;
- cálculos;
- tablero;
- cierre semanal.

### Fase 2

Gamificación y cierre visual.

### Fase 3

Estadísticas y personalización.

### Fase 4

Funciones experimentales.

---

## 39. Resumen ejecutivo para Codex

Construir una app web compartida para Bri y Facu que gamifica objetivos semanales.

Debe:

- definir metas individuales;
- cronometrar;
- cargar tiempo manual;
- distinguir Trabajo, Estudio, Ocio elegido y Ocio fuga;
- aplicar x1.5 a Ocio fuga;
- calcular banco de ocio;
- registrar sesiones de Cultivo;
- registrar misiones;
- calcular Constancia;
- mostrar progreso visual;
- calcular puntos;
- cerrar semanas;
- comparar participantes;
- guardar historial;
- tener estética cozy pixel art.

No es una app genérica de productividad.

Es una implementación fiel de esta dinámica de pareja.
