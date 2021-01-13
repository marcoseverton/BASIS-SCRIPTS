-- NOVAS REGRAS PARA TRANSFERENCIA DE CURSO


-- A nota da turma é inscricao.tb_fies_nota_transferencia

/*
Essa TAG impacta a realizacao do aditamento de transferencia, agora, o estudante que deseja realizar transferencia apena terá exito se a sua nota de enem
for maior que a nota da turma. A nota da turma é considerado o maior semestre que antecede o semestre que ele ta desejando transferencia
OU seja se ele deseja transferencia para 2020/2 e a turma que ele deseja nao formou turma em 2020/1 mas apenas em 2018/1 ...
 é utilizada como parametro a nota de 2018/1
Então, quando forem ajustar os dados do estudante para contratacao, existem dois campos que precisam ser observados se contemplam nota e dado... 
vl_nota_enem_considerada e nu_ano_enem, sendo que nu_ano_enem é apenas necessário para inscricoes efetivadas a partir de 2018/1 
que impactará em aditamentos realizados diretamente no Agente Financeiro.
Contudo, duas novas tabelas foram geradas para nos dar suporte em auditoria ou explicacao.
 Pois o estudante na transferencia poderá ter sua transferencia negada, primeiro se nao possuir nota suficiente se comparada a nota da turma mais recente 
 e segundo caso o curso nunca tenha tido turma no FIES.
select st.* , i.vl_nota_enem_considerada, nt.vl_nota_transferencia,nt.co_semestre
  from inscricao.tb_fies_solicita_transferencia st
  inner join inscricao.tb_fies_inscricao i USING (Co_inscricao)
  LEFT join inscricao.tb_fies_nota_transferencia nt USING (co_nota_transferencia)
essas duas tabelas são nova.. ,uma guarda o status da solicitacao do estudante, se foi negado ou permitida a transferencia para uma determinada turma...
 e a segunda tabela guarda a nota da turma.
vl_nota_enem_considerada e nu_ano_enem se encontram na tabela inscricao.tb_fies_inscricao
*/
--CONSULTA PARA VERIFICAR SOLICITACOES
Select co_inscricao, co_solicita_transferencia,vl_nota_transferencia "NOTA TURMA", i.vl_nota_enem_considerada "NOTA ALUNO", st.co_semestre "SEMESTRE DE SOLICITACA",  nt.co_semestre "SEMESTRE TURMA" ,st.*
  from inscricao.tb_fies_solicita_transferencia st
  inner join inscricao.tb_fies_inscricao i using (co_inscricao)
  inner join  inscricao.tb_fies_nota_transferencia nt using (co_nota_transferencia) --caso deseje ver tb as que nao possuiram turma substituir por left
  where nu_cpf = '61685441351' order by st.co_solicita_transferencia

--CONSULTA DA TURMA PARA VERIFICAR QUAL A NOTA DE CORTE PARA TRANSFERENCIA
SELECT ca.co_curso ,ca.co_turno ,ca.co_ies,co_semestre_aditamento, MIN(vl_nota_enem_considerada) vl_nota_transferencia
                     FROM inscricao.tb_fies_inscricao i
                     INNER JOIN inscricao.tb_fies_curso_associado ca USING (nu_cpf)
                     INNER JOIN inscricao.tb_fies_semestre_aditamento USING(nu_semestre_referencia)
                     LEFT  JOIN inscricao.tb_fies_abrangencia_liminar a ON i.nu_cpf = a.nu_cpf
                     LEFT JOIN inscricao.tb_fies_liminar_liberacao_enem e ON e.co_liminar = a.co_liminar
                        												 AND e.st_liberar_inscricao = 'S'
                      LEFT JOIN inscricao.tb_fies_implicacao_liminar ip ON ip.co_liminar = e.co_liminar
                        											     AND ip.tp_implicacao in (16,25)
                    WHERE 1=1
                        AND ca.co_ies ='1885'::int
                        AND ca.co_curso ='1284950'::int
                        AND ca.co_turno ='10067'::int
                        AND co_semestre_aditamento <'65'::int --PARAMETRO serÃ¡ o codigo do semestre, provavelmente onde resultara o primeiro menor devido ao LIMIT.
                    	AND  co_situacao_inscricao in (5,8,10,15)
                    	and  tp_contrato <> 2.  --modalidade fies*
                    	and  tp_usuario = 1.
                    	AND e.co_liminar is null
                    	AND (trim(i.vl_nota_enem_considerada) <> '' and vl_nota_enem_considerada <> 0.00)
                    GROUP BY ca.co_curso,ca.co_turno,ca.co_ies,i.nu_semestre_referencia,co_semestre_aditamento, i.NU_SEMESTRE_REFERENCIA
                    order by co_semestre_aditamento desc
                    limit 1


			
                        select nu_cpf, vl_nota_enem_considerada, nu_ano_enem, * from inscricao.tb_fies_inscricao where 
                        nu_cpf in   ( select nu_cpf from inscricao.tb_fies_curso_associado ca where 
                              ca.co_ies   = 1885
                            AND  ca.co_curso = 1284950
			    AND  ca.co_turno = 10067 ) and co_situacao_inscricao = 5 
			    and vl_nota_enem_considerada is not null



			    