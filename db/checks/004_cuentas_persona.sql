-- Usa sesiones APEX temporales, sin cambios en metas ni asignaciones.
-- Requiere al menos una cuenta ya vinculada y acceso a la app 100.
declare
  v_usuario lfo_cuentas_persona.usuario_apex%type;
  v_esperada lfo_cuentas_persona.persona%type;
  v_resultado lfo_cuentas_persona.persona%type;
  v_desconocido varchar2(100) := 'TEST_' || rawtohex(sys_guid());
  v_sesion number;
  v_rechazada boolean := false;
begin
  select usuario_apex, persona into v_usuario, v_esperada
    from lfo_cuentas_persona where rownum = 1;
  apex_session.create_session(p_app_id => 100, p_page_id => 3, p_username => v_usuario);
  v_sesion := v('APP_SESSION');
  v_resultado := lfo_persona_actual;
  if v_resultado != v_esperada then
    raise_application_error(-20990, 'La cuenta no corresponde a la persona esperada.');
  end if;
  apex_session.delete_session(p_session_id => v_sesion);
  v_sesion := null;

  apex_session.create_session(p_app_id => 100, p_page_id => 3, p_username => v_desconocido);
  v_sesion := v('APP_SESSION');
  begin
    v_resultado := lfo_persona_actual;
  exception when others then
    if sqlcode = -20021 then v_rechazada := true; else raise; end if;
  end;
  if not v_rechazada then
    raise_application_error(-20991, 'Una cuenta sin vincular obtuvo acceso.');
  end if;
  apex_session.delete_session(p_session_id => v_sesion);
exception when others then
  if v_sesion is not null then
    apex_session.delete_session(p_session_id => v_sesion);
  end if;
  raise;
end;
/
