-- Ocio: el exceso respecto de las horas previstas determina el puntaje.
create or replace function lfo_puntos_ocio(p_segundos number,p_horas_objetivo number)
  return number deterministic authid definer
is
  v_exceso number;
begin
  if p_horas_objetivo is null or p_horas_objetivo<=0 then return null; end if;
  v_exceso:=greatest(nvl(p_segundos,0),0)-p_horas_objetivo*3600;
  if v_exceso<=0 then return 5;
  elsif v_exceso<=3600 then return 4;
  elsif v_exceso<=7200 then return 3;
  elsif v_exceso<=10800 then return 2;
  elsif v_exceso<=18000 then return 1;
  else return 0;
  end if;
end;
/
-- Cada cumplimiento aporta una parte igual del total, con tope por actividad.
create or replace view lfo_puntos_cultivo_v as
select persona,semana_inicio,sum(least(cumplimientos,veces_por_semana)) completados,
       sum(veces_por_semana) objetivo,
       5*sum(least(cumplimientos,veces_por_semana))/sum(veces_por_semana) puntos
from lfo_progreso_cultivo_v2 group by persona,semana_inicio;
/
create or replace view lfo_puntos_semanales_v as
with semanas as (
  select persona,semana_inicio from lfo_puntos_semanales_parciales_v
  union select persona,semana_inicio from lfo_puntos_cultivo_v
), ocio as (
  select persona,semana_inicio,lfo_puntos_ocio(segundos,horas_objetivo) puntos
  from lfo_progreso_horas_v where categoria='OCIO'
)
select s.persona,s.semana_inicio,p.puntos_trabajo,p.puntos_estudio,
       nvl(p.puntos_constancia,0) puntos_constancia,o.puntos puntos_ocio,
       c.puntos puntos_cultivo,p.puntos_metas_semanales,
       case when p.puntos_trabajo is not null and p.puntos_estudio is not null
          and o.puntos is not null and c.puntos is not null and p.puntos_metas_semanales is not null
         then round(p.puntos_trabajo)+round(p.puntos_estudio)+round(nvl(p.puntos_constancia,0))+
              round(o.puntos)+round(c.puntos)+round(p.puntos_metas_semanales)
       end puntos_totales
from semanas s
left join lfo_puntos_semanales_parciales_v p on p.persona=s.persona and p.semana_inicio=s.semana_inicio
left join ocio o on o.persona=s.persona and o.semana_inicio=s.semana_inicio
left join lfo_puntos_cultivo_v c on c.persona=s.persona and c.semana_inicio=s.semana_inicio;
/
