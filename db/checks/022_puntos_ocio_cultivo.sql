-- Límites de deuda de ocio y ponderación de cumplimientos de Cultivo.
declare
  w date:=date '2087-01-06'; a number; b number; n number; objetivos number; puntos number;
  procedure ocio(p_segundos number,p_esperado number) is v number:=lfo_puntos_ocio(p_segundos,5);
  begin if v!=p_esperado then raise_application_error(-20894,'Puntos de ocio incorrectos.'); end if; end;
begin
  savepoint prueba_puntos_cultivo;
  ocio(0,5); ocio(18000,5); ocio(18001,4); ocio(21600,4); ocio(21601,3);
  ocio(25200,3); ocio(25201,2); ocio(28800,2); ocio(28801,1); ocio(36000,1); ocio(36001,0);
  if lfo_puntos_ocio(0,null) is not null then raise_application_error(-20895,'El ocio sin objetivo no debe puntuar.'); end if;
  select count(*) into n from lfo_metas_cultivo where semana_inicio=w;
  if n!=0 then raise_application_error(-20896,'La semana de prueba no está vacía.'); end if;
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('BRI',w,'TEST A',1,4) returning id into a;
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('BRI',w,'TEST B',1,1) returning id into b;
  insert into lfo_registros_cultivo(meta_id,semana_inicio,dia_logico,minutos) values(a,w,w,1);
  insert into lfo_registros_cultivo(meta_id,semana_inicio,dia_logico,minutos) values(a,w,w,1);
  insert into lfo_registros_cultivo(meta_id,semana_inicio,dia_logico,minutos) values(b,w,w,1);
  select completados,objetivo,puntos into n,objetivos,puntos from lfo_puntos_cultivo_v where persona='BRI' and semana_inicio=w;
  if n!=3 or objetivos!=5 or puntos!=3 then raise_application_error(-20897,'Puntos de Cultivo incorrectos.'); end if;
  insert into lfo_registros_cultivo(meta_id,semana_inicio,dia_logico,minutos) values(b,w,w,1);
  select puntos into puntos from lfo_puntos_cultivo_v where persona='BRI' and semana_inicio=w;
  if puntos!=3 then raise_application_error(-20898,'Se contaron cumplimientos por encima del objetivo.'); end if;
  select puntos_totales into puntos from lfo_puntos_semanales_v where persona='BRI' and semana_inicio=w;
  if puntos is not null then raise_application_error(-20899,'Se calculó un total con objetivos faltantes.'); end if;
  insert into lfo_objetivos_horas(persona,semana_inicio,categoria,horas_objetivo) values('BRI',w,'TRABAJO',1);
  insert into lfo_objetivos_horas(persona,semana_inicio,categoria,horas_objetivo) values('BRI',w,'ESTUDIO',1);
  insert into lfo_objetivos_horas(persona,semana_inicio,categoria,horas_objetivo) values('BRI',w,'OCIO',1);
  insert into lfo_metas_semanales(persona,semana_inicio,descripcion,completada) values('BRI',w,'TEST TOTAL','S');
  select puntos_totales into puntos from lfo_puntos_semanales_v where persona='BRI' and semana_inicio=w;
  if puntos!=13 then raise_application_error(-20900,'La suma de los seis rubros es incorrecta.'); end if;
  insert into lfo_metas_semanales(persona,semana_inicio,descripcion,completada) values('BRI',w,'TEST PENDIENTE','N');
  select puntos_totales into puntos from lfo_puntos_semanales_v where persona='BRI' and semana_inicio=w;
  if puntos!=11 then raise_application_error(-20901,'No se redondeó el rubro antes de sumarlo.'); end if;
  update lfo_metas_cultivo set veces_por_semana=3 where id=a;
  select puntos_totales into puntos from lfo_puntos_semanales_v where persona='BRI' and semana_inicio=w;
  if puntos!=12 then raise_application_error(-20902,'El total no suma cada rubro redondeado.'); end if;
  rollback to prueba_puntos_cultivo;
exception when others then rollback to prueba_puntos_cultivo; raise;
end;
/
