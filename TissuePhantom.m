% INTRODUCTION

% Script to process image data of Atlantis phantom.

function [] = Proton(VarFile)

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

VarFile = '/Users/josmond/Library/Matlab/Variables/Las/ProPhan.txt'

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

DataNameShort = regexprep(DataName, '_data', '');
DataNameForm = regexprep(DataName, {'_' 'data'}, {' ' ''});
InDir = ['/Users/josmond/Data/' Ins '/' Name];
OutDir = ['/Users/josmond/Results/' Ins '/' Name];

% Calculate quantitative constants:

NoFrames = single(diff(Frames));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUT DATA

% Read data:

[DataImg, DataSD] = StatData([InDir '/' DataName], Ins, Frames, GroupSize);
[DarkImg, DarkSD] = StatData([InDir '/' DarkName], Ins, Frames, GroupSize);
[OpenImg, OpenSD] = StatData([InDir '/' OpenName], Ins, Frames, GroupSize);

[Data] = ReadData([InDir '/' DataName], Ins, Frames);
DataImg = median(Data,3);

[Dark] = ReadData([InDir '/' DarkName], Ins, Frames);
DarkImg = median(Dark,3);

[Open] = ReadData([InDir '/' OpenName], Ins, Frames);
OpenImg = median(Open,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPROCESSING

% Correct data:

%[CorImg, FiltImg, MaskImg, CorSD] = CorData(DataImg, DataSD, DarkImg, DarkSD, OpenImg, OpenSD);
%imtool(CorImg);
%pause

% Use cor script on these:

DataImg = DataImg - DarkImg;
OpenImg = OpenImg - DarkImg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DataName

for i = 1:NoFrames
    
    i
    
    DataFrame = (Data(:,:,i) - DarkImg);
    CutFrame = DataFrame;
    CutFrame(find(CutFrame < 3*DarkSD)) = 0;
    
    CutFrame = DataFrame;
    
    [CircFrame, MaskFrame] = CircSel(CutFrame, 650, 690, 240, 'In');
        
    Sum(i) = sum(sum(CircFrame));
    
    % Creat histogram:
    
    Bins = 5:10:995;
    Hist = hist(CutFrame(find(CutFrame > 0)), Bins);
    
    if (i == 1)
        HistAll = Hist;
    else
        HistAll = HistAll + Hist;
    end
    
    % Examine frame:
    
    %[ShufImg] = ReShuffle(CutFrame, 51, 280);
    %imtool(ShufImg);
    %imtool(CutFrame);
    
    %Limits = [min(min(CutFrame)) max(max(CutFrame))];
    %Range = Limits(2) - Limits(1);
    
    
    %imagesc(CutFrame,[Limits(1)+(0.01*Range) Limits(2)-(0.01*Range)]);
    %imagesc(CutFrame,[100 500]);
    
    %imagesc(Dark)
    %colormap('gray')
    
    %pause;
    
end


sprintf('%1.2e',mean(Sum))

% Print image:

imagesc(DataImg,[0 500]);
%ShufImg = ReShuffle(DataImg, 51, 280);
%imagesc(ShufImg(:,1:281),[0  200]);

axis image;
colormap(gray);
xlabel('X');
ylabel('Y');

WritePlot(OutDir, [DataNameShort '_Img'], 'n', 'y');

% Plot histogram:

plot(Bins*double(FrameRate),HistAll/(NoFrames*1350*1350*0.01));
xlabel('Signal (DN s^{-1})');
ylabel('Pixels (%)');
title(DataNameForm);

WritePlot(OutDir, [DataNameShort '_Hist'], 'n', 'y');

% Plot timing:

plot((1:1:NoFrames)/double(FrameRate),Sum)
xlabel('Time (s)');
ylabel('Signal (DN frame^{-1})');
title(DataNameForm);

WritePlot(OutDir, [DataNameShort '_Time'], 'n', 'y');

close;

CircArea=(((240/1350)*5.6)^2)*pi

Energy = [103 117 133 152];
Current = [140 120 100 50];
Signal = [4.71 3.48 3.39 2.10] .* (1/CircArea) .* double(FrameRate) .* 10^7;
plot(Energy, Signal./Current);

xlabel('Energy (MeV)');
ylabel('Signal (DN cm^{-2} s^{-1} nA^{-1})');
WritePlot(OutDir, [Name '_SigEnCur'], 'n', 'y');



Energy = 222.6;
Gain = 6165.443 * Energy^(-0.7037);
MU = 1;
FieldSize = 4; % cm^2
Mode = 4; % Passive Scattering
Flux = (MU * 3E-9)/(1.6E-19*Gain*FieldSize*Mode)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%