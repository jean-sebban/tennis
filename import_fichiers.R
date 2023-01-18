#Visualisation des fichiers
joueurs <- read.csv2("data/player_overviews_unindexed_csv.csv",sep = ",")

#Tournois
tournois <- read.csv2("data/tournaments_1877-2017_unindexed_csv.csv",sep = ",")

#matchs stats
match_stats_2017 <- read.csv2("data/match_stats_2017_unindexed_csv.csv",sep = ",")
match_stats_1991_2016 <- read.csv2("data/match_stats_1991-2016_unindexed_csv.csv",sep = ",")

#match scores
match_scores_1991_2016 <- read.csv2("data/match_scores_1991-2016_unindexed_csv.csv",sep = ",")

#Classements de 1973 à 2017
classements_1973_2017 <- read.csv2("data/rankings_1973-2017_csv.csv",sep = ",")
