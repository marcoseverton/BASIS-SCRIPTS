-- INSERIR SEMESTRE A MAIOR
insert into inscricao.tb_fies_lib_estud_semestre_financ
 (nu_cpf, qt_semestres_financiamento, dt_ultima_alteracao)
values ('97444456020', 17, now);

-- CONSULTAS FINANCIAMENTO DO (A) ESTUDANTE
declare
v_arr_cpf varchar array[1] := '{"06796503422","05731347905"}';

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
   
 
end;



/*Demanda Judicial #2823 | DEBORA ELMIRA PINHEIRO GOMES, CPF: 027.859.632-02*/


select nu_semestre_referencia,* from auditoria.vw_lg_fies_inscricao where nu_cpf = '02785963202' order by dt_log_alteracao desc;

select * from auditoria.vw_lg_fies_curso_associado where nu_cpf = '02785963202' order by dt_log_alteracao desc;




begin
raise notice 'INICIO DA TRANSACAO.';

-- EXCLUIR COMPROVANTES
delete inscricao.tb_fies_comprovante where co_inscricao = 4439295; 

-- ALTERAR O SEMESTRE DE REFERENCIA DA INSCRIÇAO E PRORROGAR OS PRAZOS
update inscricao.tb_fies_inscricao set nu_semestre_referencia = '12015' where co_inscricao = 4439295;

update inscricao.tb_fies_termo_financiamento set 
dt_conclusao_inscricao = '2015-10-30' 
where co_inscricao = 4439295;


commit;
raise notice 'TRANSAÇÃO COMPLETA!!!!!!!!!!';
--TRATAMENTO DE ERRO
exception when others then
        rollback;
        raise notice 'ROLLBACK aplicado!!!!!!!!!!';
        raise exception '% %', SQLERRM, SQLSTATE;
end;

-- VERIFICAR DADOS DO CURSO DO ESTUDANTE

SELECT 
    no_usuario, ca.nu_cpf,
    vw.co_curso as vw_curso, ca.co_curso as ca_curso,s.co_curso as s_curso,d.co_curso as d_curso,
    vw.co_mantenedora as vw_mantenedora, ca.co_mantenedora as ca_mantenedora,
    s.co_mantenedora as s_mantenedora, a.co_mantenedora as a_mantenedora, 
    cad.co_mantenedora as cad_mantenedora, tf.co_mantenedora as tf_mantenedora, d.co_mantenedora as d_mantenedora,
    a.nu_semestre_referencia, a.co_aditamento,
    vw.co_ies as vw_ies, ca.co_ies as ca_ies, cad.co_ies as cad_ies, s.co_ies as s_ies, d.co_ies as d_ies, 
    vw.co_campus as vw_campus, ca.co_campus as ca_campus, cad.co_campus as cad_campus, s.co_campus as s_campus, d.co_campus as d_campus,
    vw.co_turno as vw_turno, ca.co_turno as ca_turno, cad.co_turno as cad_turno, s.co_turno as s_turno, d.co_turno as d_turno,
    vw.st_vinculo_ativo_emec, vw.dt_perda_vinculo_emec, ds_condicao_funcionamento,

    case 
        when vw.co_turno IS NOT NULL AND vw.co_ies IS NOT NULL AND vw.co_campus IS NOT NULL AND vw.co_mantenedora IS NOT NULL
        then 'N'::char        
        when vw.co_turno ISNULL AND vw.co_ies ISNULL AND vw.co_campus ISNULL AND vw.co_mantenedora ISNULL 
        then 'S'::char 
    END dados_divergentes_emec,

* FROM inscricao.tb_fies_curso_associado ca left join 
    vw_fies_curso vw on 
    vw.co_curso = ca.co_curso and
    vw.co_mantenedora = ca.co_mantenedora and 
    vw.co_ies = ca.co_ies and 
    vw.co_campus = ca.co_campus and
    vw.co_turno = ca.co_turno
left join inscricao.tb_fies_aditamento a 
    on ca.nu_cpf = a.nu_cpf 
    and a.co_aditamento = (
        select co_aditamento from inscricao.tb_fies_aditamento
        where nu_cpf = ca.nu_cpf and co_situacao_aditamento <> 39 
        and co_situacao_aditamento <> 47 order by co_semestre_aditamento desc limit 1
    )
left join inscricao.tb_fies_curso_associado_aditamento cad 
    on cad.co_aditamento = a.co_aditamento
left join inscricao.tb_fies_termo_financiamento tf 
    on a.co_inscricao = tf.co_inscricao
left join inscricao.tb_fies_suspensao s 
    on a.co_inscricao = s.co_inscricao and 
    co_suspensao = (
        select co_suspensao from inscricao.tb_fies_suspensao 
        where co_inscricao = a.co_inscricao order by co_semestre_aditamento desc limit 1
    )
left join inscricao.tb_fies_dilatacao d 
    on d.co_inscricao = d.co_inscricao and 
    co_dilatacao = (
        select co_dilatacao from inscricao.tb_fies_dilatacao 
        where co_inscricao = a.co_inscricao order by co_semestre_aditamento desc limit 1
    )
left join inscricao.tb_fies_usuario_inscricao u 
    on u.nu_cpf = ca.nu_cpf
where ca.nu_cpf in ('12619821690','13031637640')


 

--Verificar porque não houve repasse para um determinado estudante--

 

--1) Verificar se o aditamento consta no módulo financeiro

SELECT nu_semestre_aditamento||'/'||nu_ano_aditamento as "Semestre_ano",

       b.nu_cpf, c.no_usuario,

       co_tipo_preliminar,

       vl_aditamento,

       a.dt_inclusao::date as dt_inclusao

  from financeiro.tb_fies_aditamento_contrato a

    INNER JOIN financeiro.tb_fies_contrato b ON a.co_contrato_fies = b.co_contrato_fies

    INNER JOIN inscricao.tb_fies_usuario_inscricao c ON c.nu_cpf = b.nu_cpf

where

 b.nu_cpf IN ('41615451854', '34713968889')

ORDER BY nu_ano_aditamento, nu_semestre_aditamento

--Se o semestre desejado não vier no select, indica que não houve integração com o módulo financeiro. Acionar um dos ADs para incluir o semestre no financeiro.

 

--Executar o script abaixo para confirmar se o semestre foi contratado no acadêmico

SELECT a.nu_cpf, no_usuario, nu_semestre_referencia, a.co_situacao_aditamento, ds_situacao_aditamento

  FROM inscricao.tb_fies_aditamento a

    INNER JOIN inscricao.tb_fies_situacao_aditamento b USING (co_situacao_aditamento)

    INNER JOIN inscricao.tb_fies_usuario_inscricao c ON c.nu_cpf = a.nu_cpf

WHERE a.nu_cpf = '41615451854'

AND co_finalidade_aditamento = 2

ORDER BY co_aditamento

 

 

--2) - Verificar se está no acordão

SELECT nu_semestre_aditamento,

       nu_ano_aditamento,

       b.nu_cpf,

       vl_aditamento,

       a.dt_inclusao::date as dt_inclusao,

       tp_grupo_repasse

  from financeiro.tb_fies_aditamento_contrato a

    INNER JOIN financeiro.tb_fies_contrato b ON a.co_contrato_fies = b.co_contrato_fies

    INNER JOIN tb_fies_adesao c ON a.co_mantenedora = c.co_mantenedora

where

 a.dt_inclusao BETWEEN '2015-08-01' AND '2015-12-31'

AND c.tp_grupo_repasse = 2

AND b.nu_cpf IN

('41615451854',

'34713968889')

 

--3) Verificar se é preliminar no semestre 1/2015

SELECT nu_semestre_aditamento,

       nu_ano_aditamento,

       b.nu_cpf,

       co_tipo_preliminar,

       vl_aditamento,

       a.dt_inclusao::date as dt_inclusao

  from financeiro.tb_fies_aditamento_contrato a

    INNER JOIN financeiro.tb_fies_contrato b ON a.co_contrato_fies = b.co_contrato_fies

where

 a.vl_aditamento_original > 0

 AND b.nu_cpf IN

('41615451854',

'34713968889')

--Se o select trouxer ao menos 1 registro, indica que é preliminar.

--Se vier registro e o campo co_tipo_preliminar vier vazio, indica que o FNDE ainda não liberou esse aditamento para repasse.

--Se vier registro e o campo co_tipo_preliminar vier com 1, 2, 3, 4 ou 6, indica que o aditamento está liberado para repasse e deveria ter sido feito.

 

--4) Verificar se o aditamento está bloqueado

--Caso não encontre nenhum impedimento nos selects acima

 

--Saber se estão bloqueados para repasse

SELECT

 a.co_inscricao,

nu_semestre_referencia as "Semestre_ano",

 a.nu_cpf, c.no_usuario, a.co_inscricao, 'Bloqueado para repasse' as "Situação",

FORMAT_NUMBER(vl_contrato) as vl_semestre,

dt_inclusao::date

 FROM financeiro.tb_fies_contrato a

   INNER JOIN financeiro.tb_fies_bloqueio_calculo b ON a.co_inscricao = b.co_inscricao

   INNER JOIN inscricao.tb_fies_usuario_inscricao c ON a.nu_cpf = c.nu_cpf

WHERE

 st_bloqueia = 'S'

AND a.nu_cpf IN

('41615451854',

'34713968889')

GROUP BY a.nu_cpf, "Semestre_ano", no_usuario, a.co_inscricao, "Situação", vl_semestre, dt_inclusao

ORDER BY nu_cpf

--Se o select apresentar ao menos 1 registro, indica que o estudante está bloqueado para repasse

--Para maiores informações: SELECT * FROM financeiro.tb_fies_bloqueio_calculo WHERE nu_cpf = 99999999999 OR co_inscricao = 999999


 