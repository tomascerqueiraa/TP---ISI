# Smart Delivery Analytics – ETL com Pentaho Kettle

Trabalho Prático I · Integração de Sistemas de Informação · 2026/27  
Licenciatura em Engenharia de Sistemas Informáticos · Escola Superior de Tecnologia – IPCA  
Autor: **Tomás Afonso Cerqueira Gomes nº31501**

## 1. Descrição

Processo ETL para uma empresa fictícia de distribuição (**Smart Delivery Analytics**). Integra dados de uma frota que estão em formatos diferentes, limpa-os e valida-os, cruza motoristas, viaturas e telemetria, deteta excessos de velocidade e guarda os resultados em PostgreSQL e em ficheiros. No fim envia um relatório HTML por email e mostra os resultados num dashboard Node-RED.

| Fase | O que faz |
|---|---|
| **E** (Extrair) | CSV (motoristas), XML (viaturas), JSON (telemetria) e API REST (Open-Meteo) |
| **T** (Transformar) | Nulos, duplicados, regex, normalização, lookups, filtros, agregações, conversão de formatos |
| **L** (Carregar) | PostgreSQL, ficheiros CSV/JSON/XML/HTML, email e dashboard Node-RED |

## 2. Estrutura do projeto

```
job_frotas_simples.kjb      Job principal (orquestra tudo)
T1_motoristas.ktr           Limpeza dos motoristas (CSV)
T2_viaturas.ktr             Junção motoristas + viaturas (XML)
T3_telemetria.ktr           Validação da telemetria (JSON), alertas e resumo
T4_meteo.ktr                Chamada à API Open-Meteo
T5_carregar_bd.ktr          Carga nas tabelas PostgreSQL
T6_resumo_xml.ktr           Resumo por veículo em XML
T7_html_variavel.ktr        Guarda o HTML do relatório na variável html_body
relatorio.xsl               Folha XSL: XML -> relatório HTML
motoristas_frota.csv        Dados de entrada (CSV)
viaturas.xml                Dados de entrada (XML)
telemetria_sensores.json    Dados de entrada (JSON)
config_zonas.yaml           Regras por zona (não usado nesta versão)
sql/schema.sql              Criação das tabelas
sql/consultas.sql           Consultas de verificação
node-red/flows.json         Fluxo e dashboard Node-RED
database/                   Backup da base de dados (db_logistica_backup.sql)
staging/                    Ficheiros intermédios (criada automaticamente)
saida/                      Rejeitados, exportações e relatório (criada automaticamente)
```

Todos os caminhos usam `${Internal.Entry.Current.Directory}`, por isso o projeto funciona em qualquer pasta, desde que os ficheiros fiquem **todos juntos**.

## 3. Requisitos

| Software | Para quê |
|---|---|
| Pentaho Data Integration (Spoon) 10.2 | Executar o job e as transformações |
| PostgreSQL + pgAdmin | Base de dados `db_logistica` |
| Node.js (LTS) e Node-RED | Dashboard |
| smtp4dev (ou conta SMTP) | Receber os emails de teste |
| Ligação à Internet | Chamada à API Open-Meteo (T4) |

## 4. Preparação

### 4.1 Base de dados
1. Cria a base de dados `db_logistica` no pgAdmin.
2. As tabelas são criadas automaticamente pelo job (entrada *Criar tabelas BD*), com o `sql/schema.sql`. Também podes executá-lo manualmente.
3. No Spoon, edita a ligação **`postgresSQL`** (host `localhost`, porta `5432`, base `db_logistica`, utilizador `postgres`) e confirma a palavra-passe com *Test*.

### 4.2 Email
O job usa, por defeito, o **smtp4dev** local (`localhost`, porta `25`, sem autenticação).
1. Descarrega o `.zip` para Windows na página de *Releases* do projeto smtp4dev (`github.com/rnwood/smtp4dev/releases`) e executa `Rnwood.Smtp4dev.exe`.
2. Abre `http://localhost:5000` para ver os emails recebidos.
3. Se usares outra porta, altera **Port** nas entradas *Email de sucesso* e *Email de erro* do job.

Para um servidor real (por exemplo Office 365: `smtp.office365.com`, porta `587`, TLS), ativa a autenticação nas duas entradas. **Não guardes palavras-passe no repositório.**

### 4.3 Node-RED
1. Instala o Node.js (LTS) e depois, numa linha de comandos: `npm install -g node-red`.
2. Arranca com `node-red` e abre `http://localhost:1880`.
3. Em *Manage palette → Install*, instala: `node-red-dashboard`, `node-red-node-ui-table` e `node-red-contrib-postgresql`.
4. Menu → *Import* e seleciona `node-red/flows.json`.
5. No nó PostgreSQL, edita a configuração do servidor (host `127.0.0.1`, porta `5432`, base `db_logistica`, utilizador `postgres`) e escreve a palavra-passe.
6. Clica em **Deploy** (o botão fica cinzento quando não há alterações por publicar).

## 5. Como executar

1. Abre `job_frotas_simples.kjb` no Spoon.
2. Garante que o PostgreSQL e o smtp4dev estão a correr.
3. Clica em **Run**.
4. Verifica os resultados:
   - pastas `staging/` e `saida/`;
   - tabelas na base de dados (`sql/consultas.sql`);
   - email recebido no smtp4dev;
   - dashboard em `http://localhost:1880/ui`.

Também pode ser executado pela linha de comandos: `kitchen /file:job_frotas_simples.kjb /level:Basic`.

## 6. Fluxo do job

```
START → T1 → T2 → T3 → T4 → Criar tabelas BD → T5 → Apagar relatorio.html
      → T6 → XSL (HTML) → T7 → Email de sucesso → Sucesso

(qualquer passo falha) → Email de erro → Abortar job
```

| Etapa | O que faz |
|---|---|
| **T1** | Lê o CSV. Ordena e remove duplicados por `id_motorista`, normaliza o texto, rejeita nomes vazios e valida a matrícula com a regex `^[0-9]{2}-[A-Z]{2}-[0-9]{2}$`. Grava `staging/motoristas_limpos.csv` e `saida/rejeitados_motoristas.csv`. |
| **T2** | Lê o XML das viaturas (loop `/frota/viatura`) e junta-o aos motoristas com um *Stream lookup* por matrícula. Grava `staging/motoristas_viaturas.csv`. |
| **T3** | Lê o JSON. Valida veículo, velocidade (nula, negativa ou acima de 200 km/h), combustível (até 100%) e formato do instante (regex). Remove duplicados, associa o motorista (lookup), gera alertas (velocidade acima de 50 km/h) em CSV e JSON, e um resumo por veículo (*Group by*). |
| **T4** | Faz um pedido GET à API Open-Meteo (Braga) e grava `saida/meteo_braga.csv`. |
| **T5** | Carrega os resultados nas tabelas PostgreSQL com *Table output*. |
| **T6 / XSL / T7** | Converte o resumo para XML, gera um relatório HTML com `relatorio.xsl` e guarda-o na variável `html_body`, usada como corpo do email. |

## 7. Base de dados

| Tabela | Conteúdo | Carga |
|---|---|---|
| `motorista_viatura` | motoristas válidos com a sua viatura | truncate + insert |
| `alerta_velocidade` | leituras acima de 50 km/h | truncate + insert |
| `resumo_veiculo` | leituras, velocidade média e máxima, combustível mínimo por veículo | truncate + insert |
| `meteo` | meteorologia atual (uma linha por execução) | acumula histórico |

Para gerar o backup (guardar em `database/`):
```
pg_dump -U postgres db_logistica > db_logistica_backup.sql
```

## 8. Resultados esperados (primeira execução)

| Etapa | Resultado |
|---|---|
| T1 | 20 linhas → 19 únicas → **15 válidas**, 4 rejeitadas |
| T2 | 17 viaturas no XML; os 15 motoristas válidos têm viatura |
| T3 | 60 leituras → 7 rejeitadas na validação → 53 → 1 duplicada → 52 → **45 com motorista** (7 sem motorista) |
| T3 | **16 alertas** de velocidade e resumo de **15 veículos** |
| T4 | 1 linha com a meteorologia atual |
| BD | `motorista_viatura` 15 · `alerta_velocidade` 16 · `resumo_veiculo` 15 · `meteo` 1 por execução |

## 9. Dashboard Node-RED

O dashboard (`http://localhost:1880/ui`) lê a base de dados de 10 em 10 segundos e mostra:
- número de veículos, motoristas e alertas;
- gráfico de barras com a velocidade máxima por veículo;
- tabela dos 20 maiores alertas;
- temperatura e vento atuais (API Open-Meteo).

O dashboard não executa o ETL: mostra os dados da última execução do job.

## 10. Qualidade dos dados

Os dados de entrada têm problemas propositados, tratados e registados em `saida/`:
- motoristas duplicados, nomes vazios e matrículas inválidas;
- telemetria com veículo ou velocidade nulos, velocidade negativa ou de 300 km/h, combustível acima de 100% e instantes inválidos (`2026-13-40T99:00:00Z`, `09/10/2026 17:45`);
- leituras repetidas e leituras de veículos sem motorista válido.

Os registos inválidos ficam em `saida/rejeitados_*.csv`, para auditoria.

## 11. Resolução de problemas

| Problema | Causa provável |
|---|---|
| T4 falha | Sem ligação à Internet ou API indisponível |
| Erro de ligação à BD | PostgreSQL parado, base inexistente ou palavra-passe errada na ligação `postgresSQL` |
| Não chega email | smtp4dev parado ou porta diferente nas entradas *Mail* |
| Node-RED mostra "missing node types" | Falta instalar `node-red-node-ui-table`, `node-red-dashboard` ou `node-red-contrib-postgresql` |
| Dashboard vazio | O job ainda não correu ou as tabelas estão vazias |

## 12. Limitações e trabalhos futuros

- Não há anonimização do nome dos motoristas.
- A carta de condução não é validada.
- O `config_zonas.yaml` não é usado: o limite de 50 km/h é único.
- A telemetria vem de um ficheiro estático e não de um fluxo em tempo real (MQTT/Node-RED).
- A meteorologia é uma consulta única e não está ligada às coordenadas de cada veículo.
- Possível extensão: transferência SFTP e botão no dashboard para executar o job.

## 13. Tecnologias

Pentaho Data Integration 10.2 · PostgreSQL · Node-RED (node-red-dashboard) · XSLT · API Open-Meteo · smtp4dev

## 14. Referências

- Pentaho Data Integration – https://help.hitachivantara.com/Documentation/Pentaho
- Open-Meteo – https://open-meteo.com/en/docs
- PostgreSQL – https://www.postgresql.org/docs/
- Node-RED – https://nodered.org/docs/
- smtp4dev – https://github.com/rnwood/smtp4dev
