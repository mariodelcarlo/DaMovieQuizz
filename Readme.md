Voilà quelques explications concernant mon code et des idées d’amélioration.

J’ai réalisé une application iPhone qui s’éxecute à partir d’iOS 8. Normalement, je gère les versions à partir d’iOS7 (car il y a encore environ 7% de gens  qui l’utilisent d’après les stats) mais j’ai eu un problème avec l’alertview en mode UIAlertViewStylePlainTextInput donc j’ai utilisé des UIAlertController pour aller plus vite.

Pour ne pas ré-inventer la roue, j’ai utilisé la librairie JLTMDbClient  qui s’appuie sur AFNetWorking qui était citée dans la page API de themoviedb. Elle m’a semblé plus à jour que l’autre proposée. Je l’ai installée via CocoaPods.

J’ai utilisé CoreData pour sauvegarder des informations en base, ayant l’habitude de travailler avec CoreData plutôt que Sqlite et cela est plus pratique pour faire des liens entre acteurs et films qu’un fichier texte.

J'ai décidé de concevoir un jeu simple et pour cela, je me suis limitée aux 40 acteurs et actrices les plus populaires. Donc, je lance la requête person/popular sur les 2 premières pages. Je sauvegarde cette liste en base au premier lancement du jeu. Comme les requêtes sur l'API sont limitées à 40 par secondes, avec simplement ces 2 requêtes, j'ai la base de mon jeu. Possibilté d'amélioration: on pourrait avoir plus d’acteurs et rafraîchir cette liste à chaque nouveau lancement de l'appli, de façon à ce que cette liste soit mise à jour régulièrement. 


Au démarrage d'une partie, je prépare 10 questions à l'avance. Quand il n’y a plus que 2 questions à venir, je re-prépare 10 questions. Ce nombre est une constante paramétrable. A l'avenir cela pourrait permettre de gérer les pertes de réseau et de pré-charger les posters.

Pour gérer le tirage au sort acteur/film et de façon à ce qu'il y'ait 50% de chance que le résultat soit VRAI ou FAUX, voici comment je procède:
- Je choisis au hasard 2 acteurs dans ma base de données, Acteur_A et Acteur_B
- Je récupère la liste des films dans lesquels ils ont joué: 1 liste pour chaque acteur (Je fais une requête dans l’API person/{id}/credits et je sauvegarde en base les films et le lien film/acteur). Attention ici, si je prenais tous les films dans lesquels les 40 acteurs de ma liste ont joué, je me heurterai à la limite des requêtes sur l'API. Ceci dit, nous pourrions augmenter le nombre d'acteurs pris en compte si besoin.
- Je choisis au hasard un des deux acteurs -> Ce sera le nom de l’acteur affiché dans ma question (Acteur_A)
- Je choisis au hasard un film dans lequel Acteur_A a joué
- Je choisis au hasard un film dans lequel A n’a pas joué. Pour cela, je cherche un film dans lequel Acteur_B a joué et ou A n’est pas listé.
- Je choisis au hasard un film parmi ces 2 films->j’ai donc 50% de chances que la réponse soit oui, ce sera le film affiché dans ma question.


Je sauvegarde en base les films au fur et à mesure, et je n’envoie une requête vers l’Api que si je n’ai pas la liste des films pour un acteur donné. Cela limite le nombre de requêtes vers l'API.

L’image de l’affiche du film n’est pas sauvegardée en base: seul le poster_path est sauvé. J’avais peur que cela surcharge la taille de l’appli sur le téléphone, mais du coup, il est nécessaire d’avoir une connexion internet pour jouer. Une solution serait d'afficher le nom du film derrière l'image. Si vraiment le besoin serait d'avoir une application fonctionnelle offline, il faudrait de toute façon récupérer toute la base de données sur le téléphone (avec les problèmes de mises à jour qui en découlent).


J’ai quelques erreurs que je n’ai pas pris le temps de gérer, comme par exemple si la requête en base qui liste les acteurs renvoie une erreur.
Je n’ai pas géré aussi l’affichage du timer si celui-ci dépasse 1h, cela est peu probable mais c’est à faire.

Pour les highs scores, ceux-ci sont sauvés en base. A score égal, on choisit le temps pour savoir quelle partie est la meilleure. Je ne prends pas en compte les scores à 0.

J’ai développé en testant avec un iPhone 5 sous iOS 9.2 et un iPhone6s 9.2.1. J’ai fait quelques tests avec le simulateur sur des iPhone 6, 6plus et 6sPlus pour vérifier les layouts mais cela est resté superficiel pour cause de timing.






