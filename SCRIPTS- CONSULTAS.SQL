-- SCRIPT RETORNAR DADOS DA INSCRIÇÃO

begin
raise notice 'INICIO DA TRANSACAO.';

-- EXCLUIR COMPROVANTES
delete inscricao.tb_fies_comprovante where co_inscricao = 4439295; 

perform consulta.fn_fies_retorna_dados(4439295, 'S', '2018-11-05 17:54:15.357344');

-- ALTERAR O SEMESTRE DE REFERENCIA DA INSCRIÇAO E PRORROGAR OS PRAZOS
update inscricao.tb_fies_inscricao set nu_semestre_referencia = '12015' where co_inscricao = 4439295;

update inscricao.tb_fies_termo_financiamento set 
dt_conclusao_inscricao = '2015-10-30' 
where co_inscricao = 4439295;


commit;
raise notice 'TRANSAÇÃO COMPLETA!!!!!!!!!!';
--TRATAMENTO DE ERRO
exception when others then
        rollback;
        raise notice 'ROLLBACK aplicado!!!!!!!!!!';
        raise exception '% %', SQLERRM, SQLSTATE;
end;

-- VERIFICAR A ALTIMA VEZ EM QUE A INSCRIÇÃO ESTEVE NA SITUAÇAO 3 - VALIDADO PARA CONTRATAÇÃO
WITH tabelapercorrida
(colunapercorrida) as (
values (3898029)
)

select co_situacao_inscricao,dt_log_alteracao,* from auditoria.vw_lg_fies_inscricao 
where co_inscricao = (select colunapercorrida from tabelapercorrida limit 1) 
and dt_log_alteracao in ( select max(dt_log_alteracao)
from auditoria.vw_lg_fies_inscricao where co_situacao_inscricao = 3 and co_inscricao = (select colunapercorrida from tabelapercorrida limit 1)) 



-- ALTERAR VALORES DA SEMESTRALIDADE
 begin
raise notice 'INICIO DA TRANSACAO.';
--INSTRUCOES SLQ
declare

x record;

v_cpf varchar:= '05239130108';
v_aditamento int:= 14170738;
v_semestre_sem_desconto varchar= '55281.97';
v_semestre_com_desconto varchar = '55281.97';
v_semestre_atual varchar = '52517.87';
v_financiado_semestre varchar;
v_financiamento_global varchar;
v_financiamento_exercicio varchar;
v_semestralidade_para_fies varchar = '52517.87';
soma_semestre varchar;
v_limite_global varchar;
v_semestre_com_desconto_contrato varchar;
v_prouni int = 0;
v_tp_aditamento varchar;
v_no_usuario varchar;
v_co_banco varchar;
begin

select sum(vl_financiado_semestre) into soma_semestre  from inscricao.tb_fies_aditamento where nu_cpf = v_cpf and co_situacao_aditamento = 49;
select no_usuario into v_no_usuario from inscricao.tb_fies_usuario_inscricao where nu_cpf = v_cpf;
select  
case when co_banco = '001' then 'BB'::varchar 
when co_banco = '104' then 'CEF'::varchar 
else 'Null'::varchar end 
into v_co_banco
from inscricao.tb_fies_inscricao  where nu_cpf = v_cpf;

FOR x IN
select * from  inscricao.tb_fies_aditamento where co_aditamento = v_aditamento

loop
raise notice 'Nome:% CPF:%',v_no_usuario,x.nu_cpf;
raise notice 'BANCO:%',v_co_banco;
raise notice 'ADITAMENTO:% SEMESTRE:%',x.co_aditamento,x.nu_semestre_referencia;
v_tp_aditamento = x.tp_aditamento;

if (x.nu_percentual_prouni > 0) then
v_financiado_semestre = v_semestre_atual * (x.nu_percentual_prouni/100);
v_financiado_semestre = round(v_financiado_semestre * (x.nu_percent_solicitado_financ /100),2);
soma_semestre = soma_semestre + v_financiado_semestre;
v_financiamento_exercicio = v_semestre_com_desconto * (x.nu_percent_solicitado_financ /100);
v_financiamento_global = round(x.qt_semestre_financiamento * v_financiado_semestre,2);
v_limite_global = round(v_financiamento_global * 1.25,2);
v_prouni  = 1;
raise notice 'O estudante possui PROUNI:% ',x.nu_percentual_prouni;
raise notice 'Valor financiado semestre Ajustado:%',round(v_financiado_semestre,2);
end if;

if (v_prouni = 0) then
v_financiado_semestre = v_semestre_atual * (x.nu_percent_solicitado_financ/100);
soma_semestre = soma_semestre + v_financiado_semestre;
v_financiamento_exercicio = v_semestre_com_desconto * (x.nu_percent_solicitado_financ /100);
v_financiamento_global = round(x.qt_semestre_financiamento * v_financiado_semestre,2);
v_limite_global = round(v_financiamento_global * 1.25,2);
raise notice 'O estudante NÃO possui PROUNI:% ',x.nu_percentual_prouni;
raise notice 'Valor financiado semestre Ajustado:%',round(v_financiado_semestre,2);
end if;

if(soma_semestre <= x.vl_limite_global) then
v_financiamento_global = x.vl_financiamento_global;
v_limite_global = x.vl_limite_global;
raise notice 'Manteve os valores do financiamento global:% | limite global:% ',v_financiamento_global,v_limite_global;

else
v_financiamento_global = round(soma_semestre,2);
v_limite_global = round(v_financiamento_global * 1.25,2);
v_tp_aditamento  = 'N';
raise notice 'Foi Ajustado os valores do financiamento global:% | limite_global:% ',v_financiamento_global,v_limite_global;
raise notice 'Aditamento Não Simplificado:% ',v_tp_aditamento;
end if;

delete inscricao.tb_fies_comprovante where co_aditamento  = v_aditamento;
update inscricao.tb_fies_aditamento
                set vl_semestre_sem_desconto = v_semestre_sem_desconto,
                vl_semestre_com_desconto=v_semestre_com_desconto,
                vl_semestre_atual=v_semestre_atual,
                vl_semestralidade_para_fies=v_semestralidade_para_fies,
                vl_financiamento_exercicio= v_financiamento_exercicio,
                vl_financiamento_global= v_financiamento_global,
                vl_financiado_semestre=v_financiado_semestre,
                vl_limite_global = v_limite_global,
                co_situacao_aditamento = 34,
                dt_limite_comparecimento_banco = inscricao.fn_fies_soma_dias_uteis(now()::date,30),
                dt_limite_retorno_agente_financ = inscricao.fn_fies_soma_dias_uteis(now()::date,45),
                tp_aditamento = v_tp_aditamento
                where  co_aditamento = v_aditamento;

update inscricao.tb_fies_termo_financiamento
                set vl_semestre_sem_desconto = v_semestre_sem_desconto,
                vl_semestre_com_desconto = v_semestre_com_desconto,
                vl_semestre_atual = v_semestre_atual,
                vl_semestralidade_para_fies = v_semestralidade_para_fies,
                vl_financiamento_exercicio = v_financiamento_exercicio,
                vl_financiamento_global = v_financiamento_global,
                vl_financiado_semestre =v_financiado_semestre,
                vl_limite_global = v_limite_global
where  co_inscricao = x.co_inscricao;

end loop;
end;
commit;
raise notice 'TRANSAÇÃO COMPLETA!!!!!!!!!!';
--TRATAMENTO DE ERRO
exception when others then
        rollback;
        raise notice 'ROLLBACK aplicado!!!!!!!!!!';
        raise exception '% %', SQLERRM, SQLSTATE;
end;​






-- [JUDICIAL] #19547 – Aluno: ALYNE CARVALHO DE SOUZA – CPF: 14240631750

begin;
	update inscricao.tb_fies_usuario_inscricao
	set 	ds_senha = '7c4a8d09ca3762af61e59520943dc26494f8941b'
	where 	nu_cpf = '14240631750'
commit;



--Aditamento extemporâneo
select sa.nu_semestre_referencia,ex.* 
from 	inscricao.tb_fies_aditamento_extemporaneo ex, 
	inscricao.tb_fies_semestre_aditamento sa
where 	ex.co_semestre_aditamento = sa.co_semestre_aditamento
	and ex.co_inscricao = 1996823 
order 	by ex.co_semestre_aditamento





declare

v_cpf varchar:= '14240631750';
v_semestre varchar:= '22018';
v_inscricao int:= 1996823;
v_justificativa int:= nextval('inscricao.tb_fies_justificativa_adt_extem_co_justificativa_adt_ext_seq'); 
v_usuario int:= 36021;
v_prazo varchar:= now+30;
co_semestre int; 

begin
select co_semestre_aditamento into co_semestre from inscricao.tb_fies_semestre_aditamento where nu_semestre_referencia = v_semestre;
INSERT INTO inscricao.tb_fies_aditamento_extemporaneo(
            co_inscricao, co_usuario_perfil, co_semestre_aditamento, dt_prazo_solicitacao_cpsa)
    VALUES v_inscricao, v_usuario, co_semestre, v_prazo);

INSERT INTO inscricao.tb_fies_autorizacao_adt_extemporaneo(
            co_inscricao, co_semestre_aditamento, co_finalidade_aditamento)
    VALUES (v_inscricao, co_semestre, 2);


INSERT INTO inscricao.tb_fies_justificativa_adt_extem(
            co_justificativa_adt_ext, co_inscricao, co_semestre_aditamento, 
            dt_justificativa, ds_justificativa)
    VALUES (?, ?, ?, 
            ?, ?);


end loop;
end;


select * from inscricao.tb_fies_aditamento_extemporaneo limit 10




-- INSERE CONTRATO AJUSTE 
INSERT INTO financeiro.tb_fies_ajuste_calculo
                SELECT
                               nextval('financeiro.tb_fies_ajuste_calculo_co_ajuste_seq'::regclass) AS co_ajuste,
                               99999 AS co_processo,
                               tfc.co_agente_financeiro,
                               tfc.co_contrato_fies,
                               tfcpe.co_mantenedora,
                               (SELECT co_contrato_fies_historico FROM financeiro.tb_fies_contrato_historico tch WHERE tch.co_contrato_fies = tfc.co_contrato_fies ORDER BY co_contrato_fies_historico DESC LIMIT 1) co_contrato_fies_historico,
                               now() AS dt_ajuste,
                               'D'::CHAR(1) AS tp_operacao,
                               tfcpe.st_aditamento,  -- Ã‰ ou NÃƒO um aditamento?
                               NULL AS co_aditamento,
                               tfcpe.co_calculo,
                               9 AS co_tipo_ajuste_calculo, -- TIPO 9 = DEMANDA JUDICIAL / TIPO 10 = CANCELAMENTO DE CONTRATO / 11 = DEMANDA EXTRAJUDICIAL
                               43 AS co_aprovacao_ajuste, -- Ã‰ o registro com a APROVAÃ‡ÃƒO e JUSTIFICATIVA do AJUSTE
                               tfcpe.nu_mes_referencia,
                               tfcpe.nu_ano_referencia,
                                    tfcpe.vl_mensalidade, -- tem que calcular para os crÃ©ditos
                               COALESCE(tfcpe.st_suspensao,0),
                               tfcpe.lg_fgeduc,
                               tfcpe.co_termo_fgeduc,
                               tfcpe.dt_fim_termo,
                               tfcpe.dt_aceite_fgeduc,
                               now() AS dt_criacao,
                               'ABDA' ds_usuario,
                               tfcpe.co_aditamento_origem,
                               tfcpe.dt_aditamento,
                               tfcpe.co_regra_fgeduc
                FROM 
                               financeiro.tb_fies_contrato tfc
                               INNER JOIN inscricao.tb_fies_termo_financiamento ttf ON ttf.co_inscricao = tfc.co_inscricao
                               INNER JOIN inscricao.tb_fies_inscricao tfi ON tfi.co_inscricao = tfc.co_inscricao
                               INNER JOIN financeiro.tb_fies_calculo_processo_emissao_cfte tfcpe ON tfcpe.co_contrato_fies = tfc.co_contrato_fies --AND tfcpe.st_aditamento = 1
                               --INNER JOIN financeiro.tb_fies_aditamento_contrato tfac on tfcpe.co_contrato_fies = tfac.co_contrato_fies 
                               --      and tfac.nu_semestre_aditamento = 2 
    --      and tfac.nu_ano_aditamento = 2015
                               --LEFT OUTER JOIN inscricao.tb_fies_aditamento AS tfa ON tfa.co_inscricao = tfc.co_inscricao  AND tfa.co_finalidade_aditamento = 2
                where  
                        tfc.co_contrato_fies = 1656930
                               --and tp_operacao = 'D' AND co_ajuste in (249623, 249624, 249625, 249626, 249627, 249628)
                               and nu_mes_referencia in (7,8,9,10,11,12) 
                               and nu_ano_referencia = 2018
                ORDER BY
                               tfc.co_contrato_fies,
                               tfcpe.nu_mes_referencia,
                               tfcpe.nu_ano_referencia;
							   
/*
RECUPERAR CONTROLE DE VAGAS DA INSCRIÇÃO
*/

begin;

INSERT into fies_preinscricao.tb_pre_historico_inscricao 
(co_historico_inscricao, co_situacao_inscricao, co_tipo_vencimento, co_inscricao, dt_historico_inscricao) 
values (fies_preinscricao.sq_pre_historico_inscricao.NEXTVAL, 4, 1, 623363, sysdate);

INSERT INTO inscricao.tb_fies_controle_vaga_pre_inscricao
select
            nextval('inscricao.tb_fies_controle_vaga_pre_ins_co_controle_vaga_pre_inscrica_seq'), 20172, co_mantenedora, 
            co_ies, co_campus, co_curso, co_turno, 'Liminar', 4832830., 
            now(), now()+90, 4662571, 
            true, null, null
 from inscricao.tb_fies_controle_vaga_pre_inscricao
 where co_controle_vaga_pre_inscricao = 972906;

update fies_preinscricao.tb_pre_inscricao set co_situacao_inscricao = 3, co_tipo_vencimento = null where co_inscricao = 4832830.;

INSERT INTO inscricao.tb_fies_liminar
select
            nextval('inscricao.tb_fies_liminar_co_liminar_seq'), nu_liminar, dsc_liminar, co_semestre_aditamento, 
            dt_inicio_validade, '2018-06-19', nu_processo, no_vara, ds_detalhamento_liminar, 
            co_tipo_liminar, st_encerrado, tp_classe
from inscricao.tb_fies_liminar where co_liminar = 2472;

update inscricao.tb_fies_liminar set dt_fim_validade = '2018-06-19' where co_liminar = 2472;

insert into inscricao.tb_fies_implicacao_liminar values (nextval('inscricao.tb_fies_implicacao_liminar_co_implicacao_liminar_seq'),
currval('inscricao.tb_fies_liminar_co_liminar_seq'), 10);

insert into inscricao.tb_fies_liminar_liberacao_vagas
values(currval('inscricao.tb_fies_implicacao_liminar_co_implicacao_liminar_seq'), currval('inscricao.tb_fies_liminar_co_liminar_seq'), 'S', null, null, null, null );

insert into inscricao.tb_fies_abrangencia_liminar
select 
nextval('inscricao.tb_fies_abrangencia_liminar_co_abrangencia_liminar_seq'),currval('inscricao.tb_fies_liminar_co_liminar_seq'),tp_abrangencia,nu_cpf,co_cidade,co_uf,co_mantenedora,co_ies,co_campus
from inscricao.tb_fies_abrangencia_liminar
where co_abrangencia_liminar = 14973;

update inscricao.tb_fies_inscricao set co_situacao_inscricao = 1, nu_semestre_referencia = '22017' where nu_cpf = '60754956300';

commit;					