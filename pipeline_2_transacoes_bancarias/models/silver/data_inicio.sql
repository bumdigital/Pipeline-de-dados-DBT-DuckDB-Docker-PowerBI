SELECT
    MIN(data_hora_transacao),
    MIN(data_abertura_conta)
FROM {{ ref('transacoes_silver') }}
