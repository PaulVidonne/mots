Présentation des fichiers de ce dépôt, à jour le 14/03/2023.
 
# mots #
Ecrit en bash, le logiciel **mots** version 7.00 b-20230314 décompte les mots, les syllabes, les phrases et les caractères d'un texte ou d'une liste ; il calcule la longueur des mots et des phrases et fait leurs moyennes. Il compte la fréquence des caractères et des mots, avec de nombreuses possibilités : il permet par exemple la recherche de la fréquence des mots d'un vocabulaire donné ou d'une longueur donnée. Il calcule tous les indices classiques de lisibilité auxquels il ajoute un indice spécifique. Il calcule trois indicateurs de richesse de vocabulaire. Il comprend de **nombreuses options et sous-options.** Il restitue les données de manière détaillée ou synthétique à l'écran ou dans un fichier de type texte ou PDF. Il peut établir un fichier de sortie au format CSV pour retraitements externes. Il peut traiter des fichiers de grande taille. La version 7.00 ajoute l'analyse des phrases.


*Aide très détaillée : **mots** --help*

# locate.sh #
Le script bash **locate.sh** version 3.20 b-20221215 est une sur-couche de la commande 'locate'  permettant de retouver des fichiers ou répertoires dont la liste figure dans la base de données générée par 'updatedb'. Il donne la liste de fichiers et de répertoires répondant à la recherche, avec leurs meta données (permissions, propriétaire, taille, date). Les dates des fichiers trouvés sont paramétrables et peuvent être les dates de :

* dernière modification (defaut)
* dernier accès
* dernier changement des attributs
* création

*Aide détaillée : **locate.sh** --help*

# find.sh # 
Egalement en bash, le script **find.sh** version 1.04 b-20221214 est aussi une sur-couche de la commande 'find' permettant de retouver des fichiers ou répertoires à partir de leurs dates, de partie ou totalité de leur nom ou de leur contenu. Simplifiant la commande système, le choix des fichiers recherchés repose sur la réponse interactive aux questions suivantes :

* date de début des fichiers recherchés
* date de fin des fichiers recherchés
* répertoire de recherche
* profondeur de la recherche à partir de ce répertoire
* nom ou partie du nom des fichers et répertoires recherchés
* présence d'un texte donné dans les fichiers trouvés

Le résultat distingue les fichiers, les répertoires et les fichiers contenant le texte recherché. 
Le type des dates des fichiers et répertoires tant recherchés que trouvés est paramétrable : 
 
| Type de date           |  Recherche  |  Résultats  | 
| :--------------------- | :---------: | :---------: |
| dernière modification  | oui         | oui         |
| dernier accès          | oui         | oui         |
| dern. modif. attrib.   | oui         | oui         |
| création               | non         | oui         |

Le résultat écran peur être envoyé dans un fichier.

*Aide détaillée : **find.sh** --help*

# financial #
Le script **financial** version 1.10 b-20221111, en python, calcule les montants des remboursements périodiques d'un prêt et publie le tableau d'amortissement. Il se présente sous deux versions : la version complète prend en compte l'inflation estimée et calcule les montants actualisés des payments périodiques (intéret et capital) et des restes dûs ; elle calcule ensuite le coût total effectif de l'opération. La  version simplifiée se rapproche d'une calculette. Les deux versions permettent d'envoyer les résultats dans un fichier. 

*Aide détaillée : **financial** --help*

# litteral #

Ecrit en bash, le script **litteral** version 2.30 b-20221217 transcrit en lettres les nombres saisis en chiffres, en "français de France" actuel, dans le respect des règles énoncées ci-dessous. le résultat est donné en échelle latine longue avec alternance -ion -iard. Le résultat peut être envoyé dans un fichier.

#### Règles orthographiques ####

       Les adjectifs numéraux cardinaux strictement inférieurs à cent sont reliés
       par un trait d'union, sauf quand ils sont reliés par "et" ; "mille" est
       toujours invariable ; "vingt" et "cent" ne prennent le pluriel que lorsqu'ils
       terminent l'adjectif numéral cardinal ; "un" est omis devant "cent" et
       "mille". La réforme de 1990 n'est pas appliquée.

*Aide détaillée : **litteral** --help*

# dow #

Le script bash **dow** version 1.30 b-20230221 établit la correspondance entre les dates du calendrier grégorien, celles du calendrier julien et celles de leurs numéros en "jours juliens" inventés par Joseph Juste Scaliger. La saisie de l'une de ces trois données affiche les deux autres ainsi que le jour de la semaine. Une option affiche le jour de Pâques de l'année.

*Aide détaillée : **dow** --help*

# clean #

Le script bash **clean** version 3.00 b-20221130 recherche les fichiers et répertoires contenant un  motif indiqué, les dénombre et les élimine après confirmation.

*Aide : **clean** --help*

# longli #

Ecrit en bash, le script **longli** version 1.20 b-20221226 compte le nombre de caractères des lignes d'un fichier texte et affiche le début de celles qui dépassent une longueur paramétrable.

*Aide : **longli** --help*

# iban #

Le script bash **iban** version 1.00 b-20230302 calcule le RIB et l'IBAN d'un compte bancaire français à partir des numéros de la banque, du guichet et du compte. Le résultat peut être envoyé dans un fichier.

# triangle #

Just for fun, joli triangle de Pascal



