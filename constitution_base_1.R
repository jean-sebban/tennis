library(dplyr)
library(stringr)

#1 - Importation des fichiers-----

#1-1 Directement avec les liens URL--------
match_stats_2017 <- read.csv2("https://datahub.io/sports-data/atp-world-tour-tennis-data/r/match_stats_2017_unindexed.csv",sep = ",")
match_stats_1991_2016 <- read.csv2("https://datahub.io/sports-data/atp-world-tour-tennis-data/r/match_stats_1991-2016_unindexed.csv",sep = ",")
match_scores_1991_2016 <- read.csv2("https://datahub.io/sports-data/atp-world-tour-tennis-data/r/match_scores_1991-2016_unindexed.csv",sep = ",")
match_scores_2017 <- read.csv2("https://datahub.io/sports-data/atp-world-tour-tennis-data/r/match_scores_2017_unindexed.csv",sep = ",")
joueurs <- read.csv2("https://datahub.io/sports-data/atp-world-tour-tennis-data/r/player_overviews_unindexed.csv",sep = ",")
tournois <- read.csv2("https://datahub.io/sports-data/atp-world-tour-tennis-data/r/tournaments_1877-2017_unindexed.csv",sep = ",")
# classements_1973_2017 <- read.csv2("https://datahub.io/sports-data/atp-world-tour-tennis-data/r/rankings_1973-2017.csv",sep = ",") #Fichier lourd

#1-2 Si Les fichiers plats sont stockés sur le disque dur
# match_stats_2017 <- read.csv2("data/match_stats_2017_unindexed_csv.csv",sep = ",")
# match_stats_1991_2016 <- read.csv2("data/match_stats_1991-2016_unindexed_csv.csv",sep = ",")
# joueurs <- read.csv2("data/player_overviews_unindexed_csv.csv",sep = ",")
# tournois <- read.csv2("data/tournaments_1877-2017_unindexed_csv.csv",sep = ",")
# match_scores_1991_2016 <- read.csv2("data/match_scores_1991-2016_unindexed_csv.csv",sep = ",")
# match_scores_2017 <- read.csv2("data/match_scores_2017_unindexed_csv.csv",sep = ",")
# classements_1973_2017 <- read.csv2("data/rankings_1973-2017_csv.csv",sep = ",")



#Fusion des fichiers sur les matches de 1991 à 2017
match_stats_1991_2017 <- match_stats_1991_2016 %>% bind_rows(match_stats_2017)
match_scores_1991_2017 <- match_scores_1991_2016 %>% bind_rows(match_scores_2017)
# rm(match_scores_2017,match_scores_1991_2016)
# rm(match_stats_2017,match_stats_1991_2016)


#2- Ajout d'une variable d'ordre des matches--------


matchs_ordonnes <- match_stats_1991_2017 %>% 
  mutate(annee = as.numeric(substr(match_id,1,4)),
         toto = substr(match_stats_url_suffix,21,26)) %>% 
  arrange(annee,tourney_order,desc(toto)) %>% 
  cbind(1:nrow(match_stats_1991_2017)) %>% 
  rename(numero_ordre = "1:nrow(match_stats_1991_2017)")
  
#Il n'y a pas toujours les données des matchs de qualification

# 3 Filtre des matches pour lesquels on ne retrouve pas les scores
matchs_ordonnes_filtres <- matchs_ordonnes %>% semi_join(match_scores_1991_2017,by="match_id")
#Seulement 17 matches pour lesquels on a pas les scores

# 5 Elaboration des stats sur les joueurs

#paramètres
# annees <- 2 #nombre d'années en compte
# nb_matches <- 10 #nombre de matches précédents pris en compte dans le calcul

#Création de variables concernant le joueur 1 (j1) et le joueur 2 (j2)

joueurs <- joueurs %>% select(player_id,birth_year,weight_kg,height_cm)

don <- matchs_ordonnes_filtres %>% 
  left_join(match_scores_1991_2017,by="match_id") %>% 
  select(match_id,winner_player_id,loser_player_id,tourney_year_id,numero_ordre) %>% 
  mutate(year = as.integer(substr(match_id,1,4)))

#Age au moment du tournoi (en age révolu : En 2017, un joueur né en 1958 a 59 ans)

don <- don %>% 
  left_join(joueurs,by = c("winner_player_id"="player_id")) %>% 
  left_join(joueurs,by=c("loser_player_id" = "player_id")) %>% 
  mutate(winner_age = year - birth_year.x, loser_age = year - birth_year.y) %>%
  rename(winner_weight = weight_kg.x, 
         loser_weight = weight_kg.y,
         winner_height = height_cm.x, 
         loser_height = height_cm.y) %>% 
  select(match_id,numero_ordre,winner_player_id,winner_weight,winner_height,winner_age,loser_player_id,loser_weight,loser_height,loser_age)

#Création d'un id


# Ajout d'un compteur de matchs par joueur par année
toto1 <- unique(don$winner_player_id) %>% as.data.frame()
toto2 <- unique(don$loser_player_id)%>% as.data.frame()
toto <- toto1 %>% full_join(toto2,by=c("." = ".")) %>% rename("player_id" = ".") #%>% sample_n(100)


#Création d'un objet qui contient autant d'éléments que de joueurs différents dans l'ensemble des matchs
b <- list()
for (i in toto$player_id){
  print(i)
  a <- don %>% 
    filter(winner_player_id == i | loser_player_id == i)
  # a <-   mutate(nb_matches = 0:length(a))
  n <- nrow(a)
  a <- a %>% mutate(nb_matches = 0:(n-1))
  a <- a %>% mutate(winner_nb_matches = case_when(
    winner_player_id == i ~ as.character(nb_matches)),
    loser_nb_matches= case_when(
      loser_player_id == i ~ as.character(nb_matches))) %>% 
    select(match_id,winner_nb_matches,loser_nb_matches) %>% 
    mutate(winner_nb_matches = as.numeric(winner_nb_matches),
           loser_nb_matches = as.numeric(loser_nb_matches))
  # assign(i,a) 
  b[i] <- list(a)

}

# #Pour i = 1
# a1 <- b[1] %>% as.data.frame()
# a2 <- b[1+1] %>% as.data.frame()
# colnames(a1) <- colnames(a)
# colnames(a2) <- colnames(a)
# 
# a3 <- a2 %>%
#   full_join(a1,by=c("match_id")) %>%
#   group_by(match_id) %>%
#   mutate(winner_nb_matches = sum(winner_nb_matches.x,winner_nb_matches.y,na.rm = TRUE),
#          loser_nb_matches = sum(loser_nb_matches.x,loser_nb_matches.y,na.rm = TRUE)
#   )%>%
#   select(match_id,winner_nb_matches,loser_nb_matches) %>% ungroup()
# b[1] <- list(a3)
# 
# #Pour i=2
# a1 <- b[1] %>% as.data.frame()
# a2 <- b[2+1] %>% as.data.frame()
# colnames(a1) <- colnames(a)
# colnames(a2) <- colnames(a)
# 
# a3 <- a2 %>%
#   full_join(a1,by=c("match_id")) %>%
#   group_by(match_id) %>%
#   mutate(winner_nb_matches = sum(winner_nb_matches.x,winner_nb_matches.y,na.rm = TRUE),
#          loser_nb_matches = sum(loser_nb_matches.x,loser_nb_matches.y,na.rm = TRUE)
#   )%>%
#   select(match_id,winner_nb_matches,loser_nb_matches) %>% ungroup()
# b[1] <- list(a3)

#Fusion de tous les éléments de la liste (attention : pour 3500 éléments, cette boucle dure près de deux heures...)
for (i in 1:(nrow(toto)-1)){
  print(i)
  a1 <- b[1] %>% as.data.frame()
  a2 <- b[i+1] %>% as.data.frame()
  colnames(a1) <- colnames(a)
  colnames(a2) <- colnames(a)
  a3 <- a2 %>% full_join(a1,by=c("match_id")) %>%
    group_by(match_id) %>% 
    mutate(winner_nb_matches = sum(winner_nb_matches.x,winner_nb_matches.y,na.rm = TRUE),
           loser_nb_matches = sum(loser_nb_matches.x,loser_nb_matches.y,na.rm = TRUE)) %>% 
    select(match_id,winner_nb_matches,loser_nb_matches) %>% ungroup()
  b[1] <- list(a3)
}

a <- b[1] %>% as.data.frame() %>% distinct()
colnames(a) <- c("match_id", "winner_nb_matches", "loser_nb_matches")
saveRDS(a,"nb_matches.RDS")

