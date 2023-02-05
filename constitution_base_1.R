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
classements_1973_2017 <- read.csv2("https://datahub.io/sports-data/atp-world-tour-tennis-data/r/rankings_1973-2017.csv",sep = ",") #Fichier lourd
#le fichier classement fait près de 300 Mo


#1-2 Si Les fichiers plats sont stockés sur le disque dur dans un dossier data
# match_stats_2017 <- read.csv2("data/match_stats_2017_unindexed_csv.csv",sep = ",")
# match_stats_1991_2016 <- read.csv2("data/match_stats_1991-2016_unindexed_csv.csv",sep = ",")
# joueurs <- read.csv2("data/player_overviews_unindexed_csv.csv",sep = ",")
# tournois <- read.csv2("data/tournaments_1877-2017_unindexed_csv.csv",sep = ",")
# match_scores_1991_2016 <- read.csv2("data/match_scores_1991-2016_unindexed_csv.csv",sep = ",")
# match_scores_2017 <- read.csv2("data/match_scores_2017_unindexed_csv.csv",sep = ",")
# classements_1973_2017 <- read.csv2("data/rankings_1973-2017_csv.csv",sep = ",")

#2 - Nettoyage des fichiers match_stats et match_scores

#2-1 Match_stats

#Fusion des fichiers sur les matches de 1991 à 2017
match_stats <- match_stats_1991_2016 %>% bind_rows(match_stats_2017)

#on enlève les doublons de matches en utilisant l'url comme identifiant
x <- unique(match_stats[duplicated(match_stats$match_stats_url_suffix),"match_stats_url_suffix"]) #liste des doublons d'url
match_stats <- match_stats %>% filter(!(match_stats_url_suffix %in% x))

#2-2 Match_scores

match_scores <- match_scores_1991_2016 %>% bind_rows(match_scores_2017)
x <- unique(match_scores[duplicated(match_scores$match_stats_url_suffix),"match_stats_url_suffix"]) #liste des doublons d'url
match_scores <- match_scores %>% filter(!(match_stats_url_suffix %in% x))
#il manque les url des 127 matches de l'us open 2017 dans le fichier des scores...à compléter

#2- Ajout d'une variable d'ordre des matches--------
matchs_ordonnes <- match_stats %>% 
  mutate(annee = as.numeric(substr(match_id,1,4)),
         toto = substr(match_stats_url_suffix,21,26)) %>% 
  arrange(annee,tourney_order,desc(toto)) %>% 
  cbind(1:nrow(match_stats)) %>% 
  rename(numero_ordre = "1:nrow(match_stats)")
  
#Il n'y a pas toujours les données des matchs de qualification

# 3 Filtre des matches pour lesquels on ne retrouve pas les scores--------
matchs_ordonnes_filtres <- matchs_ordonnes %>% semi_join(match_scores,by="match_stats_url_suffix")
#sans l'us open, on est sur une base de 95 610 matchs

# 4 Constitution de la base de données don--------

# 4-1 Ajout d'informations à partir de la base des joueurs (taille, poids, âge)-------

don <- matchs_ordonnes_filtres %>% 
  left_join(match_scores,by="match_stats_url_suffix") %>% 
  select(match_stats_url_suffix,winner_player_id,loser_player_id,tourney_year_id,numero_ordre,match_stats_url_suffix,match_id.x) %>% 
  rename(match_id = match_id.x) %>% 
  mutate(year = as.integer(substr(match_id,1,4)))
#Age au moment du tournoi (en age révolu : En 2017, un joueur né en 1988 a 29 ans)
don <- don %>% 
  left_join(joueurs,by = c("winner_player_id"="player_id")) %>% 
  left_join(joueurs,by=c("loser_player_id" = "player_id")) %>% 
  mutate(winner_age = year - birth_year.x, loser_age = year - birth_year.y) %>%
  rename(winner_weight = weight_kg.x, 
         loser_weight = weight_kg.y,
         winner_height = height_cm.x, 
         loser_height = height_cm.y) %>% 
  select(match_id,numero_ordre,match_stats_url_suffix,winner_player_id,winner_weight,winner_height,winner_age,loser_player_id,loser_weight,loser_height,loser_age)

# 4-2 Ajout du nombre de matches joués précédemment-------------

# # Ajout d'un compteur de matchs par joueur par année
# winners <- unique(don$winner_player_id) %>% as.data.frame()
# losers <- unique(don$loser_player_id)%>% as.data.frame()
# toto <- winners %>% full_join(losers,by=c("." = ".")) %>% rename("player_id" = ".") #%>% sample_n(100)
# #Création d'un objet b qui contient autant d'éléments que de joueurs différents dans l'ensemble des matchs
# b <- list()
# for (i in toto$player_id){
#   print(i)
#   a <- don %>% 
#     filter(winner_player_id == i | loser_player_id == i)
#   n <- nrow(a)
#   a <- a %>% mutate(nb_matches = 0:(n-1))
#   a <- a %>% mutate(winner_nb_matches = case_when(
#     winner_player_id == i ~ as.character(nb_matches)),
#     loser_nb_matches= case_when(
#       loser_player_id == i ~ as.character(nb_matches))) %>% 
#     select(match_stats_url_suffix,winner_nb_matches,loser_nb_matches) %>% 
#     mutate(winner_nb_matches = as.numeric(winner_nb_matches),
#            loser_nb_matches = as.numeric(loser_nb_matches))
#   b[i] <- list(a)
# 
# }
# #Fusion de tous les éléments de la liste (attention : pour 3500 éléments, cette boucle dure près de deux heures...)
# for (i in 1:(nrow(toto)-1)){
#   print(i)
#   a1 <- b[1] %>% as.data.frame()
#   a2 <- b[i+1] %>% as.data.frame()
#   colnames(a1) <- colnames(a)
#   colnames(a2) <- colnames(a)
#   a3 <- a2 %>% full_join(a1,by=c("match_stats_url_suffix")) %>%
#     group_by(match_stats_url_suffix) %>% 
#     mutate(winner_nb_matches = sum(winner_nb_matches.x,winner_nb_matches.y,na.rm = TRUE),
#            loser_nb_matches = sum(loser_nb_matches.x,loser_nb_matches.y,na.rm = TRUE)) %>% 
#     select(match_stats_url_suffix,winner_nb_matches,loser_nb_matches) %>% ungroup()
#   b[1] <- list(a3)
# }
# a <- b[1] %>% as.data.frame() 
# colnames(a) <- c("match_stats_url_suffix", "winner_nb_matches", "loser_nb_matches")
# saveRDS(a,"nb_matches.RDS")

#Ajout du nombre de matches joués
a <- readRDS("nb_matches.rds")
don <- don %>% left_join(a,by="match_stats_url_suffix")

# 4-3 Ajout du classement du joueur au moment du match
#Calcul de la moyenne de classement par joueur, par mois et par année entre 1991 et 2017
toto <- classements_1973_2017 %>% filter(week_year > 1990) %>% group_by(player_id,week_year,week_month) %>% 
  summarise(classement = round(mean(rank_number))) %>% ungroup()
#ajout d'un identifiant dans la base du classement
toto <- toto %>% 
  mutate(id_classement = paste(player_id,as.character(week_year),as.character(week_month),sep = "-")) %>%
  select(id_classement,classement)

#ajout d'un identifiant dans la base des match pour les winners et les losers
toto2 <- don %>% 
  left_join(match_scores[,c("tourney_year_id","match_stats_url_suffix")],by="match_stats_url_suffix") %>% 
  left_join(tournois[,c("tourney_year_id","tourney_year","tourney_month")],by="tourney_year_id") %>% 
  mutate(winner_id_classement = paste(winner_player_id,as.character(tourney_year),as.character(tourney_month),sep = "-"),
         loser_id_classement = paste(loser_player_id,as.character(tourney_year),as.character(tourney_month),sep = "-"))


toto3 <- toto2 %>% left_join(toto,by=c("winner_id_classement" = "id_classement")) %>% rename(winner_classement = classement)
toto4 <- toto3 %>% left_join(toto,by=c("loser_id_classement" = "id_classement")) %>% rename(loser_classement = classement)

don <- toto4
saveRDS(don,"don.rds")


#4-4 Ajout des stats par joueur

n <- 100
# don2 <- don pas de tirage aléatoire
don2 <- sample_n(don,size = n,replace = FALSE)
winners <- unique(don2$winner_player_id) %>% as.data.frame()
losers <- unique(don2$loser_player_id)%>% as.data.frame()
winners_losers <- winners %>% full_join(losers,by=c("." = ".")) %>% rename("player_id" = ".")

#Création d'un objet b qui contient autant d'éléments que de joueurs différents dans l'ensemble des matchs
b <- list()
for (i in winners_losers$player_id){
  print(i)
  a <- don %>%
    filter(winner_player_id == i | loser_player_id == i) %>% 
    select(match_stats_url_suffix,winner_player_id,winner_nb_matches,loser_player_id,loser_nb_matches) %>% 
    left_join(match_stats,by="match_stats_url_suffix")
  b[i] <- list(a)
}

