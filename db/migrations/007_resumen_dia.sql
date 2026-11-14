-- El resumen suma únicamente intervalos registrados asociados a un día.
-- Los registros anteriores sin día quedan fuera hasta acordar su migración.
create or replace view lfo_resumen_dia_v as
select d.id dia_id, d.persona, d.fecha_logica, r.categoria,
       sum(extract(day from (r.hasta - r.desde)) * 86400
         + extract(hour from (r.hasta - r.desde)) * 3600
         + extract(minute from (r.hasta - r.desde)) * 60
         + extract(second from (r.hasta - r.desde))) segundos,
       count(*) intervalos
from lfo_dias_personales d
join lfo_reloj_tramos t on t.dia_id = d.id and t.persona = d.persona
join lfo_tiempo_registrado r on r.tramo_id = t.id and r.persona = d.persona
group by d.id, d.persona, d.fecha_logica, r.categoria;
