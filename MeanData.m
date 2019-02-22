% Script to open large number of images and generate statistical data:

function [ImgMean ImgSD] = StatData(Name, Ins, Frames, GroupSize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate variables:

NumGroups = ceil((Frames(2)-Frames(1))/GroupSize);
NumFrames = Frames(2)-Frames(1)+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop around frames and calculate mean pixel values:

for i = 1:NumGroups
    
    disp(['Processing group ', num2str(i), ' of ' num2str(NumGroups)]);
    
     if (i < NumGroups)
            GroupFrames(1) = Frames(1) + (i-1)*GroupSize;
            GroupFrames(2) = Frames(1) + i*GroupSize - 1;
     else
            GroupFrames(1) = Frames(1) + (i-1)*GroupSize;
            GroupFrames(2) = Frames(2);
     end
    
    [Img] = ReadData(Name, Ins, GroupFrames);
    
    ImgSum = sum(Img,3);
    clear Img;
    
    if (i == 1)
        ImgAll = ImgSum;
    else
        ImgAll = ImgAll + ImgSum;
    end
    
    %i
    %imagesc(ImgSum);
    %colormap('gray');
    %pause;
    
end

ImgMean = ImgAll ./ NumFrames;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop around frames and calculate standard deviation in pixel values:

for i = 1:NumGroups
    
    disp(['Processing group ', num2str(i), ' of ' num2str(NumGroups)]);
    
     if (i < NumGroups)
            GroupFrames(1) = Frames(1) + (i-1)*GroupSize;
            GroupFrames(2) = Frames(1) + i*GroupSize - 1;
     else
            GroupFrames(1) = Frames(1) + (i-1)*GroupSize;
            GroupFrames(2) = Frames(2);
     end
    
    [Img] = ReadData(Name, Ins, GroupFrames);
    
    for j = 1:GroupSize
        Img(:,:,j) = (Img(:,:,j) - ImgMean).^2;
    end
    
    ImgSum = sum(Img,3);
    clear Img;
    
    if (i == 1)
        ImgDev = ImgSum;
    else
        ImgDev = ImgDev + ImgSum;
    end
    
end

ImgSD = sqrt(ImgDev./(NumFrames-1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end