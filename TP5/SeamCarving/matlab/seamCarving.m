function [ dst ] = seamCarving( src, newHeight, newWidth )
%SEAMCARVING Redimensionne une image en préservant son contenu
%   Ne supprime que les pixels ne contenant pas d'information
%   Calcule d'abord la carte d'energie de l'image (contenu)
%   Puis calcule des 'seam' à enlever de l'image,
%   par programmation dynamique
%   Attention : src et dst peuvent avoir un nombre quelconque de canaux (4
%   ou plus, par exemple).

    % On redimensionne horizontalement
    dst = resizeH( src, newWidth );
    
    % On redimensionne verticalement
    dst = permute( dst,[2,1,3] ); % on tourne de 90deg
    dst = resizeH( dst, newHeight );
    dst = permute( dst,[2,1,3] );
end

% redimensionne horizontalement une image
function [ dst ] = resizeH( src, newWidth )

    % Choisit entre enlever ou ajouter des pixels
    if newWidth < size(src,2)
        dst = shrinkH( src, newWidth );
    else
        dst = enlargeH( src, newWidth );
    end
end

% Supprime des seams verticales
function dst = shrinkH( src, newWidth )

    % TODO : Question 3
    nIterations = size(src, 2) - newWidth;
    srcHeight = size(src, 1);
    srcWidth = size(src, 2);
    srcChannel = size(src, 3);
    tempWidth = srcWidth - 1;
    oldImageWidth = srcWidth;
    
    oldImage = src;
    
    tempEnergy = getEnergy(src);
    tempPathCosts = pathsCost(tempEnergy);
    bestSeam = getSeam(tempPathCosts);
    jnewImage = 1;
    
    for n = 1 : nIterations
       newImage = zeros(size(src, 1), tempWidth, srcChannel);
       for i = 1 : srcHeight
           targetSeam = bestSeam(i);
           for j = 1 : oldImageWidth
               if targetSeam ~= j
                   newImage(i, jnewImage, :) = oldImage(i, j, :);   
                   jnewImage = jnewImage + 1;
               end
           end
          jnewImage = 1;
       end
       
       oldImage = newImage;
       tempWidth = tempWidth - 1;
       tempEnergy = getEnergy(oldImage);
       tempPathCosts = pathsCost(tempEnergy);
       bestSeam = getSeam(tempPathCosts);
       oldImageWidth = size(oldImage, 2);
        
    end
    
    dst = newImage;
    
end

% Duplique les pixels de seams verticales
function dst = enlargeH( src, newWidth )

    % TODO : Question 4
    nIterations = newWidth - size(src, 2);
    srcHeight = size(src, 1);
    srcWidth = size(src, 2);
    srcChannel = size(src, 3);
    tempWidth = srcWidth - 1;
    oldImageWidth = srcWidth;
    oldImage = src;

    tempEnergy = getEnergy(src);
    tempPathCosts = pathsCost(tempEnergy);
    bestSeam = getSeam(tempPathCosts);
    bestSeams = double(zeros(srcHeight, nIterations));
    bestSeams(:, 1) = bestSeam(:); 
    jnewImage = 1;
    enlargedImage = double(zeros(srcHeight, newWidth, srcChannel));

    for n = 1 : nIterations - 1
        newImage = zeros(size(src, 1), tempWidth, srcChannel);
        for i = 1 : srcHeight
            targetSeam = bestSeam(i);
            for j = 1 : oldImageWidth
                if targetSeam ~= j
                    newImage(i, jnewImage, :) = oldImage(i, j, :);   
                    jnewImage = jnewImage + 1;
                end
            end
            jnewImage = 1;
        end

       oldImage = newImage;
       tempWidth = tempWidth - 1;
       tempEnergy = getEnergy(oldImage);
       tempPathCosts = pathsCost(tempEnergy);
       bestSeam = getSeam(tempPathCosts);
       bestSeams(:, n + 1) = bestSeam(:);
       oldImageWidth = size(oldImage, 2);
   end

   jEnlargedImage = 1;
   for i = 1 : srcHeight
      for j = 1 : srcWidth 
          found = 0;
          for k = 1 : nIterations
            if bestSeams(i, k) == j
                found = found + 1;
            else
                disp(j);
            end
          end
          if found == 0
            enlargedImage(i, jEnlargedImage, :) = src(i, j, :);
            jEnlargedImage = jEnlargedImage + 1;
          else
            
            enlargedImage(i, jEnlargedImage, :) = src(i, j, :);
            for nSeam = 1 : found
                enlargedImage(i, jEnlargedImage + nSeam, :) = src(i, j, :);
            end
            jEnlargedImage = jEnlargedImage + found + 1;
         end
      end
      jEnlargedImage = 1;
   end

   dst = enlargedImage;
        
end