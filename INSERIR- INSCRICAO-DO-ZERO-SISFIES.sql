/* Demanda judicial 16231
GABRIELLE SANTOS STUTZ GOMES – CPF: 01540935566*/

 begin
raise notice 'INICIO DA TRANSACAO.';
--INSTRUCOES SLQ

-- AQUI DEVEM IR AS INSTRUÇÕES (UPDATE’S, INSERT’S, ETC)

-- INSERIR PRÉ-USUARIO
INSERT INTO fies_preinscricao.tb_pre_usuario(
            co_usuario, co_pessoa, dt_cadastro, ds_senha, dt_ultimo_acesso, 
            ds_token)
    VALUES (6853610., 13896530., '2018-07-16 17:14:43', '1b45e64064dba5628aae4ce3a7016f62e2d3967e', '2018-07-16 17:14:43', 
            'd41dadc39bde627778defb0215d91dcc');

-- INSERIR COMPLEMENTO PESSOA FISICA
INSERT INTO fies_global.tb_glb_compl_pessoa_fisica(
            co_compl_pessoa_fisica, co_pessoa, co_estado_civil, sg_uf_org_emissor, 
            co_municipio, sg_uf, co_cbo, co_deficiencia, co_raca_cor, st_possui_deficiencia, 
            ds_email, dt_cadastro, nu_cep, ds_logradouro, no_bairro, nu_logradouro, 
            ds_complemento, nu_identidade, nu_ric, nu_tel_residencial, nu_celular, 
            co_orgao_expedidor, dt_emissao_identidade, ds_email_alternativo, 
            ds_tipo_logradouro, no_social, nu_tel_comercial)
    VALUES (12259649., 13896530., 1, 'BA', 
            2927408, 'BA', NULL, NULL, 4, 'N', 
            'gabistutz@yahoo.com.br', NOW, '41810-045', 'Rubem Berta', 'Pituba', '240', 
            'Apt 301', 1003735690, NULL, '7130180345', '71982589760', 
            10, '2015-01-25 00:00:00', null, 
            'Rua', null, null);

-- INSERIR REGISTRO GRUPO FAMILIAR
INSERT INTO FIES_PREINSCRICAO.TB_PRE_GRUPO_FAMILIAR (CO_GRUPO_FAMILIAR,CO_INSCRICAO,CO_PESSOA,CO_PESSOA_SEM_CPF,CO_GRAU_PARENTESCO,VL_RENDA_BRUTA)
VALUES (13752463, 10586877, 14322412, NULL, 2, 0);

-- INSERIR USUSARIO SEMESTRE
INSERT INTO fies_preinscricao.tb_pre_usuario_semestre(
            co_usuario, co_semestre, co_compl_pessoa_fisica, st_ativo)
    VALUES (6853610, 20172., 12259649., 'S');


-- INSERIR PRÉ-INSCRICAÇÃO

INSERT INTO fies_preinscricao.tb_pre_inscricao(
            co_inscricao, co_semestre, co_usuario, co_situacao_inscricao, 
            st_tipo_concorrencia, dt_cadastro, dt_conclusao, vl_renda_individual, 
            st_escola_publica, st_concorrer_professor, no_escola, co_municipio_escola, 
            st_rede_ensino_escola, ds_matr_inst_prof_escola, ds_area_atuacao_escola, 
            st_concluiu_ensino_superior, nu_indice_classificacao, nu_rank_com_enem, 
            nu_rank_sem_enem, ds_povo_indigena, ds_terra_indigena, vl_renda_familiar_per_capita, 
            nu_ano_conclusao_ens_medio, st_declaracao_professor, co_tipo_vencimento, 
            st_possui_matricula, dt_possui_matricula, nu_aba, co_historico_inscricao, 
            co_fato_inscricao_enem, vl_media_geral, nu_nota_final_red, nu_nota_linguas, 
            nu_nota_matematica, nu_nota_ciencias_naturais, nu_nota_ciencias_humanas, 
            tp_contrato_sisfies)
    VALUES (10586877., 20172., 6853610., 3, 
            'Enem', now, now, '4006.48', 
            'P', 'N', null, null, 
            null, null, null, 
            'S', null, null, 
            null, null, null, '2003.24', 
            '2002', 'N', null, 
            null, null, 6, 67136395, 
            454452817, '694.2', '900', '610.1', 
            '668', '675.7', '617.2', 
            0);

 -- INSERIR USUARIO INSCRICAO
 INSERT INTO inscricao.tb_fies_usuario_inscricao(
            co_usuario_inscricao, nu_cpf, no_usuario, ds_email, ds_senha, 
            dt_inclusao, dt_ultimo_acesso, st_usuario_ativo, ds_hash, dt_nascimento, 
            sg_sexo, nu_consultas_receita, dt_ultima_consulta_receita, co_semestre_aditamento, 
            no_social_candidato)
    VALUES (nextval('inscricao.tb_fies_usuario_inscricao_co_usuario_inscricao_seq'), '01540935566', 'GABRIELLE SANTOS STUTZ GOMES', 'gabistutz@yahoo.com.br', 
            '1b45e64064dba5628aae4ce3a7016f62e2d3967e', 
            NOW, NOW, 'S', NULL, '1984-08-22', 
            'F', null, null, null, 
            null);
 
 -- INSERIR INSCRIÇÃO
 INSERT INTO inscricao.tb_fies_inscricao(
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
			co_tipo_fianca, tp_contrato, co_seguradora, tp_usuario)
			
    VALUES (
	        nextval('inscricao.tb_fies_inscricao_co_inscricao_seq'), currval('inscricao.tb_fies_usuario_inscricao_co_usuario_inscricao_seq'), '01540935566', 
			'N', '0.00', '1003735690', 
			'SSPBA', '2005-01-25', '001', 
            1, NULL, NULL, 
			'4960.48', '4006.48', '2927408', 
			'29', 'RUA RUBEN BERTA', 'EDÍFICIO ANA CRISTINA', 
			'PITUBA', '240', '41810045', 
			'71', '30180345', '71',
			'71', 'B', 'N', 
			null, 'S', null, 
			null, '3183', '53', 
			'000000002927408', 1, now, 
			'104', null, 'N', 
            10, 'BA', 0, 
            null, now, null, 
			'22018', null, null,
			null, null, 0, 
			null, '2002', 1, 
			null, null, null, 
			2318649, null, null, 
            null, 'S', null, 
            null, null, null, 3,1, null, 1);

 
 -- INSERIR CURSO ASSOCIADO
insert into inscricao.tb_fies_curso_associado 
SELECT nextval('inscricao.tb_fies_curso_associado_co_curso_associado_seq'), '01540935566', co_curso, co_turno, co_mantenedora, 
       co_ies, co_campus, sg_uf, co_municipio, dt_inclusao, currval('inscricao.tb_fies_usuario_inscricao_co_usuario_inscricao_seq'), 
       vl_avaliacao_cc, vl_avaliacao_cpc, vl_avaliacao_enade, nu_nota_avaliacao, 
       nu_nota_utilizada_inscricao
  FROM inscricao.tb_fies_curso_associado WHERE co_curso_associado = 5581471;
 
 
 -- INSERIR TERMO DE FINANCIAMENTO
INSERT INTO inscricao.tb_fies_termo_financiamento(

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
            nu_percent_max_financ, vl_salario_referencia_curso
            )
    VALUES (
            currval('inscricao.tb_fies_inscricao_co_inscricao_seq'), currval ('inscricao.tb_fies_curso_associado_co_curso_associado_seq'), '0.00',
	    '0004439', '46800.00', '46800.00', 
	    0, '1653.49', 0.00, 
	    6, '100.00', 'N', 
            10074, 12, '46800.00', 
            '561600.00', 'R', now, 
            null, 'R', now,
            now()+90, null, null, 
            null, null, null, 
            null, 15521, 15521,
            '46800.00', '46800.00', null, 
            '702000.00', null, 12, 
            12, '702000.00', null, 
            null, null, now, 
            null, null, '46800.00', null, '7800.00');
 

-- INSERIR CONTROLE DE VAGAS DA PRÉ-INSCRIÇÃO
INSERT INTO inscricao.tb_fies_controle_vaga_pre_inscricao
select
            nextval('inscricao.tb_fies_controle_vaga_pre_ins_co_controle_vaga_pre_inscrica_seq'), 20172, co_mantenedora, 
            co_ies, co_campus, co_curso, co_turno, 'Liminar', 10586877., 
            now(), now()+90, currval('inscricao.tb_fies_inscricao_co_inscricao_seq'), 
            true, null, null
 from inscricao.tb_fies_controle_vaga_pre_inscricao
 where co_controle_vaga_pre_inscricao = 1011159;

 
 -- INSERIR PRORROGAÇÃO DE INSCRIÇÃO
 insert into inscricao.tb_fies_pergunta_insc_prorroga
(co_semestre_aditamento, co_inscricao, co_pergunta_opcao, 
co_usuario_ssd, dt_pergunta_inscricao_prorrogad, nu_semestre_prorrogado)
values 
(60, currval('inscricao.tb_fies_inscricao_co_inscricao_seq'), 25, 1796507, now, '22018');
 

commit;
raise notice 'TRANSAÇÃO COMPLETA!!!!!!!!!!';
--TRATAMENTO DE ERRO
exception when others then
        rollback;
        raise notice 'ROLLBACK aplicado!!!!!!!!!!';
        raise exception '% %', SQLERRM, SQLSTATE;
end;

 
 
 
 
 
 
 
 
 
 
 
            



