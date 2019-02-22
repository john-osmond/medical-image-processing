function [Img] = ScaleImg(Img, RefImg, Co)

% Function to scale image so that the total signal in the region defined by
% Co is the same for both the image and reference image.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ImgMean = nanmean(reshape(Img(Co(3):Co(4),Co(1):Co(2)),1,[]));
RefMean = nanmean(reshape(RefImg(Co(3):Co(4),Co(1):Co(2)),1,[]));
Img = Img*(RefMean/ImgMean);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%end