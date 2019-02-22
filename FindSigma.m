% Open image data for different devices.

function [SigmaOpt] = FindSigma(Img, SigBox, AmBox)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Script to find smoothing scale that optimises Contrast to noise ratio.



Img=Data(:,:,1);
SigCo = [590 790 582 614];
AmCo = [590 790 1000 1200];

for Sigma = 1:40
    
    Sigma
    Filter = fspecial('gauss', [Sigma*4 Sigma*4], Sigma);
    ImgSmooth = filter2(Filter, Img);
    
    SigBox = ImgSmooth(SigCo(3):SigCo(4),SigCo(1):SigCo(2));
    AmBox = ImgSmooth(AmCo(3):AmCo(4),AmCo(1):AmCo(2));
    
    Contrast = abs(mean2(SigBox) - mean2(AmBox));
    Noise = sqrt(std2(SigBox)^2 + std2(AmBox)^2);
    CNR(Sigma) = Contrast/Noise;
    
    imagesc(ImgSmooth);
    colormap('gray');
    pause
    
end

disp('...done.');
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end