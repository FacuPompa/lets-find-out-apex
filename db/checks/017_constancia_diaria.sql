-- Los segundos de trabajo y estudio se evalúan por separado.
declare
  procedure comprobar(p_trabajo number, p_estudio number, p_esperado number) is
  begin
    if lfo_dia_constante(p_trabajo,p_estudio) != p_esperado then
      raise_application_error(-20812,'Resultado incorrecto para constancia diaria.');
    end if;
  end;
begin
  comprobar(null,null,0);
  comprobar(1800,1800,0);
  comprobar(3599,0,0);
  comprobar(3600,0,1);
  comprobar(0,3600,1);
  comprobar(3600,3600,1);
end;
/
-- Comprueba agregación, semana del día personal y límite de cinco puntos.
-- Requiere una persona de prueba sin cronómetros y una sesión dedicada.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid());
  s number; d number; activos number; puntos number; n number; guardado boolean:=false;
  lunes date:=date '2087-01-06';
  procedure agregar(p_categoria varchar2,p_segundos number) is
  begin
    lfo_cronometros.iniciar(p_categoria);
    update lfo_relojes set activo_desde=activo_desde-numtodsinterval(p_segundos,'SECOND')
      where persona='BRI' and categoria=p_categoria;
    update lfo_reloj_tramos set inicio=inicio-numtodsinterval(p_segundos,'SECOND'),
      registrado_hasta=registrado_hasta-numtodsinterval(p_segundos,'SECOND')
      where persona='BRI' and categoria=p_categoria and fin is null;
    lfo_cronometros.registrar(p_categoria,'N');
  end;
begin
  select count(*) into n from lfo_relojes where persona='BRI';
  if n>0 then raise_application_error(-20813,'Se requiere una persona de prueba aislada.'); end if;
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); s:=v('APP_SESSION');
  savepoint prueba_constancia; guardado:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  for i in 0..6 loop
    if i=0 then agregar('TRABAJO',1800); agregar('TRABAJO',1800);
    elsif i=5 then agregar('TRABAJO',1800); agregar('ESTUDIO',1800);
    else agregar('ESTUDIO',3600); end if;
    select id into d from lfo_dias_personales where persona='BRI' and cerrado_en is null;
    update lfo_dias_personales set fecha_logica=lunes+i, cerrado_en=systimestamp where id=d;
  end loop;
  select dias_activos,puntos into activos,puntos from lfo_constancia_semanal_v
    where persona='BRI' and semana_inicio=lunes;
  if activos!=6 or puntos!=5 then raise_application_error(-20814,'Constancia semanal incorrecta.'); end if;
  select dia_activo into n from lfo_constancia_dia_v where persona='BRI' and fecha_logica=lunes+5;
  if n!=0 then raise_application_error(-20815,'Se sumaron categorías distintas.'); end if;
  rollback to prueba_constancia; apex_session.delete_session(p_session_id=>s);
exception when others then
  if guardado then rollback to prueba_constancia; end if;
  if s is not null then apex_session.delete_session(p_session_id=>s); end if;
  raise;
end;
/
