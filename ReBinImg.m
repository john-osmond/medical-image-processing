% Script to step through a 3D image stack and display each one
% individually.

% Data: 3D array containing a stack of images.

function [ImgOut] = ReBinImg(Img, PixSize, Quad)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Rebinning data...');

%if size(Factor,2) == 1
%    X = floor(size(Img,2)/Factor);
%    Y = floor(size(Img,1)/Factor);
%else
%    X = floor(size(Img,2)/Factor(1));
%    Y = floor(size(Img,1)/Factor(2));
%end

%for i = 1:size(Img,3)
%    for j = 1:X
%        xLo = round(size(Img,2)*(j-1)/X)+1;
%        xHi = round(size(Img,2)*j/X);
%        for k = 1:Y
%            yLo = round(size(Img,1)*(k-1)/Y)+1;
%            yHi = round(size(Img,1)*k/Y);
%            ImgOut(k,j,i) = nanmean(reshape(Img(yLo:yHi,xLo:xHi,i),1,[]));
%        end
%    end
%end

ImgOut = zeros(ceil(size(Img,1)/PixSize(2)),ceil(size(Img,2)/PixSize(1)),size(Img,3));

for i = 1:size(Img,3)
    for j = 1:ceil(size(Img,2)/PixSize(1))
        xCo = LimitCo(Img, 2, [((j-1)*PixSize(1))+1 j*PixSize(1)]);
        for k = 1:ceil(size(Img,1)/PixSize(2))
            yCo = LimitCo(Img, 1, [((k-1)*PixSize(2))+1 k*PixSize(2)]);
            ROI = reshape(Img(yCo(1):yCo(2),xCo(1):xCo(2),i),1,[]);
            if strcmpi(Quad,'y')
                Val = sqrt(nanmean(ROI.^2));
            else
                Val = nanmean(ROI);
            end
            ImgOut(k,j,i) = Val;
        end
    end
end

disp('...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end