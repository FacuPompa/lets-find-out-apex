-- Ejecutar después de 002_registrar_sesion.sql, en una sesión de prueba.
declare
  v_persona lfo_metas_cultivo.persona%type;
  v_meta lfo_metas_cultivo.id%type;
  v_registros number;
  v_cumplimientos number;
  v_faltantes number;
  procedure debe_fallar(p_meta number, p_dia date, p_minutos number, p_error number) is
  begin
    lfo_registrar_sesion(p_meta, p_dia, p_minutos);
    raise_application_error(-20999, 'Se aceptó un registro inválido.');
  exception when others then
    if sqlcode != p_error then raise; end if;
  end;
begin
  savepoint prueba_registrar_sesion;
  select min(persona) into v_persona from lfo_metas_cultivo;
  if v_persona is null then
    raise_application_error(-20998, 'La prueba requiere una persona existente.');
  end if;
  insert into lfo_metas_cultivo (persona, semana_inicio, nombre, minutos_minimos, veces_por_semana)
  values (v_persona, date '2099-01-05', 'Test ' || rawtohex(sys_guid()), 30, 3)
  returning id into v_meta;

  lfo_registrar_sesion(v_meta, date '2099-01-05', 29);
  lfo_registrar_sesion(v_meta, date '2099-01-05', 30);
  lfo_registrar_sesion(v_meta, date '2099-01-05', 90);
  select registros, cumplimientos, faltantes into v_registros, v_cumplimientos, v_faltantes
  from lfo_progreso_cultivo_v where id = v_meta;
  if v_registros != 3 or v_cumplimientos != 2 or v_faltantes != 1 then
    raise_application_error(-20997, 'El progreso no coincide con las sesiones.');
  end if;
  debe_fallar(v_meta, date '2099-01-05', 0, -20012);
  debe_fallar(v_meta, date '2099-01-05', 1.5, -20012);
  debe_fallar(v_meta, date '2099-01-12', 30, -20014);
  debe_fallar(v_meta, date '2099-01-05' + 1/24, 30, -20011);
  debe_fallar(null, date '2099-01-05', 30, -20010);
  rollback to prueba_registrar_sesion;
exception when others then
  rollback to prueba_registrar_sesion;
  raise;
end;
/
