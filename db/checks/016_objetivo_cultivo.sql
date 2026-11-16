-- Inserta metas temporales y revierte todos los cambios de esta prueba.
declare
  v_semana date := date '2087-01-06'; -- lunes
  v_nombre varchar2(60) := 'TEST_' || rawtohex(sys_guid());
  v_horas number;
begin
  savepoint prueba_objetivo_cultivo;
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('BRI',v_semana,v_nombre||'_1',30,4);
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('BRI',v_semana,v_nombre||'_2',45,2);
  select horas_objetivo into v_horas from lfo_objetivo_cultivo_v where persona='BRI' and semana_inicio=v_semana;
  if v_horas != 3.5 then raise_application_error(-20811,'La suma de objetivos de Cultivo no coincide.'); end if;
  rollback to prueba_objetivo_cultivo;
exception when others then rollback to prueba_objetivo_cultivo; raise;
end;
/
