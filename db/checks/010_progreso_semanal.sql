-- Usa cuenta y datos temporales; requiere persona BRI sin cronómetros existentes.
declare
  v_usuario varchar2(100) := 'TEST_' || rawtohex(sys_guid());
  v_sesion number;
  v_guardado boolean := false;
  v_semana date := trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date), 'IW');
  v_objetivo number;
  v_segundos number;
  v_count number;
begin
  select count(*) into v_count from lfo_relojes where persona='BRI';
  if v_count != 0 then raise_application_error(-20890, 'Se requiere persona de prueba aislada.'); end if;
  apex_session.create_session(p_app_id=>100, p_page_id=>1, p_username=>v_usuario);
  v_sesion := v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA', to_char(v_semana,'YYYY-MM-DD'), v_usuario);
  savepoint prueba_progreso;
  v_guardado := true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(v_usuario,'BRI');
  lfo_objetivos_horas_api.guardar(2, null, 5, null, v_semana);
  lfo_cronometros.iniciar('TRABAJO');
  update lfo_relojes set activo_desde = activo_desde - interval '120' second where persona='BRI' and categoria='TRABAJO';
  update lfo_reloj_tramos set inicio = inicio - interval '120' second,
    registrado_hasta = registrado_hasta - interval '120' second where persona='BRI' and categoria='TRABAJO' and fin is null;
  lfo_cronometros.registrar('TRABAJO','N');
  select horas_objetivo, segundos into v_objetivo,v_segundos from lfo_progreso_horas_v
    where persona='BRI' and semana_inicio=v_semana and categoria='TRABAJO';
  if v_objetivo != 2 or v_segundos < 120 then raise_application_error(-20891, 'El progreso no coincide con el tiempo y objetivo.'); end if;
  select count(*) into v_count from lfo_progreso_horas_v
    where persona='FACU' and semana_inicio=v_semana and categoria='TRABAJO' and horas_objetivo=2;
  if v_count != 0 then raise_application_error(-20892, 'El objetivo se asignó a otra persona.'); end if;
  rollback to prueba_progreso;
  apex_util.remove_preference('LFO_SEMANA',v_usuario);
  apex_session.delete_session(p_session_id=>v_sesion);
exception when others then
  if v_guardado then rollback to prueba_progreso; end if;
  apex_util.remove_preference('LFO_SEMANA',v_usuario);
  if v_sesion is not null then apex_session.delete_session(p_session_id=>v_sesion); end if;
  raise;
end;
/
