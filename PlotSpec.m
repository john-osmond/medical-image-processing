% INTRODUCTION

% Script to plot spectra.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clear
close all hidden
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InDir = '/Users/josmond/Data/Spectral';
OutDir = '/Users/josmond/Results/Spectral';

Source = 'Synergy';
%Source = 'Linac';

if ( strcmpi(Source,'Linac') == 1 )
    xLim = [0.1 6];
else
    xLim = [0.02 0.1];
end

% Linac Flux normalisation:

LinacFluxNorm = 1.2e10; % Flux from linac
SynFluxNorm = 2107;
SAD = 1; % Source axis distance in m.
SDD = 1.55; % Source detector distance in m.
ScintCor = (SAD/SDD)^2; % Correction to scintillator.

% ZnWO4 = ? ms, 9,500 photons/MeV Rad Length = 1.10 cm, RI = 2.32.
% CsI(TI) = 2 ms, 52,000 photons/MeV,  Rad Length = 1.86 cm, RI = 1.78
% 1.7 x improvement.

ZnTOptYield = 9500;
CsIOptYield = 52000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LINAC EMISSION SPECTRUM

% Calculate spectrum of Flux emitted by linac:

FileName = 'LinacFlux6MV.txt';
Data = importdata([InDir '/' FileName]);
LinacEn = Data(:,1);
LinacFlux = Data(:,2);

LinacFluxCor = LinacFluxNorm/sum(LinacFlux);
LinacFlux = LinacFlux.*LinacFluxCor;

plot(LinacEn,LinacFlux);

set(gca,'xLim',xLim);
%title('Linac Emission Spectrum')
xlabel('Energy (MeV)');
ylabel('Flux (cm^{-2} s^{-1})');

WritePlot(OutDir, 'LinacFlux', [], 'n');

% Calculate spectrum of Energy Flux emitted by linac:

LinacEnFlux = LinacFlux.*LinacEn;

plot(LinacEn,LinacEnFlux);

set(gca,'xLim',xLim);
%title('Linac Emission Spectrum')
xlabel('Energy (MeV)');
ylabel('Energy Flux (MeV cm^{-2} s^{-1})');

WritePlot(OutDir, 'LinacEnFlux', [], 'n');

display(['Flux out of Linac: ' num2str(sum(LinacEnFlux))]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SYNERGY EMISSION SPECTRUM

% Calculate spectrum of Fluence emitted by kV set (20-100 keV):

FileName = '100kVp.txt';
Data = importdata([InDir '/' FileName]);
SynEn = (Data(:,1)+0.5)/1000;
SynFlux = Data(:,3)*SynFluxNorm;

plot(SynEn,SynFlux);

set(gca,'xLim',xLim);
%title('Synergy Emission Spectrum')
xlabel('Energy (MeV)');
ylabel('Relative Flux');

WritePlot(OutDir, 'SynFlux', [], 'n');

SynEnFlux = SynFlux.*SynEn;

plot(SynEn,SynEnFlux);

set(gca,'xLim',xLim);
%title('Synergy Emission Spectrum')
xlabel('Energy (MeV)');
ylabel('Relative Energy Flux');

WritePlot(OutDir, 'SynEnFlux', [], 'n');

display(' ');
display(['Flux out of Synergy: ' num2str(sum(SynFlux))]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Choose source spectrum:

if ( strcmpi(Source,'Linac') == 1 )
    display('Using Linac MeV energy source...')
    SourceEn = LinacEn;
    SourceFlux = LinacFlux;
    SourceEnFlux = LinacEnFlux;
else
    display('Using XVI keV energy source...')
    SourceEn = SynEn;
    SourceFlux = SynFlux;
    SourceEnFlux = SynEnFlux;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TissThick = 20;
GoldThick = 0.015;
CuThick = 0.25;

[~, TissTrans] = IntSpec('/Users/josmond/Data/Spectral',...
    'Water', 1, SourceEn, 1, TissThick, 'T', []);

[~, GoldTrans] = IntSpec('/Users/josmond/Data/Spectral',...
    'Au', 1, SourceEn, 19.3, GoldThick, 'T', []);

[~, FilterTrans] = IntSpec('/Users/josmond/Data/Spectral', ...
    'Cu', 1, SourceEn, 8.94, CuThick, 'T', []);

[~, AlTrans] = IntSpec('/Users/josmond/Data/Spectral', ...
    'Al', 1, SourceEn, 2.7, 0.75, 'T', []);

[~, CTrans] = IntSpec('/Users/josmond/Data/Spectral', ...
    'C', 1, SourceEn, 2.05, 0.88, 'T', []);

[~, ScintAtt] = IntSpec('/Users/josmond/Data/Spectral', ...
    'CsI', 1, SourceEn, 3.9, 0.4, 'A', []);

%[~, ScintAtt] = IntSpec('/Users/josmond/Data/Spectral', ...
%    {'W' 'Zn' 'O'}, [66 184 64], SourceEn, 7.62, 4, 'A', OutDir);

DetAtt =  AlTrans.*CTrans.*ScintAtt;
FiltAtt = FilterTrans.*DetAtt;
DiffAtt = DetAtt-FiltAtt;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate transmission spectra through body:

TissGoldTrans = TissTrans.*GoldTrans;

plot(SourceEn,TissTrans*100,'-b');
hold on;
plot(SourceEn,TissGoldTrans*100,'--r');
hold off;

set(gca,'xLim',xLim);
xlabel('Energy (MeV)');
ylabel(['Transmission (%)']);
legend([num2str(TissThick) ' mm Tissue'],...
    [num2str(TissThick) ' mm Tissue + ' num2str(GoldThick) ' mm Gold'],...
    'Location','NW')

WritePlot(OutDir, 'BodyTrans', [], 'n');

% Calculate flux through body:

TissFlux = SynEnFlux.*TissTrans;
TissGoldFlux = SynEnFlux.*TissGoldTrans;
Contrast = (TissTrans-TissGoldTrans)./TissTrans;

Scale = max(TissFlux);

plot(SourceEn,100*TissFlux/Scale,'-b');
hold on;
plot(SourceEn,100*TissGoldFlux/Scale,'--r');
plot(SourceEn,100*Contrast,'-.k');
%[AX1,H1,H2] = plotyy(SourceEn,TissGoldFlux/Scale, SourceEn, Contrast,'plot');
hold off;

set(gca,'xLim',xLim);
xlabel('Energy (MeV)');
ylabel(['Energy Flux & Contrast (%)']);
legend([num2str(TissThick) ' mm SW'],...
    [num2str(TissThick) ' mm SW + ' num2str(GoldThick*1000) ' {\mu}m Au'],...
    'Contrast',...
    'Location','NE')

WritePlot(OutDir, 'BodyFlux', [], 'n');

% Plot detector attenuation spectrum:

plot(SourceEn,DetAtt*100,'-b');
hold on;
plot(SourceEn,FiltAtt*100,'--r');
plot(SourceEn,DiffAtt*100,'-.g');
hold off;

set(gca,'xLim',xLim);
xlabel('Energy (MeV)');
ylabel(['Detector Response (%)']);
legend('XVI',['XVI + ' num2str(CuThick) ' mm Cu'],'Difference')

WritePlot(OutDir, 'Detector', [], 'n');

plot(SourceEn,Contrast*100,'-b');

set(gca,'xLim',xLim);
xlabel('Energy (MeV)');
ylabel(['Contrast (%)']);
%legend('Filtered','Difference','Location','NW')

WritePlot(OutDir, 'Contrast', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate spectrum of Fluence detected through soft tissue and gold marker:

display(' ');
display('Calculating Unfiltered spectrum...');

TissFlux = SourceFlux.*TissTrans;
TissGoldFlux = SourceFlux.*TissGoldTrans;
ConUnFilt = (sum(TissFlux)-sum(TissGoldFlux))/sum(TissFlux);
%ConUnFilt = sum(TissFlux)-sum(TissGoldFlux);

display(' ');
display(['Flux out of Tissue: ' num2str(sum(TissFlux))]);
display(' ');
display(['Flux out of Tissue+Gold: ' num2str(sum(TissGoldFlux))]);
display(' ');
display(['Contrast: ' num2str(ConUnFilt)]);

% Apply filter:

display(' ');
display('Calculating Filtered spectrum...');

TissFluxFilt = TissFlux.*FilterTrans;
TissGoldFluxFilt = TissGoldFlux.*FilterTrans;
ConFilt = (sum(TissFluxFilt)-sum(TissGoldFluxFilt))/sum(TissFluxFilt);
%ConFilt = sum(TissFluxFilt)/sum(TissGoldFluxFilt);

display(' ');
display(['Flux out of Tissue: ' num2str(sum(TissFluxFilt))]);
display(' ');
display(['Flux out of Tissue+Gold: ' num2str(sum(TissGoldFluxFilt))]);
display(' ');
display(['Contrast: ' num2str(ConFilt)]);

% Calculate difference:

display(' ');
display('Subtracting spectra...');

TissFluxDiff = TissFlux-TissFluxFilt;
TissGoldFluxDiff = TissGoldFlux-TissGoldFluxFilt;
ConDiff = (sum(TissFluxDiff)-sum(TissGoldFluxDiff))/sum(TissFluxDiff);
%ConDiff = sum(TissFluxDiff)/sum(TissGoldFluxDiff);

display(' ');
display(['Flux out of Tissue: ' num2str(sum(TissFluxDiff))]);
display(' ');
display(['Flux out of Tissue+Gold: ' num2str(sum(TissGoldFluxDiff))]);
display(' ');
display(['Contrast: ' num2str(ConDiff)]);

display(' ');
display(['Improvement: ' num2str(ConDiff/ConUnFilt)]);