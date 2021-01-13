
declare
v_arr_cpf varchar array[1] := '{"04337008586"}';
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
--select qt_semestres_financiamento from inscricao.tb_fies_lib_estud_semestre_financ where nu_cpf in ('04337008586')
 
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









