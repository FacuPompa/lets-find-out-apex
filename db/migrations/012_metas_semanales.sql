-- Metas personales por semana; conserva los datos existentes.
begin
  execute immediate q'[
    create table lfo_metas_semanales (
      id number generated always as identity primary key,
      persona varchar2(4 char) not null,
      semana_inicio date not null,
      descripcion varchar2(300 char) not null,
      completada varchar2(1 char) default 'N' not null,
      creada_en timestamp with time zone default systimestamp not null,
      constraint lfo_meta_semanal_persona_ck check (persona in ('BRI','FACU')),
      constraint lfo_meta_semanal_semana_ck check (semana_inicio=trunc(semana_inicio,'IW')),
      constraint lfo_meta_semanal_estado_ck check (completada in ('S','N'))
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
create or replace package lfo_metas_semanales_api authid definer as
  procedure crear(p_descripcion varchar2, p_semana_esperada date);
  procedure cambiar_estado(p_id number, p_completada varchar2, p_semana_esperada date);
end lfo_metas_semanales_api;
/
create or replace package body lfo_metas_semanales_api as
  function semana_actual return date is
    v_fecha date;
  begin
    v_fecha := to_date(nvl(apex_util.get_preference('LFO_SEMANA',v('APP_USER')),
      to_char(trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date),'IW'),'YYYY-MM-DD')),'FXYYYY-MM-DD');
    if v_fecha != trunc(v_fecha,'IW') then raise_application_error(-20181,'La semana seleccionada no es válida.'); end if;
    return v_fecha;
  end;
  procedure verificar(p_esperada date, p_actual date) is
  begin
    if p_esperada is null or p_esperada != p_actual then
      raise_application_error(-20182,'Cambió la semana seleccionada. Volvé a abrir las metas.');
    end if;
  end;
  procedure crear(p_descripcion varchar2, p_semana_esperada date) is
    v_persona varchar2(4) := lfo_persona_actual;
    v_semana date := semana_actual;
    v_descripcion varchar2(32767) := trim(p_descripcion);
  begin
    verificar(p_semana_esperada,v_semana);
    if v_descripcion is null or length(v_descripcion)>300 then
      raise_application_error(-20183,'Escribí una meta de hasta 300 caracteres.');
    end if;
    insert into lfo_metas_semanales(persona,semana_inicio,descripcion) values(v_persona,v_semana,v_descripcion);
  end;
  procedure cambiar_estado(p_id number, p_completada varchar2, p_semana_esperada date) is
    v_persona varchar2(4) := lfo_persona_actual;
    v_semana date := semana_actual;
  begin
    verificar(p_semana_esperada,v_semana);
    if p_completada is null or p_completada not in ('S','N') then raise_application_error(-20184,'Estado inválido.'); end if;
    update lfo_metas_semanales set completada=p_completada
    where id=p_id and persona=v_persona and semana_inicio=v_semana;
    if sql%rowcount=0 then raise_application_error(-20185,'La meta no existe en tu semana seleccionada.'); end if;
  end;
end lfo_metas_semanales_api;
/
create or replace view lfo_resumen_metas_semanales_v as
select persona, semana_inicio, count(*) total,
       sum(case when completada='S' then 1 else 0 end) completadas,
       5 * sum(case when completada='S' then 1 else 0 end) / count(*) puntos
from lfo_metas_semanales group by persona,semana_inicio;
/
