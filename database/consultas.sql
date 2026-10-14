-- consultas.sql - verificacao dos dados carregados
SELECT 'motorista_viatura' AS tabela, COUNT(*) FROM motorista_viatura
UNION ALL SELECT 'alerta_velocidade', COUNT(*) FROM alerta_velocidade
UNION ALL SELECT 'resumo_veiculo', COUNT(*) FROM resumo_veiculo
UNION ALL SELECT 'meteo', COUNT(*) FROM meteo;

-- Veiculos com maior velocidade maxima
SELECT veiculo_id, n_leituras, velocidade_media, velocidade_max
FROM resumo_veiculo ORDER BY velocidade_max DESC;

-- Alertas por motorista
SELECT nome, COUNT(*) AS n_alertas, MAX(velocidade_kmh) AS vel_max
FROM alerta_velocidade GROUP BY nome ORDER BY n_alertas DESC;

-- Ultima leitura meteorologica
SELECT * FROM meteo ORDER BY id_meteo DESC LIMIT 1;
