{{
    config(
        materialized='table'
    )
}}

SELECT
    DISTINCT canal

FROM {{ ref('transacoes_silver') }}

WHERE canal IS NOT NULL
