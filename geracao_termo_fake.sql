select distinct nu_cnpj_mantenedora 
from legado.tb_fies_importa_legado_contrato
where
 nu_cnpj_mantenedora in (
select nu_cnpj from tb_fies_adesao
 )
 and nu_cpf = '54681111104'




select nu_cnpj_mantenedora,*
from legado.tb_fies_importa_legado_contrato
where
 nu_cnpj_mantenedora in (
select nu_cnpj from tb_fies_adesao
 )
 and nu_cpf = '57701873104'


select *
from legado.tb_fies_importa_legado_aditivo
where
nu_cpf = '57701873104'


 

select * from tb_fies_adesao

select * from tb_fies_termo_adesao

select * from aux.geracao_fake_termo where co_mantenedora in ()

drop taBLE aux.geracao_fake_termo
select min(nu_ano_exercicio) nu_ano_exercicio, max(co_termo_adesao)co_termo_adesao , co_mantenedora
--into aux.geracao_fake_termo
 from tb_fies_termo_adesao 
where
co_mantenedora not in (
        select co_mantenedora 
        from  tb_fies_termo_adesao 
        where nu_ano_exercicio = 1999
)
group by 3


select nu_ano_exercicio,* from tb_fies_termo_adesao
where
co_mantenedora = 647



INSERT INTO tb_fies_termo_adesao(
            co_termo_adesao, co_adesao, st_termo_aditivo, ds_razao_social, 
            co_natureza_juridica, nu_cnpj, co_mantenedora, co_cidade, co_uf, 
            ds_tipo_logradouro, ds_logradouro, ds_logradouro_comp, ds_bairro, 
            ds_numero, nu_cep, vl_adesao_requerido, co_ticket_assinatura, 
            dt_inicio_termo, dt_termino_termo, co_usuario_ultima_operacao, 
            sg_mantenedora, co_cnae_principal, nu_numeracao, vl_liquidez_corrente, 
            vl_liquidez_geral, vl_solvencia_geral, nu_ano_exercicio, vl_renovacao_adesao_requerido, 
            st_termo_renovacao, nu_ano_referencia_balanco, vl_mensal_imposto, 
            vl_ativo_total, vl_patrimonio_liquido, vl_ativo_permanente, vl_ativo_circulante, 
            vl_realizavel_longo_prazo, vl_passivo_circulante, vl_exigivel_longo_prazo, 
            vl_mensal_contribuicao_previdenciaria, st_termo_balanco, st_termo_prorrogacao)


select * from aux.gerados join co_tick


select max(co_termo_adesao), co_adesao, st_termo_aditivo, ds_razao_social, 
            co_natureza_juridica, nu_cnpj, co_mantenedora, co_cidade, co_uf, 
            ds_tipo_logradouro, ds_logradouro, ds_logradouro_comp, ds_bairro, 
            ds_numero, nu_cep, null, co_ticket_assinatura, 
            dt_inicio_termo, dt_termino_termo, co_usuario_ultima_operacao, 
            sg_mantenedora, co_cnae_principal, nu_numeracao, vl_liquidez_corrente, 
            vl_liquidez_geral, vl_solvencia_geral, min(nu_ano_exercicio), vl_renovacao_adesao_requerido, 
            st_termo_renovacao, nu_ano_referencia_balanco, vl_mensal_imposto, 
            vl_ativo_total, vl_patrimonio_liquido, vl_ativo_permanente, vl_ativo_circulante, 
            vl_realizavel_longo_prazo, vl_passivo_circulante, vl_exigivel_longo_prazo, 
            vl_mensal_contribuicao_previdenciaria, st_termo_balanco, st_termo_prorrogacao from  tb_fies_termo_adesao 
group by   co_adesao, st_termo_aditivo, ds_razao_social, 
co_natureza_juridica, nu_cnpj, co_mantenedora, co_cidade, co_uf, 
            ds_tipo_logradouro, ds_logradouro, ds_logradouro_comp, ds_bairro, 
            ds_numero, nu_cep, vl_adesao_requerido,          dt_inicio_termo, dt_termino_termo, co_usuario_ultima_operacao, 
            sg_mantenedora, co_cnae_principal, nu_numeracao, vl_liquidez_corrente, 
            vl_liquidez_geral, vl_solvencia_geral, vl_renovacao_adesao_requerido, 
            st_termo_renovacao, nu_ano_referencia_balanco, vl_mensal_imposto, 
            vl_ativo_total, vl_patrimonio_liquido, vl_ativo_permanente, vl_ativo_circulante, 
            vl_realizavel_longo_prazo, vl_passivo_circulante, vl_exigivel_longo_prazo, 
            vl_mensal_contribuicao_previdenciaria, st_termo_balanco, st_termo_prorrogacao  

      DROP TABLE aux.gerados   
select distinct exe.* , t.co_termo_adesao, t.co_mantenedora
into aux.gerados
from tb_fies_ano_exercicio exe,
--left join 
aux.geracao_fake_termo t --using(nu_ano_exercicio)

where 
exe.nu_ano_exercicio < t.nu_ano_exercicio
order by t.co_mantenedora, exe.nu_ano_exercicio



-- apos popular a tabela aux.gerados
begin;

INSERT INTO tb_fies_termo_adesao(
             co_adesao, st_termo_aditivo, ds_razao_social, 
            co_natureza_juridica, nu_cnpj, co_mantenedora, co_cidade, co_uf, 
            ds_tipo_logradouro, ds_logradouro, ds_logradouro_comp, ds_bairro, 
            ds_numero, nu_cep, vl_adesao_requerido, co_ticket_assinatura, 
            dt_inicio_termo, dt_termino_termo, co_usuario_ultima_operacao, 
            sg_mantenedora, co_cnae_principal, nu_numeracao, vl_liquidez_corrente, 
            vl_liquidez_geral, vl_solvencia_geral, nu_ano_exercicio, vl_renovacao_adesao_requerido, 
            st_termo_renovacao, nu_ano_referencia_balanco, vl_mensal_imposto, 
            vl_ativo_total, vl_patrimonio_liquido, vl_ativo_permanente, vl_ativo_circulante, 
            vl_realizavel_longo_prazo, vl_passivo_circulante, vl_exigivel_longo_prazo, 
            vl_mensal_contribuicao_previdenciaria, st_termo_balanco, st_termo_prorrogacao)
            
select 
co_adesao, st_termo_aditivo, ds_razao_social, 
       co_natureza_juridica, nu_cnpj, ta.co_mantenedora, co_cidade, co_uf, 
       ds_tipo_logradouro, ds_logradouro, ds_logradouro_comp, ds_bairro, 
       ds_numero, nu_cep, null::numeric, 'TERMO LEGADO', 
       (g.nu_ano_exercicio||'-01-01')::date , (g.nu_ano_exercicio||'-12-31')::date , co_usuario_ultima_operacao, 
       sg_mantenedora, co_cnae_principal, 0, null::numeric, 
       null::numeric, null::numeric, g.nu_ano_exercicio, null::numeric, 
       'f'::boolean , null::smallint, null::numeric, 
       null::numeric, null::numeric, null::numeric, null::numeric, 
       null::numeric, null::numeric, null::numeric, 
       null::numeric, 'N', 'N'

from aux.gerados g join  tb_fies_termo_adesao ta using(co_termo_adesao, co_mantenedora)
where
co_adesao <> 122
order by co_mantenedora, nu_ano_exercicio





select * from tb_fies_termo_adesao join (
select  distinct co_adesao, 0 nu_numeracao, (g.nu_ano_exercicio||'-01-01')::date::timestamp dt_inicio_termo
from aux.gerados g join  tb_fies_termo_adesao ta using(co_termo_adesao, co_mantenedora)
order by co_mantenedora, g.nu_ano_exercicio
) a using(co_adesao, nu_numeracao, dt_inicio_termo)

select * from aux.gerados

(co_adesao, nu_numeracao, dt_inicio_termo);



select co_adesao, nu_numeracao, dt_inicio_termo, nu_ano_exercicio,* from tb_fies_termo_adesao
where
co_mantenedora = 647


------------------------------------geração termo fake listagem de 25 mantenedoras--------------------------------------

-- popular a tabela aux.gerados com as 25 mantenedoras.
begin;

INSERT INTO aux.gerados(
            nu_ano_exercicio, dt_inicio_periodo_adesao, dt_termino_periodo_adesao, 
            co_termo_adesao, co_mantenedora)
            
select nu_ano_exercicio,
   to_char(dt_inicio_termo, 'yyyy-mm-dd') dt_inicio_termo
  ,to_char(dt_termino_termo, 'yyyy-mm-dd') dt_termino_termo
  ,co_termo_adesao
  ,co_mantenedora,* 
from tb_fies_termo_adesao ta
where to_char(dt_termino_termo, 'yyyy-mm-dd') = '2013-12-31' 
and nu_ano_exercicio = '2012'
and not exists (select 1 from tb_fies_termo_adesao sub where nu_ano_exercicio = '2013' and sub.nu_cnpj = ta.nu_cnpj)
and exists (select 1 from tb_fies_termo_adesao sub where nu_ano_exercicio = '2014' and sub.nu_cnpj = ta.nu_cnpj)

rollback;
commit;
