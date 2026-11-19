-- Cada cuenta guarda solo su premio; todo se revierte.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid()); otro varchar2(100):='TEST_'||rawtohex(sys_guid());
  s number; mes date:=date '2087-01-01'; n number; p varchar2(500); rechazado boolean:=false; guardado boolean:=false;
begin
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); s:=v('APP_SESSION');
  apex_util.set_preference('LFO_MES',to_char(mes,'YYYY-MM-DD'),u);
  apex_util.set_preference('LFO_MES',to_char(mes,'YYYY-MM-DD'),otro);
  savepoint prueba_premio_mes; guardado:=true;
  select count(*) into n from lfo_premios_mensuales where mes_inicio=mes;
  if n>0 then raise_application_error(-20935,'El mes de prueba debe estar vacío.'); end if;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  insert into lfo_cuentas_persona(usuario_apex,persona) values(otro,'FACU');
  lfo_premios_mensuales_api.guardar(mes,'Premio uno');
  begin lfo_premios_mensuales_api.guardar(add_months(mes,-1),'Inválido');
  exception when others then if sqlcode=-20230 then rechazado:=true; else raise; end if; end;
  if not rechazado then raise_application_error(-20936,'Se aceptó un mes desactualizado.'); end if;
  apex_custom_auth.set_user(otro);
  lfo_premios_mensuales_api.guardar(mes,'Premio dos');
  select premio into p from lfo_premios_mensuales where persona='BRI' and mes_inicio=mes;
  if p!='Premio uno' then raise_application_error(-20937,'Se alteró el premio de otra cuenta.'); end if;
  select count(*) into n from lfo_premios_mensuales where mes_inicio=mes;
  if n!=2 then raise_application_error(-20938,'Premios no separados por persona.'); end if;
  apex_custom_auth.set_user(u);
  rollback to prueba_premio_mes; apex_util.remove_preference('LFO_MES',u); apex_util.remove_preference('LFO_MES',otro); apex_session.delete_session(p_session_id=>s);
exception when others then
  if guardado then rollback to prueba_premio_mes; end if;
  apex_util.remove_preference('LFO_MES',u); apex_util.remove_preference('LFO_MES',otro); if s is not null then apex_session.delete_session(p_session_id=>s); end if; raise;
end;
/
