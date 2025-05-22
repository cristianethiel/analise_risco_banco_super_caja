
# com os dados selecionados (agora em CTE) podemos calcular os pontos 

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
)

SELECT
  ds.id_cliente,
  ds.indicador_inadimplencia,
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
LIMIT 100;
