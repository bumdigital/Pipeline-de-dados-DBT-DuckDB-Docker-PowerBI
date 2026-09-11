{{
    config(
        materialized='table'
    )
}}

SELECT * 
FROM read_csv(
    '/app/data/base_transacoes_bancarias_pipeline2.csv',
    header = true,
    columns = {
        'id_transacao': 'VARCHAR',
        'id_cliente': 'BIGINT',
        'id_conta': 'VARCHAR',
        'data_hora_transacao': 'TIMESTAMP',
        'data_abertura_conta': 'DATE',
        'tipo_conta': 'VARCHAR',
        'segmento_cliente': 'VARCHAR',
        'uf_cliente': 'VARCHAR',
        'faixa_etaria': 'VARCHAR',
        'produto_bancario': 'VARCHAR',
        'tipo_transacao': 'VARCHAR',
        'canal': 'VARCHAR',
        'valor_transacao': 'DOUBLE',
        'tarifa': 'DOUBLE',
        'saldo_antes': 'DOUBLE',
        'saldo_depois': 'DOUBLE',
        'status_transacao': 'VARCHAR',
        'motivo_recusa': 'VARCHAR',
        'categoria_estabelecimento': 'VARCHAR',
        'indicador_internacional': 'VARCHAR',
        'indicador_fraude': 'VARCHAR',
        'score_risco': 'BIGINT',
    }
)
