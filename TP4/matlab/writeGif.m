function writeGif( frames, dstFileName, frameRate )
%WRITEGIF Sauvegarde une vidéo en Gif animé
%   frames : tableau 4D des pixels
%   dstFileName : nom du Gif en sortie

    length = size(frames,4); % nombre de frames totales
    % On construit la table des couleurs du Gif avec une image de la vidéo
    [im,map] = rgb2ind( ...
        frames(:,:,:,floor(length/2)), ... % image pour la carte de couleurs
        256); % nombre de couleurs
    im(1,1,1,length) = 0;
    for frame = 1:length % On ajout les frames une par une
        im(:,:,1,frame) = rgb2ind(frames(:,:,:,frame),map);
    end
    imwrite(im,map,dstFileName,'DelayTime',1/frameRate,'LoopCount',inf);
    
end

