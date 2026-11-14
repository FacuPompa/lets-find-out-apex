-- Objetivos de horas por persona y semana. No modifica registros existentes.
begin
  execute immediate q'[
    create table lfo_objetivos_horas (
      persona varchar2(4 char) not null,
      semana_inicio date not null,
      categoria varchar2(12 char) not null,
      horas_objetivo number,
      constraint lfo_obj_horas_pk primary key (persona, semana_inicio, categoria),
      constraint lfo_obj_persona_ck check (persona in ('BRI','FACU')),
      constraint lfo_obj_semana_ck check (semana_inicio = trunc(semana_inicio,'IW')),
      constraint lfo_obj_categoria_ck check (categoria in ('TRABAJO','ESTUDIO','OCIO','CULTIVO')),
      constraint lfo_obj_horas_ck check (horas_objetivo is null or horas_objetivo > 0)
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
create or replace package lfo_objetivos_horas_api authid definer as
  procedure guardar(p_trabajo number, p_estudio number, p_ocio number, p_cultivo number, p_semana_esperada date);
end lfo_objetivos_horas_api;
/
create or replace package body lfo_objetivos_horas_api as
  procedure guardar(p_trabajo number, p_estudio number, p_ocio number, p_cultivo number, p_semana_esperada date) is
    v_persona varchar2(4) := lfo_persona_actual;
    v_semana date := to_date(nvl(apex_util.get_preference('LFO_SEMANA', v('APP_USER')),
      to_char(trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date), 'IW'), 'YYYY-MM-DD')), 'FXYYYY-MM-DD');
    procedure poner(p_categoria varchar2, p_horas number) is
    begin
      if p_horas is not null and p_horas <= 0 then
        raise_application_error(-20160, 'Las horas deben ser mayores que cero; dejá vacío si no tenés objetivo.');
      end if;
      merge into lfo_objetivos_horas o
      using (select v_persona persona, v_semana semana_inicio, p_categoria categoria, p_horas horas from dual) n
      on (o.persona = n.persona and o.semana_inicio = n.semana_inicio and o.categoria = n.categoria)
      when matched then update set o.horas_objetivo = n.horas
      when not matched then insert (persona, semana_inicio, categoria, horas_objetivo)
        values (n.persona, n.semana_inicio, n.categoria, n.horas);
    end;
  begin
    if v_semana != trunc(v_semana, 'IW') then raise_application_error(-20161, 'La semana seleccionada no es válida.'); end if;
    if p_semana_esperada is null or p_semana_esperada != v_semana then
      raise_application_error(-20162, 'Cambió la semana seleccionada. Volvé a abrir los objetivos y revisalos.');
    end if;
    if (p_trabajo is not null and p_trabajo <= 0) or (p_estudio is not null and p_estudio <= 0)
       or (p_ocio is not null and p_ocio <= 0) or (p_cultivo is not null and p_cultivo <= 0) then
      raise_application_error(-20160, 'Las horas deben ser mayores que cero; dejá vacío si no tenés objetivo.');
    end if;
    poner('TRABAJO', p_trabajo);
    poner('ESTUDIO', p_estudio);
    poner('OCIO', p_ocio);
    poner('CULTIVO', p_cultivo);
  end;
end lfo_objetivos_horas_api;
/
create or replace view lfo_progreso_horas_v as
with horas as (
  select persona, trunc(fecha_logica,'IW') semana_inicio, categoria, sum(segundos) segundos
  from lfo_resumen_dia_v group by persona, trunc(fecha_logica,'IW'), categoria
)
select coalesce(o.persona,h.persona) persona,
       coalesce(o.semana_inicio,h.semana_inicio) semana_inicio,
       coalesce(o.categoria,h.categoria) categoria,
       o.horas_objetivo, nvl(h.segundos,0) segundos
from lfo_objetivos_horas o full outer join horas h
  on h.persona=o.persona and h.semana_inicio=o.semana_inicio and h.categoria=o.categoria;
