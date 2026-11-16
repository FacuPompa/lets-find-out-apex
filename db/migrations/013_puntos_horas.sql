-- Puntaje parcial para trabajo y estudio; sin objetivo no se asignan puntos.
create or replace function lfo_puntos_horas(p_segundos number, p_horas_objetivo number)
  return number deterministic authid definer
is
  v_segundos number := greatest(nvl(p_segundos,0),0);
  v_objetivo number;
begin
  if p_horas_objetivo is null or p_horas_objetivo <= 0 then return null; end if;
  v_objetivo := p_horas_objetivo * 3600;
  if v_segundos >= v_objetivo then return 5;
  elsif v_segundos >= v_objetivo * 0.8 then return 4;
  elsif v_segundos >= v_objetivo * 0.6 then return 3;
  elsif v_segundos >= v_objetivo * 0.4 then return 2;
  elsif v_segundos > 0 then return 1;
  else return 0;
  end if;
end;
/
