# Pipeline 2 — Transações Bancárias com Docker, dbt, DuckDB e Power BI

## 📌 Sobre o projeto

Este projeto foi desenvolvido para praticar a construção de uma solução analítica de ponta a ponta, utilizando uma base de transações bancárias em formato CSV.

O fluxo contempla ingestão, tratamento, modelagem dimensional e disponibilização dos dados para análise no Power BI. A organização segue uma arquitetura inspirada no padrão **Medallion**, com as camadas **Raw**, **Silver** e **Gold** armazenadas no DuckDB.

O dbt é executado em contêineres Docker, em um ambiente Linux com WSL2. O Power BI Desktop é utilizado no Windows e acessa o banco por meio de ODBC.

## 🏗️ Arquitetura

O fluxo lógico dos dados é:

**CSV → Raw → Silver → Gold → Power BI**

As transformações são desenvolvidas em SQL com Jinja e executadas pelo dbt sobre o DuckDB. O Docker fornece o ambiente de execução e suas dependências; os arquivos do projeto e o banco são disponibilizados ao contêiner por um volume do tipo bind mount.

### Raw

Responsável pela leitura do arquivo `base_transacoes_bancarias_pipeline2.csv`, por meio do modelo `transacoes_raw`.

Mantém os dados próximos da estrutura original, como ponto de partida para as demais camadas.

### Silver

Responsável pela preparação dos dados para a modelagem analítica. O tratamento desenvolvido contempla:

- remoção de espaços nas extremidades de campos textuais com `trim`;
- conversão de textos vazios em valores nulos com `nullif`;
- padronização das UFs em letras maiúsculas com `upper`;
- deduplicação por identificador da transação, utilizando uma ordenação temporal para selecionar um registro.

Na deduplicação com `row_number`, apenas uma linha é mantida por identificador. Se os critérios de ordenação empatarem, a escolha entre registros diferentes não é determinística sem um critério adicional de desempate.

### Gold

Responsável pela organização dos dados em um modelo dimensional, com uma tabela fato de transações e dimensões para os contextos de análise.

O grão esperado da fato é **uma linha por transação bancária**, após o tratamento e a deduplicação realizados na Silver.

## 📊 Modelo dimensional

O modelo organiza as transações em torno de conceitos como cliente, conta, data, canal e produto bancário.

| Componente | Finalidade |
| --- | --- |
| Dimensão cliente | Permitir análises por cliente e seus atributos, como segmento, faixa etária e UF. |
| Dimensão conta | Organizar informações das contas, como identificador, tipo e data de abertura. |
| Dimensão data | Disponibilizar atributos de calendário para análises por dia, mês, trimestre e ano. |
| Dimensão canal | Permitir a análise das transações por canal de atendimento ou operação. |
| Contexto de produto bancário | Permitir a comparação de quantidade e valor das transações por produto. |
| Fato de transações | Reunir as referências às dimensões e as medidas financeiras das operações. |

A dimensão data é construída a partir de um calendário, sem depender da existência de transações em cada dia. Seu intervalo deve cobrir as datas utilizadas pela fato.

As informações quantitativas da origem incluem valor da transação, tarifa, saldo anterior e saldo posterior. Os saldos representam posições em momentos específicos e exigem cuidado na agregação: sua soma entre transações não representa necessariamente o saldo de uma conta ou carteira.

> Os nomes físicos da fato, do modelo Silver e a organização final do produto bancário devem ser conferidos nos arquivos SQL. Esta documentação descreve os conceitos do modelo sem pressupor nomes de arquivos não confirmados.

## 🛠️ Tecnologias utilizadas

- **Docker Engine e Docker Compose** — construção e execução do ambiente em contêineres.
- **WSL2 / Ubuntu** — ambiente Linux utilizado no desenvolvimento.
- **Python** — base do ambiente de execução das ferramentas.
- **DuckDB** — banco de dados analítico local.
- **dbt e adapter dbt-duckdb** — transformação, modelagem, documentação e testes.
- **SQL e Jinja** — desenvolvimento dos modelos e referências entre camadas.
- **Power BI Desktop** — modelagem de consumo e visualização dos dados.
- **ODBC** — conexão entre Power BI e DuckDB.
- **Git** — versionamento do projeto.

## 📁 Organização do projeto

A organização principal contempla:

| Caminho ou arquivo | Conteúdo |
| --- | --- |
| `data/` | Arquivo CSV de origem. |
| `models/raw/` | Modelo de ingestão `transacoes_raw` e sua documentação. |
| `models/silver/` | Modelo de tratamento e deduplicação. |
| `models/gold/` | Dimensões, fato e documentação da camada analítica. |
| `database/dev.duckdb` | Banco DuckDB gerado pelo projeto. |
| `dashboard/` | Arquivo Power BI e documentação de acesso. |
| `macros/` | Macros auxiliares, quando utilizadas. |
| `tests/` | Testes SQL personalizados, quando utilizados. |
| `Dockerfile` | Definição da imagem de execução. |
| Arquivo do Docker Compose | Configuração do serviço, diretório de trabalho e volumes. |
| `dbt_project.yml` | Configuração do projeto dbt. |
| `profiles.yml` | Configuração da conexão com o DuckDB. |
| `requirements.txt` | Dependências Python do ambiente. |

> Os caminhos representam a organização de referência e devem acompanhar a estrutura final do repositório.

## ⚙️ Preparação do ambiente

### 1. Pré-requisitos

- WSL2 com Ubuntu, para reproduzir o ambiente utilizado no Windows;
- Docker Engine em execução e Docker Compose disponível no Linux;
- Git;
- Power BI Desktop e driver ODBC do DuckDB no Windows, para a etapa de visualização.

### 2. Clonar o repositório

No terminal do Ubuntu:

```bash
git clone <URL_DO_REPOSITORIO>
cd <NOME_DO_REPOSITORIO>
```

### 3. Conferir os arquivos e caminhos

Verifique se o CSV está no local esperado pelo modelo Raw e se o caminho do banco em `profiles.yml` corresponde ao diretório persistido pelo volume.

Na configuração utilizada durante o desenvolvimento, o projeto é montado em `/app`, com diretório de trabalho nesse mesmo caminho. Assim, o banco deve ser gravado em um diretório acessível fora do contêiner, como `/app/database/dev.duckdb`, conforme a configuração efetiva do perfil.

### 4. Construir a imagem

```bash
docker compose build
```

As dependências são instaladas na imagem. A execução por Docker dispensa a criação de um ambiente virtual Python no sistema hospedeiro.

## ▶️ Executando o projeto

Execute os comandos na pasta que contém o arquivo do Docker Compose.

Nos exemplos abaixo, substitua `NOME_DO_SERVICO` pelo nome definido em `services`. Os comandos consideram a configuração do projeto com **`entrypoint` definido como `dbt`**; por isso, o comando `dbt` não é repetido após o nome do serviço.

### Validar a configuração e a conexão

```bash
docker compose run --rm NOME_DO_SERVICO debug
```

### Executar os modelos e os testes configurados

```bash
docker compose run --rm NOME_DO_SERVICO build
```

O fluxo esperado é a leitura do CSV, a construção da Raw, o tratamento na Silver e a criação das dimensões e da fato na Gold.

### Executar somente os modelos

```bash
docker compose run --rm NOME_DO_SERVICO run
```

### Executar somente os testes

```bash
docker compose run --rm NOME_DO_SERVICO test
```

### Consultar uma amostra da Raw

```bash
docker compose run --rm NOME_DO_SERVICO show --select transacoes_raw --limit 10
```

A opção `--rm` remove o contêiner após a execução. Os arquivos gravados no diretório montado permanecem no sistema hospedeiro, incluindo o banco DuckDB.

Nos modelos materializados como `table`, uma nova execução reconstrói a tabela a partir do SQL atual. Esse comportamento permite aplicar correções sem acumular automaticamente os resultados da execução anterior. Modelos incrementais seguem uma lógica diferente, definida em sua configuração.

## 🧪 Qualidade e documentação dos dados

Os arquivos YAML do dbt permitem descrever os modelos, suas colunas e os testes associados.

Entre as verificações adequadas a este projeto estão:

- `not_null` nas chaves obrigatórias;
- `unique` nos identificadores que devem ser exclusivos;
- `relationships` entre as referências da fato e as chaves das dimensões;
- testes personalizados para regras de negócio, quando necessários.

Essas verificações são executadas apenas quando declaradas no projeto. O `dbt build` aplica os testes configurados; não cria validações automaticamente.

Para gerar a documentação técnica do dbt:

```bash
docker compose run --rm NOME_DO_SERVICO docs generate
```

## 📈 Dashboard Power BI

O dashboard utiliza a camada Gold do DuckDB como fonte de dados, acessada por conexão ODBC no Windows.

As análises contemplam o acompanhamento das transações bancárias, incluindo quantidade e valor das operações, comparação por produto bancário e segmentação por UF do cliente.

Para utilizar o dashboard:

1. Execute o pipeline para disponibilizar os dados no DuckDB.
2. Configure a conexão ODBC para o arquivo `database/dev.duckdb` do projeto.
3. Abra o arquivo `.pbix` no Power BI Desktop.
4. Ajuste a origem dos dados, caso o caminho local seja diferente.
5. Atualize os dados no Power BI.

Quando o banco estiver no WSL, o caminho acessado pelo Windows pode seguir o formato `\\wsl.localhost\Ubuntu\home\<USUARIO>\<PASTA_DO_PROJETO>\database\dev.duckdb`.

Evite atualizar o Power BI enquanto o dbt ou outro processo mantiver o banco aberto para escrita. Após finalizar o pipeline, encerre as conexões de escrita antes de atualizar o dashboard, para evitar conflitos de acesso ao arquivo.

A execução do dbt atualiza o DuckDB. A atualização dos dados importados pelo Power BI é uma etapa adicional.

Os detalhes do arquivo `.pbix` e da configuração ODBC devem ser consultados na documentação específica da pasta do dashboard.

## 🧠 Conceitos praticados

- Arquitetura em camadas Raw, Silver e Gold.
- Tratamento e deduplicação de dados transacionais.
- Definição do grão e identificação de fatos e dimensões.
- Modelagem dimensional para consumo analítico.
- Transformações e dependências com SQL, Jinja e dbt.
- Documentação e testes de qualidade dos dados.
- Execução em contêineres e persistência por volumes.
- Integração entre Linux/WSL, DuckDB e Power BI no Windows.
- Versionamento do projeto com Git.

## 🎯 Resultado e objetivo de aprendizado

O projeto conecta uma base CSV de transações bancárias a um dashboard analítico, passando pelo tratamento e pela modelagem dos dados no DuckDB com dbt.

Em relação ao primeiro pipeline, acrescenta a execução em Docker e a integração entre o ambiente Linux/WSL e o Power BI no Windows.

O principal objetivo é exercitar o ciclo completo de uma solução de dados e consolidar conhecimentos de **Engenharia de Dados, Analytics Engineering e Modelagem Dimensional** em um ambiente local reproduzível.
