-- Ejecutar en sesion SQL dedicada. Se selecciona una persona sin cronometros existentes.
-- Requiere las migraciones 004, 005, 006 y 007. Usa una sesion APEX temporal y revierte las pruebas.
declare
  v_usuario lfo_cuentas_persona.usuario_apex%type := 'TEST_' || rawtohex(sys_guid());
  v_persona lfo_cuentas_persona.persona%type;
  v_sesion number;
  v_count number;
  v_segundos number;
  v_dia number;
  v_dia_siguiente number;
  v_rechazo boolean := false;
  v_guardado boolean := false;
begin
  select persona into v_persona from (
    select persona from (select 'BRI' persona from dual union all select 'FACU' from dual) candidatos
    where not exists (select 1 from lfo_relojes r where r.persona = candidatos.persona)
  ) where rownum = 1;
  apex_session.create_session(p_app_id => 100, p_page_id => 1, p_username => v_usuario);
  v_sesion := v('APP_SESSION');
  savepoint prueba_relojes;
  v_guardado := true;
  insert into lfo_cuentas_persona(usuario_apex, persona) values (v_usuario, v_persona);
  begin
    lfo_cronometros.operar('INVALIDA', 'TRABAJO', 'N');
  exception when others then
    if sqlcode = -20110 then v_rechazo := true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20977, 'Se aceptó una acción inválida.'); end if;
  v_rechazo := false;
  begin
    lfo_cronometros.iniciar('INVALIDA');
  exception when others then
    if sqlcode = -20100 then v_rechazo := true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20978, 'Se aceptó una categoría inválida.'); end if;
  v_rechazo := false;
  lfo_cronometros.iniciar('TRABAJO');
  select dia_id into v_dia from lfo_reloj_tramos where persona = v_persona and categoria = 'TRABAJO' and fin is null;
  if v_dia is null then raise_application_error(-20981, 'El intervalo no pertenece a un día.'); end if;
  update lfo_dias_personales set fecha_logica = fecha_logica - 1 where id = v_dia;
  begin
    lfo_cronometros.iniciar('ESTUDIO');
  exception when others then
    if sqlcode = -20102 then v_rechazo := true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20971, 'Se permitieron dos relojes activos.'); end if;
  update lfo_relojes set activo_desde = activo_desde - interval '120' second
    where persona = v_persona and categoria = 'TRABAJO';
  update lfo_reloj_tramos set inicio = inicio - interval '120' second,
    registrado_hasta = registrado_hasta - interval '120' second
    where persona = v_persona and categoria = 'TRABAJO';
  lfo_cronometros.registrar('TRABAJO', 'N');
  select count(*) into v_count from lfo_tiempo_registrado where persona = v_persona;
  if v_count != 1 then raise_application_error(-20972, 'No se registró el primer intervalo.'); end if;
  select count(*) into v_count from lfo_relojes
    where persona = v_persona and categoria = 'TRABAJO' and activo_desde is not null;
  if v_count != 0 then raise_application_error(-20979, 'El cronómetro no quedó pausado al registrar.'); end if;
  select acumulado_seg into v_segundos from lfo_relojes where persona = v_persona and categoria = 'TRABAJO';
  if v_segundos < 120 then raise_application_error(-20980, 'Se perdió el tiempo mostrado al conservar el contador.'); end if;
  lfo_cronometros.iniciar('TRABAJO');
  select dia_id into v_dia_siguiente from lfo_reloj_tramos where persona = v_persona and categoria = 'TRABAJO' and fin is null;
  if v_dia_siguiente != v_dia then raise_application_error(-20982, 'Se cambió el día sin cerrarlo.'); end if;
  lfo_cronometros.pausar('TRABAJO');
  lfo_cronometros.registrar('TRABAJO', 'S');
  select count(*) into v_count from lfo_tiempo_registrado where persona = v_persona;
  if v_count != 2 then raise_application_error(-20973, 'La segunda carga no es incremental.'); end if;
  select segundos into v_segundos from lfo_resumen_dia_v where dia_id = v_dia and categoria = 'TRABAJO';
  if v_segundos < 120 then raise_application_error(-20983, 'El resumen no incluye el tiempo registrado.'); end if;
  select acumulado_seg into v_segundos from lfo_relojes where persona = v_persona and categoria = 'TRABAJO';
  if v_segundos != 0 then raise_application_error(-20974, 'No se reinició el reloj pausado.'); end if;
  v_rechazo := false;
  begin
    lfo_cronometros.registrar('TRABAJO', 'N');
  exception when others then
    if sqlcode = -20106 then v_rechazo := true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20975, 'Se permitió registrar dos veces el mismo tiempo.'); end if;
  select count(*) into v_count from (
    select desde, lag(hasta) over (order by desde) anterior
    from lfo_tiempo_registrado where persona = v_persona and categoria = 'TRABAJO'
  ) where anterior is not null and desde < anterior;
  if v_count != 0 then raise_application_error(-20976, 'Se superpusieron intervalos cargados.'); end if;
  rollback to prueba_relojes;
  apex_session.delete_session(p_session_id => v_sesion);
exception when others then
  if v_guardado then rollback to prueba_relojes; end if;
  if v_sesion is not null then apex_session.delete_session(p_session_id => v_sesion); end if;
  raise;
end;
/
