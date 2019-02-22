% Script to accept a data, dark and open image and apply correction

function [OutImg, FiltImg] = CorImg(DataImg, DarkImg, OpenImg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Correcting image(s)...');

% Prepare dark image:

if strcmpi(DarkImg, 'n') == 0
    DarkImg = nanmean(DarkImg,3);
else
    DarkImg = DataImg(:,:,1)*0;
end

% Prepare open image:

if strcmpi(OpenImg, 'n') == 0
    OpenImg = nanmean(OpenImg,3) - DarkImg;
    OpenScale = nanmean(reshape(OpenImg,1,[]));
    OpenImg = OpenImg ./ OpenScale;
else
    OpenImg = (DataImg(:,:,1)*0)+1;
end

% Loop round all frames and correct for open/dark:

for i = 1:size(DataImg,3)
    
    % Correct and filter image:
    
    OutImg(:,:,i) = (DataImg(:,:,i)-DarkImg)./OpenImg;
    FiltImg(:,:,i) = medfilt2(real(OutImg(:,:,i)));
    
end

% Remove values below zero and above max:

OutImg(OutImg < 0) = NaN;
OutImg(OutImg > nanmax(reshape(DataImg,1,[]))) = NaN;

disp('...done.')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end