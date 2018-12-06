function [ dst ] = poissonBlending( src, target, alpha )
%POISSONBLENDING Effectue un collage avec la méthode de Poisson
%   Remplit la zone de 'src' où 'alpha'=0 avec le laplacien de 'target'

    % Le problème de Poisson s'énonce par :
    % 'le laplacien de src est égal à celui de target là où alpha=0'
    % Pour résoudre ce problème, on utilise la méthode de Jacobi :
    % à chaque itération, un pixel est égal à la moyenne de ses voisins +
    % la valeur du laplacien cible
    
    % TODO Question 2 :
    alpha = double(repmat(alpha,[1,1,3]));
    alpha = alpha./max(alpha(:));
    alpha(find(alpha<0.5))=0;
    alpha(find(alpha>=0.5))=1;
    
    src = double(src);
    target = double(target);
    dst = src.* alpha + src.*(1 - alpha);
    
    %Calcul du laplacien
    laplacian = zeros(size(target, 1), size(target, 2), size(target, 3));
    for k = 1:size(target, 3)
        for i = 2:(size(target, 1) - 1)
            for j = 2:(size(target, 2) - 1)
                laplacian(i, j, k) = (4 * target(i , j, k) - target(i - 1, j, k) - target(i + 1, j, k) - target(i, j - 1, k) - target(i, j + 1, k));  
            end
        end
    end
    
    nIterations = 5000;
    prevSrc = src;
    
    %Combler le trou
    for iter = 1 : nIterations
        for k = 1:size(target, 3)
            for i = 2:(size(target, 1) - 1)
                for j = 2:(size(target, 2) - 1)
                    if(alpha(i, j, k) == 0)
                        dst(i, j, k) =  (1 / 4) * (laplacian(i, j, k) + prevSrc(i - 1, j, k) + prevSrc(i + 1, j, k) + prevSrc(i, j - 1, k) + prevSrc(i, j + 1, k));
                    end
                end
            end
        end
        disp(iter);
        prevSrc = dst;
    end
    
    dst = uint8(dst);
end

