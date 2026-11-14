-- Cronometros e intervalos: migracion aditiva; no modifica datos de Cultivo.
-- No confirma operaciones de negocio; cada llamador decide COMMIT o ROLLBACK.
begin
  execute immediate q'[
    create table lfo_reloj_persona (
      persona varchar2(4 char) primary key,
      constraint lfo_reloj_persona_ck check (persona in ('BRI', 'FACU'))
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
begin
  execute immediate q'[
    create table lfo_relojes (
      persona varchar2(4 char) not null references lfo_reloj_persona(persona),
      categoria varchar2(12 char) not null,
      acumulado_seg number default 0 not null,
      activo_desde timestamp with time zone,
      constraint lfo_relojes_pk primary key (persona, categoria),
      constraint lfo_reloj_categoria_ck check (categoria in ('TRABAJO','ESTUDIO','OCIO','CULTIVO')),
      constraint lfo_reloj_acumulado_ck check (acumulado_seg >= 0)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
begin
  execute immediate q'[
    create unique index lfo_un_reloj_activo_uq on lfo_relojes
    (case when activo_desde is not null then persona end)
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
begin
  execute immediate q'[
    create table lfo_reloj_tramos (
      id number generated always as identity primary key,
      persona varchar2(4 char) not null,
      categoria varchar2(12 char) not null,
      inicio timestamp with time zone not null,
      fin timestamp with time zone,
      registrado_hasta timestamp with time zone not null,
      constraint lfo_tramo_reloj_fk foreign key (persona, categoria)
        references lfo_relojes(persona, categoria),
      constraint lfo_tramo_fechas_ck check (fin is null or fin >= inicio),
      constraint lfo_tramo_registrado_ck check (registrado_hasta >= inicio and (fin is null or registrado_hasta <= fin))
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
begin
  execute immediate q'[
    create unique index lfo_tramo_abierto_uq on lfo_reloj_tramos
    (case when fin is null then persona end)
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
begin
  execute immediate q'[
    create table lfo_tiempo_registrado (
      id number generated always as identity primary key,
      tramo_id number not null references lfo_reloj_tramos(id),
      persona varchar2(4 char) not null,
      categoria varchar2(12 char) not null,
      desde timestamp with time zone not null,
      hasta timestamp with time zone not null,
      creado_en timestamp with time zone default systimestamp not null,
      constraint lfo_tiempo_rango_ck check (hasta > desde)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
create or replace package lfo_cronometros authid definer as
  procedure operar(p_accion in varchar2, p_categoria in varchar2, p_reiniciar in varchar2);
  procedure iniciar(p_categoria in varchar2);
  procedure pausar(p_categoria in varchar2);
  procedure reiniciar(p_categoria in varchar2);
  procedure registrar(p_categoria in varchar2, p_reiniciar in varchar2 default 'N');
end lfo_cronometros;
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
  begin
    if p_reiniciar is null or p_reiniciar not in ('S','N') then
      raise_application_error(-20105, 'Indicá si querés reiniciar el contador.');
    end if;
    preparar(v_persona, p_categoria);
    select activo_desde into v_inicio from lfo_relojes
      where persona = v_persona and categoria = p_categoria;
    v_ahora := systimestamp;
    for tramo in (select id, registrado_hasta, fin from lfo_reloj_tramos
       where persona = v_persona and categoria = p_categoria
       and (fin is null or registrado_hasta < fin) for update) loop
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
