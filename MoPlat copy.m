clc
clear all

outdir = '/Users/josmond/Results/MovMark';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xlo = 0;
dx = 0.128;
xhi = 60;
x = xlo:dx:xhi;

%MaxSpeed = 15;
%MaxStep = 15*dx;

%Lujan:

%y = 2*sin(x*((2*pi)/4));
z0 = 0;
b = 25; % Maximum displacement.
n = 3; % Flatness of sine wave.
tau = 4; % Period in seconds.
y = z0 - b*(cos(((pi*x)/tau + 0.5)).^(2*n));

plot(x,y);

% Differentiate function:

for i = 2:length(x)
    dif(i) = (y(i)-y(i-1))/(dx);
end

%plot(x(2:end),dif(2:end));

lung = dif * dx;

max(dif) % This is the maximum speed

% Integrate function:

int = dx*sum(y);

% Write results to output file:

fid = fopen([outdir '/lung.dmc'], 'w');

Rows = 10
Wait = 30000
Time = 8

count = fprintf(fid, 'CM XYZ\nWT %u\nDT%u\n', Wait, Time);

for Row = 1:Rows
    
    X = 1305;
    Y = -1305;
    Z = 1305;
    
    count = fprintf(fid, 'CD %d,%d,%d; WC\n', X, Y, Z);
end

count = fprintf(fid, 'DT0; CD0;\n');

st = fclose(fid);
a = 1
pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp = 10;
step = disp / sqrt(length(x))

% Creat random walk array

randarray = rand(3,length(x)) - 0.5;

prosarray = permute([x ; step*(randarray./abs(randarray))], [2 1]);
MakeSpread(prosarray,[outdir '/prostate.csv'])
MakePlot(x,cumsum(prosarray(:,4)),'n','Time (s)','Displacement (mm)',[outdir '/prostate'])

hold on
plot(x,cumsum(prosarray(:,2)),'-r');
plot(x,cumsum(prosarray(:,3)),'-g');
hold off
plotname = [outdir '/prostate'];
print('-depsc2','-tiff',[plotname '_col.eps']);
print('-deps2',[plotname '_bw.eps']);

close;