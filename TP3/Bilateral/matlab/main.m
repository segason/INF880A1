% Fonction principale du TP sur le filtre bilat�ral

clc
clear all
close all

%% Denoising
% Il s'agit d'une simple application du filtre bilat�ral.

noise = rgb2hsv(imread('data/taj-rgb-noise.jpg'));
figure;
imshow(noise(:,:,3)); title('Image originale (bruit�e)');


% TODO Question 1 :
% filtered = medfilt2(noise(:,:,3), [ 5 5 ], 'symmetric');
edgeMin = min( noise( : ) );
edgeMax = max( noise( : ) );
sigmaSpatial = min( size(noise(:,:,3), 2), size(noise(:,:,3), 1) ) / 50;
sigmaRange = ( edgeMax - edgeMin ) /5;
samplingSpatial = sigmaSpatial;
samplingRange = sigmaRange;
filtered = bilateralFilter( noise(:,:,3), noise(:,:,3), edgeMin, edgeMax, sigmaSpatial, sigmaRange, samplingSpatial, samplingRange);
figure;
imshow(filtered); title('Image filtr�e');

%% Tone mapping
% Il s'agit de compresser la plage d'intensit�es d'une image en pr�servant
% les d�tails. Pour cela, on diminue les contrastes globaux en conservant
% les contrastes locaux.

% lecture de l'image hdr (a partir de 3 expositions diff�rentes)
srcFolder = 'data/hdr/monValley/'; ext = '.jpg';
src = double(imread([srcFolder 'low' ext])) + double(imread([srcFolder 'mid' ext])) + double(imread([srcFolder 'high' ext]));

% normalisation
src = src - min(src(:));
src = src./max(src(:));
figure; imshow(src); title('Réduction uniforme linéaire')

% Filtrage avec filtres Gaussien 
picture = rgb2hsv(src);
gaussianfilteredpicture = imgaussfilt(picture(:,:,3), 150);

%Haute Frequence
hautefreq = picture(:,:,3) - gaussianfilteredpicture;

% renormalisation
hautefreq = hautefreq - min(hautefreq(:));
hautefreq = hautefreq./max(hautefreq(:));

%Remplacement canal V
picture(:, :, 3) = hautefreq;

%Affichage
figure; imshow(hsv2rgb(picture)); title('Resultat filtre Gaussien')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Filtrage avec filtre Bilateral

%ConversionHsv
picture2 = rgb2hsv(src);

edgeMin = min( picture2( : ) );
edgeMax = max( picture2( : ) );
sigmaSpatial = min( size(picture2, 2), size(picture2, 1) ) / 5;
sigmaRange = ( edgeMax - edgeMin ) /6;
samplingSpatial = sigmaSpatial;
samplingRange = sigmaRange;
result2 = bilateralFilter( picture2(:,:,3), picture2(:,:,3), edgeMin, edgeMax, sigmaSpatial, sigmaRange, samplingSpatial, samplingRange);

%Calcul haute frequence
hautefreq = picture2(:,:,3) - result2;

% renormalisation
hautefreq = hautefreq - min(hautefreq(:));
hautefreq = hautefreq./max(hautefreq(:));

%Remplacement canal V
picture2(:, :, 3) = hautefreq;

%Affichage
figure; imshow(hsv2rgb(picture2)); title('Resultat filtre Bilateral')
