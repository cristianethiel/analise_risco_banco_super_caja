

-- Quantos clientes únicos têm empréstimos?
SELECT COUNT(DISTINCT user_id) AS distinct_users_in_loans_outstanding
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`;

-- Quantos clientes únicos na user_info?
SELECT COUNT(DISTINCT user_id) AS distinct_users_in_user_info
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

-- Quantos clientes únicos na loans_detail?
SELECT COUNT(DISTINCT user_id) AS distinct_users_in_loans_detail
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

-- Quantos clientes únicos na default?
SELECT COUNT(DISTINCT user_id) AS distinct_users_in_default
FROM `laboratoria-projeto-03.projeto03_risco_credito.default`;

-- # quantos clientes?
SELECT
  COUNT (DISTINCT user_id) AS total_clientes
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

-- # quantos emprestimos?
SELECT
  COUNT (DISTINCT loan_id) AS total_emprestimos
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`;


-- # default
SELECT
  COUNTIF(default_flag IS NULL) AS default_flag_nulos
FROM `laboratoria-projeto-03.projeto03_risco_credito.default`;

-- # loans_detail
SELECT
  COUNTIF(more_90_days_overdue IS NULL) AS more_90_days_overdue_nulos,
  COUNTIF(using_lines_not_secured_personal_assets IS NULL) AS using_lines_not_secured_personal_assets_nulos,
  COUNTIF(number_times_delayed_payment_loan_30_59_days IS NULL) AS number_times_delayed_payment_loan_30_59_days_nulos,
  COUNTIF(debt_ratio IS NULL) AS debt_ratio_nulos,
  COUNTIF(number_times_delayed_payment_loan_60_89_days IS NULL) AS number_times_delayed_payment_loan_60_89_days_nulos
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

-- # loans_outstanding
SELECT
  COUNTIF(loan_id IS NULL) AS loan_id_nulos,
  COUNTIF(loan_type IS NULL) AS loan_type_nulos
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`;

-- # user_info
SELECT
  COUNTIF(age IS NULL) AS age_nulos,
  COUNTIF(sex IS NULL) AS sex_nulos,
  COUNTIF(last_month_salary IS NULL) AS last_month_salary_nulos,
  COUNTIF(number_dependents IS NULL) AS number_dependents_nulos
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

SELECT
  COUNTIF(number_dependents = 0) AS dependentes_zero,
  COUNTIF(number_dependents IS NULL) AS dependentes_nulo
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

-- # colunas com nulos são last_month_salary (7199) e number_dependents (943)

-- # verificar se os clientes com salario null são inadimplentes ou não
SELECT
  SUM(CASE WHEN de.default_flag = 1 THEN 1 ELSE 0 END) AS inadimplentes_salario_nulo,
  SUM(CASE WHEN de.default_flag = 0 THEN 1 ELSE 0 END) AS adimplentes_salario_nulo
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info` AS ui
LEFT JOIN `laboratoria-projeto-03.projeto03_risco_credito.default` AS de
  ON ui.user_id = de.user_id
WHERE
  ui.last_month_salary IS NULL;

-- # inadimplentes 130 e adimplentes 7069
-- # 98% são adimplentes, não faz sentido excluir as linhas
-- # vou tratar os nulos com a mediana dos salarios

-- # mediana dos salarios
-- # bigquery não tem MEDIAN
-- # vou usar PERCENTILE_CONT(coluna, 0.5) (o 0.5 representa 50%, ou seja, a mediana)
-- # No BigQuery, a função PERCENTILE_CONT() só funciona dentro de um OVER()
-- # Ele entende o PERCENTILE_CONT() como uma window function — não como uma função de agregação tipo SUM(), AVG(), COUNT()
SELECT
  DISTINCT PERCENTILE_CONT(last_month_salary, 0.5) OVER() AS mediana_salario
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;
-- # a mediana é 5400

-- # verificar se tem salarios com 0
SELECT
  COUNT(last_month_salary) AS count_salario_zero
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
WHERE last_month_salary = 0;
-- # 378 salários com 0 - pode ser sem renda ou sem declaração de renda, vou manter assim

-- # para tratar os valores nulos - usar depois no join final (Exemplo de como seria feito)
SELECT
  user_id,
  COALESCE(ui.last_month_salary, 5400) AS last_month_salary_tratado -- # trata os nulos com a mediana
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info` AS ui;


-- # DUPLICADAS


-- # default
SELECT
  user_id,
  default_flag,
  COUNT(*) AS duplicados -- # conta essa combinação
FROM
  `laboratoria-projeto-03.projeto03_risco_credito.default`
GROUP BY
  user_id,
  default_flag -- # agrupa na ordem das colunas
HAVING
  COUNT(*) > 1 -- # verifica o duplicado
ORDER BY
  duplicados DESC;

-- # loans_detail
SELECT
  user_id,
  more_90_days_overdue,
  using_lines_not_secured_personal_assets,
  number_times_delayed_payment_loan_30_59_days,
  debt_ratio,
  number_times_delayed_payment_loan_60_89_days,
  COUNT (*) AS duplicados
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`
GROUP BY
  user_id,
  more_90_days_overdue,
  using_lines_not_secured_personal_assets,
  number_times_delayed_payment_loan_30_59_days,
  debt_ratio,
  number_times_delayed_payment_loan_60_89_days
HAVING COUNT (*) > 1
ORDER BY duplicados DESC;

-- # loans_outstanding
SELECT
  loan_id,
  user_id,
  loan_type,
  COUNT (*) AS duplicados
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`
GROUP BY
  loan_id,
  user_id,
  loan_type
HAVING COUNT (*) > 1
ORDER BY duplicados DESC;

-- # user_info
SELECT
  user_id,
  age,
  sex,
  last_month_salary,
  number_dependents,
  COUNT (*) AS duplicados
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
GROUP BY
  user_id,
  age,
  sex,
  last_month_salary,
  number_dependents
HAVING COUNT (*) > 1
ORDER BY duplicados DESC;

-- # ANÁLISE DE CORRELAÇÃO E CONSISTÊNCIA DE VARIÁVEIS

-- # analisar a correlação para escolher as variáveis mais representativas

SELECT
  CORR(more_90_days_overdue, number_times_delayed_payment_loan_30_59_days) AS corr_overdue90_delayed30_59
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

SELECT
  CORR(more_90_days_overdue, number_times_delayed_payment_loan_60_89_days) AS corr_overdue90_delayed60_89
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

SELECT
  CORR(number_times_delayed_payment_loan_30_59_days, number_times_delayed_payment_loan_60_89_days) AS corr_delayed30_59_delayed60_89
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

-- # verificando se existem informações consistentes

SELECT
  COUNTIF(more_90_days_overdue > 0) AS overdue90_maior_que_zero,
  COUNTIF(more_90_days_overdue = 0) AS overdue90_igual_a_zero
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

SELECT
  COUNTIF(number_times_delayed_payment_loan_60_89_days > 0) AS delayed60_89_maior_que_zero,
  COUNTIF(number_times_delayed_payment_loan_60_89_days = 0) AS delayed60_89_igual_a_zero
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

-- # Para ajudar a tomar a decisão de qual dessas duas variáveis ​​manter para o modelo, podemos usar o desvio padrão
SELECT
  STDDEV(more_90_days_overdue) AS stddev_overdue90
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;
-- # 4.12136466842672

SELECT
  STDDEV(number_times_delayed_payment_loan_60_89_days) AS stddev_delayed60_89
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;
-- # 4.1055147551019706

SELECT
  STDDEV(number_times_delayed_payment_loan_30_59_days) AS stddev_delayed30_59
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;
-- # 4.144020438225871



-- # PADRONIZAÇÃO E ANÁLISE DE LOAN_TYPE


-- # analisando variável loan_type, quantos diferentes
SELECT
  COUNT (DISTINCT loan_type) AS distinct_loan_types_original
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`;

SELECT
  DISTINCT loan_type
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`;

-- # corrigindo  REAL ESTATE e Real Estate para real estate
-- # corrigindo OTHER, Other, others para other
-- # Opção 1: Usando CASE WHEN para padronização
WITH loans_type_standardized_v1 AS (
  SELECT
    loan_id,
    user_id,
    CASE
      WHEN loan_type = 'REAL ESTATE' THEN 'real estate'
      WHEN loan_type = 'Real Estate' THEN 'real estate'
      WHEN loan_type = 'OTHER' THEN 'other'
      WHEN loan_type = 'Other' THEN 'other'
      WHEN loan_type = 'others' THEN 'other'
      ELSE loan_type
    END AS loan_type_padronizado
  FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`
)
SELECT
  loan_type_padronizado,
  COUNT(*) AS qtd_por_tipo
FROM loans_type_standardized_v1
GROUP BY loan_type_padronizado
ORDER BY loan_type_padronizado;

-- # Contar distintos após padronização v1
WITH loans_type_standardized_v1 AS (
  SELECT
    CASE
      WHEN loan_type = 'REAL ESTATE' THEN 'real estate'
      WHEN loan_type = 'Real Estate' THEN 'real estate'
      WHEN loan_type = 'OTHER' THEN 'other'
      WHEN loan_type = 'Other' THEN 'other'
      WHEN loan_type = 'others' THEN 'other'
      ELSE loan_type
    END AS loan_type_padronizado
  FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`
)
SELECT
  COUNT(DISTINCT loan_type_padronizado) AS distinct_loan_types_padronizado_v1
FROM loans_type_standardized_v1;


-- # Opção 2: Usando LOWER()
SELECT
  DISTINCT LOWER (loan_type) AS loan_type_lower
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`;


-- # Opção 3: Usando LOWER() e CASE WHEN para 'others' (mais robusto)
WITH loans_type_standardized_v2 AS (
  SELECT
    loan_id,
    user_id,
    CASE
      WHEN LOWER(loan_type) = 'others' THEN 'other'
      ELSE LOWER(loan_type)
    END AS loan_type_padronizado
  FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`
)
SELECT
  loan_type_padronizado,
  COUNT(*) AS qtd_por_tipo
FROM loans_type_standardized_v2
GROUP BY loan_type_padronizado
ORDER BY loan_type_padronizado;

-- # Contar distintos após padronização v2
WITH loans_type_standardized_v2 AS (
  SELECT
    CASE
      WHEN LOWER(loan_type) = 'others' THEN 'other'
      ELSE LOWER(loan_type)
    END AS loan_type_padronizado
  FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`
)
SELECT
  COUNT(DISTINCT loan_type_padronizado) AS distinct_loan_types_padronizado_v2
FROM loans_type_standardized_v2;


-- # ANÁLISE DE OUTLIERS (ESTATÍSTICAS DESCRITIVAS E QUARTIS)

-- # Estatísticas descritivas (antes do tratamento de outliers):

# VERIFICANDO ERROS DE DIGITAÇÃO

SELECT
  number_dependents,
  COUNT (number_dependents)
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
GROUP BY number_dependents;

SELECT
  number_times_delayed_payment_loan_30_59_days,
  COUNT (number_times_delayed_payment_loan_30_59_days)
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`
GROUP BY number_times_delayed_payment_loan_30_59_days;

SELECT
  number_times_delayed_payment_loan_60_89_days,
  COUNT (number_times_delayed_payment_loan_60_89_days)
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`
GROUP BY number_times_delayed_payment_loan_60_89_days;

SELECT
  more_90_days_overdue,
  COUNT (more_90_days_overdue)
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`
GROUP BY more_90_days_overdue;

SELECT
  using_lines_not_secured_personal_assets
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`
ORDER BY using_lines_not_secured_personal_assets DESC
LIMIT 10;

SELECT
  last_month_salary
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
ORDER BY last_month_salary DESC
LIMIT 10;

-- ## Idade (age)
SELECT
  MIN(age) AS minimo_age,
  MAX(age) AS maximo_age,
  AVG(age) AS media_age,
  STDDEV(age) AS desvio_padrao_age
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

SELECT DISTINCT
  PERCENTILE_CONT(age, 0.5) OVER() AS mediana_age
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

WITH quartis_age AS (
  SELECT
    DISTINCT -- Para obter apenas uma linha de resultado
    PERCENTILE_CONT(age, 0.25) OVER() AS Q1,
    PERCENTILE_CONT(age, 0.5) OVER() AS Q2_mediana,
    PERCENTILE_CONT(age, 0.75) OVER() AS Q3
  FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
)
SELECT
  Q1,
  Q2_mediana,
  Q3,
  (Q3 - Q1) AS IQR,
  (Q1 - 1.5 * (Q3 - Q1)) AS limite_inferior_age,
  (Q3 + 1.5 * (Q3 - Q1)) AS limite_superior_age
FROM quartis_age;

SELECT
  *
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
WHERE age > 96; -- Limite superior calculado anteriormente


-- ## Salário (last_month_salary)
SELECT
  MIN(last_month_salary) AS minimo_salary,
  MAX(last_month_salary) AS maximo_salary,
  AVG(last_month_salary) AS media_salary,
  STDDEV(last_month_salary) AS desvio_padrao_salary
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

SELECT DISTINCT
  PERCENTILE_CONT(last_month_salary, 0.5) OVER() AS mediana_salary
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

WITH quartis_salario AS (
  SELECT
    DISTINCT
    PERCENTILE_CONT(last_month_salary, 0.25) OVER() AS Q1,
    PERCENTILE_CONT(last_month_salary, 0.5) OVER() AS Q2_mediana,
    PERCENTILE_CONT(last_month_salary, 0.75) OVER() AS Q3
  FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
  WHERE last_month_salary IS NOT NULL -- Importante para quartis
)
SELECT
  Q1,
  Q2_mediana,
  Q3,
  (Q3 - Q1) AS IQR,
  (Q1 - 1.5 * (Q3 - Q1)) AS limite_inferior_salary,
  (Q3 + 1.5 * (Q3 - Q1)) AS limite_superior_salary
FROM quartis_salario;



-- # analisando as idades com salarios 0
SELECT
 MAX(age) AS max_age_salario_zero,
 MIN(age) AS min_age_salario_zero
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
WHERE last_month_salary = 0;

SELECT
  last_month_salary
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
ORDER BY last_month_salary DESC
LIMIT 10;

-- # quantos têm salário acima de 15.650 (valor do limite superior calculado)
SELECT
  COUNTIF (last_month_salary > 15650) AS count_salary_acima_lim_superior
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

-- # quantos têm salário 0 e nulos
SELECT
  COUNTIF (last_month_salary < 1) AS salario_zero, -- Assumindo 0 como salario_zero
  COUNTIF (last_month_salary IS NULL) AS salario_nulo
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

-- # Detalhes de usuários com salário > 15650
SELECT
  ui.age,
  ui.number_dependents,
  cl.debt_ratio,
  cl.using_lines_not_secured_personal_assets,
  cl.number_times_delayed_payment_loan_30_59_days,
  ui.last_month_salary
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info` AS ui
LEFT JOIN `laboratoria-projeto-03.projeto03_risco_credito.loans_detail` AS cl
  ON ui.user_id = cl.user_id
WHERE ui.last_month_salary > 15650 -- Limite superior calculado anteriormente
ORDER BY ui.last_month_salary DESC
LIMIT 20;


-- ## Dependentes (number_dependents)
SELECT
  MIN(number_dependents) AS minimo_dependents,
  MAX(number_dependents) AS maximo_dependents,
  AVG(number_dependents) AS media_dependents,
  STDDEV(number_dependents) AS desvio_padrao_dependents
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

SELECT DISTINCT
  PERCENTILE_CONT(number_dependents, 0.5) OVER() AS mediana_dependents
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`;

WITH quartis_dependentes AS (
  SELECT
    DISTINCT
    PERCENTILE_CONT(number_dependents, 0.25) OVER() AS Q1,
    PERCENTILE_CONT(number_dependents, 0.5) OVER() AS Q2_mediana,
    PERCENTILE_CONT(number_dependents, 0.75) OVER() AS Q3
  FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
  WHERE number_dependents IS NOT NULL -- Importante para quartis
)
SELECT
  Q1,
  Q2_mediana,
  Q3,
  (Q3 - Q1) AS IQR,
  (Q1 - 1.5 * (Q3 - Q1)) AS limite_inferior_dependents,
  (Q3 + 1.5 * (Q3 - Q1)) AS limite_superior_dependents
FROM quartis_dependentes;

SELECT
 *
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
WHERE
  number_dependents > 3 -- Limite superior calculado anteriormente
ORDER BY number_dependents DESC;

SELECT
  number_dependents,
  COUNT(*) AS conta_registros
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`
WHERE number_dependents > 3 -- Limite superior calculado anteriormente
GROUP BY number_dependents
ORDER BY number_dependents DESC;


-- ## Uso do crédito (using_lines_not_secured_personal_assets)
SELECT
  MIN(using_lines_not_secured_personal_assets) AS minimo_uso_credito,
  MAX(using_lines_not_secured_personal_assets) AS maximo_uso_credito,
  AVG(using_lines_not_secured_personal_assets) AS media_uso_credito,
  STDDEV(using_lines_not_secured_personal_assets) AS desvio_padrao_uso_credito
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

SELECT DISTINCT
  PERCENTILE_CONT(using_lines_not_secured_personal_assets, 0.5) OVER() AS mediana_uso_credito
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

WITH quartis_uso_credito AS (
  SELECT
    DISTINCT
    PERCENTILE_CONT(using_lines_not_secured_personal_assets, 0.25) OVER() AS Q1,
    PERCENTILE_CONT(using_lines_not_secured_personal_assets, 0.5) OVER() AS Q2_mediana,
    PERCENTILE_CONT(using_lines_not_secured_personal_assets, 0.75) OVER() AS Q3
  FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`
  WHERE using_lines_not_secured_personal_assets IS NOT NULL -- Importante para quartis
)
SELECT
  Q1,
  Q2_mediana,
  Q3,
  (Q3 - Q1) AS IQR,
  (Q1 - 1.5 * (Q3 - Q1)) AS limite_inferior_uso_credito,
  (Q3 + 1.5 * (Q3 - Q1)) AS limite_superior_uso_credito
FROM quartis_uso_credito;

SELECT DISTINCT
  using_lines_not_secured_personal_assets
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`
WHERE using_lines_not_secured_personal_assets > 1.327; -- Limite superior calculado anteriormente

SELECT
  using_lines_not_secured_personal_assets,
  COUNT(*) AS conta_registros
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`
WHERE using_lines_not_secured_personal_assets > 1.327 -- Limite superior calculado anteriormente
GROUP BY using_lines_not_secured_personal_assets
ORDER BY using_lines_not_secured_personal_assets DESC;


-- ## Taxa de endividamento (debt_ratio)
SELECT
  MIN(debt_ratio) AS minimo_debt_ratio,
  MAX(debt_ratio) AS maximo_debt_ratio,
  AVG(debt_ratio) AS media_debt_ratio,
  STDDEV(debt_ratio) AS desvio_padrao_debt_ratio
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

SELECT DISTINCT
  PERCENTILE_CONT(debt_ratio, 0.5) OVER() AS mediana_debt_ratio
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

WITH quartis_endividamento AS (
  SELECT
    DISTINCT
    PERCENTILE_CONT(debt_ratio, 0.25) OVER() AS Q1,
    PERCENTILE_CONT(debt_ratio, 0.5) OVER() AS Q2_mediana,
    PERCENTILE_CONT(debt_ratio, 0.75) OVER() AS Q3
  FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`
  WHERE debt_ratio IS NOT NULL -- Importante para quartis
)
SELECT
  Q1,
  Q2_mediana,
  Q3,
  (Q3 - Q1) AS IQR,
  (Q1 - 1.5 * (Q3 - Q1)) AS limite_inferior_debt_ratio,
  (Q3 + 1.5 * (Q3 - Q1)) AS limite_superior_debt_ratio
FROM quartis_endividamento;

SELECT
  debt_ratio
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`
WHERE
  debt_ratio > 1.919 -- Limite superior calculado anteriormente
ORDER BY debt_ratio DESC;


-- ## Atrasos no pagamento (number_times_delayed_payment_loan_30_59_days)
SELECT
  MIN(number_times_delayed_payment_loan_30_59_days) AS minimo_atrasos_30_59,
  MAX(number_times_delayed_payment_loan_30_59_days) AS maximo_atrasos_30_59,
  AVG(number_times_delayed_payment_loan_30_59_days) AS media_atrasos_30_59,
  STDDEV(number_times_delayed_payment_loan_30_59_days) AS desvio_padrao_atrasos_30_59
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

SELECT DISTINCT
  PERCENTILE_CONT(number_times_delayed_payment_loan_30_59_days, 0.5) OVER() AS mediana_atrasos_30_59
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`;

WITH quartis_atrasos_30_59 AS (
  SELECT
    DISTINCT
    PERCENTILE_CONT(number_times_delayed_payment_loan_30_59_days, 0.25) OVER() AS Q1,
    PERCENTILE_CONT(number_times_delayed_payment_loan_30_59_days, 0.5) OVER() AS Q2_mediana,
    PERCENTILE_CONT(number_times_delayed_payment_loan_30_59_days, 0.75) OVER() AS Q3
  FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_detail`
  WHERE number_times_delayed_payment_loan_30_59_days IS NOT NULL -- Importante para quartis
)
SELECT
  Q1,
  Q2_mediana,
  Q3,
  (Q3 - Q1) AS IQR,
  (Q1 - 1.5 * (Q3 - Q1)) AS limite_inferior_atrasos_30_59,
  (Q3 + 1.5 * (Q3 - Q1)) AS limite_superior_atrasos_30_59
FROM quartis_atrasos_30_59;


-- # CONSULTAS AGREGADAS E COMBINADAS

-- # quantidade de emprestimos por cliente
SELECT
  user_id,
  COUNT (loan_id) AS total_loan_id_por_cliente
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`
GROUP BY user_id;

-- # quantidade de emprestimos por tipo para cada cliente
WITH loans_type_standardized AS (
  SELECT
    loan_id,
    user_id,
    CASE
      WHEN LOWER(loan_type) = 'others' THEN 'other'
      ELSE LOWER(loan_type)
    END AS loan_type_padronizado
  FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`
)
SELECT
    user_id,
    loan_type_padronizado,
    COUNT(loan_id) AS total_emprestimos_tipo_cliente
FROM
    loans_type_standardized
GROUP BY
    user_id, loan_type_padronizado;

-- # total de empréstimos e média de endividamento por cliente
SELECT
    lo.user_id,
    COUNT(lo.loan_id) AS total_emprestimos_cliente,
    AVG(ld.debt_ratio) AS media_endividamento_cliente
FROM
    `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding` lo
JOIN
    `laboratoria-projeto-03.projeto03_risco_credito.loans_detail` ld
ON
    lo.user_id = ld.user_id
GROUP BY
    lo.user_id;

-- # média de atrasos por tipo de empréstimo
-- # entre os clientes que atrasam, quais tipos de empréstimo eles costumam pegar
-- # qtd de cliente que pediu para tipo e qtd de emprestimos de cada tipo

WITH loans_type_standardized AS (
  SELECT
    user_id,
    loan_id,
    CASE
      WHEN LOWER(loan_type) = 'others' THEN 'other'
      ELSE LOWER(loan_type)
    END AS loan_type_padronizado
  FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`
)
SELECT
  lo.loan_type_padronizado,
  COUNT(DISTINCT lo.user_id) AS qtd_clientes_por_tipo,
  COUNT(lo.loan_id) AS qtd_emprestimos_por_tipo,
  AVG(ld.number_times_delayed_payment_loan_30_59_days) AS media_atrasos_30_59_dias_por_tipo
FROM loans_type_standardized lo
JOIN `laboratoria-projeto-03.projeto03_risco_credito.loans_detail` ld
  ON lo.user_id = ld.user_id
GROUP BY lo.loan_type_padronizado;

-- # para outros periodos de atraso
WITH loans_type_standardized AS (
  SELECT
    user_id,
    loan_id,
    CASE
      WHEN LOWER(loan_type) = 'others' THEN 'other'
      ELSE LOWER(loan_type)
    END AS loan_type_padronizado
  FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`
)
SELECT
  lo.loan_type_padronizado,
  COUNT(DISTINCT lo.user_id) AS qtd_clientes_por_tipo,
  COUNT(lo.loan_id) AS qtd_emprestimos_por_tipo,
  AVG(ld.more_90_days_overdue) AS media_atrasos_mais_90_dias_por_tipo
FROM loans_type_standardized lo
JOIN `laboratoria-projeto-03.projeto03_risco_credito.loans_detail` ld
  ON lo.user_id = ld.user_id
GROUP BY lo.loan_type_padronizado;

WITH loans_type_standardized AS (
  SELECT
    user_id,
    loan_id,
    CASE
      WHEN LOWER(loan_type) = 'others' THEN 'other'
      ELSE LOWER(loan_type)
    END AS loan_type_padronizado
  FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`
)
SELECT
  lo.loan_type_padronizado,
  COUNT(DISTINCT lo.user_id) AS qtd_clientes_por_tipo,
  COUNT(lo.loan_id) AS qtd_emprestimos_por_tipo,
  AVG(ld.number_times_delayed_payment_loan_60_89_days) AS media_atrasos_60_89_dias_por_tipo
FROM loans_type_standardized lo
JOIN `laboratoria-projeto-03.projeto03_risco_credito.loans_detail` ld
  ON lo.user_id = ld.user_id
GROUP BY lo.loan_type_padronizado;


# perfil dos clientes que nunca pediram emprestimo

WITH clientes_sem_emprestimo AS(
  
  SELECT
    ui.user_id,
    age,
    last_month_salary,
    number_dependents
  FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info` AS ui
    FULL JOIN `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`AS lo ON (ui.user_id = lo.user_id)
  WHERE 
    lo.loan_id IS NULL
),

mediana_idade AS (
  SELECT DISTINCT PERCENTILE_CONT(age, 0.5) OVER() AS mediana_idade
  FROM clientes_sem_emprestimo
),

mediana_salario AS (
  SELECT DISTINCT PERCENTILE_CONT(last_month_salary, 0.5) OVER() AS mediana_salario
  FROM clientes_sem_emprestimo
),

mediana_dependentes AS (
  SELECT DISTINCT PERCENTILE_CONT(number_dependents, 0.5) OVER() AS mediana_dependentes
  FROM clientes_sem_emprestimo
)

SELECT  
  MIN(age) AS min_idad,
  MAX(age) AS max_idade,
  AVG(age) AS media_idade,
  MIN(last_month_salary) AS min_salario,
  MAX(last_month_salary) AS max_salario,
  AVG(last_month_salary) AS media_salario,
  MIN(number_dependents) AS min_dependentes,
  MAX(number_dependents) AS max_dependentes,
  AVG(number_dependents) AS media_dependentes,
  (SELECT DISTINCT mediana_idade FROM mediana_idade) AS mediana_idade,
  (SELECT DISTINCT mediana_salario FROM mediana_salario) AS mediana_salario,
  (SELECT DISTINCT mediana_dependentes FROM mediana_dependentes) AS mediana_dependentes

FROM clientes_sem_emprestimo







