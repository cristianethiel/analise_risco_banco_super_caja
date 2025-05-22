CREATE OR REPLACE TABLE `laboratoria-projeto-03.projeto03_risco_credito.tabela_variavel_dummy` AS
SELECT
  id_cliente,
  default_flag,

  -- Dummies para quartil_idade 
  CASE WHEN quartil_idade = 1 THEN 1 ELSE 0 END AS dummy_idade_q1,
  CASE WHEN quartil_idade = 2 THEN 1 ELSE 0 END AS dummy_idade_q2,
  CASE WHEN quartil_idade = 3 THEN 1 ELSE 0 END AS dummy_idade_q3,
  CASE WHEN quartil_idade = 4 THEN 1 ELSE 0 END AS dummy_idade_q4,

  -- Dummies para decil_salario 
  -- Clientes com decil_salario NULL terão 0 em todas estas dummies de salário
  CASE WHEN decil_salario = 1 THEN 1 ELSE 0 END AS dummy_salario_d1,
  CASE WHEN decil_salario = 2 THEN 1 ELSE 0 END AS dummy_salario_d2,
  CASE WHEN decil_salario = 3 THEN 1 ELSE 0 END AS dummy_salario_d3,
  CASE WHEN decil_salario = 4 THEN 1 ELSE 0 END AS dummy_salario_d4,
  CASE WHEN decil_salario = 5 THEN 1 ELSE 0 END AS dummy_salario_d5,
  CASE WHEN decil_salario = 6 THEN 1 ELSE 0 END AS dummy_salario_d6,
  CASE WHEN decil_salario = 7 THEN 1 ELSE 0 END AS dummy_salario_d7,
  CASE WHEN decil_salario = 8 THEN 1 ELSE 0 END AS dummy_salario_d8,
  CASE WHEN decil_salario = 9 THEN 1 ELSE 0 END AS dummy_salario_d9,
  CASE WHEN decil_salario = 10 THEN 1 ELSE 0 END AS dummy_salario_d10,

  -- Dummies para quartil_dependentes
  CASE WHEN quartil_dependentes = 1 THEN 1 ELSE 0 END AS dummy_dependentes_q1,
  CASE WHEN quartil_dependentes = 2 THEN 1 ELSE 0 END AS dummy_dependentes_q2,
  CASE WHEN quartil_dependentes = 3 THEN 1 ELSE 0 END AS dummy_dependentes_q3,
  CASE WHEN quartil_dependentes = 4 THEN 1 ELSE 0 END AS dummy_dependentes_q4,

  -- Dummies para quartil_uso_credito
  CASE WHEN quartil_uso_credito = 1 THEN 1 ELSE 0 END AS dummy_uso_credito_q1,
  CASE WHEN quartil_uso_credito = 2 THEN 1 ELSE 0 END AS dummy_uso_credito_q2,
  CASE WHEN quartil_uso_credito = 3 THEN 1 ELSE 0 END AS dummy_uso_credito_q3,
  CASE WHEN quartil_uso_credito = 4 THEN 1 ELSE 0 END AS dummy_uso_credito_q4,

  -- Dummies para quartil_taxa_endividamento
  -- Clientes com quartil_taxa_endividamento NULL terão 0 em todas estas dummies de endividamento
  CASE WHEN quartil_taxa_endividamento = 1 THEN 1 ELSE 0 END AS dummy_endividamento_q1,
  CASE WHEN quartil_taxa_endividamento = 2 THEN 1 ELSE 0 END AS dummy_endividamento_q2,
  CASE WHEN quartil_taxa_endividamento = 3 THEN 1 ELSE 0 END AS dummy_endividamento_q3,
  CASE WHEN quartil_taxa_endividamento = 4 THEN 1 ELSE 0 END AS dummy_endividamento_q4,

  -- Dummies para historico_atrasos
  -- Assumindo que historico_atrasos pode ser 'sim', 'não', ou NULL (se as colunas base eram NULL)
  CASE WHEN historico_atrasos = 'sim' THEN 1 ELSE 0 END AS dummy_historico_atrasos_sim,
  CASE WHEN historico_atrasos = 'não' THEN 1 ELSE 0 END AS dummy_historico_atrasos_nao,
  -- Se historico_atrasos for NULL, ambas as dummies acima serão 0.


FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar` tua
  LEFT JOIN `laboratoria-projeto-03.projeto03_risco_credito.default`cd ON (cd.user_id = tua.id_cliente);