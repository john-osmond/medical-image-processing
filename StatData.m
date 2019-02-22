% Script to open large number of images and generate statistical data:

function [ImgMean ImgSD TS Hist] = StatData(Name, DarkImg, XBins, Frames, ROICo, GroupSize)

disp('Starting StatData...');

if CountEnv({'InDir' 'Ins'}) < 2;
    disp('Missing environment variables');
    return
end

% Substitute defaults:

if numel(Frames) == 0
    File = dir([getenv('InDir') '/' char(Name) '.*']);
    TotalFrames = (File.bytes-str2double(getenv('BytesPerHeader')))/...
        str2double(getenv('BytesPerFrame'));
    Frames = [1 TotalFrames];
end

if numel(GroupSize) == 0
    GroupSize = 10;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate variables:

NumGroups = ceil((diff(Frames)+1)/GroupSize);
NumFrames = zeros([1 NumGroups]);
TS = zeros([1 (diff(Frames)+1)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop around frames and calculate mean pixel values:

for i = 1:NumGroups
    
    disp(['Calculating mean for group ', num2str(i), ' of ' num2str(NumGroups)]);
    
     if (i < NumGroups)
            GroupFrames(1) = Frames(1) + (i-1)*GroupSize;
            GroupFrames(2) = Frames(1) + i*GroupSize - 1;
     else
            GroupFrames(1) = Frames(1) + (i-1)*GroupSize;
            GroupFrames(2) = Frames(2);
     end
     
     % Read data and sum frames:
    
    [Img] = ReadData(Name, GroupFrames, ROICo);
    
    % Apply dark correction if requested:
    
    for j = 1:size(Img,3)
        if numel(DarkImg) > 0; Img(:,:,j) = Img(:,:,j) - DarkImg; end
        TS(sum(NumFrames)+j) = nanmean(reshape(Img(:,:,j),1,[]));
    end
    
    % Add frames to running sum:
    
    if (i == 1)
        ImgSum = sum(Img,3);
    else
        ImgSum = ImgSum + sum(Img,3);
    end
    
    % Create histogram data if required
    
    if numel(XBins) > 0
        [HistY(i,:), HistX(i,:)] = hist(reshape(Img, 1, []), XBins);
    end
    
    clear Img;
    
    NumFrames(i) = diff(GroupFrames) + 1;
    
end

ImgMean = ImgSum ./ sum(NumFrames);

if numel(XBins) > 0
    Hist = [nanmean(HistX,1); 100*nansum(HistY,1)/nansum(reshape(HistY,1,[]))];
else
    Hist = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop around frames and calculate standard deviation in pixel values:

for i = 1:NumGroups
    
    disp(['Calculating standard deviation for group ', num2str(i), ' of ' num2str(NumGroups)]);
    
     if (i < NumGroups)
            GroupFrames(1) = Frames(1) + (i-1)*GroupSize;
            GroupFrames(2) = Frames(1) + i*GroupSize - 1;
     else
            GroupFrames(1) = Frames(1) + (i-1)*GroupSize;
            GroupFrames(2) = Frames(2);
     end
     
    [Img] = ReadData(Name, GroupFrames, ROICo);
    
    % Apply dark correction if requested:
    
    for j = 1:size(Img,3)
        if numel(DarkImg) > 0; Img(:,:,j) = Img(:,:,j) - DarkImg; end
    end
    
    % Calculate deviation image:
    
    for j = 1:diff(GroupFrames)+1
        Img(:,:,j) = (Img(:,:,j) - ImgMean).^2;
    end
    
    % Add deviation image to running sum:
    
    if (i == 1)
        ImgSumDev = sum(Img,3);
    else
        ImgSumDev = ImgSumDev + sum(Img,3);
    end
    clear Img;
    
end

ImgSD = sqrt(ImgSumDev./(sum(NumFrames)-1));

% Remove inf and nans:

%ImgMean(isnan(ImgMean)) = 0;
%ImgMean(isinf(ImgMean)) = 0;

%ImgSD(isnan(ImgSD)) = 0;
%ImgSD(isinf(ImgSD)) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('...done.');

end