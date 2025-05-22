SELECT
  id_cliente
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE qtd_emprestimos_real_estate = '0' AND qtd_emprestimos_other = '0'
      OR qtd_emprestimos_real_estate = 'não informado' AND qtd_emprestimos_other = 'não informado';

SELECT  
  COUNT(DISTINCT user_id) 
FROM `laboratoria-projeto-03.projeto03_risco_credito.loans_outstanding`

SELECT  
  COUNT(DISTINCT user_id) 
FROM `laboratoria-projeto-03.projeto03_risco_credito.user_info`

SELECT 
  column_name, data_type 
FROM `laboratoria-projeto-03.projeto03_risco_credito.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'tabela_unificada_auxiliar';


# correlação

SELECT
  'idade_x_salario' AS variaveis_combinadas,
  CORR(idade, CASE WHEN salario > 0 THEN salario ELSE NULL END) AS coeficiente_correlacao -- exclui salários nulos/zeros
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`

UNION ALL

SELECT
  'idade_x_uso_linha_credito' AS par_variaveis,
  CORR(idade, uso_linha_credito) AS coeficiente_correlacao
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE uso_linha_credito IS NOT NULL -- exclui NULL

UNION ALL

SELECT
  'idade_x_taxa_endividamento' AS par_variaveis,
  CORR(idade, taxa_endividamento) AS coeficiente_correlacao 
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE taxa_endividamento IS NOT NULL

UNION ALL

SELECT
  'salario_x_uso_linha_credito' AS par_variaveis,
  CORR(CASE WHEN salario > 0 THEN salario ELSE NULL END, uso_linha_credito) AS coeficiente_correlacao
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE uso_linha_credito IS NOT NULL AND (salario > 0 OR salario IS NULL) 

UNION ALL

SELECT
  'salario_x_taxa_endividamento' AS par_variaveis,
  CORR(CASE WHEN salario > 0 THEN salario ELSE NULL END, taxa_endividamento) AS coeficiente_correlacao
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE taxa_endividamento IS NOT NULL AND (salario > 0 OR salario IS NULL)

UNION ALL

SELECT
  'uso_linha_credito_x_taxa_endividamento' AS par_variaveis,
  CORR(uso_linha_credito, taxa_endividamento) AS coeficiente_correlacao
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE uso_linha_credito IS NOT NULL AND taxa_endividamento IS NOT NULL

UNION ALL

SELECT
  'numero_dependentes_x_salario' AS par_variaveis,
  CORR(numero_dependentes, CASE WHEN salario > 0 THEN salario ELSE NULL END) AS coeficiente_correlacao
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE (salario > 0 OR salario IS NULL)
;

## verificar a inadimpência por tipo de empréstimo

-- Inadimplência para clientes com algum empréstimo Real Estate
SELECT
  'Real Estate' AS grupo,
  COUNT(DISTINCT CASE WHEN tua.indicador_inadimplencia = 1 THEN tua.id_cliente END) AS inadimplentes,
  COUNT(DISTINCT tua.id_cliente) AS total_clientes_no_grupo,
  ROUND(COUNT(DISTINCT CASE WHEN tua.indicador_inadimplencia = 1 THEN tua.id_cliente END) * 100.0 / COUNT(DISTINCT tua.id_cliente), 2) AS taxa_inadimplencia
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar` tua
WHERE tua.qtd_emprestimos_real_estate != '0' AND tua.qtd_emprestimos_real_estate != 'não informado'
GROUP BY 1

UNION ALL

-- Inadimplência para clientes com algum empréstimo Other
SELECT
  'Other' AS grupo,
  COUNT(DISTINCT CASE WHEN tua.indicador_inadimplencia = 1 THEN tua.id_cliente END) AS inadimplentes,
  COUNT(DISTINCT tua.id_cliente) AS total_clientes_no_grupo,
  ROUND(COUNT(DISTINCT CASE WHEN tua.indicador_inadimplencia = 1 THEN tua.id_cliente END) * 100.0 / COUNT(DISTINCT tua.id_cliente), 2) AS taxa_inadimplencia
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar` tua
WHERE tua.qtd_emprestimos_other != '0' AND tua.qtd_emprestimos_other != 'não informado'
GROUP BY 1;


# faixa etaria

SELECT
  faixa_etaria,
  COUNT(DISTINCT id_cliente) AS numero_clientes,
  ROUND(COUNT(DISTINCT id_cliente) * 100.0 /
  (SELECT COUNT(DISTINCT id_cliente)
    FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`), 2
  ) AS percentual_clientes
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
GROUP BY
  faixa_etaria
ORDER BY
  numero_clientes DESC;


SELECT 
  *
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE idade > 98;



# faixa salarial

SELECT
  faixa_salarial,
  COUNT(DISTINCT id_cliente) AS numero_clientes,
  ROUND(COUNT(DISTINCT id_cliente) * 100.0 /
  (SELECT COUNT(DISTINCT id_cliente)
    FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`), 2
  ) AS percentual_clientes
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
GROUP BY
  faixa_salarial
ORDER BY
  numero_clientes DESC;

# dependentes

SELECT
  faixa_dependentes,
  COUNT(DISTINCT id_cliente) AS numero_clientes,
  ROUND(COUNT(DISTINCT id_cliente) * 100.0 /
  (SELECT COUNT(DISTINCT id_cliente)
    FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`), 2
  ) AS percentual_clientes
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
GROUP BY
  faixa_dependentes
ORDER BY
  numero_clientes DESC;


SELECT
  faixa_etaria,
  COUNT(DISTINCT id_cliente) AS numero_clientes, -- Para confirmar a contagem de clientes na faixa
  AVG(uso_linha_credito) AS media_uso_linha_credito_decimal,
  AVG(uso_linha_credito) * 100 AS media_uso_linha_credito_percentual -- Para exibir como percentual
FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  uso_linha_credito IS NOT NULL -- Importante: calcular a média apenas sobre valores não nulos,
                                -- caso a coluna 'uso_linha_credito' possa ser NULL para alguns clientes
                                -- ANTES de ser categorizada na 'faixa_uso_credito'.
                                -- Se sua 'faixa_uso_credito' já trata nulos como 'não informado'
                                -- e você está usando a coluna numérica original 'uso_linha_credito'
                                -- que poderia ser NULL, esta cláusula WHERE é importante.
GROUP BY
  faixa_etaria
ORDER BY
  -- Opcional: para ordenar como na sua tabela do Looker
  CASE faixa_etaria
    WHEN '18 a 25' THEN 1
    WHEN '26 a 35' THEN 2
    WHEN '36 a 45' THEN 3
    WHEN '46 a 60' THEN 4
    WHEN '60 ou mais' THEN 5
    ELSE 6
  END;



SELECT
  faixa_etaria,
  COUNT(DISTINCT id_cliente) AS numero_clientes, -- Para contexto e validação
  AVG(taxa_endividamento) AS media_taxa_endividamento_decimal,
  AVG(taxa_endividamento) * 100 AS media_taxa_endividamento_percentual -- Para exibir como percentual
FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  taxa_endividamento IS NOT NULL -- Importante se a coluna original 'taxa_endividamento'
                                 -- (ld.debt_ratio) puder ser NULL para alguns clientes
                                 -- após o LEFT JOIN e antes da categorização na
                                 -- 'faixa_endividamento'. Se sua coluna 'taxa_endividamento'
                                 -- na tabela final nunca é NULL (porque você tratou ou
                                 -- confirmou que sempre há dados), pode omitir.
GROUP BY
  faixa_etaria
ORDER BY
  -- Opcional: para ordenar como na sua tabela do Looker
  CASE faixa_etaria
    WHEN '18 a 25' THEN 1
    WHEN '26 a 35' THEN 2
    WHEN '36 a 45' THEN 3
    WHEN '46 a 60' THEN 4
    WHEN '60 ou mais' THEN 5
    ELSE 6 -- Para qualquer outra categoria, como 'não informado' se existir para idade
  END;


  SELECT
  taxa_endividamento
FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  taxa_endividamento IS NOT NULL
ORDER BY
  taxa_endividamento DESC -- Veja os maiores valores
LIMIT 100;

SELECT
  taxa_endividamento
FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  taxa_endividamento IS NOT NULL
ORDER BY
  taxa_endividamento ASC -- Veja os menores valores (diferentes de zero)
LIMIT 100;

SELECT
  MIN(taxa_endividamento) as min_dti,
  APPROX_QUANTILES(taxa_endividamento, 100)[OFFSET(25)] AS q1_dti, -- Primeiro quartil
  APPROX_QUANTILES(taxa_endividamento, 100)[OFFSET(50)] AS mediana_dti, -- Mediana
  AVG(taxa_endividamento) as media_dti, -- Média (que você já tem)
  APPROX_QUANTILES(taxa_endividamento, 100)[OFFSET(75)] AS q3_dti, -- Terceiro quartil
  MAX(taxa_endividamento) as max_dti,
  COUNTIF(taxa_endividamento > 5) AS count_dti_maior_que_5 -- Conte quantos são muito altos
FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  taxa_endividamento IS NOT NULL;



SELECT
  MIN(taxa_endividamento) as min_dti_sal_nao_inf,
  APPROX_QUANTILES(taxa_endividamento, 100)[OFFSET(25)] AS q1_dti_sal_nao_inf,
  APPROX_QUANTILES(taxa_endividamento, 100)[OFFSET(50)] AS mediana_dti_sal_nao_inf,
  AVG(taxa_endividamento) as media_dti_sal_nao_inf,
  APPROX_QUANTILES(taxa_endividamento, 100)[OFFSET(75)] AS q3_dti_sal_nao_inf,
  MAX(taxa_endividamento) as max_dti_sal_nao_inf,
  COUNTIF(taxa_endividamento > 5) AS count_dti_maior_que_5_sal_nao_inf,
  COUNT(*) AS total_clientes_sal_nao_inf
FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  faixa_salarial = 'não informado' AND taxa_endividamento IS NOT NULL;



SELECT
  faixa_salarial, -- Para focar no grupo 'não informado'
  status_inadimplencia, -- Ou use indicador_inadimplencia (0 ou 1)
  COUNT(DISTINCT id_cliente) AS numero_clientes,
  ROUND(COUNT(DISTINCT id_cliente) * 100.0 / (
    SELECT COUNT(DISTINCT id_cliente)
    FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
    WHERE faixa_salarial = 'não informado' -- Total apenas dentro do grupo 'não informado'
  ), 2) AS percentual_dentro_do_grupo_salario_nao_informado
FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  faixa_salarial = 'não informado' -- Filtra para o grupo de interesse
GROUP BY
  faixa_salarial,
  status_inadimplencia
ORDER BY
  numero_clientes DESC;

-- Para ver o total de clientes com salário não informado e quantos são inadimplentes:
SELECT
    COUNT(DISTINCT id_cliente) AS total_clientes_salario_nao_informado,
    SUM(indicador_inadimplencia) AS total_inadimplentes_salario_nao_informado,
    ROUND(SUM(indicador_inadimplencia) * 100.0 / COUNT(DISTINCT id_cliente), 2) AS taxa_inadimplencia_salario_nao_informado_percent
FROM
    `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
    faixa_salarial = 'não informado';


SELECT
  salario,
  taxa_endividamento
FROM
    `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE salario IS NULL
ORDER BY taxa_endividamento > 0 AND taxa_endividamento < 1 LIMIT 10 ;


SELECT
  salario,
  taxa_endividamento
FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  salario IS NULL
  AND taxa_endividamento > 0 AND taxa_endividamento < 1 -- Filtrar explicitamente por este intervalo
ORDER BY
  taxa_endividamento ASC
LIMIT 20;


SELECT
  idade
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
ORDER BY idade DESC;

SELECT 
  *
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE salario = 1560100;


SELECT
  CASE
    WHEN historico_atrasos = status_inadimplencia THEN 'Igual'
    ELSE 'Diferente'
  END AS comparacao,
  COUNT(*) AS quantidade
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
GROUP BY comparacao;


SELECT
  historico_atrasos,
  status_inadimplencia
FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE historico_atrasos = 'não' AND status_inadimplencia = '1';


#### TABELA DE RANGES DOS QUARTIS 

SELECT
  quartil_dependentes AS quartil_dependentes, 
  MIN(numero_dependentes) AS minimo,
  MAX(numero_dependentes) AS maximo,
  COUNT(DISTINCT id_cliente) AS total_clientes 
FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
GROUP BY quartil_dependentes;
    
SELECT
  quartil_uso_credito AS quartil_uso_credito, 
  MIN(quartil_uso_credito) AS minimo,
  MAX(quartil_uso_credito) AS maximo,
  COUNT(DISTINCT id_cliente) AS total_clientes 
FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
GROUP BY quartil_uso_credito;



WITH quartil_taxa_endividamento_cte AS (
  SELECT
    id_cliente,
    taxa_endividamento,
    NTILE(4) OVER (ORDER BY taxa_endividamento ASC) AS ntile_calculado
  FROM
    `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
  WHERE
    taxa_endividamento IS NOT NULL
)
SELECT
  ntile_calculado AS QuartilTaxaEndividamento, 
  MIN(taxa_endividamento) AS MinimoTaxaEndividamento,  
  MAX(taxa_endividamento) AS MaximoTaxaEndividamento,  
  COUNT(DISTINCT id_cliente) AS TotalClientes        
FROM
  quartil_taxa_endividamento_cte
GROUP BY
  ntile_calculado
ORDER BY
  ntile_calculado;


WITH quartil_atraso_cte AS (
    
    SELECT
        atrasos_30_59_dias,
        NTILE(4) OVER (ORDER BY atrasos_30_59_dias) AS quartil_atraso_num
    FROM
        `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar` 
    
)
-- Passo 2: Agrupar pelos quartis calculados para obter min, max e contagem
SELECT
    quartil_atraso_num AS quartil,
    MIN(atrasos_30_59_dias) AS minimo,
    MAX(atrasos_30_59_dias) AS maximo,
    COUNT(*) AS total
FROM
    quartil_atraso_cte
GROUP BY
    quartil_atraso_num
ORDER BY
    quartil_atraso_num;
