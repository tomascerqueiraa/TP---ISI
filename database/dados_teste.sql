-- ============================================================================
--  dados_teste.sql  -  Smart Delivery Analytics (ISI 2026/27)
--  Carga de dados de teste COM ERROS PROPOSITADOS para a Fase 2 (Limpeza/Validação)
--  Executar DEPOIS de schema.sql:   psql -U postgres -d db_logistica -f sql/dados_teste.sql
-- ============================================================================
SET client_encoding = 'UTF8';
BEGIN;

-- Limpar execuções anteriores (remove os duplicados deixados pelos testes antigos)
TRUNCATE TABLE public.frota_processada;
TRUNCATE TABLE public.historico_encomendas RESTART IDENTITY;

-- ----------------------------------------------------------------------------
--  historico_encomendas: 40 linhas
--  Erros propositados (para tratar em T1/T4 e mostrar no relatório):
--    * Duplicados exatos ........ ids 38, 39, 40 (cópias das encomendas 5, 18 e 28)
--    * Estado sujo .............. 'PENDENTE' (id 23) e 'entregue ' (id 24)
--    * Nome com espaços a mais .. id 23 ('  Mercearia   Fina ')
--    * Email inválido ........... ids 26 e 34
--    * Email em maiúsculas ...... id 24 (normalizar para minúsculas)
--    * Email NULL ............... id 31
--    * Telefone inválido ........ id 27 ('91234')
--    * Telefone com formatos .... '+351 912 345 678', '253 222 333', '00351 912 777 888'
--    * Telefone NULL ............ id 32
--    * Peso NULL ................ id 33
--    * Destino/coords NULL ...... id 35 (sem morada: deve ser rejeitada)
--    * Sem motorista atribuído .. ids 22, 33, 35, 37
--    * Acentos/ç ................ Farmácia, Conceição, Gonçalves, Têxtil, Ótica, Várzea...
-- ----------------------------------------------------------------------------
INSERT INTO public.historico_encomendas
  (cliente, destino, peso_kg, estado, id_motorista, matricula, zona, latitude, longitude, email_cliente, telefone_cliente, data_registo)
VALUES
  ('Supermercado Ponto Certo', 'Braga - Centro', 120.5, 'Pendente', 1, '12-AB-34', 'Centro Urbano', 41.5503, -8.4201, 'compras@pontocerto.pt', '253123456', '2026-10-06 08:00:00'),
  ('Farmácia Central', 'Guimarães', 15.2, 'Entregue', 2, '45-CD-67', 'Centro Urbano', 41.4425, -8.2918, 'geral@farmaciacentral.pt', '253456789', '2026-10-06 10:07:00'),
  ('Tech Store', 'Porto - Boavista', 45.0, 'Em Trânsito', 2, '45-CD-67', 'Centro Urbano', 41.1579, -8.6291, 'loja@techstore.pt', '+351 912 345 678', '2026-10-06 12:14:00'),
  ('Padaria São José', 'Rua do Souto, 45 - Braga', 32.4, 'Entregue', 1, '12-AB-34', 'Centro Urbano', 41.5518, -8.4229, 'padaria.sj@gmail.com', '912345678', '2026-10-06 14:21:00'),
  ('Pastelaria Doçaria da Avó', 'Av. da Liberdade, 120 - Braga', 18.75, 'Em Trânsito', 1, '12-AB-34', 'Centro Urbano', 41.5535, -8.4247, 'doces@docariadaavo.pt', '253 222 333', '2026-10-06 16:28:00'),
  ('Talho Conceição', 'Rua de São Marcos, 8 - Braga', 64.0, 'Pendente', 3, '89-EF-01', 'Centro Urbano', 41.547, -8.415, 'talho.conceicao@sapo.pt', '963111222', '2026-10-06 18:35:00'),
  ('Ourivesaria Gonçalves', 'Praça da República, 3 - Braga', 2.3, 'Entregue', 3, '89-EF-01', 'Centro Urbano', 41.551, -8.426, 'info@ourivesariagoncalves.pt', '253987654', '2026-10-06 20:42:00'),
  ('Livraria Lusitana', 'Rua do Raio, 200 - Braga', 27.8, 'Entregue', 5, '34-IJ-56', 'Centro Urbano', 41.553, -8.413, 'livraria@lusitana.pt', '+351 253 111 222', '2026-10-06 22:49:00'),
  ('Papelaria Escolar Braga', 'Rua Universitária, 15 - Gualtar', 54.1, 'Pendente', 5, '34-IJ-56', 'Zona Escolar', 41.561, -8.397, 'papelaria@escolarbraga.pt', '912 888 777', '2026-10-07 00:56:00'),
  ('Escola Básica de Gualtar', 'Campus de Gualtar - Braga', 210.0, 'Em Trânsito', 6, '56-KL-78', 'Zona Escolar', 41.5605, -8.3985, 'secretaria@ebgualtar.pt', '253604000', '2026-10-07 02:03:00'),
  ('Cantina Universitária', 'Largo do Paço - Braga', 340.6, 'Pendente', 6, '56-KL-78', 'Zona Escolar', 41.5585, -8.396, 'cantina@uni.pt', '253601234', '2026-10-07 04:10:00'),
  ('Colégio Nossa Senhora do Carmo', 'Rua do Carmo, 77 - Braga', 98.2, 'Entregue', 8, '78-OP-12', 'Zona Escolar', 41.5449, -8.429, 'colegio.carmo@gmail.com', '934555666', '2026-10-07 06:17:00'),
  ('Fábrica Têxtil do Ave', 'Zona Ind. de Ferreiros - Braga', 780.0, 'Em Trânsito', 4, '23-GH-45', 'Zona Industrial', 41.524, -8.391, 'logistica@textilave.pt', '253700100', '2026-10-07 08:24:00'),
  ('Metalúrgica Cávado', 'Parque Industrial de Barcelos', 925.5, 'Pendente', 4, '23-GH-45', 'Zona Industrial', 41.5333, -8.6167, 'compras@metcavado.pt', '253800200', '2026-10-07 10:31:00'),
  ('Cerâmicas Ibérica', 'Zona Industrial de Famalicão', 610.3, 'Entregue', 7, '67-MN-90', 'Zona Industrial', 41.4096, -8.5198, 'encomendas@ceramicasiberica.pt', '252300300', '2026-10-07 12:38:00'),
  ('Oficina Auto Ação', 'Rua da Indústria, 12 - Guimarães', 148.9, 'Em Trânsito', 7, '67-MN-90', 'Zona Industrial', 41.451, -8.304, 'oficina@autoacao.pt', '253400500', '2026-10-07 14:45:00'),
  ('Distribuidora Minho Frio', 'Parque Empresarial Vila Verde', 455.0, 'Entregue', 4, '23-GH-45', 'Zona Industrial', 41.648, -8.435, 'frio@minhofrio.pt', '253650100', '2026-10-07 16:52:00'),
  ('Hotel Solar do Minho', 'Estrada Nacional 101, Braga', 88.6, 'Pendente', 9, '90-QR-23', 'Autoestrada', 41.512, -8.47, 'reservas@solardominho.pt', '253555000', '2026-10-07 18:59:00'),
  ('Peixaria do Cávado', 'Mercado Municipal - Esposende', 72.4, 'Entregue', 9, '90-QR-23', 'Centro Urbano', 41.532, -8.781, 'peixaria@cavado.pt', '253961111', '2026-10-07 20:06:00'),
  ('Cervejaria Praça Velha', 'Praça Velha, 6 - Guimarães', 41.2, 'Em Trânsito', 10, '11-ST-34', 'Centro Urbano', 41.444, -8.296, 'cervejaria@pracavelha.pt', '253412121', '2026-10-07 22:13:00'),
  ('Hospital Privado do Minho', 'Av. Sá Carneiro, 300 - Braga', 190.0, 'Entregue', 10, '11-ST-34', 'Centro Urbano', 41.548, -8.418, 'farmacia@hospminho.pt', '253270000', '2026-10-08 00:20:00'),
  ('Gelataria Frescura', 'Rua D. Diogo de Sousa, 20 - Braga', 36.0, 'Cancelada', NULL, NULL, 'Centro Urbano', 41.5528, -8.4235, 'gelataria@frescura.pt', '912121212', '2026-10-08 02:27:00'),
  ('  Mercearia   Fina ', 'Rua do Anjo, 9 - Braga', 22.5, 'PENDENTE', 12, '33-WX-78', 'Centro Urbano', 41.5515, -8.421, 'mercearia.fina@gmail.com', '253332211', '2026-10-08 04:34:00'),
  ('Florista Ana Rosa', 'Av. Central, 55 - Braga', 9.9, 'entregue ', 12, '33-WX-78', 'Centro Urbano', 41.5522, -8.4215, 'INFO@ANAROSA.PT', '965432100', '2026-10-08 06:41:00'),
  ('Ótica Visão Clara', 'Rua dos Chãos, 31 - Braga', 3.4, 'Em Trânsito', 14, '55-AB-12', 'Centro Urbano', 41.549, -8.424, 'otica@visaoclara.pt', '253114477', '2026-10-08 08:48:00'),
  ('Pet Shop Amigo Fiel', 'Rua do Alferes, 4 - Guimarães', 58.3, 'Pendente', 14, '55-AB-12', 'Centro Urbano', 41.443, -8.2905, 'geral@amigofiel', '910000111', '2026-10-08 10:55:00'),
  ('Clínica Dentária Sorriso', 'Rua do Castelo, 18 - Braga', 5.6, 'Entregue', 14, '55-AB-12', 'Centro Urbano', 41.556, -8.417, 'clinica@sorriso.pt', '91234', '2026-10-08 12:02:00'),
  ('Quinta da Várzea', 'Estrada de Ponte de Lima', 133.7, 'Em Trânsito', 13, '78-QR-90', 'Autoestrada', 41.602, -8.59, 'quinta@varzea.pt', '258200200', '2026-10-08 14:09:00'),
  ('Cooperativa Agrícola do Minho', 'A3 - Saída Barcelos', 402.0, 'Pendente', 13, '78-QR-90', 'Autoestrada', 41.559, -8.57, 'coop@agricolaminho.pt', '253820820', '2026-10-08 16:16:00'),
  ('Frutaria Sabor do Campo', 'Largo do Mercado, 2 - Barcelos', 47.1, 'Entregue', 19, '77-EF-56', 'Centro Urbano', 41.538, -8.615, 'frutaria@sabordocampo.pt', '253811000', '2026-10-08 18:23:00'),
  ('Casa dos Queijos', 'Rua Direita, 100 - Guimarães', 29.0, 'Entregue', 19, '77-EF-56', 'Centro Urbano', 41.442, -8.293, NULL, '253440440', '2026-10-08 20:30:00'),
  ('Restaurante O Cantinho', 'Rua de Santa Maria, 22 - Braga', 96.8, 'Pendente', 1, '12-AB-34', 'Centro Urbano', 41.55, -8.419, 'ocantinho@sapo.pt', NULL, '2026-10-08 22:37:00'),
  ('Super Mini Preço', 'Av. Nova Sintra, 10 - Braga', NULL, 'Pendente', NULL, NULL, 'Centro Urbano', 41.544, -8.412, 'minipreco@gmail.com', '253778899', '2026-10-09 00:44:00'),
  ('Loja do Cidadão Avenidas', 'Av. da Liberdade, 1 - Braga', 15.0, 'Pendente', 8, '78-OP-12', 'Centro Urbano', 41.553, -8.425, 'contacto.loja#cidadao.pt', '253000111', '2026-10-09 02:51:00'),
  ('Armazéns Santa Luzia', NULL, 310.4, 'Pendente', NULL, NULL, 'Zona Industrial', NULL, NULL, 'armazens@santaluzia.pt', '253909090', '2026-10-09 04:58:00'),
  ('Frigorífico Norte Distribuição', 'A11 - Saída Vila Verde', 520.0, 'Entregue', 2, '45-CD-67', 'Autoestrada', 41.67, -8.43, 'norte@frigorifico.pt', '253660660', '2026-10-09 06:05:00'),
  ('Retrosaria Mão de Fada', 'Rua do Souto, 77 - Braga', 4.1, 'Cancelada', NULL, NULL, 'Centro Urbano', 41.5516, -8.423, 'retrosaria@maodefada.pt', '00351 912 777 888', '2026-10-09 08:12:00'),
  ('Pastelaria Doçaria da Avó', 'Av. da Liberdade, 120 - Braga', 18.75, 'Em Trânsito', 1, '12-AB-34', 'Centro Urbano', 41.5535, -8.4247, 'doces@docariadaavo.pt', '253 222 333', '2026-10-06 16:28:00'),
  ('Hotel Solar do Minho', 'Estrada Nacional 101, Braga', 88.6, 'Pendente', 9, '90-QR-23', 'Autoestrada', 41.512, -8.47, 'reservas@solardominho.pt', '253555000', '2026-10-07 18:59:00'),
  ('Quinta da Várzea', 'Estrada de Ponte de Lima', 133.7, 'Em Trânsito', 13, '78-QR-90', 'Autoestrada', 41.602, -8.59, 'quinta@varzea.pt', '258200200', '2026-10-08 14:09:00');

SELECT setval('public.historico_encomendas_id_encomenda_seq',
              (SELECT MAX(id_encomenda) FROM public.historico_encomendas));

COMMIT;

-- Verificações rápidas
-- SELECT COUNT(*) FROM public.historico_encomendas;                       -- 40
-- SELECT estado, COUNT(*) FROM public.historico_encomendas GROUP BY 1;
-- SELECT * FROM public.historico_encomendas WHERE id_motorista IS NULL;
