-- Historial inmutable y vista de valores efectivos; los intervalos originales no se modifican.
begin
  execute immediate q'[
    create table lfo_correcciones_tiempo (
      id number generated always as identity primary key,
      tiempo_id number not null references lfo_tiempo_registrado(id),
      usuario_apex varchar2(255 char) not null,
      corregido_en timestamp with time zone default systimestamp not null,
      categoria_antes varchar2(12 char) not null,
      categoria_despues varchar2(12 char) not null,
      segundos_antes number not null,
      segundos_despues number not null,
      meta_antes number references lfo_metas_cultivo(id),
      meta_despues number references lfo_metas_cultivo(id),
      validos_antes number,
      validos_despues number,
      constraint lfo_corr_cat_ant_ck check (categoria_antes in ('TRABAJO','ESTUDIO','OCIO','CULTIVO')),
      constraint lfo_corr_cat_des_ck check (categoria_despues in ('TRABAJO','ESTUDIO','OCIO','CULTIVO')),
      constraint lfo_corr_seg_ck check (segundos_antes > 0 and segundos_despues > 0)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
create or replace view lfo_tiempo_actual_v as
with ultima as (
  select c.*, row_number() over (partition by tiempo_id order by id desc) rn
  from lfo_correcciones_tiempo c
)
select r.id, r.tramo_id, r.persona, t.dia_id, d.fecha_logica, r.desde, r.hasta,
       coalesce(c.categoria_despues,r.categoria) categoria,
       coalesce(c.segundos_despues,
         extract(day from (r.hasta-r.desde))*86400 + extract(hour from (r.hasta-r.desde))*3600 +
         extract(minute from (r.hasta-r.desde))*60 + extract(second from (r.hasta-r.desde))) segundos,
       nvl(c.id,0) version,
       cultivo.meta_id, cultivo.segundos_validos
from lfo_tiempo_registrado r
join lfo_reloj_tramos t on t.id=r.tramo_id and t.persona=r.persona
left join lfo_dias_personales d on d.id=t.dia_id and d.persona=r.persona
left join ultima c on c.tiempo_id=r.id and c.rn=1
left join lfo_cultivo_tiempo cultivo on cultivo.tiempo_id=r.id;
/
create or replace view lfo_resumen_dia_v as
select dia_id,persona,fecha_logica,categoria,sum(segundos) segundos,count(*) intervalos
from lfo_tiempo_actual_v where dia_id is not null
group by dia_id,persona,fecha_logica,categoria;
/
create or replace package lfo_correccion_tiempo authid definer as
  procedure corregir(p_tiempo_id number, p_version number, p_categoria varchar2,
                     p_segundos number, p_meta_id number default null);
end lfo_correccion_tiempo;
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
