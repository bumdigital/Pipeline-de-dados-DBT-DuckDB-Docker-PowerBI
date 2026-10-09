{{
    config(
        materialized='table'
    )
}}

WITH bronze AS (

    SELECT *
    FROM {{ ref('transacoes_raw') }}

),

tratamento AS (

    SELECT 
        id_transacao,
        id_cliente,
        id_conta,
        data_hora_transacao,
        data_abertura_conta,

        nullif(trim(tipo_conta), '') AS tipo_conta,
        nullif(trim(segmento_cliente), '') AS segmento_cliente,
        upper(nullif(trim(uf_cliente), '')) AS uf_cliente,
        nullif(trim(faixa_etaria), '') AS faixa_etaria,
        nullif(trim(produto_bancario), '') AS produto_bancario,
        nullif(trim(tipo_transacao), '') AS tipo_transacao,
        nullif(trim(canal), '') AS canal,

        valor_transacao,
        tarifa,
        saldo_antes,
        saldo_depois,

        nullif(trim(status_transacao), '') AS status_transacao,
        nullif(trim(motivo_recusa), '') AS motivo_recusa,
        nullif(trim(categoria_estabelecimento), '') AS categoria_estabelecimento,
        
        CASE
            WHEN upper(trim(indicador_internacional)) IN ('S', 'SIM', 'Y', 'YES', '1')
                THEN 'SIM'
            WHEN upper(trim(indicador_internacional)) in ('N', 'NAO', 'NÃO', 'NO', '0')
                THEN 'NAO'
            ELSE NULL
        END AS indicador_internacional,

        CASE
            WHEN upper(trim(indicador_fraude)) IN ('S', 'SIM', 'Y', 'YES', '1')
                THEN 'SIM'

            WHEN upper(trim(indicador_fraude)) IN ('N', 'NAO', 'NÃO', 'NO', '0')
                THEN 'NAO'

            ELSE NULL
        END AS indicador_fraude,

        score_risco

    FROM bronze

),
deduplicacao AS (
    SELECT *
    FROM (
        SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY id_transacao
            ORDER BY data_hora_transacao DESC
        ) AS rn
        FROM tratamento
    )
    WHERE rn = 1
)

SELECT 
    * EXCLUDE (rn)
FROM deduplicacao
