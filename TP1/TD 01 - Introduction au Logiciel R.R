#-----------------------------------------------------------#
# TELECHARGEMENT, INSTALLATION ET ACTIVATION DES LIBRAIRIES #
#-----------------------------------------------------------#

# Installation des librairies (mise-a-jour si d?j? install?es)
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

# Filtrage du code HTML dans 'ev' afin de ne conserver que la table sur les esp?rances de vie
ev <- ev %>% html_nodes("table") %>% .[[2]] %>% html_table(fill=T)

# Affichage du contenu de la table 'ev' (esp?rances de vie)
View(ev)

#-------------------------#
# PREPARATION DES DONNEES #
#-------------------------#

# S?lection des colonnes qui seront utilis?es par la suite
ev = ev[c(1,2,6,7)]
View(ev)

# Renommage des colonnes 
names(ev)[c(2,3,4)] = c("region","ev_caucasian", "ev_african")
View(ev)

# Conversion des colonnes au format num?rique (les valeurs manquantes seront cod?es NA)
ev$ev_caucasian <- as.numeric(ev$ev_caucasian)
ev$ev_african <- as.numeric(ev$ev_african)
View(ev)

# Calcul des diff?rences entre esp?rance de vie Caucasienne-Am?ricaine et Afro-Am?ricaine 
ev$ev_diff = ev$ev_caucasian - ev$ev_african
View(ev)

# Chargement de la liste des ?tats des USA dans un objet 'states'
states = map_data("state")

# Cr?ation d'une nouvelle variable 'region' avec des noms des ?tats en minuscules
ev$region = tolower(ev$region)
View(ev)

# Fusion des donn?es de 'ev' avec celles des ?tats-Unis dans l'objet 'states'
states = merge(states, ev, by="region", all.x=T)

#---------------------------------------------------#
# AFFICHAGE DES DONNEES SUR LA CARTE DES ETATS-UNIS #
#---------------------------------------------------#

# Affichage des caract?res accentu?s dans les titres des cartes
options(encoding="latin1")

# Affichage des esp?rance de vie du groupe ethnique Afro-Am?ricains par ?tat
ggplot(states, aes(x = long, y = lat, group = group, fill = ev_african)) + geom_polygon(color = "white") + 
scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + 
labs(title="Esp?rance de vie du groupe ethnique Afro-Am?ricain") + coord_map()

# Affichage des esp?rance de vie du groupe ethnique Caucasien-Am?ricains par ?tat
ggplot(states, aes(x = long, y = lat, group = group, fill = ev_caucasian)) + geom_polygon(color = "white") + 
scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="Gray") + 
labs(title="Esp?rance de vie du groupe ethnique Caucasien-Am?ricain") + coord_map()

# Affichage des disparit?s entre les esp?rances de vie des deux groupes ethniques par ?tat
ggplot(states, aes(x = long, y = lat, group = group, fill = ev_diff)) + geom_polygon(color = "white") + 
scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + 
labs(title="Diff?rences dans l'esp?rance de vie des groupes ethniques \nCaucasien et Afro-Am?ricain par ?tat aux USA") + coord_map()

# Affichage d'une carte interactive des USA avec affichage contextuel lors du survol d'un ?tat avec la souris (ethnie Afro-Am?ricaine)
map_plot_african = ggplot(states, aes(x = long, y = lat, group = group, fill = ev_african)) + geom_polygon(color = "white") + 
scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + 
labs(title="Esp?rance de vie du groupe ethnique Afro-Am?ricain") + coord_map()
ggplotly(map_plot_african)

# Affichage d'une carte interactive des USA avec affichage contextuel lors du survol d'un ?tat avec la souris (ethnie Caucasienne-Am?ricaine)
map_plot_caucasian = ggplot(states, aes(x = long, y = lat, group = group, fill = ev_caucasian)) + geom_polygon(color = "white") + 
scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + 
labs(title="Esp?rance de vie du groupe ethnique Caucasien-Am?ricain") + coord_map()
ggplotly(map_plot_caucasian)

