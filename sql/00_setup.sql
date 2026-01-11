-- =========================================================
-- 00_setup.sql (PostgreSQL)
-- Olist dataset: create schema + tables + indexes
-- =========================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS olist;
SET search_path TO olist;

-- Drop in dependency-safe order
DROP TABLE IF EXISTS geolocation CASCADE;
DROP TABLE IF EXISTS order_reviews CASCADE;
DROP TABLE IF EXISTS order_payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS product_category_name_translation CASCADE;
DROP TABLE IF EXISTS sellers CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- 1) customers
CREATE TABLE customers (
  customer_id               TEXT PRIMARY KEY,
  customer_unique_id        TEXT NOT NULL,
  customer_zip_code_prefix  TEXT,
  customer_city             TEXT,
  customer_state            TEXT
);

-- 2) sellers
CREATE TABLE sellers (
  seller_id                 TEXT PRIMARY KEY,
  seller_zip_code_prefix    TEXT,
  seller_city               TEXT,
  seller_state              TEXT
);

-- 3) products
CREATE TABLE products (
  product_id                 TEXT PRIMARY KEY,
  product_category_name      TEXT,
  product_name_lenght        INTEGER,
  product_description_lenght INTEGER,
  product_photos_qty         INTEGER,
  product_weight_g           INTEGER,
  product_length_cm          INTEGER,
  product_height_cm          INTEGER,
  product_width_cm           INTEGER
);

-- 4) category translation
CREATE TABLE product_category_name_translation (
  product_category_name          TEXT PRIMARY KEY,
  product_category_name_english  TEXT
);

-- 5) orders
CREATE TABLE orders (
  order_id                       TEXT PRIMARY KEY,
  customer_id                    TEXT NOT NULL REFERENCES customers(customer_id),
  order_status                   TEXT,
  order_purchase_timestamp       TIMESTAMP,
  order_approved_at              TIMESTAMP,
  order_delivered_carrier_date   TIMESTAMP,
  order_delivered_customer_date  TIMESTAMP,
  order_estimated_delivery_date  TIMESTAMP
);

-- 6) order_items
CREATE TABLE order_items (
  order_id            TEXT NOT NULL REFERENCES orders(order_id),
  order_item_id       INTEGER NOT NULL,
  product_id          TEXT REFERENCES products(product_id),
  seller_id           TEXT REFERENCES sellers(seller_id),
  shipping_limit_date TIMESTAMP,
  price               NUMERIC(12,2),
  freight_value       NUMERIC(12,2),
  PRIMARY KEY (order_id, order_item_id)
);

-- 7) order_payments
CREATE TABLE order_payments (
  order_id             TEXT NOT NULL REFERENCES orders(order_id),
  payment_sequential   INTEGER NOT NULL,
  payment_type         TEXT,
  payment_installments INTEGER,
  payment_value        NUMERIC(12,2),
  PRIMARY KEY (order_id, payment_sequential)
);

-- 8) order_reviews
CREATE TABLE order_reviews (
  review_id               TEXT,
  order_id                TEXT NOT NULL REFERENCES orders(order_id),
  review_score            INTEGER,
  review_comment_title    TEXT,
  review_comment_message  TEXT,
  review_creation_date    TIMESTAMP,
  review_answer_timestamp TIMESTAMP
);

-- 9) geolocation (optional / large)
CREATE TABLE geolocation (
  geolocation_zip_code_prefix TEXT,
  geolocation_lat             NUMERIC(10,6),
  geolocation_lng             NUMERIC(10,6),
  geolocation_city            TEXT,
  geolocation_state           TEXT
);

-- Indexes for analytics performance
CREATE INDEX idx_orders_customer_id       ON orders(customer_id);
CREATE INDEX idx_orders_purchase_ts       ON orders(order_purchase_timestamp);

CREATE INDEX idx_order_items_product_id   ON order_items(product_id);
CREATE INDEX idx_order_items_seller_id    ON order_items(seller_id);

CREATE INDEX idx_payments_order_id        ON order_payments(order_id);
CREATE INDEX idx_reviews_order_id         ON order_reviews(order_id);

COMMIT;
