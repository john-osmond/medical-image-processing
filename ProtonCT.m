% INTRODUCTION

% Script to process image data of Atlantis phantom.

%function [] = Proton(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clearvars -except VarFile
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% VARIABLES

VarFile = '/Users/josmond/Google Drive/Software/Matlab/Variables/Dynamite/ProtonBham.txt'

% Read variables into a structured array:

[Var] = ReadVar(VarFile);

% Copy structured array elements to individual variables:

for i = 1:size(Var,2)
    if ( strcmp(char(Var(i).Type),'s') == 1 )
        eval([char(Var(i).Name{:}) '= char(Var(i).Value{:});']);
    else
        eval([char(Var(i).Name{:}) '= cell2mat(Var(i).Value);']);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONSTANTS

% Calculate qualitative constants:

setenv('Ins', 'DynamiteP');
setenv('Name', 'ProtonBham');
setenv('InDir', ['/Users/josmond/Data/' getenv('Ins') '/' getenv('Name')]);
setenv('OutDir', ['/Users/josmond/Google Drive/Results/' getenv('Ins') '/' getenv('Name')]);

setenv('BytesPerHeader', '512');
setenv('BytesPerFrame', '6717440');

% Set variables:

DarkName = 'DarkNoLight';
FloodName = 'CTFlood';
DataName = 'CT';

FrameZero = 502;
%Frames = [232:3:1200];
%Frames = 1:3:1200;
Frames = [232:3:1200 121:3:229];
%ROICo = [476 975 641 1140];
ROICo = [501 950 666 1115];
BeamCo = [325 325];
Bord = 150;
ROut = 250;
ProfOut = 340;

RotAxY = 889

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check dark correction:

%DarkName = 'DarkAfterExp';
%[DarkImg] = ReadData([DarkName 'Mean'], [], []);
%[TestImg] = ReadData([DataName 'Mean'], [], []);
%imtool(TestImg-DarkImg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
%[DarkImg, DarkSTD] = StatData(InDir, DarkName, Ins, Frames, ROICo, 10);
[DarkImg] = ReadData([DarkName 'Mean'], [], ROICo);

[FloodImg] = ReadData('CTFlood', [], ROICo);
CropCo = [Bord size(FloodImg,2)-Bord Bord size(FloodImg,2)-Bord];
FloodImg = (FloodImg-DarkImg)/max(reshape((FloodImg-DarkImg),[],1));
%FloodImg(FloodImg<=0) = NaN;

%XLim = [1 450];
XLim = [113 238];

for i = 1:numel(Frames)
    i
    FrameNum = Frames(i);
    Ang = (FrameNum-FrameZero)/3;
    PosA = round(RotAxY-ROICo(3)+1+sind(Ang)*190);
    PosB = round(RotAxY-ROICo(3)+1-sind(Ang)*190);
    
    [FrameImg] = ReadData(DataName, [FrameNum FrameNum], ROICo);
    CorImg = (FrameImg - DarkImg)./FloodImg;
    %CorImg = RemoveLine(CorImg, 'x', [79 81]);
    CorImg = RemoveLine(CorImg, 'x', [54 56]);
    
    % Normalise CorImg to sequence:
    
    CorImg = CorImg * (1300/nanmean(reshape(CorImg,1,[])));
    
    %Proj(:,i) = mean(CorImg(:,300:350),2);
    Proj(:,i) = mean(CorImg(:,XLim(1):XLim(2)),2);
    
    if (FrameNum == 637)
        WriteImg(CorImg, ['CT ' num2str(Ang) ' Deg'], [], [], 'n');
    end
        
end

% Flatten beam further:

ProfMean = nanmean(Proj,2);
ProfImg = repmat(ProfMean,1,size(Proj,2));
ProfImg = ProfImg/max(reshape(ProfImg,[],1));
CTSino = Proj./ProfImg;

%

WriteImg(CTSino, 'CT Sinogram', [], [], 'n');
CTRecon = iradon(CTSino, 1, 'none', 'v5cubic', 1, size(Proj,1));
WriteImg(CTRecon, 'CT Recon', [1800 2600], [], 'n');

CTSinoOut = [CTSino; CTSino; CTSino];

for i =1:size(CTSino,2)
    CTSinoOut(1:size(CTSino,1),i) = 1:CTSino(1,i)/size(CTSino,1):CTSino(1,i);
    CTSinoOut(2*size(CTSino,1)+1:end,i) = fliplr(1:CTSino(end,i)/size(CTSino,1):CTSino(end,i));
end

CTFilt = iradon(CTSinoOut, 1, 'Ram-Lak', 'v5cubic', 1, size(Proj,1));
%CTRecon = iradon(CorProj, 1, 'Shepp-Logan', 'v5cubic', 1, size(Proj,1));
%CTRecon = iradon(CorProj, 1, 'Cosine', 'v5cubic', 1, size(Proj,1));
%CTRecon = iradon(CorProj, 1, 'Hamming', 'v5cubic', 1, size(Proj,1));
%CTRecon = iradon(CorProj, 1, 'Hann', 'v5cubic', 1, size(Proj,1));

Filter = fspecial('gaussian', [30 30], 2);

%CTSmooth = imfilter(CTFilt, Filter, 'replicate');
%CTCirc = Circle(CTSmooth, [], [], 224);
CTCirc = CTFilt;

WriteImg(CTCirc, 'CT Filt', [-2 5], [], 'n');

% Creat profiles

CTReconProf = nanmean(CTRecon(229:231,:),1);
CTCircProf = nanmean(CTCirc(229:231,:),1);

CTReconProf = CTReconProf - min(CTReconProf);
CTCircProf = CTCircProf - min(CTCircProf);
CTCircProf = CTCircProf .* nanmean(CTReconProf)./nanmean(CTCircProf);

plot((1:size(CTRecon,1))/10, CTReconProf, '-b')
hold on;
plot((1:size(CTCirc,1))/10, CTCircProf, '--r')
hold off;

xlim([1 45]);
ylim([0 500]);
xlabel(gca,'x (mm)');
ylabel(gca,'\sigma (DN pixel^{-1} frame^{-1})');
legend('Unfiltered','Ram-Lak','Location','NorthWest')

line([3.7 3.7],[0 500],'LineStyle','-','Color','k')
line([5.7 5.7],[0 500],'LineStyle','-','Color','k')
line([38.1 38.1],[0 500],'LineStyle','-','Color','k')
line([40.1 40.1],[0 500],'LineStyle','-','Color','k')

WritePlot('CT Profile', [], 'n');

% Write out sinogram for Gavin:

pause

setenv('Ins', 'Sinogram');
setenv('BytesPerHeader', '0');
setenv('BytesPerFrame', '324000');
WriteData(CTSino, 'Sinogram', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Frames = [1 1200]
%for i = Frames(1):Frames(2);
if (1 == 2)
    
    % Calculate angle and position of rods:
    
    Ang = (i-FrameZero)/3;
    PosA = round(RotAxY+sind(Ang)*190);
    PosB = round(RotAxY-sind(Ang)*190);
    
    % Read frame from disk:
    
    [FrameImg] = ReadData(InDir, DataName, Ins, [i i], []);
    FrameImg = FrameImg*(11000/mean2(FrameImg));
    
    % Calculate co-ordinates of rod
    
    Wid = 90;
    [CoA] = LimitCo(FrameImg, 2, [PosA-Wid PosA+Wid]);
    [CoB] = LimitCo(FrameImg, 2, [PosB-Wid PosB+Wid]);
    
    % Blank out rods:
    
    FrameImg(CoA(1):CoA(2),:) = NaN;
    FrameImg(CoB(1):CoB(2),:) = NaN;
    
    if i == Frames(1);
        FrameSum = FrameImg;
        MaskSum = FrameImg./FrameImg;
    else
        FrameSum = nansum(cat(3, FrameSum, FrameImg), 3);
        MaskSum = nansum(cat(3, MaskSum, FrameImg./FrameImg), 3);
    end
    
    %FloodImg = FrameSum./MaskSum;
    %imagesc(FloodImg, prctile(reshape(FloodImg, 1, []), [2 98]));
    %colormap('gray');
    %axis image;
    %pause
    
end

%FloodImg = FrameSum./MaskSum;
%multibandwrite(FloodImg, [OutDir '/CTFlood.smv'], 'bsq', 'offset', 512, ...
%        'precision', 'uint16', 'machfmt', 'ieee-le');