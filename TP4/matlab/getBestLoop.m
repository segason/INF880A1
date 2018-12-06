function [ startFrame, endFrame ] = getBestLoop( src, minLength )
%GETBESTLOOP Calcule la paire de frames la plus ressemblante
%   minLength correspond à la taille minimale de la boucle vidéo
%   src correspond à une tableau 4D des pixels de la vidéo (w,h,col,frames)

    % TODO : Question 1
    startFrame = 1;
    endFrame = size(src,4);
    D = zeros(endFrame);
    disp(endFrame)
    src = double(src)/255;
    % Calcul de D
    for framei = 1:endFrame
        for framej = 1:endFrame
            temp = double(src(:,:,:,framei)-src(:,:,:,framej));
            if (framei == framej) || (abs(framej-framei) < minLength)
                D(framei, framej) = 100;
            else
%                 norm(temp(:,:,1), 2) + norm(temp(:,:,2), 2) + norm(temp(:,:,3), 2)
                D(framei, framej) = sqrt(sum(sum(sum(temp(:,:,:).^2, 1), 2), 3));
            end
        end
%         disp(framei)
%         disp(framej)
    end  

    
    % Filtrage diagonal
    m = 2;
    for framei = 1:endFrame
        for framej = 1:endFrame
            mtemp = double(m);
            total = 0;
            if (framei - m >= 1) && (framej - m >= 1) && (framei + m <= endFrame) && (framej + m <= endFrame)
                wk = 1/(2*mtemp);
                for i = framei-mtemp:framei + mtemp - 1
                    for j = framej-mtemp:framej + mtemp - 1
                        total = total + wk*D(framei, framej);
                    end
                end
                D(framei, framej) = total;
            end
        end
    end
    
   mini = 100000;   
   for i = m+1:endFrame-m+1
       for j = m+1:endFrame-m+1
           if D(i, j) < mini
               mini = D(i, j)
               x = i;
               y = j;
           end
       end
   end
   startFrame = min([x y])
   endFrame = max([x y])
end

