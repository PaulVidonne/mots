#!/bin/bash

file="tmp$(date +%m%d-%H%M%S)"
# cp "$0" "$file"
#date

origin=locate.sh
version="3.20 b-20221215"

if [[ $@ == *--version* ]] ; then
   echo -e "\n::: $(basename $0) version : $version\n"
   exit
fi
if [[ $@ == *--help* ]] ; then
echo
cat << EOF
PRESENTATION GENERALE

   Usage   $(basename $0) [--help | --version] motif [OPTIONS]

   Objet  le script $(basename $0) version $version est une sur-couche de la commande 'locate'
          permettant de retouver des fichiers ou répertoires dont la liste figure dans la base
          de données générée par la commande 'updatedb'. Le résultat peut être envoyé dans un
          fichier.

   Motif
          le motif peut comprendre un ou plusieurs mots consitutifs de la chaîne recherchée.
           Le résultat de la commande peut être envoyé dans un fichier.

   Rappel
          les dates de fichiers sous linux sont les suivants (cmd stat)
              Accès  : atime  : dernier accès, peu fiable
              Modif. : mtime  : modification du contenu
              Changt : ctime  : modification des attributs
              Créé   : crtime : création du fichier, pas tjs documenté

   Restitutions
          les dates des fichiers et répertoires trouvés peuvent être restitués en dates
          Accès, Modif., Changt, Créé.

   Mise en garde
          le motif est recherché dans tout le path. De ce fait, les résultats mélangent répertoires
          et fichiers pouvant provenir d'un élèment quelconque du path comportant le motif. Comme
          pour la commande shell 'locate', ils peuvent parfois surprendre. A contrario, la commande
          shell 'find' (et le script 'find.sh'), par ailleurs beaucoup plus détaillés, ne relèvent
          que des fichiers et des répertoires. Le script signalera les fichiers détruits depuis la
          génération de la base en mentionnant au regard de leur nom 'Aucun fichier ou dossier de
          de ce type' (contairement à la commande shell qui ne repose que sur la base de données
          générée par 'updatedb'). Les fichiers créés postérieurement à la mise à jour de la base
          ne seront pas reconnus. Il en résulte qu'il faut  mettre à jour la base de données par
          'updatedb' avant d'exécuter $(basename $0).

          Le recours aux caractères de substitution ("jokers") en ligne de commande est déconseillé,
          les résultats pouvant être imprévisibles ou erronés.

OPTIONS

   -rm   les dates des résultats sont des dates Modif. (defaut)
   -ra   les dates des résultats sont des dates Accès
   -rc   les dates des résultats sont des dates Changt
   -rb   les dates des résultats sont des dates Créé

   -s    le résultat est sensible à la casse

   -p    le résultat est envoyé dans un fichier intitulé "locate.txt" avec vidage
         de ce fichier s'il existe déjà.

   -q    le résultat est ajouté à un fichier intitulé "locate.txt".

DIVERS

   exécutabilité
         ce script a été réalisé sous GNU bash, version 5.2.9(1)-release-(x86_64-redhat-
         linux-gnu). Il ne suppose l'installation d'aucun module particulier.

   bugs  merci de signaler bugs et suggestions à : paul at vidonne point fr

   licence
         Copyright (c) $(date +%Y) Paul Vidonne. Ce script peut être librement exécuté,
         diffusé et modifié dans les conditions de la 'Creative Commons Attribution-
         NonCommercial-ShareAlike 3.0 Unported License' (CC-BY-NC-SA) publiée par Creative
         Commons. Il est mis à disposition "tel quel", SANS AUCUNE GARANTIE de quelque
         nature que ce soit et auprès de qui que ce soit. Plus d'informations (en anglais)
         sur la licence à <https://creativecommons.org/licenses/by-nc-sa/3.0/>, texte
         intégral à  <https://creativecommons.org/licenses/by-nc-sa/3.0/legalcode>.

$(basename $0)/$origin              version : $version                               ----
EOF
echo
exit
fi
echo
usage()
{
   echo -e "::: Usage $(basename $0) [--help | --version] motif [OPTIONS]"
}

if [[ -z $@ ]] ;then
  usage
  echo -e "::: Absence de motif de recherche. Abandon\n"
   exit
fi
#if [[ $@ == *['!'@#$%^\&*()_+]* ]] : Match contre Glob. Echapper les caractères estimés spéciaux
# par le shell est inutile si les catactères ? et * sont déjà développés par le shell
if [[ $@ == *[*?]* ]]
   then
   usage
   echo -e "::: Commande '$(basename $0) $@' non interprétable. Abandon\n"
  exit
fi

# pattern=$(sed -E 's/( -r(m|a|c|b)|-r(m|a|c|b) )//g' <<< $@)
pattern=$(sed -E 's/(\s*-r(m|a|c|b)\s*)|\s*-(p|q|s)//g' <<< $@)
# traitement des patterns spéciaux
if [[ "$pattern" == *"-"* ]] ; then
    pattern="-- \\$pattern"
fi
if ! [[ $@ == *-p* || $@ == *-q* ]] ; then
   fichier_sortie="/dev/null"
else
   fichier_sortie="locate.txt"
   if [[ $@ == *-p* ]] ; then
      $(> locate.txt)
   fi
   echo -e ":::========================================================================" >> $fichier_sortie
   echo -e "::: Script : $(basename $0) -- Date : $(date) -- Commande ($@)\n" >> $fichier_sortie
fi

if ! [[ $@ == *-s* ]] ; then
   casse=-i
   echo -e "::: Résultats insensibles à la casse de la commande" | tee -a $fichier_sortie
else
   echo -e "::: Résultats sensibles à la casse de la commande" | tee -a $fichier_sortie
fi

if [ -f /var/lib/plocate/plocate.db ] ; then
   last_modif=$(stat --format=%y '/var/lib/plocate/plocate.db' | sed 's/\.[0-9]*//g')
   echo -e "::: Résultats issus du dernier updatedb le : $last_modif " | tee -a $fichier_sortie
fi

message="::: Résultats en date de dernière modification. Recherche de la chaîne : "$pattern

for i in $@ ; do
   if [ $i == "-rm" ] ; then
      message="::: Résultats daté de dernière modification. Recherche de la chaîne : "$pattern
      temps=""
   elif [ $i == "-ra" ] ; then
      message="::: Résultats datée de dernier accès. Recherche de la chaîne : "$pattern
      temps="--time=atime"
   elif [ $i == "-rc" ] ; then
      message="::: Résultats daté de dernier changement d'attributs. Recherche de la chaîne : "$pattern
      temps="--time=ctime"
   elif [ $i == "-rb" ] ; then
      message="::: Résultats en date de création. Recherche de la chaîne : "$pattern
      temps="--time=birth"
   fi
done

echo -e "\n$message" | tee -a $fichier_sortie

/usr/bin/locate $casse $pattern | xargs --delimiter="\n" -r ls -Ald $temps | tee /dev/tty \
| tee -a $fichier_sortie | wc -l | xargs echo "::: Nombre d'occurence(s) :" | tee -a $fichier_sortie

echo -e "\n::: Temps d'exécution : $(($SECONDS/3600)) heure(s), $(($SECONDS%3600/60)) minute(s) et\
 $(($SECONDS%60)) seconde(s)\n" | tee -a $fichier_sortie


# note : voir /etc/profile.d/custom.sh ; le set -f est passé avant l'appel de la fonction bloque
# le globbing

