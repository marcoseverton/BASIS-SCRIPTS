
/*FNDE - #17136 - TERENCIO BARROS FERREIRA - 302.592.248-63 - FIES - Sisfies Aluno
Ordem de trabalho # WO1311862*/

begin
raise notice 'INICIO DA TRANSACAO.';

declare
 v_semestre numeric := 12018;
 v_cpf varchar := '30259224863';

begin

FOR REC IN 

select * from 
auditoria.vw_lg_fies_curso_associado ca,
auditoria.vw_lg_fies_termo_financiamento tf
where ca.nu_cpf = v_cpf and
ca.co_curso_associado = tf.co_curso_associado and
tf.dt_log_alteracao = '2018-03-13 23:46:01.356947' and
tf.co_inscricao = 5653497 limit 1

LOOP 
		
	-- EXCLUIR COMPROVANTES
	delete inscricao.tb_fies_comprovante where co_inscricao = 6481524; 
		
	update inscricao.tb_fies_usuario_inscricao set
	co_semestre_aditamento = 60
	where nu_cpf = v_cpf;

	UPDATE inscricao.tb_fies_curso_associado
	   SET 
	       co_curso= REC.co_curso,
	       co_turno= REC.co_turno, 
	       co_mantenedora= REC.co_mantenedora, 
	       co_ies= REC.co_ies,
	       co_campus= REC.co_campus, 
	       sg_uf= REC.sg_uf, 
	       co_municipio= REC.co_municipio, 
	       vl_avaliacao_cc= REC.vl_avaliacao_cc, 
	       vl_avaliacao_cpc= REC.vl_avaliacao_cpc, 
	       vl_avaliacao_enade= REC.vl_avaliacao_enade, 
	       nu_nota_avaliacao= REC.nu_nota_avaliacao, 
	       nu_nota_utilizada_inscricao= REC.nu_nota_utilizada_inscricao
	 WHERE nu_cpf = v_cpf;
		 
	update inscricao.tb_fies_inscricao set 
	co_situacao_inscricao = 3,
	nu_semestre_referencia = v_semestre
	where nu_cpf = v_cpf;
	 
	UPDATE inscricao.tb_fies_termo_financiamento
	   SET 
	       vl_taxa_juros_anual= REC.vl_taxa_juros_anual, 
	       nu_matricula= REC.nu_matricula, 
	       vl_semestre_sem_desconto= REC.vl_semestre_sem_desconto, 
	       vl_semestre_com_desconto= REC.vl_semestre_com_desconto, 
	       qt_semestre_concluido= REC.qt_semestre_concluido, 
	       vl_renda_per_capita= REC.vl_renda_per_capita, 
	       nu_percentual_comprometimento= REC.nu_percentual_comprometimento, 
	       qt_meses_financ_semestre_atual= REC.qt_meses_financ_semestre_atual, 
	       nu_percent_solicitado_financ= REC.nu_percent_solicitado_financ, 
	       st_financiar_integralidade_semestre= REC.st_financiar_integralidade_semestre,
	       co_tipo_periodicidade= REC.co_tipo_periodicidade, 
	       qt_periodicidade= REC.qt_periodicidade, 
	       vl_financiamento_exercicio= REC.vl_financiamento_exercicio, 
	       vl_financiamento_global= REC.vl_financiamento_global, 
	       tp_origem_financiamento_global= REC.tp_origem_financiamento_global, 
	       dt_conclusao_inscricao= REC.dt_conclusao_inscricao, 
	       dt_contratacao_financiamento= REC.dt_contratacao_financiamento, 
	       st_situacao_recurso_financiado= REC.st_situacao_recurso_financiado, 
	       dt_inclusao= REC.dt_inclusao, 
	       dt_limite_cpsa= REC.dt_limite_cpsa, 
	       dt_limite_contratacao= inscricao.fn_fies_soma_dias_uteis(now, 10), 
	       dt_limite_retorno_agente_financ= inscricao.fn_fies_soma_dias_uteis(now, 15), 
	       vl_financiamento_anterior_exercicio= REC.vl_financiamento_anterior_exercicio, 
	       vl_financiamento_anterior_global= REC.vl_financiamento_anterior_global, 
	       tp_origem_financiamento_global_anterior= REC.tp_origem_financiamento_global_anterior, 
	       dt_validacao_cpsa= now, 
	       co_mantenedora= REC.co_mantenedora, 
	       co_mantenedora_anterior= REC.co_mantenedora_anterior, 
	       vl_financiado_semestre= REC.vl_financiado_semestre, 
	       vl_semestre_atual= REC.vl_semestre_atual, 
	       vl_saldo_aumento_semestralidade= REC.vl_saldo_aumento_semestralidade, 
	       vl_limite_global= REC.vl_limite_global, 
	       vl_saldo_limite_global= REC.vl_saldo_limite_global, 
	       qt_semestre_financiamento= REC.qt_semestre_financiamento, 
	       qt_semestres_curso= REC.qt_semestres_curso, 
	       vl_global_fgeduc= REC.vl_global_fgeduc, 
	       ds_manutencao_registro= REC.ds_manutencao_registro, 
	       nu_percent_solicitado_financ_anterior= REC.nu_percent_solicitado_financ_anterior, 
	       dt_inicio_contratacao= REC.dt_inicio_contratacao, 
	       dt_confirmacao_inscricao= REC.dt_confirmacao_inscricao, 
	       dt_amortizacao_final_legado= REC.dt_amortizacao_final_legado, 
	       dt_primeira_conclusao_inscricao= REC.dt_primeira_conclusao_inscricao, 
	       vl_semestralidade_para_fies= REC.vl_semestralidade_para_fies, 
	       nu_percent_max_financ= REC.nu_percent_max_financ
	    WHERE co_inscricao = 6481524;

end loop;
end;


commit;
raise notice 'TRANSAÇÃO COMPLETA!!!!!!!!!!';
--TRATAMENTO DE ERRO
exception when others then
        rollback;
        raise notice 'ROLLBACK aplicado!!!!!!!!!!';
        raise exception '% %', SQLERRM, SQLSTATE;
end;

