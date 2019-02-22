function U = ContrastEnhancement_GiovanniLupica(Img)

% Img can be of class uint16 or uint8.

% Extract Image Features
[nr nc ncolors] = size(Img);
ImgFeatures = whos('Img');
ImgBitsPerPixel = ImgFeatures.bytes / (nr*nc*ncolors)* 8; 


%% IDENTIFY REGION OF INTEREST
%% The OTSU's THRESHOLDING METHOD IS USED TO AUTOMATICALLY IDENTIFY THE REGION OF INTEREST
% The parameter SW was empirically tuned.
SW = 16; % Size structuring element used to erode the MLC region segmented 
        % using the simple Otsu's thresholding method
Thr = graythresh(Img) * ( 2^ImgBitsPerPixel - 1);
se = strel('disk', SW); 
clear SW;
MLC_Mask_Temp = (Img <= Thr);
clear Thr;
MLC_Mask = imerode(MLC_Mask_Temp,se);
clear MLC_Mask_Temp;
clear se;

%% RETROSPECTIVE METHOD FOR CORRECTION OF BACKGROUND INTENSITY INHOMOGENEITY
% Model of Intensity Inhomogeneity: v(x) = u(x).*b(x) + n(x);

% DE-NOISING : remove noise n(x) using wiener filtering, i.e  that is
%              an adaptive noise removal filter
m = 5;
fw = @(x) wiener2(x,[m m]);
ImgNR = roifilt2(Img,MLC_Mask,fw); 

% FILTERING METHOD: 
%                   Filtering methods assume that intensity inhomogeneity
%                   is a low-frequency artifact that can be separated from
%                   the high-frequency signal of the imaged anatomical
%                   structures by low-pass filtering (LPF). LPF can be
%                   mean, or median based, or implemented by multiplication
%                   in the Fuorier domain

% Homomorphic Unsharp Masking - the simplest and most commonly used
% method for intensity inhomogeneity correction
%
%   u(x) = v(x)./b(x) = (v(x).*Cn) ./ LPF(v(x));
%   Cn = max(LPF(v(x))) -  min(LPF(v(x)));
Vx = double(ImgNR);
Vx(~MLC_Mask) = round(mean(ImgNR(MLC_Mask)));
% The size of the squared median filter "Len_F" was empirically chosen
Len_F = 21;
fmedian = @(x) medfilt2(x,[Len_F Len_F]);
LPF_Vx = roifilt2(Vx,MLC_Mask,fmedian); 
Cn = max(LPF_Vx(MLC_Mask)) - min(LPF_Vx(MLC_Mask));
Ux = imdivide(immultiply(Vx,Cn),LPF_Vx);

% Pixel intensity range adjustment - from [minUx, maxUx] to [0, 2^16 -1];
minUx = min(Ux(:));
maxUx = max(Ux(:));

U = uint16(((Ux - minUx)./(maxUx - minUx)).*(2^16 - 1));
figure(), imshow(U,[]), colormap(gray); 
title('Input Image after CORRECTION OF BACKGROUND INTENSITY INHOMOGENEITY');

%imwrite(U,'outputImage.png','png');
end