"""
Script de Extração e Preparação para Data Science (Propensão de Recompra)
Ferramentas: pandas, sqlite3/sqlalchemy (simulando conexão)
"""
import pandas as pd
import sqlite3
from datetime import datetime

# 1. SIMULAÇÃO DE EXTRAÇÃO (Lendo de um banco relacional / read_sql)
# Na VarejoMix, usaríamos SQLAlchemy: engine = create_engine('postgresql://user:pass@host/db')
# Aqui usamos sqlite em memória para o código ser executável independentemente.
conn = sqlite3.connect(':memory:')

# Criando dataframe simulando a query da View vw_order_summary do script SQL
data = {
    'order_id': [1, 2, 3, 4, 5],
    'customer_id': [1, 1, 2, 3, 1],
    'order_date': ['2025-10-01', '2025-11-15', '2025-12-01', '2025-05-10', '2025-12-10'],
    'total_order_value': [2800.00, 160.00, 2400.00, 300.00, 50.00]
}
df_raw = pd.DataFrame(data)
df_raw['order_date'] = pd.to_datetime(df_raw['order_date'])
df_raw.to_sql('vw_order_summary', conn, index=False)

# Extração real via SQL
query = "SELECT * FROM vw_order_summary"
df = pd.read_sql(query, conn, parse_dates=['order_date'])
print("--- Extracao Concluida ---")
print(f"Shape do Dataset Bruto: {df.shape}\n")

# 2. FEATURE ENGINEERING (Criação de Dataset Analítico)
# Criando features RFM (Recency, Frequency, Monetary) vitais para modelos de churn/recompra
analysis_date = pd.to_datetime('2025-12-31')

# Agrupando por cliente
df_features = df.groupby('customer_id').agg(
    recency=('order_date', lambda x: (analysis_date - x.max()).days),
    frequency=('order_id', 'count'),
    monetary_value=('total_order_value', 'mean')
).reset_index()

# 3. BREVE DOCUMENTAÇÃO DO DATASET (Dicionário de Dados)
print("--- Documentacao do Dataset (RFM) ---")
print(f"Total de Clientes Distintos: {df_features.shape[0]}")
print(f"Valores Nulos: \n{df_features.isnull().sum()}\n")
print("""
Dicionario de Dados:
- customer_id: Identificador unico do cliente.
- recency: Dias desde a ultima compra (quanto menor, mais recente).
- frequency: Numero total de pedidos realizados.
- monetary_value: Ticket medio (valor gasto / frequencia).
Premissas: Utilizada a data de 31/12/2025 como referencia (analysis_date).
""")

print("--- Amostra do Dataset Pronto para Machine Learning ---")
print(df_features.head())

# Opcional na vida real: Salvar em parquet para leitura do modelo
# df_features.to_parquet('customer_features.parquet')