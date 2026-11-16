-- Comprueba los límites sin redondeo, fracciones y ausencia de objetivo.
declare
  procedure comprobar(p_segundos number, p_horas number, p_esperado number) is
    v_real number := lfo_puntos_horas(p_segundos,p_horas);
  begin
    if (v_real is null and p_esperado is not null) or (v_real is not null and p_esperado is null)
       or v_real != p_esperado then
      raise_application_error(-20810,'Puntaje inesperado para segundos='||p_segundos||', horas='||p_horas);
    end if;
  end;
begin
  comprobar(0,1,0); comprobar(1,1,1);
  comprobar(1439,1,1); comprobar(1440,1,2);
  comprobar(2159,1,2); comprobar(2160,1,3);
  comprobar(2879,1,3); comprobar(2880,1,4);
  comprobar(3599,1,4); comprobar(3600,1,5); comprobar(7200,1,5);
  comprobar(900,0.5,2); comprobar(10,null,null); comprobar(10,0,null);
end;
/
