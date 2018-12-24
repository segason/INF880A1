clear;
clc;
vl_setup;

%% Get Image

image = imread('data/21.png');
image = rgb2gray(image);
image = double(image);

[region, correlation] = fisher_score(image, 1);
if region == 1 || region == 2
    region = 1;
    
elseif region == 3 || region == 4
    region = 2;
    
elseif region == 5 || region == 6
    region = 3;

elseif region == 7 || region == 8
    region = 4;

elseif region == 9 || region == 10
    region = 5;
    
end

disp(correlation);
disp(region);

