function [means, covariances, priors, ll, posteriors] = get_gmm(descriptor, numClusters, dimension)
%GET_MM Summary of this function goes here
%   Detailed explanation goes here


%%


%init gmm

% Run KMeans to pre-cluster the data
[initMeans, assignments] = vl_kmeans(descriptor, numClusters,'Algorithm','Lloyd','MaxNumIterations',5);
initCovariances = zeros(dimension,numClusters);
initPriors = zeros(1,numClusters);

% Find the initial means, covariances and priors
for i=1:numClusters
    descriptor_k = descriptor(:,assignments==i);
    initPriors(i) = size(descriptor_k,2) / numClusters;

    if size(descriptor_k,1) == 0 || size(descriptor_k,2) == 0
        initCovariances(:,i) = diag(cov(descriptor'));
    else
        initCovariances(:,i) = diag(cov(descriptor_k'));
    end
end

% Run EM starting from the given parameters
[means,covariances,priors,ll,posteriors] = vl_gmm(descriptor, numClusters, ...
    'initialization','custom', ...
    'InitMeans',initMeans, ...
    'InitCovariances',initCovariances, ...
    'InitPriors',initPriors);

end

