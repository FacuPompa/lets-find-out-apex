-- Verifica el proceso de página instalado con una sesión y datos de prueba.
-- Ejecutar en sesión SQL dedicada; crea preferencias temporales y revierte objetivos.
declare
  v_usuario varchar2(100) := 'TEST_' || rawtohex(sys_guid());
  v_sesion number;
  v_semana date := trunc(date '2201-01-01','IW');
  v_source clob;
  v_resultado number;
  v_guardado boolean := false;
begin
  apex_session.create_session(p_app_id=>100, p_page_id=>7, p_username=>v_usuario);
  v_sesion := v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA',to_char(v_semana,'YYYY-MM-DD'),v_usuario);
  savepoint prueba_pagina;
  v_guardado := true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(v_usuario,'BRI');
  apex_session_state.set_value('P7_TRABAJO','40',false);
  apex_session_state.set_value('P7_ESTUDIO','1,5',false);
  apex_session_state.set_value('P7_OCIO',cast(null as varchar2),false);
  apex_session_state.set_value('P7_CULTIVO',cast(null as varchar2),false);
  select process_source into v_source from apex_application_page_proc
    where application_id=100 and page_id=7 and process_name='Guardar objetivos';
  execute immediate 'begin ' || v_source || ' end;' using in to_char(v_semana,'YYYY-MM-DD');
  select horas_objetivo into v_resultado from lfo_objetivos_horas
    where persona='BRI' and semana_inicio=v_semana and categoria='ESTUDIO';
  if v_resultado != 1.5 then raise_application_error(-20870,'No se interpretó correctamente la fracción de hora.'); end if;
  rollback to prueba_pagina;
  apex_util.remove_preference('LFO_SEMANA',v_usuario);
  apex_session.delete_session(p_session_id=>v_sesion);
exception when others then
  if v_guardado then rollback to prueba_pagina; end if;
  apex_util.remove_preference('LFO_SEMANA',v_usuario);
  if v_sesion is not null then apex_session.delete_session(p_session_id=>v_sesion); end if;
  raise;
end;
/
