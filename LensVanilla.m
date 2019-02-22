clc
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Lens variables:

fl_min = 990                        % Minimum object distance.

f_max = 50                          % Maximum focal length.
f_min = 1/((1/f_max)+(1/fl_min));   % Minimum focal length.

F_min = 1.5                         % Minimum F-number.
F_max = 22                          % Maximum F-number.

D = f_min/F_min                     % Aperture diameter.

% Box variables:

screen = 405;                       % Length of edge of screen.
det = 56;                           % Length of edge of detector.
s1_min = 570;                       % Minimum object distance.

m_ideal = screen/det                % Ideal Magnification.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Usable values:

s1 = 1040                           % Lens to object distance.
f = 30                              % Focal length.

s2 = 1/((1/f)-(1/s1))               % Lens to detector distance.
m = s1/s2                           % Magnification.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Swindell optical coupling equation:

n = 1.6                             % Refractive index of screen.
k = 1/(16*(n^2))
F = f/D                             % F-number.

F = 5.6
m = 12.9

g1 = 20000                          % No of opt photons per scint event.
g2 = k*((F*(1+(m)))^-2)             % Prob that photon reaches detector.
g3 = 0.3*0.9*0.5                    % Product of all other loss factors.

g = g1*g2*g3                        % No of detected optical photons per x-ray. photon


r = sqrt(1+(1/g))                   % Reduction factor in SNR.