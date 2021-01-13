-- CONSULTA REALIZADO PELO SISTEMA SISFIES JURIDICO PARA CARREGAR ADITAMENTOS COM CONTRATOS REALIZADOS ANTERIORES AO 12018

SELECT
  nu_semestre_referencia,
  co_aditamento,
  dt_conclusao,
  co_finalidade_aditamento,
  ds_finalidade_aditamento,
  co_dilatacao,
  dt_comparecimento_banco,
  dt_retorno_banco,
  tp_aditamento,
  ds_tp_aditamento,
  qt_semestre_financiamento,
  ds_situacao_aditamento,
  ds_detalhe_situacao,
  co_situacao,
  dt_inclusao,
  co_situacao_aditamento,
  st_aprovacao_aluno,
  nu_percentual_prouni
FROM (

  /*Contrato - Para contrato, exibir data da contratação pelo banco*/
  SELECT
    a.nu_semestre_referencia,
    a.st_migrado,
    a.co_aditamento,
    c.dt_assinatura                                                     AS dt_conclusao,
    a.co_finalidade_aditamento,
    fa.ds_finalidade_aditamento,
    NULL :: NUMERIC                                                     AS co_dilatacao,
    dt_comparecimento_banco,
    dt_retorno_banco,
    tp_aditamento,
    decode(tp_aditamento, 'S', 'Simplificado', 'N', 'Não Simplificado') AS ds_tp_aditamento,
    qt_semestre_financiamento,
    sa.ds_situacao_aditamento,
    sa.co_situacao_aditamento,
    sa.ds_detalhes_situacao                                             AS ds_detalhe_situacao,
    a.co_situacao_aditamento                                            AS co_situacao,
    NULL :: TIMESTAMP                                                   AS dt_inclusao,
    a.st_aprovacao_aluno,
    a.nu_percentual_prouni

  FROM inscricao.tb_fies_aditamento AS a
    LEFT JOIN financeiro.tb_fies_contrato AS c ON (c.nu_cpf = a.nu_cpf)
    INNER JOIN inscricao.tb_fies_finalidade_aditamento AS fa
      ON (fa.co_finalidade_aditamento = a.co_finalidade_aditamento)
    INNER JOIN inscricao.tb_fies_curso_associado_aditamento AS ca
      ON (ca.co_curso_associado_aditamento = a.co_curso_associado_aditamento)
    INNER JOIN inscricao.tb_fies_situacao_aditamento AS sa ON (sa.co_situacao_aditamento = a.co_situacao_aditamento)
  WHERE (a.co_inscricao = 5674759)
        AND (a.co_finalidade_aditamento IN (1))

  UNION

  /* Aditamentos
  * Para aditamento simplificado, exibir data da validação pelo estudante.
  * Para aditamento não simplificado, exibir data da contratação pelo banco.
  */
  SELECT
    a.nu_semestre_referencia,
    a.st_migrado,
    a.co_aditamento,
    CASE (tp_aditamento = 'S')
    WHEN TRUE
      THEN dt_conclusao_aditamento
    ELSE dt_comparecimento_banco
    END                                                                 AS dt_conclusao,
    a.co_finalidade_aditamento,
    fa.ds_finalidade_aditamento,
    NULL :: NUMERIC                                                     AS co_dilatacao,
    dt_comparecimento_banco,
    dt_retorno_banco,
    tp_aditamento,
    decode(tp_aditamento, 'S', 'Simplificado', 'N', 'Não Simplificado') AS ds_tp_aditamento,
    qt_semestre_financiamento,
    sa.ds_situacao_aditamento,
    sa.co_situacao_aditamento,
    sa.ds_detalhes_situacao                                             AS ds_detalhe_situacao,
    a.co_situacao_aditamento                                            AS co_situacao,
    NULL :: TIMESTAMP                                                   AS dt_inclusao,
    a.st_aprovacao_aluno,
    a.nu_percentual_prouni

  FROM inscricao.tb_fies_aditamento AS a
    INNER JOIN inscricao.tb_fies_finalidade_aditamento AS fa
      ON (fa.co_finalidade_aditamento = a.co_finalidade_aditamento)
    INNER JOIN inscricao.tb_fies_curso_associado_aditamento AS ca
      ON (ca.co_curso_associado_aditamento = a.co_curso_associado_aditamento)
    INNER JOIN inscricao.tb_fies_situacao_aditamento AS sa ON (sa.co_situacao_aditamento = a.co_situacao_aditamento)
  WHERE (a.co_inscricao = 5674759)
        AND (a.co_finalidade_aditamento IN (2))

  UNION

  /* Transferencia - transferência (destino), exibir data de validação pela CPSA*/
  SELECT
    a.nu_semestre_referencia,
    a.st_migrado,
    a.co_aditamento,
    CASE (dt_validacao_cpsa_destino IS NULL)
    WHEN TRUE
      THEN dt_validacao_cpsa
    ELSE dt_validacao_cpsa_destino
    END                                                                 AS dt_conclusao,
    a.co_finalidade_aditamento,
    fa.ds_finalidade_aditamento,
    NULL :: NUMERIC                                                     AS co_dilatacao,
    dt_comparecimento_banco,
    dt_retorno_banco,
    tp_aditamento,
    decode(tp_aditamento, 'S', 'Simplificado', 'N', 'Não Simplificado') AS ds_tp_aditamento,
    NULL                                                                AS qt_semestre_financiamento,
    sa.ds_situacao_aditamento,
    sa.co_situacao_aditamento,
    sa.ds_detalhes_situacao                                             AS ds_detalhe_situacao,
    a.co_situacao_aditamento                                            AS co_situacao,
    NULL :: TIMESTAMP                                                   AS dt_inclusao,
    a.st_aprovacao_aluno,
    a.nu_percentual_prouni

  FROM inscricao.tb_fies_aditamento AS a
    INNER JOIN inscricao.tb_fies_finalidade_aditamento AS fa
      ON (fa.co_finalidade_aditamento = a.co_finalidade_aditamento)
    INNER JOIN inscricao.tb_fies_curso_associado_aditamento AS ca
      ON (ca.co_curso_associado_aditamento = a.co_curso_associado_aditamento)
    INNER JOIN inscricao.tb_fies_situacao_aditamento AS sa ON (sa.co_situacao_aditamento = a.co_situacao_aditamento)
  WHERE (a.co_inscricao = 5674759)
        AND (a.co_finalidade_aditamento IN (3))

  UNION

  /* Dilatação */
  SELECT
    nu_semestre_inicio        AS nu_semestre_referencia,
    NULL                      AS st_migrado,
    co_dilatacao              AS co_aditamento,
    d.dt_conclusao_dilatacao  AS dt_conclusao,
    4                         AS co_finalidade_aditamento,
    'Aditamento de Dilatação' AS ds_finalidade_aditamento,
    co_dilatacao,
    NULL :: TIMESTAMP         AS dt_comparecimento_banco,
    NULL :: TIMESTAMP         AS dt_retorno_banco,
    NULL                      AS tp_aditamento,
    NULL                      AS ds_tp_aditamento,
    NULL                      AS qt_semestre_financiamento,
    sd.ds_situacao_dilatacao  AS ds_situacao_aditamento,
    sd.co_situacao_dilatacao  AS co_situacao_aditamento,
    sd.ds_detalhes_situacao   AS ds_detalhe_situacao,
    d.co_situacao_dilatacao   AS co_situacao,
    d.dt_inclusao_dilatacao   AS dt_inclusao,
    NULL                      AS st_aprovacao_aluno,
    d.nu_percentual_prouni

  FROM inscricao.tb_fies_dilatacao AS d
    INNER JOIN inscricao.tb_fies_situacao_dilatacao AS sd ON (sd.co_situacao_dilatacao = d.co_situacao_dilatacao)
  WHERE (d.co_inscricao = 5674759)
        AND (d.co_situacao_dilatacao IN (5))

  /*SS741*/
  UNION

  SELECT
    enc.nu_semestre_referencia,
    NULL                          AS st_migrado,
    enc.co_encerramento           AS co_aditamento,
    enc.dt_conclusao_encerramento AS dt_conclusao,
    6                             AS co_finalidade_aditamento,
    'Encerramento'                AS ds_finalidade_aditamento,
    NULL :: NUMERIC               AS co_dilatacao,
    NULL :: TIMESTAMP             AS dt_comparecimento_banco,
    NULL :: TIMESTAMP             AS dt_retorno_banco,
    NULL                          AS tp_aditamento,
    NULL                          AS ds_tp_aditamento,
    NULL                          AS qt_semestre_financiamento,
    se.ds_situacao_encerramento   AS ds_situacao_aditamento,
    se.co_situacao_encerramento   AS co_situacao_aditamento,
    se.ds_detalhe_situacao,
    enc.co_situacao_encerramento  AS co_situacao,
    enc.dt_inclusao_encerramento  AS dt_inclusao,
    NULL                          AS st_aprovacao_aluno,
    NULL                          AS nu_percentual_prouni

  FROM inscricao.tb_fies_encerramento AS enc
    INNER JOIN inscricao.tb_fies_situacao_encerramento AS se
      ON (se.co_situacao_encerramento = enc.co_situacao_encerramento)
  WHERE (enc.co_inscricao = 5674759)

  /*SS670*/
  UNION

  SELECT
    susp.nu_semestre_referencia,
    NULL                       AS st_migrado,
    susp.co_suspensao          AS co_aditamento,
    susp.dt_confirmacao_af     AS dt_conclusao,
    5                          AS co_finalidade_aditamento,
    'Suspensão'                AS ds_finalidade_aditamento,
    NULL :: NUMERIC            AS co_dilatacao,
    NULL :: TIMESTAMP          AS dt_comparecimento_banco,
    NULL :: TIMESTAMP          AS dt_retorno_banco,
    NULL                       AS tp_aditamento,
    NULL                       AS ds_tp_aditamento,
    qt_semestre_financiamento,
    ss.ds_situacao_suspensao   AS ds_situacao_aditamento,
    ss.co_situacao_suspensao   AS co_situacao_aditamento,
    ss.ds_detalhe_situacao,
    susp.co_situacao_suspensao AS co_situacao,
    susp.dt_inclusao_suspensao AS dt_inclusao,
    NULL                       AS st_aprovacao_aluno,
    susp.nu_percentual_prouni

  FROM inscricao.tb_fies_suspensao AS susp
    INNER JOIN inscricao.tb_fies_situacao_suspensao AS ss ON (ss.co_situacao_suspensao = susp.co_situacao_suspensao)
  WHERE (susp.co_inscricao = 5674759)
)
ORDER BY substring(nu_semestre_referencia FROM 2 FOR 4) ASC,
  substring(nu_semestre_referencia FROM 1 FOR 1) ASC,
  dt_conclusao;
  
  
 -- CONSULTA REALIZADA PELO SISFIES JURIDICO AOS ADITAMENTOS A PARTIR DA CONTRATAÇAO DAS INSCRIÇOES DE 12018

SELECT
  nu_semestre_referencia,
  co_aditamento,
  dt_conclusao,
  co_finalidade_aditamento,
  ds_finalidade_aditamento,
  co_dilatacao,
  dt_comparecimento_banco,
  dt_retorno_banco,
  tp_aditamento,
  ds_tp_aditamento,
  qt_semestre_financiamento,
  ds_situacao_aditamento,
  ds_detalhe_situacao,
  co_situacao,
  dt_inclusao,
  co_situacao_aditamento,
  st_aprovacao_aluno,
  nu_percentual_prouni,
  co_tipo_fianca
FROM (

  /*Contrato - Para contrato, exibir data da contratação pelo banco*/
  SELECT
    a.nu_semestre_referencia,
    a.st_migrado,
    a.co_aditamento,
    c.dt_assinatura                                                     AS dt_conclusao,
    a.co_finalidade_aditamento,
    fa.ds_finalidade_aditamento,
    NULL :: NUMERIC                                                     AS co_dilatacao,
    dt_comparecimento_banco,
    dt_retorno_banco,
    tp_aditamento,
    decode(tp_aditamento, 'S', 'Simplificado', 'N', 'Não Simplificado') AS ds_tp_aditamento,
    qt_semestre_financiamento,
    sa.ds_situacao_aditamento,
    sa.co_situacao_aditamento,
    sa.ds_detalhes_situacao                                             AS ds_detalhe_situacao,
    a.co_situacao_aditamento                                            AS co_situacao,
    NULL :: TIMESTAMP                                                   AS dt_inclusao,
    a.st_aprovacao_aluno,
    a.nu_percentual_prouni,
    a.co_tipo_fianca

  FROM inscricao.tb_fies_aditamento_origem_cef AS a
    LEFT JOIN financeiro.tb_fies_contrato AS c ON (c.nu_cpf = a.nu_cpf)
    INNER JOIN inscricao.tb_fies_finalidade_aditamento AS fa
      ON (fa.co_finalidade_aditamento = a.co_finalidade_aditamento)
    INNER JOIN inscricao.tb_fies_curso_associado_aditamento_origem_cef AS ca
      ON (ca.co_curso_associado_aditamento = a.co_curso_associado_aditamento)
    INNER JOIN inscricao.tb_fies_situacao_aditamento AS sa
      ON (sa.co_situacao_aditamento = a.co_situacao_aditamento)
  WHERE
    (a.co_inscricao = 5674759)
    AND (a.co_finalidade_aditamento IN (1))

  UNION

  /* Aditamentos
  * Para aditamento simplificado, exibir data da validação pelo estudante.
  * Para aditamento não simplificado, exibir data da contratação pelo banco.
  */
  SELECT
    a.nu_semestre_referencia,
    a.st_migrado,
    a.co_aditamento,
    CASE (tp_aditamento = 'S')
    WHEN TRUE
      THEN dt_conclusao_aditamento
    ELSE dt_comparecimento_banco
    END                                                                 AS dt_conclusao,
    a.co_finalidade_aditamento,
    fa.ds_finalidade_aditamento,
    NULL :: NUMERIC                                                     AS co_dilatacao,
    dt_comparecimento_banco,
    dt_retorno_banco,
    tp_aditamento,
    decode(tp_aditamento, 'S', 'Simplificado', 'N', 'Não Simplificado') AS ds_tp_aditamento,
    qt_semestre_financiamento,
    sa.ds_situacao_aditamento,
    sa.co_situacao_aditamento,
    sa.ds_detalhes_situacao                                             AS ds_detalhe_situacao,
    a.co_situacao_aditamento                                            AS co_situacao,
    NULL :: TIMESTAMP                                                   AS dt_inclusao,
    a.st_aprovacao_aluno,
    a.nu_percentual_prouni,
    a.co_tipo_fianca
  FROM inscricao.tb_fies_aditamento_origem_cef AS a
    INNER JOIN inscricao.tb_fies_finalidade_aditamento AS fa
      ON (fa.co_finalidade_aditamento = a.co_finalidade_aditamento)
    INNER JOIN inscricao.tb_fies_curso_associado_aditamento_origem_cef AS ca
      ON (ca.co_curso_associado_aditamento = a.co_curso_associado_aditamento)
    INNER JOIN inscricao.tb_fies_situacao_aditamento AS sa
      ON (sa.co_situacao_aditamento = a.co_situacao_aditamento)
  WHERE
    (a.co_inscricao = 5674759)
    AND (a.co_finalidade_aditamento IN (2))
);