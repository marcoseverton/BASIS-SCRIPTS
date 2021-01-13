/*
FNDE - #23707 - LUCIANA BARBOSA DA SILVA - 780.981.734-53 - FIES - Sisfies Aluno
Ordem de trabalho # 78098173453 WO1305218
*/

/*
FNDE - INSCRIÇÃO-JOAO ANTONIO M F. ROMANIELLO CPF:106.205.376-12 - FIES - Sisfies Aluno
Ordem de trabalho # 10620537612 WO1285849
 JOÃO ANTONIO MARQUES FIGUEIREDO ROMANIELLO CPF: 10620537612

--VERIFICA SE A RENOVACAO TA ATUALIZADA NESTA TABELA 
select * from inscricao.tb_fies_ultima_renovacao  where nu_cpf = '78098173453'
select * from base_cef.tb_fies_inscricao_sifes where nu_cpf = '78098173453' 
select * from base_cef.tb_fies_inadimplente_creduc where nu_cpf = '78098173453' 
select * from auditoria.lg_fies_inadimplente_creduc WHERE nu_cpf = '78098173453'
select * from base_cef.festb010_candidato where co_cpf = '78098173453'
select * from base_cef.tb_fies_autorizacao_financiamento where nu_cpf = '78098173453'

select * from legado.tb_fies_importa_legado_aditivo where nu_cpf = '78098173453' order by dt_contratacao_aditivo
select * from  legado.tb_fies_importa_legado_contrato where nu_cpf = '78098173453' 

select * from fies_preinscricao.TB_PRE_RESTRICAO_ESTUDANTE where nu_cpf = '78098173453';

select * from inscricao.tb_fies_encerramento where co_encerramento = 353392;
================================================================================================================*/

declare
p_nu_cpf_atual  	  varchar(11):= '25558005572';
p_nu_semestre_inscricao   varchar(5):=  '';

v_rows_erro     integer:=0;
v_nu_registros  integer:=0;
                                          
begin
raise notice '----------------------------------------------------------------------------------------------------';
raise notice '--|ENCERRA E LIQUIDA O CONTRATO - SIMEC |--';
raise notice 'INICIO DA TRANSACAO - [%].', now();   
raise notice ' ';

---
begin           

	perform inscricao.sp_fies_inclusao_encerramento_liquidado(p_nu_cpf_atual, p_nu_semestre_inscricao);
	--update inscricao.tb_fies_encerramento	set tp_opcao_encerramento = 'L'	where co_encerramento = p_co_encerramento;
	
   --    
    commit;                      
    exception when others then
    begin    
        v_rows_erro := v_rows_erro+1;              
        rollback;   
        RAISE NOTICE '% %', SQLERRM, SQLSTATE;
    end;    
    
end;    
--- 
raise notice '..Total de Linhas Erro: %', v_rows_erro;   
IF v_rows_erro = 0 THEN
raise notice '..TRANSACAO SEM ERRO';   
END IF;
raise notice ' ';
raise notice 'TERMINO DA TRANSACAO - [%].', now();
raise notice '----------------------------------------------------------------------------------------------------';
end;
-------------------------------------------------------------------------------
/*================================================================================================================*/
