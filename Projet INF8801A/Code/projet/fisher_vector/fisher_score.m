function [position, correlation] = fisher_score(image, objectRegion)
    %% Get points in image

    hImage = size(image, 1);
    wImage = size(image, 2);
    p1 = [round(hImage / 4), round(wImage / 4)];
    p2 = [round(hImage / 4), round(3 * wImage / 4)];
    p3 = [round(3 * hImage / 4), round(wImage / 4)];
    p4 = [round(3 * hImage / 4), round(3 * wImage / 4)];
    p5 = [round(hImage / 2), round(wImage / 2)];

    %% Extract object

    dimObject = round(sqrt(hImage * wImage * 0.01));
    
    if objectRegion == 1
        object = image(p1(1, 1) - round(dimObject / 2)  : p1(1, 1) + round(dimObject / 2) , p1(1, 2) - round(dimObject / 2)  : p1(1, 2) + round(dimObject / 2));
        
    elseif objectRegion == 2
        object = image(p2(1, 1) - round(dimObject / 2)  : p2(1, 1) + round(dimObject / 2) , p2(1, 2) - round(dimObject / 2)  : p2(1, 2) + round(dimObject / 2));
        
    elseif objectRegion == 3
        object = image(p3(1, 1) - round(dimObject / 2)  : p3(1, 1) + round(dimObject / 2) , p3(1, 2) - round(dimObject / 2)  : p3(1, 2) + round(dimObject / 2));
        
    elseif objectRegion == 4
        object = image(p4(1, 1) - round(dimObject / 2)  : p4(1, 1) + round(dimObject / 2) , p4(1, 2) - round(dimObject / 2)  : p4(1, 2) + round(dimObject / 2));
        
    elseif objectRegion == 5
        object = image(p5(1, 1) - round(dimObject / 2)  : p5(1, 1) + round(dimObject / 2) , p5(1, 2) - round(dimObject / 2)  : p5(1, 2) + round(dimObject / 2));
    end


    tic
    %% Get Regions
    %0.5, 1, 1.25, 1.5, 2 x size of image

    region1 = image(p1(1, 1) - round(dimObject * 0.5 / 2)  : p1(1, 1) + round(dimObject * 0.5 / 2) , p1(1, 2) - round(dimObject * 0.5 / 2)  : p1(1, 2) + round(dimObject * 0.5 / 2));
    overlapregion1 = image(p1(1, 1) - 2 * round(dimObject * 0.5 / 2)  : p1(1, 1) , p1(1, 2) - 2 * round(dimObject * 0.5 / 2)  : p1(1, 2));

    region2 = image(p2(1, 1) - round(dimObject / 2)  : p2(1, 1) + round(dimObject / 2) , p2(1, 2) - round(dimObject / 2)  : p2(1, 2) + round(dimObject / 2));
    overlapregion2 = image(p2(1, 1) - 2 * round(dimObject / 2)  : p2(1, 1) , p2(1, 2) - 2 * round(dimObject / 2)  : p2(1, 2));

    region3 = image(p3(1, 1) - round(dimObject * 1.25 / 2)  : p3(1, 1) + round(dimObject * 1.25 / 2) , p3(1, 2) - round(dimObject * 1.25 / 2)  : p3(1, 2) + round(dimObject * 1.25 / 2));
    overlapregion3 = image(p3(1, 1) - 2 * round(dimObject * 1.25 / 2)  : p3(1, 1) , p3(1, 2) - 2 * round(dimObject * 1.25 / 2)  : p3(1, 2));

    region4 = image(p4(1, 1) - round(dimObject * 1.5 / 2)  : p4(1, 1) + round(dimObject * 1.5 / 2) , p4(1, 2) - round(dimObject * 1.5 / 2)  : p4(1, 2) + round(dimObject * 1.5 / 2));
    overlapregion4 = image(p4(1, 1) - 2 * round(dimObject * 1.5 / 2)  : p4(1, 1) , p4(1, 2) - 2 * round(dimObject *1.5 / 2)  : p4(1, 2));

    region5 = image(p5(1, 1) - round(dimObject * 2 / 2)  : p5(1, 1) + round(dimObject * 2/ 2) , p5(1, 2) - round(dimObject * 2/ 2)  : p5(1, 2) + round(dimObject * 2/ 2));
    overlapregion5 = image(p5(1, 1) - 2 * round(dimObject * 2/ 2)  : p5(1, 1) , p5(1, 2) - 2 * round(dimObject * 2/ 2)  : p5(1, 2));


    %% Region descriptors
    [F1, D1] = vl_sift(im2single(region1));
    [F11, D11] = vl_sift(im2single(overlapregion1));
    [F2, D2] = vl_sift(im2single(region2));
    [F22, D22] = vl_sift(im2single(overlapregion2));
    [F3, D3] = vl_sift(im2single(region3));
    [F33, D33] = vl_sift(im2single(overlapregion3));
    [F4, D4] = vl_sift(im2single(region4)); 
    [F44, D44] = vl_sift(im2single(overlapregion4)); 
    [F5, D5] = vl_sift(im2single(region5)); 
    [F55, D55] = vl_sift(im2single(overlapregion5)); 

    D1 = double(D1);
    D11 = double(D11);
    D2 = double(D2);
    D22 = double(D22);
    D3 = double(D3);
    D33 = double(D33);
    D4 = double(D4);
    D44 = double(D44);
    D5 = double(D5);
    D55 = double(D55);


    %% Image and objects Descriptors 
    [Features, SiftDescriptorOriginal] = vl_sift(im2single(image));
    [FeaturesObject, SiftDescriptorObject] = vl_sift(im2single(object));

    SiftDescriptorOriginal = double(SiftDescriptorOriginal);
    SiftDescriptorObject = double(SiftDescriptorObject);
    nValues = size(SiftDescriptorOriginal, 1);
    dimension = nValues;
    numClusters = 128;


    %% Get GMM
    [means,covariances,priors,ll,posteriors] = get_gmm(SiftDescriptorOriginal, numClusters, dimension);

    %% Get object fisher vectors

    fisherObject = vl_fisher(SiftDescriptorObject, means, covariances, priors, 'Verbose', 'Normalized');

    %% Get regions fisherVectors

    fisherRegion1 = vl_fisher(D1, means, covariances, priors, 'Verbose', 'Normalized', 'SquareRoot');
    fisherOverlap1 = vl_fisher(D11, means, covariances, priors, 'Verbose', 'Normalized', 'SquareRoot');
    fisherRegion2 = vl_fisher(D2, means, covariances, priors, 'Verbose', 'Normalized', 'SquareRoot');
    fisherOverlap2 = vl_fisher(D22, means, covariances, priors, 'Verbose', 'Normalized', 'SquareRoot');
    fisherRegion3 = vl_fisher(D3, means, covariances, priors, 'Verbose', 'Normalized', 'SquareRoot');
    fisherOverlap3 = vl_fisher(D33, means, covariances, priors, 'Verbose', 'Normalized', 'SquareRoot');
    fisherRegion4 = vl_fisher(D4, means, covariances, priors, 'Verbose', 'Normalized', 'SquareRoot');
    fisherOverlap4 = vl_fisher(D44, means, covariances, priors, 'Verbose', 'Normalized', 'SquareRoot');
    fisherRegion5 = vl_fisher(D5, means, covariances, priors, 'Verbose', 'Normalized', 'SquareRoot');
    fisherOverlap5 = vl_fisher(D55, means, covariances, priors, 'Verbose', 'Normalized', 'SquareRoot');

    %% Get Correlation


    R1 = corr(fisherObject , fisherRegion1);
    R11 = corr(fisherObject , fisherOverlap1);
    R2 = corr(fisherObject, fisherRegion2);
    R22 = corr(fisherObject , fisherOverlap2);
    R3 = corr(fisherObject , fisherRegion3);
    R33 = corr(fisherObject , fisherOverlap3);
    R4 = corr(fisherObject , fisherRegion4);
    R44 = corr(fisherObject , fisherOverlap4);
    R5 = corr(fisherObject , fisherRegion5);
    R55 = corr(fisherObject , fisherOverlap5);
    
    %% Get best correlation
    [correlation, position] = max([R1, R11, R2, R22, R3, R33, R4, R44, R5, R55]);

    toc

end
