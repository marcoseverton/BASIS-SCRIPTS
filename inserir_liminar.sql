/*
FNDE - #6203 - ESTUDANTE: JOAO PEDRO CARDOSO DI MARZIO - CPF:100.2 - FIES - Sisfies Aluno
Ordem de trabalho # WO1313844
================================================================================================================*/
declare
--
p_nu_cpf              varchar2(11) = '10022364609';
v_CO_INSCRICAO        integer = 1933761;
V_CO_LIMINAR          integer = 21;

--INFORMAÇAO DE ADITAMENTO
V_CO_ADITAMENTO       integer = 12661086;

--
v_rows_sifes         integer:=0; 
v_rows_encerramento  integer:=0;
v_rows_aux           integer:=0;
v_total              integer:=0;
v_total_sucesso      integer:=0;
v_total_erro         integer:=0;
                                         
begin
raise notice '-----------------------------------------------------------------------------------------';
raise notice '--|(REMOVE COMPROVANTE/PRORROGA/REENVIA ao AGENTE FINANCEIRO). |--';
raise notice 'INICIO DA TRANSACAO - [%].', now();   
raise notice '';
raise notice '';


    v_total              := v_total +1;


CASE V_CO_LIMINAR 
      --INSERINDO LIMINAR DE IDONEIDADE DO ESTUDANTE
      WHEN 1 THEN 
      
     delete inscricao.tb_fies_aditamento_liminar where co_aditamento = V_CO_ADITAMENTO and co_liminar = 1;

	insert into inscricao.tb_fies_aditamento_liminar (
		    co_aditamento, co_liminar, st_utilizou_liminar, st_liberar_renda_fiador, 
		    st_liberar_exigencia_fiador, st_liberar_idoneidade_aluno, st_liberar_idoneidade_fiador )
	VALUES (V_CO_ADITAMENTO,V_CO_LIMINAR,'S',NULL,NULL,'S',NULL);
	raise notice 'LIMINAR DE IDONEIDADE INSERIDA';
	
      --INSERINDO LIMINAR 20 DE TROCA DE FIANÇA DO ESTUDANTE
       WHEN 20 THEN 

     UPDATE inscricao.tb_fies_aditamento set st_troca_fianca = 'S', st_direito_troca_fianca = 'S' where co_aditamento = v_co_aditamento;
	raise notice 'LIMINAR 20 (TROCA DE FIANCA) INSERIDA';

      --INSERINDO LIMINAR 21 DE TROCA DE FIANÇA DO ESTUDANTE
       WHEN 21 THEN 
        
        UPDATE inscricao.tb_fies_aditamento set st_troca_fianca = 'S' where co_aditamento = v_co_aditamento;  

      
        IF ((SELECT COUNT(*) FROM aux.tb_fies_ajusta_liminar_21 WHERE nu_cpf = p_nu_cpf) = 0) THEN 
        insert into aux.tb_fies_ajusta_liminar_21(nu_cpf) values (p_nu_cpf);
	    raise notice 'LIMINAR 21 (TROCA DE FIANCA) INSERIDA';
	    ELSE 
	    raise notice 'JÁ EXISTE LIMINAR 21 CADASTRADA NESTE CPF!!!';
	    END IF;

       --INSERINDO LIMINAR DE DISPENSA DE FIADOR
       WHEN 43 THEN 
	insert into inscricao.tb_fies_aditamento_liminar (
		    co_aditamento, co_liminar, st_utilizou_liminar, st_liberar_renda_fiador, 
		    st_liberar_exigencia_fiador, st_liberar_idoneidade_aluno, st_liberar_idoneidade_fiador )
	VALUES (V_CO_ADITAMENTO,V_CO_LIMINAR,'S','N','S',NULL,NULL);

        delete inscricao.tb_fies_fiador_aditamento where co_aditamento = v_co_aditamento;   
	raise notice 'LIMINAR 43 (LIMINAR DE DISPENSA DE FIADOR) INSERIDA';
	
    ELSE
        raise notice 'NENHUMA LIMINAR INSERIDA';
END CASE;    

	--REMOVE O COMPROVANTE	
		delete 
			inscricao.tb_fies_comprovante 
		where 
			co_inscricao = v_CO_INSCRICAO 
			and co_aditamento = V_CO_ADITAMENTO;  



	--COMPARECIMENTO AO AGENTE FINANCEIRO

	   UPDATE inscricao.tb_fies_aditamento
	   SET    co_situacao_aditamento = 34,		  	 
		  dt_inicio_comparecimento_banco = (select inscricao.fn_fies_soma_dias_uteis(now()::date,3)),
		  dt_limite_comparecimento_banco = (select inscricao.fn_fies_soma_data(inscricao.fn_fies_soma_dias_uteis(now()::date,3)::date, 10)),
		  dt_limite_retorno_agente_financ = (select inscricao.fn_fies_soma_data(inscricao.fn_fies_soma_data(inscricao.fn_fies_soma_dias_uteis(now()::date,3)::date, 10)::date, 5))
	   WHERE  co_inscricao = v_CO_INSCRICAO        
	   and    co_aditamento = V_CO_ADITAMENTO;

    commit;  
    v_total_sucesso:=v_total_sucesso+1;
    raise notice '..CPF[%] - processado com sucesso.', p_nu_cpf ;   
    exception when others then
        v_total_erro:=v_total_erro+1;
        rollback; 
        raise notice '..CPF[%] - falha no procedimento.', p_nu_cpf ;                                  
        raise exception '% %', sqlerrm, sqlstate;
    
raise notice '';
raise notice '';
raise notice 'Total de registros lido: %', v_total;  
raise notice 'Total de registros com erro: %', v_total_erro;  
raise notice 'TERMINO DA TRANSACAO - [%].', now();
raise notice '-----------------------------------------------------------------------------------------';
end;
-------------------------------------------------------------------------------
/*================================================================================================================*/