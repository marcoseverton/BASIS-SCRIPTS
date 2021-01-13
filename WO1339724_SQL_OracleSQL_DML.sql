/* 
FNDE - #25034 - ANA LAURA DO NASCIMENTO MIRANDA - 035.795.871-37 - FIES - Sisfies Aluno
Ordem de trabalho # WO1339724
*/

SET SERVEROUTPUT ON;
DECLARE        
    --VARIAVEIS    
    P_NU_CPF                     VARCHAR2(11):= '03579587137'; 
    P_CO_INSCRICAO               NUMBER(10)  := 203931453;
    P_CO_USUARIO                 NUMBER(10)  := 9606300;    
    P_CO_SEMESTRE_FINANCIAMENTO  NUMBER(5)   := 20211;
    P_CO_SITUACAO_INSCRICAO      NUMBER(2)   := 4; 
    P_CO_SITUACAO_FINANCIAMENTO  NUMBER(2)   := 11;
    P_CO_MOTIVO_SITUACAO         NUMBER(2)   := 26;
    P_CO_PERFIL_USUARIO          NUMBER(2)   := 1; -- Perfil Carga
    
    V_RETORNO                    VARCHAR2(1000);
    V_EXISTE                     NUMBER(10);
    V_VAGA_RECUPERADA            NUMBER(1):=0;
    V_TOTAL                      NUMBER(10):=0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------------');  
    DBMS_OUTPUT.PUT_LINE('--|ORACLE - POSTERGAR INSCRICAO|--');  
    DBMS_OUTPUT.PUT_LINE('Inicio...'||to_char(sysdate,'YYYY-mm-dd HH24:MI:SS')||'.' );
    DBMS_OUTPUT.PUT_LINE(' ');     
 
        BEGIN   
                               
           UPDATE   FIES_PREINSCRICAO.TB_PRE_INSCRICAO
           SET       CO_SITUACAO_INSCRICAO =  P_CO_SITUACAO_INSCRICAO
                    ,CO_TIPO_VENCIMENTO = 5
           WHERE    CO_INSCRICAO = P_CO_INSCRICAO;         
           
           UPDATE   FIES_FINANCIAMENTO.TB_FIN_CANDIDATO
           SET      CO_SEMESTRE_FINANCIAMENTO = P_CO_SEMESTRE_FINANCIAMENTO
           WHERE    CO_USUARIO = P_CO_USUARIO;
           
            INSERT INTO FIES_FINANCIAMENTO.TH_FIN_CANDIDATO_PUBLICO (CO_H_CANDIDATO_PUBLICO, CO_CANDIDATO_PUBLICO, CO_SITUACAO_FINANCIAMENTO, CO_MOTIVO_SITUACAO, DT_HISTORICO, CO_PERFIL_USUARIO)
            VALUES (FIES_FINANCIAMENTO.SQ_H_FIN_CANDIDATO_PUBLICO.NEXTVAL,P_CO_USUARIO, P_CO_SITUACAO_FINANCIAMENTO,P_CO_MOTIVO_SITUACAO, SYSDATE , P_CO_PERFIL_USUARIO);

            V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'POSTERGADA COM SUCESSO", "ERRO":""}';
            
        --   
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('MSG : '||V_RETORNO);    
        V_TOTAL        := V_TOTAL + 1;   
        EXCEPTION
        WHEN OTHERS THEN BEGIN                       
            V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"FALHA AO POSTERGAR A INSCRICAO ['||SQLERRM||']"}';
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('MSG : '||V_RETORNO);    
        END; 
        --                
    ---|TERMINO    
    END;
    DBMS_OUTPUT.PUT_LINE(' ');          
    DBMS_OUTPUT.PUT_LINE('Total de registros lidos: '||V_TOTAL);        
    DBMS_OUTPUT.PUT_LINE('Termino...'||to_char(sysdate,'YYYY-mm-dd HH24:MI:SS')||'.');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------');  
    
    
END;--FIM 


