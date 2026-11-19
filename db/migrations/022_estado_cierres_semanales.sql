-- Identifica fotografías de cierre que ya no coinciden con los puntos actuales.
create or replace view lfo_estado_cierres_semanales_v as
select c.id,c.persona,c.semana_inicio,c.confirmado_en,c.puntos_total,c.premio,
       case when p.puntos_totales is not null
          and c.puntos_trabajo=round(p.puntos_trabajo) and c.puntos_estudio=round(p.puntos_estudio)
          and c.puntos_constancia=round(p.puntos_constancia) and c.puntos_ocio=round(p.puntos_ocio)
          and c.puntos_cultivo=round(p.puntos_cultivo) and c.puntos_metas=round(p.puntos_metas_semanales)
          then 'S' else 'N' end vigente
from lfo_cierre_semanal_actual_v c
left join lfo_puntos_semanales_v p on p.persona=c.persona and p.semana_inicio=c.semana_inicio;
/
