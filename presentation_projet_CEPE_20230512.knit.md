---
title: "Projet de Data Science"
author: "Jean Sebban, Fally et Guillaume Allard"
format: revealjs
editor: visual
---



# Problématique

Construire un modèle permettant de prédire le résultat d'un match de tennis en simple, à partir d'informations sur les joueurs qui s'affrontent.

# Constitution de la base des matches


::: {.cell}

:::



## Les fichiers sources

When you click the **Render** button a document will be generated that includes:

-   Matches (n = 95 610)
-   Joueurs (n = 10 912)
-   Classements (n = 2 694 539)
-   Tournoi (n = 4 114)

# Exploration de la base


::: {.cell}

:::


## Univarié


::: {.cell}

:::

::: {.cell}

```{.r .cell-code}
skim(data)
```

::: {.cell-output-display}
Table: Data summary

|                         |       |
|:------------------------|:------|
|Name                     |data   |
|Number of rows           |149924 |
|Number of columns        |24     |
|_______________________  |       |
|Column type frequency:   |       |
|factor                   |3      |
|numeric                  |21     |
|________________________ |       |
|Group variables          |None   |


**Variable type: factor**

|skim_variable      | n_missing| complete_rate|ordered | n_unique|top_counts                                 |
|:------------------|---------:|-------------:|:-------|--------:|:------------------------------------------|
|target             |         0|             1|FALSE   |        2|0: 74962, 1: 74962                         |
|tourney_surface    |         0|             1|FALSE   |        3|Har: 82524, Cla: 50786, Gra: 16614, Car: 0 |
|tourney_conditions |         0|             1|FALSE   |        2|Out: 128288, Ind: 21636                    |


**Variable type: numeric**

|skim_variable                         | n_missing| complete_rate|   mean|     sd|       p0|    p25|    p50|    p75|    p100|hist                                     |
|:-------------------------------------|---------:|-------------:|------:|------:|--------:|------:|------:|------:|-------:|:----------------------------------------|
|weight_j1                             |         0|             1|  79.73|   7.24|     0.00|  75.00|  79.00|  84.00|  108.00|▁▁▁▇▂ |
|height_j1                             |         0|             1| 185.32|   7.34|     0.00| 180.00| 185.00| 191.00|  211.00|▁▁▁▁▇ |
|age_j1                                |         0|             1|  26.08|   3.65|    16.00|  23.00|  26.00|  29.00|   44.00|▂▇▅▁▁ |
|classement_j1                         |         0|             1|  84.12| 100.63|     1.00|  27.00|  60.00| 105.00| 1922.00|▇▁▁▁▁ |
|nb_match_won_last_5_j1                |         0|             1|   2.64|   1.15|     0.00|   2.00|   3.00|   3.00|    5.00|▅▇▇▅▁ |
|avg_pct_ace_last_5_j1                 |         0|             1|   7.15|   4.33|     0.00|   4.03|   6.29|   9.33|   37.02|▇▅▁▁▁ |
|avg_pct_double_faults_last_5_j1       |         0|             1|   3.91|   1.83|     0.00|   2.60|   3.66|   4.95|   22.60|▇▃▁▁▁ |
|avg_pct_first_serves_in_5_j1          |         0|             1|  58.78|   7.17|     9.45|  54.91|  59.19|  63.31|   85.00|▁▁▂▇▁ |
|avg_pct_first_serves_points_won_5_j1  |         0|             1|  42.64|   5.08|    21.82|  39.17|  42.45|  45.91|   65.99|▁▃▇▂▁ |
|avg_pct_second_serves_points_won_5_j1 |         0|             1|  50.94|   5.84|    25.85|  47.06|  50.91|  54.80|   82.76|▁▅▇▁▁ |
|weight_j2                             |         0|             1|  79.73|   7.24|     0.00|  75.00|  79.00|  84.00|  108.00|▁▁▁▇▂ |
|height_j2                             |         0|             1| 185.32|   7.34|     0.00| 180.00| 185.00| 191.00|  211.00|▁▁▁▁▇ |
|age_j2                                |         0|             1|  26.08|   3.65|    16.00|  23.00|  26.00|  29.00|   44.00|▂▇▅▁▁ |
|classement_j2                         |         0|             1|  84.12| 100.63|     1.00|  27.00|  60.00| 105.00| 1922.00|▇▁▁▁▁ |
|nb_match_won_last_5_j2                |         0|             1|   2.64|   1.15|     0.00|   2.00|   3.00|   3.00|    5.00|▅▇▇▅▁ |
|avg_pct_ace_last_5_j2                 |         0|             1|   7.15|   4.33|     0.00|   4.03|   6.29|   9.33|   37.02|▇▅▁▁▁ |
|avg_pct_double_faults_last_5_j2       |         0|             1|   3.91|   1.83|     0.00|   2.60|   3.66|   4.95|   22.60|▇▃▁▁▁ |
|avg_pct_first_serves_in_5_j2          |         0|             1|  58.78|   7.17|     9.45|  54.91|  59.19|  63.31|   85.00|▁▁▂▇▁ |
|avg_pct_first_serves_points_won_5_j2  |         0|             1|  42.64|   5.08|    21.82|  39.17|  42.45|  45.91|   65.99|▁▃▇▂▁ |
|avg_pct_second_serves_points_won_5_j2 |         0|             1|  50.94|   5.84|    25.85|  47.06|  50.91|  54.80|   82.76|▁▅▇▁▁ |
|classement_diff                       |         0|             1|   0.00| 124.36| -1753.00| -42.00|   0.00|  42.00| 1753.00|▁▁▇▁▁ |
:::
:::



## ACP

## Arbre

When you click the **Render** button a presentation will be generated that includes both content and the output of embedded code. You can embed code like this:


::: {.cell}
::: {.cell-output .cell-output-stdout}
```
[1] 2
```
:::
:::


# Comparaison des performances

# Généralisation du modèle
