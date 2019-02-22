% INTRODUCTION

% Script to process image data of Atlantis phantom.

%function [Dose, SNR, CNRStat, MR, Success] = MovingMarker(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VarFile = '/Users/josmond/Library/Matlab/Variables/LAS/MakeMovie.txt'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%0

% PREPARATION

% Prepare workspace:

clearvars -except VarFile Location
close all hidden
%clc
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

[Dark] = ReadData(InDir, DarkName, Ins, Frames, ROICo);
%[Dark, ~] = RemoveOutliers(Dark);
%[~, Dark] = RemoveSpikes(Dark, ROICo(3));
DarkImg = nanmedian(Dark,3);
clear Dark;

% Read flood data:

[Flood] = ReadData(InDir, FloodName, Ins, Frames, ROICo);
%[Flood, ~] = RemoveOutliers(Flood);
%[~, Flood] = RemoveSpikes(Flood, ROICo(3));
%[Flood, ~] = RemoveBars(Flood);
FloodImg = nanmedian(Flood,3);
clear Flood;

% Read data:

[Data] = ReadData(InDir, DataName, Ins, Frames, ROICo);

%[~, ~, NoSpikeInd] = RemoveSpikes(Data, ROICo(3));

% Correct data:

[Data, ~] = CorImg(Data, DarkImg, FloodImg);

[Data, ~] = RemoveOutliers(Data);
[Data, ~] = RemoveBars(Data);

LookImg(Data)


% Plot frame mean and std vs time:

% Normalise frames:

%[Data] = NormFrames(Data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CREATE MOVIE

WriteAVI(Data, '/Users/josmond/Desktop/LAS.avi', [3800 7200], 20);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%end