Voilà quelques explications concernant mon code et des idées d’amélioration.

J’ai réalisé une application iPhone qui s’éxecute à partir d’iOS 8. Normalement, je gère les versions à partir d’iOS7 (car il y a encore environ 7% de gens  qui l’utilisent d’après les stats) mais j’ai eu un problème avec l’alertview en mode UIAlertViewStylePlainTextInput donc j’ai utilisé des UIAlertController pour aller plus vite.

Pour ne pas ré-inventer la roue, j’ai utilisé la librairie JLTMDbClient  qui s’appuie sur AFNetWorking qui était citée dans la page API de themoviedb. Elle m’a semblé plus à jour que l’autre proposée. Je l’ai installée via CooaPods.

J’ai utilisé CoreData pour sauvegarder des informations en base, ayant l’habitude de travailler avec CoreData plutôt que Sqlite et cela est plus pratique pour faire des liens entre acteurs et films qu’un fichier texte.

Pour le fonctionnement général, j’ai choisi de sauvegarder au premier lancement du jeu, des acteurs populaires fournis. Je lance la requête person/popular sur les 2 premières pages, ce qui fait 40 acteurs populaires. 
Ensuite, je prépare 10 questions. Quand il n’y a plus que 2 questions à venir, je re-prépare 10 questions. Ce nombre est une constante paramétrable.

Pour gérer le le tirage au sort acteur/film pour qu'il y'ait 50% de chance que le résultat soit VRAI ou FAUX, voici comment je procède:
- Je choisi au hasard 2 acteurs dans ma base de données A et B
- Je récupère la liste des films dans lesquels ils ont joué: 1 liste pour chaque acteur (Je fais une requête dans l’API person/{id}/credits et je sauvegarde en base les films et le lien film/acteur)
- Je choisis au hasard un des deux acteurs -> Ca sera le nom de l’acteur affiché dans ma question, mettons qu’on prenne A
- Je choisis au hasard un film dans lequel A a joué (dans ma liste précédemment calculée)
- Je choisis au hasard un film dans lequel A n’a pas joué. Pour cela, je cherche un film dans lequel B a joué et ou A n’est pas listé comme acteur.
- Je choisis au hasard un film parmi ces 2 films->j’ai 50% de chances que la réponse soit oui ou non, ce sera le film affiché dans ma question

On pourrait améliorer cela en se basant sur plusieurs acteurs et pas seulement 2.

Je sauvegarde en base les films au fur et à mesure, et je n’envoie une requête vers l’Api que si je n’ai pas la liste des films pour un acteur donné.

L’image de l’affiche du film n’est pas sauvegardée en base: seul le poster_path est sauvé. J’avais peur que cela surcharge l’appli mais du coup, il est nécessaire d’avoir une connexion internet pour jouer. On pourrait afficher le nom du film si on a des problèmes de réseau par exemple pour pouvoir continuer à jouer. Une réflexion plus approfondie est à faire à ce niveau la.
Il faudrait aussi avoir plus d’acteurs et rafraîchir cette liste: trouver une meilleure règle à appliquer. 

J’ai quelques erreurs que je n’ai pas pris le temps de gérer, comme par exemple si la requête en base qui liste les acteurs renvoie une erreur et qu’il faudrait gérer.
Je n’ai pas gérer aussi l’affichage du timer si celui-ci dépasse 1h, cela est peu probable mais c’est à faire.

Pour les highs scores, ceux-ci sont sauvés en base. A score égal, on choisit le temps pour savoir quelle partie est la meilleure. Une meilleure partie a un temps plus court.

J’ai développé en testant avec un iPhone 5 sous iOS 9.2, j’ai fait quelques tests avec le simulateur sur des iPhone 6 et 6plus pour vérifier les layouts mais cela est resté superficiel pour cause de timing.






