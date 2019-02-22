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

set(gca,'xLim',[0 5]);
title('Linac Emission Spectrum')
xlabel('Energy (MeV)');
ylabel('Flux (cm^{-2} s^{-1})');

line([0.01 0.01],[0 7000000],'LineStyle','-','Color','k')

line([1 1],[0 70000000],'LineStyle','-','Color','k')

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
display(['Flux out of Synergy: ' num2str(sum(SynFlux))])