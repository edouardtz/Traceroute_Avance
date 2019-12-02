#!/bin/bash
> traceroute.txt #Nettoyage du fichier contenant le résultat du script
> traceroute.rte
echo -e "\e[34m
████████╗██████╗  █████╗  ██████╗███████╗██████╗  ██████╗ ██╗   ██╗████████╗███████╗
╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██╔═══██╗██║   ██║╚══██╔══╝██╔════╝
   ██║   ██████╔╝███████║██║     █████╗  ██████╔╝██║   ██║██║   ██║   ██║   █████╗
   ██║   ██╔══██╗██╔══██║██║     ██╔══╝  ██╔══██╗██║   ██║██║   ██║   ██║   ██╔══╝
   ██║   ██║  ██║██║  ██║╚██████╗███████╗██║  ██║╚██████╔╝╚██████╔╝   ██║   ███████╗
   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
   \e[0m"

#Variable de vérification des duplications
anti_dupli=""

#Tableau de test des ports
# liste_ports_udp=("53" "67")
# liste_ports_tcp=("25" "80" "443" "21" "22" "53")

#Teste la présence d'un argument
NULL=""
if [ "$1" == "$NULL" ]
then
	echo " "
	echo -e "\e[1;5;31m Entrez une adresse IP a atteindre !\e[0m"
	echo " "
	else
	#Teste le nombre de HOPs nécessaires pour atteindre la cible
	hops=$(traceroute $1 -w 1| wc -l)
	#~ Exécute la commande traceroute pour chaque HOP
	ttl=1
	while [ $ttl != "$hops" ]; do

for port in "67" "53" ; do
	  test_standard=$(traceroute -n $1 -f $ttl -m $ttl -w 1 -p $port | tail -n 1 | awk '{print($2)}')
    if [ "$test_standard" != "*" ] ; then
      break
    fi
  done
    if [ "$test_standard" == "*" ] ; then # Test avec l'UDP de base
    	test_icmp=$(traceroute -I -n $1 -f $ttl -m $ttl -w 1 -p $port| tail -n 1 | awk '{print($2)}')
    	if [ "$test_icmp" == "*" ] ; then #TEST AVEC ICMP
        for port in "25" "80" "443" "21" "22" "53" ; do
    		  test_tcp=$(traceroute -T -n $1 -f $ttl -m $ttl -w 1 -p $port| tail -n 1 | awk '{print($2)}')
          if [ "$test_tcp" != "*" ] ; then
            break
          fi
        done
    		if [ "$test_tcp" == "*" ] ; then #TEST AVEC TCP
    			echo -e "$ttl Erreur" | tee -a traceroute.rte
          #~ A RESOUDRE : sortir si trop d'erreurs
    		else
          if [ "$anti_dupli" == "$test_tcp" ]; then
            break
          else
            anti_dupli="$test_tcp"
            echo -e "$ttl $test_tcp - TCP - Port $port" | tee -a traceroute.rte
            ((ttl=ttl+1))
          fi
    		fi
    	else
        if [ "$anti_dupli" == "$test_icmp" ]; then
          break
        else
          anti_dupli="$test_icmp"
          echo -e "$ttl $test_icmp - ICMP - Port $port" | tee -a traceroute.rte
    		  ((ttl=ttl+1))
        fi
    	fi
    else
      if [ "$anti_dupli" == "$test_standard" ]; then
        break
      else
        anti_dupli="$test_standard"
        echo -e "$ttl $test_standard - UDP - Port $port" | tee -a traceroute.rte
    	  ((ttl=ttl+1))
      fi
    fi
	done


chmod 777 traceroute.rte
# chmod 777 traceroute.txt
fi





#-----------[ A GARDER DE COTE ]---------------
	#~ for test_entrytype in `seq 1 9` ; do
	#~ first_char = $(cut -c 1 $1)
		#~ if [ $first_char = $test_entrytype ]; then
			#~ echo "test"
			#~ entrytype = "ip_addr"
		#~ else
			#~ entrytype = "domain"
			#~ echo "hello"
		#~ fi
	#~ done
#~ echo $entrytype



#~ if [ $test_icmp == "*" ] ; then # Sinon, tester avec ICMP
				#~ traceroute -I -n $1 -f $ttl -m $ttl -w 1| tail -n 1 | awk '{print($1,$2" ICMP")}'
				#~ ((ttl=ttl+1))
				#~ echo "cest pas de l'udp"
			#~ else
			#~ echo "ah bah zut alors"
			#~ fi

 #~ | tee -a traceroute.rte     -> pour rediriger le résultat d'une commande vers un fichier
