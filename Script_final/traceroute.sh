#!/bin/bash
#   Ce script est appelé par le script_parent.sh pour générer un fichier de route pour une seule adresse à la fois. 
#   Plusieurs instance de ce script doivent être appelée à la fois, 1 par adresse recherchée.
#   Execution du script avec pour argument le site cible   --   commandé par le script parent.

# - - - - - - - - - - VARIABLES - - - - - - - - - - #

siteweb="$1"                                        
ttl=1                                               
arg="0"                                             
boucle='0'                                          
ip_precedente=""                                     
options=("" "-I" "-T"  "-p 53 -U" "-p 67 -U" "-p 25 -T" "-p 80 -T" "-p 443 -T" "-p 21 -T" "-p 22 -T" "-p 53 -T" "end") 

ip_finale=$(nslookup $siteweb| grep Address | tail -n 2 | awk '{print($2)}' | grep -v "#" | grep -v ":")

hops=$(traceroute $siteweb -w 1 | wc -l)            

# - - - - - - - - - - SCRIPT - - - - - - - - - - #

                                   
echo ""
echo -e "\e[1;96m Cible :\e[0m" $siteweb "($ip_finale)" "| N°$(($3+1))/$4"
while [ "$ttl" != "$hops" ] ; do                                            
    while [ "$boucle" == '0' ]  ; do                                        
        resultat=$(traceroute -n -f $ttl -m $ttl -w 1 -q 1 $siteweb ${options[arg]} -A | tail -n 1 | awk '{print($2,$3)}')         
        ip_actuelle=$(traceroute -n -f $ttl -m $ttl -w 1 -q 1 $siteweb ${options[arg]} | tail -n 1 | awk '{print($2)}')
        if [ "$resultat" != "* " ] ; then                                   
            if [ "$ip_actuelle" == "$ip_finale" ] ; then
                if [ "$ip_precedente" == "$ip_actuelle" ] ; then
                    break
                else
                    if [ "$ttl" != "1" ] ; then                                
                    echo "-> " >> $siteweb.txt
                    fi  
                    echo "\"$ttl $resultat\" " >> $siteweb.txt                 
                    echo -e "\e[92m $ttl    \e[0m$resultat      "
                    break
                fi
            else    
                if [ "$ttl" != "1" ] ; then                                
                    echo "-> " >> $siteweb.txt
                fi        
                if [ "$anti_doublon" == "$resultat" ] ; then                    
                    echo -e "\e[92m $ttl    \e[0m$resultat      DOUBLON"
                    echo " \"$ttl DOUBLON $resultat\" " >> $siteweb.txt  
                    break
                else
                    echo "\"$ttl  $resultat\" " >> $siteweb.txt                 
                    echo -e "\e[92m $ttl   \e[0m$resultat      "               
                    ((arg=arg+1))                                               
                    break
                fi
            fi       
        else                                                                
            ((arg=arg+1))                                                   
            if [ "${options[arg]}" == "end" ] ; then                                                         
                echo " -> \"$ttl Not found ($siteweb)\"" >> $siteweb.txt        
                echo -e "\e[91m $ttl \e[0m" "   ¯\_(ツ)_/¯"                
                break
            fi
        fi
    done
    ((ttl=ttl+1))                                                          
    arg="0"                                                                 
    ip_precedente="$ip_actuelle"
    anti_doublon="$resultat"                                                
done

# - - - - - - - - - - CALCUL TEMPS - - - - - - - - - - #

temps_ecoule=$SECONDS
if [ $temps_ecoule -lt 60 ] ; then                                                                     
    echo -e "\e[93m         » Cible atteinte en $SECONDS secondes.\e[0m"                                
else
    echo -e "\e[93m         » Cible atteinte en $((($SECONDS/60)%60)) minute(s), $(($SECONDS%60)) secondes.\e[0m"
fi

# - - - - - - - - - - ACHEVEMENT - - - - - - - - - - #

echo "-> \"$siteweb\" [shape=box,color=$2];" >> $siteweb.txt                
tr -d '\n' < $siteweb.txt > $siteweb.rte                                    
