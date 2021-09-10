#LM
#Boucles
# Je mets ici des morceaux de code un peu élégant qui permettent d'automatiser certaines tâches. 
# Pour le moment c'est à usage perso. J'ai pas encore réfléchi sur comment structurer mes propres pense-bêtes


# Import / Export multiples ----

# Donnees pour exemple
records <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-05-25/records.csv')
records$track <-as.factor(records$track) 

# Export multiples : à partir d'un tableau, on créé des sous-tables définies par les catégories d'une variable et on exporte chacune dans un csv
library(tidyverse)
records %>% 
  group_by(track) %>% # variable dont les modalités définissent le sous-tableau
  nest() %>%          # on réarrange nos données sous forme de liste de dataframe
  pwalk(~write_csv2(x = .y, file = paste0("exemple/",.x, ".csv") )) # on utilise pwalk pour passer un groupe de liste en paramètre et lui appliquer une fonction à p paramètres
                                                                    # dans le cas d'un dataframe nesté, .x correspond au nom du df et .y aux données du df

# Export multiples : à partir d'un tableau, 1)on créé des sous-tableaux, 2)chaque sous tableau est exporté dans les onglets d'un fichier Excel
library(writexl)
records %>% 
  split(.$track) %>% 
  writexl::write_xlsx(path = "exemple/mario_kart.xlsx") 


# Import multiples d'onglet Excel : chaque onglet est assigné à un objet
library(tidyverse)
library(readxl)
path <- readxl_example("datasets.xlsx") #chemin du fichier Excel
data_list <- path %>%
  excel_sheets() %>%  # renvoie les noms des onglets en vecteur
  set_names() %>%     # convertit en liste
  map(read_excel, path = path) %>%  # renvoie une liste de tibble contenant chacun un onglet
  purrr::walk2(                     # on utilise walk2 pour passer la liste en pramètre et lui appliquer une fonction à 2 vecteurs en paramètre
    .x = names(.),                  # names to assign : premier paramètre, nom du ième élément de la liste
    .y = .,                         # object to be assigned : deuxième paramètre, ième élément de la liste
    .f = ~ assign(x = .x,                         # fonction à appliquer : on assigne l'objet, il faut préciser l'option envir = .GlobalEnv pour sortir de l'environement de la fonction
                  value = tibble::as.tibble(.y), 
                  envir = .GlobalEnv)
  )

# Import multiples d'onglets Excel : structure identique dans chaque fichier --> concaténation
library(rio)
library(readxl)
data_list <- import_list("exemple/mario_kart.xlsx") 
path <- "exemple/mario_kart.xlsx"
mario_data <- path %>%
  excel_sheets() %>% 
  map_df(read_excel, path = path) 

# Import multiples de fichiers csv
library(tidyverse)
library(stringr)
files_list <- list.files("exemple",pattern = "*.csv")
data_names <- str_remove(files_list, ".csv")
data_names %>% 
  set_names() %>%
  map(~paste0("exemple/",.,".csv")) %>%
  map(read_csv2) %>%
  purrr::walk2(                     # on utilise walk2 pour passer la liste en pramètre et lui appliquer une fonction à 2 vecteurs en paramètre
    .x = names(.),                  # names to assign : premier paramètre, nom du ième élément de la liste
    .y = .,                         # object to be assigned : deuxième paramètre, ième élément de la liste
    .f = ~ assign(x = .x,                         # fonction à appliquer : on assigne l'objet, il faut préciser l'option envir = .GlobalEnv pour sortir de l'environement de la fonction
                  value = tibble::as.tibble(.y), 
                  envir = .GlobalEnv)
  )





