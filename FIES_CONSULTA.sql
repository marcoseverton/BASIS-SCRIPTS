/**
 script consulta sysfies
 @author Marcelo Amaral <mailto: mldo@indracompany.com>
**/	


-- CONSULTA PARA RETORNAR O ADITAMENTO DE TRANSFERENCIA
SELECT * FROM inscricao.tb_fies_aditamento AS a
 INNER JOIN inscricao.tb_fies_usuario_inscricao AS ui ON ui.co_usuario_inscricao = a.co_usuario_inscricao
 INNER JOIN inscricao.tb_fies_inscricao AS i ON i.co_inscricao = a.co_inscricao
 INNER JOIN integracao.tb_fies_orgao_expedidor AS oe ON a.co_orgao_expedidor = oe.co_orgao_expedidor
 INNER JOIN inscricao.tb_fies_ocupacao AS o ON o.co_ocupacao = a.co_ocupacao
 INNER JOIN inscricao.tb_fies_estado_civil AS ec ON ec.co_estado_civil = a.co_estado_civil
 INNER JOIN inscricao.tb_fies_raca_cor AS rc ON rc.sg_raca_cor = a.sg_raca_cor
 LEFT JOIN inscricao.tb_fies_tipo_deficiencia AS td ON td.co_tipo_deficiencia = a.co_tipo_deficiencia
 INNER JOIN inscricao.tb_fies_finalidade_aditamento AS fa ON fa.co_finalidade_aditamento = a.co_finalidade_aditamento
 INNER JOIN inscricao.tb_fies_curso_associado_aditamento AS ca ON ca.co_curso_associado_aditamento = a.co_curso_associado_aditamento
 INNER JOIN inscricao.tb_fies_situacao_aditamento AS sa ON sa.co_situacao_aditamento = a.co_situacao_aditamento
 INNER JOIN inscricao.tb_fies_banco_inscricao AS ba ON i.co_banco = ba.co_banco WHERE (a.co_aditamento = 6353131) AND (a.co_inscricao =3378320) ORDER BY a.co_aditamento desc;


--inscrição "aluno modelo: 00000200018 - VERIDIANE CRISTINA ZACARIA" CEF
--inscrição "aluno modelo: 00000632155 - DANIELLE LIMA DE BRITO FERREIRA" BB

--usuario_inscricao
select * from inscricao.tb_fies_usuario_inscricao where nu_cpf = '01057445819';

--fases do contrato
select * from inscricao.tb_fies_fases_do_contrato where nu_cpf = '03597224156'

-- CHAVE DE AUTENTICACAO
select * from public.tb_fies_chave_autenticacao where nu_cpf = '06802021617' and tp_chave= 4 order by dt_chave

update inscricao.tb_fies_aditamento
    set dt_aprovacao_aditamento = '2019-03-25 08:56:43.000',
    dt_validacao_cpsa = '2019-03-25 08:56:43.000'
where nu_cpf = '06802021617' and co_aditamento = 18347909;

-- CONSULTA FIADOR BLOQUEIO ALTERACAO RENDA
SELECT DISTINCT ON (fa.nu_cpf)
  fa.nu_cpf,
  fa.nu_cpf_conjuge,
  a.co_inscricao,
  fa.co_aditamento
FROM inscricao.vw_fies_fiador_aditamento AS fa
  INNER JOIN inscricao.tb_fies_aditamento a
    ON fa.co_aditamento = a.co_aditamento
       AND a.co_situacao_aditamento = 49
       AND a.co_finalidade_aditamento NOT IN (6)
WHERE ((fa.nu_cpf = '48216720149') OR (fa.nu_cpf_conjuge = '48216720149'))
      AND a.co_semestre_aditamento = (
  SELECT max(co_semestre_aditamento)
  FROM inscricao.tb_fies_aditamento ad3
  WHERE a.co_inscricao = ad3.co_inscricao
        AND ad3.co_situacao_aditamento = 49
        AND ad3.co_finalidade_aditamento NOT IN (6)
  GROUP BY ad3.co_inscricao
)
      AND a.co_inscricao <> '4362912';


--log usuario_inscricao
select case
		when tp_log = 'I' then tp_log||'-'||'Inclusão'
		when tp_log = 'A' then tp_log||'-'||'Alteração'
		when tp_log = 'E' then tp_log||'-'||'Exclusão'
	else	tp_log
	end tp_log,
	ui.* 
from 	auditoria.vw_lg_fies_usuario_inscricao ui
where 	nu_cpf = '10284681644' 
order 	by dt_
 

--inscrição
select ui.no_usuario,i.nu_cpf,i.nu_semestre_referencia,i.co_situacao_inscricao||'-'||si.ds_situacao_inscricao situacao,b.no_banco,
	i.nu_cep,i.co_uf||'-'||uf.ds_uf estado,i.ds_logradouro,i.ds_bairro,i.ds_numero,i.co_cidade,
	tf.dt_limite_cpsa,tf.dt_limite_contratacao,tf.dt_limite_retorno_agente_financ,i.*
from	inscricao.tb_fies_inscricao i,
       inscricao.tb_fies_termo_financiamento tf,
       inscricao.tb_fies_usuario_inscricao ui,
       inscricao.tb_fies_situacao_inscricao si,
       inscricao.tb_fies_banco_inscricao b,
       tb_cdst_uf uf 
where	i.co_banco = b.co_banco
	and i.co_situacao_inscricao = si.co_situacao_inscricao
	and ui.nu_cpf = i.nu_cpf
	and tf.co_inscricao = i.co_inscricao
	and to_char(lpad(i.co_uf::numeric,15,0)) = uf.co_uf
	and i.nu_cpf in ('03112574028')
	--and i.nu_cpf = to_char(lpad('958263',11,0))
	--and i.co_inscricao = 1382626
	--and i.co_situacao_inscricao = 1
order 	by substring(nu_semestre_referencia from 2 for 4),
	substring(nu_semestre_referencia from 1 for 1),
	ui.no_usuario;

select ui.no_usuario,i.* 
from 	inscricao.tb_fies_inscricao i
inner 	join inscricao.tb_fies_usuario_inscricao ui using(nu_cpf)
where 	i.nu_cpf = '47015842823'		

		-- CO_PARTICIPACAO
            select nu_percentual_prouni, vl_semestre_atual, vl_financiado_semestre, 
            (vl_semestre_atual * (nu_percentual_prouni / 100) ) - vl_financiado_semestre::NUMERIC(12,2) as co_participacao, 
            * from 
            inscricao.tb_fies_termo_financiamento t,
            inscricao.tb_fies_inscricao i
             where i.co_inscricao = 5425592
             and i.co_inscricao = t.co_inscricao;

--log inscricao
select case
		when i.tp_log = 'I' then i.tp_log||'-'||'Inclusão'
		when i.tp_log = 'A' then i.tp_log||'-'||'Alteração'
		when i.tp_log = 'E' then i.tp_log||'-'||'Exclusão'
	else	i.tp_log
	end tp_log,
	ui.no_usuario,i.nu_cpf,i.nu_semestre_referencia,i.co_situacao_inscricao||'-'||si.ds_situacao_inscricao situacao,i.co_banco||'-'||bco.no_banco banco,
	i.dt_aceite_fgeduc,i.dt_aceite_fianca_solidaria,i.* 
from 	auditoria.vw_lg_fies_inscricao i
inner	join inscricao.tb_fies_situacao_inscricao si using(co_situacao_inscricao)
inner	join inscricao.tb_fies_usuario_inscricao ui using(nu_cpf)
inner	join inscricao.tb_fies_banco_inscricao bco using(co_banco)
where 	i.nu_cpf = '01727011120'
	--and i.co_inscricao = 1403648
order 	by i.dt_log_alteracao;

--verificar recurso
select * from tb_fies_adesao where nu_cnpj  = '04236516000190'
select * from tb_fies_valor_adesao where co_adesao  = 129
select * from auditoria.vw_lg_fies_valor_adesao where co_adesao  = 129 order by nu_ano_exercicio, dt_log_alteracao

--aditamento
select ui.no_usuario,a.nu_semestre_referencia semestre_ano,
	a.co_situacao_aditamento||'-'||sa.ds_situacao_aditamento situacao,a.co_aditamento,
	(a.vl_semestre_com_desconto*(a.nu_percent_solicitado_financ/100))::decimal(12,2) vr_semestre_com_desconto,
	a.vl_financiado_semestre,a.nu_percent_solicitado_financ,a.st_bolsista_prouni||'-'||a.nu_percentual_prouni prouni,
	case when a.tp_aditamento = 'S' then a.tp_aditamento||'-'||'Simplificado'
            when a.tp_aditamento = 'N' then a.tp_aditamento||'-'||'Não Simplificado'
            else 'outros'
       end as tp_aditamento,
	a.co_finalidade_aditamento||'-'||fa.ds_finalidade_aditamento finalidade_aditamento,
	a.vl_semestre_com_desconto,a.vl_financiado_semestre,
       a.co_tipo_fianca||'-'||tf.ds_tipo_fianca tipo_fianca,
       ins.co_banco||'-'||bco.no_banco banco,
       a.co_uf||'-'||uf.sg_uf uf,
       a.*
from	inscricao.tb_fies_aditamento a,
	inscricao.tb_fies_situacao_aditamento sa,
	inscricao.tb_fies_usuario_inscricao ui,
	inscricao.tb_fies_tipo_fianca tf,
	inscricao.tb_fies_finalidade_aditamento fa,
	inscricao.tb_fies_inscricao ins,
	inscricao.tb_fies_banco_inscricao bco,
	tb_cdst_uf uf
	
where	a.co_situacao_aditamento = sa.co_situacao_aditamento
	and a.nu_cpf = ui.nu_cpf
	and a.co_tipo_fianca = tf.co_tipo_fianca
	and a.co_finalidade_aditamento = fa.co_finalidade_aditamento
	and a.nu_cpf = ins.nu_cpf
	and ins.co_banco = bco.co_banco
	and a.co_uf = uf.co_uf::decimal
	and a.nu_cpf in ('03112574028')
	--and a.nu_semestre_referencia = '12011'
	--and a.co_situacao_aditamento <> 49
order	by ui.no_usuario,
	   a.co_semestre_aditamento,
	   a.dt_inclusao;


	   
--Aditamento extemporâneo
select sa.nu_semestre_referencia,ex.* 
from 	inscricao.tb_fies_aditamento_extemporaneo ex, 
	inscricao.tb_fies_semestre_aditamento sa
where 	ex.co_semestre_aditamento = sa.co_semestre_aditamento
	and ex.co_inscricao = 5040798 
order 	by ex.co_semestre_aditamento
--update inscricao.tb_fies_aditamento_extemporaneo set dt_prazo_solicitacao_cpsa = now()::date + 1  where co_inscricao = 1827463 and co_semestre_aditamento = 53

--aditamento não simplificado: o proximo aditamento vai ser não simplificado
select * from inscricao.tb_fies_aditamento_nao_simp_obrigatorio


--encerramento
select ui.no_usuario,se.ds_situacao_encerramento,nu_mes_encerramento,dt_limite_retorno_af, e.* 
  from inscricao.tb_fies_encerramento e,
       inscricao.tb_fies_situacao_encerramento se,
       inscricao.tb_fies_usuario_inscricao ui,
       inscricao.tb_fies_inscricao i
 where e.co_situacao_encerramento = se.co_situacao_encerramento
   and e.co_inscricao = i.co_inscricao
   and i.nu_cpf = ui.nu_cpf
   --and e.co_situacao_encerramento = 6
   and e.co_inscricao in (select co_inscricao from inscricao.tb_fies_inscricao where nu_cpf = '14380155773')
order by se.ds_situacao_encerramento;



--log encerramento
select nu_mes_encerramento,dt_limite_retorno_af,* 
  from auditoria.vw_lg_fies_encerramento
 where co_inscricao = 1539038
 order by dt_log_alteracao;

--suspensão
select i.nu_cpf,
       ui.no_usuario,
       s.nu_semestre_referencia,
       ss.ds_situacao_suspensao, 
       s.co_curso,s.co_turno,s.co_mantenedora,s.co_ies,s.co_campus,s.*
from 	inscricao.tb_fies_suspensao s,
       inscricao.tb_fies_situacao_suspensao ss,
       inscricao.tb_fies_inscricao i,
       inscricao.tb_fies_usuario_inscricao ui
where 	i.nu_cpf = ui.nu_cpf
	and s.co_inscricao = i.co_inscricao
	and s.co_situacao_suspensao = ss.co_situacao_suspensao
	and s.co_inscricao in (select co_inscricao from inscricao.tb_fies_inscricao where nu_cpf in ('93678223672'))
	--and s.co_situacao_suspensao = 8
order	by s.co_semestre_aditamento

--log suspensão
select ss.ds_situacao_suspensao, s.* 
  from auditoria.vw_lg_fies_suspensao s,
       inscricao.tb_fies_situacao_suspensao ss
 where s.co_situacao_suspensao = ss.co_situacao_suspensao
   and s.co_inscricao = 2970373  
   and s.co_suspensao = 248981
   order by s.dt_log_alteracao; 

--dilatação
select d.nu_semestre_inicio, d.nu_semestre_fim, sd.ds_situacao_dilatacao, d.*
  from inscricao.tb_fies_dilatacao d,
       inscricao.tb_fies_situacao_dilatacao sd
 where d.co_situacao_dilatacao = sd.co_situacao_dilatacao 
   and d.co_inscricao in (select co_inscricao from inscricao.tb_fies_inscricao where nu_cpf in ('07993339642'));

--comprovantes de impressão de DRI e DRM
select *
  from inscricao.tb_fies_comprovante 
 where co_inscricao in (SELECT co_inscricao from inscricao.tb_fies_inscricao where nu_cpf in ('11301062766'))
	and co_aditamento = 6698883
order by 2,4;

--termo de financiamento
select * 
from 	inscricao.tb_fies_termo_financiamento 
where 	co_inscricao =(	select co_inscricao 
				from 	inscricao.tb_fies_inscricao 
				where 	nu_cpf = '00495028088'
			)
-- log
select qt_semestre_financiamento,* from auditoria.vw_lg_fies_termo_financiamento where co_inscricao = 2441255 order by dt_log_alteracao

--enem
select * from inscricao.tb_fies_enem where nu_cpf = '38961038818'

--curso associado
select * 
from 	inscricao.tb_fies_curso_associado 
where 	nu_cpf in ('33753840840')
order	by 2

--log curso associado
select * from auditoria.lg_fies_curso_associado where nu_cpf = '112008';

--curso associado aditamento   
select co_aditamento,* 
  from inscricao.tb_fies_curso_associado_aditamento 
 where nu_cpf in ('01727011120')
 order by 3,dt_inclusao
 
--log curso associado aditamento
select * from auditoria.vw_lg_fies_curso_associado_aditamento where nu_cpf = '00130896098' order by dt_log_alteracao

--agencia A.F. e IES
select * from tb_fies_agencias_cef where co_agencia = 1050

--mantenedora
select no_razao_social,nu_cnpj,* 
from	emec_cadastro.vw_cdst_fies_mantenedora 
where	co_mantenedora = 2281


-- CONSULTA RESTRIÇAO MANTENEDORA
select * from tb_fies_suspensao_adesao where co_adesao = (select co_adesao from tb_fies_adesao where co_mantenedora = 1711);

select a.co_mantenedora, 
nu_ano_exercicio, nu_cnpj, ds_razao_social,
co_restricao_adesao, dt_inicio_restricao, 
dt_termino_restricao, ds_motivo_restricao,
* from tb_fies_restricao_adesao r,
tb_fies_adesao a where 
a.co_mantenedora = r.co_mantenedora and
a.co_mantenedora = 1711 
order by dt_termino_restricao desc limit 1;

select * from tb_fies_situacao_adesao 

select * from tb_fies_adesao where co_mantenedora = 1711
   
--ies
select * 
from	emec_cadastro.vw_cdst_fies_ies  
where	co_ies = 339

--campus
select * from emec_cadastro.vw_cdst_fies_campus where co_campus = 9522

--curso emec
select co_curso,co_turno,co_mantenedora,co_ies,co_campus,no_curso,
	ds_turno,ds_condicao_funcionamento,st_gratuito,st_vinculo_ativo_emec,nu_periodicidade
from 	vw_fies_curso 
where 	co_curso =  1110563
	and co_turno = 10070
	and co_mantenedora = 445
	and co_ies = 4429
	--and co_campus = 1056379

select co_ies, co_curso, no_curso, co_turno, ds_turno, ds_condicao_funcionamento, co_campus, co_mantenedora, st_gratuito, st_vinculo_ativo_emec 
from 	emec_cadastro.vw_cdst_fies_curso 
where 	co_curso = 21741

select * from emec_cadastro.vw_cdst_fies_inscricao_curso where co_curso = 116818 and co_turno = 10070;

select co_ies, co_curso, no_curso, co_turno, ds_turno, ds_condicao_funcionamento, co_campus, co_mantenedora, st_gratuito, st_vinculo_ativo_emec,dt_log_alteracao,*
from 	auditoria.vw_lg_vw_cdst_fies_curso 
where 	co_curso = 1110563
	and co_mantenedora = 770
	and co_turno = 10067
order 	by dt_log_alteracao;

select * from emec_cadastro.tb_fies_historico_curso_emec where co_curso = 116818;

select * from public.vw_fies_curso_base_emec where co_curso = 116818

--mantenedora, ies e curso
select u.no_usuario,
       c.no_curso,
       c.ds_turno,
       ca.* 
  from inscricao.tb_fies_curso_associado ca,
       inscricao.tb_fies_usuario_inscricao u,
       vw_fies_curso c
 where ca.co_curso = c.co_curso
   and ca.co_turno = c.co_turno
   and ca.nu_cpf = u.nu_cpf 
   and ca.co_ies = 242
   and ca.nu_cpf in ('10511072880');

--localizar membro da cpsa
SELECT *
FROM	tb_fies_membro_cpsa
WHERE	co_cpsa = (
			SELECT co_cpsa
			FROM	tb_fies_cpsa
			WHERE co_campus = 704450
			)
AND	dt_termino_representacao is null

-- verificar se o banco(CAIXA) nos enviou contratação ou derrubada de inscricao
select st_contratacao, ds_motivo_situacao,
	case 
		when nu_tipo_garantia_fk21 in (1,3) then 'CONVENCIONAL'
		when nu_tipo_garantia_fk21 in (77) then 'FGEDUC'
		when nu_tipo_garantia_fk21 in (88) then 'SOLIDARIA'
		ELSE 'sem tipo garantia'
	end::varchar as tp_fianca,
	nu_semestre_contratacao||'/'||nu_ano_contratacao semestre_ano,
	dt_inclusao_registro,
	*
  from integracao.tb_fies_importa_contrato_fies
 where co_cpf in ('51362678520')
 order by co_cpf,dt_inclusao_registro desc;
 
 -- VERIFICAR ARQUIVO DE CONTRATAÇÃO DE INSCRIÇAO DOS ESTUDANTES
 select nu_cpf,co_inscricao,st_contratacao,dt_inclusao_registro,dt_assinatura,nu_semestre_referencia,
* from (
select  
(select co_arquivo_recebido from 
       integracao.tb_fies_importa_contrato_fies 
       where co_cpf = c.nu_cpf order by dt_inclusao_registro desc limit 1),co_tipo_fianca,*
from inscricao.tb_fies_inscricao c  ) x
inner join  integracao.tb_fies_importa_contrato_fies f on f.co_cpf = x.nu_cpf and f.co_arquivo_recebido = x.co_arquivo_recebido
where nu_cpf in ('60516532367' ,'98681109120','05129081501','11011937603');


-- verificar se o banco(BB) nos enviou contratação ou derrubada de inscricao
select *
from 	integracao.tb_fies_importa_contrato_fies_bb
where 	nu_cpf in ('13590946792')
order 	by dt_inclusao_registro desc;

-- verifica se o banco(CAIXA) nos enviou contratação ou derrubada de aditamento de renovação
select co_cpf,
	ltrim(nu_sem_aditamento,0)|| '/' ||aa_aditamento semestre_ano,
	nu_aditamento_fies,
	st_aditamento||' - '||
	case
		when st_aditamento in ('C','S') then 'CONTRATADO'
		WHEN st_aditamento = 'N' then 'NÃO CONTRATADO'
		else 'SEM IDENTIFICAÇÃO'
	end st_aditamento,
	ds_motivo_situacao,
	dt_inclusao_registro,
	vr_aditamento,
	co_arquivo_recebido,*	
from	integracao.tb_fies_importa_aditamento
where	co_cpf = '00347020089'
	--and trim(nu_aditamento_fies) in ('3626938','00003626938')
order by 
	aa_aditamento::numeric,
	nu_sem_aditamento::numeric, 
	dt_inclusao_registro desc;
	
	
	
	

-- verifica se o banco(bb) nos enviou contratação ou derrubada de aditamento de renovação
select ia.ds_tipo_liminar,ui.no_usuario, ia.*
  from integracao.tb_fies_importa_aditamento_bb ia,
       inscricao.tb_fies_usuario_inscricao ui 
 where ia.nu_cpf = ui.nu_cpf
   and ia.nu_cpf in ('39114613808')
   --and ia.co_aditamento = lpad(05076525338,11,0)
   --and ia.co_aditamento in ('00005264787','00005163418','00005258074')
   --and co_motivo_situacao = '0000'
order by ui.no_usuario

      
--verificar se o banco(CAIXA) nos enviou contratação ou derrubada de suspensão ou encerramento.
select * from integracao.tb_fies_importa_ocorrencia_contrato_cef where co_cpf in ('00400014076') order by dt_inclusao_registro;

--verificar se o banco(BB) nos enviou contratação ou derrubada de suspensão ou encerramento.
select ui.no_usuario, ioc_bb.co_cpf, ioc_bb.co_ocorrencia, ioc_bb.ic_situacao_ocorrencia, ioc_bb.co_motivo_situacao, 
	ioc_bb.nu_semestre_referencia || '/' || ioc_bb.nu_ano_referencia sem_ano_referencia, ioc_bb.dt_inclusao_registro, 
	ar.no_arquivo,
	ioc_bb.*
from 	integracao.tb_fies_importa_ocorrencia_contrato_bb ioc_bb,
	inscricao.tb_fies_usuario_inscricao ui,
	integracao.tb_fies_arquivo_recebido ar
where 	ioc_bb.co_cpf = ui.nu_cpf
	and ioc_bb.co_arquivo_recebido = ar.co_arquivo_recebido
	and ioc_bb.co_cpf in ('09709915410')
order	by ioc_bb.dt_inclusao_registro


-- CRITTICAS PARA O ADITAMENTO DE RENOVAÇÃO BB
-- CRITTICAS PARA O ADITAMENTO DE RENOVAÇÃO BB
WITH myconstants 

(aditamento) as (

   values (19081785)

)
SELECT substring (nu_cpf, 4, 11) co_aditamento, nu_sequencial, co_identificacao_registro, co_critica, ds_complemento_critica, 
       co_arquivo_recebido, dt_inclusao_registro, co_chave_id_registro, 
       nu_cpf as co_aditamento
  FROM integracao.tb_fies_importa_critica_retorno 
where nu_cpf = lpad((SELECT aditamento FROM myconstants limit 1),11,0) 
order by dt_inclusao_registro;

--Encerramento
select * from inscricao.tb_fies_encerramento where co_encerramento = 86015

--ocorrencia legado
select * from integracao.tb_fies_importa_ocorrencia_contrato where co_cpf = '00400014076';	

--Criticas do A.F. para o sisFIES
select * from integracao.tb_fies_importa_critica_retorno where nu_cpf = to_char(lpad('00400014076',11,0)) order by dt_inclusao_registro desc;

--Criticas do SisFIES para o A.F.
select co_critica,ds_observacao,* from integracao.tb_fies_acompanha_arq_recebido where co_id_registro like '%06030470175%' order by dt_inclusao desc

select *
from 	integracao.tb_fies_acompanha_arq_recebido 
where 	substring(co_id_registro from 8 for 11) in ('00400014076')
order 	by dt_inclusao

select * from integracao.tb_fies_critica where co_critica = 6

-- controle critica vala
select * from integracao.tb_fies_controle_critica_vala where nu_cpf  in ('05703135621','31903815851','00501515178','05302199645')
insert 	into integracao.tb_fies_controle_critica_vala 
		( 
			co_critica,
			co_aditamento,
			nu_cpf,
			co_inscricao,
			dt_inclusao,
			dt_limite_comparecimento_banco
		)
values	(
			'050'::varchar(3),
			rec.co_aditamento,
			rec.nu_cpf,
			rec.co_inscricao,
			current_timestamp,
			inscricao.fn_fies_soma_dias_uteis(now()::date,15)
		);

--periodo de inicio e termino dos semestres de renovação, encerramento, suspensão e dilatação
select * from inscricao.tb_fies_semestre_aditamento order by co_semestre_aditamento;

--impedir que estes estudantes prosseguissem a inscrição
select * from inscricao.tb_fies_correcao_bloqueio_cpsa where nu_cpf = '02078717525';

-- BLOQUEIO INSCRIÇÃO
SELECT SEMESTRE, TIPO_USUARIO, CPF_ALUNO, ESTUDANTE,
	CASE
		WHEN QT_SEMESTRE_CONCLUIDO >0 AND TP_USUARIO::INT= 2 THEN 'VAGA REMANESCENTE COM SEMESTRES JÁ CONCLUIDOS'
		WHEN TP_USUARIO::INT = 2 AND CO_SEM_POSTERGACAO = CO_SEM_SEGUINTE THEN 'JA HOUVE PRORROGACAO ANTERIOR NO MODO REGULAR'
	ELSE 'NÃO SE APLICA'
	END DS_MOTIVO_BLOQUEIO_PRORROGACAO
FROM (
	SELECT  I.CO_INSCRICAO INSCRICAO, NO_USUARIO AS ESTUDANTE,
	I.NU_CPF CPF_ALUNO, TF.QT_SEMESTRE_CONCLUIDO, I.TP_USUARIO,
	CASE 
	  WHEN TP_USUARIO::INT = 1 THEN 'REGULAR'	  
	  WHEN TP_USUARIO::INT = 2 THEN 'REMANESCENTE'
	END TIPO_USUARIO,
	 I.NU_SEMESTRE_REFERENCIA AS SEMESTRE,
	(S.CO_SEMESTRE_ADITAMENTO+1) CO_SEM_SEGUINTE, P.CO_SEMESTRE_ADITAMENTO AS CO_SEM_POSTERGACAO
	FROM INSCRICAO.TB_FIES_INSCRICAO I
	LEFT JOIN INSCRICAO.TB_FIES_TERMO_FINANCIAMENTO TF ON TF.CO_INSCRICAO = I.CO_INSCRICAO 
	LEFT JOIN INSCRICAO.TB_FIES_PERGUNTA_INSC_PRORROGA P ON P.CO_INSCRICAO = I.CO_INSCRICAO
	INNER JOIN INSCRICAO.TB_FIES_SEMESTRE_ADITAMENTO S ON I.NU_SEMESTRE_REFERENCIA = S.NU_SEMESTRE_REFERENCIA 
	left join INSCRICAO.TB_FIES_USUARIO_INSCRICAO U ON U.NU_CPF = I.NU_CPF
	WHERE I.CO_INSCRICAO = TF.CO_INSCRICAO
) WHERE INSCRICAO IN (6604729, 6558759);



--impedir a geração de arquivo de inscricao.
select * from inscricao.tb_fies_bloqueio_expiracao_inscricao where co_inscricao = 168261

--cpsa impede aditamento
select mba.ds_motivo_bloqueio,abc.* 
from	inscricao.tb_fies_aditamento_bloqueio_cpsa abc,
	inscricao.tb_fies_motivo_bloqueio_aditamento mba
where	abc.co_motivo_bloqueio = mba.co_motivo_bloqueio
	and abc.co_inscricao = 231560

	
 --inadimplentes do CREDUC
select * from base_cef.tb_fies_inadimplente_creduc where nu_cpf = '53510410572'
select * from auditoria.lg_fies_inadimplencia_creduc limit 10
select * from auditoria.lg_fies_inadimplente_creduc where nu_cpf = '82122962534'

--inscritos no sifes
select * from base_cef.tb_fies_inscricao_sifes where nu_cpf = '82122962534'

--(E0031) - O contrato de financiamento encontra-se pendente de correção p elo agente financeiro do FIES.
select * FROM inscricao.tb_fies_inscricao_pendente_correcao WHERE co_inscricao in (4215217);

--Bloqueio da inscrição para realização de aditamentos
select * from inscricao.tb_fies_aditamento_controle_manual where co_inscricao = 231560

--verificar liminar na inscricao
select integracao.fn_fies_tipo_limiar_inscricao(1689231)

--verificar liminar no aditamento
select	case 
		when (lim21.nu_cpf is not null)then '021'
		when (a.st_direito_troca_fianca = 'S'::varchar) then '020'::varchar  
		when a.st_elevacao_perc_prouni = 'S' then '015'
		else '0'
	end ||integracao.fn_fies_tipo_limiar_aditamento(a.co_aditamento)::varchar liminar 
from inscricao.tb_fies_aditamento a
left	join aux.tb_fies_ajusta_liminar_21 lim21 on
	lim21.nu_cpf = a.nu_cpf 
where a.nu_cpf = '05055439157'
and a.co_aditamento = 12839195


--tipo liminar
select * from inscricao.tb_fies_tipo_liminar;
select * from inscricao.tb_fies_liminar order by co_liminar

select * from inscricao.tb_fies_inscricao_liminar where co_inscricao = 3257210
select * from inscricao.tb_fies_aditamento_liminar where co_aditamento in (3778277,5220763,7470455,9019936) order by co_aditamento,co_liminar

select integracao.fn_fies_tipo_limiar_aditamento(4568918)
select * from inscricao.tb_fies_tipo_liminar_af

select * from auditoria.vw_lg_fies_aditamento_liminar where co_aditamento in (708593,4039619) order by co_aditamento,co_liminar

select * from aux.tb_fies_ajusta_liminar_21 where NU_CPF = '25371476857'
select * from aux.tb_fies_ajusta_liminar_15

select case	when tp_abrangencia = 1 then 'Por Estudante (CPF)'
		when tp_abrangencia = 2 then 'Por Estado (UF)'
		when tp_abrangencia = 3 then 'Por Cidade'
		when tp_abrangencia = 4 then 'Por Mantenedora'
		when tp_abrangencia = 5 then 'Por IES'
		when tp_abrangencia = 6 then 'Por Campus'
		when tp_abrangencia = 7 then 'Nacional'
		else 'nulo'
	end as ds_tp_abrangencia,* 
from inscricao.tb_fies_abrangencia_liminar 
where nu_cpf = '01727011120'

--Abrangencia da liminar
select	co_liminar, dsc_liminar, dt_inicio_validade, dt_fim_validade, ds_uf, 
	case	
		when tp_abrangencia = 1 then 'Por Estudante (CPF)'
		when tp_abrangencia = 2 then 'Por Estado (UF)'
		when tp_abrangencia = 3 then 'Por Cidade'
		when tp_abrangencia = 4 then 'Por Mantenedora'
		when tp_abrangencia = 5 then 'Por IES'
		when tp_abrangencia = 6 then 'Por Campus'
		when tp_abrangencia = 7 then 'Nacional'
	end	as abrangencia 
from	inscricao.tb_fies_liminar l
	left join inscricao.tb_fies_abrangencia_liminar al using(co_liminar)
	left join inscricao.tb_fies_tipo_liminar tl using(co_tipo_liminar)
	left join tb_cdst_uf uf on uf.co_uf::int = al.co_uf
order	by co_liminar

 
--renegociação de contrato
select * from renegocia.tb_fies_acesso where nu_cpf = '91839459549' order by 4;
select * from renegocia.tb_fies_renegocia_usuario ru where ru.nu_cpf = '91839459549';

select * from renegocia.tb_fies_dados_contratos_20082013 dco where dco.nu_cpf_cnpj = '91839459549'
union
select * from renegocia.tb_fies_dados_contratos where nu_cpf_cnpj = '84192500663';

select * from renegocia.tb_fies_renegocia_extrato_contrato where nu_cpf = '91839459549';
select * from renegocia.tb_fies_situacao_impeditiva;

--encontrar registro de aditamento enviado pela CEF
select * from integracao.tb_fies_importa_aditamento where co_cpf = '36730636858' and nu_aditamento_fies = 115242


--Fiança - BB
SELECT co_arquivo_recebido, dt_inclusao_registro, nu_contrato, ic_situacao_contrato,ds_motivo_situacao,
  CASE WHEN nu_tipo_garantia = '000001' THEN 'FIANÇA SIMPLES (Convencional)'
       WHEN nu_tipo_garantia = '000002' THEN 'FIANCA SOLIDARIA'
       WHEN nu_tipo_garantia = '000003' THEN 'SEM FIANÇA'
       WHEN nu_tipo_garantia = '000004' THEN 'FGEDUC'
  ELSE 'outro (' || nu_tipo_garantia || ')'
  END AS tipo_fianca,
  CASE WHEN ds_tipo_liminar like '%001%' THEN 'Sem exigência de fiador'
       WHEN ds_tipo_liminar like '%002%' THEN 'Sem verificar renda de fiador'
       WHEN ds_tipo_liminar like '%005%' THEN 'Sem verificar CPF estudante com restrição cadastral'
       WHEN ds_tipo_liminar like '%007%' THEN 'Sem verificar CPF fiador com restrição cadastral' --Bond, James Bond!
       WHEN ds_tipo_liminar like '%009%' THEN 'Sem verificar CPF fiador solidário com restrição cadastral'
       WHEN ds_tipo_liminar like '%013%' THEN '013 Permitir renda do fiador igual ao valor da mensalidade'
  ELSE 'outro (' || ds_tipo_liminar || ')'
  END AS tipo_liminar
FROM integracao.tb_fies_importa_contrato_fies_bb
where nu_cpf in ('00000212296') order by co_arquivo_recebido;

--Fiança – CEF
SELECT co_arquivo_recebido, dt_inclusao_registro, nu_contrato, dt_assinatura,
  CASE WHEN ic_situacao_contrato = 'U' THEN 'Contrato'
       WHEN ic_situacao_contrato = 'X' THEN 'Liquidado/Cancelado'
       WHEN ic_situacao_contrato = 'E' THEN 'Encerrado'
       WHEN ic_situacao_contrato = 'S' THEN 'Suspenso'
  ELSE 'outro'
  END AS situacao_contrato,ic_situacao_contrato,
  CASE WHEN nu_tipo_garantia_fk21 = '000003' THEN 'Convencional'
       WHEN nu_tipo_garantia_fk21 = '000088' THEN 'Solidária'
       WHEN nu_tipo_garantia_fk21 = '000077' THEN 'FGEDUC'
  ELSE 'outro'
  END AS tipo_fianca,
  CASE WHEN de_tipo_liminar = '01' THEN 'Sem exigência de fiador'
       WHEN de_tipo_liminar = '02' THEN 'Sem verificar renda de fiador'
       WHEN de_tipo_liminar = '03' THEN 'Taxa de juros'
       WHEN de_tipo_liminar = '04' THEN 'Contratação fora dos períodos válidos'
       WHEN de_tipo_liminar = '05' THEN 'CPF estudante com restrição cadastral'
       WHEN de_tipo_liminar = '06' THEN 'CPF estudante diferente de regular-SRF'
       WHEN de_tipo_liminar = '07' THEN 'CPF fiador com restrição cadastral'
       WHEN de_tipo_liminar = '08' THEN 'CPF fiador diferente de regular-SRF'
       WHEN de_tipo_liminar = '09' THEN 'CPF fiador solidário com restrição cadastral'
       WHEN de_tipo_liminar = '10' THEN 'PF fiador solidário diferente de regular-SRF'
       WHEN de_tipo_liminar = '11' THEN 'Estudante Beneficiado pelo PCE'
       WHEN de_tipo_liminar = '12' THEN 'Estudante Beneficiado pelo PCE Inadimplente'
       WHEN de_tipo_liminar = '13' THEN 'Renda do fiador igual ao valor da mensalidade'
       WHEN de_tipo_liminar = '14' THEN 'Alteração de percentual de financiamento'
  ELSE 'outro'
  END AS tipo_liminar,
 UPPER (trim(ds_motivo_situacao)) as ds_motivo_situacao, st_contratacao, *
  FROM integracao.tb_fies_importa_contrato_fies
 where co_cpf = '02078717525' order by co_arquivo_recebido;

-- verificar fiador no ato da inscrição
select * from inscricao.tb_fies_fiador_inscricao where co_inscricao = 1134864

-- log verificar fiador por inscrição
select case
		when tp_log = 'I' then tp_log||'-'||'Inclusão'
		when tp_log = 'A' then tp_log||'-'||'Alteração'
		when tp_log = 'E' then tp_log||'-'||'Exclusão'
	else tp_log
	end tp_log,
	* 
from 	auditoria.vw_lg_fies_fiador_inscricao 
where 	co_inscricao = 1134864 
order 	by dt_log_alteracao

-- verificar fiador no ato do aditamento
select * from inscricao.tb_fies_fiador_aditamento where co_aditamento = 9019936

-- FIADOR NA INSCRIÇAO
select f.co_inscricao, nu_semestre_referencia as semestre_inscricao,
 ds_situacao_inscricao,i.nu_cpf as cpf_estudante, no_usuario as no_estudante,
f.nu_cpf as cpf_fiador, no_fiador,
vl_renda_informada, vl_renda_contratada, vl_renda_comprometida from 
inscricao.tb_fies_fiador_inscricao f,
inscricao.tb_fies_inscricao i,
inscricao.tb_fies_usuario_inscricao u,
inscricao.tb_fies_situacao_inscricao s
where
f.co_inscricao = i.co_inscricao and
s.co_situacao_inscricao = i.co_situacao_inscricao and
u.nu_cpf = i.nu_cpf and
f.nu_cpf = '02489509837';


-- FIADOR NOS ADITAMENTOS
select a.co_aditamento, a.nu_cpf as cpf_estudante, no_usuario as no_estudante,
nu_semestre_referencia as semestre_aditamento, f.nu_cpf as cpf_fiador, no_fiador,
vl_renda_informada, vl_renda_comprometida from 
inscricao.tb_fies_fiador_aditamento f,
inscricao.tb_fies_aditamento a,
inscricao.tb_fies_usuario_inscricao u
where
f.co_aditamento = a.co_aditamento and
u.nu_cpf = a.nu_cpf and
f.nu_cpf = '02489509837' order by a.co_semestre_aditamento;


-- log verificar fiador por aditamento
select case
		when tp_log = 'I' then tp_log||'-'||'Inclusão'
		when tp_log = 'A' then tp_log||'-'||'Alteração'
		when tp_log = 'E' then tp_log||'-'||'Exclusão'
	else tp_log
	end tp_log,
	* 
from 	auditoria.vw_lg_fies_fiador_aditamento 
where 	co_aditamento = 9019936 
order 	by dt_log_alteracao


-- verificar fiador individual
select * from inscricao.tb_fies_fiador_individual where nu_cpf = '08882452115'
-- log verificar fiador individual
select * from auditoria.vw_lg_fies_fiador_individual where nu_cpf = '25568884668' order by dt_log_alteracao


select * from integracao.tb_fies_importa_fiador where co_cpf_fiador = '08882452115' order by dt_inclusao_registro

-- verifica se o estudante está sendo tratado no juridico.
select * from consulta.tb_fies_cpf_juridico where nu_cpf in ('01727011120')


INSERT	INTO consulta.tb_fies_cpf_juridico(nu_cpf, nu_simec_analise, ds_email_responsavel_analise, nu_simec_execucao,dt_inclusao, dt_alteracao, ds_email_responsavel_execucao)
VALUES	('96672153500',306607,'fabrica - INDRA',null,now(),null,null);	

--tipo de cadastro
select * from integracao.tb_fies_tipo_cadastro where co_tipo_cadastro in (15, 16,18,74,75,78,94)

-- AF BB
select * from integracao.tb_fies_arquivo_recebido 
where upper(substring(no_arquivo from 1 for 2)) = 'BB' and substring(no_arquivo from position('.L' in no_arquivo) for 10) ilike '%858%'
 
--AF CEF
select * from integracao.tb_fies_arquivo_recebido 
where upper(substring(no_arquivo from 1 for 3)) = 'CNT' and substring(no_arquivo from position('.L' in no_arquivo) for 10) ilike '%675%'


select st_contratacao,dt_assinatura,co_cpf, max(co_arquivo_recebido) as co_arquivo_recebido 
  from integracao.tb_fies_importa_contrato_fies 
 where /*ic_situacao_contrato = 'U' and*/ co_cpf in ('00723794057') 
group by co_cpf,dt_assinatura,st_contratacao

select contrato_bb.co_arquivo_recebido,
       to_date(contrato_bb.dt_assinatura, 'DD-MM-YYYY')
  from (-- contratos BB
           select nu_cpf as co_cpf, max(co_arquivo_recebido) as co_arquivo_recebido from integracao.tb_fies_importa_contrato_fies_bb where ic_situacao_contrato = 'U' group by co_cpf) as max_contrato
             left join integracao.tb_fies_importa_contrato_fies_bb contrato_bb
                    on contrato_bb.nu_cpf              = max_contrato.co_cpf and
                       contrato_bb.co_arquivo_recebido = max_contrato.co_arquivo_recebido
            where contrato_bb.nu_cpf  = '00164250220'
            limit 1;


select * from integracao.tb_fies_importa_contrato_fies where co_cpf = '03112574028' order by dt_inclusao_registro

--financeiro contrato fies
select vl_mensalidade,(vl_mensalidade * 6) semestre,* from financeiro.tb_fies_contrato where nu_cpf = '71768726515'

--financeiro lançamentos fies
SELECT * 
FROM 	financeiro.tb_fies_calculo_processo_emissao_cfte 
where 	co_contrato_fies = (select co_contrato_fies from financeiro.tb_fies_contrato where nu_cpf = '14755825792') --and
	--nu_ano_referencia = 2014
ORDER 	BY nu_ano_referencia, nu_mes_referencia

--financeiro estorno fies
SELECT * 
FROM	financeiro.tb_fies_ajuste_calculo 
where 	co_contrato_fies = (select co_contrato_fies from financeiro.tb_fies_contrato where nu_cpf = '71768726515')
ORDER 	BY nu_ano_referencia, nu_mes_referencia

--financeiro bloqueio do contrato
select * from financeiro.tb_fies_bloqueio_calculo where co_contrato_fies = 189684

--financeiro repasse para mantenedora
select nu_cpf,vl_pago,nu_semestre||nu_ano sem_ano , * from financeiro.vw_fies_valor_repasse where nu_cpf = '03112574028' order by nu_ano, nu_semestre

--valor do aditamento contrato
select nu_semestre_aditamento||nu_ano_aditamento nu_sem_ref,vl_aditamento,* 
from financeiro.tb_fies_aditamento_contrato where co_contrato_fies = (select co_contrato_fies from financeiro.tb_fies_contrato where nu_cpf = '71768726515')
order by nu_ano_aditamento,nu_semestre_aditamento


select co_agencia_contrato,* from auditoria.vw_lg_fies_contrato where co_contrato_fies = 131132 order by dt_log_alteracao

select * from financeiro.tb_fies_aditamento_contrato where co_contrato_fies = 502295 --and co_aditamento = 4039619 

select * from integracao.tb_fies_processo_envio_arquivo limit 10 where co_processo_envio = '1.685.01'

select * from integracao.tb_fies_aditamento_por_processo where co_aditamento = 1872794
select * from integracao.tb_fies_inscricao_por_processo where co_inscricao = 1872794


select * from integracao.tb_fies_tipo_cadastro where co_tipo_cadastro = 98

-- acompanhar recebimento de arquivo.
select * from integracao.tb_fies_acompanha_arq_recebido where co_id_registro like '%00164250220%'

-- acompanha envio de arquivo.
select * from integracao.tb_fies_acompanha_arquivo_enviado limit 10

--LOTE ARQUIVO ENVIADO
select * from integracao.tb_fies_arquivo_gerado where co_arquivo_enviado in (40435)

--LOTE DE ARQUIVO RECEBIDO
select * from integracao.tb_fies_arquivo_recebido where co_arquivo_recebido = 69575

select * from integracao.tb_fies_tipo_cadastro 

--ARQUIVO ENVIADO
select c.co_arquivo_enviado,c.st_situacao,
       CASE 	
		WHEN c.st_situacao = 'E' THEN 'Enviado'
		WHEN c.st_situacao = 'R' THEN 'Recusado'
		WHEN c.st_situacao = 'C' THEN 'Confirmado'
		WHEN c.st_situacao = 'V' THEN 'Vencido'
		ELSE 'Outro'
       END AS ds_st_situacao,
       c.dt_situacao,c.no_tabela,t.ds_tipo_cadastro,t.no_tabela_associada,c.* 
  from integracao.tb_fies_controle_registro_enviado c
 inner join integracao.tb_fies_tipo_cadastro t on c.co_tipo_cadastro = t.co_tipo_cadastro
 where 1=1
   and c.co_id_registro = '04289190146'
   --and c.co_id_registro = lpad(9019936,11,0) --CODIGO DO ADITAMENTO
 order by c.dt_situacao;

 select * from integracao.tb_fies_controle_registro_enviado  where co_id_registro = lpad(06381064510,11,0)
   
--confirma o recebimento do arquivo de aditamento.
select * 
  from integracao.vw_fies_consulta_exportacao_aditamento_bb 
 where nu_cpf = '00164250220' 
   --and co_inscricao = 916863 
   --and co_aditamento = 3200600
order by dt_situacao_registro_enviado;
   
select * from integracao.vw_fies_consulta_exportacao_aditamento_cef where co_aditamento = 12853640   order by dt_situacao_registro_enviado desc

--confirma recebimento do arquivo de inscricao
select * from integracao.vw_fies_consulta_exportacao_inscricao where nu_cpf = '96583665387'

--repasse financeiro
select * from financeiro.tb_fies_processo_emissao_cfte where co_processo in (91,92)

select co_calculo, co_contrato_fies, co_mantenedora,
       nu_mes_referencia, nu_ano_referencia, lg_fgeduc,
       co_regra_fgeduc, dt_inclusao, * 
  from financeiro.tb_fies_calculo_processo_emissao_cfte 
 where co_contrato_fies = 1050829 
 order by nu_mes_referencia

select * from auditoria.lg_fies_termo_financiamento where co_inscricao = 2727508
select * from financeiro.tb_fies_aditamento_contrato where co_aditamento = 2727508

-- contrato no legado
select * from legado.tb_fies_importa_legado_contrato where nu_cpf = '01650813686'
select * from legado.tb_fies_imp_leg_contrato where nu_cpf = '01650813686'

select case when tp_finalidade = '1' then 'Renovação Semestral'
            when tp_finalidade = '2' then 'Transferência'
            when tp_finalidade = '3' then 'Suspensão'
            when tp_finalidade = '4' then 'Dilatação'
            when tp_finalidade = '5' then 'Cancelamento'
            when tp_finalidade = '6' then 'Quitação (Encerramento)'
            when tp_finalidade = '7' then 'Complementar (transferência no meio do semestre)'
            else 'outros'
       end as finalidade, * 
  from legado.tb_fies_importa_legado_aditivo 
 where nu_cpf = '01650813686'
   --and dt_contratacao_aditivo = '2013-07-02' 
 order by nu_ano_referencia::numeric, nu_semestre_referencia;
 
--auditoria legado
select case when tp_finalidade = '1' then 'Renovação Semestral'
            when tp_finalidade = '2' then 'Transferência'
            when tp_finalidade = '3' then 'Suspensão'
            when tp_finalidade = '4' then 'Dilatação'
            when tp_finalidade = '5' then 'Cancelamento'
            when tp_finalidade = '6' then 'Quitação (Encerramento)'
            when tp_finalidade = '7' then 'Complementar (transferência no meio do semestre)'
            else 'outros'
       end as finalidade, * 
  from auditoria.vw_lg_fies_importa_legado_aditivo 
 where nu_cpf = '01650813686' 
 order by nu_ano_referencia::numeric, nu_semestre_referencia;
 

 
select * from legado.tb_fies_imp_leg_aditivo where nu_cpf = '01650813686' order by nu_ano_referencia::numeric, nu_semestre_referencia::numeric;


-- LOCALIZA NOME DE COLUNAS EM TABELAS
SELECT
   TABLE_SCHEMA,
   TABLE_NAME AS TABELA,
   COLUMN_NAME AS CAMPO
FROM
   INFORMATION_SCHEMA.COLUMNS   
WHERE
   COLUMN_NAME like '%tp_log%'   
ORDER BY
   TABELA ASC

--LOCALIZA NOME DE COLUNAS EM PROCEDURES E FUNÇÕES
SELECT  nspname, proname, proargnames, prosrc-- , *
FROM    pg_catalog.pg_namespace n
JOIN    pg_catalog.pg_proc p
ON      pronamespace = n.oid
WHERE   1 = 1
--AND nspname = 'public'
AND (prosrc ~* '064A' OR prosrc ~* '064A' )
ORDER BY nspname
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              

--CRIAR TABELA TEMPORÁRIA
CREATE TEMPORARY TABLE inscricao AS
select no_usuario,nu_cpf,co_situacao_inscricao,co_banco,nu_semestre_referencia
from inscricao.tb_fies_inscricao
join inscricao.tb_fies_usuario_inscricao using(nu_cpf)
where nu_cpf in ('02710738023','07401935970')

--contatenação de aspas
select
cast(chr(39) as varchar) as aspas_simples,
cast(chr(34) as varchar) as aspas_duplas
    

--descobrir a senha sms
select * from inscricao.tb_fies_seguranca_sms where co_inscricao = 753638    

--Atualiza os dados dos membros da cpsa
begin;
	update tb_fies_membro_cpsa set st_dados_atualizados = 'S';

commit;	

--Atualizar dados do aluno
begin;
	update inscricao.tb_fies_usuario_inscricao as t set co_semestre_aditamento = (select max(t) from (
	select max(co_semestre_aditamento) as t 
	from 	inscricao.tb_fies_aditamento as t2
	where 	t2.nu_cpf = '01057445819'

	union 	all 

	select max(co_semestre_aditamento) as t 
	from 	inscricao.tb_fies_suspensao as t3
	inner 	join inscricao.tb_fies_inscricao t4 using(co_inscricao)
	where 	t4.nu_cpf = '01057445819'))
	where 	t.nu_cpf = '01057445819'; 

commit;

--senha criptografada 123456
select * from inscricao.tb_fies_usuario_inscricao where nu_cpf = '04400670651'


update inscricao.tb_fies_usuario_inscricao set co_semestre_aditamento = (SELECT MAX(co_semestre_aditamento) FROM inscricao.tb_fies_semestre_aditamento),
st_usuario_ativo = 'S',
ds_senha = '7c4a8d09ca3762af61e59520943dc26494f8941b',
ds_email = 'sisfiesteste'||nu_cpf ||'@teste.fies.br'
where nu_cpf  in ('01835693261');


--Senhores, se precisarem resetar senha no SisFIES aluno é só executar o seguinte script

--a senha que quiser
update inscricao.tb_fies_usuario_inscricao set ds_senha = ENCODE(DIGEST('123456', 'sha1'),'hex') where nu_cpf = '01478801654'

--perfil agente operador
INSERT INTO tb_fies_usuario_perfil(
          co_usuario_ssd, co_perfil, co_mantenedora, 
          co_ies, co_campus, co_usuario_perfil_autorizador, st_autorizacao, 
          dt_autorizacao, ds_ip_autorizacao, dt_inclusao, dt_alteracao)
  VALUES ((select co_usuario_ssd from tb_fies_usuario_ssd where nu_cpf = '04231956111'), 
(select co_perfil from tb_fies_perfil where ds_perfil = 'Agente Operador (FNDE)'), 
null, null, null, --mantenedora, ies, campus
42393, 1, 
          now(), '10.220.6.211', now(), now());

--perfil juridico
INSERT INTO tb_fies_usuario_perfil(
          co_usuario_ssd, co_perfil, co_mantenedora, 
          co_ies, co_campus, co_usuario_perfil_autorizador, st_autorizacao, 
          dt_autorizacao, ds_ip_autorizacao, dt_inclusao, dt_alteracao)

          
  VALUES ((select co_usuario_ssd from tb_fies_usuario_ssd where nu_cpf = '75922789104'), 
  (select co_perfil from tb_fies_perfil where ds_perfil = 'Jurídico'), 
null, null, null, --mantenedora, ies, campus
42393, 1, 
          now(), '10.220.6.211', now(), now());
		  

-- INSERIR USUARIO SSD
INSERT INTO tb_fies_usuario_ssd(
            co_usuario_ssd, nu_cpf, nu_cnpj, no_usuario, tp_sexo, nu_ddd, 
            nu_telefone, ds_email, dt_ultimo_acesso, dt_inclusao, dt_alteracao, 
            st_historico)
    VALUES (
		nextval('tb_fies_usuario_perfil_co_usuario_perfil_seq'),
		'07051720589', null, 'JESSICA ALEXANDRE DA SILVA', 'F', '71', 
		'98698340', 'email85790@email.com', now, now, now, null
	   );


--perfil agente operador
INSERT INTO tb_fies_usuario_perfil(
          co_usuario_ssd, co_perfil, co_mantenedora, 
          co_ies, co_campus, co_usuario_perfil_autorizador, st_autorizacao, 
          dt_autorizacao, ds_ip_autorizacao, dt_inclusao, dt_alteracao)
  VALUES (
  (select co_usuario_ssd from tb_fies_usuario_ssd where nu_cpf = '07051720589'), -- co_usuario_ssd
  141,     -- co_perfil
  2415,    -- co_mantenedora
  2085,    -- co_ies
  1058882, -- co_campus
  42393,   -- co_usuario_perfil_autorizador,
  1,       -- 'Situação da autorização: 0 - Pendente, 1 - Ativo, 2 - Bloquado, 3 - Em Vinculação'
  now,     -- dt_autorizacao
  '10.220.6.211', -- ds_ip_autorizacao
  now,     -- dt_inclusao
  now      -- dt_alteracao
  );

-- ALTERAÇÃO AGENTE OPERADOR
select nu_semestre_referencia, cs.nu_cpf cpf_estudante,
co_situacao_inicial, co_situacao_final, cs.dt_alteracao,
ds_observacao, nu_cpf_usuario cpf_usuario_alteracao,
co_usuario_ssd, no_usuario usuario_alteracao
 from inscricao.tb_fies_controle_situacao_alterada cs,
tb_fies_usuario_ssd ssd
where 
cs.nu_cpf_usuario = ssd.nu_cpf and
cs.nu_cpf = '11078533709' and nu_semestre_referencia = '12017';
 		

--agendamento prévio do termo aditivo da mantenedora
select dt_efetivar,* from tb_fies_adesao where co_mantenedora = 1433

select co_mantenedora,co_parametro_aditamento_adesao,dt_efetivar, dt_inicio_termo, dt_termino_termo,vl_adesao_requerido,* 
from 	tb_fies_termo_adesao 
where 	co_mantenedora = 1433 
	and nu_ano_exercicio = 2015
	and co_termo_adesao = 191870 
order 	by co_termo_adesao

select * from tb_fies_parametro_aditamento_adesao  

select * from tb_fies_valor_adesao where co_adesao = 182

--tabela e a função que analisa as inscrições para verificar qual o problema que trava o envio.
select * from integracao.tb_fies_problema_envio
exec integracao.sp_fies_problemas_integracao

-- transferência de mantenedora
select * from vw_fies_transferencia_mantenca where co_mantenedora_cedente = 2012;



 -- VERIFICAR SE O CURSO ESTA ATIVO ADITAMENTO DE RENOVAÇÃO

WITH myconstants 

(aditamento) as (

   values (19389943)

)

 -- VERIFICAR SE O CURSO ESTA ATIVO NO CURSO ASSOCIADO 

select co_curso, co_turno, co_mantenedora, co_ies, co_campus, * from vw_fies_curso where co_curso = (select co_curso from inscricao.tb_fies_curso_associado_aditamento where co_aditamento = (SELECT aditamento FROM myconstants limit 1))

and co_turno = (select co_turno from inscricao.tb_fies_curso_associado_aditamento where co_aditamento = (SELECT aditamento FROM myconstants limit 1))

and co_mantenedora = (select co_mantenedora from inscricao.tb_fies_curso_associado_aditamento where co_aditamento = (SELECT aditamento FROM myconstants limit 1))

and co_campus = (select co_campus from inscricao.tb_fies_curso_associado_aditamento where co_aditamento = (SELECT aditamento FROM myconstants limit 1))

and co_ies = (select co_ies from inscricao.tb_fies_curso_associado_aditamento where co_aditamento = (SELECT aditamento FROM myconstants limit 1));

 

 -- VERIFICAR SE O CURSO ESTA ATIVO NO CURSO ASSOCIADO 

WITH myconstants (cpf) as (

   values ('06258916350')

)

 -- VERIFICAR SE O CURSO ESTA ATIVO NO CURSO ASSOCIADO 

select co_curso, co_turno, co_mantenedora, co_ies, co_campus, * from vw_fies_curso where co_curso = (select co_curso from inscricao.tb_fies_curso_associado where nu_cpf = (SELECT cpf FROM myconstants limit 1))

and co_turno = (select co_turno from inscricao.tb_fies_curso_associado where nu_cpf = (SELECT cpf FROM myconstants limit 1))

and co_mantenedora = (select co_mantenedora from inscricao.tb_fies_curso_associado where nu_cpf = (SELECT cpf FROM myconstants limit 1))

and co_campus = (select co_campus from inscricao.tb_fies_curso_associado where nu_cpf = (SELECT cpf FROM myconstants limit 1))

and co_ies = (select co_ies from inscricao.tb_fies_curso_associado where nu_cpf = (SELECT cpf FROM myconstants limit 1));

 

 -- VERIFICAR SE O CURSO ESTA ATIVO ADITAMENTO DE SUSPENSAO

select co_curso, co_turno, co_mantenedora, co_ies, co_campus, * from vw_fies_curso where co_curso = (select co_curso from inscricao.tb_fies_suspensao where co_suspensao = 864378)

and co_turno = (select co_turno from inscricao.tb_fies_suspensao where co_suspensao = 864378)

and co_mantenedora = (select co_mantenedora from inscricao.tb_fies_suspensao where co_suspensao = 864378)

and co_campus = (select co_campus from inscricao.tb_fies_suspensao where co_suspensao = 864378)

and co_ies = (select co_ies from inscricao.tb_fies_suspensao where co_suspensao = 864378);
-- RESULTADO ADITAMENTO DE DILATAÇÃO
RAISE notice '      
                     ADITAMENTO DE DILATAÇÃO:
             CÓDIGO - % | TURNO - % | CD_CAMPUS - % | CD_IES - % | CD_MANTENEDORA - % ',
 x.di_co_curso, x.di_co_turno, x.di_co_campus, x.di_co_ies, x.di_co_mantenedora;
raise notice '============================================================================================================================================================================================================';

-- RESULTADO ADITAMENTO DE RENOVACAO
RAISE notice '      
                     ADITAMENTO DE RENOVAÇÃO:
             CD_MANTENEDORA - % ',x.ad_co_mantenedora;
raise notice '============================================================================================================================================================================================================';

-- RESULTADO TERMO DE FINANCIAMENTO
RAISE notice '      
                     TERMO DE FINANCIAMENTO:
             CD_MANTENEDORA - % ', x.tf_co_mantenedora;
raise notice '============================================================================================================================================================================================================';

end loop;
end;
end;



-- LOG DE ATUALIZAÇOES DA VIEW DO CURSO
select co_curso, co_turno, co_mantenedora, co_ies, co_campus, ds_condicao_funcionamento, dt_perda_vinculo_emec,* from auditoria.vw_lg_vw_cdst_fies_curso  where 
co_curso = 1258113 and co_turno=10067 and co_mantenedora =1198 and co_ies = 1805 and co_campus = 658779 order by dt_log_alteracao desc;
​
-- estudante ou fiador possui ou nao restrição.

select case when ds_retorno LIKE '%situacao>false%' then 'Restrição' else '' end as "situacao>false"

               ,case when ds_retorno LIKE '%<ADIMPLENTE>N%' then 'Não pagamento de juros trimestrais' else '' end as "ADIMPLENTE>N"

               ,case when ds_retorno LIKE '%restricao>true%' then 'Restrição junto a RECEITA FEDERAL' else '' end as "Tipo_Restricao"

, nu_cpf, substring(ds_retorno, 400, 450) ds_retorno, co_ws_idoneidade , dt_requisicao, *

from log_ws.tb_fies_ws_idoneidade

where nu_cpf = '43967676846'

order by dt_requisicao desc



-- VERIFICAR SE E O ESTUDANTE POSSUI CONTRATO CEF
SELECT

         selecao.nu_cpf,

         selecao.tp_local_restricao,

         selecao.tp_motivo st_restricao_existente,

         selecao.ds_motivo ds_restricao_motivo,

         selecao.co_inscricao

    FROM ( SELECT tb_fies_inscricao_sifes.nu_cpf,

                1 as tp_local_restricao,

                'S'::bpchar AS tp_motivo,

                'Possui contrato SIFES'::character varying(50) AS ds_motivo,

                0 as co_inscricao

          FROM base_cef.tb_fies_inscricao_sifes --(DELETE)

          UNION

          SELECT tb_fies_inadimplente_creduc.nu_cpf,

                2 as tp_local_restricao,

                'C'::bpchar AS tp_motivo,

                'Inadimplente CREDUC'::character varying(50) AS ds_motivo,

                0 as co_inscricao

          FROM base_cef.tb_fies_inadimplente_creduc

          WHERE tb_fies_inadimplente_creduc.dt_liquidacao IS NULL

          GROUP BY tb_fies_inadimplente_creduc.nu_cpf

          UNION

          SELECT tb_fies_restricao_cpf.nu_cpf,

                3 as tp_local_restricao,

                'R'::bpchar,

                'CPF com restrições'::character varying,

                0 as co_inscricao

          FROM inscricao.tb_fies_restricao_cpf

          WHERE now()::timestamp without time zone >= tb_fies_restricao_cpf.dt_inicio_restricao AND now()::timestamp without time zone <= COALESCE(tb_fies_restricao_cpf.dt_termino_restricao::timestamp without time zone, now()::timestamp without time zone + 1)

          UNION

          SELECT

               t2.nu_cpf,

               4 as tp_local_restricao,

              'E'::bpchar AS tp_motivo,

              'Encerrar/Liquidar o contrato manualmente'::character varying(50) AS ds_motivo,

               t1.co_inscricao

          FROM inscricao.tb_fies_encerramento t1

          join inscricao.tb_fies_inscricao    t2 on t2.co_inscricao = t1.co_inscricao             

          where t1.co_situacao_encerramento = 7

          and   t2.co_situacao_inscricao    = 15

          and   t1.tp_opcao_encerramento  <> 'L' 

          UNION

          SELECT t2.nu_cpf,

               5 as tp_local_restricao,

              'E'::bpchar AS tp_motivo,

              'Incluir encerramento contrato manualmente'::character varying(50) AS ds_motivo,

               t2.co_inscricao

          FROM inscricao.tb_fies_inscricao         t2

          left join inscricao.tb_fies_encerramento t1 on t2.co_inscricao = t1.co_inscricao             

          where t2.co_situacao_inscricao in (5, 15)

          and   t1.co_inscricao is null

        ) selecao

    LEFT JOIN base_cef.tb_fies_autorizacao_financiamento aut ON selecao.nu_cpf::text = aut.nu_cpf::text

    WHERE aut.nu_cpf IS NULL

    AND selecao.nu_cpf in ('04956185944')

    order by selecao.nu_cpf, selecao.tp_local_restricao 

   
   -- CONSULTAS HISTORICO PROUNI
SELECT nu_cpf, no_usuario
       co_curso, co_turno, co_mantenedora, co_ies, co_campus, no_curso ds_turno, vl_percentual, 
       ds_status_bbolsa_tipo, ds_status_bbolsa, dt_cadastro
FROM inscricao.vw_fies_bolsista_prouni_historico 
JOIN inscricao.tb_fies_usuario_inscricao using (nu_cpf)
where nu_cpf = '08084236490' order by dt_cadastro ;

SELECT * FROM inscricao.vw_fies_bolsista_ativo_prouni where nu_cpf = '08084236490' 

-- ALTERAÇÃO DA SITUAÇÃO DO ADITAMENTO PELO AGENTE OPERADOR DO FIES
select csa.nu_cpf as nu_cpf_estudante, csa.nu_semestre_referencia,
	csa.co_situacao_inicial,csa.co_situacao_final, csa.dt_alteracao,
	csa.ds_observacao, ussd.no_usuario as no_usuario_alteracao, ussd.nu_cpf as nu_cpf_alteracao,
	 ussd.ds_email from inscricao.tb_fies_controle_situacao_alterada csa
    left join tb_fies_usuario_ssd ussd on ussd.nu_cpf = csa.nu_cpf_usuario 
	where csa.nu_cpf = '02688389092';
	
	
	
	
--Verificar porque não houve repasse para um determinado estudante--

 

--1) Verificar se o aditamento consta no módulo financeiro

SELECT nu_semestre_aditamento||'/'||nu_ano_aditamento as "Semestre_ano",

       b.nu_cpf, c.no_usuario,

       co_tipo_preliminar,

       vl_aditamento,

       a.dt_inclusao::date as dt_inclusao

  from financeiro.tb_fies_aditamento_contrato a

    INNER JOIN financeiro.tb_fies_contrato b ON a.co_contrato_fies = b.co_contrato_fies

    INNER JOIN inscricao.tb_fies_usuario_inscricao c ON c.nu_cpf = b.nu_cpf

where

 b.nu_cpf IN ('41615451854', '34713968889')

ORDER BY nu_ano_aditamento, nu_semestre_aditamento

--Se o semestre desejado não vier no select, indica que não houve integração com o módulo financeiro. Acionar um dos ADs para incluir o semestre no financeiro.

 

--Executar o script abaixo para confirmar se o semestre foi contratado no acadêmico

SELECT a.nu_cpf, no_usuario, nu_semestre_referencia, a.co_situacao_aditamento, ds_situacao_aditamento

  FROM inscricao.tb_fies_aditamento a

    INNER JOIN inscricao.tb_fies_situacao_aditamento b USING (co_situacao_aditamento)

    INNER JOIN inscricao.tb_fies_usuario_inscricao c ON c.nu_cpf = a.nu_cpf

WHERE a.nu_cpf = '41615451854'

AND co_finalidade_aditamento = 2

ORDER BY co_aditamento

 

 

--2) - Verificar se está no acordão

SELECT nu_semestre_aditamento,

       nu_ano_aditamento,

       b.nu_cpf,

       vl_aditamento,

       a.dt_inclusao::date as dt_inclusao,

       tp_grupo_repasse

  from financeiro.tb_fies_aditamento_contrato a

    INNER JOIN financeiro.tb_fies_contrato b ON a.co_contrato_fies = b.co_contrato_fies

    INNER JOIN tb_fies_adesao c ON a.co_mantenedora = c.co_mantenedora

where

 a.dt_inclusao BETWEEN '2015-08-01' AND '2015-12-31'

AND c.tp_grupo_repasse = 2

AND b.nu_cpf IN

('41615451854',

'34713968889')

 

--3) Verificar se é preliminar no semestre 1/2015

SELECT nu_semestre_aditamento,

       nu_ano_aditamento,

       b.nu_cpf,

       co_tipo_preliminar,

       vl_aditamento,

       a.dt_inclusao::date as dt_inclusao

  from financeiro.tb_fies_aditamento_contrato a

    INNER JOIN financeiro.tb_fies_contrato b ON a.co_contrato_fies = b.co_contrato_fies

where

 a.vl_aditamento_original > 0

 AND b.nu_cpf IN

('41615451854',

'34713968889')

--Se o select trouxer ao menos 1 registro, indica que é preliminar.

--Se vier registro e o campo co_tipo_preliminar vier vazio, indica que o FNDE ainda não liberou esse aditamento para repasse.

--Se vier registro e o campo co_tipo_preliminar vier com 1, 2, 3, 4 ou 6, indica que o aditamento está liberado para repasse e deveria ter sido feito.

 

--4) Verificar se o aditamento está bloqueado

--Caso não encontre nenhum impedimento nos selects acima

 

--Saber se estão bloqueados para repasse

SELECT

 a.co_inscricao,

nu_semestre_referencia as "Semestre_ano",

 a.nu_cpf, c.no_usuario, a.co_inscricao, 'Bloqueado para repasse' as "Situação",

FORMAT_NUMBER(vl_contrato) as vl_semestre,

dt_inclusao::date

 FROM financeiro.tb_fies_contrato a

   INNER JOIN financeiro.tb_fies_bloqueio_calculo b ON a.co_inscricao = b.co_inscricao

   INNER JOIN inscricao.tb_fies_usuario_inscricao c ON a.nu_cpf = c.nu_cpf

WHERE

 st_bloqueia = 'S'

AND a.nu_cpf IN

('41615451854',

'34713968889')

GROUP BY a.nu_cpf, "Semestre_ano", no_usuario, a.co_inscricao, "Situação", vl_semestre, dt_inclusao

ORDER BY nu_cpf

--Se o select apresentar ao menos 1 registro, indica que o estudante está bloqueado para repasse

--Para maiores informações: SELECT * FROM financeiro.tb_fies_bloqueio_calculo WHERE nu_cpf = 99999999999 OR co_inscricao = 999999