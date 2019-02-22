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

VarFile = '/Users/John/Google Drive/Software/Matlab/Variables/Dynamite/ProtonBham.txt'

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
setenv('Name', 'ProtonBham');
setenv('InDir', ['/Volumes/Science/' getenv('Ins') '/' getenv('Name')]);
setenv('OutDir', ['/Users/John/Google Drive/Results/' getenv('Ins') '/' getenv('Name')]);

ExpTime = 100;

% Calculate quantitative constants:

NoFrames = single(diff(Frames));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Unattenuated beam properties at varying current.

DarkName = 'DarkAfterExp';
ROICo = [385 1035 375 1025];
BeamCo = [325 325];
ROut = 250;
ProfOut = 340;

HistXUnCor = 9000:100:14000;
HistX = 0:100:3500;
HistXBG = -500:100:500;
XLabel = 'Signal (DN pixel^{-1} frame^{-1})';
YLabel = 'Number of Pixels (%)';

% Open either dark frame sequence or mean and standard deviation images:

%[DarkImg, DarkSTD] = StatData(DarkName, Frames, ROICo, 10);
[DarkImg] = ReadData([DarkName 'Mean'], [], ROICo);
[DarkSD] = ReadData([DarkName 'SD'], [], ROICo);

% Write image to file:

WriteImg(DarkImg, DarkName, [], 0.1, 'n');

% Calculate histogram and write to file:

Histogram(reshape(DarkImg,1,[]), HistXUnCor, DarkName, XLabel, YLabel, []);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BEAM PROPERTIES FOR VARYING CURRENTS:

% Loop round all values current:

clear Rad Prof
Current = [0.46 0.7 0.88 1.03 1.94 2.56 2.95 6.11];

for i = 1:numel(Current)
    
    % Calculate
        
    DataName = [num2str(Current(i)) 'nA'];
    PrintName = [num2str(Current(i)) ' nA'];
        
    % Open either frame sequence of mean and standard deviation images:
        
    %[DataImg, DataSTD] = StatData(DataName, [], Frames, ROICo, 10);
    [DataImg] = ReadData([DataName 'Mean'], [], ROICo);
    [DataSD] = ReadData([DataName 'SD'], [], ROICo);
        
    nanmax(reshape(DataImg,1,[]))
        
    % Correct images:
        
    DarkImgScl = ScaleImg(DarkImg, DataImg, [1 100 551 650]);
    CorImg = DataImg - DarkImg;
    CorImg = RemoveLine(CorImg, 'x', [346 346]);
        
    % Cut out regions:
        
    [CircImg(i,:,:)] = Circle(CorImg, BeamCo, 0, ROut);
    [BGImg] = Circle(CorImg, BeamCo, ROut, ROut*2);
    [ROIImg] = Circle(CorImg, BeamCo, 0, ROut/2);
    [ROISD] = Circle(DataSD, BeamCo, 0, ROut/2);
        
    % Write image to file:
        
    WriteImg(CorImg, PrintName, [0 3000], 0.1, 'n');
        
    % Calculate histograms:
        
    Histogram(reshape(DataImg,1,[]), HistXUnCor, [PrintName ' UnCor'], XLabel, YLabel, []);
    Histogram(reshape(CircImg(i,:,:),1,[]), HistX, PrintName, XLabel, YLabel, []);
    Histogram(reshape(BGImg,1,[]), HistXBG, [PrintName ' BG'], XLabel, YLabel, []);
        
    % Sum counts in total image and insert in array:
    
    Signal(i) = nanmean(reshape(CircImg(i,:,:), 1, []));
    
    BG(i) = nanmean(reshape(BGImg, 1, []));
    Noise(i) = sqrt(nansum(reshape(ROISD.^2, 1, []))/sum(isfinite(reshape(ROIImg,1,[]))));
     
    % Calculate radial profile and insert in array:
    
    [Prof(i,:), Rad(i,:)] = RadProf(CorImg, BeamCo, 20);
    RadSig = mean(Prof(i,1:5));
    RadHalf(i) = interp1(Prof(i,:), Rad(i,:), RadSig/2);

end

% Calculate combined histogram:

for i = 1:size(CircImg,1)
    CircImg1D(i,:) = reshape(CircImg(i,:,:),1,[]);
end

Legend = {'0.46 nA', '0.70 nA', '0.88 nA', '1.03 nA', '1.93 nA', '2.56 nA', '2.95 nA', '6.11 nA', 'NorthEast'};
Histogram(CircImg1D, HistX, [], XLabel, YLabel, Legend);

mean(RadHalf)*0.1

% 22.1 to 23.4 mm mean of 22.5

% Plot beam current against integrated counts and write to file:

plot(Current, Signal, '-kd', 'MarkerEdgeColor', 'b');
xlim([0 7]);
ylim([00 2400]);
xlabel(gca, 'Proton Current (nA)');
ylabel(gca, 'Signal (DN pixel^{-1} frame^{-1})');

MC = polyfit(Current(1:4),Signal(1:4),1)
hold on;
LineX = 0:7:7;
LineY = LineX.*MC(1) + MC(2);
plot(LineX,LineY, '--k')
hold off;

text(0.5, 200, 'Signal = 1214 x Current - 107 DN pixel^{-1} frame^{-1}', 'Color', 'k')

WritePlot('SignalCurrent', [], 'y');

% Plot contrast:noise ratio

CNR = (Signal-BG)./Noise;

plot(Current,CNR, '-kd', 'MarkerEdgeColor', 'b')
xlim([0 7]);
ylim([0 35]);
xlabel(gca,'Proton Current (nA)');
ylabel(gca,'Contrast-Noise Ratio');
WritePlot('CNRCurrent', [], 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot radial profile and write to file:

Line = {'-b' '--r' '-.g' ':k' '-m' '--c' '-.b' ':r'};
for i = 1:size(Prof,1)
    plot(Rad(1,:)*0.1,flipud(Prof(size(Prof,1)-i+1,:)), char(Line(i)));
    hold on;
end
hold off;
%plot(Rad(1,:)*0.1,flipud(Prof))

xlim([1 30]);
ylim([0 3000]);
xlabel(gca,'Radius (mm)');
ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
legend('6.11 nA', '2.95 nA', '2.56 nA', '1.94 nA', '1.03 nA', '0.88 nA', '0.70 nA', '0.46 nA');
line([21.8 21.8],[0 3000],'LineStyle','--','Color','k');
text(16,2750,'r_{50} = 21.8 mm')
WritePlot('RadProf', [], 'n');

% Calculate scaled profile:

for i = 1:size(Prof,1)
    ProfScl(i,:) = Prof(i,:) * (mean(Prof(:,1))/Prof(i,1));
end

plot(Rad(1,:)*0.1,flipud(ProfScl))
xlim([1 30]);
ylim([0 2000]);
xlabel(gca,'Radius (mm)');
ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
legend('6.11 nA', '2.95 nA', '2.56 nA', '1.94 nA', '1.03 nA', '0.88 nA', '0.70 nA', '0.46 nA');
line([21.8 21.8],[0 3000],'LineStyle','--','Color','k');
text(15.5,200,'r_{50} = 21.8 mm')
WritePlot('RadProfScl', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BEAM PROPERTIES FOR VARYING EXPOSURE TIME

clear CNR Sig SigSD BG BGSD

FrameHi = [1 2 3 4 5 6 7 8 9 10 20 50 100];

for i = 1:numel(FrameHi)
    
    % Calculate
        
    DataName = '0.46nA';
    PrintName = ['0.46 nA ' num2str(FrameHi(i)/10) ' s'];
        
    % Open either frame sequence of mean and standard deviation images:
        
    [DataImg, DataSTD, ~, ~] = StatData(DataName, [], [], [1 FrameHi(i)], ROICo, 10);
        
    % Correct images:
        
    DarkImgScl = ScaleImg(DarkImg, DataImg, [1 100 551 650]);
    CorImg = DataImg - DarkImg;
    CorImg = RemoveLine(CorImg, 'x', [346 346]);
    
    [CircImg] = Circle(CorImg, BeamCo, 0, ROut);
    [ROIImg] = Circle(CorImg, BeamCo, 0, ROut/2);
    [BGImg] = Circle(CorImg, BeamCo, ROut, ROut*2);
    
    % Write image to file:
        
    WriteImg(CorImg, PrintName, [], 0.1, 'n');
           
    % Calculate histograms:
        
    Histogram(reshape(CorImg,1,[]), HistX, PrintName, XLabel, YLabel, []);
    Histogram(reshape(BGImg,1,[]), HistXBG, [PrintName ' BG'], XLabel, YLabel, []);
    
    % Sum counts in total image and insert in array:
    
    Sig(i) = nanmean(reshape(ROIImg, 1, []));
    SigSD(i) = nanstd(reshape(ROIImg, 1, []));
            
    BG(i) = nanmean(reshape(BGImg, 1, []));
    BGSD(i) = nanstd(reshape(BGImg, 1, []));

end

% Plot contrast:noise ratio

clear CNR
CNR = (Sig-BG)./SigSD;

plot(FrameHi/10, CNR, '-kd', 'MarkerEdgeColor', 'b')
xlim([0 10]);
ylim([1.4 2.8]);
xlabel(gca, 'Exposure (s)');
ylabel(gca, 'Contrast-Noise Ratio');
WritePlot('CNRExp', [], 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Temporal analysis:

Current = [0.46 0.7 0.88 1.03 1.94 2.56 2.95 6.11];

% Loop round all values current:

clear Rad Prof
for i = 1:size(Current,2)
    
    % Calculate 
    
    DataName = [num2str(Current(i)) 'nA'];
    PrintName = [num2str(Current(i)) ' nA'];
    
    DataImg = ReadData([DataName 'Mean'], [], ROICo);
    DarkImgScl = ScaleImg(DarkImg, DataImg, [1 100 551 650]);
    DarkCircImg = Circle(DarkImg, BeamCo, 0, ROut);
    
    [~, ~, TSIn, ~] = StatData(DataName, DarkCircImg, [], Frames, ROICo, 10);
    
    Time = (0:length(TSIn)-1)*(ExpTime./1000);
    plot(Time,TSIn)
    xlim([0 10]);
    %ylim([0.42 0.5]);
    %ylim([]);
    xlabel(gca,'Time (s)');
    ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
    %ylabel(gca,'Current (nA)');
    %title(PrintName)
    WritePlot([DataName 'SignalTime'], [], 'n');
    
    std(TSIn)
    
    % Calculate smoothed time series:
    
    KernSize = [4 4 4 8 8 8 8 8];
    [TSCor] = SlideWin(TSIn, KernSize(i));
    TSCor([1:2 end-1:end]) = NaN;
    
    plot(Time,TSCor)
    xlim([0 10]);
    %ylim([0.42 0.5]);
    %ylim([]);
    xlabel(gca,'Time (s)');
    ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
    %ylabel(gca,'Current (nA)');
    %title(PrintName)
    WritePlot([DataName 'SignalTimeCor'], [], 'n');
    
    nanstd(TSCor)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Characterise Beam On:

DataName = 'BeamOn';

[DataImg] = ReadData([DataName 'Mean'], [], ROICo);
DarkImgScl = ScaleImg(DarkImg, DataImg, [1 100 551 650]);
[DarkCircImg] = Circle(DarkImg, BeamCo, 0, ROut);
[DarkBGImg] = Circle(DarkImg, BeamCo, ROut, ROut*2);

[~, ~, SignalTime, ~] = StatData(DataName, DarkCircImg, [], Frames, ROICo, 10);
[~, ~, SignalTimeBG, ~] = StatData(DataName, DarkBGImg, [], Frames, ROICo, 10);

SigMin = mean(SignalTime(1:5));
SigMax = mean(SignalTime(51:100));
SigHalf = mean([SigMin SigMax]);

plot(Time,SignalTime)
xlim([0 10]);
ylim([-50 1000]);
line([0 10], [SigMin SigMin],'LineStyle','--','Color','k');
line([0 10], [SigHalf SigHalf],'LineStyle','--','Color','k');
line([0 10], [SigMax SigMax],'LineStyle','-','Color','k');
xlabel(gca,'Time (s)');
ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
%ylabel(gca,'Current (nA)');
%title('Beam On')
WritePlot('BeamOn', [], 'n');

% Average out periodic variation:

[TSOnCor] = SlideWin(SignalTime, 8);

SigMin = mean(TSOnCor(1:5));
SigMax = mean(TSOnCor(51:100));
SigHalf = mean([SigMin SigMax]);

plot(Time,TSOnCor)
xlim([0 10]);
ylim([-50 1000]);
line([0 10], [SigMin SigMin],'LineStyle','--','Color','k');
line([0 10], [SigHalf SigHalf],'LineStyle','--','Color','k');
line([0 10], [SigMax SigMax],'LineStyle','-','Color','k');
xlabel(gca,'Time (s)');
ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
%ylabel(gca,'Current (nA)');
%title(PrintName)
WritePlot('BeamOnCor', [], 'n');

plot(Time,SignalTimeBG)
xlim([0 10]);
ylim([-50 1000]);
xlabel(gca,'Time (s)');
ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
%ylabel(gca,'Current (nA)');
%title('Beam On BG')
WritePlot('BeamOnBG', [], 'n');

% time = 3.2 s

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Characterise Beam Off:

DataName = 'BeamOff';

[DataImg] = ReadData([DataName 'Mean'], [], ROICo);
DarkImgScl = ScaleImg(DarkImg, DataImg, [1 100 551 650]);
[DarkCircImg] = Circle(DarkImg, BeamCo, 0, ROut);
[DarkBGImg] = Circle(DarkImg, BeamCo, ROut, ROut*2);

[~, ~, SignalTime] = StatData(DataName, DarkCircImg, [], Frames, ROICo, 10);

SigMin = mean(SignalTime(51:100));
SigMax = mean(SignalTime(1:2));
SigHalf = mean([SigMin SigMax]);

plot(Time,SignalTime)
xlim([0 10]);
ylim([-50 1000]);
line([0 10], [SigMin SigMin],'LineStyle','--','Color','k');
line([0 10], [SigHalf SigHalf],'LineStyle','--','Color','k');
line([0 10], [SigMax SigMax],'LineStyle','-','Color','k');
xlabel(gca,'Time (s)');
ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
%ylabel(gca,'Current (nA)');
title('Beam Off')
WritePlot('BeamOff', [], 'n');

% time = 3.2 s (3.5 s)

% Average out periodic variation:

[TSOffCor] = SlideWin(SignalTime, 8);

SigMin = mean(TSOffCor(51:100));
SigMax = mean(TSOffCor(1:2));
SigHalf = mean([SigMin SigMax]);

plot(Time,TSOffCor)
xlim([0 10]);
ylim([-50 1000]);
line([0 10], [SigMin SigMin],'LineStyle','--','Color','k');
line([0 10], [SigHalf SigHalf],'LineStyle','--','Color','k');
line([0 10], [SigMax SigMax],'LineStyle','-','Color','k');
xlabel(gca,'Time (s)');
ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
%ylabel(gca,'Current (nA)');
%title(PrintName)
WritePlot('BeamOffCor', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%899 445

Scale = mean(TSOffCor(1:2)) / mean(TSOnCor(51:100));

plot(Time,[TSOnCor(1:50)*Scale TSOffCor(1:50)])

SigMin = mean(TSOffCor(51:100));
SigMax = mean(TSOffCor(1:2));
SigHalf = mean([SigMin SigMax]);

line([0 10], [SigMax SigMax],'LineStyle',':','Color','k');
line([0 10], [SigMax/2 SigMax/2],'LineStyle',':','Color','k');
line([5 5], [130 1100],'LineStyle',':','Color','k');
line([5 5], [0 30],'LineStyle',':','Color','k');

THalf = interp1(TSOnCor*Scale, Time, SigHalf);
TMax = interp1(TSOnCor*Scale, Time, SigMax);
line([THalf THalf], [0 SigHalf],'LineStyle','--','Color','k');
line([TMax TMax], [0 SigMax],'LineStyle','--','Color','k');
text(THalf+0.2, 80, 't = 0.9 s');
text(TMax+0.2, 80, 't = 3.9 s');

THalf = 5 + interp1(TSOffCor, Time, SigHalf);
TMin = 5 + interp1(TSOffCor, Time, 0);
line([THalf THalf], [0 SigHalf],'LineStyle','--','Color','k');
line([TMin TMin], [0 100],'LineStyle','--','Color','k');
text(THalf+0.3, 390, 't = 5.7 s');
text(TMin-1.2, 80, 't = 9.5 s');

xlim([0 10]);
ylim([0 1000]);
xlabel(gca,'Time (s)');
ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
WritePlot('BeamOnOffCor', [], 'n');