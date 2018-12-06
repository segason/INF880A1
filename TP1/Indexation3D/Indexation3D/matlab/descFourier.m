classdef descFourier
    %DESCFOURIER Descripteur de forme de Fourier
    %   calcule le contour de la forme, et retourne
    %   sa transformée de Fourier normalisée
    
    properties (Constant = true)
        nbPoints = 128; % nombre de points du contour
        descSize = 16; % fréquences du spectre à conserver
    end
    
    properties
       values; % spectre du contour (taille 'nbFreq') 
    end
    
    methods
         % constructeur (à  partir d'une image blanche sur noire)
         function dst = descFourier(shape)
             
            % Vous pouvez utiliser les fonctions matlab :
            % bwtraceboundary, interp1, etc..
            
            % TODO Question 1 :
            dst.values = zeros(1,descFourier.descSize);
            x = -1;
            y = -1;
            indicei = 1;
            direction = '';
            while ( indicei < size(shape,1)) && (y < 0)
                indicej = 1;
                while ( indicej < size(shape,1)) && (x < 0)
                    if shape(indicei, indicej) ~= 0
                        x = indicei;
                        y = indicej;
                        
                    end
                    indicej = indicej +1;
                end
                indicei = indicei +1;
            end
            
            if (x ~= - 1) && (y ~= -1)
                if  ((x - 1) > 0) && shape(x - 1, y + 1) ~= 0
                        direction = 'ne';
                elseif ((x - 1) > 0) && shape(x - 1, y) ~= 0
                        direction = 'n';
                elseif shape(x, y+1) ~= 0
                    direction = 'e';
                elseif shape(x+1, y + 1) ~= 0
                    direction = 'se';
                elseif shape(x+1, y) ~= 0
                    direction = 's';
                else
                    direction = 'e';
                end
            
            else
                x = 0;
                y = 0;
                direction = 'e';
            end
            
            
            contour = bwtraceboundary(shape,[x y], direction);
            contourcomplexe = contour(:, 1)+ 1i*contour(:, 2);
            contourEchantillonne = interp1(contourcomplexe, linspace(1, length(contourcomplexe), 128));
            TF = fft(contourEchantillonne);
            TF_invariant_rot = abs(TF);
            TF_invariant_rotettrans = TF_invariant_rot(2:length(TF));
            TF_invariant_total = TF_invariant_rotettrans/TF_invariant_rot(2);
            dst.values = TF_invariant_total;
            
         end
         
         % distance entre deux descripteurs
        function d = distance(desc1, desc2)
           
            d = mean(abs(desc1.values - desc2.values));
        end
    end
    
end

