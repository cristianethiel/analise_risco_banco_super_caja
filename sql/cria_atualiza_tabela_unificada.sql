# tabela unificada COM SCORES

CREATE OR REPLACE TABLE `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar` AS

# CTEs

-- CTE 1: calcula quantidade de empréstimos por tipo
WITH qtd_tipos_emprestimo_por_cliente AS (
  SELECT
    user_id AS id_cliente, -- coluna para criar jo join final
    -- Funções de AGREGAÇÃO (COUNT)
    COUNT(CASE WHEN LOWER(loan_type) = 'real estate' OR LOWER(loan_type) = 'real_estate' THEN loan_id ELSE NULL END) AS qtd_emprestimos_real_estate, -- fazendo o tratamento do real state // existem clientes sem essas informações
    COUNT(CASE WHEN LOWER(loan_type) = 'other' OR LOWER(loan_type) = 'others' THEN loan_id ELSE NULL END) AS qtd_emprestimos_other -- fazendo o tratamento do other // existem clientes sem essas informações
  FROM
    `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`
  -- Cláusula de AGREGAÇÃO
  GROUP BY
    user_id
),

-- CTE 2: trata o campo debt_ratio com base nos salarios nulos
trata_taxa_endividamento AS (
  SELECT
    ui.user_id AS id_cliente,
    ui.last_month_salary,
    ld.debt_ratio,
    CASE
      WHEN ui.last_month_salary IS NULL OR ui.last_month_salary = 0 THEN NULL 
      ELSE ld.debt_ratio 
    END AS taxa_endividamento
FROM
    `laboratoria-projeto-03.projeto03_risco_credito.user_info` AS ui
    LEFT JOIN `laboratoria-projeto-03.projeto03_risco_credito.loans_detail` AS ld ON ui.user_id = ld.user_id
)

-- query principal que usa as CTEs
SELECT
  ui.user_id AS id_cliente,
  ui.age AS idade,
  ui.last_month_salary AS salario,
  COALESCE(ui.number_dependents, 0) AS numero_dependentes,
  CASE
    WHEN qte.qtd_emprestimos_real_estate IS NOT NULL THEN CAST(qte.qtd_emprestimos_real_estate AS STRING)
    ELSE 'não informado'
  END AS qtd_emprestimos_real_estate,
  CASE
    WHEN qte.qtd_emprestimos_other IS NOT NULL THEN CAST(qte.qtd_emprestimos_other AS STRING)
    ELSE 'não informado'
  END AS qtd_emprestimos_other,
  ld.number_times_delayed_payment_loan_30_59_days AS atrasos_30_59_dias,
  ld.number_times_delayed_payment_loan_60_89_days AS atrasos_60_89_dias,
  ld.more_90_days_overdue AS atrasos_acima_90_dias,
  ld.using_lines_not_secured_personal_assets AS uso_linha_credito,

  tte.taxa_endividamento,

  de.default_flag AS indicador_inadimplencia,

#faixascriadas

# faixa etaria
CASE
  WHEN ui.age BETWEEN 18 AND 25 THEN '18 a 25'
  WHEN ui.age BETWEEN 26 AND 35 THEN '26 a 35'
  WHEN ui.age BETWEEN 36 AND 45 THEN '36 a 45'
  WHEN ui.age BETWEEN 46 AND 60 THEN '46 a 60'
ELSE '60 ou mais'
END AS faixa_etaria,

# faixa salarial
CASE
  WHEN ui.last_month_salary IS NULL OR ui.last_month_salary = 0 THEN 'não informado'
  WHEN ui.last_month_salary <= 2000 THEN 'até 2.000'
  WHEN ui.last_month_salary > 2000 AND ui.last_month_salary <= 5000 THEN '2.000 - 5.000'
  WHEN ui.last_month_salary > 5000 AND ui.last_month_salary <= 10000 THEN '5.000 - 10.000'
  WHEN ui.last_month_salary > 10000 THEN '10.000 ou mais'
END AS faixa_salarial,

# dependentes
CASE
  WHEN ui.number_dependents = 0 OR ui.number_dependents IS NULL THEN '0'
  WHEN ui.number_dependents = 1 THEN '1'
  WHEN ui.number_dependents = 2 THEN '2'
  WHEN ui.number_dependents BETWEEN 3 AND 5 THEN '3 a 5'
  WHEN ui.number_dependents >= 6 THEN '6 ou mais'
END AS faixa_dependentes,

# faixa do uso de credito
CASE
  WHEN ld.using_lines_not_secured_personal_assets IS NULL THEN '6 - não informado'
  WHEN ld.using_lines_not_secured_personal_assets <= 0.029 THEN '1 - muito baixo (até 2.9%)'
  WHEN ld.using_lines_not_secured_personal_assets > 0.029 AND ld.using_lines_not_secured_personal_assets <= 0.149 THEN '2 - baixo (2.9% - 14.9%)'
  WHEN ld.using_lines_not_secured_personal_assets > 0.149 AND ld.using_lines_not_secured_personal_assets <= 0.548 THEN '3 - moderado (14.9%  -54.8%)'
  WHEN ld.using_lines_not_secured_personal_assets > 0.548 AND ld.using_lines_not_secured_personal_assets <= 1.327 THEN '4 - elevado (54.8% - 132.7%)'
  WHEN ld.using_lines_not_secured_personal_assets > 1.327 THEN '5 - extremo (> 132.7%)'
END AS faixa_uso_credito,

# faixa de endividamento
CASE
  WHEN tte.taxa_endividamento IS NULL THEN '7 - não informado'
  WHEN tte.taxa_endividamento <= 0.3 THEN '1 - baixo (≤ 30%)' -- Abaixo da Mediana
  WHEN tte.taxa_endividamento > 0.3 AND tte.taxa_endividamento <= 0.5 THEN '2 - moderado (30% - 50%)'  -- Em torno da Mediana
  WHEN tte.taxa_endividamento > 0.5 AND tte.taxa_endividamento <= 0.7 THEN '3 - elevado (50% - 70%)'   -- Acima da Mediana, abaixo do Q3
  WHEN tte.taxa_endividamento > 0.7 AND tte.taxa_endividamento <= 1.0 THEN '4 - muito elevado (70% - 100%)' -- Em torno do Q3 até o limite crítico de 100%
  WHEN tte.taxa_endividamento > 1.0 AND tte.taxa_endividamento <= 2.0 THEN '5 - superendividamento (100% - 200%)' -- Conforme análise exploratória
  WHEN tte.taxa_endividamento > 2.0 THEN '6 - casos extremos (>200%)' -- Conforme análise exploratória
END AS faixa_endividamento,

# faixa de atraso no pagamento
CASE
  WHEN ld.number_times_delayed_payment_loan_30_59_days = 0 THEN 'sem atraso'
  WHEN ld.number_times_delayed_payment_loan_30_59_days BETWEEN 1 AND 2 THEN 'baixo'
  WHEN ld.number_times_delayed_payment_loan_30_59_days BETWEEN 3 AND 5 THEN 'moderado'
  WHEN ld.number_times_delayed_payment_loan_30_59_days BETWEEN 6 AND 10 THEN 'elevado'
  WHEN ld.number_times_delayed_payment_loan_30_59_days > 10 THEN 'extremo'
END AS faixa_atraso_pagamento,

# status da inadimplencia
CASE WHEN de.default_flag = 1 THEN 'sim' ELSE 'não'
END AS status_inadimplencia,

# historico nos atrasos
CASE
  WHEN ld.number_times_delayed_payment_loan_30_59_days > 0 OR ld.number_times_delayed_payment_loan_60_89_days > 0 OR ld.more_90_days_overdue > 0 THEN 'sim'
  ELSE 'não'
END AS historico_atrasos,

# tempo de atraso do cliente
CASE
  WHEN ld.more_90_days_overdue > 0 THEN 'acima de 90'
  WHEN ld.number_times_delayed_payment_loan_60_89_days > 0 THEN 'entre 60 e 89'
  WHEN ld.number_times_delayed_payment_loan_30_59_days > 0 THEN 'entre 30 e 59'
  ELSE 'não atrasou'
END AS faixa_atraso_atingida,

###########################
-- NOVAS COLUNAS PARA CRIAÇÃO DE QUARTIS
NTILE(4) OVER (ORDER BY ui.age) AS quartil_idade, -- no dash devo manter minhas faixas
NTILE(10) OVER (ORDER BY CASE WHEN ui.last_month_salary > 0 THEN ui.last_month_salary ELSE NULL END) AS decil_salario,
NTILE(4) OVER (ORDER BY COALESCE(ui.number_dependents, 0)) AS quartil_dependentes, -- provável que mantenha minhas faixas
NTILE(4) OVER (ORDER BY ld.using_lines_not_secured_personal_assets) AS quartil_uso_credito,
NTILE(4) OVER (ORDER BY tte.taxa_endividamento) AS quartil_taxa_endividamento,

###########################
-- SISTEMA DE SCORING E PREVISÃO (NOVAS COLUNAS ADICIONADAS)
-- Pontuação de risco baseada em:
-- 1 ponto: Idade no 1º quartil (mais jovens)
-- 1 ponto: Salário no 4º decil (mais baixos)
-- 1 ponto: Dependentes no 4º quartil (mais dependentes)
-- 1 ponto: Uso de crédito no 4º quartil (mais uso)
-- 1 ponto: Taxa endividamento no 4º quartil (mais endividados)
-- 1 ponto: Histórico de atrasos (sim)
(
  (CASE WHEN NTILE(4) OVER (ORDER BY ui.age) = 1 THEN 1 ELSE 0 END) +
  (CASE WHEN NTILE(10) OVER (ORDER BY CASE WHEN ui.last_month_salary > 0 THEN ui.last_month_salary ELSE NULL END) = 4 THEN 1 ELSE 0 END) +
  (CASE WHEN NTILE(4) OVER (ORDER BY COALESCE(ui.number_dependents, 0)) = 4 THEN 1 ELSE 0 END) +
  (CASE WHEN NTILE(4) OVER (ORDER BY ld.using_lines_not_secured_personal_assets) = 4 THEN 1 ELSE 0 END) +
  (CASE WHEN NTILE(4) OVER (ORDER BY tte.taxa_endividamento) = 4 THEN 1 ELSE 0 END) +
  (CASE WHEN (CASE WHEN ld.number_times_delayed_payment_loan_30_59_days > 0 OR ld.number_times_delayed_payment_loan_60_89_days > 0 OR ld.more_90_days_overdue > 0 THEN 'sim' ELSE 'não' END) = 'sim' THEN 1 ELSE 0 END)
) AS pontuacao_risco,

-- Previsão de inadimplência (baseado na pontuação >= 3)
CASE
  WHEN (
    (CASE WHEN NTILE(4) OVER (ORDER BY ui.age) = 1 THEN 1 ELSE 0 END) +
    (CASE WHEN NTILE(10) OVER (ORDER BY CASE WHEN ui.last_month_salary > 0 THEN ui.last_month_salary ELSE NULL END) = 4 THEN 1 ELSE 0 END) +
    (CASE WHEN NTILE(4) OVER (ORDER BY COALESCE(ui.number_dependents, 0)) = 4 THEN 1 ELSE 0 END) +
    (CASE WHEN NTILE(4) OVER (ORDER BY ld.using_lines_not_secured_personal_assets) = 4 THEN 1 ELSE 0 END) +
    (CASE WHEN NTILE(4) OVER (ORDER BY tte.taxa_endividamento) = 4 THEN 1 ELSE 0 END) +
    (CASE WHEN (CASE WHEN ld.number_times_delayed_payment_loan_30_59_days > 0 OR ld.number_times_delayed_payment_loan_60_89_days > 0 OR ld.more_90_days_overdue > 0 THEN 'sim' ELSE 'não' END) = 'sim' THEN 1 ELSE 0 END)
  ) >= 3 THEN 1 -- Ponto de corte para considerar risco alto
  ELSE 0
END AS previsao_inadimplencia

FROM
  `laboratoria-projeto-03.projeto03_risco_credito.user_info` AS ui
  LEFT JOIN `laboratoria-projeto-03.projeto03_risco_credito.loans_detail` AS ld ON (ui.user_id = ld.user_id)
  LEFT JOIN `laboratoria-projeto-03.projeto03_risco_credito.default` AS de ON (ui.user_id = de.user_id)
  LEFT JOIN qtd_tipos_emprestimo_por_cliente AS qte ON (ui.user_id = qte.id_cliente)
  LEFT JOIN trata_taxa_endividamento AS tte ON (ui.user_id = tte.id_cliente);