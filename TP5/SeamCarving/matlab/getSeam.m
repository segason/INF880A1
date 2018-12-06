function [ seam ] = getSeam( costs )
%GETSEAM Retourne la seam verticale (un indice par ligne) de coût minimal
%   Remonte les coûts calculés pas la fonction "pathsCost"

    % TODO : Question 2
    h = size(costs,1);
    seam = ones(h,1);
    
    % Recherche du minimum sur la derniere ligne
    mini = costs(size(costs, 1),1);
    rank_mini = 1;
    for j = 1:size(costs, 2)
        if costs(size(costs, 1),j) <= mini
            rank_mini = j;
            mini = costs(size(costs, 1),j);
        end
    end
    seam(1)= rank_mini;
    
    % Recherche du chemin
    i = size(costs, 1)-1;
    indice = 2;
    j = rank_mini;
    while i >= 1
        if j == size(costs, 2)
            minnie = min([costs(i,j) costs(i,j-1)]);
            if costs(i,j) == minnie
                seam(indice) = j;
                prochainj = j;
            else
                seam(indice) = j-1;
                prochainj = j-1;
            end
        elseif j == 1
            minnie = min([costs(i,j) costs(i,j+1)]);
            if costs(i,j) == minnie
                seam(indice) = j;
                prochainj = j;
            else
                seam(indice) = j+1;
                prochainj = j+1;
            end
        else
            minnie = min([costs(i,j) costs(i,j-1) costs(i,j+1)]);
            if costs(i,j) == minnie
                seam(indice) = j;
                prochainj = j;
            elseif costs(i,j-1) == minnie
                seam(indice) = j-1;
                prochainj = j-1;
            else
                seam(indice) = j+1;
                prochainj = j+1;
            end
        end
        indice = indice+1;
        j = prochainj;
        i = i-1;
    end
end

