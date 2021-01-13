
--Todos os aditamentos do estudante no módulo financeiro
SELECT a.co_contrato_fies, nu_semestre_aditamento||'/'||nu_ano_aditamento as "Semestre do aditamento", 
     vl_aditamento, a.vl_mensalidade, a.dt_criacao, a.co_mantenedora
 FROM financeiro.tb_fies_aditamento_contrato a
 INNER JOIN financeiro.tb_fies_contrato b ON a.co_contrato_fies = b.co_contrato_fies
WHERE b.nu_cpf = '02006921002'
order by 2

185900	1/2011	799.37	  133.23	2014-04-23 05:57:25.262
185900	1/2012	1679.62	  279.94	2014-05-26 19:07:31.943
185900	1/2013	1917.61	  319.60	2014-06-06 10:33:26.514
185900	1/2014	2171.04	  361.84	2014-07-01 18:58:01.288
185900	2/2011	1956.15	  326.03	2014-05-14 05:52:33.656
185900	2/2012	2015.53	  335.92	2014-05-31 06:49:59.078
185900	2/2013	2004.77	  334.13	2014-06-21 06:46:54.079
185900	2/2014	18065.31  3010.89	2019-06-26 09:00:49.543

--Encontrei o aditamento antigo de 2.2014 na tabela de histórico de aditamentos.
select co_contrato_fies, nu_semestre_aditamento||'/'||nu_ano_aditamento as "Semestre do aditamento", 
    vl_aditamento, vl_mensalidade, dt_criacao, co_mantenedora, co_aditamento
 from financeiro.tb_fies_aditamento_historico
WHERE co_contrato_fies = 185900

185900	2/2014	1443.66	240.61	2014-08-14 17:50:39.824	1493	3575071

--Conferir os repasses do aditamento 2.2014 na tabela de cálculo
SELECT  dt_inclusao, b.nu_cpf, a.co_contrato_fies, nu_mes_referencia, nu_ano_referencia, a.vl_mensalidade, co_processo, a.co_mantenedora
FROM financeiro.tb_fies_calculo_processo_emissao_cfte a
  INNER JOIN financeiro.tb_fies_contrato b ON a.co_contrato_fies = b.co_contrato_fies
WHERE b.nu_cpf = '02006921002'
AND nu_ano_referencia = 2014 AND nu_mes_referencia > 6

2014-08-28	02006921002	185900	7	2014	240.61	100	1493
2014-08-28	02006921002	185900	8	2014	240.61	100	1493
2014-09-29	02006921002	185900	9	2014	240.61	101	1493
2014-10-30	02006921002	185900	10	2014	240.61	102	1493
2014-11-28	02006921002	185900	11	2014	240.61	103	1493
2015-01-13	02006921002	185900	12	2014	240.61	104	1493

--Verificar os ajustes lançados
SELECT dt_ajuste, co_mantenedora, nu_mes_referencia, nu_ano_referencia, vl_mensalidade, tp_operacao, co_processo
 FROM financeiro.tb_fies_ajuste_calculo
WHERE co_contrato_fies = 185900
ORDER by co_mantenedora, dt_ajuste, nu_mes_referencia


Os primeiros lançamentos a débito foram lançados na mantenedora errada, 295 (que não é a mantenedora correta do aditamento 2.2014)
Daí o problema foi resolvido em 10.03.2020 lançando de volta para a manenedora 295 a crédito.
Então, o certo era fazer os lançamentos a débito (da parcela 240.61) para a mantenedora 1493, mas foram lançados só a crédito em 31.10.2019
Mas em 10.03.2020 foram feitos os lançamentos a debito na mantenedora 1493, que deveria ter sido lá em 31.10.2019

Ou seja, as coisas foram feitas na ordem trocada mas no final a mantendora recebeu tudo que tinha que receber.
De 08/2014 a 01/2015 a mantenedora 1493 recebeu (+) 6x 240.61
Em 04/2016 a mantenedora 295 (que não tinha nada a ver com história) teve desconto de (-) 6x 240.61
Em 03/2020 a mantenedora 295 teve o acréscimo de (+) 6x 240.61 para corrigir o erro anterior.

Em 10/2019 a mantenedora 1493 recebeu acréscimo de (+) 6x 3010.89 
Ou seja a mantenedora 1493 recebeu mais do que devia (6x 240.61 + 6x 3010.89) e não teve nenhum débito das parcelas anteriores
Em 03/2020 a mantenedora 1493 teve o desconto de (-) 6x 240.61 para corrigir o erro anterior.

Então, hoje pode-se dizer que foi resolvido e a mantenedora recebeu tudo que lhe era de direito

SELECT * FROM financeiro.vw_fies_valor_repasse
WHERE co_aditamento = 3575071
--Infelizmente a view não tá mostrando os valores ajustados. Só o primeiro repasse.
--vou pedir depois se o Geraldo consegue verificar isso.
Mas vc consegue comprovar na aplicação, no extrato do aluno, usando o perfil jurídico.
Estão lá os lançamentos a débito e crédito.
