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

VarFile = '/Users/josmond/Library/Matlab/Variables/Dynamite/ProtonBham.txt'

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

setenv('Ins', 'DynamiteP');
setenv('Name', 'Dark');
setenv('InDir', ['/Users/josmond/Data/' getenv('Ins') '/' getenv('Name')]);
setenv('OutDir', ['/Users/josmond/Results/Dynamite/' getenv('Ins') '/' getenv('Name')]);

setenv('BytesPerHeader', '512');
setenv('BytesPerFrame', '6717440');

ROICo = [1 1280 1 1312];
BeamCo = [709 699];
ROut = 250;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (1 == 2)

ReduceFrames({'100ms' '200ms' '500ms' '1000ms' '2000ms'}, []);

for i = [10 20];
    ReduceFrames({'100ms'}, i)
end

for i = [5 10];
    ReduceFrames({'200ms'}, i)
end

for i = [2 4];
    ReduceFrames({'500ms'}, i)
end

for i = [2];
    ReduceFrames({'1000ms'}, i)
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exps = [100 200 300 400 500 1000 2000];

for i = 1:numel(Exps);
    [MeanImg, SDImg, TS, Hist] = StatData([num2str(Exps(i)) 'ms'], ...
        [], [], [], ROICo, 10);
    TSData(i,:) = TS;
end

Scl = mean2(TSData)./mean(TSData,2);

for i = 1:numel(Exps);
    TSScl(i,:) = TSData(i,:).*Scl(i);
end

%plot(0.1:0.1:10,permute(TSData, [2 1]));
plot(1:1:100,permute(TSScl, [2 1]));
xlim([1 100])
ylim([10075 10120])
xlabel('Frame Number');
ylabel('Signal (DN pixel^{-1} frame^{-1})');
legend('100 ms', '200 ms', '300 ms', '400 ms', '500 ms', '1000 ms', '2000 ms', 'Location', 'NorthEast');
WritePlot('SignalTime', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exps = [100 200 500 1000 2000];
XBinsFPN = 7000:100:12000;
XBinsSto = -400:20:400;

if (1 == 1)

% DARK CURRENT STUDY

for i = 1:numel(Exps);
    
    DarkImg = ReadData([num2str(Exps(i)) 'msMean100'], [], ROICo);
    DarkFPNData(i,:) = reshape(DarkImg,1,[]);
    
    [MeanImg, SDImg, TS, Hist] = StatData([num2str(Exps(i)) 'ms'], ...
        DarkImg, XBinsSto, [], ROICo, 10);
    
    SDData = reshape(SDImg,1,[]);
    
    TSData(i,:) = TS;
    
    HistX(i,:) = Hist(1,:);
    HistY(i,:) = Hist(2,:);
    
    nanstd(DarkFPNData(i,:))
    sqrt(nansum(SDData.^2)./nansum(isfinite(SDData)))
    
    WriteImg(ReBinImg(SDImg, [10 10], 'y'), [num2str(Exps(i)) 'ms SD'], [], [], 'y');
    WriteImg(SDMap(MeanImg, [10 10]), [num2str(Exps(i)) 'ms SD Space'], [], [], 'n');
    WriteImg(ReBinImg(MeanImg, [10 10], 'n'), [num2str(Exps(i)) 'ms FPN'], [], [], 'n');
    
    
end

XLabel = 'Signal (DN pixel^{-1} frame^{-1})';
YLabel = 'Number of Pixels (%)';
Legend = {'100 ms' '200 ms' '500 ms' '1000 ms' '2000 ms' 'NorthWest'};

Histogram(DarkFPNData, XBinsFPN, 'Dark FPN Exp', XLabel, YLabel, Legend);

Legend = {'100 ms (\sigma = 108)' '200 ms (\sigma = 108)' ...
    '500 ms (\sigma = 7)' '1000 ms (\sigma = 9)' '2000 ms (\sigma = 12)' 'NorthWest'};

WriteHist(HistX, HistY, 'Dark Stochastic Exp', XLabel, YLabel, Legend);

end

pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Analysis of dark FPN variation vs number of read-outs for a fixed exp
% time.

Exps = [100 200 500 1000];
Sum = [10 5 2 1];

%Exps = [100 200 500 1000 2000];
%Sum = [20 10 4 2 1];

XBinsFPN = 7000:100:12000;
XBinsSto = -100:5:100;

clear HistX HistY

for i = 1:numel(Exps);
    
    if Sum(i) > 1; SumStr = ['Mean' num2str(Sum(i))]; else SumStr = ''; end
    
    DarkImg = ReadData([num2str(Exps(i)) 'msMean100'], [], ROICo);
    DarkFPNData(i,:) = reshape(DarkImg,1,[]);
    
    [MeanImg, SDImg, TS, Hist] = StatData([num2str(Exps(i)) 'ms' SumStr], ...
        DarkImg, XBinsSto, [], ROICo, 10);
    
    SDData = reshape(SDImg,1,[]);
    
    HistX(i,:) = Hist(1,:);
    HistY(i,:) = Hist(2,:);
    
    nanstd(DarkFPNData(i,:))
    sqrt(nansum(SDData.^2)./nansum(isfinite(SDData)))
    
end

pause

XLabel = 'Signal (DN pixel^{-1} frame^{-1})';
YLabel = 'Number of Pixels (%)';
Legend = {'10 RO s^{-1}' '5 RO s^{-1}' '2 RO s^{-1}' '1 RO s^{-1}' '0.5 RO s^{-1}' 'NorthWest'};

Histogram(DarkFPNData, XBinsFPN, 'Dark FPN ROps', XLabel, YLabel, Legend);

Legend = {'10 RO s^{-1} (\sigma = 28 DN)' '5 RO s^{-1} (\sigma = 46 DN)' '2 RO s^{-1} (\sigma = 6 DN)' '1 RO s^{-1} (\sigma = 9 DN)' 'NorthWest'};

WriteHist(HistX, HistY, 'Dark Stochastic RO p s', XLabel, YLabel, Legend);

pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Analysis of Scatter

ScatterName = '0.46nA';
DarkName = 'DarkAfterExp';

BeamCo = [709 699];
ROut = 250;

[DarkImg] = ReadData([DarkName 'Mean'], [], ROICo);
[DarkSD] = ReadData([DarkName 'SD'], [], ROICo);

%[ScatterImg, ScatterSD] = StatData(ScatterName, [], Frames, ROICo, 10);
[ScatterImg] = ReadData([ScatterName 'Mean'], [], ROICo);
[ScatterSD] = ReadData([ScatterName 'SD'], [], ROICo);

ScatterImg = ScatterImg - DarkImg;
ScatterImg = Circle(ScatterImg, BeamCo, ROut, []);
%WriteImg(ScatterImg, 'Scatter', [-20 50], [], []);
ScatterImg(1:500,1000:1100) = NaN;
%[Prof, Rad] = RadProf(ScatterImg, [], []);
%plot(Prof);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ReduceFrames({'End' 'Start'}, []);

StartName = 'Start';
EndName = 'End';

[StartImg] = ReadData([StartName 'Mean1000'], [], ROICo);
[StartSD] = ReadData([StartName 'SD1000'], [], ROICo);

[EndImg] = ReadData([EndName 'Mean1000'], [], ROICo);
[EndSD] = ReadData([EndName 'SD1000'], [], ROICo);

WriteImg(ReBinImg(StartSD, [10 10], 'y'), ['Start SD'], [], [], 'y');
WriteImg(ReBinImg(EndSD, [10 10], 'y'), ['End SD'], [], [], 'y');
WriteImg(ReBinImg(EndSD-StartSD, [10 10], 'y'), ['Start To End SD'], [], [], 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%