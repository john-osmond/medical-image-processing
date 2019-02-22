% INTRODUCTION

% Script to process image data of Atlantis phantom.

%function [Dose, SNR, CNRStat, MR, Success] = MovingMarker(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VarFile = '/Users/josmond/Library/Matlab/Variables/Dynamite/FirstLightZnWO4.txt'

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

InDir = ['/Users/josmond/Data/' Ins '/' Name];
OutDir = ['/Users/josmond/Results/' Ins '/' Name];

% Calculate quantitative constants:

NoFrames = single(diff(Frames));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUT DATA

% Read dark data:

DarkName = 'ZnWO4/Dark';
FloodName = 'ZnWO4/Flood15';
DataName = 'ZnWO4/QC15';

[Dark] = ReadData(InDir, DarkName, Ins, Frames, ROICo);
DarkImg = mean(Dark,3);
clear Dark;

[Flood] = ReadData(InDir, FloodName, Ins, Frames, ROICo);
[FloodRem] = RemoveBars(Flood, 2);

pause

[Data] = ReadData(InDir, DataName, Ins, Frames, ROICo);
%[Data, ~] = CorImg(Data, Dark, Flood);

imtool(Data,'InitialMagnification','adaptive')
pause


imagesc(Data);
colormap('gray')
axis('image')
set(gca,'xtick',[],'ytick',[]);
title(DataName);
WritePlot(OutDir, DataName, [16 12], 'n');
