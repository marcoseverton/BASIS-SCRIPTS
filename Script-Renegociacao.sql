﻿/*FNDE - #Renegociação de contrato - FIES - Sisfies Aluno
Ordem de trabalho # WO1320384*/

DECLARE
V_CPF VARCHAR :=  '01109300107';
--VALOR CONTRATADO D
V_VL_CONTRATADO VARCHAR := '7947.66';
--VALOR DO SALDO DEVEDOR CALCULADO E
V_VL_SALDO_DEVEDOR_TOTAL VARCHAR := '5710.54';
--PRAZO FASE DE UTILIZAçãO D
V_NU_PRAZO_FASE_UTILIZACAO VARCHAR :=  '054';
--INíCIO UTILIZAçãO D
V_DT_INI_FASE_UTILIZACAO VARCHAR := '10012009';
--FIM UTILIZAçãO D
V_DT_FIM_FASE_UTILIZACAO VARCHAR :=  '10072013';
--PRAZO DA CARêNCIA D
V_NU_PRAZO_CARENCIA VARCHAR :=  '19';
--INíCIO CARêNCIA D
V_DT_INI_CARENCIA VARCHAR :=  NULL;
--PRAZO DE AMORTIZAçãO I D
V_NU_PRAZO_FASE_AMORTIZACAO_1 VARCHAR := '012';
--INíCIO DE AMORTIZAçãO I D
V_DT_INI_FASE_AMORTIZACAO_1 VARCHAR := '10022015';
--PRAZO DE AMORTIZAçãO II D
V_NU_PRAZO_FASE_AMORTIZACAO_2 VARCHAR :='096';
--INíCIO DE AMORTIZAçãO II D
V_DT_INI_FASE_AMORTIZACAO_2 VARCHAR := '10022016';
--DATA DE FIM DO CONTRATO D
V_DT_FIM_CONTRATOD VARCHAR := '05122008';
--DATA DE FIM DO CONTRATO E
V_DT_FIM_CONTRATOE DATE := '2024-02-10';
--VALOR DE CAPITAL DOS EXTRATOS NãO PAGOS (R$) REMOVER
--JURO DOS EXTRATOS NãO PAGOS (R$) REMOVER
--DIA DE VENCIMENTO DAS PRESTAçõES E
V_NU_DIA_VENCIMENTO SMALLINT :=  10;
--VALOR DAS PRESTAçõES EM ATRASO (R$) E
V_VL_PRESTACAO_ATRASO VARCHAR :=  '0.00';
--VALOR DAS PRESTAçõES VINCENDAS (R$) E
V_VL_PRESTACAO_VINCENDA VARCHAR := '5023.32';
--DATA DO úLTIMO SALDO DEVEDOR TOTAL E
V_DT_SALDO_DEVEDOR_TOTAL TIMESTAMP := '2020-08-31';
--VALOR DA PRESTAçãO MENSAL (R$) E
V_VL_PRESTACAO_MENSAL VARCHAR := 122.52;
--PRAZO DE AMORTIZAçãO REMANESCENTE E
V_NU_PRAZO_AMORTIZACAO_REMANESCENTE VARCHAR := '41';
--PRAZO DE AMORTIZAçãO TRANSCORRIDA E
V_NU_PRAZO_AMORTIZACAO_TRANSCORRIDO VARCHAR := '055';
--VALOR DEVIDO EXTRATO E
V_VL_DEVIDO_EXTRATO VARCHAR := '0.00';
	

BEGIN
   RAISE NOTICE 'INICIO DA TRANSACAO.';
   RAISE NOTICE '';
   
	FOR REC IN 
	SELECT COUNT (*) FROM(
		SELECT E.NU_CPF,VL_CONTRATADO,VL_SALDO_DEVEDOR_TOTAL,NU_PRAZO_FASE_UTILIZACAO,DT_INI_FASE_UTILIZACAO,DT_FIM_FASE_UTILIZACAO,NU_PRAZO_CARENCIA,DT_INI_CARENCIA,NU_PRAZO_FASE_AMORTIZACAO_1,DT_INI_FASE_AMORTIZACAO_1,
		NU_PRAZO_FASE_AMORTIZACAO_2,DT_INI_FASE_AMORTIZACAO_2,D.DT_FIM_CONTRATO,E.DT_FIM_CONTRATO,NU_DIA_VENCIMENTO,VL_PRESTACAO_ATRASO,VL_PRESTACAO_VINCENDA,VL_SALDO_DEVEDOR_TOTAL,DT_SALDO_DEVEDOR_TOTAL,VL_PRESTACAO_MENSAL
		NU_PRAZO_AMORTIZACAO_REMANESCENTE,NU_PRAZO_AMORTIZACAO_TRANSCORRIDO,VL_DEVIDO_EXTRATO FROM  RENEGOCIA.TB_FIES_RENEGOCIA_EXTRATO_CONTRATO E
		INNER JOIN RENEGOCIA.TB_FIES_DADOS_CONTRATOS D ON D.NU_CPF_CNPJ = E.NU_CPF
		WHERE E.NU_CPF = V_CPF)
	
		

		 
	LOOP

	IF REC.COUNT > 0 THEN

	UPDATE RENEGOCIA.TB_FIES_DADOS_CONTRATOS
	SET VL_CONTRATADO = V_VL_CONTRATADO,
	NU_PRAZO_FASE_UTILIZACAO = V_NU_PRAZO_FASE_UTILIZACAO,
	DT_INI_FASE_UTILIZACAO = V_DT_INI_FASE_UTILIZACAO,
	DT_FIM_FASE_UTILIZACAO = V_DT_FIM_FASE_UTILIZACAO,
	NU_PRAZO_CARENCIA = V_NU_PRAZO_CARENCIA,
	DT_INI_CARENCIA = V_DT_INI_CARENCIA,
	NU_PRAZO_FASE_AMORTIZACAO_1 = V_NU_PRAZO_FASE_AMORTIZACAO_1,
	DT_INI_FASE_AMORTIZACAO_1 = V_DT_INI_FASE_AMORTIZACAO_1,
	NU_PRAZO_FASE_AMORTIZACAO_2 = V_NU_PRAZO_FASE_AMORTIZACAO_2,
	DT_INI_FASE_AMORTIZACAO_2 = V_DT_INI_FASE_AMORTIZACAO_2,
	DT_FIM_CONTRATO = V_DT_FIM_CONTRATOD
	WHERE NU_CPF_CNPJ = V_CPF;	
	
	UPDATE RENEGOCIA.TB_FIES_RENEGOCIA_EXTRATO_CONTRATO
	SET VL_SALDO_DEVEDOR_TOTAL = V_VL_SALDO_DEVEDOR_TOTAL,
	DT_FIM_CONTRATO = V_DT_FIM_CONTRATOE,
	NU_DIA_VENCIMENTO = V_NU_DIA_VENCIMENTO,
	VL_PRESTACAO_ATRASO = V_VL_PRESTACAO_ATRASO,
	VL_PRESTACAO_VINCENDA = V_VL_PRESTACAO_VINCENDA,
	DT_SALDO_DEVEDOR_TOTAL = V_DT_SALDO_DEVEDOR_TOTAL,
	VL_PRESTACAO_MENSAL = V_VL_PRESTACAO_MENSAL,
	NU_PRAZO_AMORTIZACAO_REMANESCENTE = V_NU_PRAZO_AMORTIZACAO_REMANESCENTE,
	NU_PRAZO_AMORTIZACAO_TRANSCORRIDO = V_NU_PRAZO_AMORTIZACAO_TRANSCORRIDO,
	VL_DEVIDO_EXTRATO = V_VL_DEVIDO_EXTRATO
	WHERE NU_CPF = V_CPF;

	ELSE 

	RAISE NOTICE 'NÃO EXISTE RENEGOCIAÇÃO - INSERIR MANUALMENTE';

	END IF;	

	IF	(SELECT
		CASE
		WHEN (SUBSTR(DT_ASSINATURA,5,4)||'-'||SUBSTR(DT_ASSINATURA,3,2)||'-'||SUBSTR(DT_ASSINATURA,1,2))::DATE <= '2010-01-14' THEN 'ACEITA'
		ELSE 'NÃO ACEITA'
		END::VARCHAR(50) AS DS_FASE
		FROM
		RENEGOCIA.TB_FIES_DADOS_CONTRATOS
		WHERE
		NU_CPF_CNPJ = V_CPF)  = 'ACEITA' THEN 

	RAISE NOTICE 'DATA DE  ASSINATURA É MENOR QUE 2010-01-14 - ESTÁ CORRETO';
	ELSE
	
	RAISE NOTICE 'DATA DE  ASSINATURA É MAIOR QUE 2010-01-14 - ESTÁ ERRADO';
	END IF;
	
	IF (SELECT
		CASE
		WHEN CO_SITUACAO = '32' OR CO_SITUACAO = '33' THEN 'ACEITA'
		ELSE 'NÃO ACEITA'
		END::VARCHAR(50) AS DS_PERMITE_RENEGOCIAçãO
		FROM
		RENEGOCIA.TB_FIES_DADOS_CONTRATOS
		WHERE
		NU_CPF_CNPJ = V_CPF)  = 'ACEITA' THEN 

		RAISE NOTICE 'CO_SITUACAO É 32 - FASE AMORTIZACAO I (FIES) OU 33 - FASE AMORTIZACAO II (FIES)- ESTÁ CORRETO';
		ELSE
			
		RAISE NOTICE 'DS_PERMITE_RENEGOCIAçãO ESTÁ ERRADO';
		END IF;

	IF (SELECT
		CASE
		WHEN VL_PRESTACAO_MENSAL::NUMERIC(12,2) > 100.00 THEN 'ACEITA'
		ELSE 'NÃO ACEITA'
		END::VARCHAR(50) AS DS_PERMITE_RENEGOCIACAO
		FROM
		RENEGOCIA.TB_FIES_RENEGOCIA_EXTRATO_CONTRATO
		WHERE NU_CPF = V_CPF)  = 'ACEITA' THEN 

		RAISE NOTICE 'VL_PRESTACAO_MENSAL É MAIOR QUE 100.00  - ESTÁ CORRETO';
		ELSE
			
		RAISE NOTICE 'VL_PRESTACAO_MENSAL É MENOR QUE 100.00 -  ESTÁ ERRADO';
		END IF;

		IF (SELECT
			CASE
			WHEN NU_PRAZO_FASE_AMORTIZACAO_1 + NU_PRAZO_FASE_AMORTIZACAO_2 <= (NU_PRAZO_FASE_UTILIZACAO * 3)+12
			THEN 'ACEITA'
			ELSE 'NÃO ACEITA'
			END::VARCHAR(50) AS DS_PERMITE_ALONGAMENTO_PRAZO
			FROM RENEGOCIA.TB_FIES_DADOS_CONTRATOS WHERE NU_CPF_CNPJ = V_CPF)  = 'ACEITA' THEN 

		RAISE NOTICE 'NU_PRAZO_FASE_AMORTIZACAO_1 + NU_PRAZO_FASE_AMORTIZACAO_2 <= (NU_PRAZO_FASE_UTILIZACAO * 3)+12 - ESTÁ CORRETO';
		ELSE
			
		RAISE NOTICE 'NU_PRAZO_FASE_AMORTIZACAO_1 + NU_PRAZO_FASE_AMORTIZACAO_2 <= (NU_PRAZO_FASE_UTILIZACAO * 3)+12 -  ESTÁ ERRADO';
		END IF;
		
		IF (SELECT 
			CASE
			WHEN ST_ASSINATURA_POSTERIOR = 'N'
			AND ST_UTILIZACAO_CARENCIA = 'S'
			AND ST_AMORTIZACAO_ATUAL = 'S'
			THEN 'ACEITA'
			ELSE 'NÃO ACEITA'
			END::VARCHAR(50) AS REALIZAR_SIMULACAO
			FROM RENEGOCIA.TB_FIES_DADOS_CONTRATOS WHERE NU_CPF_CNPJ = V_CPF)  = 'ACEITA' THEN 

		RAISE NOTICE 'ST_ASSINATURA_POSTERIOR = N ST_UTILIZACAO_CARENCIA = S ST_AMORTIZACAO_ATUAL = S - ESTÁ CORRETO';
		ELSE
			
		RAISE NOTICE 'ST_ASSINATURA_POSTERIOR = N ST_UTILIZACAO_CARENCIA = S ST_AMORTIZACAO_ATUAL = S -  ESTÁ ERRADO';
		END IF;



	END LOOP;


--ROLLBACK;	
COMMIT;
   RAISE NOTICE '';
   RAISE NOTICE 'TRANSAÇÃO COMPLETA!!!!!!!!!!';
--TRATAMENTO DE ERRO
EXCEPTION 
   WHEN OTHERS THEN
      ROLLBACK;
      RAISE NOTICE '% %', SQLERRM, SQLSTATE;
END;