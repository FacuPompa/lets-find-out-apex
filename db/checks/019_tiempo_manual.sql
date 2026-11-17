-- Cargas y correcciones temporales; ejecutar en sesión dedicada.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid()); otro varchar2(100):='TEST_'||rawtohex(sys_guid());
  s number; n number; r number; d number; v_version number; segundos number; rechazo boolean:=false; guardado boolean:=false;
begin
  select count(*) into n from lfo_reloj_persona where persona='BRI';
  if n>0 then raise_application_error(-20840,'Se requiere una persona de prueba aislada.'); end if;
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); s:=v('APP_SESSION');
  savepoint prueba_manual; guardado:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  insert into lfo_cuentas_persona(usuario_apex,persona) values(otro,'FACU');
  begin lfo_tiempo_manual_api.crear('OCIO',60,trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date))-1);
  exception when others then if sqlcode=-20205 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20849,'Se aceptó un día desactualizado.'); end if;
  rechazo:=false;
  lfo_tiempo_manual_api.crear('TRABAJO',1800,trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date)));
  lfo_tiempo_manual_api.crear('TRABAJO',1800,trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date)));
  select count(*) into n from lfo_relojes where persona='BRI';
  if n!=0 then raise_application_error(-20841,'La carga manual creó un reloj.'); end if;
  select max(id),max(dia_id) into r,d from lfo_tiempo_manual where persona='BRI'; r:=-r;
  select dia_activo into n from lfo_constancia_dia_v where persona='BRI';
  if n!=1 then raise_application_error(-20842,'La carga manual no cuenta para constancia.'); end if;
  lfo_cierre_diario.cerrar(d,null);
  rechazo:=false;
  begin lfo_tiempo_manual_api.crear('OCIO',60,trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date)),d);
  exception when others then if sqlcode=-20205 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20850,'Se aceptó un día cerrado con la misma fecha.'); end if;
  select count(*) into n from lfo_dias_personales where persona='BRI' and cerrado_en is null;
  if n!=0 then raise_application_error(-20859,'La carga rechazada dejó un día abierto.'); end if;
  rechazo:=false;
  apex_custom_auth.set_user(otro);
  begin lfo_tiempo_manual_api.corregir(r,0,'OCIO',60);
  exception when others then if sqlcode=-20204 then rechazo:=true; else raise; end if; end;
  apex_custom_auth.set_user(u);
  if not rechazo then raise_application_error(-20843,'Se aceptó corregir una carga ajena.'); end if;
  lfo_tiempo_manual_api.corregir(r,0,'ESTUDIO',900);
  select segundos into segundos from lfo_cierre_dia_resumen where dia_id=d and categoria='ESTUDIO';
  if segundos!=900 then raise_application_error(-20844,'El cierre no reflejó la corrección.'); end if;
  select dia_activo into n from lfo_constancia_dia_v where persona='BRI';
  if n!=0 then raise_application_error(-20845,'La constancia no reflejó la corrección.'); end if;
  rechazo:=false;
  begin lfo_tiempo_manual_api.corregir(r,0,'OCIO',60);
  exception when others then if sqlcode=-20195 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20846,'Se aceptó una versión desactualizada.'); end if;
  select version into v_version from lfo_tiempo_actual_v where id=r;
  rechazo:=false;
  begin lfo_tiempo_manual_api.corregir(r,v_version,'CULTIVO',60);
  exception when others then if sqlcode=-20201 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20847,'Se aceptó Cultivo sin actividad.'); end if;
  select count(*) into n from lfo_correcciones_manual where manual_id=-r;
  if n!=1 then raise_application_error(-20848,'No se conservó el historial.'); end if;
  rollback to prueba_manual; apex_session.delete_session(p_session_id=>s);
exception when others then
  if guardado then rollback to prueba_manual; end if;
  if s is not null then apex_session.delete_session(p_session_id=>s); end if; raise;
end;
/
