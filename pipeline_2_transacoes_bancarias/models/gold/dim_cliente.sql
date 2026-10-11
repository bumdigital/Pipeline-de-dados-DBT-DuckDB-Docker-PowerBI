{{
    config(
        materialized='table'
    )
}}

SELECT
    id_cliente, 
    segmento_cliente, 
    uf_cliente, 
    faixa_etaria

FROM {{ ref('transacoes_silver') }}

WHERE id_cliente IS NOT NULL
