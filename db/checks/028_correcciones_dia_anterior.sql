-- Ejecución dedicada: datos de prueba dentro de una transacción revertida.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid()); sesion number;
  hoy date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date));
  ayer date:=hoy-1; semana date:=trunc(hoy,'IW');
  n number; antes number; despues number; dia number; id_manual number; rechazada boolean;
  savepoint_creado boolean:=false;
begin
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); sesion:=v('APP_SESSION');
  savepoint prueba_correccion_ayer; savepoint_creado:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  select count(*) into n from lfo_cierres_semanales where persona='BRI' and semana_inicio=semana;
  if n>0 then raise_application_error(-20950,'La persona de prueba tiene un cierre de la semana actual.'); end if;
  select count(*) into n from lfo_dias_personales where persona='BRI' and fecha_logica=ayer and cerrado_en is null;
  if n>0 then raise_application_error(-20951,'El día anterior sigue abierto: elegir otra ventana de prueba.'); end if;
  lfo_edicion_fecha.validar_limite(date '2026-11-16',date '2026-11-17');
  rechazada:=false;
  begin lfo_edicion_fecha.validar_limite(date '2026-11-15',date '2026-11-16');
  exception when others then if sqlcode=-20243 then rechazada:=true; else raise; end if; end;
  if not rechazada then raise_application_error(-20963,'Se permitió corregir el domingo en lunes.'); end if;
  rechazada:=false;
  begin lfo_edicion_fecha.verificar_dia(hoy-2);
  exception when others then if sqlcode=-20243 then rechazada:=true; else raise; end if; end;
  if not rechazada then raise_application_error(-20952,'Se permitió editar una fecha demasiado antigua.'); end if;
  if ayer=trunc(ayer,'IW')+6 then
    rechazada:=false;
    begin lfo_carga_dia_anterior.crear('TRABAJO',7,ayer);
    exception when others then if sqlcode=-20243 then rechazada:=true; else raise; end if; end;
    if not rechazada then raise_application_error(-20953,'Se permitió corregir el domingo en lunes.'); end if;
  else
    select max(id) into dia from lfo_dias_personales where persona='BRI' and fecha_logica=ayer and cerrado_en is not null;
    select nvl(sum(segundos),0) into antes from lfo_cierre_dia_resumen where dia_id=dia and categoria='TRABAJO';
    lfo_carga_dia_anterior.crear('TRABAJO',7,ayer);
    select max(id) into dia from lfo_dias_personales where persona='BRI' and fecha_logica=ayer and cerrado_en is not null;
    select segundos into despues from lfo_cierre_dia_resumen where dia_id=dia and categoria='TRABAJO';
    if despues!=antes+7 then raise_application_error(-20954,'El resumen cerrado no refleja el tiempo agregado.'); end if;
    select max(id) into id_manual from lfo_tiempo_manual where persona='BRI' and dia_id=dia;
    lfo_tiempo_manual_api.corregir(-id_manual,0,'TRABAJO',11);
    select segundos into despues from lfo_cierre_dia_resumen where dia_id=dia and categoria='TRABAJO';
    if despues!=antes+11 then raise_application_error(-20967,'La corrección no actualizó el resumen cerrado.'); end if;
    select count(*) into n from lfo_dias_personales where id=dia and cerrado_en is not null;
    if n!=1 then raise_application_error(-20955,'El día dejó de estar cerrado.'); end if;
  end if;
  insert into lfo_cierres_semanales(persona,semana_inicio,usuario_apex,puntos_trabajo,puntos_estudio,
    puntos_constancia,puntos_ocio,puntos_cultivo,puntos_metas,puntos_total)
    values('BRI',semana,u,0,0,0,0,0,0,0);
  rechazada:=false;
  begin lfo_edicion_fecha.verificar_semana(semana);
  exception when others then if sqlcode=-20241 then rechazada:=true; else raise; end if; end;
  if not rechazada then raise_application_error(-20956,'Se permitió modificar una semana cerrada.'); end if;
  rollback to prueba_correccion_ayer; apex_session.delete_session(p_session_id=>sesion);
exception when others then
  if savepoint_creado then rollback to prueba_correccion_ayer; end if;
  if sesion is not null then apex_session.delete_session(p_session_id=>sesion); end if;
  raise;
end;
/
-- El cultivo de ayer suma al resumen diario y la meta semanal respeta el cierre.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid()); otro varchar2(100):='TEST_'||rawtohex(sys_guid()); sesion number;
  hoy date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date));
  ayer date:=hoy-1; semana date:=trunc(hoy,'IW');
  n number; meta number; registro number; dia number; antes number; despues number;
  rechazada boolean:=false; guardado boolean:=false;
begin
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); sesion:=v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA',to_char(semana,'YYYY-MM-DD'),u);
  savepoint prueba_cultivo_ayer; guardado:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  insert into lfo_cuentas_persona(usuario_apex,persona) values(otro,'FACU');
  select count(*) into n from lfo_cierres_semanales where persona='BRI' and semana_inicio=semana;
  if n>0 then raise_application_error(-20957,'La persona de prueba tiene un cierre de la semana actual.'); end if;
  lfo_metas_semanales_api.crear('META_TEMPORAL_'||rawtohex(sys_guid()),semana);
  if ayer!=trunc(ayer,'IW')+6 then
    select count(*) into n from lfo_dias_personales where persona='BRI' and fecha_logica=ayer and cerrado_en is null;
    if n>0 then raise_application_error(-20958,'El día anterior sigue abierto: elegir otra ventana de prueba.'); end if;
    select max(id) into dia from lfo_dias_personales where persona='BRI' and fecha_logica=ayer and cerrado_en is not null;
    select nvl(sum(segundos),0) into antes from lfo_cierre_dia_resumen where dia_id=dia and categoria='CULTIVO';
    insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
      values('BRI',semana,'TEST_'||rawtohex(sys_guid()),1,2) returning id into meta;
    lfo_cultivo_nuevo.registrar_manual(meta,ayer,1);
    select r.id,x.dia_id into registro,dia from lfo_registros_cultivo r join lfo_cultivo_manual_dia x on x.registro_id=r.id
      where r.meta_id=meta;
    select segundos into despues from lfo_cierre_dia_resumen where dia_id=dia and categoria='CULTIVO';
    if despues!=antes+60 then raise_application_error(-20959,'El resumen no incluye el Cultivo de ayer.'); end if;
    apex_custom_auth.set_user(otro);
    rechazada:=false;
    begin lfo_cultivo_manual_edicion.corregir(registro,0,meta,2);
    exception when others then if sqlcode=-20210 then rechazada:=true; else raise; end if; end;
    if not rechazada then raise_application_error(-20962,'Se pudo modificar Cultivo de otra cuenta.'); end if;
    apex_custom_auth.set_user(u);
    lfo_cultivo_manual_edicion.corregir(registro,0,meta,2);
    select segundos into despues from lfo_cierre_dia_resumen where dia_id=dia and categoria='CULTIVO';
    if despues!=antes+120 then raise_application_error(-20960,'La corrección de Cultivo no actualizó el resumen.'); end if;
  end if;
  insert into lfo_cierres_semanales(persona,semana_inicio,usuario_apex,puntos_trabajo,puntos_estudio,
    puntos_constancia,puntos_ocio,puntos_cultivo,puntos_metas,puntos_total)
    values('BRI',semana,u,0,0,0,0,0,0,0);
  rechazada:=false;
  begin lfo_metas_semanales_api.crear('NO_PERMITIDA',semana);
  exception when others then if sqlcode=-20241 then rechazada:=true; else raise; end if; end;
  if not rechazada then raise_application_error(-20961,'Se permitió agregar una meta a una semana cerrada.'); end if;
  rollback to prueba_cultivo_ayer;
  apex_util.remove_preference('LFO_SEMANA',u); apex_session.delete_session(p_session_id=>sesion);
exception when others then
  if guardado then rollback to prueba_cultivo_ayer; end if;
  apex_util.remove_preference('LFO_SEMANA',u); if sesion is not null then apex_session.delete_session(p_session_id=>sesion); end if; raise;
end;
/
-- El cronómetro no carga nuevos intervalos a una semana ya cerrada.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid()); sesion number;
  hoy date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date));
  semana date:=trunc(hoy,'IW'); n number; rechazado boolean:=false; guardado boolean:=false;
begin
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); sesion:=v('APP_SESSION');
  savepoint prueba_reloj_cerrado; guardado:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  select count(*) into n from lfo_cierres_semanales where persona='BRI' and semana_inicio=semana;
  if n>0 then raise_application_error(-20964,'La persona de prueba tiene un cierre de la semana actual.'); end if;
  select count(*) into n from lfo_relojes where persona='BRI';
  if n>0 then raise_application_error(-20965,'Se necesita una persona sin cronómetros para la prueba.'); end if;
  lfo_cronometros.iniciar('TRABAJO');
  lfo_cronometros.pausar('TRABAJO');
  insert into lfo_cierres_semanales(persona,semana_inicio,usuario_apex,puntos_trabajo,puntos_estudio,
    puntos_constancia,puntos_ocio,puntos_cultivo,puntos_metas,puntos_total)
    values('BRI',semana,u,0,0,0,0,0,0,0);
  begin lfo_cronometros.registrar('TRABAJO');
  exception when others then if sqlcode=-20241 then rechazado:=true; else raise; end if; end;
  if not rechazado then raise_application_error(-20966,'Se pudo cargar un cronómetro en una semana cerrada.'); end if;
  rollback to prueba_reloj_cerrado; apex_session.delete_session(p_session_id=>sesion);
exception when others then
  if guardado then rollback to prueba_reloj_cerrado; end if;
  if sesion is not null then apex_session.delete_session(p_session_id=>sesion); end if; raise;
end;
/
