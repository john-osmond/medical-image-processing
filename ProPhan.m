% INTRODUCTION

% Script to process image data of Atlantis phantom.

function [] = ProPhan(VarFile)

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

[~, DataSD] = StatData([InDir '/' DataName], Ins, Frames, GroupSize);
[~, DarkSD] = StatData([InDir '/' DarkName], Ins, Frames, GroupSize);
[~, OpenSD] = StatData([InDir '/' OpenName], Ins, Frames, GroupSize);

[Data] = ReadData([InDir '/' DataName], Ins, Frames);
DataImg = median(Data,3);

[Dark] = ReadData([InDir '/' DarkName], Ins, Frames);
DarkImg = median(Dark,3);

[Open] = ReadData([InDir '/' OpenName], Ins, Frames);
OpenImg = median(Open,3);

clear Data Dark Open;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPROCESSING

% Correct data:

[CorImg, FiltImg, MaskImg, CorSD] = CorData(DataImg, DataSD, DarkImg, DarkSD, OpenImg, OpenSD);
%CorImg = DataImg - DarkImg;

%imtool(CorImg);
%pause

% Use cor script on these:

%DataImg = DataImg - DarkImg;
%OpenImg = OpenImg - DarkImg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RegA = CorImg(50:280,50:530);
RegB = CorImg(50:280,830:1300);

RegC = CorImg(580:800,50:530);
RegD = CorImg(580:800,830:1300);

RegE = CorImg(1100:1300,50:1300);

Bone = [reshape(RegA, [1 numel(RegA)]) reshape(RegD, [1 numel(RegD)])];
BoneMed = median(Bone)

Lung = [reshape(RegB, [1 numel(RegB)]) reshape(RegC, [1 numel(RegC)])];
LungMed = median(Lung)

Soft = reshape(RegE, [1 numel(RegE)]);
SoftMed = median(Soft)

Signal = [LungMed SoftMed BoneMed];
Density = [0.30 1 1.819];

plot(Density, Signal);
xlabel('Density g cm^{-3})');
ylabel('Signal (DN pixel^{-1})');

WritePlot(OutDir, ['ProPhan_Cal'], 'n', 'y');

% Deal with gaps!

% Generate left profile:

LeftProf = median(CorImg(1:1350,50:530),2);

% Remove chip gaps:

ZeroInd = find(LeftProf == 0);
for i = 1:length(ZeroInd)
    if(ZeroInd(i) == 1)
        Val = LeftProf(2);
    elseif(ZeroInd(i) == 1350)
        Val = LeftProf(1349);
    else
        Val = mean([LeftProf(ZeroInd(i)-1) LeftProf(ZeroInd(i)+1)]);
    end
    LeftProf(ZeroInd(i)) = Val;
end

% Plot left profile:

plot(LeftProf);
set(gca,'xlim',[1 1350]);

xlabel('Y (Pixel)');
ylabel('Signal (DN pixel^{-1})');

WritePlot(OutDir, ['ProPhan_LeftProf'], 'n', 'y');


% Generate right profile:

RightProf = median(CorImg(1:1350,830:1300),2);

% Remove chip gaps:

ZeroInd = find(RightProf == 0);
for i = 1:length(ZeroInd)
    if(ZeroInd(i) == 1)
        Val = RightProf(2);
    elseif(ZeroInd(i) == 1350)
        Val = RightProf(1349);
    else
        Val = mean([RightProf(ZeroInd(i)-1) RightProf(ZeroInd(i)+1)]);
    end
    RightProf(ZeroInd(i)) = Val;
end

% Plot right profile:

plot(RightProf);
set(gca,'xlim',[1 1350]);


xlabel('Y (Pixel)');
ylabel('Signal (DN pixel^{-1})');

WritePlot(OutDir, ['ProPhan_RightProf'], 'n', 'y');


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%