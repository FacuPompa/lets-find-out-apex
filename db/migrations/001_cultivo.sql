-- Primer paso del prototipo. Ejecutar como LFO_APP_DEV.
-- Cada bloque se puede volver a ejecutar sin borrar tablas ni registros.
-- La semana se elige por su lunes; el dia logico se selecciona explicitamente.
begin
  execute immediate q'[
    create table lfo_metas_cultivo (
      id number generated always as identity primary key,
      persona varchar2(4 char) not null,
      semana_inicio date not null,
      nombre varchar2(100 char) not null,
      minutos_minimos number not null,
      veces_por_semana number not null,
      creado_en timestamp with time zone default systimestamp not null,
      constraint lfo_meta_persona_ck check (persona in ('BRI', 'FACU')),
      constraint lfo_meta_lunes_ck check (semana_inicio = trunc(semana_inicio, 'IW')),
      constraint lfo_meta_nombre_ck check (trim(nombre) is not null),
      constraint lfo_meta_minutos_ck check (minutos_minimos >= 1 and minutos_minimos = trunc(minutos_minimos)),
      constraint lfo_meta_veces_ck check (veces_por_semana >= 1 and veces_por_semana = trunc(veces_por_semana)),
      constraint lfo_meta_semana_uq unique (id, semana_inicio),
      constraint lfo_meta_nombre_uq unique (persona, semana_inicio, nombre)
    )
  ]';
exception when others then
  if sqlcode != -955 then raise; end if;
end;
/

begin
  execute immediate q'[
    create table lfo_registros_cultivo (
      id number generated always as identity primary key,
      meta_id number not null,
      semana_inicio date not null,
      dia_logico date not null,
      minutos number not null,
      creado_en timestamp with time zone default systimestamp not null,
      constraint lfo_reg_meta_fk foreign key (meta_id, semana_inicio)
        references lfo_metas_cultivo (id, semana_inicio),
      constraint lfo_reg_dia_ck check (
        dia_logico = trunc(dia_logico)
        and dia_logico >= semana_inicio and dia_logico < semana_inicio + 7
      ),
      constraint lfo_reg_minutos_ck check (minutos >= 1 and minutos = trunc(minutos))
    )
  ]';
exception when others then
  if sqlcode != -955 then raise; end if;
end;
/

begin
  execute immediate 'create index lfo_reg_meta_ix on lfo_registros_cultivo (meta_id, semana_inicio)';
exception when others then
  if sqlcode != -955 then raise; end if;
end;
/

create or replace view lfo_progreso_cultivo_v as
select m.id, m.persona, m.semana_inicio, m.nombre,
       m.minutos_minimos, m.veces_por_semana,
       count(r.id) as registros,
       count(case when r.minutos >= m.minutos_minimos then 1 end) as cumplimientos,
       greatest(0, m.veces_por_semana - count(case when r.minutos >= m.minutos_minimos then 1 end)) as faltantes,
       least(100, round(100 * count(case when r.minutos >= m.minutos_minimos then 1 end) / m.veces_por_semana, 1)) as porcentaje
from lfo_metas_cultivo m
left join lfo_registros_cultivo r on r.meta_id = m.id and r.semana_inicio = m.semana_inicio
group by m.id, m.persona, m.semana_inicio, m.nombre, m.minutos_minimos, m.veces_por_semana;

-- Prototipo: falta autenticacion/autorizacion, bloqueo e historial de cambios.
-- No exponer formularios de edicion a usuarios hasta implementar esas reglas.
