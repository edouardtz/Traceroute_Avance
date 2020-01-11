#!/bin/bash
#script appelant les autres autant de fois que nécessaire
rm -f *.txt
rm -f *.rte
rm -f *.dot
pos="1"
couleurs=(
    "blue"
    "red"
    "green"
    "cyan"
    "black"
    "violet"
    "greenyellow"
    "hotpink"
    "magenta"
    "orange"
    "brown"
    "yellow"
    "crimson"
    "gold"
    "royalblue"
    "forestgreen"
    "grey"
    "indigo"
    "mediumspringgreen"
    "break"
    )
sites=(
    "perdu.com"
    "kth.se"
    "acu.edu.au"
    "gov.za"
    "school.katsushika.ed.jp"
    "rt.unice.fr"
    "sergeistrelec.ru"
    "germaninstitute.de"
    "africau.edu"
    "zou.ac.zw"
    "cfasup-fc.com"
    "chine-nouvelle.com"
    "swissboardinstitute.ch"
    "news24.com"
    "mines-ales.fr"
    "iut.fr"
    "onisep.fr"
    "global.bfsu.edu.cn"
    "sib.swiss"
    )                           # Liste des adresses web a consulter

nbe_sites=${#sites[@]}
incr=0
echo "digraph traceroute { " > traceroute.dot



while [ $incr != $nbe_sites ]; do
    for cible in "${sites[@]}" ; do  
        ./traceroute.sh $cible ${couleurs[pos]}
        ((pos=pos+1))
        if [ ${couleurs[pos]} == "break" ] ; then
            pos="1"
        fi
        ((incr=incr+1))
    done
    for cible in "${sites[@]}" ; do
        cat $cible.rte >> traceroute.dot
        echo "" >> traceroute.dot    
    done   
done
echo "}" >> traceroute.dot
dot -Tpdf traceroute.dot -o route.pdf
echo "Fini !" 