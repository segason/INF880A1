Les deux fichiers les plus importants sont "main.m" et "sift_compare.m". 

- Le fichier "main.m" fait la simulation du vecteur de fisher sur une image provenant
du dossier "data" avec les images de test. Il est possible de changer l'image de test pour voir des résultats possiblement différents.
Il suffit de faire un "run" sur matlab pour tester le fonctionnement.

- Le fichier "sift_compare.m" permet de faire la détection d'objet à partir de la méthode SIFT. Il est possible de changer l'image de test en début de programme. 
Il suffit de faire un "run" sur matlab pour tester le fonctionnement.

- La fonction fisher_score.m et permet de trouver le vecteur de fisher avec la région dans laquelle devrait se trouver l'objet avec une correlation entre le vecteur de fisher
de l'objet et le vecteur de fisher de la région. Plus elle est forte, plus on peut être sûr que l'objet se trouve dans la région trouvée. Il y a 5 régions possibles et chaque région est
délimité par deux carrés qui ont une intersection entre eux. La taille des carrés provient de l'article. Par exemple, dans la région 1, les carrés
font 0.5 fois la taille de l'objet qu'on cherche. (Voir présentation pour voir les régions possibles, slide 23).
La fonction prend en paramètres l'image et la région dans laquelle on voudrait creer l'objet à détecter.

- La fonction get_gmm permet de construire un modèle de mixture de gaussiennes pour l'image servant à la détection de l'image (Voir présentation pour plus de détails.)
