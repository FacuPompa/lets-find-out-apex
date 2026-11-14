-- API interna del prototipo: la interfaz debe autorizar la meta antes de llamar.
-- No confirma la transacción; el llamador decide COMMIT o ROLLBACK.
create or replace procedure lfo_registrar_sesion (
  p_meta_id in lfo_metas_cultivo.id%type,
  p_dia_logico in date,
  p_minutos in number
) authid definer as
  v_semana lfo_metas_cultivo.semana_inicio%type;
begin
  if p_meta_id is null or p_dia_logico is null or p_minutos is null then
    raise_application_error(-20010, 'Completá la meta, el día y los minutos.');
  end if;
  if p_dia_logico != trunc(p_dia_logico) then
    raise_application_error(-20011, 'Indicá una fecha sin hora.');
  end if;
  if p_minutos < 1 or p_minutos != trunc(p_minutos) then
    raise_application_error(-20012, 'Indicá minutos enteros mayores que cero.');
  end if;

  begin
    select semana_inicio into v_semana
    from lfo_metas_cultivo where id = p_meta_id;
  exception when no_data_found then
    raise_application_error(-20013, 'La meta seleccionada no existe.');
  end;
  if p_dia_logico < v_semana or p_dia_logico >= v_semana + 7 then
    raise_application_error(-20014, 'El día debe pertenecer a la semana de la meta.');
  end if;

  insert into lfo_registros_cultivo (meta_id, semana_inicio, dia_logico, minutos)
  values (p_meta_id, v_semana, p_dia_logico, p_minutos);
end;
/
