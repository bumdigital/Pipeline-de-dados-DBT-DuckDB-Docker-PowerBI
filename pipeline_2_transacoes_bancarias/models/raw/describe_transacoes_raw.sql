-- sql/describe_transacoes_raw.sql

SELECT *
FROM (
    DESCRIBE {{ ref('transacoes_silver') }}
)