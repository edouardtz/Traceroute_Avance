#!/bin/bash
#script appelant les autres autant de fois que nécessaire

BEFORE_s=$SECONDS                 #   Variable de début du compteur de temps
#---------------------< Pré - nettoyage >---------------------#
#   Dans le cas où le script ne s'est pas terminé, effacer les fichiers intermédiaires résidus.
rm -f *.txt
rm -f *.rte
rm -f *.dot
pos="1"
#---------------------< Liste des couleurs de flèches >---------------------#
couleurs=(
    "blue"  "red"   "green"    "cyan"    "black"    "violet"    "greenyellow"
    "hotpink"    "magenta"    "orange"    "brown"    "yellow"    "crimson"
    "gold"    "royalblue"    "forestgreen"    "grey"    "indigo"    "mediumspringgreen"
    "break"
    )
#---------------------< Liste des adresses web a consulter >---------------------#
sites=(
#    "perdu.com"    "kth.se"    "acu.edu.au"    "gov.za"    "school.katsushika.ed.jp"
#    "rt.unice.fr"    "sergeistrelec.ru"    "germaninstitute.de"    "africau.edu"
#    "zou.ac.zw"    "cfasup-fc.com"    "chine-nouvelle.com"    "swissboardinstitute.ch"
    "news24.com"    "mines-ales.fr"    "iut.fr"    #"onisep.fr"    "global.bfsu.edu.cn"
#    "sib.swiss"
    )                           

nbe_sites=${#sites[@]}
incr=0
echo "digraph traceroute { " > traceroute.dot
while [ $incr != $nbe_sites ]; do                                               #   Pour autant de fois que de cibles
    for cible in "${sites[@]}" ; do                                             #   Pour chaque cible
        ./traceroute.sh $cible ${couleurs[pos]} $incr $nbe_sites                #   Exécuter le script traceretoure.sh avec en argument la cible et la couleur
        ((pos=pos+1))                                                           #   Incrémentation de la position dans la liste des couleurs
        if [ ${couleurs[pos]} == "break" ] ; then                               #   Retour au debut de la liste des couleurs si on atteint la fin de la liste
            pos="1"
        fi
        ((incr=incr+1))                                                         #   Incrémentation de la boucle
    done
    for cible in "${sites[@]}" ; do                                             #   Pour chaque cible
        cat $cible.rte >> traceroute.dot                                        #   Transférer le contenu de chaque fichier individuel à la suite du fichier conteneur principal
        echo "" >> traceroute.dot                                               #   Aller à la ligne dans entre chaque ajout dans le fichier conteneur principal
    done   
done

echo "}" >> traceroute.dot                                                      #   Finir le fichier conteneur principal
dot -Tpdf traceroute.dot -o route.pdf                                           #   Convertir le fichier conteneur principal en PDF a l'aide de DOT
echo -e "\e[1;92m               » Succès ! «\e[0m"
echo "Script exécuté en $(( ($SECONDS/60)%60 )) minute(s), $(($SECONDS%60 )) secondes."           #   Afficher un message de succès + temps d'éxécution total
echo ""

rm -f *.txt                                                                     #   Nettoyage des fichier intermédiaires
rm -f *.rte
