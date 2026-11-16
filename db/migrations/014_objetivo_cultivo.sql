-- Objetivo calculado a partir de metas, por persona y semana.
create or replace view lfo_objetivo_cultivo_v as
select persona, semana_inicio, sum(minutos_minimos * veces_por_semana) / 60 as horas_objetivo
from lfo_metas_cultivo
group by persona, semana_inicio;
/
