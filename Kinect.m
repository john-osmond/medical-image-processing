% INTRODUCTION

% Script to process image data of Atlantis phantom.

%function [] = FilterCamera(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%VarFile = '/Users/josmond/Library/Matlab/Variables/XVI/FoilWater.txt'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clearvars -except VarFile SubName CuThick
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

setenv('Ins', 'Kinect');
setenv('Exp', 'Calibrate');
setenv('Name', 'DepthImg7');
setenv('InDir', ['/Users/josmond/Data/' getenv('Ins') '/' getenv('Exp')]);
setenv('OutDir', ['/Users/josmond/Google Drive/Results/' getenv('Ins') '/' getenv('Name')]);

setenv('BytesPerHeader', '0');
setenv('BytesPerFrame', '153600');

[Data] = ReadData(getenv('Name'), [], []);

ROI = Data(100:130,140:170,:);

Img = Data(75:150,110:210,:);

for i = 1:size(ROI,3)
    Depth(i) = mean2(ROI(:,:,i));
end

DepthTrunc = Depth(198+2:451-2);
x=1:size(DepthTrunc,2);

Scale = (1052-969.4964)/80;

% Set fit options:
            
FO = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',[0,0],...
    'Upper',[1,2000],...
    'Startpoint',[0.5,1000]);

% Set model:

f = fittype('m*x + c', 'coefficients', {'m' 'c'}, 'independent', 'x', 'options', FO);
            
% Fit model:

[LMod,gof2] = fit(permute(x, [2 1]), permute(DepthTrunc, [2 1]), f);
                                   
LVal = LMod.m*x + LMod.c;
LRes = DepthTrunc - LVal;
std(LRes)

plot(x,DepthTrunc,'bd',x,LVal,'-k');
xlim([5 35]);
ylim([970 980]);
xlabel(gca,'Frame');
ylabel(gca,'Distance from Sensor (mm)');
WritePlot(OutDir, 'CalClose', [], 'n');

[XBin, YBin, YBinErr, NBin] = BinData(x, DepthTrunc, 1, 240, 24);
plot(XBin,YBin,'bd',x,LVal,'-k');

xlim([0 240]);
ylim([960 1060]);
xlabel(gca,'Frame');
ylabel(gca,'Distance from Sensor (mm)');
WritePlot(OutDir, 'CalBin', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%imtool(Data:,:,1)



