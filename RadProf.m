function [Prof, Rad] = RadProf(Img, Co, BinSize)

% Function to find mlc leaves in an imrt image.

if numel(Co) == 0;
    Co = fliplr(round(size(Img)/2));
end

if numel(BinSize) == 0;
    BinSize = 10;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:ceil(sqrt((size(Img,1)^2)+(size(Img,2)^2))/BinSize)
    RIn = BinSize*(i-1);
    ROut = BinSize*i;
    [ImgCirc] = Circle(Img, Co, RIn, ROut);
    if(isfinite(nanmean(reshape(ImgCirc,1,[]))) == 1)
        Rad(i) = mean([RIn ROut]);
        Prof(i) = nanmean(reshape(ImgCirc,1,[]));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%end