{{
    config(
        materialized='table'
    )
}}

SELECT
    id_conta, 
    tipo_conta, 
    data_abertura_conta

FROM {{ ref('transacoes_silver') }}

WHERE id_conta IS NOT NULL
