begin
raise notice 'INICIO DA TRANSACAO.';
declare 

count integer := 1;

x RECORD;

begin

    for x IN 
         
        SELECT a.co_inscricao as inscricao,
            no_usuario, ca.nu_cpf, ds_condicao_funcionamento, dt_perda_vinculo_emec, st_vinculo_ativo_emec,
            vw.co_curso as vw_curso, ca.co_curso as ca_curso,s.co_curso as s_curso,d.co_curso as d_curso,
            vw.co_mantenedora as vw_mantenedora, ca.co_mantenedora as ca_mantenedora,
            s.co_mantenedora as s_mantenedora, a.co_mantenedora as a_mantenedora, 
            cad.co_mantenedora as cad_mantenedora, tf.co_mantenedora as tf_mantenedora, d.co_mantenedora as d_mantenedora,
            a.nu_semestre_referencia, a.co_aditamento, a.co_semestre_aditamento as a_co_semestre_aditamento, s.co_semestre_aditamento as s_co_semestre_aditamento,
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
        -- vw.co_mantenedora = ca.co_mantenedora and 
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
        where ca.nu_cpf in ('12619821690', '13031637640')
    loop
        update inscricao.tb_fies_curso_associado set co_mantenedora = x.vw_mantenedora where nu_cpf = x.nu_cpf;
        update inscricao.tb_fies_curso_associado_aditamento set co_mantenedora = x.vw_mantenedora where co_aditamento = x.co_aditamento;
        update inscricao.tb_fies_aditamento set co_mantenedora = x.vw_mantenedora where co_aditamento  = x.co_aditamento;
        update inscricao.tb_fies_termo_financiamento set co_mantenedora = x.vw_mantenedora where co_inscricao = x.inscricao;

        if (x.co_suspensao IS NOT NULL) then
            if (x.s_co_semestre_aditamento < x.a_co_semestre_aditamento) then
             update inscricao.tb_fies_suspensao set co_mantenedora = x.vw_mantenedora where co_inscricao = x.inscricao;
            end if;
        end if;
        
        if (x.co_dilatacao IS NOT NULL) then
            update inscricao.tb_fies_suspensao set co_mantenedora = x.vw_mantenedora where co_inscricao = x.inscricao;
        end if;

        count = count + 1;
end loop;

end;

commit;
raise notice 'TRANSAÇÃO COMPLETA!!!!!!!!!!';
--TRATAMENTO DE ERRO
exception when others then
        rollback;
        raise notice 'ROLLBACK aplicado!!!!!!!!!!';
        raise exception '% %', SQLERRM, SQLSTATE;
end;

