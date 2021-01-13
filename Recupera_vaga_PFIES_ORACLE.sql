/*===========================================================================================================================*/
SET SERVEROUTPUT ON;
DECLARE        
    --PARAMETRO DE ENTRADA
    P_NU_CPF                     VARCHAR2(11):='86118908508'; 
    P_CO_INSCRICAO               NUMBER(10)  := 10498505;    
    P_CO_USUARIO                 NUMBER(10)  := 3014457;    
    P_TP_USUARIO                 NUMBER(1)   := 1; --REGULAR
    P_TP_VAGA                    NUMBER(1)   := 2; --PRIVADO
    P_CO_SEMESTRE                NUMBER(5)   := 20182;    
    P_CO_SEMESTRE_FINANCIAMENTO  NUMBER(5)   := 20182;
    P_CO_SITUACAO_INSCRICAO      NUMBER(2)   := 3; -- Contratato
    P_CO_SITUACAO_FINANCIAMENTO  NUMBER(2)   := 2; -- Contratato
        
        
    --VARIAVEIS
    V_CO_SITUACAO_FIN_ATUAL      NUMBER(10);
    V_CO_SITUACAO_FIN_RECUPERADA NUMBER(10);
    V_CO_MOTIVO_SITUACAO_REC     NUMBER(10);
    V_DT_DESOCUPACAO             DATE; 
    V_CO_INSCRICAO               NUMBER(10);
    V_CO_SEMESTRE                NUMBER(5);
    V_CO_USUARIO                 NUMBER(10);
    V_TP_USUARIO                 NUMBER(1);
    V_TP_VAGA                    NUMBER(1);
    V_CO_CLUSTER                 NUMBER(10);
    V_CO_H_CURSO                 NUMBER(10); 
    V_CO_CURSO                   NUMBER(10); 
    V_CO_TURNO                   NUMBER(10);
    V_NU_LINHA                   NUMBER(10);   
    V_CO_CLUSTER_VAGA_PUBLICO    VARCHAR2(50);
    V_CO_CLUSTER_VAGA_PRIVADO    VARCHAR2(50);
    V_CO_VAGA_PRIVADO            VARCHAR2(50); 
    V_CO_VAGA_PUBLICO            VARCHAR2(50);  
    --    
    V_RETORNO                    VARCHAR2(200);
    V_EXISTE                     NUMBER(10);
    V_VAGA_RECUPERADA            NUMBER(1):=0;
    V_TOTAL                      NUMBER(10):=0;

    
BEGIN
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------');  
    DBMS_OUTPUT.PUT_LINE('--|SIMEC Recuperar Vaga |--');  
    DBMS_OUTPUT.PUT_LINE('Inicio...'||to_char(sysdate,'YYYY-mm-dd HH24:MI:SS')||'.' );
    DBMS_OUTPUT.PUT_LINE(' ');     
    --   
    BEGIN   
    ----|INICIO

        --Recupera dados do cursor
        V_RETORNO       := '';
        --
        --VERIFICA SE CANDIDATO/INSCRICAO ESTA DESOCUPADA
        BEGIN    
            SELECT   CO.CO_SEMESTRE, CO.CO_USUARIO, CO.TP_USUARIO, CO.TP_VAGA, TO_DATE(TRUNC(CO.DT_DESOCUPACAO)) DT_DESOCUPACAO
            INTO      V_CO_SEMESTRE,  V_CO_USUARIO,  V_TP_USUARIO,  V_TP_VAGA, V_DT_DESOCUPACAO
            FROM     FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO CO                 
            WHERE    1 = 1
            AND      CO.TP_CHAMADA_OCUPACAO       = 3                            
            AND      CO.TP_VAGA                   = P_TP_VAGA
            AND      CO.TP_USUARIO                = P_TP_USUARIO
            AND      CO.CO_INSCRICAO              = P_CO_INSCRICAO;           
        EXCEPTION
            WHEN OTHERS THEN                                     
                V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"ESTA INSCRICAO NAO ESTA DESOCUPADA"}';    
        END;  
                    
        
        IF V_RETORNO IS NULL THEN 
            --RECUPERA OS DADOS DE CURSO, ULTIMO UTILIZADO PELA INSCRICAO INFORMADA.
            BEGIN
                SELECT 1 INTO V_VAGA_RECUPERADA FROM DUAL;
                SELECT   CO_CLUSTER,   CO_H_CURSO,   CO_CURSO,   CO_TURNO
                  INTO V_CO_CLUSTER, V_CO_H_CURSO, V_CO_CURSO, V_CO_TURNO
                  FROM (SELECT *
                          FROM FIES_PREINSCRICAO.TH_PRE_CHAMADA_OCUPACAO
                         WHERE 1 = 1 
                           AND TP_CHAMADA_OCUPACAO = 2
                           AND CO_INSCRICAO        = P_CO_INSCRICAO                       
                           AND CO_SEMESTRE         = V_CO_SEMESTRE
                           AND CO_USUARIO          = V_CO_USUARIO
                           AND TP_USUARIO          = V_TP_USUARIO
                           AND TP_VAGA             = V_TP_VAGA
                         ORDER BY DT_HISTORICO DESC)
                 WHERE ROWNUM = 1;         
            EXCEPTION
                WHEN OTHERS THEN  
                BEGIN         
                    V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"FALHA AO RECUPERAR HISTORICO DE OCUPACAO"}';                
                    SELECT 0 INTO V_VAGA_RECUPERADA FROM DUAL;
                END;    
            END;

            
            --RECUPERA OS DADOS DE CURSO, ULTIMO UTILIZADO PELA INSCRICAO INFORMADA A PARTIR DA AUDITORIA
            IF V_VAGA_RECUPERADA = 0 THEN
            BEGIN
                --
                V_RETORNO:= '';
                SELECT 1 INTO V_VAGA_RECUPERADA FROM DUAL;
                --
                SELECT   CO_CLUSTER,   CO_H_CURSO,   CO_CURSO,   CO_TURNO
                  INTO V_CO_CLUSTER, V_CO_H_CURSO, V_CO_CURSO, V_CO_TURNO
                  FROM (SELECT *
                          FROM FIES_AUDITORIA.LG_PRE_CHAMADA_OCUPACAO
                         WHERE 1 = 1 
                           AND TP_CHAMADA_OCUPACAO = 2
                           AND CO_INSCRICAO        = P_CO_INSCRICAO                       
                           AND CO_SEMESTRE         = V_CO_SEMESTRE
                           AND CO_USUARIO          = V_CO_USUARIO
                           AND TP_USUARIO          = V_TP_USUARIO
                           AND TP_VAGA             = V_TP_VAGA
                         ORDER BY DT_OPERACAO_LOG DESC)
                 WHERE ROWNUM = 1;         
            EXCEPTION
                WHEN OTHERS THEN                 
                BEGIN
                    V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"FALHA AO RECUPERAR HISTORICO DE OCUPACAO DA AUDITORIA"}';    
                    SELECT 0 INTO V_VAGA_RECUPERADA FROM DUAL;
                END;    
            END;
            END IF;
          
            
            --RECUPERA OS DADOS DE CURSO, ULTIMO UTILIZADO PELA INSCRICAO INFORMADA A PARTIR DA TERMO FIN
            IF V_VAGA_RECUPERADA = 0 THEN
            BEGIN
                --
                V_RETORNO:= '';
                SELECT 1 INTO V_VAGA_RECUPERADA FROM DUAL;
                --
                SELECT  PI.CO_CLUSTER,  CCD.CO_H_CURSO,  TF.CO_CURSO,  TF.CO_TURNO
                  INTO V_CO_CLUSTER, V_CO_H_CURSO, V_CO_CURSO, V_CO_TURNO       
                  FROM  FIES_PREINSCRICAO.TB_PRE_INSCRICAO            PI
                  JOIN  FIES_PREINSCRICAO.TB_PRE_TERMO_FINANCIAMENTO  TF    ON TF.CO_INSCRICAO = PI.CO_INSCRICAO
                  JOIN  FIES_PREINSCRICAO.TB_PRE_CLUSTER_CURSO_DADOS  CCD   ON CCD.CO_CLUSTER  = PI.CO_CLUSTER AND 
                                                                               CCD.CO_CURSO    = TF.CO_CURSO   AND   
                                                                               CCD.CO_TURNO    = TF.CO_TURNO   
                 WHERE 1 = 1 
                    AND TF.NU_OPCAO       = 1
                    AND PI.CO_INSCRICAO   = P_CO_INSCRICAO
                    AND PI.CO_SEMESTRE    = V_CO_SEMESTRE
                    AND PI.CO_USUARIO     = V_CO_USUARIO
                    AND PI.TP_USUARIO     = V_TP_USUARIO;
                    
            EXCEPTION
                WHEN OTHERS THEN   
                BEGIN
                    V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"FALHA AO RECUPERAR A PRIMEIRA OPCAO DA TERMO"}';  
                    SELECT 0 INTO V_VAGA_RECUPERADA FROM DUAL;            
                END;    
            END;
            END IF;
            
            
        END IF;
        
        --
        --SO PROSSEGUE SE FOR RECUPERADO OS DADOS DO CURSO
        IF V_RETORNO IS NULL THEN 
            --RECUPERAR UMA LINHA DE CURSO E TURNO
            SELECT NVL(MIN(NU_LINHA), 0)
              INTO V_NU_LINHA
              FROM FIES_PREINSCRICAO.TB_PRE_CLUSTER_CURSO_DETALHE DET
             WHERE CO_CLUSTER = V_CO_CLUSTER
               AND CO_H_CURSO = V_CO_H_CURSO
               AND CO_CURSO   = V_CO_CURSO
               AND CO_TURNO   = V_CO_TURNO               
               AND (TP_VAGA   = V_TP_VAGA OR TP_VAGA IS NULL)
               AND NOT EXISTS (SELECT 1
                                 FROM FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO PCO
                                WHERE PCO.CO_CURSO   = DET.CO_CURSO
                                  AND PCO.CO_H_CURSO = DET.CO_H_CURSO
                                  AND PCO.CO_TURNO   = DET.CO_TURNO
                                  AND PCO.NU_LINHA   = DET.NU_LINHA
                                  --AND PCO.TP_VAGA    = DET.TP_VAGA
                                  );
                                  

            IF V_NU_LINHA = 0 THEN  
                --V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"ERRO AO RECUPERAR UMA CADEIRA DISPONIVEL NO CURSO SELECIONADO PELO CANDIDATO NA INSCRICAO"}';    
                --CRIAR UMA CADEIRA NO CURSO
                
                SELECT NVL(MAX(NU_LINHA), 0) + 1 
                  INTO V_NU_LINHA
                  FROM FIES_PREINSCRICAO.TB_PRE_CLUSTER_CURSO_DETALHE DET
                 WHERE CO_CLUSTER = V_CO_CLUSTER
                   AND CO_CURSO   = V_CO_CURSO
                   AND CO_TURNO   = V_CO_TURNO
                   AND TP_VAGA    = V_TP_VAGA;                   
                   
                INSERT INTO FIES_PREINSCRICAO.TB_PRE_CLUSTER_CURSO_DETALHE
                (CO_CLUSTER_CURSO_DETALHE,	CO_CLUSTER,	CO_H_CURSO,	CO_CURSO,	CO_TURNO,	NU_LINHA,	ST_UTILIZADO, ST_TIPO_VAGA, TP_VAGA)
                VALUES 
                (FIES_PREINSCRICAO.SQ_PRE_CLUSTER_CURSO_DETALHE.NEXTVAL, V_CO_CLUSTER, V_CO_H_CURSO, V_CO_CURSO, V_CO_TURNO, V_NU_LINHA, 'N', 0, P_TP_VAGA);
                
                DBMS_OUTPUT.PUT_LINE('MSG: LINHA: '||V_NU_LINHA);  
            END IF;     

           
                                  
            --VALIDA SE HA POSSIBILIDADE DE OCUPAR NO CURSO.
            --RECUPERA UMA VAGA PUBLICA
            IF  V_TP_VAGA = 1 THEN                
                BEGIN                    
                    SELECT CO_CLUSTER_VAGA_PUBLICO, CO_VAGA_PUBLICO
                      INTO V_CO_CLUSTER_VAGA_PUBLICO, V_CO_VAGA_PUBLICO
                      FROM FIES_PREINSCRICAO.TB_PRE_CLUSTER_VAGA_PUBLICO
                     WHERE CO_CLUSTER_VAGA_PUBLICO = (SELECT MIN(CO_CLUSTER_VAGA_PUBLICO)
                                                        FROM FIES_PREINSCRICAO.TB_PRE_CLUSTER_VAGA_PUBLICO PCVP
                                                       WHERE 1 = 1
                                                       AND CO_SEMESTRE = V_CO_SEMESTRE
                                                       AND NOT EXISTS (SELECT 1
                                                                           FROM FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO PCO
                                                                          WHERE PCO.CO_CLUSTER_VAGA_PUBLICO = PCVP.CO_CLUSTER_VAGA_PUBLICO));
                EXCEPTION
                    WHEN OTHERS THEN                            
                        V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"FALHA AO RECUPERAR VAGA PUBLICA ['||V_CO_VAGA_PUBLICO||'] - ['||SQLERRM||'] "}';    
                END;
                    
                IF V_CO_VAGA_PUBLICO IS NOT NULL THEN 
                BEGIN                    
                    --RECRIAR VAGA
                    DELETE FROM FIES_PREINSCRICAO.TB_PRE_CLUSTER_VAGA_PUBLICO WHERE CO_VAGA_PUBLICO = V_CO_VAGA_PUBLICO;
                    --
                    V_CO_CLUSTER_VAGA_PUBLICO:= LPAD(V_CO_CLUSTER, 10, '0') || V_CO_VAGA_PUBLICO;
                    --
                    INSERT INTO FIES_PREINSCRICAO.TB_PRE_CLUSTER_VAGA_PUBLICO (CO_CLUSTER_VAGA_PUBLICO, CO_CLUSTER, CO_SEMESTRE, CO_VAGA_PUBLICO)
                    VALUES (V_CO_CLUSTER_VAGA_PUBLICO, V_CO_CLUSTER, V_CO_SEMESTRE, V_CO_VAGA_PUBLICO);
                    
                EXCEPTION
                WHEN OTHERS THEN                        
                    V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"FALHA AO RECRIAR VAGA PUBLICA ['||V_CO_VAGA_PUBLICO||'] - ['||SQLERRM||'] "}';                        
                END;                
                END IF;  
            END IF;     
        
            --RECUPERA UMA VAGA PRIVADA
            IF  V_TP_VAGA = 2 THEN   
                BEGIN
                    SELECT CO_CLUSTER_VAGA_PRIVADO, CO_VAGA_PRIVADO
                      INTO V_CO_CLUSTER_VAGA_PRIVADO, V_CO_VAGA_PRIVADO
                      FROM FIES_PREINSCRICAO.TB_PRE_CLUSTER_VAGA_PRIVADO
                     WHERE CO_CLUSTER_VAGA_PRIVADO = (SELECT MIN(CO_CLUSTER_VAGA_PRIVADO)
                                                        FROM FIES_PREINSCRICAO.TB_PRE_CLUSTER_VAGA_PRIVADO PCVP
                                                       WHERE 1 = 1
                                                       AND CO_SEMESTRE = V_CO_SEMESTRE
                                                       AND NOT EXISTS (SELECT 1
                                                                           FROM FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO PCO
                                                                          WHERE PCO.CO_CLUSTER_VAGA_PRIVADO = PCVP.CO_CLUSTER_VAGA_PRIVADO));                
                EXCEPTION
                    WHEN OTHERS THEN                            
                        V_RETORNO := '{"MSG":"MSG902", "INSCRICAO": "-1", "ERRO":"FALHA AO RECUPERAR VAGA PRIVADA ['||SQLERRM||'] "}';
                END;                
            
                IF  V_CO_VAGA_PRIVADO IS NOT NULL THEN 
                BEGIN                    
                    --RECRIAR VAGA
                    DELETE FROM FIES_PREINSCRICAO.TB_PRE_CLUSTER_VAGA_PRIVADO WHERE CO_VAGA_PRIVADO = V_CO_VAGA_PRIVADO;
                    --
                    V_CO_CLUSTER_VAGA_PRIVADO:= LPAD(V_CO_CLUSTER, 10, '0') || V_CO_VAGA_PRIVADO;
                    --
                    INSERT INTO FIES_PREINSCRICAO.TB_PRE_CLUSTER_VAGA_PRIVADO (CO_CLUSTER_VAGA_PRIVADO, CO_CLUSTER, CO_SEMESTRE, CO_VAGA_PRIVADO)
                    VALUES (V_CO_CLUSTER_VAGA_PRIVADO, V_CO_CLUSTER, V_CO_SEMESTRE, V_CO_VAGA_PRIVADO);
                    
                EXCEPTION
                WHEN OTHERS THEN                        
                    V_RETORNO := '{"MSG":"MSG903", "INSCRICAO": "-1", "ERRO":"FALHA AO RECRIAR VAGA PRIVADA ['||SQLERRM||']  "}';
                END;                
                END IF;    
            END IF;
                     
        END IF;                
        --
        IF V_RETORNO IS NULL THEN
            --VERIFICAR SE O TERMO EXISTE
            SELECT COUNT(1)
              INTO V_EXISTE 
              FROM FIES_PREINSCRICAO.TB_PRE_TERMO_FINANCIAMENTO
             WHERE CO_INSCRICAO = P_CO_INSCRICAO
               AND CO_CURSO = V_CO_CURSO
               AND CO_TURNO = V_CO_TURNO;

            IF V_EXISTE = 0 THEN
                --REINSERE NA TERMO CASO NAO EXISTA
                INSERT INTO FIES_PREINSCRICAO.TB_PRE_TERMO_FINANCIAMENTO(CO_TERMO_FINANCIAMENTO,CO_INSCRICAO,CO_OFERTA_VAGAS,CO_CURSO,CO_TURNO,NU_OPCAO,QT_SEMESTRE_CURSO,QT_SEMESTRE_CONCLUIDO,QT_SEMESTRE_FINANCIAMENTO,
                        VL_SEMESTRALIDADE_SEM_DESC,VL_SEMESTRALIDADE_COM_DESC,VL_SEMESTRALIDADE_FIES,ST_BOLSISTA_PROUNI,NU_PERCENTUAL_PROUNI,ST_MENSALIDADE_PERMITIDA,CO_TERMO_FINANCIAMENTO_VAGA)
                SELECT  TF.CO_TERMO_FINANCIAMENTO,TF.CO_INSCRICAO,TF.CO_OFERTA_VAGAS,TF.CO_CURSO,TF.CO_TURNO,TF.NU_OPCAO,TF.QT_SEMESTRE_CURSO,TF.QT_SEMESTRE_CONCLUIDO,TF.QT_SEMESTRE_FINANCIAMENTO,
                        TF.VL_SEMESTRALIDADE_SEM_DESC,TF.VL_SEMESTRALIDADE_COM_DESC,TF.VL_SEMESTRALIDADE_FIES,TF.ST_BOLSISTA_PROUNI,TF.NU_PERCENTUAL_PROUNI,TF.ST_MENSALIDADE_PERMITIDA,TF.CO_TERMO_FINANCIAMENTO_VAGA
                  FROM (SELECT MAX(CO_H_TERMO_FINANCIAMENTO) CO_H_TERMO_FINANCIAMENTO
                          FROM FIES_PREINSCRICAO.TH_PRE_TERMO_FINANCIAMENTO THF 
                         WHERE CO_INSCRICAO = P_CO_INSCRICAO
                           AND CO_CURSO = V_CO_CURSO
                           AND CO_TURNO = V_CO_TURNO) TMP
                  JOIN FIES_PREINSCRICAO.TH_PRE_TERMO_FINANCIAMENTO TF ON TF.CO_H_TERMO_FINANCIAMENTO = TMP.CO_H_TERMO_FINANCIAMENTO;
            END IF;
            
            --
            --ATUALIZA O TIPO DE VAGA NA CLUSTER CURSO DETALHE (CADEIRA)
            UPDATE FIES_PREINSCRICAO.TB_PRE_CLUSTER_CURSO_DETALHE 
            SET    TP_VAGA = V_TP_VAGA
            WHERE  1 = 1 
            AND CO_CLUSTER = V_CO_CLUSTER
            AND CO_H_CURSO = V_CO_H_CURSO
            AND CO_CURSO   = V_CO_CURSO
            AND CO_TURNO   = V_CO_TURNO  
            AND TP_VAGA IS NULL;
            
            --
			--TB_PRE_CHAMADA_OCUPACAO
			UPDATE  FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO 
			SET     DT_OCUPACAO             = SYSDATE,
					CO_H_CURSO              = V_CO_H_CURSO,
					CO_CURSO                = V_CO_CURSO,
					CO_TURNO                = V_CO_TURNO,
					NU_LINHA                = V_NU_LINHA,
					CO_CLUSTER              = V_CO_CLUSTER,
					DT_DESOCUPACAO          = NULL,
					TP_CHAMADA_OCUPACAO     = 2,
                    --CO_CLUSTER_VAGA_PUBLICO = V_CO_CLUSTER_VAGA_PUBLICO
					CO_CLUSTER_VAGA_PRIVADO = V_CO_CLUSTER_VAGA_PRIVADO
			WHERE   CO_INSCRICAO            = P_CO_INSCRICAO
			  AND   CO_USUARIO              = V_CO_USUARIO
			  AND   CO_SEMESTRE             = V_CO_SEMESTRE
			  AND   TP_USUARIO              = V_TP_USUARIO
			  AND   TP_VAGA                 = V_TP_VAGA;
            DBMS_OUTPUT.PUT_LINE('TB_PRE_CHAMADA_OCUPACAO - Total de Linhas Atualizadas:'||SQL%ROWCOUNT||'.');   
            
			/*--TH_PRE_CHAMADA_OCUPACAO
			INSERT INTO FIES_PREINSCRICAO.TH_PRE_CHAMADA_OCUPACAO (CO_H_CHAMADA_OCUPACAO, DT_HISTORICO, CO_INSCRICAO, CO_USUARIO, CO_SEMESTRE, 
																   TP_CHAMADA_OCUPACAO, TP_USUARIO, TP_VAGA, CO_CHAMADA, 
																   CO_CLUSTER, CO_H_CURSO, CO_CURSO, CO_TURNO, NU_LINHA, CO_CLUSTER_VAGA_PRIVADO, DT_OCUPACAO)
			SELECT FIES_PREINSCRICAO.SQ_PRE_H_CHAMADA_OCUPACAO.NEXTVAL, SYSDATE, CO_INSCRICAO, CO_USUARIO, CO_SEMESTRE, 
				   TP_CHAMADA_OCUPACAO, TP_USUARIO, TP_VAGA, CO_CHAMADA,
				   CO_CLUSTER, CO_H_CURSO, CO_CURSO, CO_TURNO,NU_LINHA, CO_CLUSTER_VAGA_PRIVADO, DT_OCUPACAO
			FROM   FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO
			WHERE  1 = 1
			AND    CO_INSCRICAO = P_CO_INSCRICAO
			AND    CO_USUARIO   = V_CO_USUARIO
			AND    CO_SEMESTRE  = V_CO_SEMESTRE
			AND    TP_USUARIO   = V_TP_USUARIO
			AND    TP_VAGA      = V_TP_VAGA
            AND    TP_CHAMADA_OCUPACAO = 2; 
            DBMS_OUTPUT.PUT_LINE('TH_PRE_CHAMADA_OCUPACAO - Total de Linhas Incluidas:'||SQL%ROWCOUNT||'.');   
		
            --SITUACAO INSCRICAO
            UPDATE FIES_PREINSCRICAO.TB_PRE_INSCRICAO
               SET CO_SITUACAO_INSCRICAO  = P_CO_SITUACAO_INSCRICAO,
                   CO_TIPO_VENCIMENTO     = NULL,
                   CO_MOTIVO_CANCELAMENTO = NULL
             WHERE CO_INSCRICAO = P_CO_INSCRICAO;
            DBMS_OUTPUT.PUT_LINE('TB_PRE_INSCRICAO - Total de Linhas Atualizadas:'||SQL%ROWCOUNT||'.');   
            */
            
            
            UPDATE FIES_PREINSCRICAO.TB_PRE_INSCRICAO
               SET CO_SITUACAO_INSCRICAO_PV  = P_CO_SITUACAO_INSCRICAO,
                   CO_TIPO_VENCIMENTO_PV     = NULL,
                   CO_MOTIVO_CANCELAMENTO_PV = NULL
             WHERE CO_INSCRICAO = P_CO_INSCRICAO;
            DBMS_OUTPUT.PUT_LINE('TB_PRE_INSCRICAO - Total de Linhas Atualizadas:'||SQL%ROWCOUNT||'.');   
            
            
            --TB_FIN_CANDIDATO (DATAS)
            UPDATE FIES_FINANCIAMENTO.TB_FIN_CANDIDATO
               SET DT_INICIO_FINANCIAMENTO   = SYSDATE,
                   DT_FIM_FINANCIAMENTO      = (SELECT FIES_GLOBAL.SOMA_DIAS_UTEIS (SYSDATE, 7) FROM DUAL),                   
                   DT_LIMITE_CPSA            = (SELECT FIES_GLOBAL.SOMA_DIAS_UTEIS (SYSDATE, 14) FROM DUAL),                   
                   CO_SEMESTRE_FINANCIAMENTO = P_CO_SEMESTRE_FINANCIAMENTO
                   --TP_USUARIO                = P_TP_USUARIO
                   --TP_VAGA                   = P_TP_VAGA
                   --CO_INSCRICAO              = P_CO_INSCRICAO
             WHERE CO_USUARIO = V_CO_USUARIO;
             DBMS_OUTPUT.PUT_LINE('TB_FIN_CANDIDATO - Total de Linhas Atualizadas:'||SQL%ROWCOUNT||'.');   

            /* 
            --(TH_FIN_CANDIDATO_PUBLICO) SITUACAO FINANCIAMENTO
            INSERT INTO FIES_FINANCIAMENTO.TH_FIN_CANDIDATO_PUBLICO (CO_H_CANDIDATO_PUBLICO, CO_CANDIDATO_PUBLICO, CO_SITUACAO_FINANCIAMENTO, CO_MOTIVO_SITUACAO, DT_HISTORICO)
            VALUES ( FIES_FINANCIAMENTO.SQ_H_FIN_CANDIDATO_PUBLICO.NEXTVAL, V_CO_USUARIO, P_CO_SITUACAO_FINANCIAMENTO, NULL, SYSDATE    );
            DBMS_OUTPUT.PUT_LINE('TH_FIN_CANDIDATO_PUBLICO - Total de Linhas Incluidas:'||SQL%ROWCOUNT||'.');   
            */
                        
            --(TH_FIN_CANDIDATO_PRIVADO) SITUACAO FINANCIAMENTO
            INSERT INTO FIES_FINANCIAMENTO.TH_FIN_CANDIDATO_PRIVADO (CO_H_CANDIDATO_PRIVADO, CO_CANDIDATO_PRIVADO, CO_SITUACAO_FINANCIAMENTO, CO_MOTIVO_SITUACAO, DT_HISTORICO)
            VALUES ( FIES_FINANCIAMENTO.SQ_H_FIN_CANDIDATO_PRIVADO.NEXTVAL, V_CO_USUARIO, P_CO_SITUACAO_FINANCIAMENTO, NULL, SYSDATE    );
            DBMS_OUTPUT.PUT_LINE('TH_FIN_CANDIDATO_PRIVADO - Total de Linhas Incluidas:'||SQL%ROWCOUNT||'.');   
            
            
            V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||' RECUPERADA COM SUCESSO", "ERRO":""}';
        END IF;
        --   
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('MSG : '||V_RETORNO);    
        V_TOTAL        := V_TOTAL + 1;   
        EXCEPTION
        WHEN OTHERS THEN BEGIN                       
            V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"FALHA AO RECUPERAR A VAGA DA INSCRICAO ['||SQLERRM||']"}';            
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('MSG : '||V_RETORNO);    
            DBMS_OUTPUT.PUT_LINE('MSG : '||V_CO_CLUSTER||'-'||V_CO_CLUSTER_VAGA_PRIVADO||'-'||V_CO_H_CURSO||'-'||V_CO_CURSO||'-'||V_CO_TURNO||'-'||V_NU_LINHA); 
        END; 
        --        
    DBMS_OUTPUT.PUT_LINE(' ');  
    DBMS_OUTPUT.PUT_LINE('Total de registros processados: '||V_TOTAL);        
    ---|TERMINO    
    END;
    DBMS_OUTPUT.PUT_LINE(' ');      
    DBMS_OUTPUT.PUT_LINE('Termino...'||to_char(sysdate,'YYYY-mm-dd HH24:MI:SS')||'.');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------');  
    
    
END;--FIM 
/*===========================================================================================================================*/
