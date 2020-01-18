# Traceroute

>Github du projet : https://github.com/edouardtz/traceroute
*Edouard TOUZAN - RT2 APP | Janvier 2020*

Ce projet permet de réaliser une cartographie d'internet à l'aide de la commande traceroute.
Il est composé de 2 scripts : script_parent.sh et traceroute.sh




## script_parent.sh :

* Script "pilote", qui commande autant de fois que nécessaire l'exécution du script traceroute.sh.
* Contient les informations et les données necéssaires au lancement d'une analyse traceroute vers une cible donnée. 
	
###	Fonctionnement :

		## PRE-NETTOYAGE ##

* Suppression des fichiers de stockage des résultats résiduels, si l'exécution précédente n'est pas arrivée à terme, pour recréer les fichiers un à un avec les nouvelles données.

		## PREPARATION ##

* Définition des variables et des listes de variables à utiliser en argument de l'exécution du script traceroute.sh.

	La liste des couleurs permet de visualiser une couleur différente pour chaque route sur le graphe final. La dernière valeur de cette liste n'est pas une couleur mais un repère
	pour permettre au script de revenir au début de la liste si le nombre de couleurs devenait insuffisant par rapport au nombre de cibles.
	
	La liste des cibles contient les noms de domaines / sites webs à analyser. Ils sont variés et sont hébergés dans différents pays afin d'observer des chemins divergents.
	Cette liste peut être complétée ou allégée sans impacter le script, il s'adaptera à sa taille dynamiquement via la variable "nbe_sites".
	
	On définit également des variables qui serviront à incrémenter leur position dans chacune des listes ci-dessus.	
	
		## SCRIPT ##

* Pour chaque cible contenue dans la liste des cibles, on exécute le script "traceroute.sh"  avec en arguments : la cible, la couleur, et la position de la cible dans le tableau.
* La position de la cible dans le tableau permet de visualiser la progression du script complet plus facilement.
	Si la dernière couleur a été utilisée mais qu'il reste des cibles à analyser, la position dans la lsite des couleurs est réinitialisée, comme expliqué auparavant.
	
* Quand toutes les analyses ont été effectuées, on aura obtenu un fichier .txt et .rte pour chaque cible. Le fichier .rte est la mise en forme du fichier .txt pour l'insertion des données dans le fichier
	final .DOT.
	On rassemble alors les données de chacun des fichiers .rte dans le fichier .dot. Chaque ligne correspond à un chemin vers une cible. Ainsi, le nombre de lignes vaut le nombre de cibles.

		## ACHEVEMENT ##
	
* Après écriture des données dans le fichier commun, on ferme la syntaxe dot avec le caractère "}" pour que DOT puisse interpréter son contenu.
* On génère alors un graphe au format PDF, montrant les chemins que nous venons d'analyser.
* Pour signaler à l'utilisateur que le script s'est correctement achevé, on affiche un message de succès et le temps total d'exécution du script.

		## POST-NETTOYAGE ##

* Suppression des fichiers .txt et .rte à présent inutiles.

---

## traceroute.sh :
	
* Script "piloté" par le script parent.
* Il effectue une analyse de chacun des sauts intermédiaires entre le client et la cible pour obtenir le numéro de saut, l'adresse IP et le numéro d'AS de chacun. On veut essayer de pallier à un
	maximum d'éventualités et obtenir un résultat en s'adaptant le plus possible à chacun des cas. Ce script est amené à être exécuté plusieurs fois de suite par le script parent et s'adapte donc
	aux conditions qu'il lui impose.

### Fonctionnement :

>   Les numéros en commentaire dans le script indiquent à quel point du fichier READ ME se trouvent 
   les explications et indications de la ligne commentée.

		## VARIABLES ##

* Définition des variables. La variable de la cible correspond au premier argument donné lors de l'exécution du script, on l'identifie par le nom "siteweb". On définit également les variables qui seront
	amenées à être incrémentées et à stocker des résultats temporaires ("ip_precedente").
	
	La liste "options" contient les paramètres à utiliser dans le cas ou un résultat non satisfaisant soit obtenu par le paramètre précédent. Ces paramètres utilisés en argument de la commande traceroute
	permettent d'utiliser un port ou un protocole différent, car des noeuds peuvent en filtrer certains.
	
	La variable "ip_finale" permet d'obtenir l'adresse de la cible et de la comparer plus tard avec le résultat trouvé pour chaque hop. Si le hop que l'on vient de trouver possède la même IP que la destination,
	alors la cible est atteinte. J'utilise NSLOOKUP pour ne pas utiliser traceroute pour réduire les possibilités d'erreur.

	On compte également le nombre de hops necessaires pour atteindre la cible pour s'arrêter quand on arrive à ce nombre ce nombre de sauts.

		## SCRIPT ##

1.  Affichage pour l'utilisateur de la cible et de son adresse IP déterminée précedemment
	
2.  Entrée dans la boucle tant que le nombre de hops définis précédemment n'est pas atteint, on exécute ce qui suit.
	
3. Initialisation d'une boucle WHILE infinie, afin d'utiliser des conditions précises pour en sortir par la suite
	
4. On détermine le résultat d'una analyse pour le HOP donné, à l'aide du TTL défini au début. Tant l'on n'obtient pas de réponse, on recommence  grâce à la boucle while ci-dessus
	jusqu'à tester tous les paramètres de la liste "options". 
		
    4.1 Si malgré tout on n'obtient pas de résultat, c'est que le routeur / noeud interrogé est muet, on affiche alors un message d'erreur et on passe au TTL suivant.

	4.2 Dans le cas où l'on obtient une réponse, on la compare tout d'abord avec l'adresse IP finale que nous devons atteindre. Si elles sont identiques, alors la cible est atteinte.
		Comme l'analyse continue, on souhaite ne pas tenir compte du résultat des prochains sauts qui afficheront en boucle l'adresse finale. 
		
	4.3 Ainsi, si l'adresse que l'on découvre après avoir atteint notre destination est la même que celle de destination que nous avons deja atteinte, alors on n'en tient pas compte.
		Cela sert à vérifier qu'on n'obtient pas de doublon après avoir atteint l'objectif.

	4.4 Si en revanche l'adresse IP finale n'est pas encore atteinte, soit tous les hops précédents le dernier, on l'affiche sous certaines conditions.
		
	4.5 Pour la mise en forme du fichier contenant les données, on insère une flèche "->" dans le fichier avant le résultat uniquement si le saut concerné n'est pas le premier.
		Cela permet d'afficher les flèches nécessaires au graphe uniquement pour les TTL supérieurs a 1 et ne pas créer d'erreur de graphe.
		
	4.6 On verifie que le resultat que l'on a obtenu, qui nous a permis d'arriver jusqu'ici, est un doublon ou non du précédent.
		Si c'est le cas, on l'affiche tout de même mais en précisant qu'il a été détecté comme dupliqué. C'est une exception de routage.

	4.7 Si ce n'est pas un doublon, mais un résultat unique comme on cherche à obtenir à l'origine, alors on se contente de l'afficher.		

5. Après avoir obtenu un résultat (ou pas) pour le TTL donné, on incrémente celui-ci pour analyser le saut suivant à la prochaine itérationde la boucle WHILE parente.
		
	5.1 On conserve en mémoire la dernière adresse IP que nous avons obtenu et le dernier résultat pour les comparer à la prochaine itération de la boucle et identifier les doublons.

		## CALCUL TEMPS ##

* On souhaite afficher le temps nécessaire au sript pour atteindre la cible. On utilise pour cela la variable "$SECONDS" de bash.
	Pour un meilleur affichage, on vérifie s'il est inférieur à une minute ou pas pour n'afficher que les secondes si on n'a pas depassé 1 minute.
	
		## ACHEVEMENT ## 

* Fin de l'insertion des données dans fichier .txt associé à la cible, en rajoutant comme dernière bulle le nom de domaine de la cible.
	On utilise alors le deuxième argument donné lors de l'éxécution du script pour préciser la couleur du chemin.
	
* Mise en forme des données du fichier .txt dans le fichier .rte, en supprimant les sauts de ligne. Dans le fichier .txt, on a inséré un saut de ligne à chaque nouvelle insertion, corrige donc cela
	en vue du rassemblement des routes dans un fichier .dot plus tard.

Documentation Graphviz : 
    - https://www.graphviz.org/doc/info/colors.html
    - https://graphviz.gitlab.io/_pages/doc/info/lang.html
