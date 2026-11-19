-- La regla se aplica en el servidor a las operaciones de corrección.
-- Solo los nuevos registros manuales vinculados se suman a un día personal.
begin
  execute immediate q'[create table lfo_cultivo_manual_dia (
    registro_id number primary key references lfo_registros_cultivo(id),
    dia_id number not null references lfo_dias_personales(id)
  )]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
create or replace view lfo_resumen_dia_v as
select dia_id,persona,fecha_logica,categoria,sum(segundos) segundos,sum(intervalos) intervalos
from (
  select dia_id,persona,fecha_logica,categoria,segundos,1 intervalos
    from lfo_tiempo_actual_v where dia_id is not null
  union all
  select d.id,m.persona,d.fecha_logica,'CULTIVO',r.minutos*60,1
    from lfo_cultivo_manual_dia x
    join lfo_registros_cultivo r on r.id=x.registro_id
    join lfo_metas_cultivo m on m.id=r.meta_id
    join lfo_dias_personales d on d.id=x.dia_id and d.persona=m.persona
)
group by dia_id,persona,fecha_logica,categoria;
/
create or replace package lfo_edicion_fecha authid definer as
  procedure verificar_cierre(p_semana date);
  procedure verificar_semana(p_semana date);
  procedure verificar_dia(p_fecha date, p_abierto boolean default false);
  procedure validar_limite(p_fecha date, p_hoy date, p_abierto boolean default false);
  function dia_anterior(p_fecha date) return number;
  procedure actualizar_resumen(p_dia number);
end lfo_edicion_fecha;
/
create or replace package body lfo_edicion_fecha as
  procedure verificar_cierre(p_semana date) is
    v_persona varchar2(4):=lfo_persona_actual;
    v_cierres number; v_bloqueo varchar2(4);
  begin
    begin insert into lfo_reloj_persona(persona) values(v_persona);
    exception when dup_val_on_index then null; end;
    select persona into v_bloqueo from lfo_reloj_persona where persona=v_persona for update;
    select count(*) into v_cierres from lfo_cierres_semanales
      where persona=v_persona and semana_inicio=p_semana;
    if v_cierres>0 then
      raise_application_error(-20241,'Tu semana ya está cerrada y no se puede modificar.');
    end if;
  end;
  procedure verificar_semana(p_semana date) is
    v_hoy date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date));
  begin
    if p_semana is null or p_semana!=trunc(p_semana,'IW') or p_semana<trunc(v_hoy,'IW') then
      raise_application_error(-20240,'No podés modificar semanas anteriores.');
    end if;
    verificar_cierre(p_semana);
  end;
  procedure validar_limite(p_fecha date, p_hoy date, p_abierto boolean default false) is
  begin
    if p_fecha is null or p_fecha!=trunc(p_fecha) or p_hoy is null or p_hoy!=trunc(p_hoy) then
      raise_application_error(-20242,'La fecha del registro no es válida.');
    end if;
    if not p_abierto and (p_fecha not in (p_hoy,p_hoy-1) or (p_fecha=p_hoy-1 and p_fecha=trunc(p_fecha,'IW')+6)) then
      raise_application_error(-20243,'Podés editar hoy o ayer; el domingo no se corrige el lunes.');
    end if;
  end;
  procedure verificar_dia(p_fecha date, p_abierto boolean default false) is
    v_hoy date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date));
  begin
    validar_limite(p_fecha,v_hoy,p_abierto);
    verificar_semana(trunc(p_fecha,'IW'));
  end;
  function dia_anterior(p_fecha date) return number is
    v_persona varchar2(4):=lfo_persona_actual; v_dia number; v_abiertos number;
    v_ayer date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date))-1;
  begin
    if p_fecha is null or p_fecha!=v_ayer then
      raise_application_error(-20244,'La fecha cambió. Volvé a abrir la carga.');
    end if;
    verificar_dia(v_ayer);
    select count(*) into v_abiertos from lfo_dias_personales
      where persona=v_persona and fecha_logica=v_ayer and cerrado_en is null;
    if v_abiertos>0 then
      select id into v_dia from lfo_dias_personales
        where persona=v_persona and fecha_logica=v_ayer and cerrado_en is null;
      return v_dia;
    end if;
    select max(id) into v_dia from lfo_dias_personales
      where persona=v_persona and fecha_logica=v_ayer and cerrado_en is not null;
    if v_dia is null then
      insert into lfo_dias_personales(persona,fecha_logica,cerrado_en)
        values(v_persona,v_ayer,systimestamp) returning id into v_dia;
      insert into lfo_cierre_dia_resumen(dia_id,categoria,segundos)
        select v_dia,categoria,0 from (
          select 'TRABAJO' categoria from dual union all select 'ESTUDIO' from dual union all
          select 'OCIO' from dual union all select 'CULTIVO' from dual);
    end if;
    return v_dia;
  end;
  procedure actualizar_resumen(p_dia number) is
  begin
    update lfo_cierre_dia_resumen c set segundos=nvl((select sum(r.segundos) from lfo_resumen_dia_v r
      where r.dia_id=c.dia_id and r.categoria=c.categoria),0) where c.dia_id=p_dia;
  end;
end lfo_edicion_fecha;
/

create or replace package body lfo_correccion_tiempo as
  procedure corregir(p_tiempo_id number, p_version number, p_categoria varchar2,
                     p_segundos number, p_meta_id number default null) is
    v_persona varchar2(4) := lfo_persona_actual;
    v_anterior lfo_tiempo_actual_v%rowtype;
    v_actual lfo_tiempo_actual_v%rowtype;
    v_dummy varchar2(4);
    v_minutos number; v_frecuencia number; v_antiguos number; v_manual number; v_otros number;
    v_capacidad number; v_validos number; v_cerrado timestamp with time zone;
  begin
    if p_categoria is null or p_categoria not in ('TRABAJO','ESTUDIO','OCIO','CULTIVO') then
      raise_application_error(-20190,'Elegí una categoría válida.');
    end if;
    if p_segundos is null or p_segundos<=0 or p_segundos!=trunc(p_segundos) then
      raise_application_error(-20191,'Indicá una duración mayor que cero en segundos enteros.');
    end if;
    if p_categoria='CULTIVO' and p_meta_id is null then
      raise_application_error(-20192,'Elegí una actividad de Cultivo.');
    elsif p_categoria!='CULTIVO' and p_meta_id is not null then
      raise_application_error(-20193,'La actividad solo corresponde a Cultivo.');
    end if;
    begin
      select * into v_anterior from lfo_tiempo_actual_v
      where id=p_tiempo_id and persona=v_persona and dia_id is not null;
    exception when no_data_found then
      raise_application_error(-20194,'El registro no está disponible para tu cuenta o no tiene un día asignado.');
    end;
    -- Las operaciones de Cultivo bloquean primero las metas y después la persona.
    for m in (select id from lfo_metas_cultivo where persona=v_persona
              and (id=v_anterior.meta_id or id=p_meta_id) order by id for update) loop null; end loop;
    select persona into v_dummy from lfo_reloj_persona where persona=v_persona for update;
    select * into v_actual from lfo_tiempo_actual_v where id=p_tiempo_id and persona=v_persona;
    select cerrado_en into v_cerrado from lfo_dias_personales where id=v_actual.dia_id and persona=v_persona for update;
    lfo_edicion_fecha.verificar_dia(v_actual.fecha_logica, v_cerrado is null);
    if p_version is null or v_actual.version!=p_version or v_actual.version!=v_anterior.version then
      raise_application_error(-20195,'El registro cambió. Volvé a abrirlo antes de corregirlo.');
    end if;
    if p_categoria='CULTIVO' then
      begin
        select minutos_minimos,veces_por_semana into v_minutos,v_frecuencia
        from lfo_metas_cultivo where id=p_meta_id and persona=v_persona
          and semana_inicio=trunc(v_actual.fecha_logica,'IW');
      exception when no_data_found then
        raise_application_error(-20196,'La actividad debe ser tuya y pertenecer a la semana del registro.');
      end;
      select count(*) into v_antiguos from lfo_registros_cultivo r
        where r.meta_id=p_meta_id and r.minutos>=v_minutos
        and not exists (select 1 from lfo_cultivo_manual_nuevo n where n.registro_id=r.id);
      select nvl(sum(n.segundos_validos),0) into v_manual from lfo_registros_cultivo r
        join lfo_cultivo_manual_nuevo n on n.registro_id=r.id where r.meta_id=p_meta_id;
      select nvl(sum(c.segundos_validos),0) into v_otros from lfo_cultivo_tiempo c
        where c.meta_id=p_meta_id and c.tiempo_id!=p_tiempo_id;
      v_capacidad:=greatest(0,greatest(v_frecuencia-v_antiguos,0)*v_minutos*60-v_manual-v_otros);
      if v_actual.categoria='CULTIVO' and v_actual.meta_id=p_meta_id then
        -- No se recupera el exceso descartado anteriormente por ampliar el objetivo.
        v_validos:=least(v_capacidad, least(nvl(v_actual.segundos_validos,0),p_segundos)
          + greatest(p_segundos-v_actual.segundos,0));
      else
        v_validos:=least(v_capacidad,p_segundos);
      end if;
    else v_validos:=null;
    end if;
    insert into lfo_correcciones_tiempo(tiempo_id,usuario_apex,categoria_antes,categoria_despues,
      segundos_antes,segundos_despues,meta_antes,meta_despues,validos_antes,validos_despues)
      values(p_tiempo_id,v('APP_USER'),v_actual.categoria,p_categoria,v_actual.segundos,p_segundos,
        v_actual.meta_id,p_meta_id,v_actual.segundos_validos,v_validos);
    delete from lfo_cultivo_tiempo where tiempo_id=p_tiempo_id;
    if p_categoria='CULTIVO' then
      insert into lfo_cultivo_tiempo(tiempo_id,meta_id,segundos_validos) values(p_tiempo_id,p_meta_id,v_validos);
    end if;
    select cerrado_en into v_cerrado from lfo_dias_personales where id=v_actual.dia_id and persona=v_persona for update;
    if v_cerrado is not null then
      update lfo_cierre_dia_resumen c set segundos=nvl((
        select sum(r.segundos) from lfo_resumen_dia_v r where r.dia_id=c.dia_id and r.categoria=c.categoria),0)
      where c.dia_id=v_actual.dia_id;
    end if;
  end;
end lfo_correccion_tiempo;
/

create or replace package body lfo_tiempo_manual_api as
  procedure validar(p_categoria varchar2,p_segundos number) is
  begin
    if p_categoria is null or p_categoria not in ('TRABAJO','ESTUDIO','OCIO') then
      raise_application_error(-20201,'Elegí Trabajo, Estudio u Ocio. Para Cultivo usá el registro por actividad.');
    end if;
    if p_segundos is null or p_segundos<=0 or p_segundos!=trunc(p_segundos) then
      raise_application_error(-20202,'Indicá una duración mayor que cero en segundos enteros.');
    end if;
  end;
  procedure crear(p_categoria varchar2,p_segundos number,p_fecha_esperada date,p_dia_esperado number default null) is
    v_persona varchar2(4):=lfo_persona_actual; v_dia number; v_fecha date;
  begin
    savepoint lfo_manual_crear;
    validar(p_categoria,p_segundos);
    v_dia:=lfo_dias.abrir_o_actual;
    select fecha_logica into v_fecha from lfo_dias_personales where id=v_dia and persona=v_persona;
    if p_fecha_esperada is null or p_fecha_esperada!=v_fecha or (p_dia_esperado is not null and p_dia_esperado!=v_dia) then
      raise_application_error(-20205,'Tu día personal cambió. Volvé a abrir la pantalla antes de agregar el tiempo.');
    end if;
    lfo_edicion_fecha.verificar_dia(v_fecha, true);
    insert into lfo_tiempo_manual(persona,dia_id,categoria,segundos) values(v_persona,v_dia,p_categoria,p_segundos);
  exception when others then
    rollback to lfo_manual_crear;
    raise;
  end;
  procedure corregir(p_id number,p_version number,p_categoria varchar2,p_segundos number) is
    v_persona varchar2(4):=lfo_persona_actual; v_dummy varchar2(4);
    v_actual lfo_tiempo_actual_v%rowtype; v_cerrado timestamp with time zone;
  begin
    validar(p_categoria,p_segundos);
    if p_id is null or p_id>=0 then raise_application_error(-20203,'Registro manual inválido.'); end if;
    begin
      select persona into v_dummy from lfo_reloj_persona where persona=v_persona for update;
      select * into v_actual from lfo_tiempo_actual_v where id=p_id and persona=v_persona and dia_id is not null;
    exception when no_data_found then raise_application_error(-20204,'El registro no está disponible para tu cuenta.');
    end;
    select cerrado_en into v_cerrado from lfo_dias_personales where id=v_actual.dia_id and persona=v_persona for update;
    lfo_edicion_fecha.verificar_dia(v_actual.fecha_logica, v_cerrado is null);
    if p_version is null or v_actual.version!=p_version then
      raise_application_error(-20195,'El registro cambió. Volvé a abrirlo antes de corregirlo.');
    end if;
    insert into lfo_correcciones_manual(manual_id,usuario_apex,categoria_antes,categoria_despues,segundos_antes,segundos_despues)
      values(-p_id,v('APP_USER'),v_actual.categoria,p_categoria,v_actual.segundos,p_segundos);
    select cerrado_en into v_cerrado from lfo_dias_personales where id=v_actual.dia_id and persona=v_persona for update;
    if v_cerrado is not null then
      update lfo_cierre_dia_resumen c set segundos=nvl((select sum(r.segundos) from lfo_resumen_dia_v r
        where r.dia_id=c.dia_id and r.categoria=c.categoria),0) where c.dia_id=v_actual.dia_id;
    end if;
  end;
end lfo_tiempo_manual_api;
/

create or replace package body lfo_cultivo_manual_edicion as
  procedure corregir(p_registro_id number,p_version number,p_meta_id number,p_minutos number) is
    v_persona varchar2(4):=lfo_persona_actual;
    v_antes lfo_registros_cultivo%rowtype; v_actual lfo_registros_cultivo%rowtype;
    v_version number; v_minimo number; v_frecuencia number; v_historicos number;
    v_manuales number; v_tiempos number; v_capacidad number; v_validos number;
    v_validos_antes number; v_es_nuevo number;
  begin
    if p_minutos is null or p_minutos<1 or p_minutos!=trunc(p_minutos) then
      raise_application_error(-20012,'Indicá minutos enteros mayores que cero.');
    end if;
    begin
      select r.* into v_antes from lfo_registros_cultivo r join lfo_metas_cultivo m on m.id=r.meta_id
        where r.id=p_registro_id and m.persona=v_persona;
    exception when no_data_found then raise_application_error(-20210,'La sesión no está disponible para tu cuenta.');
    end;
    for m in (select id from lfo_metas_cultivo where persona=v_persona and (id=v_antes.meta_id or id=p_meta_id)
              order by id for update) loop null; end loop;
    select * into v_actual from lfo_registros_cultivo where id=p_registro_id for update;
    lfo_edicion_fecha.verificar_dia(v_actual.dia_logico);
    select nvl(max(id),0) into v_version from lfo_correcciones_cultivo_manual where registro_id=p_registro_id;
    if p_version is null or p_version!=v_version or v_actual.meta_id!=v_antes.meta_id then
      raise_application_error(-20195,'La sesión cambió. Volvé a abrirla antes de corregirla.');
    end if;
    begin
      select minutos_minimos,veces_por_semana into v_minimo,v_frecuencia from lfo_metas_cultivo
      where id=p_meta_id and persona=v_persona and semana_inicio=v_actual.semana_inicio;
    exception when no_data_found then raise_application_error(-20196,'La actividad debe ser tuya y pertenecer a la semana del registro.');
    end;
    select count(*),max(segundos_validos) into v_es_nuevo,v_validos_antes
      from lfo_cultivo_manual_nuevo where registro_id=p_registro_id;
    if v_es_nuevo=1 then
      select count(*) into v_historicos from lfo_registros_cultivo r
        where r.meta_id=p_meta_id and r.minutos>=v_minimo
          and not exists (select 1 from lfo_cultivo_manual_nuevo n where n.registro_id=r.id);
      select nvl(sum(n.segundos_validos),0) into v_manuales from lfo_registros_cultivo r
        join lfo_cultivo_manual_nuevo n on n.registro_id=r.id
        where r.meta_id=p_meta_id and r.id!=p_registro_id;
      select nvl(sum(segundos_validos),0) into v_tiempos from lfo_cultivo_tiempo where meta_id=p_meta_id;
      v_capacidad:=greatest(0,greatest(v_frecuencia-v_historicos,0)*v_minimo*60-v_manuales-v_tiempos);
      if v_actual.meta_id=p_meta_id then
        v_validos:=least(v_capacidad,least(v_validos_antes,p_minutos*60)+greatest((p_minutos-v_actual.minutos)*60,0));
      else v_validos:=least(v_capacidad,p_minutos*60);
      end if;
    else v_validos:=null; end if;
    insert into lfo_correcciones_cultivo_manual(registro_id,usuario_apex,meta_antes,meta_despues,minutos_antes,minutos_despues,validos_antes,validos_despues)
      values(p_registro_id,v('APP_USER'),v_actual.meta_id,p_meta_id,v_actual.minutos,p_minutos,v_validos_antes,v_validos);
    update lfo_registros_cultivo set meta_id=p_meta_id,minutos=p_minutos where id=p_registro_id;
    if v_es_nuevo=1 then update lfo_cultivo_manual_nuevo set segundos_validos=v_validos where registro_id=p_registro_id; end if;
    for d in (select dia_id from lfo_cultivo_manual_dia where registro_id=p_registro_id) loop
      lfo_edicion_fecha.actualizar_resumen(d.dia_id);
    end loop;
  end;
end lfo_cultivo_manual_edicion;
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
    v_validos number; v_dia_id number;
  begin
    if p_meta_id is null or p_dia is null or p_minutos is null then
      raise_application_error(-20010,'Completá la meta, el día y los minutos.');
    end if;
    if p_dia != trunc(p_dia) then raise_application_error(-20011,'Indicá una fecha sin hora.'); end if;
    if p_minutos < 1 or p_minutos != trunc(p_minutos) then
      raise_application_error(-20012,'Indicá minutos enteros mayores que cero.');
    end if;
    v_semana := semana_meta(p_meta_id,v_persona);
    lfo_edicion_fecha.verificar_dia(p_dia);
    if p_dia < v_semana or p_dia >= v_semana+7 then
      raise_application_error(-20014,'El día debe pertenecer a la semana de la meta.');
    end if;
    if p_dia=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date))-1 then
      v_dia_id:=lfo_edicion_fecha.dia_anterior(p_dia);
    end if;
    v_validos := least(p_minutos*60, capacidad_restante(p_meta_id));
    insert into lfo_registros_cultivo(meta_id,semana_inicio,dia_logico,minutos)
      values(p_meta_id,v_semana,p_dia,p_minutos) returning id into v_id;
    insert into lfo_cultivo_manual_nuevo(registro_id,segundos_validos) values(v_id,v_validos);
    if v_dia_id is not null then
      insert into lfo_cultivo_manual_dia(registro_id,dia_id) values(v_id,v_dia_id);
      lfo_edicion_fecha.actualizar_resumen(v_dia_id);
    end if;
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
    lfo_edicion_fecha.verificar_semana(v_semana);
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
    lfo_edicion_fecha.verificar_semana(v_semana);
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
    lfo_edicion_fecha.verificar_semana(v_semana);
    if p_completada is null or p_completada not in ('S','N') then raise_application_error(-20184,'Estado inválido.'); end if;
    update lfo_metas_semanales set completada=p_completada
    where id=p_id and persona=v_persona and semana_inicio=v_semana;
    if sql%rowcount=0 then raise_application_error(-20185,'La meta no existe en tu semana seleccionada.'); end if;
  end;
end lfo_metas_semanales_api;
/

-- Carga omitida en un día cerrado, sin reabrirlo ni alterar el día actual.
create or replace package lfo_carga_dia_anterior authid definer as
  procedure crear(p_categoria varchar2,p_segundos number,p_fecha_esperada date);
end lfo_carga_dia_anterior;
/
create or replace package body lfo_carga_dia_anterior as
  procedure crear(p_categoria varchar2,p_segundos number,p_fecha_esperada date) is
    v_persona varchar2(4):=lfo_persona_actual;
    v_ayer date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date))-1;
    v_dummy varchar2(4); v_dia number; v_abierto number;
  begin
    savepoint lfo_carga_ayer;
    if p_fecha_esperada is null or p_fecha_esperada!=v_ayer then
      raise_application_error(-20244,'La fecha cambió. Volvé a abrir la carga.');
    end if;
    if p_categoria is null or p_categoria not in ('TRABAJO','ESTUDIO','OCIO') then
      raise_application_error(-20201,'Elegí Trabajo, Estudio u Ocio. Para Cultivo usá el registro por actividad.');
    end if;
    if p_segundos is null or p_segundos<=0 or p_segundos!=trunc(p_segundos) then
      raise_application_error(-20202,'Indicá una duración mayor que cero en segundos enteros.');
    end if;
    begin insert into lfo_reloj_persona(persona) values(v_persona);
    exception when dup_val_on_index then null; end;
    select persona into v_dummy from lfo_reloj_persona where persona=v_persona for update;
    lfo_edicion_fecha.verificar_dia(v_ayer);
    select count(*) into v_abierto from lfo_dias_personales
      where persona=v_persona and fecha_logica=v_ayer and cerrado_en is null;
    if v_abierto>0 then
      raise_application_error(-20245,'Ayer sigue siendo tu día abierto. Cargá el tiempo en el día actual.');
    end if;
    select max(id) into v_dia from lfo_dias_personales
      where persona=v_persona and fecha_logica=v_ayer and cerrado_en is not null;
    if v_dia is null then
      insert into lfo_dias_personales(persona,fecha_logica,cerrado_en)
        values(v_persona,v_ayer,systimestamp) returning id into v_dia;
      insert into lfo_cierre_dia_resumen(dia_id,categoria,segundos)
        select v_dia,categoria,0 from (
          select 'TRABAJO' categoria from dual union all select 'ESTUDIO' from dual union all
          select 'OCIO' from dual union all select 'CULTIVO' from dual);
    end if;
    insert into lfo_tiempo_manual(persona,dia_id,categoria,segundos)
      values(v_persona,v_dia,p_categoria,p_segundos);
    update lfo_cierre_dia_resumen c set segundos=nvl((select sum(r.segundos) from lfo_resumen_dia_v r
      where r.dia_id=c.dia_id and r.categoria=c.categoria),0) where c.dia_id=v_dia;
  exception when others then rollback to lfo_carga_ayer; raise;
  end;
end lfo_carga_dia_anterior;
/

create or replace package body lfo_objetivos_horas_api as
  procedure guardar(p_trabajo number, p_estudio number, p_ocio number, p_cultivo number, p_semana_esperada date) is
    v_persona varchar2(4) := lfo_persona_actual;
    v_semana date := to_date(nvl(apex_util.get_preference('LFO_SEMANA', v('APP_USER')),
      to_char(trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date), 'IW'), 'YYYY-MM-DD')), 'FXYYYY-MM-DD');
    procedure poner(p_categoria varchar2, p_horas number) is
    begin
      if p_horas is not null and p_horas <= 0 then
        raise_application_error(-20160, 'Las horas deben ser mayores que cero; dejá vacío si no tenés objetivo.');
      end if;
      merge into lfo_objetivos_horas o
      using (select v_persona persona, v_semana semana_inicio, p_categoria categoria, p_horas horas from dual) n
      on (o.persona = n.persona and o.semana_inicio = n.semana_inicio and o.categoria = n.categoria)
      when matched then update set o.horas_objetivo = n.horas
      when not matched then insert (persona, semana_inicio, categoria, horas_objetivo)
        values (n.persona, n.semana_inicio, n.categoria, n.horas);
    end;
  begin
    if v_semana != trunc(v_semana, 'IW') then raise_application_error(-20161, 'La semana seleccionada no es válida.'); end if;
    if p_semana_esperada is null or p_semana_esperada != v_semana then
      raise_application_error(-20162, 'Cambió la semana seleccionada. Volvé a abrir los objetivos y revisalos.');
    end if;
    if (p_trabajo is not null and p_trabajo <= 0) or (p_estudio is not null and p_estudio <= 0)
       or (p_ocio is not null and p_ocio <= 0) or (p_cultivo is not null and p_cultivo <= 0) then
      raise_application_error(-20160, 'Las horas deben ser mayores que cero; dejá vacío si no tenés objetivo.');
    end if;
    lfo_edicion_fecha.verificar_semana(v_semana);
    poner('TRABAJO', p_trabajo);
    poner('ESTUDIO', p_estudio);
    poner('OCIO', p_ocio);
    poner('CULTIVO', p_cultivo);
  end;
end lfo_objetivos_horas_api;
/

create or replace package body lfo_cronometros as
  function segundos(p_inicio timestamp with time zone, p_fin timestamp with time zone) return number is
    v_delta interval day(9) to second(6);
  begin
    v_delta := p_fin - p_inicio;
    return extract(day from v_delta)*86400 + extract(hour from v_delta)*3600
      + extract(minute from v_delta)*60 + extract(second from v_delta);
  end;

  procedure preparar(p_persona varchar2, p_categoria varchar2) is
    v_dummy varchar2(4);
  begin
    if p_categoria is null or p_categoria not in ('TRABAJO','ESTUDIO','OCIO','CULTIVO') then
      raise_application_error(-20100, 'Categoría de cronómetro inválida.');
    end if;
    begin
      insert into lfo_reloj_persona(persona) values(p_persona);
    exception when dup_val_on_index then null;
    end;
    select persona into v_dummy from lfo_reloj_persona where persona = p_persona for update;
    begin
      insert into lfo_relojes(persona, categoria) values(p_persona, p_categoria);
    exception when dup_val_on_index then null;
    end;
  end;

  procedure iniciar(p_categoria in varchar2) is
    v_persona varchar2(4) := lfo_persona_actual;
    v_otros number;
    v_inicio timestamp with time zone;
    v_ahora timestamp with time zone;
  begin
    preparar(v_persona, p_categoria);
    select activo_desde into v_inicio from lfo_relojes
      where persona = v_persona and categoria = p_categoria;
    if v_inicio is not null then
      raise_application_error(-20101, 'Este cronómetro ya está en marcha.');
    end if;
    select count(*) into v_otros from lfo_relojes
      where persona = v_persona and activo_desde is not null;
    if v_otros > 0 then
      raise_application_error(-20102, 'Pausá el otro cronómetro antes de iniciar este.');
    end if;
    v_ahora := systimestamp;
    update lfo_relojes set activo_desde = v_ahora
      where persona = v_persona and categoria = p_categoria;
    insert into lfo_reloj_tramos(persona,categoria,inicio,registrado_hasta)
      values(v_persona,p_categoria,v_ahora,v_ahora);
  end;

  procedure pausar(p_categoria in varchar2) is
    v_persona varchar2(4) := lfo_persona_actual;
    v_inicio timestamp with time zone;
    v_ahora timestamp with time zone;
    v_segundos number;
  begin
    preparar(v_persona, p_categoria);
    select activo_desde into v_inicio from lfo_relojes
      where persona = v_persona and categoria = p_categoria;
    if v_inicio is null then
      raise_application_error(-20103, 'Este cronómetro ya está pausado.');
    end if;
    v_ahora := systimestamp;
    v_segundos := segundos(v_inicio, v_ahora);
    update lfo_relojes set acumulado_seg = acumulado_seg + v_segundos, activo_desde = null
      where persona = v_persona and categoria = p_categoria;
    update lfo_reloj_tramos set fin = v_ahora
      where persona = v_persona and categoria = p_categoria and fin is null;
    if sql%rowcount != 1 then
      raise_application_error(-20104, 'El estado del cronómetro no coincide con sus intervalos.');
    end if;
  end;

  procedure registrar(p_categoria in varchar2, p_reiniciar in varchar2 default 'N') is
    v_persona varchar2(4) := lfo_persona_actual;
    v_ahora timestamp with time zone;
    v_hasta timestamp with time zone;
    v_inicio timestamp with time zone;
    v_segundos number;
    v_cargas number := 0;
    v_fecha_dia date;
  begin
    if p_reiniciar is null or p_reiniciar not in ('S','N') then
      raise_application_error(-20105, 'Indicá si querés reiniciar el contador.');
    end if;
    preparar(v_persona, p_categoria);
    select activo_desde into v_inicio from lfo_relojes
      where persona = v_persona and categoria = p_categoria;
    v_ahora := systimestamp;
    for tramo in (select id, registrado_hasta, fin, dia_id from lfo_reloj_tramos
       where persona = v_persona and categoria = p_categoria
       and (fin is null or registrado_hasta < fin) for update) loop
      if tramo.dia_id is not null then
        select fecha_logica into v_fecha_dia from lfo_dias_personales
          where id=tramo.dia_id and persona=v_persona;
        lfo_edicion_fecha.verificar_cierre(trunc(v_fecha_dia,'IW'));
      end if;
      v_hasta := coalesce(tramo.fin, v_ahora);
      if v_hasta > tramo.registrado_hasta then
        insert into lfo_tiempo_registrado(tramo_id, persona, categoria, desde, hasta)
          values(tramo.id, v_persona, p_categoria, tramo.registrado_hasta, v_hasta);
        update lfo_reloj_tramos set registrado_hasta = v_hasta where id = tramo.id;
        v_cargas := v_cargas + 1;
      end if;
    end loop;
    if v_cargas = 0 then
      raise_application_error(-20106, 'No hay tiempo nuevo para registrar.');
    end if;
    if v_inicio is not null then
      v_segundos := segundos(v_inicio, v_ahora);
      update lfo_reloj_tramos set fin = v_ahora
        where persona = v_persona and categoria = p_categoria and fin is null;
      if sql%rowcount != 1 then
        raise_application_error(-20104, 'El estado del cronómetro no coincide con sus intervalos.');
      end if;
      update lfo_relojes set acumulado_seg = acumulado_seg + v_segundos, activo_desde = null
        where persona = v_persona and categoria = p_categoria;
    end if;
    if p_reiniciar = 'S' then
      update lfo_relojes set acumulado_seg = 0
        where persona = v_persona and categoria = p_categoria;
    end if;
  end;
  procedure reiniciar(p_categoria in varchar2) is
    v_persona varchar2(4) := lfo_persona_actual;
    v_inicio timestamp with time zone;
  begin
    preparar(v_persona, p_categoria);
    select activo_desde into v_inicio from lfo_relojes
      where persona = v_persona and categoria = p_categoria;
    update lfo_relojes set acumulado_seg = 0,
      activo_desde = case when v_inicio is not null then systimestamp else null end
      where persona = v_persona and categoria = p_categoria;
  end;

  procedure operar(p_accion in varchar2, p_categoria in varchar2, p_reiniciar in varchar2) is
  begin
    case p_accion
      when 'INICIAR' then iniciar(p_categoria);
      when 'PAUSAR' then pausar(p_categoria);
      when 'REGISTRAR' then registrar(p_categoria, 'N');
      when 'REINICIAR' then reiniciar(p_categoria);
      else raise_application_error(-20110, 'Acción no válida.');
    end case;
  end;
end lfo_cronometros;
/
