#!/bin/bash
#echo -e "\e[1;5;31m
#████████╗██████╗  █████╗  ██████╗███████╗██████╗  ██████╗ ██╗   ██╗████████╗███████╗
#╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██╔═══██╗██║   ██║╚══██╔══╝██╔════╝
#   ██║   ██████╔╝███████║██║     █████╗  ██████╔╝██║   ██║██║   ██║   ██║   █████╗
#   ██║   ██╔══██╗██╔══██║██║     ██╔══╝  ██╔══██╗██║   ██║██║   ██║   ██║   ██╔══╝
#   ██║   ██║  ██║██║  ██║╚██████╗███████╗██║  ██║╚██████╔╝╚██████╔╝   ██║   ███████╗
#   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
#   \e[0m"
#----------------------------------Préparation----------------------------------#
> traceroute.txt                                    # Nettoyage du fichier contenant le résultat du script
> traceroute.dot                                    # Nettoyage du fichier dot contenant le graphe
echo "digraph traceroute { " > traceroute.txt       # Début du fichier dot

#-----------------------------------Variables----------------------------------#
                                              
ttl=1                                               # Variable du TTL pour commencer au premier HOP 
arg="0"                                             # Position dans le tableau des options arguments
#web="0"                                            # Position dans le tableau des adresses web
boucle='0'                                          # Boucle infinie dans le "while" principal
anti_doublon=""                                     # Correcteur de doublon           
options=("" "-I" "-T"  "-p 53 -U" "-p 67 -U" "-p 25 -T" "-p 80 -T" "-p 443 -T" "-p 21 -T" "-p 22 -T" "-p 53 -T" "end") # Liste des options à tester en argument de la commande traceroute     
sites=(
 #   "perdu.com"
 #   "rt.unice.fr"
 #   "cfasup-fc.com"
 #   "chine-nouvelle.com"
 #   "mines-ales.fr"
    "iut.fr"
    "onisep.fr"
    "global.bfsu.edu.cn")                           # Liste des adresses web a consulter

#----------------------------------TRACEROUTE----------------------------------#
for siteweb in "${sites[@]}" ; do
    ipaddr=$(nslookup $siteweb | grep Address | tail -n 1 | cut -d " " -f 2)
    #masque=$(ipcalc $ipaddr | grep Netmask | awk '{print($4)}'  )              #Extraction du masque de sous-réseau  
    hops=$(traceroute $siteweb -w 1 | wc -l)                                    # Nombre de lignes du traceroute   
    #AS=$(traceroute -n -f $ttl -m $ttl -w 1 -q 1 $siteweb -A | tail -n 1 | awk '{print($3)}')
    echo ""       
    echo -e "\e[96m Cible :\e[0m" $siteweb "($ipaddr)"
    while [ "$ttl" != "$hops" ] ; do                                            # Boucle Principale / s'arrête quand le nombre de hops calculé auparavant est atteint                                              
        while [ "$boucle" == '0' ]  ; do                                        # Boucle infinie tant que les conditions futures ne "breakent" pas
            resultat=$(traceroute -n -f $ttl -m $ttl -w 1 -q 1 $siteweb ${options[arg]} -A | tail -n 1 | awk '{print($2,$3)}')         #Résultat de la commande traceroute stockée, en fonction des options utilisées          
            if [ "$resultat" != "* " ] ; then                                   # Condition si on trouve un résultat non nul
                if [ "$anti_doublon" == "$resultat" ] ; then                    # Condition si c'est un doublon
                    break   
                else
                    if [ "$ttl" != "1" ] ; then                                 # Condition si c'est la première ligne
                        echo " -> " >> traceroute.txt
                    fi
                    echo " \" $ttl $resultat\" " >> traceroute.txt             # Stocker le résultat (si le résultat n'est pas nul et que ce n'est pas un doublon)
                    echo -e "\e[92m $ttl    \e[0m$resultat      "               # Afficher le résultat
                    ((arg=arg+1))                                               # Incrémentation de la position dans le tableau des options
                    break
                fi
            else                                                                # Si on trouve un résultat NUL
                #echo "$ttl" "$resultat" "${options[arg]}"
                ((arg=arg+1))                                                   # Changement d'option traceroute  
                if [ "${options[arg]}" == "end" ] ; then                        # Si on arrive à la fin du tableau des options
                    echo "->" >> traceroute.txt                                 # Ecrire la flèche
                    echo "\" $ttl Not found \"" >> traceroute.txt               # Ecrire le résultat dans le fichier
                    echo -e "\e[91m $ttl \e[0m"     "¯\_(ツ)_/¯"                     # Afficher l'erreur
                    break
                fi
            fi
        done
        ((ttl=ttl+1))                                                           # Augmenter le TTL pour passer au HOP suivant
        arg="0"                                                                 # Réinitialiser la position dans le tableau
        anti_doublon="$resultat"                                                # Stockage du résultat pour comparer avec le résultat futur      
    done
    echo "->" \"$siteweb\" >> traceroute.txt                                    # Afficher l'adresse cible à la fin du graphe
    ttl="1"
done

##----------------------------------Mise en forme graphe----------------------------------#

echo ""                                                 # Saut de ligne
echo ";" >> traceroute.txt                              # Fin du schéma dot
tr -d '\n' < traceroute.txt > traceroute.dot            # Transformer . texte en dot sans les sauts de ligne
echo "}" >> traceroute.dot                              # Terminer le fichier dot
dot -Tpdf traceroute.dot -o route.pdf                   # Générer le fichier PDF selon le graphe DOT

