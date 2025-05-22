## Análise de Risco Relativo

# escolher a variável = idade, salario, dependentes.... 
# evento de risco = inadimplência
# Grupo de Interesse X Grupo de Referência
# calcular para cada quartil

# RR = (Inadimplentes no Q1 / Total Q1) / (Inadimplentes nos Q2+Q3+Q4 / Total Q2+Q3+Q4)

######################################
# IDADE
######################################

SELECT

  # -- Taxa de inadimplência do Quartil 1
  ROUND(
    SUM(CASE WHEN quartil_idade = 1 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_idade = 1 THEN 1 ELSE 0 END), 0),2) AS taxa_inadimplencia_q1,
    -- NULLIF para evitar divisão por zero se o quartil estiver vazio
  
  # -- Taxa de inadimplência do Quartil 2
  ROUND(
    SUM(CASE WHEN quartil_idade = 2 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_idade = 2 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_q2,
    -- NULLIF para evitar divisão por zero se o quartil estiver vazio

  # -- Taxa de inadimplência do Quartil 3
  ROUND(
    SUM(CASE WHEN quartil_idade = 3 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_idade = 3 THEN 1 ELSE 0 END), 0),2) AS taxa_inadimplencia_q3,
    -- NULLIF para evitar divisão por zero se o quartil estiver vazio

  # -- Taxa de inadimplência do Quartil 4
  ROUND(
   SUM(CASE WHEN quartil_idade = 4 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
   NULLIF(SUM(CASE WHEN quartil_idade = 4 THEN 1 ELSE 0 END), 0),2) AS taxa_inadimplencia_q4,
    -- NULLIF para evitar divisão por zero se o quartil estiver vazio

  -- Q1 vs Q2, Q3, Q4
  ROUND(
    (SUM(CASE WHEN quartil_idade = 1 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_idade = 1 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_idade IN (2, 3, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_idade IN (2, 3, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q1,

  -- Q2 vs Q1, Q3, Q4
  ROUND(
    (SUM(CASE WHEN quartil_idade = 2 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_idade = 2 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_idade IN (1, 3, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_idade IN (1, 3, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q2,

  -- Q3 vs Q1, Q2, Q4
  ROUND(
    (SUM(CASE WHEN quartil_idade = 3 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_idade = 3 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_idade IN (1, 2, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_idade IN (1, 2, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q3,

  -- Q4 vs Q1, Q2, Q3
  ROUND(
    (SUM(CASE WHEN quartil_idade = 4 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_idade = 4 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_idade IN (1, 2, 3) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_idade IN (1, 2, 3) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q4

FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  quartil_idade IS NOT NULL
  AND indicador_inadimplencia IS NOT NULL;


######################################
# SALÁRIO
######################################

SELECT

  -- Taxa de inadimplência por decil de salário
  ROUND(
    SUM(CASE WHEN decil_salario = 1 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN decil_salario = 1 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_d1,

  ROUND(
    SUM(CASE WHEN decil_salario = 2 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN decil_salario = 2 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_d2,

  ROUND(
    SUM(CASE WHEN decil_salario = 3 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN decil_salario = 3 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_d3,

  ROUND(
    SUM(CASE WHEN decil_salario = 4 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN decil_salario = 4 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_d4,

  ROUND(
    SUM(CASE WHEN decil_salario = 5 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN decil_salario = 5 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_d5,

  ROUND(
    SUM(CASE WHEN decil_salario = 6 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN decil_salario = 6 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_d6,

  ROUND(
    SUM(CASE WHEN decil_salario = 7 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN decil_salario = 7 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_d7,

  ROUND(
    SUM(CASE WHEN decil_salario = 8 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN decil_salario = 8 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_d8,

  ROUND(
    SUM(CASE WHEN decil_salario = 9 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN decil_salario = 9 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_d9,

  ROUND(
    SUM(CASE WHEN decil_salario = 10 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN decil_salario = 10 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_d10

FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  decil_salario IS NOT NULL
  AND indicador_inadimplencia IS NOT NULL;

#########################################

-- Riscos relativos
SELECT

  ROUND(
    (SUM(CASE WHEN decil_salario = 1 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario = 1 THEN 1 ELSE 0 END), 0)) /
    (SUM(CASE WHEN decil_salario BETWEEN 2 AND 10 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario BETWEEN 2 AND 10 THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_d1,

  ROUND(
    (SUM(CASE WHEN decil_salario = 2 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario = 2 THEN 1 ELSE 0 END), 0)) /
    (SUM(CASE WHEN decil_salario IN (1,3,4,5,6,7,8,9,10) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario IN (1,3,4,5,6,7,8,9,10) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_d2,

  ROUND(
    (SUM(CASE WHEN decil_salario = 3 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario = 3 THEN 1 ELSE 0 END), 0)) /
    (SUM(CASE WHEN decil_salario IN (1,2,4,5,6,7,8,9,10) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario IN (1,2,4,5,6,7,8,9,10) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_d3,

  ROUND(
    (SUM(CASE WHEN decil_salario = 4 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario = 4 THEN 1 ELSE 0 END), 0)) /
    (SUM(CASE WHEN decil_salario IN (1,2,3,5,6,7,8,9,10) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario IN (1,2,3,5,6,7,8,9,10) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_d4,

  ROUND(
    (SUM(CASE WHEN decil_salario = 5 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario = 5 THEN 1 ELSE 0 END), 0)) /
    (SUM(CASE WHEN decil_salario IN (1,2,3,4,6,7,8,9,10) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario IN (1,2,3,4,6,7,8,9,10) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_d5,

  ROUND(
    (SUM(CASE WHEN decil_salario = 6 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario = 6 THEN 1 ELSE 0 END), 0)) /
    (SUM(CASE WHEN decil_salario IN (1,2,3,4,5,7,8,9,10) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario IN (1,2,3,4,5,7,8,9,10) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_d6,

  ROUND(
    (SUM(CASE WHEN decil_salario = 7 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario = 7 THEN 1 ELSE 0 END), 0)) /
    (SUM(CASE WHEN decil_salario IN (1,2,3,4,5,6,8,9,10) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario IN (1,2,3,4,5,6,8,9,10) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_d7,

  ROUND(
    (SUM(CASE WHEN decil_salario = 8 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario = 8 THEN 1 ELSE 0 END), 0)) /
    (SUM(CASE WHEN decil_salario IN (1,2,3,4,5,6,7,9,10) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario IN (1,2,3,4,5,6,7,9,10) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_d8,

  ROUND(
    (SUM(CASE WHEN decil_salario = 9 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario = 9 THEN 1 ELSE 0 END), 0)) /
    (SUM(CASE WHEN decil_salario IN (1,2,3,4,5,6,7,8,10) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario IN (1,2,3,4,5,6,7,8,10) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_d9,

  ROUND(
    (SUM(CASE WHEN decil_salario = 10 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario = 10 THEN 1 ELSE 0 END), 0)) /
    (SUM(CASE WHEN decil_salario IN (1,2,3,4,5,6,7,8,9) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN decil_salario IN (1,2,3,4,5,6,7,8,9) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_d10

FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  decil_salario IS NOT NULL
  AND indicador_inadimplencia IS NOT NULL;


######################################
# DEPENDENTES
######################################

SELECT
  -- Taxa de inadimplência do Quartil 1 (Dependentes)
  ROUND(
    SUM(CASE WHEN quartil_dependentes = 1 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_dependentes = 1 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_q1_dependentes,
  
  -- Taxa de inadimplência do Quartil 2 (Dependentes)
  ROUND(
    SUM(CASE WHEN quartil_dependentes = 2 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_dependentes = 2 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_q2_dependentes,

  -- Taxa de inadimplência do Quartil 3 (Dependentes)
  ROUND(
    SUM(CASE WHEN quartil_dependentes = 3 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_dependentes = 3 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_q3_dependentes,

  -- Taxa de inadimplência do Quartil 4 (Dependentes)
  ROUND(
    SUM(CASE WHEN quartil_dependentes = 4 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_dependentes = 4 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_q4_dependentes,

  -- Q1 vs Q2, Q3, Q4 (Risco relativo)
  ROUND(
    (SUM(CASE WHEN quartil_dependentes = 1 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_dependentes = 1 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_dependentes IN (2, 3, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_dependentes IN (2, 3, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q1_dependentes,

  -- Q2 vs Q1, Q3, Q4 (Risco relativo)
  ROUND(
    (SUM(CASE WHEN quartil_dependentes = 2 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_dependentes = 2 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_dependentes IN (1, 3, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_dependentes IN (1, 3, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q2_dependentes,

  -- Q3 vs Q1, Q2, Q4 (Risco relativo)
  ROUND(
    (SUM(CASE WHEN quartil_dependentes = 3 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_dependentes = 3 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_dependentes IN (1, 2, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_dependentes IN (1, 2, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q3_dependentes,

  -- Q4 vs Q1, Q2, Q3 (Risco relativo)
  ROUND(
    (SUM(CASE WHEN quartil_dependentes = 4 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_dependentes = 4 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_dependentes IN (1, 2, 3) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_dependentes IN (1, 2, 3) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q4_dependentes

FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  quartil_dependentes IS NOT NULL
  AND indicador_inadimplencia IS NOT NULL;




######################################
# USO DO CRÉDITO
######################################

SELECT

  # -- Taxa de inadimplência do Quartil 1
  ROUND(
    SUM(CASE WHEN quartil_uso_credito = 1 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_uso_credito = 1 THEN 1 ELSE 0 END), 0),2) AS taxa_inadimplencia_q1,
    -- NULLIF para evitar divisão por zero se o quartil estiver vazio
  
  # -- Taxa de inadimplência do Quartil 2
  ROUND(
    SUM(CASE WHEN quartil_uso_credito = 2 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_uso_credito = 2 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_q2,
    -- NULLIF para evitar divisão por zero se o quartil estiver vazio

  # -- Taxa de inadimplência do Quartil 3
  ROUND(
    SUM(CASE WHEN quartil_uso_credito = 3 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_uso_credito = 3 THEN 1 ELSE 0 END), 0),2) AS taxa_inadimplencia_q3,
    -- NULLIF para evitar divisão por zero se o quartil estiver vazio

  # -- Taxa de inadimplência do Quartil 4
  ROUND(
   SUM(CASE WHEN quartil_uso_credito = 4 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
   NULLIF(SUM(CASE WHEN quartil_uso_credito = 4 THEN 1 ELSE 0 END), 0),2) AS taxa_inadimplencia_q4,
    -- NULLIF para evitar divisão por zero se o quartil estiver vazio

  -- Q1 vs Q2, Q3, Q4
  ROUND(
    (SUM(CASE WHEN quartil_uso_credito = 1 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_uso_credito = 1 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_uso_credito IN (2, 3, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_uso_credito IN (2, 3, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q1,

  -- Q2 vs Q1, Q3, Q4
  ROUND(
    (SUM(CASE WHEN quartil_uso_credito = 2 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_uso_credito = 2 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_uso_credito IN (1, 3, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_uso_credito IN (1, 3, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q2,

  -- Q3 vs Q1, Q2, Q4
  ROUND(
    (SUM(CASE WHEN quartil_uso_credito = 3 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_uso_credito = 3 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_uso_credito IN (1, 2, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_uso_credito IN (1, 2, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q3,

  -- Q4 vs Q1, Q2, Q3
  ROUND(
    (SUM(CASE WHEN quartil_uso_credito = 4 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_uso_credito = 4 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_uso_credito IN (1, 2, 3) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_uso_credito IN (1, 2, 3) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q4

FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  quartil_uso_credito IS NOT NULL
  AND indicador_inadimplencia IS NOT NULL;


######################################
# TAXA DE ENDIVIDAMENTO
######################################

SELECT
  -- Taxa de inadimplência do Quartil 1 (Taxa de Endividamento)
  ROUND(
    SUM(CASE WHEN quartil_taxa_endividamento = 1 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_taxa_endividamento = 1 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_q1_endividamento,
  
  -- Taxa de inadimplência do Quartil 2 (Taxa de Endividamento)
  ROUND(
    SUM(CASE WHEN quartil_taxa_endividamento = 2 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_taxa_endividamento = 2 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_q2_endividamento,

  -- Taxa de inadimplência do Quartil 3 (Taxa de Endividamento)
  ROUND(
    SUM(CASE WHEN quartil_taxa_endividamento = 3 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_taxa_endividamento = 3 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_q3_endividamento,

  -- Taxa de inadimplência do Quartil 4 (Taxa de Endividamento)
  ROUND(
    SUM(CASE WHEN quartil_taxa_endividamento = 4 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 100 /
    NULLIF(SUM(CASE WHEN quartil_taxa_endividamento = 4 THEN 1 ELSE 0 END), 0), 2) AS taxa_inadimplencia_q4_endividamento,

  -- Q1 vs Q2, Q3, Q4 (Risco relativo)
  ROUND(
    (SUM(CASE WHEN quartil_taxa_endividamento = 1 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_taxa_endividamento = 1 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_taxa_endividamento IN (2, 3, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_taxa_endividamento IN (2, 3, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q1_endividamento,

  -- Q2 vs Q1, Q3, Q4 (Risco relativo)
  ROUND(
    (SUM(CASE WHEN quartil_taxa_endividamento = 2 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_taxa_endividamento = 2 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_taxa_endividamento IN (1, 3, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_taxa_endividamento IN (1, 3, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q2_endividamento,

  -- Q3 vs Q1, Q2, Q4 (Risco relativo)
  ROUND(
    (SUM(CASE WHEN quartil_taxa_endividamento = 3 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_taxa_endividamento = 3 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_taxa_endividamento IN (1, 2, 4) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_taxa_endividamento IN (1, 2, 4) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q3_endividamento,

  -- Q4 vs Q1, Q2, Q3 (Risco relativo)
  ROUND(
    (SUM(CASE WHEN quartil_taxa_endividamento = 4 AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_taxa_endividamento = 4 THEN 1 ELSE 0 END), 0))
    /
    (SUM(CASE WHEN quartil_taxa_endividamento IN (1, 2, 3) AND indicador_inadimplencia = 1 THEN 1 ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN quartil_taxa_endividamento IN (1, 2, 3) THEN 1 ELSE 0 END), 0))
  , 2) AS risco_relativo_q4_endividamento

FROM
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
WHERE
  quartil_taxa_endividamento IS NOT NULL
  AND indicador_inadimplencia IS NOT NULL;


######################################
# HISTÓRICO DE ATRASOS
######################################

SELECT 
  historico_atrasos,
  COUNT(CASE WHEN status_inadimplencia = 'sim' THEN 1 END) / COUNT(*) AS taxa_inadimplencia
FROM 
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
GROUP BY 
  historico_atrasos;

############

SELECT 
  historico_atrasos,
  (COUNT(CASE WHEN status_inadimplencia = 'sim' THEN 1 END) / COUNT(*)) / 
  (SELECT COUNT(CASE WHEN status_inadimplencia = 'sim' THEN 1 END) / COUNT(*) 
   FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`) 
  AS risco_relativo
FROM 
  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
GROUP BY 
  historico_atrasos;



# ranges dos quartis para ficha técnica

WITH quartis_age AS (
  SELECT 
    idade,
    NTILE(4) OVER (ORDER BY idade) AS quartil_idade
  FROM  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
  WHERE idade IS NOT NULL
)

SELECT 
  quartil_idade,
  MIN(idade) AS idade_minima,
  MAX(idade) AS idade_maxima,
  COUNT(*) AS total_clientes
FROM  `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
GROUP BY quartil_idade
ORDER BY quartil_idade;

######

WITH decisis_salary AS (
  SELECT 
    salario,
    NTILE(10) OVER (ORDER BY salario) AS decil_salario
  FROM `laboratoria-projeto-03.projeto03_risco_credito.tabela_unificada_auxiliar`
  WHERE salario IS NOT NULL
)

SELECT 
  decil_salario,
  MIN(salario) AS salario_minimo,
  MAX(salario) AS salario_maximo,
  COUNT(*) AS total_clientes
FROM decisis_salary
GROUP BY decil_salario
ORDER BY decil_salario;



