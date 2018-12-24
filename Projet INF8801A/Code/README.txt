Les deux fichiers les plus importants sont "main.m" et "sift_compare.m". 

- Le fichier "main.m" fait la simulation du vecteur de fisher sur une image provenant
du dossier "data" avec les images de test. Il est possible de changer l'image de test pour voir des r�sultats possiblement diff�rents.
Il suffit de faire un "run" sur matlab pour tester le fonctionnement.

- Le fichier "sift_compare.m" permet de faire la d�tection d'objet � partir de la m�thode SIFT. Il est possible de changer l'image de test en d�but de programme. 
Il suffit de faire un "run" sur matlab pour tester le fonctionnement.

- La fonction fisher_score.m et permet de trouver le vecteur de fisher avec la r�gion dans laquelle devrait se trouver l'objet avec une correlation entre le vecteur de fisher
de l'objet et le vecteur de fisher de la r�gion. Plus elle est forte, plus on peut �tre s�r que l'objet se trouve dans la r�gion trouv�e. Il y a 5 r�gions possibles et chaque r�gion est
d�limit� par deux carr�s qui ont une intersection entre eux. La taille des carr�s provient de l'article. Par exemple, dans la r�gion 1, les carr�s
font 0.5 fois la taille de l'objet qu'on cherche. (Voir pr�sentation pour voir les r�gions possibles, slide 23).
La fonction prend en param�tres l'image et la r�gion dans laquelle on voudrait creer l'objet � d�tecter.

- La fonction get_gmm permet de construire un mod�le de mixture de gaussiennes pour l'image servant � la d�tection de l'image (Voir pr�sentation pour plus de d�tails.)
