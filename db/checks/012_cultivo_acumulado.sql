-- Sesión APEX y datos de prueba; todo se revierte. Requiere BRI sin cronómetros.
declare
  v_usuario varchar2(100) := 'TEST_' || rawtohex(sys_guid());
  v_sesion number;
  v_semana date := trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date),'IW');
  v_meta number;
  v_ajena number;
  v_cumplidos number;
  v_cantidad number;
  v_dia number;
  v_aviso number;
  v_guardado boolean := false;
  v_rechazo boolean := false;
begin
  select count(*) into v_cantidad from lfo_relojes where persona='BRI';
  if v_cantidad != 0 then raise_application_error(-20860,'Se requiere persona de prueba aislada.'); end if;
  apex_session.create_session(p_app_id=>100,p_page_id=>3,p_username=>v_usuario);
  v_sesion:=v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA',to_char(v_semana,'YYYY-MM-DD'),v_usuario);
  savepoint prueba_cultivo_nuevo;
  v_guardado := true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(v_usuario,'BRI');
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('BRI',v_semana,'TEST_' || rawtohex(sys_guid()),60,3) returning id into v_meta;
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('FACU',v_semana,'TEST_' || rawtohex(sys_guid()),60,3) returning id into v_ajena;
  begin
    lfo_cultivo_nuevo.registrar_manual(v_ajena,v_semana,60);
  exception when others then if sqlcode=-20170 then v_rechazo:=true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20861,'Se aceptó una meta ajena.'); end if;
  v_rechazo:=false;
  begin
    v_aviso:=lfo_cultivo_nuevo.aviso_minutos(v_ajena);
  exception when others then if sqlcode=-20170 then v_rechazo:=true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20872,'Se obtuvo aviso de una meta ajena.'); end if;
  v_rechazo:=false;
  begin
    lfo_cultivo_nuevo.operar_reloj('REGISTRAR','CULTIVO','N');
  exception when others then if sqlcode=-20173 then v_rechazo:=true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20873,'Se registró Cultivo sin elegir actividad.'); end if;
  insert into lfo_registros_cultivo(meta_id,semana_inicio,dia_logico,minutos) values(v_meta,v_semana,v_semana,30);
  insert into lfo_registros_cultivo(meta_id,semana_inicio,dia_logico,minutos) values(v_meta,v_semana,v_semana,60);
  select cumplimientos into v_cumplidos from lfo_progreso_cultivo_v2 where id=v_meta;
  if v_cumplidos != 1 then raise_application_error(-20862,'Cambió el historial anterior.'); end if;
  lfo_cultivo_nuevo.registrar_manual(v_meta,v_semana,45);
  lfo_cultivo_nuevo.registrar_manual(v_meta,v_semana,20);
  select cumplimientos into v_cumplidos from lfo_progreso_cultivo_v2 where id=v_meta;
  if v_cumplidos != 2 then raise_application_error(-20863,'No se acumularon los minutos nuevos.'); end if;
  lfo_cronometros.iniciar('CULTIVO');
  update lfo_relojes set activo_desde = activo_desde - interval '2700' second where persona='BRI' and categoria='CULTIVO';
  update lfo_reloj_tramos set inicio=inicio-interval '2700' second, registrado_hasta=registrado_hasta-interval '2700' second
    where persona='BRI' and categoria='CULTIVO' and fin is null;
  v_aviso := lfo_cultivo_nuevo.aviso_minutos(v_meta);
  if v_aviso < 9 or v_aviso > 10 then raise_application_error(-20870,'No se avisó cerca del próximo cumplimiento.'); end if;
  update lfo_relojes set activo_desde = activo_desde - interval '600' second where persona='BRI' and categoria='CULTIVO';
  update lfo_reloj_tramos set inicio=inicio-interval '600' second, registrado_hasta=registrado_hasta-interval '600' second
    where persona='BRI' and categoria='CULTIVO' and fin is null;
  select dia_id into v_dia from lfo_reloj_tramos where persona='BRI' and categoria='CULTIVO' and fin is null;
  update lfo_dias_personales set fecha_logica=v_semana+7 where id=v_dia;
  v_rechazo:=false;
  begin
    lfo_cultivo_nuevo.registrar_cronometro(v_meta);
  exception when others then if sqlcode=-20171 then v_rechazo:=true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20864,'Se aceptó tiempo de otra semana.'); end if;
  update lfo_dias_personales set fecha_logica=v_semana where id=v_dia;
  lfo_cultivo_nuevo.registrar_cronometro(v_meta);
  select cumplimientos into v_cumplidos from lfo_progreso_cultivo_v2 where id=v_meta;
  if v_cumplidos != 3 then raise_application_error(-20865,'El cronómetro no sumó al progreso.'); end if;
  select count(*) into v_cantidad from lfo_cultivo_tiempo where meta_id=v_meta;
  if v_cantidad != 1 then raise_application_error(-20866,'Tiempo asociado incorrectamente.'); end if;
  v_rechazo:=false;
  begin
    lfo_cultivo_nuevo.registrar_cronometro(v_meta);
  exception when others then if sqlcode=-20106 then v_rechazo:=true; else raise; end if;
  end;
  if not v_rechazo then raise_application_error(-20867,'Se aceptó registrar dos veces.'); end if;
  lfo_cronometros.iniciar('CULTIVO');
  update lfo_relojes set activo_desde=activo_desde-interval '3600' second where persona='BRI' and categoria='CULTIVO';
  update lfo_reloj_tramos set inicio=inicio-interval '3600' second, registrado_hasta=registrado_hasta-interval '3600' second
    where persona='BRI' and categoria='CULTIVO' and fin is null;
  lfo_cultivo_nuevo.registrar_cronometro(v_meta);
  select cumplimientos into v_cumplidos from lfo_progreso_cultivo_v2 where id=v_meta;
  if v_cumplidos != 3 then raise_application_error(-20868,'Se contaron actividades después de completar la meta.'); end if;
  select count(*) into v_cantidad from lfo_cultivo_tiempo where meta_id=v_meta;
  if v_cantidad != 2 then raise_application_error(-20869,'La segunda carga no se vinculó por separado.'); end if;
  lfo_cultivo_nuevo.registrar_manual(v_meta,v_semana,60);
  update lfo_metas_cultivo set veces_por_semana=4 where id=v_meta;
  select cumplimientos into v_cumplidos from lfo_progreso_cultivo_v2 where id=v_meta;
  if v_cumplidos != 3 then raise_application_error(-20871,'Se recuperó tiempo descartado al cambiar la meta.'); end if;
  rollback to prueba_cultivo_nuevo;
  apex_util.remove_preference('LFO_SEMANA',v_usuario);
  apex_session.delete_session(p_session_id=>v_sesion);
exception when others then
  if v_guardado then rollback to prueba_cultivo_nuevo; end if;
  apex_util.remove_preference('LFO_SEMANA',v_usuario);
  if v_sesion is not null then apex_session.delete_session(p_session_id=>v_sesion); end if;
  raise;
end;
/
