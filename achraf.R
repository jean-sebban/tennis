

data <- readRDS("./data/don_sansNA.rds") %>% 
  select(-starts_with("match")) %>% 
  mutate_if(is.character, as.factor)

model <- rpart(target ~ ., data = dplyr::sample_n(data, 10000), cp = 0.001)


visNetwork::visTree(model, fallenLeaves = T, height = "1000px")

small_data <-  dplyr::sample_n(data, 10000)

esquisse::esquisser()
