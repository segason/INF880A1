function [ costs ] = pathsCost( energy )
%PATHCOST Retourne le tableau avec l'énergie cumulée minimale pour 
%   atteindre le bord du haut (avec une seam) en partant de chacun des 
%   pixels. Obtenue par programmation dynamique (du haut vers le bas).

    % TODO : Question 2
    costs = zeros(size(energy));
    for i = 1: size(energy, 1)
        for j = 1: size(energy, 2)
            if i==1 && j == 1
                costs(i, j) = energy(i,j);
            elseif i==1
                costs(i, j) = energy(i,j);
            elseif j==1
                costs(i, j) = energy(i,j) + min([costs(i-1,j) costs(i-1,j+1)]);
            elseif j == size(costs, 2)
                costs(i, j) = energy(i,j) + min([costs(i-1,j-1) costs(i-1,j)]);
            else
                costs(i, j) = energy(i,j) + min([costs(i-1,j-1) costs(i-1,j) costs(i-1,j+1)]);
            end
        end
    end
end

