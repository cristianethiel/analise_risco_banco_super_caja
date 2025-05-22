-- Mostra o score e previsão para alguns clientes
WITH dados_para_score_base AS (
  SELECT
    tua.id_cliente,
    tua.indicador_inadimplencia,
    dar.dummy_idade_q1,
    dar.dummy_salario_d4,
    dar.dummy_dependentes_q4,
    dar.dummy_uso_credito_q4,
    dar.dummy_endividamento_q4,
    dar.dummy_historico_atrasos_sim
  FROM
    `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar` tua
  JOIN
    `laboratoria-projeto-03.projeto03_risco_credito.tabela_variavel_dummy` dar
    ON tua.id_cliente = dar.id_cliente
  WHERE
    tua.indicador_inadimplencia IS NOT NULL
),

score_por_cliente AS (
  SELECT
    ds.*,
    (
      ds.dummy_idade_q1 +
      ds.dummy_salario_d4 +
      ds.dummy_dependentes_q4 +
      ds.dummy_uso_credito_q4 +
      ds.dummy_endividamento_q4 +
      ds.dummy_historico_atrasos_sim
    ) AS pontuacao_risco
  FROM
    dados_para_score_base ds
),

previsao_por_cliente AS (
  SELECT
    spc.*,
    CASE
      WHEN spc.pontuacao_risco >= 4 THEN 1
      ELSE 0
    END AS previsao_inadimplencia
  FROM
    score_por_cliente spc
)

SELECT
  id_cliente,
  indicador_inadimplencia,
  pontuacao_risco,
  previsao_inadimplencia
FROM
  previsao_por_cliente
LIMIT 100;
