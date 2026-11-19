-- Verifica semanas comparables, pertenencia al mes y redondeo, con rollback.
declare
  w date:=date '2087-01-06'; n number; esperadas number; promedio number; puntos number; meta number;
begin
  savepoint prueba_mes;
  select count(*) into n from lfo_puntos_semanales_v where semana_inicio>=w and semana_inicio<w+35;
  if n!=0 then raise_application_error(-20930,'La ventana de prueba debe estar vacía.'); end if;
  for i in 0..4 loop
    for persona in (select 'BRI' codigo from dual union all select 'FACU' from dual) loop
      insert into lfo_objetivos_horas(persona,semana_inicio,categoria,horas_objetivo) values(persona.codigo,w+i*7,'TRABAJO',1);
      insert into lfo_objetivos_horas(persona,semana_inicio,categoria,horas_objetivo) values(persona.codigo,w+i*7,'ESTUDIO',1);
      insert into lfo_objetivos_horas(persona,semana_inicio,categoria,horas_objetivo) values(persona.codigo,w+i*7,'OCIO',1);
      insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
        values(persona.codigo,w+i*7,'TEST_'||rawtohex(sys_guid()),1,1) returning id into meta;
      insert into lfo_metas_semanales(persona,semana_inicio,descripcion,completada)
        values(persona.codigo,w+i*7,'TEST',case when i<2 or (i=2 and persona.codigo='BRI') then 'S' else 'N' end);
      insert into lfo_cierres_semanales(persona,semana_inicio,usuario_apex,puntos_trabajo,puntos_estudio,puntos_constancia,
        puntos_ocio,puntos_cultivo,puntos_metas,puntos_total)
      select persona,semana_inicio,'TEST',round(puntos_trabajo),round(puntos_estudio),round(puntos_constancia),
        round(puntos_ocio),round(puntos_cultivo),round(puntos_metas_semanales),puntos_totales
      from lfo_puntos_semanales_v where persona=persona.codigo and semana_inicio=w+i*7;
      if sql%rowcount!=1 then raise_application_error(-20931,'Faltó el puntaje para la prueba.'); end if;
    end loop;
  end loop;
  select semanas_comparables,semanas_del_mes,promedio,puntos_mensuales into n,esperadas,promedio,puntos
  from lfo_progreso_mensual_v where persona='BRI' and mes_inicio=trunc(w,'MM');
  if n!=4 or esperadas!=4 or promedio!=8.75 or puntos!=9 then raise_application_error(-20932,'Promedio o pertenencia al mes incorrectos.'); end if;
  select semanas_comparables,promedio,puntos_mensuales into n,promedio,puntos
  from lfo_progreso_mensual_v where persona='FACU' and mes_inicio=trunc(w,'MM');
  if n!=4 or promedio!=7.5 or puntos!=8 then raise_application_error(-20933,'Promedio de la segunda persona incorrecto.'); end if;
  update lfo_metas_semanales set completada='N' where persona='BRI' and semana_inicio=w and descripcion='TEST';
  select semanas_comparables into n from lfo_progreso_mensual_v where persona='FACU' and mes_inicio=trunc(w,'MM');
  if n!=3 then raise_application_error(-20934,'Se incluyó una semana con cierre desactualizado.'); end if;
  rollback to prueba_mes;
exception when others then rollback to prueba_mes; raise;
end;
/
