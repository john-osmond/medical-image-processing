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

setenv('Name', 'ProtonBham');
setenv('InDir', ['/Users/josmond/Data/' Ins '/' Name]);
setenv('OutDir', ['/Users/josmond/Results/Dynamite/' Ins '/' Name]);
setenv('Ins', 'DynamiteP');

ExpTime = 100;
ROICo = [390 1050 440 1100];
X = 325;
Y = 325;
ROut = 250;
ProfOut = 340;

% Calculate quantitative constants:

NoFrames = single(diff(Frames));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (1 == 2)

% BRAGG PEAK

ROICo = [390 1050 440 1100];

DarkName = 'DarkNoLightMean';
FloodName = 'FloodAfterWedgeMean';

DataName = 'BraggCMean';
PrintName = '6 (Top) & 8 mm (Bottom) of Water Equivalent Plastic';

%DataName = 'HolesDiameterMean';
%PrintName = 'Holes of varying diameter';

[DarkImg] = ReadData(DarkName, [], ROICo);
[FloodImg] = ReadData(FloodName, [], ROICo);
[DataImg] = ReadData(DataName, [], ROICo);

FloodImg = (FloodImg-DarkImg)/max(reshape((FloodImg-DarkImg),[],1));
CorImg = (DataImg-DarkImg)./FloodImg;
%CorImg(CorImg<0) = 0;
%CorImg(isnan(CorImg)) = 0;

RegA = CorImg(280:360,360:440);
RegB = CorImg(420:500,360:440);

mean2(RegA)
mean2(RegB)

CorImg = RemoveLine(CorImg, 'x', [281 281]);

WriteImg(CorImg, [DataName 'Img'], [], 0.1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot signal vs thickness of attenuating material

%Thick = [4 6 8 10 12];
%Signal = [3757.5 5379.3 8745.8 56 44]; % unadjusted
%Signal = [3757.5 4888.9 9003.9 56 44]; % adjusted between exposures

Thick = [3 3 5 5 7 7 9 9 11 11 13 13];
Signal = [0 3757.5 3757.5 4888.9 4888.9 9003.9 9003.9 56 56 44 44 0];

plot(Thick, Signal/max(Signal), '-b');

xlim([2.5 13.5]);
ylim([0 1.05]);
xlabel(gca,'Thickness of Water Equivalent Plastic (mm)');
ylabel(gca,'Normalised Signal');
WritePlot('BraggPeak', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FLUX CALCULATION

% plot current vs counts

Areacm = pi*(2.5^2);
AreaPix = Areacm*100*100;
ProtonCharge = 1.6e-19;
Time = 1;

CurrentMeas = (0:0.1:2)*1e-9;
Current = CurrentMeas*0.1;

Charge = Current*Time;
ProtonNum = Charge/ProtonCharge;
ProtonFlux = ProtonNum/AreaPix;

plot(CurrentMeas*1e9,ProtonFlux);
xlim([0 2]);
ylim([0 7000]);
xlabel(gca,'Measured Beam Current (nA)');
ylabel(gca,'Proton Flux (pixel^{-1} s^{-1})');
WritePlot('FluxCurrent', [], 'n');

SPExp = 330;
PExp = SPExp/4;
PLineExp = PExp/1280;
PLineRate = 1000/LineExp;

% Flux (pixel-1 s-1) = Current (nA) * 3183

% Proton Flux = 3183 (pixel-1 s-1 nA-1)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DARK CURRENT STUDY

DarkAName = 'Dark100';
DarkBName = 'DarkAfterExp';
DarkCName = 'DarkNoLight';
ScatterName = '0.46nA';
DarkAll = {DarkAName DarkBName DarkCName};

ROICo = [1 1280 1 1312];
BeamCo = [709 699];
ROut = 250;

% Read Data:

%[DarkAImg, DarkASD] = StatData(DarkAName, [], Frames, ROICo, 10);
[DarkAImg] = ReadData([DarkAName 'Mean'], [], ROICo);
[DarkASD] = ReadData([DarkAName 'SD'], [], ROICo);

%[DarkBImg, DarkBSD] = StatData(DarkAName, [], Frames, ROICo, 10);
[DarkBImg] = ReadData([DarkBName 'Mean'], [], ROICo);
[DarkBSD] = ReadData([DarkBName 'SD'], [], ROICo);

%[DarkCImg, DarkASD] = StatData(DarkCName, [], Frames, ROICo, 10);
[DarkCImg] = ReadData([DarkCName 'Mean'], [], ROICo);
[DarkCSD] = ReadData([DarkCName 'SD'], [], ROICo);

% Write images of DC:

%DarkCSpaceSD = SDMap()


%[ScatterImg, ScatterSD] = StatData(ScatterName, [], Frames, ROICo, 10);
[ScatterImg] = ReadData([ScatterName 'Mean'], [], ROICo);
[ScatterSD] = ReadData([ScatterName 'SD'], [], ROICo);
ScatterImg = ScatterImg - DarkBImg;
[Prof, Rad] = RadProf(ScatterImg, BeamCo, 20);
plot(Prof);
ScatterImg = Circle(ScatterImg, BeamCo, ROut, []);
WriteImg(ScatterImg, 'Scatter', [-20 50], []);
ScatterImg(1:500,1000:1100) = NaN;

clear ScatterSD

for i=1:50
    [ScatterImg, ScatterSDImg] = StatData(ScatterName, DarkBImg, [1 i], ROICo, 10);
    ScatterSD(i) = nanstd(reshape(ScatterImg,1,[]));
end

plot(DarkSD, '-b');

xlim([1 50]);
ylim([0 120]);
xlabel(gca,'Number of Added Frames');
ylabel(gca,'\sigma (DN pixel^{-1} frame^{-1})');
WritePlot('DarkFrame', [], 'n');

plot(ScatterSD, '-b');

xlim([1 50]);
ylim([190 270]);
xlabel(gca,'Number of Added Frames');
ylabel(gca,'\sigma (DN pixel^{-1} frame^{-1})');
WritePlot('ScatterFrame', [], 'n');

plot(DarkSD, '-b');
hold on
plot(ScatterSD, '--r');
hold off

xlim([1 50]);
ylim([0 270]);
xlabel(gca,'Number of Added Frames');
ylabel(gca,'\sigma (DN pixel^{-1} frame^{-1})');
WritePlot('DarkScatterFrame', [], 'n');

% 8 Frame periodicity.

W0042abcde  where abcde is the exposure time in units of 10µs, divided by 65536, rounded down to an integer
W0041fghij  where fghij is the remainder of the exposure time in units of 10µs divided by 65536
In both cases, use leading zeros to bring it up to 5 digits.
 
e.g. for an exposure time of 700ms,  abcde =  00001, and fghij = 04464
enter     W004200001
          W004104464

Exp = 2000; %ms
Code42 = floor(Exp*100/65536)
Code41 = Exp*100 - 65536*floor(Exp*100/65536)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%