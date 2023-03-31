library(dplyr)
library(visNetwork)
library(rpart)
library(sparkline)

data <- readRDS("./data/don_sansNA.rds") %>% 
  select(-starts_with("match")) %>% 
  mutate_if(is.character, as.factor)

skimr::skim(data)

model <- rpart(target ~ ., 
               data = dplyr::sample_n(data, 10000), 
               cp = 0.0016,
               maxcompete = 3, #montre les variables proches de celle choisie
               maxsurrogate=1)#permet de traiter les valeurs manquantes
summary(model)

visNetwork::visTree(model, fallenLeaves = TRUE, height = "1000px")

small_data <-  dplyr::sample_n(data, 10000)

esquisse::esquisser()
