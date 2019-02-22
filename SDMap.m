% Script to remove interferance bars from a stack of images.

function [ImgOut] = SDMap(Img, PixSize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Creating STD Map...');

%for i = 1:size(Img,3)
%    for j = 1:X
%        xLo = round(size(Img,2)*(j-1)/X)+1;
%        xHi = round(size(Img,2)*j/X);
%        for k = 1:Y
%            yLo = round(size(Img,1)*(k-1)/Y)+1;
%            yHi = round(size(Img,1)*k/Y);
%            Img(yLo:yHi,xLo:xHi,i) = nanstd(reshape(Img(yLo:yHi,xLo:xHi,i),1,[]));
%        end
%    end
%end

ImgOut = zeros(ceil(size(Img,1)/PixSize(2)),ceil(size(Img,2)/PixSize(1)),size(Img,3));

for i = 1:size(Img,3)
    for j = 1:ceil(size(Img,2)/PixSize(1))
        xCo = LimitCo(Img, 2, [((j-1)*PixSize(1))+1 j*PixSize(1)]);
        for k = 1:ceil(size(Img,1)/PixSize(2))
            yCo = LimitCo(Img, 1, [((k-1)*PixSize(2))+1 k*PixSize(2)]);
            ImgOut(k,j,i) = nanstd(reshape(Img(yCo(1):yCo(2),xCo(1):xCo(2),i),1,[]));
        end
    end
end

disp('...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end