-- El cierre conserva una fotografia del tiempo ya registrado.
-- Pausar el reloj no registra automaticamente su tiempo pendiente.
begin
  execute immediate q'[
    create table lfo_cierre_dia_resumen (
      dia_id number not null references lfo_dias_personales(id),
      categoria varchar2(12 char) not null,
      segundos number default 0 not null,
      constraint lfo_cierre_resumen_pk primary key (dia_id, categoria),
      constraint lfo_cierre_categoria_ck check (categoria in ('TRABAJO','ESTUDIO','OCIO','CULTIVO')),
      constraint lfo_cierre_segundos_ck check (segundos >= 0)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
create or replace package lfo_cierre_diario authid definer as
  procedure cerrar(p_dia_id in number, p_reloj_confirmado in varchar2 default null);
end lfo_cierre_diario;
/
create or replace package body lfo_cierre_diario as
  procedure cerrar(p_dia_id in number, p_reloj_confirmado in varchar2 default null) is
    v_persona lfo_reloj_persona.persona%type := lfo_persona_actual;
    v_dummy lfo_reloj_persona.persona%type;
    v_dia number;
    v_activo lfo_relojes.categoria%type;
  begin
    begin
      select persona into v_dummy from lfo_reloj_persona where persona = v_persona for update;
      select id into v_dia from lfo_dias_personales
        where id = p_dia_id and persona = v_persona and cerrado_en is null for update;
    exception when no_data_found then
      raise_application_error(-20130, 'Este día ya está cerrado o no está disponible para tu cuenta.');
    end;
    begin
      select categoria into v_activo from lfo_relojes
        where persona = v_persona and activo_desde is not null;
    exception when no_data_found then v_activo := null;
    end;
    if nvl(v_activo, '#') != nvl(p_reloj_confirmado, '#') then
      raise_application_error(-20131, 'El cronómetro activo cambió. Revisá el resumen y volvé a confirmar.');
    end if;
    if v_activo is not null then
      lfo_cronometros.pausar(v_activo);
    end if;
    insert into lfo_cierre_dia_resumen(dia_id, categoria, segundos)
      select v_dia, c.categoria, nvl(r.segundos, 0)
      from (select 'TRABAJO' categoria from dual union all
            select 'ESTUDIO' from dual union all
            select 'OCIO' from dual union all
            select 'CULTIVO' from dual) c
      left join lfo_resumen_dia_v r on r.dia_id = v_dia and r.categoria = c.categoria;
    update lfo_dias_personales set cerrado_en = systimestamp where id = v_dia;
  end;
end lfo_cierre_diario;
/
