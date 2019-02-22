clc

% Define frequencies:

f1 = 5;
f2 = 10;

% Define time range:

tint = 0.01;
tmax = 1;
t = 0:tint:tmax;

% Generate two sin waves, add noise and plot:

y = sin(f1*(2*pi)*t) + sin(f2*(2*pi)*t);
yn = y + randn(size(t));

plot(t,yn);
xlabel('time (seconds)')
ylabel('noisy signal')

% Define no of points to use in Fourier Transform:

poi = 1024;
nyq = round(poi/2);

% Calculate Fast Fourier Transform (FFT) of data:

ffty = fft(yn,poi);
ps = ffty .* conj(ffty) / 512;
f =(1/tint)*(0:(nyq))/poi;

% Plot Power Spectrum:

plot(f,ps(1:(nyq+1)));
xlabel('Frequency (Hz)');
ylabel('Power');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create image:

img = zeros(512,512);