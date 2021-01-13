/*===========================================================================================================================*/
/*FNDE - Prorrogação do Prazo de Validação de Inscrição da CPSA - FIES - Sisfies Aluno
Ordem de trabalho # WO1333522*/


SET SERVEROUTPUT ON;
DECLARE        
    --VARIAVEIS    
    V_RETORNO       VARCHAR2(500);
    V_TOTAL         NUMBER(10):=0; 
    V_NU_CPF       VARCHAR2(11):=0;      
    V_CO_INSCRICAO  NUMBER(10):=0; 
    V_CO_USUARIO    NUMBER(10):=0;
    V_CO_SEMESTRE   NUMBER(5):=0;
    V_TP_USUARIO    NUMBER(1):=0;           
    V_TP_VAGA       NUMBER(1):=0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------------');  
    DBMS_OUTPUT.PUT_LINE('--|ORACLE - PRORROGACAO DE INSCRICAO|--');  
    DBMS_OUTPUT.PUT_LINE('Inicio...'||to_char(sysdate,'YYYY-mm-dd HH24:MI:SS')||'.' );
    DBMS_OUTPUT.PUT_LINE(' ');     
    --   
    FOR REC_INSCRICAO IN (        
        
                SELECT  
                        PF.NU_CPF, 
                        PI.CO_INSCRICAO,
                        PI.CO_USUARIO,
                        PI.CO_SEMESTRE,
                        HCP.CO_SITUACAO_FINANCIAMENTO,
                        HCP.CO_H_CANDIDATO_PUBLICO,
                        PI.CO_SITUACAO_INSCRICAO,
                        CO.DT_OCUPACAO,
                        CO.DT_DESOCUPACAO,
                        cd.dt_limite_cpsa
          
                        
                FROM        FIES_PREINSCRICAO.TB_PRE_INSCRICAO               PI
                INNER JOIN  FIES_PREINSCRICAO.TB_PRE_USUARIO                 US  ON US.CO_USUARIO   = PI.CO_USUARIO
                INNER JOIN  FIES_GLOBAL.TB_GLB_PESSOA_FISICA                 PF  ON PF.CO_PESSOA    = US.CO_PESSOA
                INNER JOIN  FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO        CO  ON CO.CO_INSCRICAO = PI.CO_INSCRICAO AND 
                                                                                    CO.CO_USUARIO   = PI.CO_USUARIO   AND 
                                                                                    CO.CO_SEMESTRE  = PI.CO_SEMESTRE                                                             
                INNER JOIN  FIES_FINANCIAMENTO.TB_FIN_CANDIDATO              CD  ON CD.CO_USUARIO                 = PI.CO_USUARIO 
                LEFT JOIN   FIES_FINANCIAMENTO.TH_FIN_CANDIDATO_PUBLICO      HCP ON HCP.CO_CANDIDATO_PUBLICO = CD.CO_USUARIO 
                AND         HCP.CO_H_CANDIDATO_PUBLICO =     (        
                 SELECT MAX(CO_H_CANDIDATO_PUBLICO) FROM FIES_FINANCIAMENTO.TH_FIN_CANDIDATO_PUBLICO  WHERE CO_CANDIDATO_PUBLICO = CD.CO_USUARIO 
                )
  
                WHERE       1 = 1 
                AND         CO.TP_CHAMADA_OCUPACAO IN (2) 
                AND         CO.CO_SEMESTRE = 20202
                AND         CO.TP_USUARIO = 2
                AND         HCP.CO_SITUACAO_FINANCIAMENTO IN (2,7)
                AND         CD.DT_LIMITE_CPSA <= SYSDATE  
              
        )
    LOOP 
        BEGIN   
                     
                --Recupera variaveis do cursor                          
                V_CO_INSCRICAO := REC_INSCRICAO.CO_INSCRICAO;                            
                V_CO_USUARIO   := REC_INSCRICAO.CO_USUARIO;                            
                V_CO_SEMESTRE  := REC_INSCRICAO.CO_SEMESTRE;                           
                
                    UPDATE FIES_FINANCIAMENTO.TB_FIN_CANDIDATO
                       SET DT_INICIO_FINANCIAMENTO   = SYSDATE,
                           DT_FIM_FINANCIAMENTO      = (SELECT TO_DATE(TO_CHAR(TRUNC(FIES_GLOBAL.SOMA_DIAS_UTEIS(SYSDATE, 5)), 'DD/MM/YYYY') || ' 23:59:59', 'DD/MM/YYYY HH24:MI:SS') FROM DUAL ),
                           DT_LIMITE_CPSA            = '18/12/2020',
                           CO_SEMESTRE_FINANCIAMENTO = 20202 
                     WHERE CO_USUARIO = V_CO_USUARIO;
            
                    --SITUACAO INSCRICAO
                    UPDATE FIES_PREINSCRICAO.TB_PRE_INSCRICAO
                       SET CO_SITUACAO_INSCRICAO  = 3,
                           CO_TIPO_VENCIMENTO     = NULL,
                           CO_MOTIVO_CANCELAMENTO = NULL
                     WHERE CO_INSCRICAO = V_CO_INSCRICAO;
                     
                    --Inclui situacao
                    INSERT INTO FIES_FINANCIAMENTO.TH_FIN_CANDIDATO_PUBLICO (CO_H_CANDIDATO_PUBLICO, CO_CANDIDATO_PUBLICO, CO_SITUACAO_FINANCIAMENTO, DT_HISTORICO, CO_PERFIL_USUARIO)
                    VALUES (FIES_FINANCIAMENTO.SQ_H_FIN_CANDIDATO_PUBLICO.NEXTVAL, V_CO_USUARIO, REC_INSCRICAO.CO_SITUACAO_FINANCIAMENTO, SYSDATE, 1);
          
            COMMIT;  
            EXCEPTION
            WHEN OTHERS THEN BEGIN                                       
                ROLLBACK;                
                DBMS_OUTPUT.PUT_LINE('MSG: ERRO - '||SQLERRM);                
            END; 
            --             
            --                          
        ---|TERMINO    
        END;
            V_TOTAL:=V_TOTAL+1;    
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(' ');    
    DBMS_OUTPUT.PUT_LINE('Total de registros lidos:'||V_TOTAL||'.');      
    DBMS_OUTPUT.PUT_LINE('Termino...'||to_char(sysdate,'YYYY-mm-dd HH24:MI:SS')||'.');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------------');  
END;--FIM 

/*===========================================================================================================================*/