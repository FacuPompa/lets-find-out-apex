-- Requiere una sesión dedicada y que BRI no tenga cronómetros; revierte los datos de prueba.
declare
  v_usuario varchar2(100) := 'TEST_' || rawtohex(sys_guid());
  v_sesion number;
  v_cantidad number;
  v_guardados number;
  v_segundos number;
  v_activo timestamp with time zone;
  v_rollback boolean := false;
  v_rechazo boolean := false;
begin
  select count(*) into v_cantidad from lfo_relojes where persona='BRI';
  if v_cantidad > 0 then raise_application_error(-20880,'La persona de prueba debe estar aislada.'); end if;
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>v_usuario);
  v_sesion:=v('APP_SESSION');
  savepoint prueba_reinicio;
  v_rollback:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(v_usuario,'BRI');
  lfo_cronometros.iniciar('TRABAJO');
  update lfo_relojes set activo_desde=activo_desde-interval '60' second where persona='BRI' and categoria='TRABAJO';
  update lfo_reloj_tramos set inicio=inicio-interval '60' second, registrado_hasta=registrado_hasta-interval '60' second where persona='BRI' and categoria='TRABAJO';
  lfo_cronometros.registrar('TRABAJO','N');
  select count(*) into v_guardados from lfo_tiempo_registrado where persona='BRI' and categoria='TRABAJO';
  lfo_cronometros.iniciar('TRABAJO');
  update lfo_relojes set activo_desde=activo_desde-interval '30' second where persona='BRI' and categoria='TRABAJO';
  update lfo_reloj_tramos set inicio=inicio-interval '30' second, registrado_hasta=registrado_hasta-interval '30' second where persona='BRI' and categoria='TRABAJO' and fin is null;
  lfo_reiniciar_reloj('TRABAJO');
  select acumulado_seg, activo_desde into v_segundos, v_activo from lfo_relojes where persona='BRI' and categoria='TRABAJO';
  if v_segundos != 0 or v_activo is not null then raise_application_error(-20881,'El reloj no quedó en cero y pausado.'); end if;
  select count(*) into v_cantidad from lfo_tiempo_registrado where persona='BRI' and categoria='TRABAJO';
  if v_cantidad != v_guardados or v_guardados=0 then raise_application_error(-20882,'Se alteró el tiempo registrado.'); end if;
  select count(*) into v_cantidad from lfo_reloj_descartes d join lfo_reloj_tramos t on t.id=d.tramo_id where t.persona='BRI' and t.categoria='TRABAJO';
  if v_cantidad != 1 then raise_application_error(-20883,'No se conservó la evidencia del descarte.'); end if;
  begin lfo_cronometros.registrar('TRABAJO','N'); exception when others then if sqlcode=-20106 then v_rechazo:=true; else raise; end if; end;
  if not v_rechazo then raise_application_error(-20884,'Se volvió a cargar tiempo descartado.'); end if;
  lfo_reiniciar_reloj('TRABAJO');
  rollback to prueba_reinicio;
  apex_session.delete_session(p_session_id=>v_sesion);
exception when others then
  if v_rollback then rollback to prueba_reinicio; end if;
  if v_sesion is not null then apex_session.delete_session(p_session_id=>v_sesion); end if;
  raise;
end;
/
