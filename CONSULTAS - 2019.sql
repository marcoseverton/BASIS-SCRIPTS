-- VERIFICAR LOG DO ADITAMENTO
SELECT ui.no_usuario, ad.nu_cpf, ad.co_aditamento, sa.ds_situacao_aditamento,ad.tp_aditamento, ad.tp_log, ad.dt_log_alteracao, ad.no_usuario_banco, * from
auditoria.vw_lg_fies_aditamento as ad
left join inscricao.tb_fies_usuario_inscricao as ui 
on ui.nu_cpf = ad.nu_cpf  
left join inscricao.tb_fies_situacao_aditamento as sa
on ad.co_situacao_aditamento = sa.co_situacao_aditamento
where ad.co_aditamento = 8770290 order by ad.dt_log_alteracao desc;




