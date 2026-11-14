-- Ejecutar en sesión dedicada: crea una sesión APEX de prueba y revierte todos sus datos.
declare
  v_usuario varchar2(100) := 'TEST_' || rawtohex(sys_guid());
  v_persona varchar2(4);
  v_sesion number;
  v_dia number;
  v_count number;
  v_segundos number;
  v_rechazo boolean := false;
  v_guardado boolean := false;
begin
  select persona into v_persona from (
    select persona from (select 'BRI' persona from dual union all select 'FACU' from dual) candidatos
    where not exists (select 1 from lfo_relojes r where r.persona = candidatos.persona)
  ) where rownum = 1;
  apex_session.create_session(p_app_id => 100, p_page_id => 1, p_username => v_usuario);
  v_sesion := v('APP_SESSION');
  savepoint prueba_cierre;
  v_guardado := true;
  insert into lfo_cuentas_persona(usuario_apex, persona) values(v_usuario, v_persona);
  lfo_cronometros.iniciar('TRABAJO');
  select dia_id into v_dia from lfo_reloj_tramos where persona = v_persona and fin is null;
  update lfo_relojes set activo_desde = activo_desde - interval '120' second
    where persona = v_persona and categoria = 'TRABAJO';
  update lfo_reloj_tramos set inicio = inicio - interval '120' second, registrado_hasta = registrado_hasta - interval '120' second
    where persona = v_persona and fin is null;
  lfo_cronometros.registrar('TRABAJO', 'N');
  lfo_cronometros.iniciar('ESTUDIO');
  begin
    lfo_cierre_diario.cerrar(v_dia, null);
  exception when others then
    if sqlcode = -20131 then v_rechazo := true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20940, 'Se cerró sin confirmar el reloj activo.'); end if;
  select count(*) into v_count from lfo_relojes where persona = v_persona and categoria = 'ESTUDIO' and activo_desde is not null;
  if v_count != 1 then raise_application_error(-20941, 'Se pausó sin confirmación.'); end if;
  lfo_cierre_diario.cerrar(v_dia, 'ESTUDIO');
  select count(*) into v_count from lfo_relojes where persona = v_persona and activo_desde is not null;
  if v_count != 0 then raise_application_error(-20942, 'El reloj no se pausó.'); end if;
  select count(*) into v_count from lfo_dias_personales where id = v_dia and cerrado_en is not null;
  if v_count != 1 then raise_application_error(-20943, 'El día no se cerró.'); end if;
  select segundos into v_segundos from lfo_cierre_dia_resumen where dia_id = v_dia and categoria = 'TRABAJO';
  if v_segundos < 120 then raise_application_error(-20944, 'El resumen perdió tiempo registrado.'); end if;
  select count(*) into v_count from lfo_reloj_tramos
    where persona = v_persona and categoria = 'ESTUDIO' and fin is not null and registrado_hasta < fin;
  if v_count != 1 then raise_application_error(-20945, 'El tiempo pendiente no quedó conservado.'); end if;
  v_rechazo := false;
  begin
    lfo_cierre_diario.cerrar(v_dia, null);
  exception when others then
    if sqlcode = -20130 then v_rechazo := true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20946, 'Se cerró dos veces.'); end if;
  rollback to prueba_cierre;
  apex_session.delete_session(p_session_id => v_sesion);
exception when others then
  if v_guardado then rollback to prueba_cierre; end if;
  if v_sesion is not null then apex_session.delete_session(p_session_id => v_sesion); end if;
  raise;
end;
/
