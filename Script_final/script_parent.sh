#script appelant les autres autant de fois que nécessaire

sites=(
 #   "perdu.com"
 #   "rt.unice.fr"
 #   "cfasup-fc.com"
 #   "chine-nouvelle.com"
 #   "mines-ales.fr"
    "iut.fr"
    "onisep.fr"
    "global.bfsu.edu.cn")                           # Liste des adresses web a consulter

nbe_sites=${#sites[@]}
incr=0

while [ $incr != $nbe_sites ]; do
    for cible in "${sites[@]}" ; do
        ./traceroute.sh $cible
        ((incr=incr+1))
    done
done