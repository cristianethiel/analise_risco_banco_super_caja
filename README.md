# Análise de Risco de Crédito - Banco Super Caja

Exploração de dados financeiros para entender os fatores que impactam o risco de inadimplência. Este projeto foi desenvolvido com foco em apoiar a tomada de decisão na concessão de crédito, substituindo processos manuais por uma abordagem baseada em dados.

## Visão Geral
Com a queda nas taxas de juros, o Banco Super Caja enfrentou aumento nas solicitações de crédito. O objetivo do projeto é construir um sistema de classificação de risco para reduzir inadimplência e melhorar a eficiência operacional.

## Problema Central
O processo manual de avaliação de crédito gera gargalos, é sujeito a erros e aumenta o risco de inadimplência. O banco precisava de:
- Uma metodologia objetiva baseada em dados históricos.
- Um score simplificado para triagem rápida.
- Um modelo estatístico preditivo para maior precisão.

## Ferramentas e Tecnologias
- **Linguagens:** SQL (BigQuery), Python
- **Bibliotecas Python:** Pandas, NumPy, Matplotlib, Seaborn, Scikit-learn, Statsmodels
- **Banco de Dados:** Google BigQuery
- **Visualização:** Looker Studio
- **Ambiente:** VS Code

## Estrutura do Repositório
- `/dados_brutos`: Dados originais (CSV).
- `/dataset`: Dados tratados e preparados.
- `/SQL`: Consultas SQL executadas no BigQuery.
- `/documentacao`: Documentação técnica.
  - `ficha_tecnica_risco.pdf`: Metodologia detalhada, tratamentos aplicados e análises.
  - `apresentacao_risco.pdf`: Apresentação dos insights e recomendações.
- `analise_risco.ipynb`: Notebook com análise exploratória, modelagem estatística e criação de score.
- `requirements.txt`: Dependências Python.

## Metodologia
- **Coleta e Consolidação:** Extração dos dados no BigQuery, unificação das tabelas de clientes, empréstimos e inadimplência.
- **Limpeza e Tratamento:** 
  - Correção de nulos e inconsistências.
  - Tratamento de outliers e dados duplicados.
  - Criação de variáveis derivadas e faixas categóricas.
- **Análise Exploratória (EDA):**
  - Análise estatística das variáveis.
  - Distribuição de variáveis demográficas, crédito e inadimplência.
  - Correlação entre variáveis.
- **Modelagem de Risco:**
  - Score simplificado baseado em regras de negócio (faixas de risco).
  - Modelo estatístico preditivo (Regressão Logística).
- **Visualização:**
  - Dashboard interativo no Looker Studio com análise de perfis de risco.
 
*Os resultados completos das análises e as recomendações estratégicas na [Ficha Técnica](/documentacao/ficha_tecnica_risco.pdf).*

## Principais Insights
👉 [Link para a Apresentação](https://www.loom.com/share/7997995cf1a749d2aaa1351fb475ae75)
- **Uso elevado do limite de crédito** é o maior preditor de inadimplência (RR = 44,65).
- **Idade (21-41 anos)** apresenta risco 2,5 vezes maior que a média.
- **Maior número de dependentes e alta taxa de endividamento** também elevam o risco.
- Aplicando o modelo de score simplificado com ponto de corte 3, o banco **reduz inadimplência em até 76%**, mantendo uma análise rápida e escalável.
- Já o modelo de regressão logística permite uma **redução potencial de até 81% na inadimplência**, mantendo um baixo impacto sobre bons clientes.

## Data Visualization
Acompanhe os insights no dashboard publicado:  
👉 [Link para o Dashboard no Looker Studio](https://lookerstudio.google.com/reporting/4f9b8cf6-444a-4193-a9a8-005472d73cef)

## Analista de Dados
Cristiane Thiel  
🌐 [https://cristianethiel.com.br/](https://cristianethiel.com.br/)  
🔗 [https://www.linkedin.com/in/cristianethiel/](https://www.linkedin.com/in/cristianethiel/)  
