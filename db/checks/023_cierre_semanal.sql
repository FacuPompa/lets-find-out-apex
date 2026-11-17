-- Sesión y datos temporales; cada cierre se revierte al finalizar.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid()); otro varchar2(100):='TEST_'||rawtohex(sys_guid());
  s number; w date:=date '2087-01-06'; n number; ver number; total number; meta number;
  rechazo boolean:=false; guardado boolean:=false;
begin
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); s:=v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA',to_char(w,'YYYY-MM-DD'),u);
  apex_util.set_preference('LFO_SEMANA',to_char(w,'YYYY-MM-DD'),otro);
  savepoint prueba_cierre_semanal; guardado:=true;
  select count(*) into n from lfo_puntos_semanales_v where semana_inicio=w;
  if n>0 then raise_application_error(-20910,'La semana de prueba debe estar vacía.'); end if;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  insert into lfo_cuentas_persona(usuario_apex,persona) values(otro,'FACU');
  begin lfo_cierre_semanal.confirmar(w,0,null);
  exception when others then if sqlcode=-20224 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20911,'Se cerró sin metas ni objetivos.'); end if;
  for persona in (select 'BRI' p from dual union all select 'FACU' from dual) loop
    insert into lfo_objetivos_horas(persona,semana_inicio,categoria,horas_objetivo) values(persona.p,w,'TRABAJO',1);
    insert into lfo_objetivos_horas(persona,semana_inicio,categoria,horas_objetivo) values(persona.p,w,'ESTUDIO',1);
    insert into lfo_objetivos_horas(persona,semana_inicio,categoria,horas_objetivo) values(persona.p,w,'OCIO',1);
    insert into lfo_metas_semanales(persona,semana_inicio,descripcion,completada) values(persona.p,w,'TEST','S');
    insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
      values(persona.p,w,'TEST_'||rawtohex(sys_guid()),1,1) returning id into meta;
  end loop;
  lfo_cierre_semanal.confirmar(w,0,'Premio de prueba');
  select id,puntos_total into ver,total from lfo_cierre_semanal_actual_v where persona='BRI' and semana_inicio=w;
  if total!=10 then raise_application_error(-20912,'Total de cierre incorrecto.'); end if;
  rechazo:=false;
  begin lfo_cierre_semanal.confirmar(w,0,null);
  exception when others then if sqlcode=-20222 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20913,'Se aceptó una versión desactualizada.'); end if;
  lfo_cierre_semanal.confirmar(w,ver,'Premio actualizado');
  select count(*) into n from lfo_cierres_semanales where persona='BRI' and semana_inicio=w;
  if n!=2 then raise_application_error(-20914,'No se conservó el historial de cierres.'); end if;
  apex_custom_auth.set_user(otro);
  lfo_cierre_semanal.confirmar(w,0,'Otro premio');
  select count(*) into n from lfo_cierre_semanal_actual_v where semana_inicio=w;
  if n!=2 then raise_application_error(-20915,'Los cierres no son independientes.'); end if;
  apex_custom_auth.set_user(u);
  rechazo:=false;
  begin lfo_cierre_semanal.confirmar(w-7,0,null);
  exception when others then if sqlcode=-20220 then rechazo:=true; else raise; end if; end;
  if not rechazo then raise_application_error(-20916,'Se aceptó una semana distinta.'); end if;
  rollback to prueba_cierre_semanal;
  apex_util.remove_preference('LFO_SEMANA',u); apex_util.remove_preference('LFO_SEMANA',otro); apex_session.delete_session(p_session_id=>s);
exception when others then
  if guardado then rollback to prueba_cierre_semanal; end if;
  apex_util.remove_preference('LFO_SEMANA',u); apex_util.remove_preference('LFO_SEMANA',otro);
  if s is not null then apex_session.delete_session(p_session_id=>s); end if; raise;
end;
/
