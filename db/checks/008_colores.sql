-- Crea y elimina preferencias para identidades temporales aleatorias.
declare
  usuario_a varchar2(80) := 'TEST_A_' || rawtohex(sys_guid());
  usuario_b varchar2(80) := 'TEST_B_' || rawtohex(sys_guid());
  preference_name varchar2(100) := 'LFO_COLOR_TRABAJO';
begin
  apex_util.set_workspace('LETS_FIND_OUT_DEV');
  apex_util.set_preference(preference_name, '#123456', usuario_a);
  apex_util.set_preference(preference_name, '#abcdef', usuario_b);
  if nvl(apex_util.get_preference(preference_name, usuario_a), '?') != '#123456'
     or nvl(apex_util.get_preference(preference_name, usuario_b), '?') != '#abcdef' then
    raise_application_error(-20920, 'Los colores no son independientes por cuenta.');
  end if;
  if regexp_like('#abc123', '^#[0-9A-Fa-f]{6}$', 'c') = false
     or regexp_like('#123456; color:red', '^#[0-9A-Fa-f]{6}$', 'c') then
    raise_application_error(-20921, 'La validación de color no funciona.');
  end if;
  apex_util.remove_preference(preference_name, usuario_a);
  apex_util.remove_preference(preference_name, usuario_b);
  rollback;
exception when others then
  apex_util.remove_preference(preference_name, usuario_a);
  apex_util.remove_preference(preference_name, usuario_b);
  rollback;
  raise;
end;
/
