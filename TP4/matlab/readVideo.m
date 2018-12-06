function [ dst, framerate ] = readVideo( srcFileName, smallSide )
%READVIDEO Lis une vidéo sur le disque
%   dst : correspond aux frames de la vidéo. Tableau 4D (w,h,col,frames)
%   maxSize : optionnel, correspond à la taille maximale des frames

    % taille maximale de la vidéo
    % on la redimensionne si elle est trop grande
    if nargin < 2, smallSide = 256; end
    
    srcVid = VideoReader(srcFileName); % flux vidéo en lecture
    w = srcVid.Width;
    h = srcVid.Height;
    framerate = srcVid.FrameRate;
    nbFrames = uint32(srcVid.FrameRate * srcVid.Duration); % estimation du nombre de frames
    ratio = min( 1, smallSide / min(w,h) ); % ratio de réduction de la vidéo
    w = floor(w * ratio); h = floor(h * ratio);
    
    % Tableau 4D (w,h,col,frames) représentant les pixels de la vidéo
    dst = uint8(zeros(h,w,3,nbFrames));
    nbFrames = 0; % on compte le nombre réel de frames
    while hasFrame(srcVid)
        nbFrames = nbFrames+1;
        frame = readFrame(srcVid);
        dst(:,:,:,nbFrames) = imresize(frame,[h,w]);
    end
    dst = dst(:,:,:,1:nbFrames);

end

