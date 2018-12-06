function [ dst ] = clone( src, nbClones )
%CLONE Clone les personnages d'une boucle
%   src : frames de la vidéo (w,h,col,frames)
%   nbClones : nombre de clones (=0 si aucun clonage)

    % arguments par défault
    if nargin < 2, nbClones = 2; end

    % TODO : Question 2
    
    % Init et extraction boucle
    [ startFrame, endFrame ] = getBestLoop( src, 20 );
    
    % Calcul du fond
    somme = double(zeros(size(src, 1),size(src, 2),size(src, 3)));
    for framei = startFrame : endFrame
       somme = somme + double(src(:, :, :, framei)); 
    end
    fond = somme / endFrame;
    
    % Segmentation mouvement
    
        % soustratction et valeur absolue
        
    dst = double(src);
    for framei = startFrame : endFrame
       dst(:, :, :, framei) = abs(dst(:, :, :, framei)-fond); 
    end
    
        % moyennage des canaux couleurs et seuillage
        
    nW = size(src, 1);
    nH = size(src, 2);
    moyenne = double(zeros(size(src, 1), size(src, 2),1,size(src, 4)));
    for framei = startFrame : endFrame
        for w = 1:nW
            for h = 1:nH
                moyenne(w, h, 1, framei) = (double(dst(w, h, 1, framei)) + double(dst(w, h, 2, framei)) + double(dst(w, h, 3, framei)))/3.00;
           end
        end
        matrice = moyenne(:, :, 1, framei);
        maxi = max(matrice(:));
        moyenne(:, :, 1, framei) = moyenne(:, :, 1, framei)./maxi;
        matrice = moyenne(:, :, 1, framei);
        matrice(find(matrice<0.5))=0;
        matrice(find(matrice>=0.5))=1;
        moyenne(:, :, 1, framei) = matrice;
    end

    %Detour des objets 
    for framei = startFrame : endFrame
        for w = 1 : nW
            for h = 1:nH
                if moyenne(w, h, 1, framei) == 0
                    dst(w, h, 1, framei) = 0;
                    dst(w, h, 2, framei) = 0;
                    dst(w, h, 3, framei) = 0;
                end
            end
        end
    end

    
    i = startFrame;
    resultat = double(zeros(size(src, 1),size(src, 2),size(src, 3),size(src, 4)));
    while i <= endFrame
        fondtemp = double(fond);
        for w = 1 : nW
            for h = 1:nH
                if moyenne(w, h, 1, i) == 1
                    fondtemp(w, h, 1) = dst(w, h, 1, i);
                    fondtemp(w, h, 2) = dst(w, h, 2, i);
                    fondtemp(w, h, 3) = dst(w, h, 3, i);
                    
                end
                
                newindice = i + 6;
                if i+6 > endFrame
                    newindice = startFrame + 6 - (endFrame-i);
                end
                
                if moyenne(w, h, 1, newindice) == 1
                    fondtemp(w, h, 1) = dst(w, h, 1, newindice);
                    fondtemp(w, h, 2) = dst(w, h, 2, newindice);
                    fondtemp(w, h, 3) = dst(w, h, 3, newindice);
                end
                
                newindice = i + 12;
                if i+12 > endFrame
                    newindice = startFrame + 12 - (endFrame-i);
                end
                
                if moyenne(w, h, 1, newindice) == 1
                    fondtemp(w, h, 1) = dst(w, h, 1, newindice);
                    fondtemp(w, h, 2) = dst(w, h, 2, newindice);
                    fondtemp(w, h, 3) = dst(w, h, 3, newindice);
                end
                
                resultat(w, h, 1, i) = fondtemp(w, h, 1);
                resultat(w, h, 2, i) = fondtemp(w, h, 2);
                resultat(w, h, 3, i) = fondtemp(w, h, 3);
            end
        end
        i = i+1;
    end
    
    dst = uint8(resultat);   
end

