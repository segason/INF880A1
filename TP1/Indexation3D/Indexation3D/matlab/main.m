
clear all
close all
clc

%% Test des descripteurs

shape1 = imread('../test/cheval.png');
shape2 = imread('../test/avion.png');

% Descripteur de fourier
figure; d = descFourier(shape1); plot(d.values); title('Descripteur de Fourier 1');
figure; d = descFourier(shape2); plot(d.values); title('Descripteur de Fourier 2');

% Descripteur de Zernike
figure; d = descZernike(shape1); plot(d.values); title('Descripteur de Zernike 1');
figure; d = descZernike(shape2); plot(d.values); title('Descripteur de Zernike 2');

%% Base de données de plusieurs objets

% Ce programme permet d'effectuer des requètes dans
% une base de donnée d'objets 3D. Pour cela, il calcule
% un descripteur pour chaque objet.

% chemin du dossier contenant les modèles 3D (.obj) :
dbDir = '../test/obj/';
% dossier contenant les rendus 2D des modèles
renderDir = '../test/renders/';
if ~exist(renderDir,'dir'), mkdir(renderDir), end;

% Map contenant les noms de fichiers (clée)
% et leurs descripteurs (valeur) :
database = containers.Map;

% on essaie de la charger depuis le disque, si elle existe déjà
% ATTENTION : Ne pas oublier de supprimer le fichier si le code du descripteur change
% try load('database.mat'), catch, end;

%% Construction de la base de données (DB)

% On liste les fichiers de la DB et les ajoute à 'database'
h = waitbar(0,'Pre-Traitement de la base de données');
dirList = dir(dbDir);
for i = 1:length(dirList)
    file = dirList(i);
    if ~ file.isdir
        
        % nom du fichier
        name = file.name;
        
        % si le fichier appartient déjà à la DB, on passe au suivant
        if database.isKey(name), continue; end;
        
        % on fait un rendu de l'objet en une image
        
        % le nom de l'image : on remplace l'extension .obj par .png
        dots = strfind(name,'.');
        baseName = name(1:dots(end)-1);
        renderName = [ renderDir baseName '.png'];
        
        % si le rendu n'existe pas, on le fait
        if ~ exist(renderName,'file')
           
            % on utilise le logiciel MeshRenderer.exe
            % Si vous ne l'avez pas, compilez-le à  partir
            % de son code C++ (c.f. sujet)
            system(['MeshRenderer.exe ' dbDir name ' ' renderName]);
            
        end
        
        % on charge le rendu de l'objet
        try
            render = imread(renderName);
        catch e
            disp([e.message ' with ' renderName]); % erreurs potentielles si un fichier est corrompu
            continue;
        end
        
        % on calcule son descripteur (c'est la partie à compléter !)
        entry.descriptor = descripteur(render);

        % on sauvegarde la DB sur le disque pour
        % ne pas avoir à refaire les calculs la prochaine fois
        save('database.mat','database');
        
        database(name) = entry; % clée associée : nom de l'objet
        
        waitbar( i/length(dirList), h );
        
    end;
end
close(h);

%% comparaison entre tous les objets
% On calcule la différence entre chaque paires d'objets
% Et on conserve le résultat dans une matrice

% distance entre chaque paires
keys = database.keys;
n = length(keys);
distances = zeros(n);
h = waitbar(0,'Calcul des distances de chaque paires');
count = 0;
for i = 1:n
   
   disp(keys{i});
   
   for j = i+1:n
       mod1 = database(keys{i});
       mod2 = database(keys{j});
       
       d = mod1.descriptor.distance(mod2.descriptor);
       distances(i,j) = d;
       distances(j,i) = d;
       
       count = count+1;
       waitbar( count / ((n-1)*n/2), h );
   end
end
close(h);

figure;
image(64*distances./max(distances(:))); colormap('gray'); colorbar();
title('distances entre chaque paires');
% remplacer les _ par des - dans les noms
set(gca, 'xTick', linspace(1,n,n));
set(gca, 'xTickLabel', strrep(keys,'_','-'));
set(gca, 'yTick', linspace(1,n,n));
set(gca, 'yTickLabel', strrep(keys,'_','-'));