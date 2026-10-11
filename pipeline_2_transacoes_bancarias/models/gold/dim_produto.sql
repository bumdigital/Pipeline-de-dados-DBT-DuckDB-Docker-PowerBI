{{
    config(
        materialized='table'
    )
}}

SELECT
    produto_bancario

FROM {{ ref('transacoes_silver') }}

WHERE produto_bancario IS NOT NULL
