library(dplyr)
library(lubridate)

tournois <- read.csv2("data/tournaments_1877-2017_unindexed_csv.csv",sep = ",")
tournois <- tournois %>% mutate(tourney_dates = ymd(tourney_dates)) %>% distinct() #on enlève les vrais doublons

#match scores
match_scores_1991_2016 <- read.csv2("data/match_scores_1991-2016_unindexed_csv.csv",sep = ",")
match_scores_2017 <- read.csv2("data/match_scores_2017_unindexed_csv.csv",sep = ",")
match_scores_1991_2017 <- match_scores_1991_2016 %>% bind_rows(match_scores_2017)%>% distinct()#pas de vrais doublons

#matchs stats
match_stats_2017 <- read.csv2("data/match_stats_2017_unindexed_csv.csv",sep = ",")
match_stats_1991_2016 <- read.csv2("data/match_stats_1991-2016_unindexed_csv.csv",sep = ",")
match_stats_1991_2017 <- match_stats_1991_2016 %>% bind_rows(match_stats_2017) %>% distinct()
#Des vrais doublons


#Constitution de la base de données

#1- on ordonne les matches
don1 <- match_stats_1991_2017 %>% 
  mutate(annee = as.numeric(substr(match_id,1,4)),
         toto = substr(match_stats_url_suffix,21,26)) %>% 
  arrange(annee,tourney_order,desc(toto)) %>% 
  cbind(1:nrow(match_stats_1991_2017)) %>% 
  rename(numero_ordre = "1:nrow(match_stats_1991_2017)") %>% select(match_id,numero_ordre)

#2- On ne garde que les matchs pour lesquels on a les stats et le score entre 1991 et 2017
don2 <- don1 %>% semi_join(match_scores_1991_2017,by="match_id") %>% select(match_id,numero_ordre)


#3 Récupération d'informations sur les dates des matches à partir de la table des tournois
don3 <- don2 %>% 
  left_join(match_scores_1991_2017,by="match_id") %>% 
  left_join(tournois,by="tourney_year_id") %>% 
  select(match_id,tourney_id,numero_ordre,tourney_year_id,round_order,tourney_dates,winner_player_id,loser_player_id) %>% 
  distinct()

#4 Nombre de matches joués précedemment
toto1 <- unique(don3$winner_player_id) %>% as.data.frame()
toto2 <- unique(don3$loser_player_id)%>% as.data.frame()
# toto <- toto1 %>% anti_join(toto2,by=c("." = ".")) %>% rename("player_id" = ".")

toto <- toto1 %>% full_join(toto2,by=c("." = ".")) %>% rename("player_id" = ".")




#don3[duplicated(don3$match_id),] tests de vérification des doublons de matches
#il peut y avoir des doublons de matches dans les Masters (avec la phase de poules) et 
# si il y a un lucky loser repéché dans un tournoi qui rejoue contre le même joueur


#4 - ajout de la date des matchs à partir de la date des tournois et de l'ordre des matches
#Récup du nombre de tours par tournoi-année
nb_tours_par_tournoi_annee <- match_scores_1991_2017 %>% group_by(tourney_year_id) %>% summarise(nb_matches = n(),
                                                                                                 nb_tours = max(round_order))





