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
echo ""                                             # Saut de ligne

#-----------------------------------Variables----------------------------------#
                                              
ttl=1                                               # Nombre de lignes du traceroute
pos="0"                                             # Position dans le tableau des options arguments
boucle='0'                                          # Boucle infinie dans le "while" principal
anti_doublon=""                                     # Correcteur de doublon
hops=$(traceroute $1 -w 1| wc -l)                   # Variable du TTL pour commencer au premier HOP                   
options=("" "-I" "-T"  "-p 53 -U" "-p 67 -U" "-p 25 -T" "-p 80 -T" "-p 443 -T" "-p 21 -T" "-p 22 -T" "-p 53 -T" "end") # Liste des options à tester en argument de la commande traceroute     

#----------------------------------TRACEROUTE----------------------------------#

while [ "$ttl" != "$hops" ] ; do                                            # Boucle Principale / s'arrête quand le nombre de hops calculé auparavant est atteint
    while [ "$boucle" == '0' ]  ; do                                        # Boucle infinie tant que les conditions futures ne "breakent" pas
        resultat=$(traceroute -n -f $ttl -m $ttl -w 1 $1 ${options[pos]} -A | tail -n 1 | awk '{print($2,$3)}')         #Résultat de la commande traceroute stockée, en fonction des options utilisées
        if [ "$resultat" != "* *" ] ; then                                  # Condition si on trouve un résultat non nul
            if [ "$anti_doublon" == "$resultat" ] ; then                    # Condition si c'est un doublon
                break   
            else
                if [ "$ttl" != "1" ] ; then                                 # Condition si c'est la première ligne
                    echo " -> " | tee -a traceroute.txt
                fi
                echo " \" $ttl $resultat \" "| tee -a traceroute.txt        # Afficher le résultat (si le résultat n'est pas nul et que ce n'est pas un doublon)
                ((pos=pos+1))                                               # Incrémentation de la position dans le tableau des options
                break
            fi
        else                                                                # Si on trouve un résultat NUL
            #echo "$ttl" "$resultat" "${options[pos]}"
            ((pos=pos+1))                                                   # Changement d'option traceroute  
            if [ "${options[pos]}" == "end" ] ; then                        # Si on arrive à la fin du tableau des options
                echo "->" | tee -a traceroute.txt
                echo "\" $ttl 'Not found' \""| tee -a traceroute.txt
                break
            fi
        fi
    done
    ((ttl=ttl+1))                                                           # Augmenter le TTL pour passer au HOP suivant
    pos="0"                                                                 # Réinitialiser la position dans le tableau
    anti_doublon="$resultat"                                                # Stockage du résultat pour comparer avec le résultat futur
    
done

#----------------------------------C----------------------------------#

echo ";" | tee -a traceroute.txt                        # Fin du schéma dot
tr -d '\n' < traceroute.txt > traceroute.dot            # Transformer . texte en dot sans les sauts de ligne
echo "}" >> traceroute.dot                              # Terminer le fichier dot
dot -Tpdf traceroute.dot -o route.pdf                   # Générer le fichier PDF selon le graphe DOT