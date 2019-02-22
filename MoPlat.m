clc
clear all

OutDir = '/Users/josmond/Results/MoPlat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tlo = 0;
thi = 6;
dtexp = 5;
dt = (2^dtexp)/1000;
t = tlo:dt:thi;

%MaxSpeed = 15 rotations per second
%4000 steps per revolution
%pitch = 2 mm = 1 rotation
%therefore 1 step = 2/4000 = 0.5 micron.
%max speed = 15 rotation/s = 30 mm/s
%max speed = 15 * 4000 =  60000 step/s
%max step in 1 dt (dt = 5) = 1920
%MaxStep = 15*dx;
% max of 1920
% Limit speed to 20/mm/s
MaxSpeed = 0.64; % mm/dt

% x = side/side, y = up/down, z = forwards/backwards

NumLoops=100;

%Lujan:

%y = 2*sin(x*((2*pi)/4));
z0 = 0;
b = 20; % Maximum displacement.
n = 2; % Flatness of sine wave.
tau = 6; % Period in seconds.
z = b/2 - b*(cos((((pi*t)/tau) + (pi/2))).^(2*n));

%plot(t,z);

% Differentiate function:

dif = diff(z);

disp(['Max z Speed = ' num2str(max(abs(dif))/dt) ' mm/s']);

% Integrate function:

int = dt*sum(z);

% Calculate random walk for other dimensions:

trand = t(1:length(t)/2);
disp = b/4;
step = disp / sqrt(length(trand));

% Creat random walk array

randhalf = MaxSpeed*2*(rand(2,length(trand)) - 0.5);
randall = [randhalf randhalf.*(-1)];

max(abs(reshape(randall,1,[])))/dt

plot(t,cumsum(randall))

% Write results to output file:

fid = fopen([OutDir '/Lung.dmc'], 'w');

count = fprintf(fid, '#START\n');
count = fprintf(fid, 'PA 0,0,%d;\n', b*0.5*2000);
count = fprintf(fid, '#AGAIN; JP #AGAIN, _BNC>0;');
count = fprintf(fid, 'CM XYZ\n');
count = fprintf(fid, 'DT%u\n', dtexp);
count = fprintf(fid, 'V1=0;\n');
count = fprintf(fid, 'MG{P1}"Begin contour mode"\n');
count = fprintf(fid, 'ttt=TIME\n');
count = fprintf(fid, 'MG{P1}ttt\n');
count = fprintf(fid, '#LOOP\n');

%platform moves in half micron steps

for i = 1:length(dif)
    
    X = round(randall(1,i)*2000);
    Y = round(randall(2,i)*2000);
    Z = round(dif(i)*2000);
    
    lung(i) = Z/2000;
    
    count = fprintf(fid, 'CD %d,%d,%d\n', X, Y, Z);
end

count = fprintf(fid, 'V1=V1+1;\n');
count = fprintf(fid, '#HERE; JP #HERE, _CM<>511;\n');
count = fprintf(fid, 'JP #LOOP, V1<%u;\n', NumLoops);
count = fprintf(fid, 'ttt2=TIME-ttt\n');
count = fprintf(fid, 'MG{P1}"End of loop."');
count = fprintf(fid, 'WT %u;\n', 2^dtexp);
count = fprintf(fid, 'DT0;\n');
count = fprintf(fid, 'CD 0,0,0;\n');
count = fprintf(fid, 'ttt3=ttt2*1000/1024\n');
count = fprintf(fid, 'MG{P1}ttt2\n');
count = fprintf(fid, 'MG{P1}ttt3\n');
count = fprintf(fid, 'MG{P1}{F1.0}V1\n');
count = fprintf(fid, 'MG{P1}"End contour mode."\nEN\n');

st = fclose(fid);

plot(t(1:end-1),cumsum(lung)+(b/2),'b',...
    t,cumsum(randall(1,:)),'r',...
    t,cumsum(randall(2,:)),'g');
xlabel('Time (s)');
ylabel('Displacement (mm)');

WritePlot(OutDir, 'Lung', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%trand = t(1:length(t)/2);

%disp = 10;
%step = disp / sqrt(length(t));

% Creat random walk array

%randarray = rand(3,length(t)) - 0.5;
%prosarray = permute([t ; step*(randarray./abs(randarray))], [2 1]);

%MakeSpread(prosarray,[outdir '/prostate.csv'])
%MakePlot(t,cumsum(prosarray(:,4)),'n','Time (s)','Displacement (mm)',[outdir '/prostate'])

%hold on
%plot(t,cumsum(prosarray(:,2)),'-r');
%plot(t,cumsum(prosarray(:,3)),'-g');
%hold off
%plotname = [outdir '/prostate'];
%print('-depsc2','-tiff',[plotname '_col.eps']);
%print('-deps2',[plotname '_bw.eps']);

%close;


S = load('/Users/josmond/Data/Shirato/hokudai/j2.mat','yConcat');

for i = 1:size(S.yConcat,2)
    if (i==1)
        All = S.yConcat{i};
    else
        All = [All; S.yConcat{i}];
    end
end

disp([num2str(median(abs(diff(All))))]);



