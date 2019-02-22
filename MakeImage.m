% INTRODUCTION

% Script to process image data of Atlantis phantom.

function [Dose, SNR, CNRStat, ME, Success] = MovingMarker(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Location = 'Work';
VarFile = '/Users/josmond/Library/Matlab/Variables/LAS/MovingMarker20.txt'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clearvars -except VarFile Location
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% READ VARIABLES

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

% SET CONSTANTS

% Calculate qualitative constants:

if ( strcmpi(Location,'Work') == 1 )
    InDir = ['/Users/josmond/Data/' Ins '/' Name];
    OutDir = ['/Users/josmond/Results/' Ins '/' Name];
elseif ( strcmpi(Location,'Home') == 1 )
    InDir = ['/Users/John/Data/' Ins '/' Name];
    OutDir = ['/Users/John/Results/' Ins '/' Name];
end

% Calculate quantitative constants:

ROICo=[490 890 90 730];
Frames=[3 400];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUT DATA

% Read dark data:

[Dark] = ReadData(InDir, DarkName, Ins, [1 100], ROICo);
DarkImg = nanmedian(Dark,3);
clear Dark;

% Read flood data:

[Flood] = ReadData(InDir, FloodName, Ins, [1 100], ROICo);
[Flood, ~] = RemoveBars(Flood);
FloodImg = nanmedian(Flood,3);
clear Flood;

% Read data:

[Data1] = ReadData(InDir, DataName, Ins, [36 46], ROICo);
[Data2] = ReadData(InDir, DataName, Ins, [161 171], ROICo);
[Data3] = ReadData(InDir, DataName, Ins, [286 296], ROICo);

Data = cat(3, Data1, Data2, Data3);

clear Data1 Data2 Data3;

% Correct data:

[Data, ~] = CorImg(Data, DarkImg, FloodImg);
[Data, ~] = RemoveBars(Data);

DoseAll = [0.11 0.23 0.45 1 2];
jAll = [1 2 4 9 18];

for i = 1:5
    j = jAll(i);
    %j = 2^(i-1);
    Dose = DoseMin * (1/60) * (1/FrameRate) * j;
    %Dose = DoseAll(i);
    display(['Dose: ' num2str(Dose)]);
    
    DataAdd = AddFrames(Data,j);
    Img = DataAdd(:,:,1)/j;
    Val = median(reshape(Img,1,[]));
    Img(isnan(Img)) = 1000;
    
    FiltImg = medfilt2(real(Img));
    %FiltImg = RemoveNaN(Img);
        
    %eval(['c' num2str(i) ' = subplot(2,5,i);'])
    imagesc(FiltImg,[3800 4500]);
    colormap('gray');
    axis image;
    set(gca,'xtick',[],'ytick',[]);
    title([num2str(0.125*(2^(i-1))) ' MU'])
    if (i == 1); ylabel('APS'); end;
    
    WritePlot(OutDir, ['ImgCMOS' num2str(i)], [16 12], 'n');
end

% fps = 20, v < 0.1, frames = 36-46, 161-171, 286-296,
% fps = 20, v < 0.01, frames = 39-43, 164-168

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VarFile = '/Users/josmond/Library/Matlab/Variables/Shark/StaticMarker19.txt'

clearvars -except VarFile Location InDir OutDir c1 c2 c3 c4 c5
%close all hidden
clc
tic

[Var] = ReadVar(VarFile);

% Copy structured array elements to individual variables:

for i = 1:size(Var,2)
    if ( strcmp(char(Var(i).Type),'s') == 1 )
        eval([char(Var(i).Name{:}) '= char(Var(i).Value{:});']);
    else
        eval([char(Var(i).Name{:}) '= cell2mat(Var(i).Value);']);
    end
end

if ( strcmpi(Location,'Work') == 1 )
    InDir = ['/Users/josmond/Data/' Ins '/' Name];
    OutDir = ['/Users/josmond/Results/' Ins '/' Name];
elseif ( strcmpi(Location,'Home') == 1 )
    InDir = ['/Users/John/Data/' Ins '/' Name];
    OutDir = ['/Users/John/Results/' Ins '/' Name];
end

ROICo = [486 534 474 550];

[Dark] = ReadData(InDir, DarkName, Ins, DarkFrames, ROICo);
DarkImg = nanmedian(Dark,3);
clear Dark;

% Read data:

[Data] = ReadData(InDir, DataName, Ins, Frames, ROICo);

% Correct data:

[Data, ~] = CorImg(Data, DarkImg, 'n');
[Data, ~] = RemoveBars(Data);

%imtool(mean(Data,3))

for i = 1:5
    j = 2^(i-1)
    Dose = DoseMin * (1/60) * (1/FrameRate) * j;
    display(['Dose: ' num2str(Dose)]);
    
    DataAdd = AddFrames(Data,j);
    Img = DataAdd(:,:,1)/j;
    %FiltImg = medfilt2(real(Img));
    FiltImg = Img;
    FiltImg = flipud(FiltImg);
        
    %eval(['e' num2str(i) ' = subplot(2,5,i+5);'])
    imagesc(FiltImg,[340 420]);
    colormap('gray');
    axis image;
    set(gca,'xtick',[],'ytick',[]);
    if (i == 1); ylabel('a-Si  EPID'); end;
    WritePlot(OutDir, ['ImgEPID' num2str(i)], [16 12], 'n');
end

end