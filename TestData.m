% Script to generate noisy data, dark and open images, to write these
% files to disk, and to open, correct and display them.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREP

% Start up:

clear
close all hidden
clc
tic

% Set variables:

Name = 'Test';
DataName = 'Test_data.raw';
DarkName = 'Dark_data.raw';
OpenName = 'Open_data.raw';

ClassOut = 'uint16';
Ins = 'Test';

DataNorm = 5000;
OpenRand = 500;
DarkNorm = 3000;
DarkRand = 500;

ImgSize = [200 200];
Frames = [1 200];
GroupSize = 40;

% Calculate constants:

InDir = ['/Users/josmond/Data/' Name];
OutDir = ['/Users/josmond/Results/' Name];

ImgStep = zeros(5,2);

for i = 1:5
    ImgStep(i,:) = round(ImgSize*(i/5));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CREATE IMAGES

% Generate image:

Img = zeros(ImgSize);
Img(ImgStep(1,1):ImgStep(4,1),ImgStep(1,2):ImgStep(4,2)) = DataNorm/2;
Img(ImgStep(2,1):ImgStep(3,1),ImgStep(2,2):ImgStep(3,2)) = DataNorm;

% Generate gain image:

ImgOpen = zeros(ImgSize);
Open = 1:DataNorm/ImgSize(1):DataNorm;
ImgOpen = [bsxfun(@plus,ImgOpen,Open)];

% Generate dark image:

ImgDark = zeros(ImgSize)+(DarkNorm/2);
ImgDark(1:ImgStep(1,1),:) = DarkNorm;
ImgDark(ImgStep(2,1):ImgStep(3,1),:) = DarkNorm;
ImgDark(ImgStep(4,1):ImgStep(5,1),:) = DarkNorm;

% Open image files:

FDark = fopen([InDir '/' DarkName], 'w');
FOpen = fopen([InDir '/' OpenName], 'w');
FData = fopen([InDir '/' DataName], 'w');

for i = Frames(1):Frames(2)
    
    % Add noise to images:
    
    ImgDarkNoise = ImgDark + (DarkRand*randn(ImgSize));
    ImgOpenNoise = ImgOpen + (OpenRand*randn(ImgSize));
    ImgDataNoise = (Img + (sqrt(Img).*randn(ImgSize))).*(ImgOpen/mean2(ImgOpen));
    
    % Combine images:
    
    ImgDarkOut = ImgDarkNoise;
    ImgOpenOut = ImgOpenNoise + ImgDarkNoise;
    ImgDataOut = ImgDataNoise + ImgDarkNoise;
    
    % Write out images:
        
    fwrite(FData, ImgDataOut, ClassOut);
    fwrite(FDark, ImgDarkOut, ClassOut);
    fwrite(FOpen, ImgOpenOut, ClassOut);
    
end

% Close image files:

fclose(FDark);
fclose(FOpen);
fclose(FData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% READ IMAGES

% Read data:

[DataImg, DataSD] = StatData([InDir '/' DataName], Ins, Frames, GroupSize);
[DarkImg, DarkSD] = StatData([InDir '/' DarkName], Ins, Frames, GroupSize);
[OpenImg, OpenSD] = StatData([InDir '/' OpenName], Ins, Frames, GroupSize);
    
% Correct data:

[ImgCor, SDCor] = cordata(DataImg, DataSD, DarkImg, DarkSD, OpenImg, OpenSD);

% Display data:

imtool(ImgCor);
imtool(SDCor);