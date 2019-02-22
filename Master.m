
clearvars
close all hidden
clc
tic

OutDir = '/Users/josmond/Results/LAS/MovingMarker';

% Calculate CNR vs Dose for all datasets:

%Bad: 9 19

%DoseMin = [19 38 75 150 280 580]
DoseMin = 19

for i = DoseMin
    VarFile = ['/Users/josmond/Library/Matlab/Variables/Shark/StaticMarker' num2str(i) '.txt'];
    [Dose, SNR, CNR] = StaticMarker(VarFile);
    eval(['Dose' num2str(i) ' = Dose;'])
    eval(['SNR' num2str(i) ' = SNR;'])
    eval(['CNR' num2str(i) ' = CNR;'])
    clear Dose SNR CNR;
    
    if (i == DoseMin(1))
        IntString = ['CNRInt' num2str(i) '(:,i)'];
        CorString = ['CNRCor' num2str(i) '(:,i)'];
    else
        IntString = [IntString ' CNRInt' num2str(i) '(:,i)'];
        CorString = [CorString ' CNRCor' num2str(i) '(:,i)'];
    end
end

% Interpolate datasets to create consistent dose values:

DoseInt = 0:0.1:10;

for i = DoseMin
    s = ['CNRInt' num2str(i) ' = interp1(Dose' num2str(i) ',CNR' num2str(i) ',DoseInt);'];
    eval(s)
end

% Calculate mean of interpolated datasets:

for i = 1:4
    eval(['CNRInt(:,i) = nanmean([' IntString '],2);'])
end

% Correct interpolated datasets:

for i = DoseMin
    eval(['CNRIntTemp = CNRInt' num2str(i) ';'])
    Scale = nanmean(CNRInt./CNRIntTemp);
    ScaleRep = repmat(Scale, size(CNRIntTemp,1), 1);
    CNRCorTemp = CNRIntTemp.*ScaleRep;
    eval(['CNRCor' num2str(i) ' = CNRCorTemp;'])
end

% Calculate mean of corrected datasets:

for i = 1:4
    eval(['CNRCor(:,i) = nanmean([' CorString '],2);'])
end

%plot(DoseInt, CNRCor(:,1), 'r', DoseInt, CNRCor(:,2), 'g',...
%    DoseInt, CNRCor(:,3), 'b', DoseInt, CNRCor(:,4), 'k')

CNRShark = CNRCor;
DoseShark = DoseInt;

Style = {'-r' '--g' ':b' '-.k'};
for i = 1:4; plot(DoseShark,CNRShark(:,i),char(Style(i))); hold on; end
hold off;

xlim([0 10]);
ylim([0 6]);
legend('2 mm','1.6 mm','1.2 mm','0.8 mm');
xlabel(gca,'{\it d} (MU)');
ylabel(gca,'{\it CNR}');
WritePlot(OutDir, 'CNRDoseAll', [], 'n');

clear DoseInt CNRInt IntString CorString CNRCor CNRCorTemp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LAS DATA

% Calculate CNR vs Dose for all datasets:

%FrameRate = [20 50];
FrameRate = 20;

for i = FrameRate
    VarFile = ['/Users/josmond/Library/Matlab/Variables/LAS/MovingMarker' num2str(i) '.txt'];
    [Dose, SNR, CNR, ME, Success] = MovingMarker(VarFile);
    eval(['Dose' num2str(i) ' = Dose;'])
    eval(['SNR' num2str(i) ' = SNR;'])
    eval(['CNR' num2str(i) ' = CNR;'])
    eval(['ME' num2str(i) ' = ME;'])
    eval(['Success' num2str(i) ' = Success;'])
    clear Dose SNR CNR ME;
    
    if (i == FrameRate(1))
        IntString = ['CNRInt' num2str(i) '(:,i)'];
        CorString = ['CNRCor' num2str(i) '(:,i)'];
    else
        IntString = [IntString ' CNRInt' num2str(i) '(:,i)'];
        CorString = [CorString ' CNRCor' num2str(i) '(:,i)'];
    end
    
end

% Interpolate datasets to create consistent dose values:

DoseInt = 0.1:0.01:1;

for i = FrameRate
    s = ['CNRInt' num2str(i) ' = interp1(Dose' num2str(i) ',CNR' num2str(i) ',DoseInt);'];
    eval(s)
end

% Calculate mean of interpolated datasets:

for i = 1:4
    eval(['CNRInt(:,i) = nanmean([' IntString '],2);'])
end

% Correct interpolated datasets:

for i = FrameRate
    eval(['CNRIntTemp = CNRInt' num2str(i) ';'])
    Scale = nanmean(CNRInt./CNRIntTemp);
    ScaleRep = repmat(Scale, size(CNRIntTemp,1), 1);
    CNRCorTemp = CNRIntTemp.*ScaleRep;
    eval(['CNRCor' num2str(i) ' = CNRCorTemp;'])
end

% Calculate mean of corrected datasets:

for i = 1:4
    eval(['CNRCor(:,i) = nanmean([' CorString '],2);'])
end

%plot(DoseInt, CNRCor(:,1), 'r', DoseInt, CNRCor(:,2), 'g',...
%    DoseInt, CNRCor(:,3), 'b', DoseInt, CNRCor(:,4), 'k')

Style = {'-r' '--g' ':b' '-.k'};
for i = 1:4; plot(DoseInt,CNRCor(:,i),char(Style(i))); hold on; end
hold off;

xlim([0.1 1]);
ylim([0 5]);
legend('2 mm','1.6 mm','1.2 mm','0.8 mm');
xlabel(gca,'{\it d} (MU)');
ylabel(gca,'{\it CNR}');
WritePlot(OutDir, 'CNRDoseLAS', [], 'n');

CNRCorLAS = CNRCor;
DoseLas = DoseInt;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% COMBINE INSTRUMENTS:

OutDir = '/Users/josmond/Results/LAS/MovingMarker';

% Plot SNR:

Factor = (84/52)/(8/0.34);
plot(Dose20,SNR20.^2,'-r');
hold on;
Factor = (84/52)/(8/0.34);
plot(Dose20,(SNR20*Factor).^2,':b');
plot(Dose19,SNR19.^2,'--g');
hold off;

xlim([0 2]);
ylim([-1000 40000]);
legend('APS','APS\prime','a-Si EPID','Location','NorthWest');
xlabel(gca,'{\it D} (MU)');
ylabel(gca,'{\it SNR}^{2}');
WritePlot(OutDir, 'SNRDoseAll', [], 'n');

% Plot CNR:

Style = {'-r' '--g' ':b' '-.k'};
for i = 1:4; plot(Dose19,CNR19(:,i),char(Style(i))); hold on; end
for i = 1:4; plot(Dose20,CNR20(:,i),char(Style(i))); hold on; end
hold off;

xlim([0 2]);
ylim([0 18]);
legend('2 mm','1.6 mm','1.2 mm','0.8 mm','Location','NorthWest');
xlabel(gca,'{\it d} (MU)');
ylabel(gca,'{\it CNR}');
WritePlot(OutDir, 'CNRDoseAll', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate efficience of CMOS and EPID scintillators:

FileName = 'LinacFlux6MV.txt';
Data = importdata(['/Users/josmond/Data/Spectral/' FileName]);
LinacEn = Data(:,1);
LinacFlux = Data(:,2);
LinacEnFlux = LinacFlux.*LinacEn;

EPIDResponse = importdata('Users/josmond/Data/Spectral/EPIDResponseDave.txt');
EPIDResInt = interp1(EPIDResponse(:,1),EPIDResponse(:,2),LinacEn);
%plot(LinacEn,EPIDResInt);
GadTotEff = 100*nansum(EPIDResInt.*LinacEnFlux)/nansum(LinacEnFlux)

% Response = 0.34 % (Dave), 0.28% (Emma)

%[~, GadAtt] = IntSpec('/Users/josmond/Data/Spectral', ...
%    {'Gd' 'O' 'S'}, [314 32 32], LinacEn, 7.24, 0.29, 'A', []);

%GadEff = 100*sum(GadAtt.*LinacEnFlux)/sum(LinacEnFlux)

[~, ZincAtt] = IntSpec('/Users/josmond/Data/Spectral', ...
    {'Zn' 'W' 'O'}, [65 184 64], LinacEn, 7.62, 4, 'A', []);

ZincEff = 100*sum(ZincAtt.*LinacEnFlux)/sum(LinacEnFlux)

% Gad efficiency = 1.1 %, Zinc efficiency = 14%, Factor = 12.8

% 13.8 x thicker

% Improvement is less if use flux not en flux.

t = 0:1:1000;

%CNR = (4.3-0.0054*t)/(9.2+0.017t^-0.57);