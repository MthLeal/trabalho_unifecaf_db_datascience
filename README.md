# Projeto de Arquitetura de Dados - VarejoMix

Este repositório contém a entrega final para o desafio de Engenharia e Análise de Dados da VarejoMix, endereçando a reestruturação da arquitetura de dados (OLTP, NoSQL, e Lakehouse). [Link](https://youtu.be/p0DkVCQN_Ks) para assistir o vídeo pit.

## Estrutura do Repositório (Pacote Técnico)
- `relatorio_arquitetura.pdf`: Relatório teórico (6-10 págs) gerado a partir do HTML, contendo diagramas, trade-offs e o estudo de caso da Uber.
- `database_setup.sql`: DDL, DML, criação de views, queries analíticas (CTEs/Window Functions) e otimização por índices.
- `data_science_prep.py`: Script Python integrando via `read_sql` e gerando features RFM para Data Science.

## Pré-requisitos
- PostgreSQL (opcional para rodar o SQL, pode ser testado online via DB Fiddle).
- Python 3.8+ e a biblioteca `pandas` (`pip install pandas`).

## Passo a Passo de Execução Local

### 1. Testando o SQL
1. Abra um SGBD (ex: DBeaver, pgAdmin) conectado a uma instância PostgreSQL.
2. Execute o conteúdo de `database_setup.sql` sequencialmente.
3. Ao rodar o comando `EXPLAIN ANALYZE SELECT * FROM tb_orders WHERE order_date >= '2025-11-01';`, você notará no output o uso do `Index Scan` no índice `idx_orders_order_date` ao invés de um custoso `Seq Scan` (Leitura sequencial).

### 2. Executando o pipeline Python
1. No terminal, navegue até a pasta do projeto.
2. Execute o script: `python data_science_prep.py`
3. **Evidência de saída esperada (Log Terminal):**
```text
--- Extracao Concluida ---
Shape do Dataset Bruto: (5, 4)

--- Documentacao do Dataset (RFM) ---
Total de Clientes Distintos: 3
...
--- Amostra do Dataset Pronto para Machine Learning ---
   customer_id  recency  frequency  monetary_value
0            1       21          3      1003.333333
1            2       30          1      2400.000000
2            3      235          1       300.000000
```