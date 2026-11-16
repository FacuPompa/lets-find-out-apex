-- Usa cuentas temporales y revierte sus datos. Ejecutar en sesión dedicada.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid());
  s number; w date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date),'IW');
  m number; n number; p number; rechazado boolean:=false; guardado boolean:=false;
begin
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); s:=v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA',to_char(w,'YYYY-MM-DD'),u);
  savepoint prueba_metas; guardado:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  lfo_metas_semanales_api.crear('Primera meta temporal',w);
  lfo_metas_semanales_api.crear('Segunda meta temporal',w);
  lfo_metas_semanales_api.crear('Tercera meta temporal',w);
  select max(id) into m from lfo_metas_semanales where persona='BRI' and descripcion='Primera meta temporal';
  lfo_metas_semanales_api.cambiar_estado(m,'S',w);
  select count(*), 5*sum(case when completada='S' then 1 else 0 end)/count(*) into n,p
    from lfo_metas_semanales where persona='BRI' and semana_inicio=w and descripcion like '%meta temporal';
  if n!=3 or abs(p-5/3)>0.000001 then raise_application_error(-20895,'Puntos incorrectos.'); end if;
  insert into lfo_metas_semanales(persona,semana_inicio,descripcion) values('FACU',w,'Meta ajena temporal') returning id into m;
  begin lfo_metas_semanales_api.cambiar_estado(m,'S',w);
  exception when others then if sqlcode=-20185 then rechazado:=true; else raise; end if; end;
  if not rechazado then raise_application_error(-20896,'Se aceptó modificar una meta ajena.'); end if;
  rechazado:=false;
  begin lfo_metas_semanales_api.crear('Meta semana anterior',w-7);
  exception when others then if sqlcode=-20182 then rechazado:=true; else raise; end if; end;
  if not rechazado then raise_application_error(-20897,'Se aceptó una semana desactualizada.'); end if;
  rollback to prueba_metas;
  apex_session.delete_session(p_session_id=>s);
exception when others then
  if guardado then rollback to prueba_metas; end if;
  if s is not null then apex_session.delete_session(p_session_id=>s); end if;
  raise;
end;
/
