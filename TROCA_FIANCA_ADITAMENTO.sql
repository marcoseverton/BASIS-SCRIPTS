
BEGIN
RAISE NOTICE 'INICIO DA TRANSACAO.';

DECLARE 

	V_CO_FIADOR INT;
	V_CPF_ESTUDANTE VARCHAR := '47406178115';
	V_NOME_FIADOR VARCHAR := 'ARACI RODRIGUES FREIRE'; 
	V_CPF_FIADOR_ATUAL VARCHAR := '53575601100';
	V_RENDA_FIADOR NUMERIC := 2658.73;
	V_CO_ESTADO_CIVIL_FIADOR INT := 1; 
	
	rec RECORD;

BEGIN



FOR rec IN

	select a.co_aditamento, fa.nu_cpf as cpf_fiador, co_inscricao
	 from inscricao.tb_fies_aditamento a,
	inscricao.tb_fies_fiador_aditamento fa 
	where a.co_aditamento = fa.co_aditamento and
				a.nu_cpf = V_CPF_ESTUDANTE ORDER BY CO_SEMESTRE_ADITAMENTO DESC LIMIT 1

LOOP 

	delete inscricao.tb_fies_fiador_inscricao where co_inscricao = REC.CO_INSCRICAO;
	delete inscricao.tb_fies_fiador_aditamento where co_aditamento = REC.CO_ADITAMENTO;

	INSERT INTO INSCRICAO.TB_FIES_FIADOR_INDIVIDUAL(
	co_fiador,  nu_cpf, vl_renda_comprovada, st_confirmacao_banco)
	VALUES (NEXTVAL('inscricao.tb_fies_fiador_aditamento_co_fiador_seq'),V_CPF_FIADOR_ATUAL, V_RENDA_FIADOR,'S')
	RETURNING CO_FIADOR INTO V_CO_FIADOR;

	INSERT INTO inscricao.tb_fies_fiador_aditamento(
	co_fiador, co_aditamento, nu_cpf, no_fiador, vl_renda_informada,
	vl_renda_comprometida, co_estado_civil, nu_cpf_conjuge, no_conjuge,
	dt_inclusao, sg_pais, nu_rg, ds_orgao_emissor)
	VALUES (V_CO_FIADOR,REC.CO_ADITAMENTO,V_CPF_FIADOR_ATUAL,V_NOME_FIADOR,V_RENDA_FIADOR,
	0,V_CO_ESTADO_CIVIL_FIADOR,null,null,
	now,null,null,null);

	INSERT INTO inscricao.tb_fies_fiador_inscricao(
	co_fiador,
	co_inscricao,
	nu_cpf,
	no_fiador,
	vl_renda_informada,
	vl_renda_contratada,
	vl_renda_comprometida,
	co_estado_civil,
	nu_cpf_conjuge,
	no_conjuge,
	dt_inclusao,
	sg_pais,
	nu_rg,
	ds_orgao_emissor)
	VALUES (V_CO_FIADOR,REC.CO_INSCRICAO,V_CPF_FIADOR_ATUAL,V_NOME_FIADOR,V_RENDA_FIADOR, V_RENDA_FIADOR,
	0,V_CO_ESTADO_CIVIL_FIADOR,null,null,
	now,null,null,null);


END LOOP;
END;
rollback;
--COMMIT;
RAISE NOTICE 'TRANSAÇÃO COMPLETA!!!!!!!!!!';
--TRATAMENTO DE ERRO
EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RAISE NOTICE 'ROLLBACK APLICADO!!!!!!!!!!';
        RAISE EXCEPTION '% %', SQLERRM, SQLSTATE;
END;