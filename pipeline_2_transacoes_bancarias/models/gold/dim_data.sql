{{ config(materialized='table') }}

{% set data_inicio = '2012-01-01' %}
{% set data_fim = '2030-12-31' %}

WITH calendario AS (

    SELECT
        CAST(dia AS DATE) AS data
    FROM generate_series(
        DATE '{{ data_inicio }}',
        DATE '{{ data_fim }}',
        INTERVAL '1 day'
    ) AS serie(dia)

)

SELECT
    CAST(strftime(data, '%Y%m%d') AS INTEGER) AS id_data,
    data,
    year(data) AS ano,
    month(data) AS mes,
    day(data) AS dia,
    quarter(data) AS trimestre,
    strftime(data, '%Y-%m') AS ano_mes,
    isodow(data) AS dia_semana,
    isodow(data) IN (6, 7) AS fim_de_semana
FROM calendario
