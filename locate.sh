#!/bin/bash

file="tmp$(date +%H%M%S)"
#cp "$0" "$file"
#date

version="3.10 b-20221208"

if [[ $@ == *--help* ]] ; then
echo
cat << EOF
PRESENTATION GENERALE

   Usage   $(basename $0) [--help | --version] [OPTIONS] motif

   Objet  le script $(basename $0) version $version est une sur-couche de la commande 'locate'
          permettant de retouver des fichiers ou répertoires dont la liste figure dans la base
          de données générée par la commande 'updatedb'.

   Motif
          le motif peut comprendre un ou plusieurs mots consitutifs de la chaîne recherchée,
          considérée commme unique (contrairement à la commande shell 'locate' qui recherche
          chacun des arguments et ne les concatène pas). Le motif ne doit pas comporter de joker.
          La recherche est sensible à la casse du motif.

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
          le motif est recherché dans tout le path d'un fichier. De ce fait, les résultats
          mélangent répertoires et fichiers. Ils peuvent provenir d'un élèment quelconque du
          path comportant le motif. Dès lors, comme pour la commande shell 'locate', ils peuvent
          parfois surprendre. A contrario, la commande shell 'find' (et le script 'find.sh'),
          par ailleurs beaucoup plus détaillés, ne donnent en résultat que des fichiers ou
          des répertoires. Reposant sur la base de données générée par 'updatedb', contrairement
          à la commande shell, le script ne déclarera pas les fichiers détruits depuis la génération
          de la base en mentionnant au regard de leur nom 'Aucun fichier ou dossier de ce type'.
          De même, les fichiers créés postérieurement à la mise à jour de la base ne seront
          pas reconnus. Il en résulte qu'il faut  mettre à jour la base de données par
          'updatedb' avant d'exécuter $(basename $0).

OPTIONS
          -rm   les dates des résultats sont des dates Modif. (defaut)
          -ra   les dates des résultats sont des dates Accès
          -rc   les dates des résultats sont des dates Changt
          -rb   les dates des résultats sont des dates Créé

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

$(basename $0)                      version : $version                               ----
EOF
echo
exit
fi

if [[ $@ == *--version* ]] ; then
   echo -e "\n::: $(basename $0) version : $version\n"
   exit
fi

if [[ -z $@ ]] ;then
   echo -e "\n::: Absence de motif de recherche. Abandon\n"
   exit
fi

#if [[ $@ == *['!'@#$%^\&*()_+]* ]] : Match contre Glob. Echapper les caractères estimés spéciaux par le shell
if [[ $@ == *[*?]* ]]
then
  echo -e "\n::: Présence de joker. Abandon\n"
  exit
fi

pattern=$(sed -E 's/( -r(m|a|c|b)|-r(m|a|c|b) )//g' <<< $@)

if [[ " $pattern" == *" -"* ]] ; then
   echo -e "\n::: Le motif '$pattern' est incorrect. Abandon.\n"
   exit
fi

if [ -f /var/lib/plocate/plocate.db ] ; then
   last_modif=$(stat --format=%y '/var/lib/plocate/plocate.db' | sed 's/\.[0-9]*//g')
   echo -e "\n::: Résultats datés du dernier updatedb le : $last_modif "
fi

message="::: Résultats en date de dernière modification. Recherche de la chaîne '$pattern'"

for i in $@ ; do
   if [ $i == "-rm" ] ; then
      message="::: Résultats en date de dernière modification. Recherche de la chaîne '$pattern'"
      temps=""
   elif [ $i == "-ra" ] ; then
      message="::: Résultats en date de dernier accès. Recherche de la chaîne '$pattern'"
      temps="--time=atime"
   elif [ $i == "-rc" ] ; then
      message="::: Résultats en date de dernier changement d'attributs. Recherche de la chaîne '$pattern'"
      temps="--time=ctime"
   elif [ $i == "-rb" ] ; then
      message="::: Résultats en date de création. Recherche de la chaîne '$pattern'"
      temps="--time=birth"
   fi
done

echo -e "\n$message"

/usr/bin/locate  "$pattern" | xargs --delimiter="\n" -r ls -Ald $temps | tee /dev/tty | wc -l | xargs echo "::: Nombre d'occurence(s) :"

echo -e "\n::: Temps d'exécution : $(($SECONDS/3600)) heure(s), $(($SECONDS%3600/60)) minute(s) et $(($SECONDS%60)) seconde(s)\n" | tee -a $fichier_sortie


# note : voir etc/profile.d/custom.sh ; le set -f est passé avant l'appel de la fonction bloquant ainsi le globbing
