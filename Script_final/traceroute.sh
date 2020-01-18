#!/bin/bash
#   Les numéros en commentaire indiquent à quel point du fichier READ ME se trouvent 
#   les explications et indications de la ligne commentée.

# - - - - - - - - - - VARIABLES - - - - - - - - - - #

siteweb="$1"                                        #   Le premier Argument est la cible                          
ttl=1                                               #   Commencer par analyser le 1er TTL
arg="0"                                             #   Position dans la liste des paramètres de tests traceroute
boucle='0'                                          #   Boucle infinie
ip_precedente=""                                    #   Stockage de l'adresse IP obtenue à l'itération précédente pour comparaison

#   Liste des paramètres de test traceroute
options=("" "-I" "-T"  "-p 53 -U" "-p 67 -U" "-p 25 -T" "-p 80 -T" "-p 443 -T" "-p 21 -T" "-p 22 -T" "-p 53 -T" "end")
ip_finale=$(nslookup $siteweb| grep Address | tail -n 2 | awk '{print($2)}' | grep -v "#" | grep -v ":")                #   Obtention de l'adresse de destination pour comparaison et arrêt
hops=$(traceroute $siteweb -w 1 | wc -l)            #   Nombre de sauts totaux pour atteindre la cible         

# - - - - - - - - - - SCRIPT - - - - - - - - - - #
                             
echo ""
echo -e "\e[1;96m Cible :\e[0m" $siteweb "($ip_finale)" "| N°$(($3+1))/$4"      # 1     Afficher dans le terminal la cible, son IP et sa position dans la file.
while [ "$ttl" != "$hops" ] ; do                                                    # 2     Jusqu'à atteindre le nombre de hops déterminé auparavant
    while [ "$boucle" == '0' ]  ; do                                                    # 3     Boucle infinie pour n'en sortir qu'en suivant les conditions à venir
        resultat="$(traceroute -n -f $ttl -m $ttl -w 1 -q 1 $siteweb ${options[arg]} -A | tail -n 1 | awk '{print($2,$3)}')"        #   Résultat contenant IP + AS      
        ip_actuelle="$(traceroute -n -f $ttl -m $ttl -w 1 -q 1 $siteweb ${options[arg]} | tail -n 1 | awk '{print($2)}')"           #   Résultat contenant IP seulement, pour comparer avec $ip_finale et $ip_precedente
        if [ "$resultat" != "* " ] ; then                         # 4    
            if [ "$ip_actuelle" == "$ip_finale" ] ; then            # 4.2   
                if [ "$ip_precedente" == "$ip_actuelle" ] ; then        # 4.3   Si c'est un doublon et qu'on a deja atteint la cible,
                    break                                               #       Ne pas en tenir compte.
                else                                                    #   Si c'est la première fois qu'on trouve l'adresse cible,
                    if [ "$ttl" != "1" ] ; then                         #   Pour tous les TTL > 1, 
                    echo "-> " >> $siteweb.txt                          #   insérer une fleche avant le resultat dans le fichier .txt.
                    fi  
                    echo "\"$ttl $resultat\" " >> $siteweb.txt          #   Ecrire le resultat dans le fichier .txt et
                    echo -e "\e[92m $ttl    \e[0m$resultat      "       #   Afficher le resultat dans le terminal.
                    break
                fi
            else                                                    # 4.4                                                    
                if [ "$ttl" != "1" ] ; then                             # 4.5   Pour tous les TTL > 1, 
                    echo "-> " >> $siteweb.txt                          #       insérer une fleche avant le resultat dans le fichier .txt.
                fi 
                if [ "$anti_doublon" == "$resultat" ] ; then                # 4.6    Si c'est un doublon,             
                    echo -e "\e[92m $ttl    \e[0m$resultat      DOUBLON"    #        Afficher que c'est un doublon dans le terminal et
                    echo " \"$ttl DOUBLON $resultat\" " >> $siteweb.txt     #        Insérer le resultat en précisant que c'est un doublon dans le fichier .txt.
                    break
                else                                                            # 4.7    Si c'est un résultat unique,
                    echo "\"$ttl  $resultat\" " >> $siteweb.txt                 #        L'écrire dans le fichier .txt et   
                    echo -e "\e[92m $ttl   \e[0m$resultat      "                #        L'afficher sur le terminal.
                    break
                fi
            fi       
        else                                                       # 4.1                                                         
            ((arg=arg+1))                                          #    Changer de paramètre de test traceroute  
            if [ "${options[arg]}" == "end" ] ; then                        #   Si on a effectué tous les tests mais rien trouvé,                                             
                echo " -> \"$ttl Not found ($siteweb)\"" >> $siteweb.txt    #   Ecrire qu'on a rien trouvé dans la fichier .txt et
                echo -e "\e[91m $ttl \e[0m" "   ¯\_(ツ)_/¯"                  #  Afficher un message d'erreur sur le terminal.
                break
            fi
        fi
    done
    ((ttl=ttl+1))       # 5                                                      
    arg="0"             # Réinitialisation de l'option de test dans la liste des options                                                    
    ip_precedente="$ip_actuelle"        # 5.1
    anti_doublon="$resultat"                                                
done

# - - - - - - - - - - CALCUL TEMPS - - - - - - - - - - #
#   Calcul et affichage du temps utilisé par le script

temps_ecoule=$SECONDS
if [ $temps_ecoule -lt 60 ] ; then                                                                                      #   Si le script a duré moins d'1 minute,
    echo -e "\e[93m         » Cible atteinte en $SECONDS secondes.\e[0m"                                                #   n'afficher que les secondes.
else
    echo -e "\e[93m         » Cible atteinte en $((($SECONDS/60)%60)) minute(s), $(($SECONDS%60)) secondes.\e[0m"       #   Sinon, afficher les minutes et les secondes.
fi

# - - - - - - - - - - ACHEVEMENT - - - - - - - - - - #

echo "-> \"$siteweb\" [color=$2];" >> $siteweb.txt           #  Ajouter le nom de la cible dans une bulle supplémentaire     
tr -d '\n' < $siteweb.txt > $siteweb.rte                     #  Générer une copie du fichier .txt sans les sauts de ligne dans un fichier .rte    
