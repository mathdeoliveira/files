insert into dim_tempo
	(sk_tempo,
	data_completa,
	nr_ano,
	nr_mes,
	nm_mes,
	nr_dia_mes,
	nm_dia_semana,
	nr_dia_ano,
	nr_semana,
	data_formatada,
	nm_trimestre,
	nr_ano_trimestre,
	nr_ano_nr_mes,
	nr_ano_nr_semana,
	flag_tipo_dia_semana,
	flag_feriado_fixo,
	periodo_negocio,
	ultimo_dia_mes,
	etl_dt_inicio,
	etl_dt_fim,
	etl_versao
	) select
		0, --sk_tempo
		'1900-01-01', --data_completa
		-1, --nr_ano
		-1, --nr_mes
		'*** Não Informado ***', --nm_mes
		-1, --nr_dia_mes
		'*** Não Informado ***', --nm_dia_semana
		-1, --nr_dia_ano
		-1, --nr_semana
		'01/01/1900', --data_formatada
		'*** Não Informado ***', --nm_trimestre
		'1900/Q1', --nr_ano_trimestre 
		'1900/12', --nr_ano_nr_mes
		'1900/52', --nr_ano_nr_semana
		'*** Não Informado ***', --flag_tipo_dia_semana
		'*** Não Informado ***', --flag_feriado_fixo
		'*** Não Informado ***', --periodo_negocio
		'1900/01/01', --ultimo_dia_mes
		'1900/01/01', --etl_dt_inicio
		'2099/01/01', --etl_dt_fim
		1 --etl_versao
		where not exists 
				(select 1
				from dim_tempo
				where sk_tempo=0 );
insert into dim_tempo
	select
		to_char(datum, 'yyyymmdd'):: int4 as sk_tempo,
		to_char(datum, 'yyyy-mm-dd') as data_completa,
		extract(year from datum) as nr_ano,
		extract(month from datum) as nr_mes,
		to_char(datum, 'TMmonth') as nm_mes,
		extract(day from datum) as nr_dia_mes,
		to_char(datum, 'TMday') as nm_dia_semana,
		extract(doy from datum) as nr_dia_ano,
		extract(week from datum) as nr_semana,
		to_char(datum, 'dd/mm/yyyy') as data_formatada,
		'T' || to_char(datum, 'Q') as nm_trimestre,
		to_char(datum, 'yyyy/"T"Q') as nr_ano_trimestre,
		to_char(datum, 'yyyy/mm') as nr_ano_nr_mes,
		to_char(datum, 'iyyy/IW') as nr_ano_nr_semana,
		case when extract(isodow from datum) in (6, 7) then 'Fim de Semana' else 'Dia de Semana' end as flag_tipo_dia_semana,
	--feriados fixos
	        case when to_char(datum, 'mmdd') in ('0101', '0704', '1225')
	        then 'Feriado' else 'Não Feriado' end
	        as flag_feriado_fixo,	
		-- periodos importantes para o negócio
		case when to_char(datum, 'mmdd') between '0601' and '0831' then 'Temporada de Inverno'
		 when to_char(datum, 'mmdd') between '1115' and '1225' then 'Temporada de Natal'
		 when to_char(datum, 'mmdd') > '1225' or to_char(datum, 'mmdd') <= '0106' then 'Temporada de Verão'
			else 'Normal' end
			as periodo_negocio,	
		(datum + (1 - extract(day from datum))::integer + '1 month'::interval)::date - '1 day'::interval as ultimo_dia_mes,
		current_timestamp as etl_dt_inicio,       -- controle pdi --
		'2099/01/01' as etl_dt_fim,
		1 as etl_versao                            -- controle pdi --
	from (
		-- data inicial da carga 
		select '2018-01-01'::date + sequence.day as datum
		from generate_series(0,3652) as sequence(day)
		group by sequence.day
	     ) dq
	order by 1;

-- Atualiza NM_MES para pt_BR
UPDATE dim_tempo SET nm_mes='Janeiro' WHERE nm_mes='january';
UPDATE dim_tempo SET nm_mes='Fevereiro' WHERE nm_mes='february';
UPDATE dim_tempo SET nm_mes='Março' WHERE nm_mes='march';
UPDATE dim_tempo SET nm_mes='Abril' WHERE nm_mes='april';
UPDATE dim_tempo SET nm_mes='Maio' WHERE nm_mes='may';
UPDATE dim_tempo SET nm_mes='Junho' WHERE nm_mes='june';
UPDATE dim_tempo SET nm_mes='Julho' WHERE nm_mes='july';
UPDATE dim_tempo SET nm_mes='Agosto' WHERE nm_mes='august';
UPDATE dim_tempo SET nm_mes='Setembro' WHERE nm_mes='september';
UPDATE dim_tempo SET nm_mes='Outubro' WHERE nm_mes='october';
UPDATE dim_tempo SET nm_mes='Novembro' WHERE nm_mes='november';
UPDATE dim_tempo SET nm_mes='Dezembro' WHERE nm_mes='december';
-- Atualiza nm_dia_semana para pt_BR
UPDATE dim_tempo SET nm_dia_semana='Segunda-feira' WHERE nm_dia_semana='monday';
UPDATE dim_tempo SET nm_dia_semana='Terça-feira' WHERE nm_dia_semana='tuesday';
UPDATE dim_tempo SET nm_dia_semana='Quarta-feira' WHERE nm_dia_semana='wednesday';
UPDATE dim_tempo SET nm_dia_semana='Quinta-feira' WHERE nm_dia_semana='thursday';
UPDATE dim_tempo SET nm_dia_semana='Sexta-feira' WHERE nm_dia_semana='friday';
UPDATE dim_tempo SET nm_dia_semana='Sábado' WHERE nm_dia_semana='saturday';
UPDATE dim_tempo SET nm_dia_semana='Domingo' WHERE nm_dia_semana='sunday';
