clear all
close all
clc

%% INF8801 TP5 : recadrage
% But : implémenter l'algorithme "Seam Carving"
% http://www.faculty.idc.ac.il/arik/SCWeb/imret/

%% image à redimensionner
src = double(imread('data/src.png'))/255;
figure; imshow(src); title('Image originale');

%% Énergie de l'image
energy = getEnergy( src );
figure; image(energy*64/max(sqrt(energy(:))));
colormap('hot'); title('Énergie de l''image');

%% Énergie cumulée pour atteindre le haut de l'image
costs = pathsCost( energy );
figure; image(costs*64/max(costs(:)));
title('Énergie cumulée pour atteindre le haut');

%% Meilleure seam
seam = getSeam(costs);
seamViz = src;
for y = 1:size(src,1), seamViz(y,seam(y),:) = [1,0,0]; end;
figure; imshow(seamViz); title('Meilleure seam');

%% Redimensionnement avec le seam carving

% downscaling horizontal
dst = seamCarving( src, size(src,1), size(src,2)/1.5);
figure; imshow(dst); title('Suppression de seams');

% upscaling horizontal
dst = seamCarving( src, size(src,1), size(src,2)*1.5);
figure; imshow(dst); title('Ajout de seams');

%% Seam Carving dans le domaine du gradient

src = double(imread('data/camera.png'))/255;
%src = imresize(src,0.5);
%figure; imshow(src); title('Image originale');
newSize = [size(src,1)/1.5, size(src)/1.5];
chans = size(src,3);

% % Seam Carving sur les couleurs
dst = seamCarving( src, newSize(1), newSize(2) );
figure; imshow(dst); title('Dans le domaine des couleurs');

% Seam Carving sur le gradient
srcX = imfilter(src,[-1,1]/2,'replicate'); % gradient en X
srcY = imfilter(src,[-1;1]/2,'replicate'); % gradient en Y

% On ajoute les gradients comme canaux supplémentaires à l'image
src = cat(3,src,srcX,srcY);

% On applique le seamCarving (il faut que votre code puisse gérer
% un nombre indéfini de canaux !)
dst = seamCarving( src, newSize(1), newSize(2) );

% On récupère les gradients redimensionnés
dstX = dst(:,:,chans+1:2*chans); % gradient en X
dstY = dst(:,:,2*chans+1:3*chans); % gradient en Y

% Calcul du laplacien
lap = -(imfilter(dstX,[-1,1]/2,'replicate') + ...
        imfilter(dstY,[-1;1]/2,'replicate'));

% Résolution du problème de poisson (Lap(X) = Y avec Y donné)
dst = poissonIntegration( lap, dst(:,:,1:chans) );
figure; imshow(dst); title('Dans le domaine du gradient');