-- Sesion APEX temporal. Todas las asignaciones y objetivos de prueba se revierten.
declare
  v_usuario varchar2(100) := 'TEST_' || rawtohex(sys_guid());
  v_sesion number;
  v_semana date := trunc(date '2201-01-01', 'IW');
  v_guardado boolean := false;
  v_num number;
  v_rechazo boolean := false;
begin
  apex_session.create_session(p_app_id=>100, p_page_id=>1, p_username=>v_usuario);
  v_sesion := v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA', to_char(v_semana,'YYYY-MM-DD'), v_usuario);
  savepoint prueba_objetivos;
  v_guardado := true;
  insert into lfo_cuentas_persona(usuario_apex, persona) values(v_usuario, 'BRI');
  lfo_objetivos_horas_api.guardar(40, 12.5, 5, null, v_semana);
  select horas_objetivo into v_num from lfo_progreso_horas_v
    where persona='BRI' and semana_inicio=v_semana and categoria='TRABAJO';
  if v_num != 40 then raise_application_error(-20900, 'Objetivo incorrecto.'); end if;
  select horas_objetivo into v_num from lfo_objetivos_horas
    where persona='BRI' and semana_inicio=v_semana and categoria='ESTUDIO';
  if v_num != 12.5 then raise_application_error(-20901, 'No se conserva la fracción de hora.'); end if;
  select count(*) into v_num from lfo_objetivos_horas where persona='FACU' and semana_inicio=v_semana;
  if v_num != 0 then raise_application_error(-20902, 'Se modificó otra persona.'); end if;
  begin
    lfo_objetivos_horas_api.guardar(99, -1, 5, null, v_semana);
  exception when others then
    if sqlcode = -20160 then v_rechazo := true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20903, 'Se aceptaron horas inválidas.'); end if;
  select horas_objetivo into v_num from lfo_objetivos_horas
    where persona='BRI' and semana_inicio=v_semana and categoria='TRABAJO';
  if v_num != 40 then raise_application_error(-20904, 'Un error alteró los otros objetivos.'); end if;
  v_rechazo := false;
  begin
    lfo_objetivos_horas_api.guardar(99, 1, 5, null, v_semana + 7);
  exception when others then
    if sqlcode = -20162 then v_rechazo := true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20905, 'Se aceptó otra semana.'); end if;
  rollback to prueba_objetivos;
  apex_util.remove_preference('LFO_SEMANA', v_usuario);
  apex_session.delete_session(p_session_id=>v_sesion);
exception when others then
  if v_guardado then rollback to prueba_objetivos; end if;
  apex_util.remove_preference('LFO_SEMANA', v_usuario);
  if v_sesion is not null then apex_session.delete_session(p_session_id=>v_sesion); end if;
  raise;
end;
/
