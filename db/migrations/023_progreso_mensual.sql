-- Solo se promedian semanas con ambas confirmaciones vigentes.
create or replace view lfo_semanas_comparables_v as
select semana_inicio from lfo_estado_cierres_semanales_v
group by semana_inicio
having count(*)=2 and count(distinct persona)=2 and sum(case when vigente='S' then 1 else 0 end)=2;
/
create or replace view lfo_progreso_mensual_v as
with base as (
  select trunc(c.semana_inicio,'MM') mes_inicio,c.persona,count(*) semanas_comparables,
         avg(c.puntos_total) promedio
  from lfo_estado_cierres_semanales_v c
  join lfo_semanas_comparables_v s on s.semana_inicio=c.semana_inicio
  group by trunc(c.semana_inicio,'MM'),c.persona
)
select mes_inicio,persona,semanas_comparables,
       floor((last_day(mes_inicio)-(trunc(mes_inicio,'IW')+
         case when trunc(mes_inicio,'IW')<mes_inicio then 7 else 0 end))/7)+1 semanas_del_mes,
       promedio,round(promedio) puntos_mensuales
from base;
/
begin
  execute immediate q'[
    create table lfo_premios_mensuales (
      persona varchar2(4 char) not null,
      mes_inicio date not null,
      premio varchar2(500 char),
      actualizado_en timestamp with time zone default systimestamp not null,
      constraint lfo_premios_mes_pk primary key (persona,mes_inicio),
      constraint lfo_premios_mes_persona_ck check (persona in ('BRI','FACU')),
      constraint lfo_premios_mes_fecha_ck check (mes_inicio=trunc(mes_inicio,'MM'))
    )
  ]';
exception when others then if sqlcode != -955 then raise; end if;
end;
/
create or replace package lfo_premios_mensuales_api authid definer as
  procedure guardar(p_mes_esperado date,p_premio varchar2);
end lfo_premios_mensuales_api;
/
create or replace package body lfo_premios_mensuales_api as
  procedure guardar(p_mes_esperado date,p_premio varchar2) is
    v_persona varchar2(4):=lfo_persona_actual;
    v_mes date:=to_date(nvl(apex_util.get_preference('LFO_MES',v('APP_USER')),
      to_char(trunc(cast(systimestamp at time zone 'America/Argentina/Buenos_Aires' as date),'MM'),'YYYY-MM-DD')),'FXYYYY-MM-DD');
    v_premio varchar2(32767):=trim(p_premio);
  begin
    if v_mes!=trunc(v_mes,'MM') or p_mes_esperado is null or p_mes_esperado!=v_mes then
      raise_application_error(-20230,'Cambió el mes seleccionado. Volvé a abrir el recuento.');
    end if;
    if length(v_premio)>500 then raise_application_error(-20231,'El premio puede tener hasta 500 caracteres.'); end if;
    merge into lfo_premios_mensuales p using (select v_persona persona,v_mes mes_inicio from dual) n
    on (p.persona=n.persona and p.mes_inicio=n.mes_inicio)
    when matched then update set p.premio=v_premio,p.actualizado_en=systimestamp
    when not matched then insert(persona,mes_inicio,premio) values(n.persona,n.mes_inicio,v_premio);
  end;
end lfo_premios_mensuales_api;
/
