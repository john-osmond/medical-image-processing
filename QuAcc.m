7clear all
close all hidden
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set some constants:

OutDir = '/Users/josmond/Results/Quantum_Accounting';
Name = 'QuAcc';

DoseRate = 550; % Dose rate of Linac in MU/min or cGy/min at isocentre.
DoseRateJkg = DoseRate /60 /100; % Dose rate in J/kg/s.

EnergyMeV = 1.67; % Mean photon energy in MeV.
ElectronCharge = 1.6 * 10^-19; % C.
EnergyJ = EnergyMeV * 10^6 * ElectronCharge; % Mean photon energy in J.

% The energy transfer co-eff is the total fraction of incident photon energy
% which is transferred to charged particles.  Ignores energy released via
% brem x-rays and scattered photons.

% The energy absorption co-eff is the fraction of photon energy which is
% absorbed.

EnTrCo = 0.0574; % Energy Transfer Coefficient in cm^2/g.
EnAbCo = 0.02833; % Energy Absorption Coefficient in cm^2/g.

% The energy transfer co-efficient is the total fraction of energy lost

AbFrac = EnAbCo/EnTrCo;

% Fraction of energy lost by photon which is absorbed by medium.  The rest
% of the energy is carried away by x-ray photons via brem.

SAD = 1; % Source axis distance in m.
SDD = 1.55; % Source detector distance in m.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X-ray flux at Isocentre:

FluxIso = DoseRateJkg/(EnergyJ*EnAbCo*1000);  % Flux at isocentre in /cm^2/s.

% X-ray flux to scintillator:

FluxToScint = FluxIso * (SAD/SDD)^2; % Flux at detector in /cm^2/s.

% X-ray flux absorbed in scintillator:

ScintEff = 0.015;

FluxInScint = FluxToScint * ScintEff;

% Optical flux from scintillator:

g = 56000; % Optical photons per x-ray per MeV.

OptEff = AbFrac * EnergyMeV * g; % Optical conversion factor

FluxFromScint = FluxInScint * OptEff;

% Optical flux to detector:

CoupEff = 0.5; % Optical coupling efficiency.

FluxToDet = FluxFromScint * CoupEff;

% Optical flux absorbed in detector:

DetQE = 0.5; % Quantum efficiency of detector.

FluxInDet = FluxToDet * DetQE;

% Electron flux generated in detector:

ElecCon = 1; % Number of electrons produced per absorbed x-ray.

ElecFlux = FluxInDet * ElecCon;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y = [FluxIso FluxToScint FluxInScint FluxFromScint FluxToDet FluxInDet ElecFlux];
x = 1:length(y);

ylo = 10^7;
yhi = 10^13;

fontsize = 14;
linewidth = 1.4;
markersize = 10;

set(0,'DefaultLineLineWidth',linewidth,...
    'DefaultTextFontSize',fontsize,...
    'DefaultAxesFontSize',fontsize);

axes('YScale','log','XLim',[min(x)-0.5 max(x)+0.5],'XTick',x,'YLim',[ylo yhi],...
    'Box','on','Linewidth',linewidth);

xreg = [0.5 0.5 3.5 3.5];
yreg = [ylo yhi yhi ylo];
patch(xreg, yreg, [0.95 1.0 0.95]);

xreg = [3.5 3.5 6.5 6.5];
patch(xreg, yreg, [0.95 0.95 1.0]);

xreg = [6.5 6.5 7.5 7.5];
patch(xreg, yreg, [1.0 1.0 0.95]);

hold on;

semilogy(x,y,'-ko','MarkerEdgeColor','k','MarkerFaceColor','w',...
    'MarkerSize',markersize);

hold off;

% Add text

text(1.7, 2*10^7, 'x-rays');
text(4.6, 2*10^7, 'photons');
text(6.95, 2*10^7, 'e^{-}');

% Label axes:

xlabel('Stage');
ylabel('Particle Flux (cm^{-2} s^{-1})');

% Print to file and close plot:

print('-depsc2','-tiff',[OutDir '/' Name '_col.eps']);
print('-deps2',[OutDir '/' Name '_bw.eps']);

close;