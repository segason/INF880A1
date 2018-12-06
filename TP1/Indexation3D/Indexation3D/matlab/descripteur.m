classdef descripteur
    %DESRIPTEUR Descripteur permettant de caractériser simplement une image
    %   Utiliser le constructeur pour l'appliquer sur une image
    
    properties (Constant = true) % variables statiques
        
        % un 'field' est un dodécahèdre.
        % On en prend plusieurs, avec des rotations différentes
        nbFields = 10;
        
        % une vue pour chacun des sommets du dodécahèdre
        nbViewsPerField = 20;
        
        % taille du descripteur de forme d'une seule vue
        descSize = descFourier.descSize + descZernike.descSize;
        
        % rotations (= permutations) possibles d'une dodécahèdre
        permutations = [
            0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19;
            0, 7, 8, 9, 1, 2, 3, 4, 5, 6, 15, 16, 17, 10, 11, 13, 14, 19, 18, 12;
            0, 4, 5, 6, 7, 8, 9, 1, 2, 3, 13, 14, 19, 15, 16, 10, 11, 12, 18, 17;
            1, 2, 3, 4, 0, 7, 8, 9, 10, 11, 12, 13, 14, 5, 6, 16, 17, 18, 19, 15;
            1, 9, 10, 11, 2, 3, 4, 0, 7, 8, 16, 17, 18, 12, 13, 5, 6, 15, 19, 14;
            1, 0, 7, 8, 9, 10, 11, 2, 3, 4, 5, 6, 15, 16, 17, 12, 13, 14, 19, 18;
            2, 3, 4, 0, 1, 9, 10, 11, 12, 13, 14, 5, 6, 7, 8, 17, 18, 19, 15, 16;
            2, 11, 12, 13, 3, 4, 0, 1, 9, 10, 17, 18, 19, 14, 5, 7, 8, 16, 15, 6;
            2, 1, 9, 10, 11, 12, 13, 3, 4, 0, 7, 8, 16, 17, 18, 14, 5, 6, 15, 19;
            3, 4, 0, 1, 2, 11, 12, 13, 14, 5, 6, 7, 8, 9, 10, 18, 19, 15, 16, 17;
            3, 13, 14, 5, 4, 0, 1, 2, 11, 12, 18, 19, 15, 6, 7, 9, 10, 17, 16, 8;
            3, 2, 11, 12, 13, 14, 5, 4, 0, 1, 9, 10, 17, 18, 19, 6, 7, 8, 16, 15;
            4, 0, 1, 2, 3, 13, 14, 5, 6, 7, 8, 9, 10, 11, 12, 19, 15, 16, 17, 18;
            4, 5, 6, 7, 0, 1, 2, 3, 13, 14, 19, 15, 16, 8, 9, 11, 12, 18, 17, 10;
            4, 3, 13, 14, 5, 6, 7, 0, 1, 2, 11, 12, 18, 19, 15, 8, 9, 10, 17, 16;
            5, 6, 7, 0, 4, 3, 13, 14, 19, 15, 16, 8, 9, 1, 2, 12, 18, 17, 10, 11;
            5, 14, 19, 15, 6, 7, 0, 4, 3, 13, 12, 18, 17, 16, 8, 1, 2, 11, 10, 9;
            5, 4, 3, 13, 14, 19, 15, 6, 7, 0, 1, 2, 11, 12, 18, 16, 8, 9, 10, 17;
            6, 7, 0, 4, 5, 14, 19, 15, 16, 8, 9, 1, 2, 3, 13, 18, 17, 10, 11, 12;
            6, 15, 16, 8, 7, 0, 4, 5, 14, 19, 18, 17, 10, 9, 1, 3, 13, 12, 11, 2;
            6, 5, 14, 19, 15, 16, 8, 7, 0, 4, 3, 13, 12, 18, 17, 9, 1, 2, 11, 10;
            7, 0, 4, 5, 6, 15, 16, 8, 9, 1, 2, 3, 13, 14, 19, 17, 10, 11, 12, 18;
            7, 8, 9, 1, 0, 4, 5, 6, 15, 16, 17, 10, 11, 2, 3, 14, 19, 18, 12, 13;
            7, 6, 15, 16, 8, 9, 1, 0, 4, 5, 14, 19, 18, 17, 10, 2, 3, 13, 12, 11;
            8, 9, 1, 0, 7, 6, 15, 16, 17, 10, 11, 2, 3, 4, 5, 19, 18, 12, 13, 14;
            8, 16, 17, 10, 9, 1, 0, 7, 6, 15, 19, 18, 12, 11, 2, 4, 5, 14, 13, 3;
            8, 7, 6, 15, 16, 17, 10, 9, 1, 0, 4, 5, 14, 19, 18, 11, 2, 3, 13, 12;
            9, 1, 0, 7, 8, 16, 17, 10, 11, 2, 3, 4, 5, 6, 15, 18, 12, 13, 14, 19;
            9, 10, 11, 2, 1, 0, 7, 8, 16, 17, 18, 12, 13, 3, 4, 6, 15, 19, 14, 5;
            9, 8, 16, 17, 10, 11, 2, 1, 0, 7, 6, 15, 19, 18, 12, 3, 4, 5, 14, 13;
            10, 11, 2, 1, 9, 8, 16, 17, 18, 12, 13, 3, 4, 0, 7, 15, 19, 14, 5, 6;
            10, 17, 18, 12, 11, 2, 1, 9, 8, 16, 15, 19, 14, 13, 3, 0, 7, 6, 5, 4;
            10, 9, 8, 16, 17, 18, 12, 11, 2, 1, 0, 7, 6, 15, 19, 13, 3, 4, 5, 14;
            11, 2, 1, 9, 10, 17, 18, 12, 13, 3, 4, 0, 7, 8, 16, 19, 14, 5, 6, 15;
            11, 12, 13, 3, 2, 1, 9, 10, 17, 18, 19, 14, 5, 4, 0, 8, 16, 15, 6, 7;
            11, 10, 17, 18, 12, 13, 3, 2, 1, 9, 8, 16, 15, 19, 14, 4, 0, 7, 6, 5;
            12, 13, 3, 2, 11, 10, 17, 18, 19, 14, 5, 4, 0, 1, 9, 16, 15, 6, 7, 8;
            12, 18, 19, 14, 13, 3, 2, 11, 10, 17, 16, 15, 6, 5, 4, 1, 9, 8, 7, 0;
            12, 11, 10, 17, 18, 19, 14, 13, 3, 2, 1, 9, 8, 16, 15, 5, 4, 0, 7, 6;
            13, 3, 2, 11, 12, 18, 19, 14, 5, 4, 0, 1, 9, 10, 17, 15, 6, 7, 8, 16;
            13, 14, 5, 4, 3, 2, 11, 12, 18, 19, 15, 6, 7, 0, 1, 10, 17, 16, 8, 9;
            13, 12, 18, 19, 14, 5, 4, 3, 2, 11, 10, 17, 16, 15, 6, 0, 1, 9, 8, 7;
            14, 5, 4, 3, 13, 12, 18, 19, 15, 6, 7, 0, 1, 2, 11, 17, 16, 8, 9, 10;
            14, 19, 15, 6, 5, 4, 3, 13, 12, 18, 17, 16, 8, 7, 0, 2, 11, 10, 9, 1;
            14, 13, 12, 18, 19, 15, 6, 5, 4, 3, 2, 11, 10, 17, 16, 7, 0, 1, 9, 8;
            15, 16, 8, 7, 6, 5, 14, 19, 18, 17, 10, 9, 1, 0, 4, 13, 12, 11, 2, 3;
            15, 19, 18, 17, 16, 8, 7, 6, 5, 14, 13, 12, 11, 10, 9, 0, 4, 3, 2, 1;
            15, 6, 5, 14, 19, 18, 17, 16, 8, 7, 0, 4, 3, 13, 12, 10, 9, 1, 2, 11;
            16, 8, 7, 6, 15, 19, 18, 17, 10, 9, 1, 0, 4, 5, 14, 12, 11, 2, 3, 13;
            16, 17, 10, 9, 8, 7, 6, 15, 19, 18, 12, 11, 2, 1, 0, 5, 14, 13, 3, 4;
            16, 15, 19, 18, 17, 10, 9, 8, 7, 6, 5, 14, 13, 12, 11, 1, 0, 4, 3, 2;
            17, 10, 9, 8, 16, 15, 19, 18, 12, 11, 2, 1, 0, 7, 6, 14, 13, 3, 4, 5;
            17, 18, 12, 11, 10, 9, 8, 16, 15, 19, 14, 13, 3, 2, 1, 7, 6, 5, 4, 0;
            17, 16, 15, 19, 18, 12, 11, 10, 9, 8, 7, 6, 5, 14, 13, 2, 1, 0, 4, 3;
            18, 12, 11, 10, 17, 16, 15, 19, 14, 13, 3, 2, 1, 9, 8, 6, 5, 4, 0, 7;
            18, 19, 14, 13, 12, 11, 10, 17, 16, 15, 6, 5, 4, 3, 2, 9, 8, 7, 0, 1;
            18, 17, 16, 15, 19, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 3, 2, 1, 0, 4;
            19, 14, 13, 12, 18, 17, 16, 15, 6, 5, 4, 3, 2, 11, 10, 8, 7, 0, 1, 9;
            19, 15, 6, 5, 14, 13, 12, 18, 17, 16, 8, 7, 0, 4, 3, 11, 10, 9, 1, 2;
            19, 18, 17, 16, 15, 6, 5, 14, 13, 12, 11, 10, 9, 8, 7, 4, 3, 2, 1, 0
        ];
    end
    
    properties
       
        % tableau à 3 dimensions :
        % [ descSize, nbViewsPerField, nbFields ]
        values
        
    end
    
    methods
        
        % constructeur (à  partir d'une image d'un lightfield)
        function dst = descripteur(src)
            %   'src' correspond aux 20x10 vues de l'objet 3D,
            %   chacune étant une silhouette blanche sur un fond noir
            %   'dst' est le descripteur concaténé de ces vues
            
            % on sépare chaque vue en une image différente
            h = size(src,1) / descripteur.nbFields; % hauteur d'une vue
            w = size(src,2) / descripteur.nbViewsPerField; % largeur d'une vue

            dst.values = zeros( descripteur.descSize, descripteur.nbViewsPerField, descripteur.nbFields );
            for field = 0:descripteur.nbFields-1
               for view = 0:descripteur.nbViewsPerField-1

                   % on extrait une vue
                   y0 = field*h; x0 = view*w;
                   shape = src( y0+1:y0+h, x0+1:x0+w );

                   % descripteur de forme
                   desc1 = descFourier( shape );
                   desc2 = descZernike( shape );
                   
                   alpha = 0.5; % Pondération entre les deux descripteurs (dans [0;1])
                   viewDesc = [ alpha * desc1.values(:); (1-alpha) * desc2.values(:) ];

                   % on l'ajoute au résultat
                   dst.values( :, view+1, field+1 ) = viewDesc;
               end
            end
        end
        
        % distance entre deux descripteurs
        function d = distance(desc1, desc2)
            % on cherche la meilleure paire de 'fields'
            % entre les deux modèles, et on retourne sa distance
            d = Inf;
            for fieldI1 = 1:descripteur.nbFields
               for fieldI2 = 1:descripteur.nbFields
                  
                   % les vues de chaque 'field'
                   field1 = desc1.values(:,:,fieldI1);
                   field2 = desc2.values(:,:,fieldI2);
                   
                   % pour chaque paire, on teste toutes les permutations
                   % du deuxième 'field'
                   for p = 1:size(descripteur.permutations,1)
                       
                       perm  = descripteur.permutations(p,:);
                       
                       % distance pour cette configuration
                       dSum = sum(sum(abs(field1(:,:)-field2(:,perm+1))));
                       
                       d = min(d,dSum);
                   end
               end
            end
        end
    end
    
end

