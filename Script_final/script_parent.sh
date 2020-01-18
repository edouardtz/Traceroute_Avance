#!/bin/bash
#script appelant les autres autant de fois que nécessaire

# - - - - - - - - - - PRE-NETTOYAGE - - - - - - - - - - #
#   Dans le cas où le script ne s'est pas terminé, effacer les fichiers intermédiaires résidus.

rm -f *.txt
rm -f *.rte
rm -f *.dot

# - - - - - - - - - - PREPARATION - - - - - - - - - - #

#   Liste des couleurs de flèches
#   Si la liste est épuisée car trop de sites, on revient au début de la liste.

couleurs=(
    "blue"  "red"   "green"    "cyan"    "black"    "violet"    "greenyellow"   "lightsalmon"
    "hotpink"    "magenta"    "orange"    "brown"    "yellow"    "coral"    "lightseagreen"
    "gold"    "royalblue"    "forestgreen"    "grey"    "indigo"    "orangered" "peru"
    "break"
    )

#   Liste des adresses web a consulter
#   On peut y ajouter ou supprimer des entrées sans impacter le script

sites=(
     "kth.se"    "gov.za"    "school.katsushika.ed.jp"    "rt.unice.fr"    "sergeistrelec.ru"    
    "germaninstitute.de"    "africau.edu"    "cfasup-fc.com"    "railway.co.th"
    "chine-nouvelle.com"    "swissboardinstitute.ch"    "news24.com"    "mines-ales.fr"
    "iut.fr"    "onisep.fr"    "sib.swiss"    "www.librarybrunei.gov.bn"      "guiaforte.com.br"      
    "www.pilersuisoq.gl"    "hostel.is"
    )                           

nbe_sites=${#sites[@]}                           #  Nombre d'entrées dans la liste de sites sous forme de valeur numérique
incr=0                                           #  Variable d'incrémentation de la boucle de la liste des sites
pos="1"                                          #  Variable d'incrémentation dans la liste des couleurs
# - - - - - - - - - - SCRIPT - - - - - - - - - - #

echo "digraph traceroute { " > traceroute.dot                                   #   Début du fichier DOT
while [ $incr != $nbe_sites ]; do                                               #   Pour autant de fois que de cibles
    for cible in "${sites[@]}" ; do                                             #   Pour chaque cible
        ./traceroute.sh $cible ${couleurs[pos]} $incr $nbe_sites                #   Exécuter le script traceroute.sh avec en argument la cible et la couleur
        ((pos=pos+1))                                                           #   Incrémentation de la position dans la liste des couleurs
        if [ ${couleurs[pos]} == "break" ] ; then                               #   Retour au debut de la liste des couleurs si on atteint la fin de la liste
            pos="1"
        fi
        ((incr=incr+1))                                                         #   Incrémentation de la boucle WHILE
    done
    for cible in "${sites[@]}" ; do                                             #   Pour chaque cible
        cat $cible.rte >> traceroute.dot                                        #   Transférer le contenu de chaque fichier individuel à la suite du fichier conteneur principal DOT
        echo "" >> traceroute.dot                                               #   Aller à la ligne dans entre chaque nouvelle insertion dans le fichier DOT
    done   
done

# - - - - - - - - - - ACHEVEMENT - - - - - - - - - - #

echo "}" >> traceroute.dot                                                      #   Finir le fichier DOT
dot -Tpdf traceroute.dot -o route.pdf                                           #   Convertir le fichier conteneur principal en PDF a l'aide de DOT
echo ""
echo -e "\e[1;92m               » Succès ! «\e[0m"                              #   Afficher un message de succès + temps d'exécution total
echo "Script exécuté en $(( ($SECONDS/60)%60 )) minute(s), $(($SECONDS%60 )) secondes."           
echo ""

# - - - - - - - - - - POST NETTOYAGE - - - - - - - - - - #
#   Nettoyage des fichier intermédiaires à présent inutiles

rm -f *.txt                                                                     
rm -f *.rte