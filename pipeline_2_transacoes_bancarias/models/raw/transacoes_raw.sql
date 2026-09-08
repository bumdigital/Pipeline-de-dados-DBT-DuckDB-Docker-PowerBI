{{
    config(
        materialized='table'
    )
}}

select * from read_csv('/app/data/base_transacoes_bancarias_pipeline2.csv')
