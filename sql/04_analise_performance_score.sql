
# essa é a primeira query - primeira etapa
# com os dados selecionados (CTE 1) e pontos calculados (CTE 2) podem os comparar previsão e realidade
# como a pontuação de risco se relaciona com a inadimplência real?
# agrupa os clientes pela pontuação e conta quantos tem em cada grupo
# quantos sao inadimplentes? qual a taxa de inadimplemntes?
# é a base para entender qual seria o melhor ponto de corte

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
)

SELECT
  pontuacao_risco,
  COUNT(DISTINCT id_cliente) AS total_clientes,
  SUM(indicador_inadimplencia) AS total_inadimplentes,
  ROUND(SAFE_DIVIDE(SUM(indicador_inadimplencia), COUNT(DISTINCT id_cliente)) * 100, 2) AS taxa_inadimplencia_real_perc
FROM
  score_por_cliente
GROUP BY
  pontuacao_risco
ORDER BY
  pontuacao_risco;
