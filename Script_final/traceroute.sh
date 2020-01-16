#!/bin/bash
# Ce script est appelé par le script_parent.sh pour générer un fichier de route pour une seule adresse à la fois. Plusieurs instance de ce script doivent être appelée à la fois, 1 par adresse recherchée.
#Execution du script avec pour argument le site cible   --   commandé par le script parent.
temps_debut=$SECONDS
siteweb="$1"
ttl=1                                               #   Variable du TTL pour commencer au premier HOP
arg="0"                                             #   Position dans le tableau des options arguments
boucle='0'                                          #   Boucle infinie dans le "while" principal
anti_doublon=""                                     #   Correcteur de doublon
options=("" "-I" "-T"  "-p 53 -U" "-p 67 -U" "-p 25 -T" "-p 80 -T" "-p 443 -T" "-p 21 -T" "-p 22 -T" "-p 53 -T" "end") # Liste des options à tester en argument de la commande traceroute


ipaddr=$(nslookup $siteweb | grep Address | tail -n 1 | cut -d " " -f 2)
hops=$(traceroute $siteweb -w 1 | wc -l)                                    #   Nombre de lignes du traceroute
echo ""
echo -e "\e[1;96m Cible :\e[0m" $siteweb "($ipaddr)" "| N°$(($3+1))/$4"
while [ "$ttl" != "$hops" ] ; do                                            #   Boucle Principale / s'arrête quand le nombre de hops calculé auparavant est atteint
    while [ "$boucle" == '0' ]  ; do                                        #   Boucle infinie tant que les conditions futures ne "breakent" pas
        resultat=$(traceroute -n -f $ttl -m $ttl -w 1 -q 1 $siteweb ${options[arg]} -A | tail -n 1 | awk '{print($2,$3)}')         #Résultat de la commande traceroute stockée, en fonction des options utilisées
        if [ "$resultat" != "* " ] ; then                                   #   Condition si on trouve un résultat non nul
            if [ "$anti_doublon" == "$resultat" ] ; then                    #   Condition si c'est un doublon
                break
            else
                if [ "$ttl" != "1" ] ; then                                 #   Condition si c'est la première ligne
                    echo " -> " >> $siteweb.txt
                fi
                #---- TEST EXCEPTIONS A FAIRE ----#          
                echo " \"$ttl $resultat\" " >> $siteweb.txt                 #   Stocker le résultat (si le résultat n'est pas nul et que ce n'est pas un doublon)
                echo -e "\e[92m $ttl    \e[0m$resultat      "               #   Afficher le résultat
                ((arg=arg+1))                                               #   Incrémentation de la position dans le tableau des options
                break
            fi
        else                                                                #   Si on trouve un résultat NUL
            #echo "$ttl" "$resultat" "${options[arg]}"
            ((arg=arg+1))                                                   #   Changement d'option traceroute
            if [ "${options[arg]}" == "end" ] ; then                        #   Si on arrive à la fin du tableau des options
                echo "->" >> $siteweb.txt                                   #   Ecrire la flèche
                echo "\"$ttl Not found ($siteweb)\"" >> $siteweb.txt        #   Ecrire le résultat dans le fichier
                echo -e "\e[91m $ttl \e[0m" "   ¯\_(ツ)_/¯"                  #   Afficher l'erreur
                break
            fi
        fi
    done
    ((ttl=ttl+1))                                                           #   Augmenter le TTL pour passer au HOP suivant
    arg="0"                                                                 #   Réinitialiser la position dans le tableau
    anti_doublon="$resultat"                                                #   Stockage du résultat pour comparer avec le résultat futur
done
temps_ecoule=$SECONDS

if [ $temps_ecoule -lt 60 ] ; then
    echo -e "\e[93m         » Cible atteinte en $SECONDS secondes.\e[0m"
else
    echo -e "\e[93m         » Cible atteinte en $((($SECONDS/60)%60)) minute(s), $(($SECONDS%60)) secondes.\e[0m"
fi

echo "-> \"$siteweb\" [shape="box",color=$2];" >> $siteweb.txt                # Afficher l'adresse cible à la fin du graphe
ttl="1"
echo ""                                                                     #   Saut de ligne
tr -d '\n' < $siteweb.txt > $siteweb.rte                                    #   Transformer . texte en dot sans les sauts de ligne
