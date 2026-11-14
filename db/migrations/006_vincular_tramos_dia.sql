-- Todo intervalo nuevo se vincula al día abierto de la persona autenticada.
-- Los intervalos anteriores sin dia_id se conservan sin reasignar.
create or replace trigger lfo_tramo_asignar_dia
before insert on lfo_reloj_tramos
for each row
declare
  v_persona lfo_reloj_persona.persona%type := lfo_persona_actual;
  v_dia lfo_dias_personales.id%type;
begin
  if :new.persona != v_persona then
    raise_application_error(-20120, 'El intervalo no pertenece a tu cuenta.');
  end if;
  v_dia := lfo_dias.abrir_o_actual;
  if :new.dia_id is not null and :new.dia_id != v_dia then
    raise_application_error(-20121, 'El intervalo no corresponde al día abierto.');
  end if;
  :new.dia_id := v_dia;
end;
/
