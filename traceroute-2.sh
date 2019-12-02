#!/bin/bash
> traceroute.txt #Nettoyage du fichier contenant le résultat du script
> traceroute.rte
ttl=1
echo ""
# Variables
hops=$(traceroute $1 -w 1| wc -l)
options=("" "-I" "-T"  "-p 53 -U" "-p 67 -U" "-p 25 -T" "-p 80 -T" "-p 443 -T" "-p 21 -T" "-p 22 -T" "-p 53 -T" "end")
incrementation='0'
pos="0"
boucle='0'
anti_doublon=""
#Début boucle
while [ "$ttl" != "$hops" ] ; do
    while [ "$boucle" == '0' ] 
    do
        resultat=$(traceroute -n -f $ttl -m $ttl -w 1 $1 ${options[pos]} -A | tail -n 1 | awk '{print($2,$3)}') 
        if [ "$resultat" != "* *" ] ; then
            if [ "$anti_doublon" == "$resultat" ] ; then
                break
            else
                echo "$ttl" "$resultat"| tee -a traceroute.rte
                ((pos=pos+1))
                break
            fi
        else
            #echo "$ttl" "$resultat" "${options[pos]}"
            ((pos=pos+1))      
            if [ "${options[pos]}" == "end" ] ; then
                echo $ttl "Not found" | tee -a traceroute.rte
                 break              
            fi
        fi
    done
    ((ttl=ttl+1))
    pos="0"
    anti_doublon="$resultat"
done