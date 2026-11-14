-- Ejecutar en una sesión de desarrollo dedicada, después de conectar al esquema.
-- Se crean preferencias solo para identificadores aleatorios; se eliminan al terminar.
declare
  usuario_a varchar2(80) := 'TEST_A_' || rawtohex(sys_guid());
  usuario_b varchar2(80) := 'TEST_B_' || rawtohex(sys_guid());
begin
  apex_util.set_workspace('LETS_FIND_OUT_DEV');
  apex_util.set_preference('LFO_SEMANA', '2026-11-09', usuario_a);
  apex_util.set_preference('LFO_SEMANA', '2026-11-16', usuario_b);
  if nvl(apex_util.get_preference('LFO_SEMANA', usuario_a), '?') != '2026-11-09'
     or nvl(apex_util.get_preference('LFO_SEMANA', usuario_b), '?') != '2026-11-16' then
    raise_application_error(-20970, 'Las preferencias no están aisladas.');
  end if;
  apex_util.remove_preference('LFO_SEMANA', usuario_a);
  apex_util.remove_preference('LFO_SEMANA', usuario_b);
  rollback;
exception when others then
  rollback;
  raise;
end;
/
