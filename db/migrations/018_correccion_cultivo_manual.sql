-- Correcciones de sesiones manuales de Cultivo, con auditoría de valores previos.
begin
  execute immediate q'[
    create table lfo_correcciones_cultivo_manual (
      id number generated always as identity primary key,
      registro_id number not null references lfo_registros_cultivo(id),
      usuario_apex varchar2(255 char) not null,
      corregido_en timestamp with time zone default systimestamp not null,
      meta_antes number not null references lfo_metas_cultivo(id),
      meta_despues number not null references lfo_metas_cultivo(id),
      minutos_antes number not null,
      minutos_despues number not null,
      validos_antes number,
      validos_despues number,
      constraint lfo_corr_cult_min_ck check (minutos_antes>0 and minutos_despues>0)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
create or replace package lfo_cultivo_manual_edicion authid definer as
  procedure corregir(p_registro_id number,p_version number,p_meta_id number,p_minutos number);
end lfo_cultivo_manual_edicion;
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
  end;
end lfo_cultivo_manual_edicion;
/
