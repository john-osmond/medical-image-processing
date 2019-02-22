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

%VarFile = '/Users/josmond/Library/Matlab/Variables/Las/ProtonScrew.txt'
%VarFile = '/Users/josmond/Library/Matlab/Variables/Las/ProtonTissue.txt'
VarFile = '/Users/josmond/Library/Matlab/Variables/Las/ProtonPencil.txt'

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

InDir = ['/Users/josmond/Data/' Ins '/' Name];
OutDir = ['/Users/josmond/Results/' Ins '/' Name];

% Calculate quantitative constants:

NoFrames = single(diff(Frames));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUT DATA

% Read data:

[Dark] = ReadData(InDir, DarkName, Ins, Frames, ROICo);
DarkImg = nanmean(Dark,3);
clear Dark;

[Flood] = ReadData(InDir, OpenName, Ins, Frames, ROICo);
FloodImg = nanmean(Flood,3);
clear Flood;

[Data] = ReadData(InDir, DataName, Ins, Frames, ROICo);
DataImg = nanmean(Data,3);
clear Data;

[Img, ~] = CorImg(DataImg, DarkImg, FloodImg);

% Median filter image:

NanInd = isnan(Img);
%Img(NanInd) = nanmean(reshape(Img,1,[]));
Img(NanInd) = 0;
Img = medfilt2(real(Img));

% Smooth image:

Filter = fspecial('gaussian', [30 30], 3);
FiltImg = imfilter(Img,Filter,'replicate');

% Display image:

imagesc(FiltImg,iLim);
colormap('bone');
axis image;
box on;
set(gca,'xtick',-1,'ytick',-1);

%text(210,110,'Sprung Biro + 2 Slotted Screws','FontSize',16,'color','black');

%text(250,190,'Bone','FontSize',16,'color','black')
%text(250,680,'Lung','FontSize',16,'color','white')
%text(540,1140,'Soft Tissue','FontSize',16,'color','white')
%text(960,190,'Lung','FontSize',16,'color','white')
%text(960,680,'Bone','FontSize',16,'color','black')

text(430,230,'20mm Pencil Beam','FontSize',16,'color','white');

print('-depsc2','/Users/josmond/Desktop/Figure.eps');
print('-dpdf','/Users/josmond/Desktop/Figure.pdf');
close;

%pause
%close;
%imtool(FiltImg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%