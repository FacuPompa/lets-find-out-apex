-- Cada confirmación guarda una fotografía; las confirmaciones previas se conservan.
begin
  execute immediate q'[
    create table lfo_cierres_semanales (
      id number generated always as identity primary key,
      persona varchar2(4 char) not null,
      semana_inicio date not null,
      confirmado_en timestamp with time zone default systimestamp not null,
      usuario_apex varchar2(255 char) not null,
      puntos_trabajo number not null,
      puntos_estudio number not null,
      puntos_constancia number not null,
      puntos_ocio number not null,
      puntos_cultivo number not null,
      puntos_metas number not null,
      puntos_total number not null,
      premio varchar2(500 char),
      constraint lfo_cierre_sem_persona_ck check (persona in ('BRI','FACU')),
      constraint lfo_cierre_sem_fecha_ck check (semana_inicio=trunc(semana_inicio,'IW')),
      constraint lfo_cierre_sem_total_ck check (puntos_total between 0 and 30)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
create or replace view lfo_cierre_semanal_actual_v as
select id,persona,semana_inicio,confirmado_en,usuario_apex,puntos_trabajo,puntos_estudio,
       puntos_constancia,puntos_ocio,puntos_cultivo,puntos_metas,puntos_total,premio
from (select c.*,row_number() over(partition by persona,semana_inicio order by id desc) rn
      from lfo_cierres_semanales c)
where rn=1;
/
create or replace package lfo_cierre_semanal authid definer as
  procedure confirmar(p_semana_esperada date,p_version number,p_premio varchar2);
end lfo_cierre_semanal;
/
create or replace package body lfo_cierre_semanal as
  procedure confirmar(p_semana_esperada date,p_version number,p_premio varchar2) is
    v_persona varchar2(4):=lfo_persona_actual;
    v_semana date:=to_date(nvl(apex_util.get_preference('LFO_SEMANA',v('APP_USER')),
      to_char(trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date),'IW'),'YYYY-MM-DD')),'FXYYYY-MM-DD');
    v_dummy varchar2(4); v_version number; v_pendientes number;
    v_puntos lfo_puntos_semanales_v%rowtype;
    v_premio varchar2(32767):=trim(p_premio);
  begin
    if p_semana_esperada is null or p_semana_esperada!=v_semana or v_semana!=trunc(v_semana,'IW') then
      raise_application_error(-20220,'Cambió la semana seleccionada. Volvé a abrir el cierre.');
    end if;
    if length(v_premio)>500 then raise_application_error(-20221,'El premio puede tener hasta 500 caracteres.'); end if;
    begin insert into lfo_reloj_persona(persona) values(v_persona);
    exception when dup_val_on_index then null; end;
    select persona into v_dummy from lfo_reloj_persona where persona=v_persona for update;
    select nvl(max(id),0) into v_version from lfo_cierres_semanales
      where persona=v_persona and semana_inicio=v_semana;
    if p_version is null or p_version!=v_version then
      raise_application_error(-20222,'El cierre cambió. Volvé a abrirlo y revisá el resultado.');
    end if;
    select count(*) into v_pendientes from lfo_reloj_tramos t
      join lfo_dias_personales d on d.id=t.dia_id and d.persona=t.persona
      where t.persona=v_persona and d.fecha_logica>=v_semana and d.fecha_logica<v_semana+7
        and (t.fin is null or t.registrado_hasta<t.fin);
    if v_pendientes>0 then
      raise_application_error(-20223,'Tenés tiempo sin registrar en esta semana. Pausá y registrá los cronómetros antes de cerrar.');
    end if;
    begin
      select * into v_puntos from lfo_puntos_semanales_v where persona=v_persona and semana_inicio=v_semana;
    exception when no_data_found then
      raise_application_error(-20224,'Completá los objetivos de horas y definí al menos una meta semanal y una actividad de Cultivo.');
    end;
    if v_puntos.puntos_totales is null then
      raise_application_error(-20224,'Completá los objetivos de horas y definí al menos una meta semanal y una actividad de Cultivo.');
    end if;
    insert into lfo_cierres_semanales(persona,semana_inicio,usuario_apex,puntos_trabajo,puntos_estudio,
      puntos_constancia,puntos_ocio,puntos_cultivo,puntos_metas,puntos_total,premio)
    values(v_persona,v_semana,v('APP_USER'),round(v_puntos.puntos_trabajo),round(v_puntos.puntos_estudio),
      round(v_puntos.puntos_constancia),round(v_puntos.puntos_ocio),round(v_puntos.puntos_cultivo),
      round(v_puntos.puntos_metas_semanales),v_puntos.puntos_totales,v_premio);
  end;
end lfo_cierre_semanal;
/
