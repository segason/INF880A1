clear all
close all
clc
%% Partie 1
% Trouver la meilleure boucle dans une vidéo

    %% Lecture de la vidéo
    [ src, frameRate ] = readVideo( '../data/clock_input.avi' );
    
    %% Calcul de la boucle optimale
    % On cherche le couple de frames (début et fin) se ressembant le plus
    [ debut, fin ] = getBestLoop( src, 5 );
    % Début de boucle (inclusif) et fin de boucle (non inclusif)
    dst = src(:,:,:,debut:fin-1);
    
    %% Export en un Gif animé
    % Un gif utilise une carte limitée de couleurs
    
    writeGif( dst, '../data/dstLoop.gif', frameRate );

%% Partie 2
% Cloner des personnages dans une boucle

    [ src, frameRate ] = readVideo( '../data/bmxLoop.mp4' );
    dst = clone( src, 3 );
    writeGif( dst, '../data/dstClone.gif', frameRate );

