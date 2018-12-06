function [ dst ] = poissonIntegration( lap, col )
%POISSONINTEGRATION Intégration du laplacien
%   Résout le problème de Poisson pour un laplacien donné
%   i.e. trouve "dst" tel que "Lap * dst = lap"
%   
%   "lap" est le laplacien de l'image, p.ex. calculé avec
%   imfilter(src,[0,-1,0;-1,4,-1;0,-1,0]/4,'replicate')
%   
%   "col" est un argument optionnel correspondant à
%   une condition de Dirichlet (valeurs fixées aux frontières), sinon
%   une condition de Neumann (gradient nul aux frontières) est
%   utilisée

    % dimensions de l'image
    h = size(lap,1); w = size(lap,2); c = size(lap,3);
        
    %% construction des matrices du laplacien

    % indices des voisins
    indexes = zeros(h,w); indexes(:) = 1:w*h;
    left = imfilter(indexes,[1,0,0],'replicate'); left = left(:);
    right = imfilter(indexes,[0,0,1],'replicate'); right = right(:);
    top = imfilter(indexes,[1;0;0],'replicate'); top = top(:);
    bot = imfilter(indexes,[0;0;1],'replicate'); bot = bot(:);
    indexes = indexes(:);

    % filtrage des bordures (=1 ssi le voisin n'est pas sur la bordure)
    leftFilter = (left~=indexes);
    rightFilter = (right~=indexes);
    topFilter = (top~=indexes);
    botFilter = (bot~=indexes);

    % liste des éléments non nuls de la matrice (sparse) du laplacien
    rows = [ % indices de ligne
      indexes,
      indexes(leftFilter(:)),
      indexes(rightFilter(:)),
      indexes(topFilter(:)),
      indexes(botFilter(:))
    ];
    cols = [ % indices des colonnes
      indexes,
      left(leftFilter(:)),
      right(rightFilter(:)),
      top(topFilter(:)),
      bot(botFilter(:))
    ];
    values = [ % valeur de la matrice en ces points
        ones(size(indexes)),
        -0.25*ones(size(indexes(leftFilter(:)))),
        -0.25*ones(size(indexes(rightFilter(:)))),
        -0.25*ones(size(indexes(topFilter(:)))),
        -0.25*ones(size(indexes(botFilter(:))))
    ];
    lapM = sparse(rows,cols,values,w*h,w*h);

    % matrice partielle du laplacien appliqué aux bordures
    rows = [
        indexes(~leftFilter(:)),
        indexes(~rightFilter(:)),
        indexes(~topFilter(:)),
        indexes(~botFilter(:))
    ];
    cols = [
      left(~leftFilter(:)),
      right(~rightFilter(:)),
      top(~topFilter(:)),
      bot(~botFilter(:))
    ];
    values = [
        -0.25*ones(size(indexes(~leftFilter(:)))),
        -0.25*ones(size(indexes(~rightFilter(:)))),
        -0.25*ones(size(indexes(~topFilter(:)))),
        -0.25*ones(size(indexes(~botFilter(:))))
    ];
    borderLapM = sparse(rows,cols,values,w*h,w*h);
    
    % conditions de Dirichlet ?
    dirichlet = nargin > 1;
    if ~dirichlet % sinon, conditions de Neumann
       lapM = lapM - borderLapM; 
    end
    
  %% résolution de l'équation pour chaque canal
	dst = zeros(h,w,c);
    for k = 1:c
        lapVec = lap(:,:,k);
        if dirichlet % valeurs déterminées par "col", aux bordures
            colVec = col(:,:,k);
            dstVec = lapM\(lapVec(:) - borderLapM*colVec(:));
        else
            dstVec = lapM\(lapVec(:));
        end
        dst(:,:,k) = reshape(dstVec,[h,w]);
    end
end

