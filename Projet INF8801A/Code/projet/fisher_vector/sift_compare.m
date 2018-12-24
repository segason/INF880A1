
clear;
clc;
vl_setup;

%% Get images
image = imread('data/1.jpg');
image = rgb2gray(image);
Ia = double(image);
hImage = size(image, 1);
wImage =  size(image, 2);

p3 = [round(3 * hImage / 4), round(wImage / 4)];
dimObject = round(sqrt(hImage * wImage * 0.01));
Ib = image(p3(1, 1) - round(dimObject * 1.25 / 2)  : p3(1, 1) + round(dimObject * 1.25 / 2) , p3(1, 2) - round(dimObject * 1.25 / 2)  : p3(1, 2) + round(dimObject * 1.25 / 2));
Ib = imresize(Ib, [size(Ia, 1), size(Ia, 2)]);

tic

[fa, siftO] = vl_sift(im2single(Ia));
[fb, sift2] = vl_sift(im2single(Ib));

%%
[matches, scores] = vl_ubcmatch(siftO, sift2);
[drop, perm] = sort(scores, 'descend') ;
matches = matches(:, perm) ;
scores  = scores(perm) ;

figure(1) ; clf ;
imagesc(cat(2, Ia, Ib)) ;
axis image off ;
vl_demo_print('sift_match_1', 1) ;

figure(2) ; clf ;
imagesc(cat(2, Ia, Ib)) ;

xa = fa(1,matches(1,:)) ;
xb = fb(1,matches(2,:)) + size(Ia,2) ;
ya = fa(2,matches(1,:)) ;
yb = fb(2,matches(2,:)) ;

hold on ;
h = line([xa ; xb], [ya ; yb]) ;
set(h,'linewidth', 1, 'color', 'b') ;

vl_plotframe(fa(:,matches(1,:))) ;
fb(1,:) = fb(1,:) + size(Ia,2) ;
vl_plotframe(fb(:,matches(2,:))) ;
axis image off ;

vl_demo_print('sift_match_2', 1) ;

toc
