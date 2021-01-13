/*FNDE - #8219 - ANA CAROLINA SILVA BORGES 097.505.906-86 - FIES - Sisfies Aluno
Ordem de trabalho # WO1328845*/

 begin
raise notice 'INICIO DA TRANSACAO.';

delete tb_fies_acesso_usuario where co_usuario_inscricao  = 7721330;

 -- INSERIR USUARIO INSCRICAO
 update inscricao.tb_fies_usuario_inscricao set
            co_usuario_inscricao = 338228
 where nu_cpf = '09750590686'; 
  
 -- INSERIR INSCRIÇÃO
 INSERT INTO inscricao.tb_fies_inscricao 
 select 
            co_inscricao, co_usuario_inscricao, nu_cpf, 
			st_bolsista_prouni, nu_percentual_prouni, nu_rg, 
			ds_orgao_emissor, dt_emissao, co_ocupacao, 
            co_estado_civil, nu_cpf_conjuge, no_conjuge, 
			vl_renda_familiar_bruta_mensal, vl_renda_pessoal_bruta_mensal, co_cidade, 
			co_uf, ds_logradouro, ds_logradouro_comp, 
			ds_bairro, ds_numero, nu_cep, 
			nu_ddd_telefone_residencial, nu_telefone_residencial, nu_ddd_telefone_celular, 
			nu_telefone_celular, sg_raca_cor, st_deficiencia, 
			co_tipo_deficiencia, st_ensino_medio_escola_publica, st_atua_professor_rede_publica_basica, 
			vl_nota_enem_considerada, co_agencia, co_uf_agencia, 
			co_cidade_agencia, co_situacao_inscricao, dt_inclusao, 
			co_banco, dt_aceite_fianca_solidaria, st_migrado, 
            co_orgao_expedidor, sg_uf_expedidor, st_altera_renda_per_capita, 
            ds_codigo_verificacao, dt_aceite_fgeduc, nu_ric, 
			nu_semestre_referencia, st_declaracao_enem, st_declaracao_professor_rede_publica,
			co_aditamento, dt_aditamento, st_passo_inscricao, 
			st_declaracao_professor, nu_ano_conclusao_ensino_medio, co_origem_ds_bairro,
			st_autoriza_contrato, nu_consultas_receita, dt_ultima_consulta_receita, 
			co_usuario_ssd, nu_contrato_cx, dt_aceite_fgeduc_concomitante, 
            st_limite_financiamento, st_dados_atualizados, vl_renda_individual_conjuge, 
            st_bloqueado, st_nivel_superior, nu_semestre_a_cursar,
			co_tipo_fianca, tp_contrato, co_seguradora, 1
from auditoria.vw_lg_fies_inscricao 
where nu_cpf = '09750590686' and co_situacao_inscricao = 1 order by dt_log_alteracao desc limit 1;
 
 -- INSERIR CURSO ASSOCIADO
insert into inscricao.tb_fies_curso_associado 
select
	    co_curso_associado, nu_cpf, co_curso, co_turno, co_mantenedora, 
            co_ies, co_campus, sg_uf, co_municipio, dt_inclusao, co_usuario_inscricao, 
            vl_avaliacao_cc, vl_avaliacao_cpc, vl_avaliacao_enade, nu_nota_avaliacao, 
            nu_nota_utilizada_inscricao
FROM auditoria.vw_lg_fies_curso_associado where nu_cpf = '09750590686' order by dt_log_alteracao desc limit 1;

 
 -- INSERIR TERMO DE FINANCIAMENTO
INSERT INTO inscricao.tb_fies_termo_financiamento 
select
            co_inscricao, co_curso_associado, vl_taxa_juros_anual, 
            nu_matricula, vl_semestre_sem_desconto, vl_semestre_com_desconto, 
            qt_semestre_concluido, vl_renda_per_capita, nu_percentual_comprometimento, 
            qt_meses_financ_semestre_atual, nu_percent_solicitado_financ, st_financiar_integralidade_semestre, 
            co_tipo_periodicidade, qt_periodicidade, vl_financiamento_exercicio, 
            vl_financiamento_global, tp_origem_financiamento_global, dt_conclusao_inscricao, 
            dt_contratacao_financiamento, st_situacao_recurso_financiado, dt_inclusao, 
            dt_limite_cpsa, dt_limite_contratacao, dt_limite_retorno_agente_financ, 
            vl_financiamento_anterior_exercicio, vl_financiamento_anterior_global, tp_origem_financiamento_global_anterior, 
            dt_validacao_cpsa, co_mantenedora, co_mantenedora_anterior, 
            vl_financiado_semestre, vl_semestre_atual, vl_saldo_aumento_semestralidade, 
            vl_limite_global, vl_saldo_limite_global, qt_semestre_financiamento, 
            qt_semestres_curso, vl_global_fgeduc, ds_manutencao_registro, 
            nu_percent_solicitado_financ_anterior, dt_inicio_contratacao, dt_confirmacao_inscricao,
            dt_amortizacao_final_legado, dt_primeira_conclusao_inscricao, vl_semestralidade_para_fies, 
            nu_percent_max_financ--, vl_salario_referencia_curso
 from auditoria.vw_lg_fies_termo_financiamento 
 where co_inscricao = 258066 order by dt_log_alteracao desc limit 1;


commit;
raise notice 'TRANSAÇÃO COMPLETA!!!!!!!!!!';
--TRATAMENTO DE ERRO
exception when others then
        rollback;
        raise notice 'ROLLBACK aplicado!!!!!!!!!!';
        raise exception '% %', SQLERRM, SQLSTATE;
end;

 
 
 
 
 
 
 
 
 
 
 
            



