#-----------------------------------------------------------#
# TELECHARGEMENT, INSTALLATION ET ACTIVATION DES LIBRAIRIES #
#-----------------------------------------------------------#

# Installation des librairies (mise-a-jour si déjà installées)
install.packages("rvest")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("scales")
install.packages("maps")
install.packages("mapproj")
install.packages("plotly")

# Activation des librairies
library(rvest)
library(ggplot2)
library(dplyr)
library(scales)
library(maps)
library(mapproj)
library(plotly)

#-----------------------------------------#
# CHARGEMENT DES DONNEES DEPUIS WIKIPEDIA #
#-----------------------------------------#

# Chargement du code HTML de la page Internet dans un objet nomme 'ev' avec la  fonction 'read_html()' 
ev <- read_html("https://en.wikipedia.org/w/index.php?title=List_of_U.S._states_and_territories_by_life_expectancy&oldid=928537169")

# Filtrage du code HTML dans 'ev' afin de ne conserver que la table sur les espérances de vie
ev <- ev %>% html_nodes("table") %>% .[[2]] %>% html_table(fill=T)

# Affichage du contenu de la table 'ev' (espérances de vie)
View(ev)

#-------------------------#
# PREPARATION DES DONNEES #
#-------------------------#

# Sélection des colonnes qui seront utilisées par la suite
ev = ev[c(1,2,6,7)]
View(ev)

# Renommage des colonnes 
names(ev)[c(2,3,4)] = c("region","ev_caucasian", "ev_african")
View(ev)

# Conversion des colonnes au format numérique (les valeurs manquantes seront codées NA)
ev$ev_caucasian <- as.numeric(ev$ev_caucasian)
ev$ev_african <- as.numeric(ev$ev_african)
View(ev)

# Calcul des différences entre espérance de vie Caucasienne-Américaine et Afro-Américaine 
ev$ev_diff = ev$ev_caucasian - ev$ev_african
View(ev)

# Chargement de la liste des états des USA dans un objet 'states'
states = map_data("state")

# Création d'une nouvelle variable 'region' avec des noms des états en minuscules
ev$region = tolower(ev$region)
View(ev)

# Fusion des données de 'ev' avec celles des États-Unis dans l'objet 'states'
states = merge(states, ev, by="region", all.x=T)

#---------------------------------------------------#
# AFFICHAGE DES DONNEES SUR LA CARTE DES ETATS-UNIS #
#---------------------------------------------------#

# Affichage des caractères accentués dans les titres des cartes
options(encoding="latin1")

# Affichage des espérance de vie du groupe ethnique Afro-Américains par état
ggplot(states, aes(x = long, y = lat, group = group, fill = ev_african)) + geom_polygon(color = "white") + 
scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + 
labs(title="Espérance de vie du groupe ethnique Afro-Américain") + coord_map()

# Affichage des espérance de vie du groupe ethnique Caucasien-Américains par état
ggplot(states, aes(x = long, y = lat, group = group, fill = ev_caucasian)) + geom_polygon(color = "white") + 
scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="Gray") + 
labs(title="Espérance de vie du groupe ethnique Caucasien-Américain") + coord_map()

# Affichage des disparités entre les espérances de vie des deux groupes ethniques par état
ggplot(states, aes(x = long, y = lat, group = group, fill = ev_diff)) + geom_polygon(color = "white") + 
scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + 
labs(title="Différences dans l'espérance de vie des groupes ethniques \nCaucasien et Afro-Américain par état aux USA") + coord_map()

# Affichage d'une carte interactive des USA avec affichage contextuel lors du survol d'un état avec la souris (ethnie Afro-Américaine)
map_plot_african = ggplot(states, aes(x = long, y = lat, group = group, fill = ev_african)) + geom_polygon(color = "white") + 
scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + 
labs(title="Espérance de vie du groupe ethnique Afro-Américain") + coord_map()
ggplotly(map_plot_african)

# Affichage d'une carte interactive des USA avec affichage contextuel lors du survol d'un état avec la souris (ethnie Caucasienne-Américaine)
map_plot_caucasian = ggplot(states, aes(x = long, y = lat, group = group, fill = ev_caucasian)) + geom_polygon(color = "white") + 
scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + 
labs(title="Espérance de vie du groupe ethnique Caucasien-Américain") + coord_map()
ggplotly(map_plot_caucasian)

