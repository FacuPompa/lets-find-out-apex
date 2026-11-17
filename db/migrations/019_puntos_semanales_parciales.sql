-- Vista de puntajes ya definidos; no calcula un total ni cierra la semana.
create or replace view lfo_puntos_semanales_parciales_v as
with semanas as (
  select persona,semana_inicio from lfo_progreso_horas_v
  union select persona,semana_inicio from lfo_constancia_semanal_v
  union select persona,semana_inicio from lfo_resumen_metas_semanales_v
), horas as (
  select persona,semana_inicio,
    max(case when categoria='TRABAJO' then lfo_puntos_horas(segundos,horas_objetivo) end) puntos_trabajo,
    max(case when categoria='ESTUDIO' then lfo_puntos_horas(segundos,horas_objetivo) end) puntos_estudio
  from lfo_progreso_horas_v group by persona,semana_inicio
)
select s.persona,s.semana_inicio,h.puntos_trabajo,h.puntos_estudio,
       nvl(c.puntos,0) puntos_constancia,m.puntos puntos_metas_semanales
from semanas s
left join horas h on h.persona=s.persona and h.semana_inicio=s.semana_inicio
left join lfo_constancia_semanal_v c on c.persona=s.persona and c.semana_inicio=s.semana_inicio
left join lfo_resumen_metas_semanales_v m on m.persona=s.persona and m.semana_inicio=s.semana_inicio;
/
