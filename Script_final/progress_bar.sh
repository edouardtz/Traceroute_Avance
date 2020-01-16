#!/bin/bash
# progress bar function
prog() {
    local w=80 p=$1;  shift
    # create a string of spaces, then change them to dots
    printf -v dots "%*s" "$(( $p*$w/100 ))" ""; dots=${dots// /.};
    # print those dots on a fixed-width space plus the percentage etc. 
    printf "\r\e[K|%-*s| %3d %% %s" "$w" "$dots" "$p" "$*"; 
}

sites=(
    "kth.se"   "gov.za"    "school.katsushika.ed.jp"    "rt.unice.fr"    "sergeistrelec.ru"    
    "germaninstitute.de"    "africau.edu"    "zou.ac.zw"    "cfasup-fc.com"    
    "chine-nouvelle.com"    "swissboardinstitute.ch"    "news24.com"    "mines-ales.fr"
    "iut.fr"    "onisep.fr"    "global.bfsu.edu.cn"    "sib.swiss"     
    "www.librarybrunei.gov.bn"      "guiaforte.com.br"      "www.pilersuisoq.gl"
    "hostel.is"
    )                           

# test loop
for x in {1..100} ; do
    prog "$x" still working...
    
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
done
