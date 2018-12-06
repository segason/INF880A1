close all
clear all
clc

%% Effectue un collage avec la méthode de Poisson

folder = 'data/testPoisson/test3/';

% Image à compléter
[src, ~, alpha] = imread([ folder 'src.png' ]);

% Image à coller
target = imread([ folder 'target.png' ]);

% Méthode de Poisson
dst = poissonBlending( src, target, alpha );

imshow(dst);
