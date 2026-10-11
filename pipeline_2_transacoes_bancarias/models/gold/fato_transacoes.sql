{{
    config(
        materialized='table'
    )
}}

SELECT 
    id_transacao, 
    data_hora_transacao, 
    tipo_transacao, 
    valor_transacao, 
	tarifa, 
    saldo_antes, 
    saldo_depois, 
    status_transacao, 
    motivo_recusa, 
	indicador_internacional, 
    indicador_fraude, 
    categoria_estabelecimento,
	score_risco

FROM {{ ref('transacoes_silver') }}

WHERE id_transacao IS NOT NULL
