-- Prueba transaccional: revierte exclusivamente sus propios datos.
declare
  v_meta number;
  v_vacia number;
  v_registros number;
  v_cumplimientos number;
  v_faltantes number;
  v_porcentaje number;
  procedure rechazar_registro(p_semana date, p_dia date, p_minutos number, p_error number) is
  begin
    insert into lfo_registros_cultivo (meta_id, semana_inicio, dia_logico, minutos)
    values (v_meta, p_semana, p_dia, p_minutos);
    raise_application_error(-20001, 'Se acepto un registro invalido');
  exception when others then
    if sqlcode != p_error then raise; end if;
  end;
begin
  savepoint prueba_cultivo;
  insert into lfo_metas_cultivo (persona, semana_inicio, nombre, minutos_minimos, veces_por_semana)
  values ('FACU', date '2099-01-05', 'Prueba ' || rawtohex(sys_guid()), 30, 3)
  returning id into v_meta;

  select registros, cumplimientos, faltantes, porcentaje
  into v_registros, v_cumplimientos, v_faltantes, v_porcentaje
  from lfo_progreso_cultivo_v where id = v_meta;
  if v_registros != 0 or v_cumplimientos != 0 or v_faltantes != 3 or v_porcentaje != 0 then
    raise_application_error(-20002, 'Progreso inicial incorrecto');
  end if;

  for r in (select 29 minutos from dual union all select 30 from dual union all select 90 from dual) loop
    insert into lfo_registros_cultivo (meta_id, semana_inicio, dia_logico, minutos)
    values (v_meta, date '2099-01-05', date '2099-01-05', r.minutos);
  end loop;
  select registros, cumplimientos, faltantes, porcentaje
  into v_registros, v_cumplimientos, v_faltantes, v_porcentaje
  from lfo_progreso_cultivo_v where id = v_meta;
  if v_registros != 3 or v_cumplimientos != 2 or v_faltantes != 1 or v_porcentaje != 66.7 then
    raise_application_error(-20003, 'Error con minimo, sesion larga o sesiones del mismo dia');
  end if;

  rechazar_registro(date '2099-01-05', date '2099-01-05', 0, -2290);
  rechazar_registro(date '2099-01-05', date '2099-01-05', 1.5, -2290);
  rechazar_registro(date '2099-01-05', date '2099-01-04', 30, -2290);
  rechazar_registro(date '2099-01-05', date '2099-01-12', 30, -2290);
  rechazar_registro(date '2099-01-12', date '2099-01-12', 30, -2291);

  insert into lfo_registros_cultivo (meta_id, semana_inicio, dia_logico, minutos)
  values (v_meta, date '2099-01-05', date '2099-01-11', 30);
  insert into lfo_registros_cultivo (meta_id, semana_inicio, dia_logico, minutos)
  values (v_meta, date '2099-01-05', date '2099-01-11', 30);
  select cumplimientos, faltantes, porcentaje
  into v_cumplimientos, v_faltantes, v_porcentaje
  from lfo_progreso_cultivo_v where id = v_meta;
  if v_cumplimientos != 4 or v_faltantes != 0 or v_porcentaje != 100 then
    raise_application_error(-20004, 'Error al superar el objetivo');
  end if;

  insert into lfo_metas_cultivo (persona, semana_inicio, nombre, minutos_minimos, veces_por_semana)
  values ('BRI', date '2099-01-05', 'Prueba ' || rawtohex(sys_guid()), 20, 2)
  returning id into v_vacia;
  select cumplimientos into v_cumplimientos from lfo_progreso_cultivo_v where id = v_vacia;
  if v_cumplimientos != 0 then
    raise_application_error(-20005, 'Se mezclaron metas de distintas personas');
  end if;

  rollback to prueba_cultivo;
exception when others then
  rollback to prueba_cultivo;
  raise;
end;
/
