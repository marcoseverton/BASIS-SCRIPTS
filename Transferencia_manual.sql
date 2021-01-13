
declare
v_co_aditamento integer;
v_co_curso_associado_aditamento integer;

begin
raise notice 'INICIO DA TRANSACAO.';

INSERT INTO inscricao.tb_fies_aditamento
SELECT
nextval('inscricao.tb_fies_aditamento_co_aditamento_seq'), co_inscricao, 56, 54,
3, 'S',
inscricao.fn_fies_soma_dias_uteis(now, 10), --dt_limite_cpsa
NULL, --inscricao.fn_fies_soma_dias_uteis(now, 15), --dt_limite_comparecimento_banco
NULL, --inscricao.fn_fies_soma_dias_uteis(now, 20), --dt_limite_retorno_AF
now(), --dt_validacao_cpsa
nu_cpf, st_bolsista_prouni,
nu_percentual_prouni, nu_rg, ds_orgao_emissor, dt_emissao, co_ocupacao,
co_estado_civil, nu_cpf_conjuge, no_conjuge, vl_renda_familiar_bruta_mensal,
vl_renda_pessoal_bruta_mensal, co_cidade, co_uf, ds_logradouro,
ds_logradouro_comp, ds_bairro, ds_numero, nu_cep, nu_ddd_telefone_residencial,
nu_telefone_residencial, nu_ddd_telefone_celular, nu_telefone_celular,
sg_raca_cor, st_deficiencia, co_tipo_deficiencia, '22016', -- semestre referencia
co_curso_associado_aditamento, vl_taxa_juros_anual, nu_matricula, -- numero da matricula
vl_semestre_sem_desconto, vl_semestre_com_desconto, 0, -- qt_semestre_concluido
vl_renda_per_capita, nu_percentual_comprometimento, qt_meses_financ_semestre_atual,
nu_percent_solicitado_financ, st_financiar_integralidade_semestre,
co_tipo_periodicidade, qt_periodicidade, vl_financiamento_exercicio,
vl_financiamento_global, now(), co_mantenedora, vl_financiado_semestre,
vl_semestre_atual, vl_saldo_aumento_semestralidade, vl_limite_global,
null, null, co_motivo_rejeicao,
ds_justificativa_validacao, co_usuario_inscricao, st_aproveitamento_academico,nu_ric, 17, -- qt_semestre_financiamento
now(), st_passo_aditamento,tp_origem_financiamento_global, vl_global_fgeduc, dt_inicio_comparecimento_banco,
co_origem_ds_bairro, st_aprovacao_aluno, now(),
co_curso_associado_aditamento, -- co_curso_associado_aditamento_origem
'C',
null, --dt_validacao_cpsa_destino
inscricao.fn_fies_soma_dias_uteis(now, 10), --dt_limite_cpsa_destino
'2016-06-30', -- dt_desligamento 
17, -- qt_semestres_curso_destino
qt_semestres_curso_origem, nu_percent_solicitado_financ_original,
'N', nu_consultas_receita, dt_ultima_consulta_receita,
co_usuario_ssd, st_migrado, st_troca_fianca, co_tipo_fianca,
st_alteracao_bolsa_prouni, st_elevacao_perc_prouni, st_direito_troca_fianca,
st_dados_atualizados,
st_aditamento_preliminar, vl_ultrapassado_margem_preliminar, vl_autorizado_ajuste, vl_financiado_preliminar, dt_validacao_preliminar,
co_tipo_preliminar, 1, -- nu_semestre_a_cursar
vl_semestralidade_para_fies, co_orgao_expedidor, sg_uf_expedidor, st_envia_af
FROM inscricao.tb_fies_aditamento
WHERE co_aditamento = 10994220
returning co_aditamento into v_co_aditamento;

INSERT INTO inscricao.tb_fies_curso_associado_aditamento
select nextval('inscricao.tb_fies_curso_associado_adita_co_curso_associado_aditamento_seq'), 
nu_cpf, 1259204, -- co_curso
10070, -- co_turno
1775, -- co_mantenedora
1775, -- co_ies
658755, -- co_campus
'PE' , -- sg_uf
'2604106', -- co_municipio
now(), co_usuario_inscricao,
17, -- qt_semestre_financiamento_destino
NULL, v_co_aditamento
from inscricao.tb_fies_curso_associado_aditamento
where co_curso_associado_aditamento = 10994220
returning co_curso_associado_aditamento into v_co_curso_associado_aditamento;

update inscricao.tb_fies_aditamento set co_curso_associado_aditamento = v_co_curso_associado_aditamento where co_aditamento = v_co_aditamento;

update inscricao.tb_fies_curso_associado set 
co_mantenedora = 1179, 
co_ies = 1179, 
co_curso = 1259204, 
co_campus = 658755, 
co_turno = 10070, 
co_municipio = '2604106', 
vl_avaliacao_enade = 3
where nu_cpf = '09269671429';

update inscricao.tb_fies_termo_financiamento set qt_semestre_concluido = 0, co_mantenedora = 1179, qt_semestre_financiamento = 17 where co_inscricao = 2712006;

commit;
raise notice 'TRANSAÇÃO COMPLETA!!!!!!!!!!';
--TRATAMENTO DE ERRO
exception when others then
rollback;
raise notice 'ROLLBACK aplicado!!!!!!!!!!';
raise exception '% %', SQLERRM, SQLSTATE;
end;