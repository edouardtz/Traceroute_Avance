#!/bin/bash
#script appelant les autres autant de fois que nécessaire
rm *.txt
rm *.rte
rm *.dot

sites=(
    "perdu.com"
    "rt.unice.fr"
    "cfasup-fc.com"
    "chine-nouvelle.com"
    "mines-ales.fr"
    "iut.fr"
    "onisep.fr"
    "global.bfsu.edu.cn"
    )                           # Liste des adresses web a consulter

nbe_sites=${#sites[@]}
incr=0
echo "digraph traceroute { " > traceroute.dot

while [ $incr != $nbe_sites ]; do
    for cible in "${sites[@]}" ; do
        ./traceroute.sh $cible
        
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