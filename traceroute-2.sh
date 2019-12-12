#!/bin/bash
> traceroute.txt #Nettoyage du fichier contenant le résultat du script
> traceroute.rte
> traceroute.dot
#echo -e "\e[1;5;31m
#████████╗██████╗  █████╗  ██████╗███████╗██████╗  ██████╗ ██╗   ██╗████████╗███████╗
#╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██╔═══██╗██║   ██║╚══██╔══╝██╔════╝
#   ██║   ██████╔╝███████║██║     █████╗  ██████╔╝██║   ██║██║   ██║   ██║   █████╗
#   ██║   ██╔══██╗██╔══██║██║     ██╔══╝  ██╔══██╗██║   ██║██║   ██║   ██║   ██╔══╝
#   ██║   ██║  ██║██║  ██║╚██████╗███████╗██║  ██║╚██████╔╝╚██████╔╝   ██║   ███████╗
#   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
#   \e[0m"

echo "digraph traceroute { " > traceroute.txt

ttl=1
echo ""
# Variables
hops=$(traceroute $1 -w 1| wc -l)
#echo $hops
((test=hops-1))
#echo "test :" $test
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
                if [ "$ttl" != "1" ] ; then
                    echo " -> " | tee -a traceroute.txt
                fi
                echo " \" $ttl $resultat \" "| tee -a traceroute.txt
                ((pos=pos+1))
                break
            fi
        else
            #echo "$ttl" "$resultat" "${options[pos]}"
            ((pos=pos+1))      
            if [ "${options[pos]}" == "end" ] ; then
                echo "->" | tee -a traceroute.txt
                echo "\" $ttl 'Not found' \""| tee -a traceroute.txt
                break
            fi
        fi
    done

    ((ttl=ttl+1))
    pos="0"
    anti_doublon="$resultat"
    
done

echo ";" | tee -a traceroute.txt
tr -d '\n' < traceroute.txt > traceroute.dot # transformer . texte en dot sans les sauts de ligne
echo "}" >> traceroute.dot