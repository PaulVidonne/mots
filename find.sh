#!/bin/bash

# file="tmp$(date +%m%d-%H%M%S)"
# cp "$0" "$file"
# date

version="1.03 b-20221129"

if [[ $@ == *--help* ]] ; then
echo
cat << EOF
PRESENTATION GENERALE

   Usage   $(basename $0) [--help | --version] [OPTIONS]

   Objet  le script $(basename $0) version $version est une sur-couche de la commande 'find'
          permettant de retouver des fichiers ou répertoires à partir de leurs dates, de
          partie ou totalité de leur nom ou de leur contenu.

   Recherches
          Le motif de recherche (fichier, répertoire) est traité sans égard pour la casse.
          Sans joker, le motif est recherché strictement. Il n'est pas recherché dans le path,
          mais seulement dans les noms de fichiers et de répertoires. Les fichiers et
          répertoires peuvent être recherchés à partir de leurs dates Accès, Modif. Changt.
          Attention : Créé n'est pas implémenté. Le texte présent dans les fichiers est
          également recherché sans égard pour la casse.

   Profondeur des recherches
          nombre de sous-répertoires examinés à partir de la racine saisie. La profondeur "0"
          correspond à la racine. Pour une recherche non limitée faire RC (retour chariot).

   Restitutions
          les dates des fichiers et répertoires trouvés peuvent être donnés en  dates
          Accès, Modif., Changt, Créé.

   Rappels
          les dates de fichiers sous linux sont les suivants (cmd stat)
              Accès  : atime  : dernier accès, peu fiable
              Modif. : mtime  : modification du contenu
              Changt : ctime  : changement des attributs
              Créé   : crtime : création du fichier, pas tjs documenté

          les noms de fichiers ne peuvent contenir les caractères '\ / " < > $' et ne
          peuvent être précédés du signe '-'.

OPTIONS

         -cm   les dates de recherche sont des dates Modif. (defaut)
         -ca   les dates de recherche sont des dates Accès
         -cc   les dates de recherche sont des dates  Changt
         -rm   les dates des résultats sont des dates Modif. (defaut)
         -ra   les dates des résultats sont des dates Accès
         -rc   les dates des résultats sont des dates Changt
         -rb   les dates des résultats sont des dates Créé
         -p    le résultat est envoyé dans un fichier intitulé "find.txt" avec vidage de
               ce fichier s'il existe déjà.
         -q    le résultat est ajouté à un fichier intitulé "find.txt".

DIVERS

   exécutabilité
          ce script a été réalisé sous GNU bash, version 5.1.8(1)-release-(x86_64-redhat-
          linux-gnu). Il ne suppose l'installation d'aucun module particulier.

   bugs   merci de signaler bugs et suggestions à : paul at vidonne point fr

   licence
          Copyright (c) $(date +%Y) Paul Vidonne. Ce script peut être librement exécuté,
          diffusé et modifié dans les conditions de la 'Creative Commons Attribution-
          NonCommercial-ShareAlike 3.0 Unported License' (CC-BY-NC-SA) publiée par Creative
          Commons. Il est mis à disposition "tel quel", SANS AUCUNE GARANTIE de quelque
          nature que ce soit et auprès de qui que ce soit. Plus d'informations (en anglais)
          sur la licence à <https://creativecommons.org/licenses/by-nc-sa/3.0/>, texte
         intégral à  <https://creativecommons.org/licenses/by-nc-sa/3.0/legalcode>.

$(basename $0)                      version : $version                               ----
EOF
echo
exit
fi
if [[ $@ == *--version* ]] ; then
   echo -e "\n::: $(basename $0) version : $version\n"
   exit
fi
# syntaxe : =~ ^regex$
if ! [[ $(sed -E 's/(-c(m|a|c)|-r(m|a|c|b)|-p|-q)//g' <<< $@) =~ ^( )*$ ]] ; then
  echo -e "\n::: Présence d'option(s) non reconnue(s) en ligne de commande '$@'. Abandon. \n"
  exit
fi
if [[ $@ == *-cm* ]] ; then
   test=-newermt
   limites="dernière modification contenu"
elif [[ $@ == *-ca* ]] ; then
   test=-newerat
   limites="dernier accès"
elif [[ $@ == *-cc* ]] ; then
   test=-newerct
   limites="dernier changement d'attribut"
else
   test=-newermt
   limites="dernière modification contenu"
fi

if [[ $@ == *-rm* ]] ; then
   temps=""
   temps_result="dernière modification contenu"
elif [[ $@ == *-ra* ]] ; then
   temps="--time=atime"
   temps_result="dernier accès"
elif [[ $@ == *-rc* ]] ; then
   temps="--time=ctime"
   temps_result="dernier changement d'attributs"
elif [[ $@ == *-rb* ]] ; then
   temps="--time=birth"
   temps_result="création"
else
   temps=""
   temps_result="dernière modification contenu"
fi

echo -e "\n::: Les dates suivantes sont des dates de $limites"
read -p "::: Date début recherche, format YYYY-MM-JJ [HH:MM] : " debut
if [ -z "$debut" ] ; then
    debut="1970-01-01"
fi

if ! ( [[ $debut =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}){0,1}$ ]] && \
       [[ $(date -d "$debut" >/dev/null 2>&1 ; echo $?) == 0 ]] ) ; then
   echo -e "\n::: Date '$debut' invalide. Abandon\n"
   exit
fi

read -p "::: Date fin recherche, format YYYY-MM-JJ [HH:MM] : " fin
if [ -z "$fin" ] ; then
    fin="2999-12-31"
fi
if ! ( [[ $fin =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}){0,1}$ ]] && \
       [[ $(date -d "$fin" >/dev/null 2>&1 ; echo $?) == 0 ]] ) ; then
   echo -e "\n::: Date '$fin' invalide. Abandon\n"
   exit
fi

if [[ "$debut" > "$fin" ]] ; then
   echo -e "\n::: Date de début '$debut' supérieure à date de fin '$fin'. Abandon.\n"
   exit
fi

read -p "::: Répertoire de recherche, à partir de : " racine
if [ -z ${racine} ] ; then
   echo -e "\n::: Le répertoire de recherche n'est pas défini. Abandon.\n"
   exit
fi
if ! [ -d $racine ] ; then
    echo -e "\n::: Le répertoire $racine n'existe pas. Abandon\n"
    exit
fi

read -p "::: Profondeur de recherche à partie de '$racine' : " rep

if [ -z ${rep} ] ; then
   maxdepth=
   rep="non limitée"
   elif [[ "${rep}" =~ ^[+]?[0-9]+$ ]] ; then
      maxdepth="-maxdepth $(($rep +1))"
else
   echo -e "\n::: La profondeur de recherche '$rep' n'est pas un nombre acceptable. Abandon\n"
   exit
fi

read -p "::: Nom du ou des fichiers recherchés (jokers possibles) : " nom
if [ -z "$nom" ] ; then
   nom="*"
fi

if [[ "${nom}" =~ ^[-]|[\/\"\<\>$] ]] ; then
   echo -e "\n::: Présence de caractère(s) dans '$nom' non autorisé(s) dans un nom de fichier. Abandon\n"
   exit
fi

read -p "::: Texte présent dans le ou les fichiers : " contenu

if ! [[ $@ == *-p* || $@ == *-q* ]] ; then
   fichier_sortie="/dev/null"
else
   fichier_sortie="find.txt"
   if [[ $@ == *-p* ]] ; then
      $(> find.txt)
   fi
   echo -e "\n:::=======================================================================" >> $fichier_sortie
   echo -e "::: Script : $(basename $0) -- Date : $(date) -- Commande ($@)" >> $fichier_sortie
fi

echo -e "\n::: FICHIERS : Commande : '$(basename $0) $@' ; Racine : '$racine' ; Profondeur : $rep ; Début : '$debut' ; Fin : '$fin' " \
        | tee -a $fichier_sortie
echo -e "::: Temps des limites : $limites ; Nom recherché : '$nom' ; Temps des résultats : $temps_result" | \
        tee -a $fichier_sortie
find "$racine" $maxdepth $test "$debut"  -not $test "$fin"  -type f -iname "$nom" -print0  | xargs -0 -r ls -ltr $temps \
        | tee /dev/tty | tee -a $fichier_sortie | wc -l | xargs echo "::: Nombre de fichiers(s) :" | tee -a $fichier_sortie

echo -e "\n::: REPERTOIRES : Commande : '$(basename $0) $@' ; Racine : '$racine' ; Profondeur : $rep ; Début : '$debut' ; Fin : '$fin' " \
        | tee -a $fichier_sortie
echo -e "::: Temps des limites : $limites ; Nom recherché : '$nom' ; Temps des résultats : $temps_result" | \
        tee -a $fichier_sortie
find "$racine" $maxdepth $test "$debut"  -not $test "$fin"  -type d -iname "$nom" -print0  | xargs -0 -r ls -dltr $temps \
        | tee /dev/tty | tee -a $fichier_sortie | wc -l | xargs echo "::: Nombre de répertoires(s) :" | tee -a $fichier_sortie

if ! [ -z "$contenu" ] ; then
   echo -e "\n::: FICHIERS qui, de plus, contiennent '$contenu' (fichier:ligne numéro:ligne)" | tee -a $fichier_sortie
   find "$racine" $maxdepth $test "$debut"  -not $test "$fin"  -type f -iname "$nom" -print0  | xargs -0 grep -H -n -i \
        "$contenu" 2>&1 | sed 's/grep: //' | tee /dev/tty | tee -a $fichier_sortie | wc -l | xargs echo "::: Nombre d'occurence(s) :" \
        | tee -a $fichier_sortie
fi

if [[ $@ == *-p* || $@ == *-q* ]] ; then
   echo -e "\n::: Les résultats ci-dessus figurent dans le fichier : $(pwd)/find.txt" | tee -a $fichier_sortie
fi

echo -e "\n::: Temps d'exécution : $(($SECONDS/3600)) heure(s), $(($SECONDS%3600/60)) minute(s) et $(($SECONDS%60)) \
seconde(s)\n" | tee -a $fichier_sortie

