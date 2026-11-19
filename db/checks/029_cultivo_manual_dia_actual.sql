-- Prueba con sesiones y registros temporales, sin confirmar datos.
declare
  u varchar2(100):='TEST_'||rawtohex(sys_guid()); otro varchar2(100):='TEST_'||rawtohex(sys_guid());
  sesion number; hoy date:=trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date));
  semana date:=trunc(hoy,'IW'); n number; meta number; registro number; dia number; segundos number;
  rechazado boolean:=false; guardado boolean:=false;
begin
  apex_session.create_session(p_app_id=>100,p_page_id=>1,p_username=>u); sesion:=v('APP_SESSION');
  apex_util.set_preference('LFO_SEMANA',to_char(semana,'YYYY-MM-DD'),u);
  savepoint prueba_cultivo_hoy; guardado:=true;
  insert into lfo_cuentas_persona(usuario_apex,persona) values(u,'BRI');
  insert into lfo_cuentas_persona(usuario_apex,persona) values(otro,'FACU');
  select count(*) into n from lfo_dias_personales where persona='BRI' and cerrado_en is null;
  if n>0 then raise_application_error(-20970,'La persona de prueba ya tiene un día abierto.'); end if;
  select count(*) into n from lfo_cierres_semanales where persona='BRI' and semana_inicio=semana;
  if n>0 then raise_application_error(-20971,'La persona de prueba ya tiene cerrada la semana.'); end if;
  begin insert into lfo_reloj_persona(persona) values('BRI');
  exception when dup_val_on_index then null; end;
  insert into lfo_metas_cultivo(persona,semana_inicio,nombre,minutos_minimos,veces_por_semana)
    values('BRI',semana,'TEST_'||rawtohex(sys_guid()),30,3) returning id into meta;
  savepoint pruebas_hoy;
  lfo_cultivo_nuevo.registrar_manual(meta,hoy,30);
  select r.id,x.dia_id into registro,dia from lfo_registros_cultivo r
    join lfo_cultivo_manual_dia x on x.registro_id=r.id where r.meta_id=meta;
  select segundos into segundos from lfo_resumen_dia_v where dia_id=dia and categoria='CULTIVO';
  if segundos!=1800 then raise_application_error(-20972,'El día no refleja los 30 minutos.'); end if;
  select segundos into segundos from lfo_progreso_horas_v where persona='BRI' and semana_inicio=semana and categoria='CULTIVO';
  if segundos<1800 then raise_application_error(-20973,'El progreso semanal no incluye el cultivo.'); end if;
  select cumplimientos into n from lfo_progreso_cultivo_v2 where id=meta;
  if n!=1 then raise_application_error(-20974,'El cultivo se contó más o menos de una vez.'); end if;
  apex_custom_auth.set_user(otro);
  begin lfo_cultivo_manual_edicion.corregir(registro,0,meta,45);
  exception when others then if sqlcode=-20210 then rechazado:=true; else raise; end if; end;
  if not rechazado then raise_application_error(-20975,'Se permitió editar una sesión ajena.'); end if;
  apex_custom_auth.set_user(u);
  lfo_cultivo_manual_edicion.corregir(registro,0,meta,45);
  select segundos into segundos from lfo_resumen_dia_v where dia_id=dia and categoria='CULTIVO';
  if segundos!=2700 then raise_application_error(-20976,'La corrección no actualizó el día.'); end if;
  lfo_cierre_diario.cerrar(dia,null);
  select segundos into segundos from lfo_cierre_dia_resumen where dia_id=dia and categoria='CULTIVO';
  if segundos!=2700 then raise_application_error(-20979,'El cierre no conserva el Cultivo manual.'); end if;
  rollback to pruebas_hoy;
  -- El día personal puede seguir abierto después de medianoche.
  if trunc(hoy-1,'IW')=semana then
    insert into lfo_dias_personales(persona,fecha_logica) values('BRI',hoy-1) returning id into dia;
    lfo_cultivo_nuevo.registrar_manual(meta,hoy-1,30);
    select count(*) into n from lfo_registros_cultivo r join lfo_cultivo_manual_dia x on x.registro_id=r.id
      where r.meta_id=meta and x.dia_id=dia and r.dia_logico=hoy-1;
    if n!=1 then raise_application_error(-20977,'La sesión no quedó en el día abierto anterior.'); end if;
    rechazado:=false;
    begin lfo_cultivo_nuevo.registrar_manual(meta,hoy,30);
    exception when others then if sqlcode=-20247 then rechazado:=true; else raise; end if; end;
    if not rechazado then raise_application_error(-20978,'Se aceptó una fecha distinta del día abierto.'); end if;
  end if;
  rollback to prueba_cultivo_hoy;
  apex_util.remove_preference('LFO_SEMANA',u); apex_session.delete_session(p_session_id=>sesion);
exception when others then
  if guardado then rollback to prueba_cultivo_hoy; end if;
  apex_util.remove_preference('LFO_SEMANA',u); if sesion is not null then apex_session.delete_session(p_session_id=>sesion); end if; raise;
end;
/
