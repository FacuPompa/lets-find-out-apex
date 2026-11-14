-- Integracion aditiva de registros nuevos. No modifica ni reinterpreta el historial anterior.
begin
  execute immediate q'[
    create table lfo_cultivo_manual_nuevo (
      registro_id number primary key references lfo_registros_cultivo(id),
      segundos_validos number not null,
      constraint lfo_cultivo_manual_seg_ck check (segundos_validos >= 0)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
begin
  execute immediate q'[
    create table lfo_cultivo_tiempo (
      tiempo_id number primary key references lfo_tiempo_registrado(id),
      meta_id number not null references lfo_metas_cultivo(id),
      segundos_validos number not null,
      constraint lfo_cultivo_tiempo_seg_ck check (segundos_validos >= 0)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
-- La versión preliminar sin segundos válidos no debe tener registros reales.
declare
  v_existe number;
  v_filas number;
begin
  for t in (select 'LFO_CULTIVO_MANUAL_NUEVO' nombre from dual union all select 'LFO_CULTIVO_TIEMPO' from dual) loop
    select count(*) into v_existe from user_tab_columns where table_name=t.nombre and column_name='SEGUNDOS_VALIDOS';
    if v_existe=0 then
      execute immediate 'select count(*) from ' || t.nombre into v_filas;
      if v_filas != 0 then raise_application_error(-20174, 'Hay datos que requieren migración antes de agregar segundos válidos.'); end if;
      execute immediate 'alter table ' || t.nombre || ' add (segundos_validos number not null)';
    end if;
  end loop;
end;
/
declare
  v_existe number;
begin
  select count(*) into v_existe from user_constraints where constraint_name='LFO_CULTIVO_MANUAL_SEG_CK';
  if v_existe=0 then
    execute immediate 'alter table lfo_cultivo_manual_nuevo add constraint lfo_cultivo_manual_seg_ck check (segundos_validos >= 0)';
  end if;
  select count(*) into v_existe from user_constraints where constraint_name='LFO_CULTIVO_TIEMPO_SEG_CK';
  if v_existe=0 then
    execute immediate 'alter table lfo_cultivo_tiempo add constraint lfo_cultivo_tiempo_seg_ck check (segundos_validos >= 0)';
  end if;
end;
/
create or replace package lfo_cultivo_nuevo authid definer as
  procedure registrar_manual(p_meta_id number, p_dia date, p_minutos number);
  procedure registrar_cronometro(p_meta_id number);
  function aviso_minutos(p_meta_id number) return number;
  procedure operar_reloj(p_accion varchar2, p_categoria varchar2, p_reiniciar varchar2);
end lfo_cultivo_nuevo;
/
create or replace package body lfo_cultivo_nuevo as
  function semana_actual return date is
  begin
    return to_date(nvl(apex_util.get_preference('LFO_SEMANA',v('APP_USER')),
      to_char(trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date),'IW'),'YYYY-MM-DD')),'FXYYYY-MM-DD');
  end;
  function semana_meta(p_meta_id number, p_persona varchar2) return date is
    v_semana date;
    v_actual date := semana_actual;
  begin
    select semana_inicio into v_semana from lfo_metas_cultivo
      where id=p_meta_id and persona=p_persona and semana_inicio=v_actual for update;
    return v_semana;
  exception when no_data_found then
    raise_application_error(-20170,'La actividad no está disponible para tu cuenta y la semana seleccionada.');
  end;
  function capacidad_restante(p_meta_id number) return number is
    v_minimo number;
    v_objetivo number;
    v_anteriores number;
    v_manual number;
    v_cronometro number;
  begin
    select minutos_minimos, veces_por_semana into v_minimo,v_objetivo from lfo_metas_cultivo where id=p_meta_id;
    select count(*) into v_anteriores from lfo_registros_cultivo r
      where r.meta_id=p_meta_id and r.minutos>=v_minimo
      and not exists (select 1 from lfo_cultivo_manual_nuevo n where n.registro_id=r.id);
    select nvl(sum(n.segundos_validos),0) into v_manual from lfo_registros_cultivo r
      join lfo_cultivo_manual_nuevo n on n.registro_id=r.id where r.meta_id=p_meta_id;
    select nvl(sum(c.segundos_validos),0) into v_cronometro from lfo_cultivo_tiempo c where c.meta_id=p_meta_id;
    return greatest(0,greatest(v_objetivo-v_anteriores,0)*v_minimo*60-v_manual-v_cronometro);
  end;
  procedure registrar_manual(p_meta_id number, p_dia date, p_minutos number) is
    v_persona varchar2(4) := lfo_persona_actual;
    v_semana date;
    v_id number;
    v_validos number;
  begin
    if p_meta_id is null or p_dia is null or p_minutos is null then
      raise_application_error(-20010,'Completá la meta, el día y los minutos.');
    end if;
    if p_dia != trunc(p_dia) then raise_application_error(-20011,'Indicá una fecha sin hora.'); end if;
    if p_minutos < 1 or p_minutos != trunc(p_minutos) then
      raise_application_error(-20012,'Indicá minutos enteros mayores que cero.');
    end if;
    v_semana := semana_meta(p_meta_id,v_persona);
    if p_dia < v_semana or p_dia >= v_semana+7 then
      raise_application_error(-20014,'El día debe pertenecer a la semana de la meta.');
    end if;
    v_validos := least(p_minutos*60, capacidad_restante(p_meta_id));
    insert into lfo_registros_cultivo(meta_id,semana_inicio,dia_logico,minutos)
      values(p_meta_id,v_semana,p_dia,p_minutos) returning id into v_id;
    insert into lfo_cultivo_manual_nuevo(registro_id,segundos_validos) values(v_id,v_validos);
  end;
  procedure registrar_cronometro(p_meta_id number) is
    type ids_t is table of number index by pls_integer;
    type fechas_t is table of timestamp with time zone index by pls_integer;
    v_ids ids_t;
    v_desde fechas_t;
    v_count pls_integer := 0;
    v_vinculados pls_integer := 0;
    v_capacidad number;
    v_segundos number;
    v_persona varchar2(4) := lfo_persona_actual;
    v_dummy varchar2(4);
    v_semana date;
  begin
    v_semana := semana_meta(p_meta_id,v_persona);
    begin
      select persona into v_dummy from lfo_reloj_persona where persona=v_persona for update;
    exception when no_data_found then
      raise_application_error(-20106,'No hay tiempo nuevo para registrar.');
    end;
    for tramo in (
      select t.id,t.registrado_hasta,t.dia_id,d.fecha_logica
      from lfo_reloj_tramos t left join lfo_dias_personales d on d.id=t.dia_id and d.persona=t.persona
      where t.persona=v_persona and t.categoria='CULTIVO' and (t.fin is null or t.registrado_hasta<t.fin)
      order by t.id
    ) loop
      if tramo.dia_id is null or tramo.fecha_logica < v_semana or tramo.fecha_logica >= v_semana+7 then
        raise_application_error(-20171,'Hay tiempo pendiente de otra semana o sin día asignado. Revisá la semana antes de registrar.');
      end if;
      v_count := v_count+1;
      v_ids(v_count) := tramo.id;
      v_desde(v_count) := tramo.registrado_hasta;
    end loop;
    if v_count = 0 then raise_application_error(-20106,'No hay tiempo nuevo para registrar.'); end if;
    v_capacidad := capacidad_restante(p_meta_id);
    lfo_cronometros.registrar('CULTIVO','N');
    for i in 1..v_count loop
      for r in (select r.id, r.hasta-r.desde duracion from lfo_tiempo_registrado r
        where r.tramo_id=v_ids(i) and r.persona=v_persona and r.categoria='CULTIVO' and r.desde>=v_desde(i)
        and not exists (select 1 from lfo_cultivo_tiempo x where x.tiempo_id=r.id)) loop
        v_segundos := extract(day from r.duracion)*86400 + extract(hour from r.duracion)*3600 +
          extract(minute from r.duracion)*60 + extract(second from r.duracion);
        insert into lfo_cultivo_tiempo(tiempo_id,meta_id,segundos_validos)
          values(r.id,p_meta_id,least(v_segundos,v_capacidad));
        v_capacidad := greatest(0,v_capacidad-v_segundos);
        v_vinculados := v_vinculados+1;
      end loop;
    end loop;
    if v_vinculados = 0 then raise_application_error(-20172,'No se pudo asociar el tiempo a la actividad.'); end if;
  end;
  function aviso_minutos(p_meta_id number) return number is
    v_persona varchar2(4) := lfo_persona_actual;
    v_semana date;
    v_minimo number;
    v_objetivo number;
    v_anteriores number;
    v_manual number;
    v_cronometro number;
    v_pendiente number;
    v_invalidos number;
    v_total number;
    v_faltan number;
    v_siguiente number;
  begin
    v_semana := semana_meta(p_meta_id,v_persona);
    select minutos_minimos, veces_por_semana into v_minimo, v_objetivo
      from lfo_metas_cultivo where id=p_meta_id and persona=v_persona;
    select count(*) into v_anteriores from lfo_registros_cultivo r
      where r.meta_id=p_meta_id and r.minutos>=v_minimo
      and not exists (select 1 from lfo_cultivo_manual_nuevo n where n.registro_id=r.id);
    select nvl(sum(n.segundos_validos),0) into v_manual from lfo_registros_cultivo r
      join lfo_cultivo_manual_nuevo n on n.registro_id=r.id where r.meta_id=p_meta_id;
    select nvl(sum(c.segundos_validos),0) into v_cronometro from lfo_cultivo_tiempo c where c.meta_id=p_meta_id;
    select count(case when t.dia_id is null or d.fecha_logica<v_semana or d.fecha_logica>=v_semana+7 then 1 end),
      nvl(sum(extract(day from (coalesce(t.fin,systimestamp)-t.registrado_hasta))*86400 +
        extract(hour from (coalesce(t.fin,systimestamp)-t.registrado_hasta))*3600 +
        extract(minute from (coalesce(t.fin,systimestamp)-t.registrado_hasta))*60 +
        extract(second from (coalesce(t.fin,systimestamp)-t.registrado_hasta))),0)
      into v_invalidos,v_pendiente
      from lfo_reloj_tramos t left join lfo_dias_personales d on d.id=t.dia_id and d.persona=t.persona
      where t.persona=v_persona and t.categoria='CULTIVO' and (t.fin is null or t.registrado_hasta<t.fin);
    if v_invalidos>0 then
      raise_application_error(-20171,'Hay tiempo pendiente de otra semana o sin día asignado. Revisá la semana antes de registrar.');
    end if;
    if v_pendiente<=0 then return 0; end if;
    v_total := v_manual + v_cronometro + v_pendiente;
    v_siguiente := v_anteriores + floor(v_total/(v_minimo*60)) + 1;
    v_faltan := (floor(v_total/(v_minimo*60))+1)*v_minimo*60-v_total;
    if v_siguiente >= 2 and v_siguiente <= v_objetivo and v_faltan > 0 and v_faltan <= 600 then
      return ceil(v_faltan/60);
    end if;
    return 0;
  end;
  procedure operar_reloj(p_accion varchar2, p_categoria varchar2, p_reiniciar varchar2) is
  begin
    if p_accion = 'REGISTRAR' and p_categoria = 'CULTIVO' then
      raise_application_error(-20173, 'Elegí una actividad para registrar el tiempo de Cultivo.');
    end if;
    lfo_cronometros.operar(p_accion,p_categoria,p_reiniciar);
  end;
end lfo_cultivo_nuevo;
/
create or replace view lfo_progreso_cultivo_v2 as
with manuales as (
  select r.meta_id, count(*) cantidad,
         sum(case when n.registro_id is null and r.minutos >= m.minutos_minimos then 1 else 0 end) antiguos,
         sum(case when n.registro_id is not null then n.segundos_validos else 0 end) segundos_nuevos
  from lfo_registros_cultivo r join lfo_metas_cultivo m on m.id=r.meta_id
  left join lfo_cultivo_manual_nuevo n on n.registro_id=r.id
  group by r.meta_id
), tiempos as (
  select c.meta_id, count(*) cantidad,
         sum(c.segundos_validos) segundos
  from lfo_cultivo_tiempo c join lfo_tiempo_registrado r on r.id=c.tiempo_id
  group by c.meta_id
), calculado as (
  select m.id,m.persona,m.semana_inicio,m.nombre,m.minutos_minimos,m.veces_por_semana,
         nvl(a.cantidad,0)+nvl(t.cantidad,0) registros,
         nvl(a.antiguos,0) + least(greatest(m.veces_por_semana-nvl(a.antiguos,0),0),
           floor((nvl(a.segundos_nuevos,0)+nvl(t.segundos,0))/(m.minutos_minimos*60))) cumplimientos
  from lfo_metas_cultivo m left join manuales a on a.meta_id=m.id left join tiempos t on t.meta_id=m.id
)
select id,persona,semana_inicio,nombre,minutos_minimos,veces_por_semana,registros,cumplimientos,
       greatest(0,veces_por_semana-cumplimientos) faltantes,
       least(100,round(100*cumplimientos/veces_por_semana,1)) porcentaje
from calculado;
