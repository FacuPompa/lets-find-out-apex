-- Comprueba el rechazo de tiempo pendiente; usa una persona de prueba aislada.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid()); s number; n number;
  w date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date),'IW');
  rechazado boolean:=false; guardado boolean:=false;
begin
  select count(*) into n from lfo_relojes where persona='BRI';
  if n>0 then raise_application_error(-20918,'Se requiere una persona de prueba aislada.'); end if;
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); s:=v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA',to_char(w,'YYYY-MM-DD'),u);
  savepoint prueba_pendientes; guardado:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  lfo_cronometros.iniciar('TRABAJO');
  begin lfo_cierre_semanal.confirmar(w,0,null);
  exception when others then if sqlcode=-20223 then rechazado:=true; else raise; end if; end;
  if not rechazado then raise_application_error(-20919,'Se aceptó cerrar con tiempo pendiente.'); end if;
  rollback to prueba_pendientes; apex_util.remove_preference('LFO_SEMANA',u); apex_session.delete_session(p_session_id=>s);
exception when others then
  if guardado then rollback to prueba_pendientes; end if;
  apex_util.remove_preference('LFO_SEMANA',u); if s is not null then apex_session.delete_session(p_session_id=>s); end if; raise;
end;
/
