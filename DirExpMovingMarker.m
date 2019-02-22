% INTRODUCTION

% Script to process image data of Atlantis phantom.

function [] = DirExpMovMark(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clearvars -except VarFile
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONSTANTS

% Calculate qualitative constants:

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
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPROCESSING

% Correct data:

[CorImg, FiltImg, MaskImg, CorSD] = CorData(DataImg, DataSD, DarkImg, DarkSD, OpenImg, OpenSD);

imtool(FiltImg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
