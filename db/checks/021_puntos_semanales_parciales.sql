-- Datos temporales; no modifica semanas de uso y revierte la prueba.
declare
  w date:=date '2087-01-06'; t number; e number; c number; m number; cantidad number;
begin
  savepoint prueba_puntos_parciales;
  select count(*) into cantidad from lfo_puntos_semanales_parciales_v where semana_inicio=w;
  if cantidad!=0 then raise_application_error(-20890,'Se requiere una semana de prueba vacía.'); end if;
  insert into lfo_objetivos_horas(persona,semana_inicio,categoria,horas_objetivo) values('BRI',w,'TRABAJO',2);
  insert into lfo_metas_semanales(persona,semana_inicio,descripcion,completada) values('BRI',w,'TEST 1','S');
  insert into lfo_metas_semanales(persona,semana_inicio,descripcion,completada) values('BRI',w,'TEST 2','N');
  insert into lfo_metas_semanales(persona,semana_inicio,descripcion,completada) values('BRI',w,'TEST 3','N');
  insert into lfo_objetivos_horas(persona,semana_inicio,categoria,horas_objetivo) values('FACU',w,'ESTUDIO',1);
  select puntos_trabajo,puntos_estudio,puntos_constancia,puntos_metas_semanales into t,e,c,m
    from lfo_puntos_semanales_parciales_v where persona='BRI' and semana_inicio=w;
  if t!=0 or e is not null or c!=0 or abs(m-5/3)>0.000001 then raise_application_error(-20891,'Puntos parciales incorrectos.'); end if;
  select puntos_trabajo,puntos_estudio,puntos_constancia,puntos_metas_semanales into t,e,c,m
    from lfo_puntos_semanales_parciales_v where persona='FACU' and semana_inicio=w;
  if t is not null or e!=0 or c!=0 or m is not null then raise_application_error(-20892,'No se conservaron datos por persona.'); end if;
  rollback to prueba_puntos_parciales;
exception when others then rollback to prueba_puntos_parciales; raise;
end;
/
