# Dashboard Power BI

Esta pasta contém o dashboard desenvolvido em **Power BI Desktop** para análise das transações bancárias do Pipeline 2.

## Arquivo

Abra o arquivo `.pbix` disponibilizado nesta pasta utilizando o **Power BI Desktop**.

Se o arquivo estiver salvo com os dados importados, é possível visualizar os gráficos e utilizar os filtros sem configurar o ambiente do pipeline. A configuração abaixo é necessária apenas para atualizar os dados.

## Fonte de dados

O dashboard utiliza as tabelas da **camada Gold**, construídas com dbt e armazenadas no banco **DuckDB**:

`database/dev.duckdb`

O pipeline é executado em Docker no Ubuntu/WSL2. O Power BI Desktop é executado no Windows e acessa o banco por meio de **ODBC**.

## Pré-requisitos para atualização

1. Banco `database/dev.duckdb` gerado pelo projeto.
2. Driver ODBC do DuckDB instalado no Windows, com arquitetura compatível com o Power BI Desktop.
3. Caminho da conexão ajustado para o local do banco na máquina.

Para gerar ou reprocessar o banco, siga as instruções do README principal do projeto.

## Configurando a conexão

No Power BI Desktop:

1. Acesse **Transformar dados**.
2. Nas consultas, localize a etapa **Fonte**.
3. Ajuste o caminho do banco na string de conexão ODBC, preservando as demais etapas.

Exemplo de conexão, substituindo usuário e pastas pelo caminho local:

```text
Driver={DuckDB Driver};Database=\\wsl.localhost\Ubuntu\home\SEU_USUARIO\CAMINHO_DO_PROJETO\database\dev.duckdb;access_mode=READ_ONLY;
```

O caminho deve ser acessível pelo Explorador de Arquivos do Windows. O caminho `/app/database/dev.duckdb`, utilizado dentro do contêiner, não deve ser usado no Power BI.

A conexão acima utiliza diretamente o driver e o arquivo do banco, sem exigir a criação de um DSN.

## Atualizando o dashboard

1. Feche o Power BI e outras ferramentas conectadas ao banco.
2. Execute o pipeline conforme o README principal e aguarde sua conclusão.
3. Abra o arquivo `dashboard_transacoes_bancarias.pbix`.
4. Clique em **Atualizar**.
5. Salve o relatório após a atualização.

**Atenção:** execute o dbt e a atualização do Power BI em momentos distintos para evitar bloqueios do arquivo DuckDB. O parâmetro `READ_ONLY` não permite gravação simultânea pelo dbt.

Atualizar o Power BI apenas carrega os dados existentes no banco; essa ação não executa o pipeline.

## Fluxo de dados

`CSV → Bronze → Silver → Gold → Power BI`

O dbt transforma e modela os dados no DuckDB. O Power BI apresenta os indicadores para consumo analítico.