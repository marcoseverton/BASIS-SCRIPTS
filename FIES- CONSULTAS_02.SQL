  --Idoneidade
select case when ds_retorno LIKE '%situacao>false%' then 'Restrição' else '' end as "situacao>false"
,case when ds_retorno LIKE '%<ADIMPLENTE>N%' then 'Restrição' else '' end as "ADIMPLENTE>N"
,case when ds_retorno LIKE '%restricao>true%' then 'Restrição' else '' end as "restricao>true",*
from log_ws.tb_fies_ws_idoneidade
where nu_cpf = '07960376980'
order by dt_requisicao DESC

-- VERIFICAR OS PERIODOS  DOS SEMESTRES
SELECT * FROM INSCRICAO.TB_FIES_SEMESTRE_ADITAMENTO

-- CONSULTA PERDA DE VAGA PREINSCRIÇÃO
SELECT CO_SITUACAO_INSCRICAO,* FROM AUDITORIA.VW_LG_FIES_INSCRICAO WHERE CO_INSCRICAO = 5283765  ORDER BY DT_LOG_ALTERACAO DESC;
select * from inscricao.tb_fies_controle_vaga_pre_inscricao where CO_INSCRICAO = 5283765
select * from inscricao.tb_fies_controle_vaga_perdida where CO_INSCRICAO = 5283765
-- CONSULTA PRÉ-INSCRIÇÃO
select i.co_inscricao, i.co_semestre, i.co_situacao_inscricao, 'Regular' as Tipo
 from FIES_PREINSCRICAO.TB_PRE_INSCRICAO i
 join FIES_PREINSCRICAO.TB_PRE_USUARIO u on u.CO_USUARIO = i.co_usuario
 join FIES_GLOBAL.TB_GLB_PESSOA_FISICA pf on pf.co_pessoa = u.co_pessoa
where pf.nu_cpf = '08441745994'
Union
select i.co_inscricao, i.co_semestre, i.co_situacao_inscricao, 'Remanescente' as Tipo
 from FIES_REMANESCENTE.TB_REM_INSCRICAO i 
 join FIES_PREINSCRICAO.TB_PRE_USUARIO u on u.CO_USUARIO = i.co_usuario
 join FIES_GLOBAL.TB_GLB_PESSOA_FISICA pf on pf.co_pessoa = u.co_pessoa
where pf.nu_cpf = '08441745994';
-- VERIFICA DADOS DA PRE INSCRICAO - RANKING DE CLASSIFICAÇÃO

--FUNÇAO PARA CONSULTAR SE EXISTE VAGA
select inscricao.fn_fies_consulta_vaga_pre_inscricao('05564452526', '20171');
NOTA:  CO_PRE_INSCRICAO: 2307112 CPF: 05564452526 NOME: MARIA EDUARDA BUTARELLI NASCIMENTO CURSO: 5000001 TURNO: 10071 SEMESTRE: 20171
NOTA:  SITUACAO SELECAO: Lista de espera VAGAS OCUPADAS: 9 VAGAS LIBERADAS: 10 LISTA ESPERA: 198
Ranking: 28, --->  CPF: 05564452526 | Nome: MARIA EDUARDA BUTARELLI NASCIMENTO | Ranking Enem: 1753 | Cod Inscrição: 2307112 | Tipo Concorrência: Enem | Situação da Inscrição: 2 - Lista de espera
 
select inscricao.fn_fies_consulta_vaga_pre_inscricao('05564452526', '20172');
NOTA:  CO_PRE_INSCRICAO: 3625492 CPF: 05564452526 NOME: MARIA EDUARDA BUTARELLI NASCIMENTO CURSO: 1184325 TURNO: 10071 SEMESTRE: 20172
NOTA:  SITUACAO SELECAO: Pré-selecionado VAGAS OCUPADAS: 27 VAGAS LIBERADAS: 27 LISTA ESPERA: 414
Ranking: 176, --->  CPF: 05564452526 | Nome: MARIA EDUARDA BUTARELLI NASCIMENTO | Ranking Enem:  | Cod Inscrição: 3625492 | Tipo Concorrência: Enem | Situação da Inscrição: 3 - Pré-selecionado
 
--
-- Função wellinton ranking - enem - indice
declare
 
v_cpf varchar(11):= '05564452526';
v_curso int := 5000001;
v_semestre int := 20171;
v_turno int := 10071;
v_tipo_concorrencia varchar(6) := 'Enem'; --'Indice'
--texto varchar(500);
linha int := 1;
r record;
 
begin
 
for r in
select (case when pf.nu_cpf = v_cpf then ' ---> ' else '' end) ||' CPF: '||pf.nu_cpf || ' | Nome: ' || pf.no_pessoa||
' | Ranking '||v_tipo_concorrencia||': '||(case when v_tipo_concorrencia = 'Indice' then NU_RANK_SEM_ENEM else NU_RANK_com_ENEM end)||
' | Cod Inscrição: '|| ins.CO_INSCRICAO ||
' | Tipo Concorrência: '||ins.ST_TIPO_CONCORRENCIA ||
' | Situação da Inscrição: ' || (case ins.CO_SITUACAO_INSCRICAO::int
  when 1 THEN '1 - Em preenchimento'
  when 2 then '2 - Lista de espera'
  when 3 then '3 - Pré-selecionado'
  when 4 then '4 - Vencido'
  when 5 then '5 - Contratado'
end) as texto
from fies_preinscricao.tb_pre_usuario us
inner join fies_global.tb_glb_pessoa_fisica pf on us.co_pessoa = pf.co_pessoa
inner join fies_preinscricao.tb_pre_inscricao ins on ins.co_usuario = us.co_usuario
inner join fies_preinscricao.tb_pre_termo_financiamento fin on ins.co_inscricao = fin.co_inscricao
where fin.CO_CURSO::int = v_curso
and fin.co_turno::int = v_turno
and ins.co_semestre::int = v_semestre
and ST_TIPO_CONCORRENCIA = v_tipo_concorrencia
--and pf.nu_cpf = v_cpf
order by NU_RANK_com_ENEM, NU_RANK_SEM_ENEM loop
 
RAISE info E'\nRanking: %,%', linha, r.texto;
linha := (linha+1);
end loop;
 
end;

	-- Arquivo recebido
				/**        CAIXA        **/
	SELECT * FROM integracao.tb_fies_importa_contrato_fies WHERE co_cpf = ''
	SELECT * FROM integracao.tb_fies_importa_aditamento WHERE co_cpf = '' AND nu_sem_aditamento::int||aa_aditamento = ''
	SELECT * FROM integracao.tb_fies_importa_ocorrencia_contrato_cef WHERE co_cpf = '' AND nu_semestre_referencia::int||nu_ano_referencia = ''
	SELECT * FROM integracao.tb_fies_importa_aditamento WHERE co_cpf = ''

            /**        BB        **/
SELECT * FROM integracao.tb_fies_importa_contrato_fies_bb WHERE nu_cpf = ''
SELECT * FROM integracao.tb_fies_importa_aditamento_bb WHERE nu_cpf = ''
SELECT * FROM integracao.tb_fies_importa_ocorrencia_contrato_bb WHERE co_cpf = '' AND nu_semestre_referencia::int||nu_ano_referencia = ''

--Enviados CEF
SELECT * FROM integracao.vw_fies_consulta_exportacao_aditamento_cef WHERE nu_cpf = ''


--Enviados BB
SELECT * FROM integracao.vw_fies_consulta_exportacao_aditamento_bb WHERE nu_cpf = ''


--Contrato CEF
SELECT * FROM integracao.vw_fies_contrato_recebido_cef WHERE nu_cpf = ''

--Contrato BB
SELECT * FROM integracao.vw_fies_consulta_exportacao_inscricao WHERE nu_cpf = ''

-- VERIFICA NOME DO ARQUIVO RECEBIDO
SELECT ia.co_arquivo_recebido, i.no_arquivo,* FROM integracao.tb_fies_importa_aditamento as ia left join integracao.tb_fies_arquivo_recebido as i on ia.co_arquivo_recebido = i.co_arquivo_recebido WHERE co_cpf = '89797710025'
  
-- TERMO DE FINANCIAMENTO
select co_inscricao, co_curso_associado,vl_semestre_sem_desconto,vl_semestre_com_desconto,nu_percentual_comprometimento,nu_percent_solicitado_financ,vl_financiado_semestre, vl_semestre_atual, vl_limite_global, vl_saldo_limite_global, qt_semestres_curso, 
qt_semestre_financiamento, qt_meses_financ_semestre_atual, qt_periodicidade, qt_semestre_concluido,
* 
from 	inscricao.tb_fies_termo_financiamento 
where 	co_inscricao =(	select co_inscricao 
				from 	inscricao.tb_fies_inscricao 
				where 	nu_cpf = '07960376980'
			)

-- CONSULTA DERRUBADA BANCO DE ADITAMENTO DE RENOVAÇÃO BB;
SELECT nu_sequencial, co_identificacao_registro, co_critica, ds_complemento_critica,
       co_arquivo_recebido, dt_inclusao_registro, co_chave_id_registro,
       nu_cpf
  FROM integracao.tb_fies_importa_critica_retorno
  where substr(nu_cpf, 4, 8)::int = 13478460 order by dt_inclusao_registro desc

-- CONSULTA CURSO, MANTENEDORA
SELECT * FROM vw_fies_curso WHERE co_curso = 98728;

--CONSULTA ADITAMENTO , CURSO - ASSOCIADO
SELECT C.co_curso_associado_aditamento,C.co_aditamento, A.co_inscricao, A.co_tipo_fianca, A.nu_semestre_referencia,A.co_semestre_aditamento,A.co_situacao_aditamento, A.co_finalidade_aditamento, A.st_bolsista_prouni,A.nu_percentual_prouni, C.co_curso,C.co_turno,C.co_mantenedora,C.co_ies,C.co_campus, A.vl_semestre_sem_desconto,
A.vl_semestre_com_desconto, A.vl_financiamento_exercicio, A.nu_percent_solicitado_financ, A.qt_semestre_concluido,A.qt_meses_financ_semestre_atual, A.qt_periodicidade FROM inscricao.tb_fies_curso_associado_aditamento 
AS C INNER JOIN inscricao.tb_fies_aditamento AS A ON  C.co_aditamento = A.co_aditamento  WHERE C.co_aditamento = 2266543; 

-- CONSULTA MANTENEDORA
select no_razao_social,nu_cnpj,* 
from	emec_cadastro.vw_cdst_fies_mantenedora 
where	co_mantenedora = ;

  --  Excluir aditamentos 
begin;
delete from inscricao.tb_fies_aditamento_motivo_variacao_reajuste where co_aditamento in (11029492,9804001,6500715);
delete from inscricao.tb_fies_comprovante where co_aditamento in (11029492,9804001,6500715);
delete from inscricao.tb_fies_curso_associado_aditamento where co_aditamento in (11029492,9804001,6500715);
delete from inscricao.tb_fies_aditamento where co_aditamento in (11029492,9804001,6500715);
commit;
 
  -- Excluir aditamento renovação, comprovantes, curso associado ao aditamento e troca de mantença
delete from inscricao.tb_fies_aditamento_troca_mantenca where co_aditamento = 12839460;
delete from inscricao.tb_fies_curso_associado_aditamento where co_aditamento = 12839460;
delete from inscricao.tb_fies_comprovante where co_aditamento = 12839460;
delete from inscricao.tb_fies_aditamento where co_aditamento = 12839460;

--  Excluir suspensoes
delete from inscricao.tb_fies_comprovante where co_suspensao = 521927;
delete from inscricao.tb_fies_suspensao where co_suspensao = 521927;
--  Excluir aditamentos 
delete from inscricao.tb_fies_aditamento_motivo_variacao_reajuste where co_aditamento = 10213853;
delete from inscricao.tb_fies_comprovante where co_aditamento = 10213853;
delete from inscricao.tb_fies_curso_associado_aditamento where co_aditamento = 10213853;
delete from inscricao.tb_fies_aditamento where co_aditamento = 10213853;

-- PRORROGAR OS PRAZOS E ALTERAR A SITUACAO DO ENCERRAMENTO 
UPDATE inscricao.tb_fies_encerramento set 
   dt_limite_comparecimento_banco = inscricao.fn_fies_soma_dias_uteis(now, 10),
   dt_limite_retorno_af = inscricao.fn_fies_soma_dias_uteis(now, 15),
   co_situacao_encerramento = 2
WHERE co_encerramento = 163270;
commit;  

/* SCRIPTS PARA TRAZER A SITUAÇÃO DE INSCRIÇÃO, ADITAMENTO, SUSPENSÃO, ENCERRAMENTO E DILATAÇÃO */

-- BUSCA SITUAÇÃO DA INSCRIÇÃO

SELECT co_situacao_inscricao, ds_situacao_inscricao, co_grupo_sit_inscricao, 
       ds_grupo
  FROM inscricao.tb_fies_situacao_inscricao;

-- BUSCA SITUAÇÃO DO ADITAMENTO

SELECT co_situacao_aditamento, ds_situacao_aditamento, ds_detalhes_situacao, 
       st_permite_editar, st_exibe_expirado
  FROM inscricao.tb_fies_situacao_aditamento;

-- BUSCA SITUAÇÃO DA SUSPENSÃO

SELECT co_situacao_suspensao, ds_situacao_suspensao, ds_detalhe_situacao, 
       st_bloqueia_calculo
  FROM inscricao.tb_fies_situacao_suspensao;  

-- BUSCA SITUAÇÃO DO ENCERRAMENTO

SELECT co_situacao_encerramento, ds_situacao_encerramento, ds_detalhe_situacao, 
       st_bloqueia_calculo
  FROM inscricao.tb_fies_situacao_encerramento;

-- BUSCA SITUAÇÃO DA DILATAÇÃO

SELECT co_situacao_dilatacao, ds_situacao_dilatacao, ds_detalhes_situacao, 
       st_permite_editar, st_exibe_expirado
  FROM inscricao.tb_fies_situacao_dilatacao;


-- PESQUISA SITUACAO ESTADO CIVIL
select a.co_inscricao,a.co_situacao_inscricao,a.co_estado_civil,e.ds_estado_civil,a.nu_cpf_conjuge,a.dt_log_alteracao
from auditoria.vw_lg_fies_inscricao as a left join inscricao.tb_fies_estado_civil as e 
on a.co_estado_civil = e.co_estado_civil where a.co_inscricao = 5540915 order by a.dt_log_alteracao desc;

-- REMOVE SOLICITAÇÃO DE CADASTRO DE INFORMAÇÕES NO HMG-SISFIES-ALUNO
update inscricao.tb_fies_usuario_inscricao set co_semestre_aditamento = (SELECT MAX(co_semestre_aditamento) FROM inscricao.tb_fies_semestre_aditamento),
st_usuario_ativo = 'S',
ds_senha = '7c4a8d09ca3762af61e59520943dc26494f8941b',
ds_email = 'sisfiesteste'||nu_cpf ||'@teste.fies.br'
where nu_cpf  in ('04346520162');

-- CONSULTA ALTERAÇÃO PELO ESTUDANTE
SELECT * FROM auditoria.lg_fies_usuario_inscricao WHERE nu_cpf = '03507859378' ORDER BY dt_log_alteracao desc;

--situação na preinscricao
select pf.no_pessoa,pf.nu_cpf,i.co_semestre,i.co_situacao_inscricao,si.ds_situacao_inscricao
from fies_global.tb_glb_pessoa_fisica pf
INNER JOIN fies_preinscricao.tb_pre_usuario u on u.co_pessoa = pf.co_pessoa
inner join fies_preinscricao.tb_pre_inscricao i on i.co_usuario = u.co_usuario
inner join fies_preinscricao.tb_pre_situacao_inscricao si on si.co_situacao_inscricao = i.co_situacao_inscricao
where pf.nu_cpf = '85958118579'


-- CONSULTA QUANTIDADE DE SEMESTRES FINANCIAMENTO/CONCLUIDOS


declare
v_arr_cpf varchar array[1] := '{"79556426191"}';
--v_arr_cpf varchar array[1] := '{"04932823606","77314808287","06639979926","07789221620","11721862609","38774684892","06479535952","12066220752","02814783092","02178670067","00068170173","08656136992","04057315667","00283552379","01435742052","70457468068","03550475195","56859511400","02033253112","04071839147","09716569670","14741352773","13898062783","02743913509","05876881490","05929948720","38409498820","66599695604","08565622460","36381643811","37629687800","07012686979","08741041658","07881016680","42923306899","22378130864","43105568840","13392421766","05299181531","12691117871","31137332867","34380232883","13918512770","41146745869","15866444755","66045835620","11027067603","34943916880","09744068647","04274816940","37252614824","02723469344","03113379962","01899997130","01779377347","00770333109","71417184353","12205526740","06406409906","31434659801","00234448008","06141799981","40890601844","03754544110","00626411076","01664164014","09835155658"}';
v_cpf varchar(11);
v_legado varchar(6) := '';
-----------------------------------------------
cursor_aditamento record;
cursor_inscricao record;
-----------------------------------------------
TOTAL_FINANCIADOS INT := 0;
TOTAL_SUSPENSOES INT := 0;
TOTAL_DILATACOES INT := 0;
TOTAL_ENCERRAMENTO INT := 0;
-----------------------------------------------
x_v_qt varchar;
count integer := 1;
--select qt_semestres_financiamento from inscricao.tb_fies_lib_estud_semestre_financ where nu_cpf in ('10969508719')
 
begin
 
                LOOP
                               v_cpf = to_char(v_arr_cpf[count]);
                              
                               select case when min(co_semestre_aditamento) < 32 then 'LEGADO'::VARCHAR(6) ELSE ''::VARCHAR(6) end into v_legado from inscricao.tb_fies_aditamento where nu_cpf = v_cpf; --32 = 12010
                              
                               select
                                               *
                               into
                                               cursor_inscricao
                               from
                                               inscricao.tb_fies_inscricao i
                                               left join inscricao.tb_fies_termo_financiamento tf using(co_inscricao)
                                               left join inscricao.tb_fies_curso_associado ca using(nu_cpf)
                                               inner join inscricao.tb_fies_banco_inscricao bco using (co_banco)
                                               inner join inscricao.tb_fies_usuario_inscricao ui using (nu_cpf)
                                               --left join inscricao.tb_fies_fiador_inscricao fi using(co_inscricao)
                               where i.nu_cpf = v_cpf;
                                               raise notice 'N°%',to_char(lpad(count,3,0));
                                               raise notice 'NOME: % CPF: % INSCRICAO: %',cursor_inscricao.no_usuario,v_cpf,cursor_inscricao.co_inscricao;
                                               raise notice '%', rpad(cursor_inscricao.co_banco,3,' ')||' - '||rpad(cursor_inscricao.no_banco,80,' ');
                                               raise notice '%',lpad(v_legado,84,' ');
                              
                                               raise notice '% | % | % | % | % | % | % | % | % | % | %',
                                                rpad('CO_ADIT',10,' '),
                                                rpad('SEM/ANO',9,' '),
                                                rpad('TP',3,' '),
                                                rpad('FINALIDADE_ADITAMENTO',22,' '),
                                                rpad('SITUAÇÃO',33,' '),
                                               rpad('QT_SEM_FINANC',13,' '),
                                               rpad('QT_SEM_CURSO',12,' '),
                                                rpad('QT_SEM_CONCLUIDO',16,' '),
                                               rpad('QT_SEM_FINANC_TF',16,' '), 
                                                rpad('QT_SEM_CURSO_TF',15,' '),
                                               rpad('QT_SEM_CONCLUIDO_TF',19,' ');
                                              
                                               for cursor_aditamento in
                                              
                                                                      select rpad(ui.no_usuario,30,' ') estudante,
                                                                                                     a.co_inscricao inscricao,
                                                                                                     lpad(a.co_aditamento,8,0) co_aditamento,
                                                                                                     a.nu_semestre_referencia nu_sem_referencia,
                                                                                                     lpad(a.qt_semestre_financiamento,13,' ') qt_sem_financiamento,
                                                                                                     lpad(coalesce(coalesce(a.qt_semestres_curso_destino,a.qt_periodicidade),0),12,' ') qt_sem_curso,
                                                                                                     lpad(a.qt_semestre_concluido,16,' ') qt_sem_concluido,
                                                                                                     case
                                                                                                                                    when a.co_finalidade_aditamento = 1 then 'CONTRATO             '
                                                                                                                                    WHEn a.co_finalidade_aditamento = 2 then 'RENOVAÇÃO            '
                                                                                                                                   WHEN a.co_finalidade_aditamento = 3 then 'TRANSFERÊNCIA        '
                                                                                                                                    WHEN a.co_finalidade_aditamento = 4 then 'DILATAÇÃO            '
                                                                                                                                    else 'outros               '
                                                                                                     end as finalidade_aditamento,
                                                                                                     a.co_situacao_aditamento co_situacao,
                                                                                                     rpad(sa.ds_situacao_aditamento,50,' ') situacao,
                                                                                                     a.co_semestre_aditamento co_sem_aditamento,
                                                                                                     a.dt_conclusao_aditamento dt_aditamento,
                                                                                                     a.dt_retorno_banco dt_conclusao,
                                                                                                     a.tp_aditamento::varchar(1) as tipo,
                                                                                                     coalesce(caa.qt_semestre_financiamento_destino,0) qt_semestre_financiamento_destino
                                                                      from      inscricao.tb_fies_aditamento a,
                                                                                                     inscricao.tb_fies_usuario_inscricao ui,
                                                                                                    inscricao.tb_fies_situacao_aditamento sa,
                                                                                                     inscricao.tb_fies_curso_associado_aditamento caa   ---
                                                                      where a.nu_cpf = v_cpf
                                                                                                     and a.nu_cpf = ui.nu_cpf
                                                                                                     and a.co_situacao_aditamento = sa.co_situacao_aditamento
                                                                                                     and a.co_curso_associado_aditamento = caa.co_curso_associado_aditamento
 
                                                                      union
 
                                                                      select rpad(ui.no_usuario,30,' ') estudante,
                                                                                                     i.co_inscricao inscricao,
                                                                                                     lpad(s.co_suspensao,8,0) co_aditamento,
                                                                                                     s.nu_semestre_referencia nu_sem_referencia,
                                                                                                     lpad(s.qt_semestre_financiamento,13,' ') qt_sem_financiamento,
                                                                                                     lpad(coalesce(s.qt_semestres_curso_destino,0),12,' ') qt_sem_curso,
                                                                                                     lpad(s.qt_semestre_concluido,16,' ') qt_sem_concluido,
                                                                                                     'SUSPENSÃO            ' AS finalidade_aditamento,
                                                                                                     s.co_situacao_suspensao co_situacao,
                                                                                                     rpad(ss.ds_situacao_suspensao,50,' ') situacao,
                                                                                                     s.co_semestre_aditamento co_sem_aditamento,
                                                                                                     s.dt_inclusao_suspensao dt_aditamento,
                                                                                                     s.dt_confirmacao_af dt_conclusao ,
                                                                                                     s.tp_suspensao::varchar(1) as tipo,
                                                                                                     0 as qt_semestre_financiamento_destino
                                                                      from      inscricao.tb_fies_suspensao s,
                                                                                                     inscricao.tb_fies_inscricao i,
                                                                                                     inscricao.tb_fies_usuario_inscricao ui,
                                                                                                     inscricao.tb_fies_situacao_suspensao ss
                                                                      where  s.co_inscricao = (select co_inscricao from inscricao.tb_fies_inscricao where nu_cpf = v_cpf)
                                                                                                     and i.nu_cpf = ui.nu_cpf
                                                                                                     and s.co_inscricao = i.co_inscricao
                                                                                                     and s.co_situacao_suspensao = ss.co_situacao_suspensao      
                                                                                                     
                                                                      union   
 
                                                                      select rpad(ui.no_usuario,30,' ') estudante,
                                                                                                     i.co_inscricao inscricao,
                                                                                                     lpad(d.co_dilatacao,8,0) co_aditamento,
                                                                                                     d.nu_semestre_inicio nu_sem_referencia,
                                                                                                     lpad(d.qt_semestre_financiamento,13,' ') qt_sem_financiamento,
                                                                                                     lpad(coalesce(d.qt_semestres_curso_destino,0),12,' ') qt_sem_curso,
                                                                                                     lpad(d.qt_semestre_concluido,16,' ') qt_sem_concluido,
                                                                                                     'DILATAÇÃO            ' AS finalidade_aditamento,
                                                                                                     d.co_situacao_dilatacao co_situacao,
                                                                                                     rpad(sd.ds_situacao_dilatacao,50,' ') situacao,
                                                                                                     d.co_semestre_aditamento co_sem_aditamento,
                                                                                                     d.dt_inclusao_dilatacao dt_aditamento,
                                                                                                     d.dt_conclusao_dilatacao dt_conclusao ,
                                                                                                     'I'::varchar(1) as tipo,
                                                                                                     0 as qt_semestre_financiamento_destino
                                                                      from      inscricao.tb_fies_dilatacao d,
                                                                                                     inscricao.tb_fies_inscricao i,
                                                                                                     inscricao.tb_fies_usuario_inscricao ui,
                                                                                                     inscricao.tb_fies_situacao_dilatacao sd
                                                                      where d.co_inscricao = (select co_inscricao from inscricao.tb_fies_inscricao where nu_cpf = v_cpf)
                                                                                                     and i.nu_cpf = ui.nu_cpf
                                                                                                     and d.co_inscricao = i.co_inscricao
                                                                                                     and d.co_situacao_dilatacao = sd.co_situacao_dilatacao
 
                                                                      union
 
                                                                      select rpad(ui.no_usuario,30,' ') estudante,
                                                                                                     i.co_inscricao inscricao,
                                                                                                     lpad(e.co_encerramento,8,0) co_aditamento,
                                                                                                     e.nu_semestre_referencia nu_sem_referencia,
                                                                                                     lpad('XX',13,' ') qt_sem_financiamento,
                                                                                                     lpad('XX',12,' ') qt_sem_curso,
                                                                                                     lpad('XX',16,' ') qt_sem_concluido,
                                                                                                     'ENCERRAMENTO         ' AS finalidade_aditamento,
                                                                                                     e.co_situacao_encerramento co_situacao,
                                                                                                     rpad(se.ds_situacao_encerramento,50,' ') situacao,
                                                                                                     e.co_semestre_aditamento co_sem_aditamento,
                                                                                                     e.dt_inclusao_encerramento dt_aditamento,
                                                                                                     e.dt_conclusao_encerramento dt_conclusao ,
                                                                                                     e.tp_encerramento::varchar(1) as tipo,
                                                                                                     0 as qt_semestre_financiamento_destino
                                                                      from      inscricao.tb_fies_encerramento e,
                                                                                                     inscricao.tb_fies_inscricao i,
                                                                                                     inscricao.tb_fies_usuario_inscricao ui,
                                                                                                     inscricao.tb_fies_situacao_encerramento se
                                                                      where e.co_inscricao = (select co_inscricao from inscricao.tb_fies_inscricao where nu_cpf = v_cpf)
                                                                                                     and i.nu_cpf = ui.nu_cpf
                                                                                                     and e.co_inscricao = i.co_inscricao
                                                                                                     and e.co_situacao_encerramento = se.co_situacao_encerramento
                                                                                                    
                                                                      order    by co_sem_aditamento,
                                                                                                     dt_aditamento,
                                                                                                     co_aditamento
 
                                               loop
 
                                               IF (TRIM(cursor_aditamento.finalidade_aditamento) = 'ENCERRAMENTO' and trim(cursor_aditamento.tipo) = 'I' AND TRIM(cursor_aditamento.situacao) = 'Contratado') THEN
                                                               TOTAL_ENCERRAMENTO = TOTAL_ENCERRAMENTO + 1;           
                                               END IF;
 
                                               IF (TRIM(cursor_aditamento.finalidade_aditamento) = 'DILATAÇÃO' AND TRIM(cursor_aditamento.situacao) = 'Contratado') THEN
                                                               TOTAL_DILATACOES = TOTAL_DILATACOES + 1;              
                                               END IF;
 
                                               IF (TRIM(cursor_aditamento.finalidade_aditamento) = 'SUSPENSÃO' and trim(cursor_aditamento.tipo) = 'I' AND TRIM(cursor_aditamento.situacao) = 'Contratado') THEN
                                                               TOTAL_SUSPENSOES = TOTAL_SUSPENSOES + 1;           
                                               END IF;
 
                                               IF (TRIM(cursor_aditamento.situacao) = 'Contratado' and TRIM(cursor_aditamento.finalidade_aditamento) in('SUSPENSÃO','CONTRATO','RENOVAÇÃO') and trim(cursor_aditamento.tipo) in ('S','N','I')) THEN
                                                               TOTAL_FINANCIADOS = TOTAL_FINANCIADOS + 1;      
                                               END IF;
                                              
                                               if(cursor_aditamento.qt_sem_concluido is null) then
                                                               x_v_qt = lpad(coalesce('0',0),16,' ');
                                               else
                                                               x_v_qt = cursor_aditamento.qt_sem_concluido;
                                               end if;
 
                              
                                                                      raise notice '% | % | % | % (%)| %-% | % | % | % | % | % | %',
                                                                      rpad(cursor_aditamento.co_aditamento,10,' '),
                                                                      rpad(cursor_aditamento.nu_sem_referencia,9,' '),
                                                                      rpad(cursor_aditamento.tipo,3,' '),
                                                                      lpad(cursor_aditamento.finalidade_aditamento,18,' '),
                                                                      lpad(cursor_aditamento.qt_semestre_financiamento_destino,2,'0'),
                                                                      lpad(cursor_aditamento.co_situacao,2,0),
                                                                      rpad(trim(cursor_aditamento.situacao),30,' '),
                                                                              lpad(cursor_aditamento.qt_sem_financiamento,13,' '),
                                                                      lpad(cursor_aditamento.qt_sem_curso,12,' '),
                                                                      lpad(x_v_qt,16,' '),
                                                                      rpad(cursor_inscricao.qt_semestre_financiamento,16,' '),
                                                                      rpad(cursor_inscricao.qt_semestres_curso,15,' '),
                                                                      rpad(cursor_inscricao.qt_semestre_concluido,19,' ');
                                                                                                                                                                                                                                
                                               end loop;           
 
                                               raise notice '';
                                               raise notice 'TOTAL FINANCIADOS........................................:%',lpad(TOTAL_FINANCIADOS,3,' ');
                                               raise notice '';
 
                               TOTAL_FINANCIADOS  = 0;
                               TOTAL_SUSPENSOES   = 0;
                               TOTAL_DILATACOES   = 0;
                               TOTAL_ENCERRAMENTO = 0;
                               count = count + 1;
                              
                               EXIT WHEN count > array_length(v_arr_cpf,1); 
                END LOOP;
   
 
end




-- CONSULTAS PROUNI

SELECT NU_PERCENT_SOLICITADO_FINANC, ST_BOLSISTA_PROUNI,* FROM INSCRICAO.TB_FIES_ADITAMENTO WHERE CO_INSCRICAO = 5335525 ORDER BY DT_INCLUSAO ASC;
SELECT NU_PERCENT_SOLICITADO_FINANC,* FROM AUDITORIA.VW_LG_FIES_TERMO_FINANCIAMENTO WHERE CO_INSCRICAO = 5335525 ORDER BY DT_LOG_ALTERACAO ASC;
SELECT ST_BOLSISTA_PROUNI,* FROM INSCRICAO.TB_FIES_INSCRICAO WHERE CO_INSCRICAO = 5335525
select co_mantenedora, co_ies, co_campus, co_curso, * from inscricao.vw_fies_bolsista_prouni_historico where nu_cpf = '13874170616' order by dt_cadastro asc ;
select * from inscricao.tb_fies_semestre_aditamento;
select * from inscricao.vw_fies_bolsista_ativo_prouni where nu_cpf = '13874170616'  ;

SELECT * FROM vw_fies_ies WHERE co_ies = 2233
SELECT * FROM vw_fies_curso WHERE co_curso = 103834
SELECT * FROM vw_fies_curso WHERE co_curso = 1304225

-- FASES DO CONTRATO
SELECT * FROM inscricao.tb_fies_fases_do_contrato WHERE NU_CPF = 23505299839;

-- REPROCESSA ADITAMENTO
select integracao.fn_fies_reprocessa_aditamento_cef(14222172,true); -- Flag TRUE para reprocessamento de aditamentos somente é utilizada para casos de fiança, quando se ignora o fiador. O uso da Flag 'TRUE' não garante a contratação do aditamento, e a informação de que foi solicitado a ignorar o tratamento de fiadores fica registrado no Log de execução, para os demais casos utilizar a flag FALSE.

