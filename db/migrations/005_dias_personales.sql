-- Estructura aditiva: los intervalos anteriores permanecen sin asignar.
-- No cierra ni reasigna dias existentes. Ejecutar como esquema de la app.
begin
  execute immediate q'[
    create table lfo_dias_personales (
      id number generated always as identity primary key,
      persona varchar2(4 char) not null references lfo_reloj_persona(persona),
      fecha_logica date not null,
      abierto_en timestamp with time zone default systimestamp not null,
      cerrado_en timestamp with time zone,
      constraint lfo_dia_fecha_ck check (fecha_logica = trunc(fecha_logica)),
      constraint lfo_dia_cierre_ck check (cerrado_en is null or cerrado_en >= abierto_en),
      constraint lfo_dia_id_persona_uq unique (id, persona)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
begin
  execute immediate q'[
    create unique index lfo_un_dia_abierto_uq on lfo_dias_personales
      (case when cerrado_en is null then persona end)
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
declare
  v_existe number;
begin
  select count(*) into v_existe from user_tab_columns
    where table_name = 'LFO_RELOJ_TRAMOS' and column_name = 'DIA_ID';
  if v_existe = 0 then
    execute immediate 'alter table lfo_reloj_tramos add (dia_id number)';
  end if;
end;
/
declare
  v_existe number;
begin
  select count(*) into v_existe from user_constraints where constraint_name = 'LFO_TRAMO_DIA_FK';
  if v_existe = 0 then
    execute immediate q'[alter table lfo_reloj_tramos add constraint lfo_tramo_dia_fk
      foreign key (dia_id, persona) references lfo_dias_personales (id, persona)]';
  end if;
end;
/
create or replace package lfo_dias authid definer as
  function abrir_o_actual return number;
end lfo_dias;
/
create or replace package body lfo_dias as
  function abrir_o_actual return number is
    v_persona lfo_reloj_persona.persona%type := lfo_persona_actual;
    v_dummy lfo_reloj_persona.persona%type;
    v_id lfo_dias_personales.id%type;
  begin
    begin
      insert into lfo_reloj_persona(persona) values(v_persona);
    exception when dup_val_on_index then null;
    end;
    select persona into v_dummy from lfo_reloj_persona where persona = v_persona for update;
    begin
      select id into v_id from lfo_dias_personales where persona = v_persona and cerrado_en is null;
    exception when no_data_found then
      insert into lfo_dias_personales(persona, fecha_logica)
        values(v_persona, trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date)))
        returning id into v_id;
    end;
    return v_id;
  end;
end lfo_dias;
/
