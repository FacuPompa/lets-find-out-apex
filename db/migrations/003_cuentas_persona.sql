-- Asociacion administrativa entre cuentas APEX y personas existentes.
-- No modifica metas ni crea cuentas. La asignacion se hace por separado.
begin
  execute immediate q'[
    create table lfo_cuentas_persona (
      usuario_apex varchar2(100 char) primary key,
      persona varchar2(4 char) not null,
      constraint lfo_cuenta_usuario_ck check (usuario_apex = upper(trim(usuario_apex))),
      constraint lfo_cuenta_persona_ck check (persona in ('BRI', 'FACU'))
    )
  ]';
exception when others then
  if sqlcode != -955 then raise; end if;
end;
/

create or replace function lfo_persona_actual return varchar2 authid definer as
  v_persona lfo_cuentas_persona.persona%type;
  v_usuario varchar2(100) := upper(trim(v('APP_USER')));
begin
  if v('APP_SESSION') is null or v_usuario is null or v_usuario = 'APEX_PUBLIC_USER' then
    raise_application_error(-20020, 'Se requiere una sesión de la aplicación.');
  end if;
  select persona into v_persona
    from lfo_cuentas_persona where usuario_apex = v_usuario;
  return v_persona;
exception when no_data_found then
  raise_application_error(-20021, 'Esta cuenta todavía no está vinculada a una persona.');
end;
/
