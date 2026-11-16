-- Evalúa las categorías por separado; el llamador suma las sesiones del día.
create or replace function lfo_dia_constante(p_trabajo_segundos number, p_estudio_segundos number)
  return number deterministic authid definer
is
begin
  if nvl(p_trabajo_segundos,0) >= 3600 or nvl(p_estudio_segundos,0) >= 3600 then
    return 1;
  end if;
  return 0;
end;
/
create or replace view lfo_constancia_dia_v as
select persona, fecha_logica,
       lfo_dia_constante(
         sum(case when categoria='TRABAJO' then segundos else 0 end),
         sum(case when categoria='ESTUDIO' then segundos else 0 end)
       ) dia_activo
from lfo_resumen_dia_v
where categoria in ('TRABAJO','ESTUDIO')
group by persona,fecha_logica;
/
-- La semana es la del día personal, incluso si se cierra al día siguiente.
create or replace view lfo_constancia_semanal_v as
select persona, trunc(fecha_logica,'IW') semana_inicio,
       sum(dia_activo) dias_activos, least(5,sum(dia_activo)) puntos
from lfo_constancia_dia_v
group by persona,trunc(fecha_logica,'IW');
/
