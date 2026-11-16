-- Cargas manuales sin intervalos ficticios de cronómetro.
begin
  execute immediate q'[
    create table lfo_tiempo_manual (
      id number generated always as identity primary key,
      persona varchar2(4 char) not null,
      dia_id number not null,
      categoria varchar2(12 char) not null,
      segundos number not null,
      creado_en timestamp with time zone default systimestamp not null,
      constraint lfo_manual_dia_fk foreign key (dia_id,persona) references lfo_dias_personales(id,persona),
      constraint lfo_manual_categoria_ck check (categoria in ('TRABAJO','ESTUDIO','OCIO')),
      constraint lfo_manual_segundos_ck check (segundos>0 and segundos=trunc(segundos))
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
begin
  execute immediate q'[
    create table lfo_correcciones_manual (
      id number generated always as identity primary key,
      manual_id number not null references lfo_tiempo_manual(id),
      usuario_apex varchar2(255 char) not null,
      corregido_en timestamp with time zone default systimestamp not null,
      categoria_antes varchar2(12 char) not null,
      categoria_despues varchar2(12 char) not null,
      segundos_antes number not null,
      segundos_despues number not null,
      constraint lfo_corr_manual_cat_ant_ck check (categoria_antes in ('TRABAJO','ESTUDIO','OCIO')),
      constraint lfo_corr_manual_cat_des_ck check (categoria_despues in ('TRABAJO','ESTUDIO','OCIO')),
      constraint lfo_corr_manual_seg_ck check (segundos_antes>0 and segundos_despues>0)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
create or replace view lfo_tiempo_actual_v as
with ultima as (
  select c.*, row_number() over (partition by tiempo_id order by id desc) rn
  from lfo_correcciones_tiempo c
), ultima_manual as (
  select c.*, row_number() over (partition by manual_id order by id desc) rn
  from lfo_correcciones_manual c
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
left join lfo_cultivo_tiempo cultivo on cultivo.tiempo_id=r.id
union all
select -m.id,cast(null as number),m.persona,m.dia_id,d.fecha_logica,m.creado_en,m.creado_en,
       coalesce(c.categoria_despues,m.categoria),coalesce(c.segundos_despues,m.segundos),
       nvl(c.id,0),cast(null as number),cast(null as number)
from lfo_tiempo_manual m
join lfo_dias_personales d on d.id=m.dia_id and d.persona=m.persona
left join ultima_manual c on c.manual_id=m.id and c.rn=1;
/
create or replace package lfo_tiempo_manual_api authid definer as
  procedure crear(p_categoria varchar2,p_segundos number,p_fecha_esperada date,p_dia_esperado number default null);
  procedure corregir(p_id number,p_version number,p_categoria varchar2,p_segundos number);
end lfo_tiempo_manual_api;
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
