
# quais serão os dados?

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
LIMIT 100;
