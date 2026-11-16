-- Aísla las sesiones y las metas con datos temporales, y revierte la prueba.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid()); otro varchar2(100):='TEST_'||rawtohex(sys_guid());
  s number; semana date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date),'IW');
  m number; m2 number; ajena number; r number; legado number; n number; ver number; valido number;
  rechazo boolean:=false; guardado boolean:=false;
begin
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); s:=v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA',to_char(semana,'YYYY-MM-DD'),u);
  savepoint prueba_cultivo_manual; guardado:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  insert into lfo_cuentas_persona(usuario_apex,persona) values(otro,'FACU');
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('BRI',semana,'TEST_'||rawtohex(sys_guid()),60,1) returning id into m;
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('BRI',semana,'TEST_'||rawtohex(sys_guid()),60,2) returning id into m2;
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('FACU',semana,'TEST_'||rawtohex(sys_guid()),60,2) returning id into ajena;
  lfo_cultivo_nuevo.registrar_manual(m,semana,120);
  select max(id) into r from lfo_registros_cultivo where meta_id=m;
  update lfo_metas_cultivo set veces_por_semana=2 where id=m;
  lfo_cultivo_manual_edicion.corregir(r,0,m,120);
  select segundos_validos into valido from lfo_cultivo_manual_nuevo where registro_id=r;
  if valido!=3600 then raise_application_error(-20851,'Se recuperó un exceso descartado.'); end if;
  select max(id) into ver from lfo_correcciones_cultivo_manual where registro_id=r;
  begin lfo_cultivo_manual_edicion.corregir(r,0,m,30);
  exception when others then if sqlcode=-20195 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20852,'Se aceptó una versión anterior.'); end if;
  rechazo:=false;
  begin lfo_cultivo_manual_edicion.corregir(r,ver,ajena,30);
  exception when others then if sqlcode=-20196 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20853,'Se aceptó una actividad ajena.'); end if;
  apex_custom_auth.set_user(otro); rechazo:=false;
  begin lfo_cultivo_manual_edicion.corregir(r,ver,ajena,30);
  exception when others then if sqlcode=-20210 then rechazo:=true; else raise; end if; end;
  apex_custom_auth.set_user(u);
  if not rechazo then raise_application_error(-20854,'Se aceptó corregir una sesión ajena.'); end if;
  lfo_cultivo_manual_edicion.corregir(r,ver,m2,60);
  select cumplimientos into n from lfo_progreso_cultivo_v2 where id=m2;
  if n!=1 then raise_application_error(-20855,'La actividad nueva no refleja la corrección.'); end if;
  select cumplimientos into n from lfo_progreso_cultivo_v2 where id=m;
  if n!=0 then raise_application_error(-20856,'La actividad anterior conserva la sesión.'); end if;
  insert into lfo_registros_cultivo(meta_id,semana_inicio,dia_logico,minutos) values(m,semana,semana,90) returning id into legado;
  lfo_cultivo_manual_edicion.corregir(legado,0,m,120);
  select count(*) into n from lfo_cultivo_manual_nuevo where registro_id=legado;
  if n!=0 then raise_application_error(-20857,'Cambió la regla de una sesión histórica.'); end if;
  select count(*) into n from lfo_correcciones_cultivo_manual where registro_id=r;
  if n!=2 then raise_application_error(-20858,'Falta historial.'); end if;
  rollback to prueba_cultivo_manual; apex_util.remove_preference('LFO_SEMANA',u); apex_session.delete_session(p_session_id=>s);
exception when others then
  if guardado then rollback to prueba_cultivo_manual; end if;
  apex_util.remove_preference('LFO_SEMANA',u); if s is not null then apex_session.delete_session(p_session_id=>s); end if; raise;
end;
/
