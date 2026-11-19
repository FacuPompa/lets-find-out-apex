-- Dos cuentas temporales intentan modificar metas ajenas; todo se revierte.
declare
  usuario_a varchar2(100):='TEST_'||rawtohex(sys_guid());
  usuario_b varchar2(100):='TEST_'||rawtohex(sys_guid());
  desconocido varchar2(100):='TEST_'||rawtohex(sys_guid());
  sesion number; semana date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date),'IW');
  meta_a number; meta_b number; n number; persona varchar2(4); rechazo boolean; guardado boolean:=false;
begin
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>usuario_a); sesion:=v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA',to_char(semana,'YYYY-MM-DD'),usuario_a);
  apex_util.set_preference('LFO_SEMANA',to_char(semana,'YYYY-MM-DD'),usuario_b);
  savepoint aislamiento_metas; guardado:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(usuario_a,'BRI');
  insert into lfo_cuentas_persona(usuario_apex,persona) values(usuario_b,'FACU');
  select count(*) into n from lfo_cierres_semanales where semana_inicio=semana and persona in ('BRI','FACU');
  if n>0 then raise_application_error(-20980,'La prueba necesita una semana sin cierres para ambas personas.'); end if;
  insert into lfo_metas_semanales(persona,semana_inicio,descripcion) values('BRI',semana,usuario_a) returning id into meta_a;
  insert into lfo_metas_semanales(persona,semana_inicio,descripcion) values('FACU',semana,usuario_b) returning id into meta_b;
  lfo_metas_semanales_api.cambiar_estado(meta_a,'S',semana);
  rechazo:=false;
  begin lfo_metas_semanales_api.cambiar_estado(meta_b,'S',semana);
  exception when others then if sqlcode=-20185 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20981,'Una cuenta pudo modificar la meta ajena.'); end if;
  apex_custom_auth.set_user(usuario_b);
  lfo_metas_semanales_api.cambiar_estado(meta_b,'S',semana);
  rechazo:=false;
  begin lfo_metas_semanales_api.cambiar_estado(meta_a,'N',semana);
  exception when others then if sqlcode=-20185 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20982,'La otra cuenta pudo modificar la meta ajena.'); end if;
  select count(*) into n from lfo_metas_semanales where id in (meta_a,meta_b) and completada='S';
  if n!=2 then raise_application_error(-20983,'El intento ajeno alteró una meta.'); end if;
  apex_custom_auth.set_user(desconocido); rechazo:=false;
  begin persona:=lfo_persona_actual;
  exception when others then if sqlcode=-20021 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20984,'Una cuenta sin vincular obtuvo una persona.'); end if;
  rollback to aislamiento_metas;
  apex_util.remove_preference('LFO_SEMANA',usuario_a); apex_util.remove_preference('LFO_SEMANA',usuario_b);
  apex_session.delete_session(p_session_id=>sesion);
exception when others then
  if guardado then rollback to aislamiento_metas; end if;
  apex_util.remove_preference('LFO_SEMANA',usuario_a); apex_util.remove_preference('LFO_SEMANA',usuario_b);
  if sesion is not null then apex_session.delete_session(p_session_id=>sesion); end if;
  raise;
end;
/
