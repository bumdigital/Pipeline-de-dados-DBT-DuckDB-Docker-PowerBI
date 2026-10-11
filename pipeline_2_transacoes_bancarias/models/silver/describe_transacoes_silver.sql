SELECT * 
FROM (
    DESCRIBE {{ ref('transacoes_silver') }}
)