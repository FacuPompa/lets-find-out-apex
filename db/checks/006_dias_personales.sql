-- Ejecutar en sesion SQL dedicada. Usa una cuenta vinculada sin dia abierto.
-- Las filas de prueba se revierten; no cierra ni altera dias reales.
declare
  v_usuario lfo_cuentas_persona.usuario_apex%type;
  v_persona lfo_cuentas_persona.persona%type;
  v_sesion number;
  v_uno number;
  v_dos number;
  v_guardado boolean := false;
  v_rechazado boolean := false;
begin
  select usuario_apex, persona into v_usuario, v_persona from (
    select c.usuario_apex, c.persona from lfo_cuentas_persona c
    where not exists (select 1 from lfo_dias_personales d where d.persona = c.persona and d.cerrado_en is null)
  ) where rownum = 1;
  apex_session.create_session(p_app_id => 100, p_page_id => 1, p_username => v_usuario);
  v_sesion := v('APP_SESSION');
  savepoint prueba_dias;
  v_guardado := true;
  v_uno := lfo_dias.abrir_o_actual;
  v_dos := lfo_dias.abrir_o_actual;
  if v_uno != v_dos then raise_application_error(-20960, 'Se crearon dos días abiertos.'); end if;
  update lfo_dias_personales set fecha_logica = fecha_logica - 1 where id = v_uno;
  v_dos := lfo_dias.abrir_o_actual;
  if v_uno != v_dos then raise_application_error(-20961, 'El día abierto cambió al cambiar la fecha.'); end if;
  begin
    insert into lfo_dias_personales(persona, fecha_logica) values(v_persona, trunc(sysdate));
  exception when dup_val_on_index then v_rechazado := true;
  end;
  if not v_rechazado then raise_application_error(-20962, 'Se permitió más de un día abierto.'); end if;
  rollback to prueba_dias;
  apex_session.delete_session(p_session_id => v_sesion);
exception when others then
  if v_guardado then rollback to prueba_dias; end if;
  if v_sesion is not null then apex_session.delete_session(p_session_id => v_sesion); end if;
  raise;
end;
/
