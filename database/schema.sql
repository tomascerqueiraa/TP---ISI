-- schema.sql - Smart Delivery Analytics (ISI 2026/27)
-- Executar na base de dados db_logistica (PostgreSQL).
-- O job tambem executa estas instrucoes no passo "Criar tabelas".

CREATE TABLE IF NOT EXISTS motorista_viatura (
    id_motorista    INTEGER PRIMARY KEY,
    nome            VARCHAR(100),
    carta_conducao  VARCHAR(20),
    matricula       VARCHAR(20),
    categoria       VARCHAR(20),
    marca           VARCHAR(50),
    modelo          VARCHAR(50),
    tipo_carga      VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS alerta_velocidade (
    id_alerta              SERIAL PRIMARY KEY,
    veiculo_id             VARCHAR(20),
    ts                     VARCHAR(30),
    velocidade_kmh         NUMERIC(6,1),
    temperatura_carga_c    NUMERIC(5,1),
    nivel_combustivel_pct  NUMERIC(5,1),
    nome                   VARCHAR(100),
    categoria              VARCHAR(20),
    tipo_carga             VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS resumo_veiculo (
    veiculo_id        VARCHAR(20) PRIMARY KEY,
    n_leituras        INTEGER,
    velocidade_media  NUMERIC(8,2),
    velocidade_max    NUMERIC(6,1),
    combustivel_min   NUMERIC(5,1)
);

CREATE TABLE IF NOT EXISTS meteo (
    id_meteo         SERIAL PRIMARY KEY,
    status           VARCHAR(10),
    hora             VARCHAR(30),
    temperatura_c    NUMERIC(5,1),
    humidade_pct     NUMERIC(5,1),
    vento_kmh        NUMERIC(5,1),
    precipitacao_mm  NUMERIC(5,1),
    carregado_em     TIMESTAMP DEFAULT now()
);
