%clear all
%close all hidden
%clc

% [Dose] = DepthDose('/Users/josmond/Data/Spectral/LinacFlux6MV.txt', 1, 2, '/Users/josmond/Data/Spectral/CsIAtt.txt', 1, 3, [1 2 3 4 5 6 7 8 9 10], 4.51)

% Depth:  Array of depths in mm.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Dose] = DepthDose(FluFile, FluEnCol, FluValCol, ...
    AttFile, AttEnCol, AttValCol, Depth, Density)

% Set up dose data:

Dose = Depth * 0;

% Read in source fluence:

Data = double(importdata(FluFile));
FluEn = Data(:,FluEnCol);
Flu = Data(:,FluValCol);
%FluStart = sum(Flu.*FluEn);

% Read in attenuation co-efficients:

Data = double(importdata(AttFile));
AttEn = Data(:,AttEnCol);
Att = Data(:,AttValCol);

% Interpolate:

FluInt = interp1(FluEn,Flu,AttEn);
Ind = find(isfinite(FluInt));
%AttCoInt = interp1(AttEn,Att,FluEn);

for i = 1:length(Dose)
    
    AttFrac = 1-exp(-1.*Att(Ind).*Density.*(Depth(i)/10));
    DoseSlice = sum(FluInt(Ind).*AttEn(Ind).*AttFrac)/sum(FluInt(Ind).*AttEn(Ind))
    Dose(i) = DoseSlice - sum(Dose);
    
end

plot(Depth,Dose)

end