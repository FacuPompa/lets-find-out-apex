-- Prueba aislada: requiere que la persona técnica de prueba no tenga cronómetros.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid()); u_ajeno varchar2(100):='TEST_'||rawtohex(sys_guid()); s number; n number; d number; r number;
  m number; otra number; version number; cantidad number; segundos number; validos number;
  semana date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date),'IW');
  guardado boolean:=false; rechazo boolean:=false;
begin
  select count(*) into n from lfo_relojes where persona='BRI';
  if n>0 then raise_application_error(-20820,'Se requiere una persona de prueba aislada.'); end if;
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); s:=v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA',to_char(semana,'YYYY-MM-DD'),u);
  savepoint prueba_correccion; guardado:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u_ajeno,'FACU');
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('BRI',semana,'TEST_'||rawtohex(sys_guid()),1,2) returning id into m;
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('FACU',semana,'TEST_'||rawtohex(sys_guid()),1,2) returning id into otra;
  lfo_cronometros.iniciar('TRABAJO');
  update lfo_relojes set activo_desde=activo_desde-interval '60' second where persona='BRI' and categoria='TRABAJO';
  update lfo_reloj_tramos set inicio=inicio-interval '60' second, registrado_hasta=registrado_hasta-interval '60' second
    where persona='BRI' and categoria='TRABAJO' and fin is null;
  lfo_cronometros.registrar('TRABAJO','N');
  select id into r from lfo_tiempo_registrado where persona='BRI' and categoria='TRABAJO';
  select dia_id into d from lfo_tiempo_actual_v where id=r;
  lfo_cierre_diario.cerrar(d,null);
  apex_custom_auth.set_user(u_ajeno);
  begin lfo_correccion_tiempo.corregir(r,0,'OCIO',60,null);
  exception when others then if sqlcode=-20194 then rechazo:=true; else raise; end if; end;
  apex_custom_auth.set_user(u);
  if not rechazo then raise_application_error(-20830,'Se aceptó corregir tiempo de otra cuenta.'); end if;
  rechazo:=false;
  lfo_correccion_tiempo.corregir(r,0,'ESTUDIO',3600,null);
  select segundos into segundos from lfo_cierre_dia_resumen where dia_id=d and categoria='ESTUDIO';
  if segundos!=3600 then raise_application_error(-20821,'No se actualizó el cierre.'); end if;
  select count(*) into n from lfo_constancia_dia_v where persona='BRI' and dia_activo=1;
  if n!=1 then raise_application_error(-20822,'No se actualizó la constancia.'); end if;
  begin lfo_correccion_tiempo.corregir(r,0,'OCIO',60,null);
  exception when others then if sqlcode=-20195 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20823,'Se aceptó una versión desactualizada.'); end if;
  select version into version from lfo_tiempo_actual_v where id=r;
  rechazo:=false;
  begin lfo_correccion_tiempo.corregir(r,version,'CULTIVO',120,otra);
  exception when others then if sqlcode=-20196 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20824,'Se aceptó una meta ajena.'); end if;
  lfo_correccion_tiempo.corregir(r,version,'CULTIVO',120,m);
  select cumplimientos into cantidad from lfo_progreso_cultivo_v2 where id=m;
  if cantidad!=2 then raise_application_error(-20825,'Cultivo no reflejó la corrección.'); end if;
  select segundos into segundos from lfo_cierre_dia_resumen where dia_id=d and categoria='CULTIVO';
  if segundos!=120 then raise_application_error(-20826,'El cierre no reflejó Cultivo.'); end if;
  select version into version from lfo_tiempo_actual_v where id=r;
  lfo_correccion_tiempo.corregir(r,version,'OCIO',90,null);
  select cumplimientos into cantidad from lfo_progreso_cultivo_v2 where id=m;
  if cantidad!=0 then raise_application_error(-20827,'No se retiró el cumplimiento de Cultivo.'); end if;
  update lfo_metas_cultivo set veces_por_semana=1 where id=m;
  select version into version from lfo_tiempo_actual_v where id=r;
  lfo_correccion_tiempo.corregir(r,version,'CULTIVO',120,m);
  update lfo_metas_cultivo set veces_por_semana=2 where id=m;
  select version into version from lfo_tiempo_actual_v where id=r;
  lfo_correccion_tiempo.corregir(r,version,'CULTIVO',120,m);
  select segundos_validos into validos from lfo_cultivo_tiempo where tiempo_id=r;
  if validos!=60 then raise_application_error(-20831,'Se recuperó un exceso descartado.'); end if;
  select count(*) into n from lfo_correcciones_tiempo where tiempo_id=r;
  if n!=5 then raise_application_error(-20828,'No se conservó el historial.'); end if;
  select count(*) into n from lfo_tiempo_registrado where id=r and categoria='TRABAJO';
  if n!=1 then raise_application_error(-20829,'Se modificó el registro original.'); end if;
  rollback to prueba_correccion; apex_util.remove_preference('LFO_SEMANA',u); apex_session.delete_session(p_session_id=>s);
exception when others then
  if guardado then rollback to prueba_correccion; end if;
  apex_util.remove_preference('LFO_SEMANA',u); if s is not null then apex_session.delete_session(p_session_id=>s); end if; raise;
end;
/
