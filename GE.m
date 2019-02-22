% INTRODUCTION

% Script to create plots for GE.

%function [] = Proton(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clearvars -except VarFile
close all hidden
clc
tic
setenv('OutDir', '/Users/John/Google Drive/Results/GE');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Res =  [0   0.1  0.17 0.25 0.5  1];
%MTF1 = [1.1 1    0.83 0.4  0.1 0.02];
MTF1 = [1   0.9  0.75 0.36 0.09 0.02];
MTF2 = [1   0.58 0.18 0.03 0    0];

plot(Res,MTF1, '-bd', 'MarkerSize', 12, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w')
hold on
plot(Res,MTF2, '-rd', 'MarkerSize', 12, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w')
hold off

line([0 1], [0.5 0.5], 'LineStyle', '--', 'Color', 'k');
line([0.115 0.115], [0.14 0.5], 'LineStyle', '--', 'Color', 'k');
line([0.115 0.115], [0 0.03], 'LineStyle', '--', 'Color', 'k');

line([0.225 0.225], [0 0.5], 'LineStyle', '--', 'Color', 'k');
legend('CMOS', 'PMT', 'Location', 'NorthEast')
text(0.035, 0.06, 'f_{50} = 0.11');
text(0.24, 0.55, 'f_{50} = 0.23');

xlim([0 1]);
ylim([0 1]);
xlabel(gca,'Spatial Frequency (cycles mm^{-1})');
ylabel(gca,'MTF');
WritePlot('MTF', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Scatter

Position = -4:0.02:4;
Radius=10;
X=0;
Y=-9.93;
Scatter = ((Radius.^2)-(0.06*(Position-X).^2)).^0.5+Y;

% PSF

FWHM = 0.2;
Position = -4:0.02:4;
sigma=FWHM/2.35;
mu=0;
Signal = exp(- 0.5 * ((Position - mu) / sigma) .^ 2) / (sigma * sqrt(2 * pi));
for i=1:length(Signal)
    Noise(i) = 0.05*randn(1);
end
SignalNoise = Signal+Noise+(5*Scatter);
Norm = max(SignalNoise);
SignalNoise = SignalNoise/(Norm);
plot(Position, SignalNoise, 'Color', 'b')
hold on

FWHM = 3.8;
Position = -4:0.02:4;
sigma=FWHM/2.35;
mu=0;
Signal = exp(- 0.5 * ((Position - mu) / sigma) .^ 2) / (sigma * sqrt(2 * pi));
for i=1:length(SignalNoise)
    Noise(i) = 0.002*randn(1);
end
SignalNoise = Signal+Noise+(2*Scatter);
Norm = max(SignalNoise);
SignalNoise = SignalNoise/(Norm);
plot(Position, SignalNoise, 'Color', 'r')
%plot(Position, Scatter, 'Color', 'g')
hold off

%legend('CMOS FWHM = 0.2', 'PMT FWHM = 3.9', 'Location', 'NorthEast')
text(0.3, 0.2, 'CMOS = 0.2 mm', 'Color', 'k')
text(1.2, 0.9, 'PMT = 3.8 mm', 'Color', 'k')
xlim([-4 4]);
ylim([-0.05 1]);
xlabel(gca,'Position (mm)');
ylabel(gca,'LSF');
WritePlot('LSF', [], 'n');