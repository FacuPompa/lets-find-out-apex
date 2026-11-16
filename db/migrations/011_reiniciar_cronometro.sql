-- Registra el tiempo pendiente descartado sin modificar las cargas ya guardadas.
begin
  execute immediate q'[
    create table lfo_reloj_descartes (
      id number generated always as identity primary key,
      tramo_id number not null references lfo_reloj_tramos(id),
      desde timestamp with time zone not null,
      hasta timestamp with time zone not null,
      creado_en timestamp with time zone default systimestamp not null,
      constraint lfo_reloj_descarte_fechas_ck check (hasta > desde)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
create or replace procedure lfo_reiniciar_reloj(p_categoria varchar2) authid definer is
  v_persona varchar2(4) := lfo_persona_actual;
  v_dummy varchar2(4);
  v_activos number;
begin
  if p_categoria is null or p_categoria not in ('TRABAJO','ESTUDIO','OCIO','CULTIVO') then
    raise_application_error(-20100, 'Categoría de cronómetro inválida.');
  end if;
  begin
    insert into lfo_reloj_persona(persona) values(v_persona);
  exception when dup_val_on_index then null;
  end;
  select persona into v_dummy from lfo_reloj_persona where persona=v_persona for update;
  select count(*) into v_activos from lfo_relojes
    where persona=v_persona and categoria=p_categoria and activo_desde is not null;
  if v_activos > 0 then lfo_cronometros.pausar(p_categoria); end if;
  for t in (select id, registrado_hasta, fin from lfo_reloj_tramos
    where persona=v_persona and categoria=p_categoria and fin is not null and registrado_hasta < fin
    for update) loop
    insert into lfo_reloj_descartes(tramo_id,desde,hasta) values(t.id,t.registrado_hasta,t.fin);
    update lfo_reloj_tramos set registrado_hasta=t.fin where id=t.id;
  end loop;
  lfo_cronometros.reiniciar(p_categoria);
end;
/
