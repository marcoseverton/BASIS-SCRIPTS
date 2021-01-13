 -- INSERIR VAGA P/ ESTUDANTE SOMENTE CHAMADO

 
 /*===========================================================================================================================*/
SET SERVEROUTPUT ON;
DECLARE
    --PARAMETRO DE ENTRADA
    
    P_CO_INSCRICAO               NUMBER(10)  := 8014500;
    P_TP_USUARIO                 NUMBER(1)   := 2; --REGULAR OU REMANESCENTE
    P_TP_VAGA                    NUMBER(1)   := 1; --PUBLICO
    P_CO_SEMESTRE_FINANCIAMENTO  NUMBER(5)   := 20202;
    P_CO_SITUACAO_INSCRICAO      NUMBER(2)   := 3; -- Validado pelo MEC
    P_CO_SITUACAO_FINANCIAMENTO  NUMBER(2)   := 1;

    --VARIAVEIS
    P_NU_CPF                     VARCHAR2(11);
    P_CO_USUARIO                 NUMBER(10);
    P_CO_SEMESTRE                NUMBER(5);
    V_CO_PERFIL_USUARIO          NUMBER(1)   :=1;
    V_CO_LIMINAR                 NUMBER(10);
    V_CO_SITUACAO_FIN_ATUAL      NUMBER(10);
    V_CO_SITUACAO_FIN_RECUPERADA NUMBER(10);
    V_CO_MOTIVO_SITUACAO_REC     NUMBER(10);
    V_DT_DESOCUPACAO             DATE;
    V_CO_INSCRICAO               NUMBER(10);
    V_CO_SEMESTRE                NUMBER(5);
    V_CO_USUARIO                 NUMBER(10);
    V_TP_USUARIO                 NUMBER(1);
    V_TP_VAGA                    NUMBER(1);
    V_TP_VAGA_LIMINAR            NUMBER(1);
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
    V_GERA_LIMINAR               VARCHAR2(1000);
    V_RETORNO_INSERT             VARCHAR2(1000);
    V_RETORNO                    VARCHAR2(1000);
    V_MSG_ERROR                  VARCHAR2(1000);
    V_EXISTE                     NUMBER(10);
    V_VAGA_RECUPERADA            NUMBER(1):=0;
    V_TOTAL                      NUMBER(10):=0;
    --
    V_COMPL_PES_FIS     NUMBER(10);
    V_CO_TIPO_LIMINAR   NUMBER(3):=3; --Liberacao de vagas para o financiamento
    V_ST_IMPORTANCIA    CHAR(1):= 'O'; --OPCAO (NAO vinculado a processo judicial)
    V_ST_GRUPO          CHAR(1):= 'P'; --pessoal/individual
    V_ULTIMO_DIA        DATE;
    V_DS_JUSTIFICATIVA  VARCHAR2(100):= 'Liminar de liberacao/recuperacao de vaga solicitado por demanda';


BEGIN
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('--|SIMEC Recuperar Vaga |--');
    DBMS_OUTPUT.PUT_LINE('Inicio...'||to_char(sysdate,'YYYY-mm-dd HH24:MI:SS')||'.' );
    DBMS_OUTPUT.PUT_LINE(' ');

BEGIN
----|INICIO
    --Recupera dados do cursor
    V_RETORNO       := NULL;
    V_TP_VAGA_LIMINAR := 1;
    
    SELECT PF.NU_CPF ,CO_SEMESTRE, I.CO_USUARIO INTO P_NU_CPF, P_CO_SEMESTRE, P_CO_USUARIO 
    FROM FIES_PREINSCRICAO.TB_PRE_INSCRICAO I
    LEFT JOIN FIES_PREINSCRICAO.TB_PRE_USUARIO U ON U.CO_USUARIO = I.CO_USUARIO
    LEFT JOIN FIES_GLOBAL.TB_GLB_PESSOA_FISICA PF ON PF.CO_PESSOA = U.CO_PESSOA
    WHERE I.CO_INSCRICAO = P_CO_INSCRICAO;
    
    
    IF V_RETORNO IS NULL THEN
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
                AND PI.CO_SEMESTRE    = P_CO_SEMESTRE
                AND PI.CO_USUARIO     = P_CO_USUARIO
                AND PI.TP_USUARIO     = P_TP_USUARIO;

        EXCEPTION
            WHEN OTHERS THEN
            BEGIN
                V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"FALHA AO RECUPERAR A PRIMEIRA OPCAO DA TERMO"}';
                SELECT 0 INTO V_VAGA_RECUPERADA FROM DUAL;
            END;
        END;
        END IF;

        --
        --VERIFICAR SE O TERMO EXISTE
        IF V_VAGA_RECUPERADA = 0 THEN
        BEGIN
            --
            SELECT COUNT(1)
              INTO V_EXISTE
              FROM FIES_PREINSCRICAO.TB_PRE_TERMO_FINANCIAMENTO
             WHERE CO_INSCRICAO = P_CO_INSCRICAO
               AND CO_CURSO     = V_CO_CURSO
               AND CO_TURNO     = V_CO_TURNO;

            IF V_EXISTE = 0 THEN
                --REINSERE NA TERMO CASO NAO EXISTA
                INSERT INTO FIES_PREINSCRICAO.TB_PRE_TERMO_FINANCIAMENTO(CO_TERMO_FINANCIAMENTO,CO_INSCRICAO,CO_OFERTA_VAGAS,CO_CURSO,CO_TURNO,NU_OPCAO,QT_SEMESTRE_CURSO,QT_SEMESTRE_CONCLUIDO,QT_SEMESTRE_FINANCIAMENTO,
                        VL_SEMESTRALIDADE_SEM_DESC,VL_SEMESTRALIDADE_COM_DESC,VL_SEMESTRALIDADE_FIES,ST_BOLSISTA_PROUNI,NU_PERCENTUAL_PROUNI,ST_MENSALIDADE_PERMITIDA,CO_TERMO_FINANCIAMENTO_VAGA)
                SELECT  TF.CO_TERMO_FINANCIAMENTO,TF.CO_INSCRICAO,TF.CO_OFERTA_VAGAS,TF.CO_CURSO,TF.CO_TURNO,TF.NU_OPCAO,TF.QT_SEMESTRE_CURSO,TF.QT_SEMESTRE_CONCLUIDO,TF.QT_SEMESTRE_FINANCIAMENTO,
                        TF.VL_SEMESTRALIDADE_SEM_DESC,TF.VL_SEMESTRALIDADE_COM_DESC,TF.VL_SEMESTRALIDADE_FIES,TF.ST_BOLSISTA_PROUNI,TF.NU_PERCENTUAL_PROUNI,TF.ST_MENSALIDADE_PERMITIDA,TF.CO_TERMO_FINANCIAMENTO_VAGA
                FROM
                   (
                        SELECT *
                        FROM
                            (
                                SELECT * FROM FIES_AUDITORIA.LG_PRE_TERMO_FINANCIAMENTO
                                WHERE CO_INSCRICAO = P_CO_INSCRICAO
                                  AND CO_CURSO     = V_CO_CURSO
                                  AND CO_TURNO     = V_CO_TURNO
                                  AND TP_OPERACAO_LOG = 'U'
                                ORDER BY DT_OPERACAO_LOG DESC
                            ) WHERE ROWNUM = 1
                    ) TF;
            END IF;

            SELECT COUNT(1)
              INTO V_EXISTE
              FROM FIES_PREINSCRICAO.TB_PRE_TERMO_FINANCIAMENTO
             WHERE CO_INSCRICAO = P_CO_INSCRICAO
               AND CO_CURSO     = V_CO_CURSO
               AND CO_TURNO     = V_CO_TURNO;

            IF V_EXISTE = 0 THEN
                --V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"FALHA AO RECUPERAR O TERMO DE FINANCIAMENTO - CURSO('||V_CO_CURSO||') TURNO('||V_CO_TURNO||')"}';
                SELECT 0 INTO V_VAGA_RECUPERADA FROM DUAL;
            END IF;
            --
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
           AND CO_CURSO   = V_CO_CURSO
           AND CO_TURNO   = V_CO_TURNO
           AND TP_VAGA    = V_TP_VAGA
           AND NOT EXISTS  (SELECT 1
                             FROM FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO PCO
                            WHERE PCO.CO_CURSO   = DET.CO_CURSO
                              AND PCO.CO_H_CURSO = DET.CO_H_CURSO
                              AND PCO.CO_TURNO   = DET.CO_TURNO
                              AND PCO.NU_LINHA   = DET.NU_LINHA
                            );


        --Gerar vaga de liminar na cluster curso detalhe
        IF V_NU_LINHA = 0 THEN
        BEGIN
            --V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"ERRO AO RECUPERAR UMA CADEIRA DISPONIVEL NO CURSO SELECIONADO PELO CANDIDATO NA INSCRICAO"}';
            --CRIAR UMA CADEIRA NO CURSO
            V_TP_VAGA_LIMINAR := 3;

            SELECT NVL(MAX(NU_LINHA), 0) + 1
              INTO V_NU_LINHA
              FROM FIES_PREINSCRICAO.TB_PRE_CLUSTER_CURSO_DETALHE DET
             WHERE CO_CLUSTER = V_CO_CLUSTER
               AND CO_CURSO   = V_CO_CURSO
               AND CO_TURNO   = V_CO_TURNO;

            INSERT INTO FIES_PREINSCRICAO.TB_PRE_CLUSTER_CURSO_DETALHE
            (CO_CLUSTER_CURSO_DETALHE, CO_CLUSTER, CO_H_CURSO, CO_CURSO, CO_TURNO, NU_LINHA, ST_UTILIZADO, ST_TIPO_VAGA, TP_VAGA)
            VALUES
            (FIES_PREINSCRICAO.SQ_PRE_CLUSTER_CURSO_DETALHE.NEXTVAL, V_CO_CLUSTER, V_CO_H_CURSO, V_CO_CURSO, V_CO_TURNO, V_NU_LINHA, 'N', 1, V_TP_VAGA_LIMINAR);

            EXCEPTION
                WHEN OTHERS THEN
                    V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"Falha ao gerar vaga de liminar ['||V_NU_LINHA||'] - cluster['||V_CO_CLUSTER||'] hcurso['||V_CO_H_CURSO||'] curso['||V_CO_CURSO||'] - turno['||V_CO_TURNO||'] - ['||SQLERRM||'] "}';
        END;
        END IF;

        --GERAR/Recuperar liminar para a inscricao
        IF ( V_TP_VAGA_LIMINAR = 3 AND V_RETORNO IS NULL) THEN
        BEGIN

             --Verifica se tem liminar vigente ja vinculada ao CPF
            BEGIN
                SELECT
                     LM.CO_LIMINAR INTO V_CO_LIMINAR
                FROM FIES_PREINSCRICAO.TB_PRE_INSCRICAO            PI
                JOIN FIES_PREINSCRICAO.TB_PRE_USUARIO              US ON US.CO_USUARIO   = PI.CO_USUARIO
                JOIN FIES_GLOBAL.TB_GLB_PESSOA_FISICA              PF ON PF.CO_PESSOA    = US.CO_PESSOA
                JOIN FIES_PREINSCRICAO.TB_PRE_USUARIO_SEMESTRE     UE ON UE.CO_USUARIO   = PI.CO_USUARIO AND UE.CO_SEMESTRE = PI.CO_SEMESTRE AND UE.TP_USUARIO = PI.TP_USUARIO
                JOIN FIES_PREINSCRICAO.TB_PRE_ABRANGENCIA          AB ON AB.CO_COMPL_PESSOA_FISICA = UE.CO_COMPL_PESSOA_FISICA
                JOIN FIES_PREINSCRICAO.TB_PRE_LIMINAR              LM ON LM.CO_LIMINAR   = AB.CO_LIMINAR
                JOIN FIES_PREINSCRICAO.TB_PRE_LIMINAR_TIPO_LIMINAR TL ON TL.CO_LIMINAR   = LM.CO_LIMINAR
                WHERE 1=1
                AND PI.CO_INSCRICAO    = P_CO_INSCRICAO
                AND TL.CO_TIPO_LIMINAR = V_CO_TIPO_LIMINAR
                AND TL.ST_IMPORTANCIA  = V_ST_IMPORTANCIA
                AND LM.DT_FINAL_VIGENCIA > SYSDATE;

                V_GERA_LIMINAR := '{"CO_INSCRICAO":"'||P_CO_INSCRICAO||'", "CO_LIMINAR":"'||V_CO_LIMINAR||'", "ERRO":"" }';
            EXCEPTION
                WHEN OTHERS THEN
                    V_GERA_LIMINAR := NULL;
            END;


            --Gerar nova liminar
            IF V_GERA_LIMINAR IS NULL THEN
            BEGIN
                --|Recuperar ultimo dia do ano
                SELECT TO_DATE('31/12/'||CEIL(EXTRACT(YEAR from sysdate))||' 23:59:59', 'DD/MM/YYYY HH24:MI:SS') ULTIMO_DIA_ANO INTO V_ULTIMO_DIA FROM DUAL;

                --|TB_PRE_LIMINAR
                SELECT FIES_PREINSCRICAO.SQ_PRE_LIMINAR.NEXTVAL INTO V_CO_LIMINAR FROM DUAL;

                INSERT INTO FIES_PREINSCRICAO.TB_PRE_LIMINAR
                           ( CO_LIMINAR, CO_PERFIL_USUARIO, DT_CADASTRO, DT_INICIAL_VIGENCIA, DT_FINAL_VIGENCIA, ST_CONCLUIDO, CO_SEMESTRE )
                VALUES     ( V_CO_LIMINAR, V_CO_PERFIL_USUARIO, SYSDATE, SYSDATE, V_ULTIMO_DIA, 'N', P_CO_SEMESTRE );


                --|TB_PRE_HISTORICO_LIMINAR
                INSERT INTO FIES_PREINSCRICAO.TB_PRE_HISTORICO_LIMINAR
                           ( CO_HISTORICO_LIMINAR, CO_LIMINAR, ST_CONCLUIDO, DS_JUSTIFICATIVA_LIMINAR, DT_INICIO_VIGENCIA, DT_TERMINO_VIGENCIA, CO_PERFIL_USUARIO, DT_HISTORICO_LIMINAR, CO_SEMESTRE )
                VALUES     ( FIES_PREINSCRICAO.SQ_PRE_HISTORICO_LIMINAR.NEXTVAL, V_CO_LIMINAR, 'N', V_DS_JUSTIFICATIVA, SYSDATE, V_ULTIMO_DIA, V_CO_PERFIL_USUARIO, SYSDATE, P_CO_SEMESTRE );

                --|TB_PRE_LIMINAR_TIPO_LIMINAR
                INSERT INTO FIES_PREINSCRICAO.TB_PRE_LIMINAR_TIPO_LIMINAR ( CO_LIMINAR, CO_TIPO_LIMINAR, ST_IMPORTANCIA )
                VALUES (V_CO_LIMINAR, V_CO_TIPO_LIMINAR, V_ST_IMPORTANCIA);

                --|TB_PRE_ABRANGENCIA
                INSERT INTO FIES_PREINSCRICAO.TB_PRE_ABRANGENCIA
                       (CO_ABRANGENCIA, CO_LIMINAR, CO_COMPL_PESSOA_FISICA, DT_CADASTRO_ABRANGENCIA, ST_NOTIFICACAO, ST_GRUPO)
                VALUES (FIES_PREINSCRICAO.SQ_PRE_ABRANGENCIA.NEXTVAL, V_CO_LIMINAR, V_COMPL_PES_FIS, SYSDATE, 'N', V_ST_GRUPO );

                --SAIDA
                V_GERA_LIMINAR := '{"CO_INSCRICAO":"'||P_CO_INSCRICAO||'", "CO_LIMINAR":"'||V_CO_LIMINAR||'", "ERRO":"" }';
                EXCEPTION
                WHEN OTHERS THEN BEGIN
                    V_GERA_LIMINAR := '{"CO_INSCRICAO":"'||P_CO_INSCRICAO||'", "CO_LIMINAR":"0", "ERRO":" FALHA AO CRIAR LIMINAR ('||SQLERRM||')" }';
                END;

            END;
            END IF;

            /* FUNCAO  SELECT FIES_PREINSCRICAO.FC_LIMINAR_RECUPERACAO_VAGA(P_CO_INSCRICAO) INTO V_GERA_LIMINAR FROM DUAL;   */
            SELECT  JSON_VALUE(V_GERA_LIMINAR, '$.CO_LIMINAR'),
                    JSON_VALUE(V_GERA_LIMINAR, '$.ERRO')
            INTO V_CO_LIMINAR, V_MSG_ERROR
            FROM DUAL;

            IF V_CO_LIMINAR = 0 THEN
                V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"Falha ao gerar liminar - ['||V_MSG_ERROR||'] "}';
            END IF;


        END;
        END IF;


    END IF;

    --
    IF V_RETORNO IS NULL THEN

        --VALIDA SE HA POSSIBILIDADE DE OCUPAR NO CURSO.
        --RECUPERA UMA VAGA PUBLICA
        IF V_TP_VAGA_LIMINAR = 1 THEN
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

    END IF;

    --
    IF V_RETORNO IS NULL THEN
    BEGIN
        --|TB_FIN_CANDIDATO - PREPARA TABELA CANDIDATO PARA OCUPACAO DO TIPO LIMINAR
        UPDATE FIES_FINANCIAMENTO.TB_FIN_CANDIDATO
           SET  DT_INICIO_FINANCIAMENTO   = NULL,
                DT_FIM_FINANCIAMENTO      = NULL,
                DT_LIMITE_CPSA            = NULL,
                CO_SEMESTRE_FINANCIAMENTO = NULL,
                TP_VAGA                   = NULL,
                CO_INSCRICAO              = NULL
         WHERE  CO_USUARIO                = P_CO_USUARIO;

        --|TB_PRE_CHAMADA_OCUPACAO
        UPDATE  FIES_PREINSCRICAO.TB_PRE_CHAMADA_OCUPACAO
        SET     DT_OCUPACAO             = SYSDATE,
                DT_DESOCUPACAO          = NULL,
                CO_CLUSTER              = NULL,
                CO_CLUSTER_VAGA_PUBLICO = NULL,
                CO_H_CURSO              = V_CO_H_CURSO,
                CO_CURSO                = V_CO_CURSO,
                CO_TURNO                = V_CO_TURNO,
                NU_LINHA                = V_NU_LINHA,
                TP_VAGA                 = V_TP_VAGA_LIMINAR,
                CO_LIMINAR              = V_CO_LIMINAR,
                TP_CHAMADA_OCUPACAO     = 2
        WHERE   CO_INSCRICAO            = P_CO_INSCRICAO
          AND   CO_USUARIO              = P_CO_USUARIO
          AND   CO_SEMESTRE             = P_CO_SEMESTRE
          AND   TP_USUARIO              = P_TP_USUARIO
          AND   TP_VAGA                 = P_TP_VAGA;


        --TB_FIN_CANDIDATO (DATAS)
        UPDATE FIES_FINANCIAMENTO.TB_FIN_CANDIDATO
           SET  DT_INICIO_FINANCIAMENTO   = SYSDATE,
                DT_FIM_FINANCIAMENTO      = ( SELECT TO_DATE(TO_CHAR(TRUNC(FIES_GLOBAL.SOMA_DIAS_UTEIS(SYSDATE, 5)), 'DD/MM/YYYY') || ' 23:59:59', 'DD/MM/YYYY HH24:MI:SS') FROM DUAL ),
                DT_LIMITE_CPSA            = ( SELECT TO_DATE(TO_CHAR(TRUNC(FIES_GLOBAL.SOMA_DIAS_UTEIS(SYSDATE, 7)), 'DD/MM/YYYY') || ' 23:59:59', 'DD/MM/YYYY HH24:MI:SS') FROM DUAL ),
                CO_SEMESTRE_FINANCIAMENTO = P_CO_SEMESTRE_FINANCIAMENTO,
                CO_SEMESTRE               = P_CO_SEMESTRE,
                TP_USUARIO                = P_TP_USUARIO,
                TP_VAGA                   = V_TP_VAGA_LIMINAR,
                CO_INSCRICAO              = P_CO_INSCRICAO
        WHERE  CO_USUARIO                 = P_CO_USUARIO;


        EXCEPTION
        WHEN OTHERS THEN
            V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "LIMINAR": "'||V_CO_LIMINAR||'", "TP_VAGA": "'||V_TP_VAGA_LIMINAR||'", "ERRO":"FALHA AO OCUPAR VAGA] - ['||SQLERRM||'] "}';
    END;
    END IF;


    IF V_RETORNO IS NULL THEN
    BEGIN

        --|TB_PRE_INSCRICAO - SITUACAO INSCRICAO
        UPDATE FIES_PREINSCRICAO.TB_PRE_INSCRICAO
           SET CO_SITUACAO_INSCRICAO  = P_CO_SITUACAO_INSCRICAO,
               CO_TIPO_VENCIMENTO     = NULL,
               CO_MOTIVO_CANCELAMENTO = NULL
         WHERE CO_INSCRICAO = P_CO_INSCRICAO;
        --DBMS_OUTPUT.PUT_LINE('TB_PRE_INSCRICAO - Total de Linhas Atualizadas:'||SQL%ROWCOUNT||'.');


        --(TH_FIN_CANDIDATO_PUBLICO) SITUACAO FINANCIAMENTO
        INSERT INTO FIES_FINANCIAMENTO.TH_FIN_CANDIDATO_PUBLICO (CO_H_CANDIDATO_PUBLICO, CO_CANDIDATO_PUBLICO, CO_SITUACAO_FINANCIAMENTO, CO_MOTIVO_SITUACAO, DT_HISTORICO, CO_PERFIL_USUARIO)
        VALUES ( FIES_FINANCIAMENTO.SQ_H_FIN_CANDIDATO_PUBLICO.NEXTVAL, P_CO_USUARIO, P_CO_SITUACAO_FINANCIAMENTO, NULL, SYSDATE, V_CO_PERFIL_USUARIO );
        --DBMS_OUTPUT.PUT_LINE('TH_FIN_CANDIDATO_PUBLICO - Total de Linhas Incluidas:'||SQL%ROWCOUNT||'.');

        EXCEPTION
        WHEN OTHERS THEN
            V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO": "'||P_CO_INSCRICAO||'", "ERRO":"FALHA ATUALIZAR A SITUACAO DA INSCRICAO] - ['||SQLERRM||'] "}';

    END;
    END IF;
    IF V_RETORNO IS NULL THEN
        V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO":"'||P_CO_INSCRICAO||'", "VAGA RECUPERADA COM SUCESSO":"CLUSTER('||V_CO_CLUSTER||') CURSO('||V_CO_CURSO||') TURNO('||V_CO_TURNO||') LINHA('||V_NU_LINHA||') TIPO('||V_TP_VAGA_LIMINAR||') LIMINAR ('||V_CO_LIMINAR||')"}';
    END IF;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('MSG : '||V_RETORNO);
    V_TOTAL        := V_TOTAL + 1;
    EXCEPTION
    WHEN OTHERS THEN
    BEGIN
        ROLLBACK;
        V_RETORNO := '{"CPF":"'||P_NU_CPF||'", "INSCRICAO":"'||P_CO_INSCRICAO||'", "FALHA AO RECUPERAR A VAGA":"CLUSTER('||V_CO_CLUSTER||') CURSO('||V_CO_CURSO||') TURNO('||V_CO_TURNO||') LINHA('||V_NU_LINHA||') TIPO('||V_TP_VAGA_LIMINAR||')", "ERRO":"'||SQLERRM||')"}';
        DBMS_OUTPUT.PUT_LINE('MSG : '||V_RETORNO);
    END;
    --
    --
---|TERMINO
END;

DBMS_OUTPUT.PUT_LINE(' ');
DBMS_OUTPUT.PUT_LINE('Total de registros processados: '||V_TOTAL);
DBMS_OUTPUT.PUT_LINE('Termino...'||to_char(sysdate,'YYYY-mm-dd HH24:MI:SS')||'.');
DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------');

END;--FIM
/*===========================================================================================================================*/
