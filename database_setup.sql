-- 1. MODELAGEM OLTP (NORMALIZAÇÃO E INTEGRIDADE) - PostgreSQL
-- Garantindo chaves fortes e integridade referencial (3ª Forma Normal)

CREATE TABLE tb_customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tb_products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    current_price DECIMAL(10,2) NOT NULL
);

CREATE TABLE tb_orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES tb_customers(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'completed'
);

CREATE TABLE tb_order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES tb_orders(order_id),
    product_id INT REFERENCES tb_products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL -- Guarda o preço no momento da compra
);

-- 2. DML - CARGA MÍNIMA DE DADOS
INSERT INTO tb_customers (name, email) VALUES 
('Ana Silva', 'ana@email.com'), ('Bruno Costa', 'bruno@email.com'), ('Carlos Dias', 'carlos@email.com');

INSERT INTO tb_products (name, category, current_price) VALUES 
('Smartphone X', 'Eletrônicos', 2500.00), ('Fone Bluetooth', 'Eletrônicos', 300.00), ('Camisa Básica', 'Vestuário', 80.00);

INSERT INTO tb_orders (customer_id, order_date) VALUES 
(1, '2025-10-01 10:00:00'), (1, '2025-11-15 14:00:00'), (2, '2025-12-01 09:30:00');

INSERT INTO tb_order_items (order_id, product_id, quantity, unit_price) VALUES 
(1, 1, 1, 2500.00), (1, 2, 1, 300.00), (2, 3, 2, 80.00), (3, 1, 1, 2400.00);


-- 3. OTIMIZAÇÃO: ÍNDICES E PLANO DE EXECUÇÃO (EXPLAIN ANALYZE)
-- Problema: Consultas filtrando pedidos por data ou cliente estavam lentas.
-- Solução: Criação de índices B-Tree nas chaves estrangeiras e datas.

CREATE INDEX idx_orders_customer_id ON tb_orders(customer_id);
CREATE INDEX idx_orders_order_date ON tb_orders(order_date);

-- Evidência para o relatório (Executar isso no banco para obter os logs):
-- EXPLAIN ANALYZE 
-- SELECT * FROM tb_orders WHERE order_date >= '2025-11-01';


-- 4. CONSULTAS ANALÍTICAS (VIEWS, CTES e WINDOW FUNCTIONS)

-- VIEW Analítica para facilitar a vida do time de Dados (agrega o valor do pedido)
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    SUM(oi.quantity * oi.unit_price) AS total_order_value
FROM tb_orders o
JOIN tb_order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.customer_id, o.order_date;

-- CTE e Window Function: 
-- Objetivo: Identificar o ticket médio acumulado do cliente e ranquear suas compras
WITH CustomerPurchases AS (
    SELECT 
        customer_id,
        order_id,
        order_date,
        total_order_value,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as purchase_number,
        SUM(total_order_value) OVER (PARTITION BY customer_id ORDER BY order_date) as cumulative_spent
    FROM vw_order_summary
)
SELECT * FROM CustomerPurchases;
