/*===========================================================================================================================*/
/* 
FNDE - DERRUBAR INSCRIÇOES
*/

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
    DBMS_OUTPUT.PUT_LINE('--|ORACLE - DERRUBADA INSCRICAO|--');  
    DBMS_OUTPUT.PUT_LINE('Inicio...'||to_char(sysdate,'YYYY-mm-dd HH24:MI:SS')||'.' );
    DBMS_OUTPUT.PUT_LINE(' ');     
    --   
    FOR REC_INSCRICAO IN 
    (        
       
SELECT      DISTINCT
                    PF.NU_CPF, 
                    PI.CO_INSCRICAO,
                    PI.CO_USUARIO,
                    PI.CO_SEMESTRE,
                    CO.TP_VAGA,
                    CO.TP_USUARIO,
                    HCP.CO_SITUACAO_FINANCIAMENTO
                    
        FROM        FIES_PREINSCRICAO.TB_PRE_INSCRICAO               PI
        INNER JOIN  FIES_PREINSCRICAO.TB_PRE_USUARIO                 US  ON US.CO_USUARIO   = PI.CO_USUARIO
        INNER JOIN  FIES_GLOBAL.TB_GLB_PESSOA_FISICA                 PF  ON PF.CO_PESSOA    = US.CO_PESSOA
        INNER JOIN  FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO        CO  ON CO.CO_INSCRICAO = PI.CO_INSCRICAO AND 
                                                                            CO.CO_USUARIO   = PI.CO_USUARIO   AND 
                                                                            CO.CO_SEMESTRE  = PI.CO_SEMESTRE                                                             
        INNER JOIN  FIES_FINANCIAMENTO.TB_FIN_CANDIDATO              CD  ON CD.CO_USUARIO                 = PI.CO_USUARIO 
        INNER JOIN   FIES_FINANCIAMENTO.TH_FIN_CANDIDATO_PUBLICO      HCP ON HCP.CO_CANDIDATO_PUBLICO = CD.CO_USUARIO
        AND  HCP.CO_SITUACAO_FINANCIAMENTO = 
             (   
        select MAX(CO_SITUACAO_FINANCIAMENTO) from 
        FIES_FINANCIAMENTO.TH_FIN_CANDIDATO_PUBLICO 
        where CO_CANDIDATO_PUBLICO =  HCP.CO_CANDIDATO_PUBLICO  AND 
        ROWNUM = 1
        )   
        WHERE       1 = 1 
        AND         CO.TP_CHAMADA_OCUPACAO = 2 --OCUPADO        
        AND         CO.TP_VAGA IN (1,2)
        AND         HCP.CO_SITUACAO_FINANCIAMENTO = 18
        AND         PF.NU_CPF IS NOT NULL
        AND         PI.CO_SEMESTRE != 20202            
    )
    LOOP 
        BEGIN   
        ----|INICIO                    
            --Recupera variaveis do cursor
            V_NU_CPF       := REC_INSCRICAO.NU_CPF;                            
            V_CO_INSCRICAO := REC_INSCRICAO.CO_INSCRICAO;                            
            V_CO_USUARIO   := REC_INSCRICAO.CO_USUARIO;                            
            V_CO_SEMESTRE  := REC_INSCRICAO.CO_SEMESTRE;                            
            V_TP_USUARIO   := REC_INSCRICAO.TP_USUARIO;                            
            V_TP_VAGA      := REC_INSCRICAO.TP_VAGA;                            
            
                        
             --Desocupar
            UPDATE  FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO
            SET     TP_CHAMADA_OCUPACAO     = 3,
                    CO_H_CURSO              = NULL, 
                    CO_CURSO                = NULL, 
                    CO_TURNO                = NULL, 
                    NU_LINHA                = NULL, 
                    CO_CLUSTER              = NULL,
                    CO_CLUSTER_VAGA_PRIVADO = NULL, 
                    CO_CLUSTER_VAGA_PUBLICO = NULL, 
                    DT_OCUPACAO             = NULL,
                    DT_DESOCUPACAO          = SYSDATE
            WHERE   1 = 1
            AND     CO_INSCRICAO            = V_CO_INSCRICAO
            AND     CO_USUARIO              = V_CO_USUARIO
            AND     CO_SEMESTRE             = V_CO_SEMESTRE
            AND     TP_USUARIO              = V_TP_USUARIO            
            AND     TP_VAGA                 = V_TP_VAGA           
            AND     TP_CHAMADA_OCUPACAO     = 2;
            
            --Criar historico da chamada ocupacao: th_pre_chamada_ocupacao
            INSERT INTO FIES_PREINSCRICAO.TH_PRE_CHAMADA_OCUPACAO (CO_H_CHAMADA_OCUPACAO, DT_HISTORICO, CO_INSCRICAO, CO_USUARIO, CO_SEMESTRE, CO_CLUSTER, TP_USUARIO, TP_VAGA,
                                                                   TP_CHAMADA_OCUPACAO, CO_CHAMADA, CO_H_CURSO, CO_CURSO, CO_TURNO, NU_LINHA, CO_CLUSTER_VAGA_PUBLICO, DT_OCUPACAO)
            SELECT FIES_PREINSCRICAO.SQ_PRE_H_CHAMADA_OCUPACAO.NEXTVAL, SYSDATE, CO_INSCRICAO, CO_USUARIO, CO_SEMESTRE, CO_CLUSTER, TP_USUARIO, TP_VAGA,
                   TP_CHAMADA_OCUPACAO, CO_CHAMADA, CO_H_CURSO, CO_CURSO, CO_TURNO,NU_LINHA, CO_CLUSTER_VAGA_PUBLICO, DT_OCUPACAO
            FROM   FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO
            WHERE   1 = 1
            AND     CO_INSCRICAO            = V_CO_INSCRICAO
            AND     CO_USUARIO              = V_CO_USUARIO
            AND     CO_SEMESTRE             = V_CO_SEMESTRE
            AND     TP_USUARIO              = V_TP_USUARIO            
            AND     TP_VAGA                 = V_TP_VAGA                
            AND     TP_CHAMADA_OCUPACAO     = 3
            AND     DT_DESOCUPACAO          IS NOT NULL;
            
            --Inclui candidato se não existir
            MERGE INTO FIES_FINANCIAMENTO.TB_FIN_CANDIDATO DESTINO
            USING ( 
                    SELECT V_CO_USUARIO  as CO_USUARIO, 
                           V_CO_SEMESTRE as CO_SEMESTRE, 
                           V_TP_USUARIO  as TP_USUARIO 
                           FROM DUAL) ORIGEM 
            ON (ORIGEM.CO_USUARIO = DESTINO.CO_USUARIO)
            WHEN NOT MATCHED THEN
            INSERT (DESTINO.CO_USUARIO, DESTINO.CO_SEMESTRE, DESTINO.TP_USUARIO, DESTINO.CO_PERFIL_USUARIO)
            VALUES (ORIGEM.CO_USUARIO,  ORIGEM.CO_SEMESTRE, ORIGEM.TP_USUARIO, 1);

            --Setar os dados da tabela: tb_fin_candidato para null
            UPDATE  FIES_FINANCIAMENTO.TB_FIN_CANDIDATO 
            SET     DT_INICIO_FINANCIAMENTO = NULL,
                    DT_FIM_FINANCIAMENTO    = NULL,
                    DT_LIMITE_CPSA          = NULL,
                    NU_MATRICULA            = NULL,
                    CO_PERFIL_USUARIO       = 1
            WHERE   1 = 1
            AND     CO_USUARIO  = V_CO_USUARIO
            AND     CO_SEMESTRE = V_CO_SEMESTRE
            AND     TP_USUARIO  = V_TP_USUARIO;
            
            --PUBLICO
            IF V_TP_VAGA = 1 THEN
                --Inclui candidato publico se não existir
                MERGE INTO FIES_FINANCIAMENTO.TB_FIN_CANDIDATO_PUBLICO DESTINO
                USING ( SELECT V_CO_USUARIO as CO_USUARIO FROM DUAL ) ORIGEM 
                ON (ORIGEM.CO_USUARIO = DESTINO.CO_USUARIO)
                WHEN NOT MATCHED THEN
                INSERT (DESTINO.CO_USUARIO, CO_PERFIL_USUARIO)
                VALUES (ORIGEM.CO_USUARIO, 1);
                
                --Inclui situacao
                INSERT INTO FIES_FINANCIAMENTO.TH_FIN_CANDIDATO_PUBLICO (CO_H_CANDIDATO_PUBLICO, CO_CANDIDATO_PUBLICO, CO_SITUACAO_FINANCIAMENTO, DT_HISTORICO, CO_PERFIL_USUARIO)
                VALUES (FIES_FINANCIAMENTO.SQ_H_FIN_CANDIDATO_PUBLICO.NEXTVAL, V_CO_USUARIO, 6, SYSDATE, 1);

                
                --Atualiza a inscricao
                UPDATE  FIES_PREINSCRICAO.TB_PRE_INSCRICAO
                SET     CO_SITUACAO_INSCRICAO    = 4,
                        CO_TIPO_VENCIMENTO       = 1,
                        CO_MOTIVO_CANCELAMENTO   = NULL
                WHERE   CO_INSCRICAO             = V_CO_INSCRICAO
                AND     CO_USUARIO               = V_CO_USUARIO
                AND     CO_SEMESTRE              = V_CO_SEMESTRE
                AND     TP_USUARIO               = V_TP_USUARIO;   

            END IF;

            IF V_TP_VAGA = 2 THEN
                --Inclui candidato publico se não existir
                MERGE INTO FIES_FINANCIAMENTO.TB_FIN_CANDIDATO_PRIVADO DESTINO
                USING ( SELECT V_CO_USUARIO as CO_USUARIO FROM DUAL ) ORIGEM 
                ON (ORIGEM.CO_USUARIO = DESTINO.CO_USUARIO)
                WHEN NOT MATCHED THEN
                INSERT (DESTINO.CO_USUARIO)
                VALUES (ORIGEM.CO_USUARIO);
                
                --Inclui situacao
                INSERT INTO FIES_FINANCIAMENTO.TH_FIN_CANDIDATO_PRIVADO (CO_H_CANDIDATO_PRIVADO, CO_CANDIDATO_PRIVADO, CO_SITUACAO_FINANCIAMENTO, DT_HISTORICO)
                VALUES (FIES_FINANCIAMENTO.SQ_H_FIN_CANDIDATO_PRIVADO.NEXTVAL, V_CO_USUARIO, 6, SYSDATE);
                
                
                --Atualiza a inscricao
                UPDATE  FIES_PREINSCRICAO.TB_PRE_INSCRICAO
                SET     CO_SITUACAO_INSCRICAO_PV  = 4,
                        CO_TIPO_VENCIMENTO_PV     = 1,
                        CO_MOTIVO_CANCELAMENTO_PV = NULL
                WHERE   CO_INSCRICAO              = V_CO_INSCRICAO
                AND     CO_USUARIO                = V_CO_USUARIO
                AND     CO_SEMESTRE               = V_CO_SEMESTRE
                AND     TP_USUARIO                = V_TP_USUARIO;   

                
            END IF;
            
            --Retirar restricao estudante
            UPDATE FIES_PREINSCRICAO.TB_PRE_RESTRICAO_ESTUDANTE 
            SET    ST_MOTIVO_RESTRICAO     = 'N',
                   ST_RESTRICAO_FIANCA     = 'N',
                   ST_RESTRICAO_LEGADO     = 'N',
                   ST_RESTRICAO_PRORROGADO = 'N',
                   CO_SITUACAO_INSCRICAO   = 6
            WHERE  NU_CPF = V_NU_CPF;
            
            --   
            COMMIT;                        
                DBMS_OUTPUT.PUT_LINE('..CPF ['||V_NU_CPF||'] - INSCRICAO ['||V_CO_INSCRICAO||'] derrubada com sucesso.');
            EXCEPTION
            WHEN OTHERS THEN BEGIN                                       
                ROLLBACK;                
                DBMS_OUTPUT.PUT_LINE('..CPF ['||V_NU_CPF||'] - INSCRICAO ['||V_CO_INSCRICAO||'] falha ao derrubar.');
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