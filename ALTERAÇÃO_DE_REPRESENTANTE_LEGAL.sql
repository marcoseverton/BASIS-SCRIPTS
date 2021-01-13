/* 

select dt_termino_representacao, * from public.tb_fies_representante where nu_cpf = '01290851115' 

select dt_termino_representacao, * from public.tb_fies_representante where nu_cpf = '00843640332' 

*/
begin
raise notice 'INICIO DA TRANSACAO.';

PERFORM consulta.fn_fies_troca_representante_legal
('01290851115'::character varying(11),-- cpf atual
 '00843640332'::character varying(11),-- cpf novo 
 'FRANCISCO JOSIVAN FERRO FERREIRA'::character varying(60), -- nome novo
  null::integer --adesao
  );

commit;
raise notice 'TRANSAÇÃO COMPLETA!!!!!!!!!!';
--TRATAMENTO DE ERRO
exception when others then
        rollback;
        raise notice 'ROLLBACK aplicado!!!!!!!!!!';
        raise exception '% %', SQLERRM, SQLSTATE;
end;
