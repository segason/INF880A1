close all
clear all

%% test sur une image

% image de test
src = imread('data/testGist/street.jpg');
figure; imshow(src); title('Image de test');

% calcul du descripteur
desc = descGist(src);

% affichage des valeurs du descripteur
figure; image(64*desc.display());
title('descripteur GIST');

%% Base de données d'images

% dossier de test
dbDir = './data/testGist/';

% Map contenant les noms de fichiers (clée)
% et leurs descripteurs (valeur) :
database = containers.Map;

% on essaie de la charger depuis le disque, si elle existe déjà
% ATTENTION : supprimer le .mat si le code du descripteur change
%try load('database.mat'), catch, end;

% On liste les fichiers de la DB et les ajoute à 'database'
h = waitbar(0,'Calcul des descripteurs');
dirList = dir(dbDir);
for i = 1:length(dirList)
    file = dirList(i);
    if ~ file.isdir
        
        % nom du fichier
        name = file.name;
        
        % si le fichier appartient déjà à la DB, on passe au suivant
        if database.isKey(name), continue; end
        
        % on calcule son descripteur (c'est la partie à compléter !)
        database(name) = descGist(imread([ dbDir name ]));

        % on sauvegarde la DB sur le disque pour ne pas
        % avoir à refaire les calculs la prochaine fois
        save('database.mat','database');
        
        waitbar( i/length(dirList), h );
        
    end
end
close(h);

%% comparaison entre toutes les images

% distance entre chaque paires
keys = database.keys;
n = length(keys);
distances = zeros(n);
for i = 1:n
   
   disp(keys{i});
   
   for j = i+1:n
       mod1 = database(keys{i});
       mod2 = database(keys{j});
       
       d = mod1.distance(mod2);
       distances(i,j) = d;
       distances(j,i) = d;
   end
end
distances = distances/max(distances(:));

% on affiche aussi le descripteur sur la diagonale
dS = 128;
distances = imresize(distances,dS,'nearest');
for i = 1:n
   descView = database(keys{i}).display();
   distances( ...
       dS*(i-1)+1 : dS*i, ...
       dS*(i-1)+1 : dS*i ...
   ) = imresize( 0.5*descView, [dS,dS] );
end

% on affiche finalement les distances
figure;
image(64*distances); colormap('bone');
title('distances entre chaque paires');
% remplacer les _ par des - dans les noms
set(gca, 'xTick', linspace(dS/2,dS*n-dS/2,n));
set(gca, 'xTickLabel', strrep(keys,'_','-'));
set(gca, 'yTick', linspace(dS/2,dS*n-dS/2,n));
set(gca, 'yTickLabel', strrep(keys,'_','-'));
