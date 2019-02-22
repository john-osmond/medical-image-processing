% INTRODUCTION

% Script to analyse i

%function [] = Proton(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clearvars -except VarFile
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% VARIABLES

VarFile = '/Users/josmond/Google Drive/Software/Matlab/Variables/Dynamite/ProtonBham.txt'

% Read variables into a structured array:

[Var] = ReadVar(VarFile);

% Copy structured array elements to individual variables:

for i = 1:size(Var,2)
    if ( strcmp(char(Var(i).Type),'s') == 1 )
        eval([char(Var(i).Name{:}) '= char(Var(i).Value{:});']);
    else
        eval([char(Var(i).Name{:}) '= cell2mat(Var(i).Value);']);
    end
end

setenv('Ins', 'DynamiteP');
setenv('Name', 'ProtonBham');
setenv('InDir', ['/Users/josmond/Data/' getenv('Ins') '/' getenv('Name')]);
setenv('OutDir', ['/Users/josmond/Google Drive/Results/' getenv('Ins') '/' getenv('Name')]);

ExpTime = 100;
ROICo = [390 1050 440 1100];
BeamCo = [325 325];
ROut = 250;
ProfOut = 340;

% Calculate quantitative constants:

NoFrames = single(diff(Frames));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check dark correction:

%DarkName = 'Dark100';
%[DarkImg] = ReadData([DarkName 'Mean'], [], []);
%[TestImg] = ReadData('HolesDiameterMean', [], []);
%imtool(TestImg-DarkImg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PHANTOM

DarkName = 'DarkNoLight';
[DarkImg] = ReadData([DarkName 'Mean'], [], ROICo);

FloodName = 'FloodAfterWedge';
[FloodImg] = ReadData([FloodName 'Mean'], [], ROICo);

FloodImg = (FloodImg-DarkImg)/max(reshape((FloodImg-DarkImg),[],1));
FloodImg(FloodImg<=0) = NaN;

DataName = {'HolesDepth' 'HolesDiameter' 'WedgeA' 'WedgeB' 'WedgeC' 'Bone'};
PrintName = {'Holes Varying Depth' 'Holes Varying Diameter' 'Wedge A' 'Wedge B' 'Wedge C' 'Bone'};

% Loop around phantoms and correct

for i = 1:length(DataName)
    
    [DataImg] = ReadData([DataName{i} 'Mean'], [], ROICo);
    
    CorImg = (DataImg-DarkImg)./FloodImg;
    %CorImg(CorImg<0) = 0;
    CorImg = RemoveLine(CorImg, 'x', [281 281]);
    
    WriteImg(CorImg, PrintName{i}, [], 0.1, 'n');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Analyse holes of varying depth:

clear Rad Prof

DataName = 'HolesDepth';

HoleCo = [180 295; 287 153; 455 210; 453 387; 283 439];
HoleRad = 50;
X = HoleRad+1;
Y = HoleRad+1;

[DataImg] = ReadData([DataName 'Mean'], [], ROICo);

CorImg = (DataImg-DarkImg)./FloodImg;
%CorImg(CorImg<0) = 0;
CorImg = RemoveLine(CorImg, 'x', [281 281]);

for j=1:size(HoleCo,1)
    
    ROI = CorImg(HoleCo(j,2)-HoleRad:HoleCo(j,2)+HoleRad,HoleCo(j,1)-HoleRad:HoleCo(j,1)+HoleRad);
    
    % Use 5 or 2:
    
    [Prof(j,:), Rad(j,:)] = RadProf(ROI, [], 2);
    
    %imagesc(ROI, prctile(reshape(ROI, 1, []), [1 99]));
    %colormap('gray')
    %axis image;
    %line([X X],[Y-15 Y+15],'LineStyle','-','Color','r');
    %line([X-15 X+15],[Y Y],'LineStyle','-','Color','r');
    %pause
    
end

% 1 2 3 5 10 mm wide, 2 3 4 5 6

% Scale all profiles to the same outermost value:

ScaleCos = find(Rad(1,:)>45);
ScaleCo = ScaleCos(1);
ProfScale = repmat(mean(Prof(:,ScaleCo))./Prof(:,ScaleCo),1,size(Prof,2));
Prof = Prof.*ProfScale;

% Plot radial profile and write to file:

Line = {'-b' '--r' '-.g' ':k' '-m' '--c' '-.b' ':r'};
for i = 1:size(Prof,1)
    plot(Rad(1,:)*0.1,Prof(size(Prof,1)-i+1,:), char(Line(i)));
    hold on;
end
hold off;
%plot(Rad(1,:)*0.1,Prof)

xlim([0.25 4.75]);
ylim([1000 7000]);
xlabel(gca,'Radius (mm)');
ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
legend('2 mm', '3 mm', '4 mm', '5 mm', '6 mm', 'Location', 'NorthWest');
line([2.5 2.5],[1000 7000],'LineStyle','--','Color','k');
WritePlot('Holes Varying Depth Prof', [], 'n');

% Plot central signal vs depth of hole:

plot([2 3 4 5 6],Prof(:,1), '-kd', 'MarkerEdgeColor', 'b')
xlim([1.5 6.5]);
ylim([1500 3500]);
xlabel(gca,'Depth of Hole (mm)');
ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
WritePlot('Signal Depth', [], 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Analyse holes of varying diameter:

clear Rad Prof

DataName = 'HolesDiameter';

%HoleCo = [180 295; 287 153; 455 210; 453 387; 283 439];
HoleCo = [210 403; 210 226; 378 169; 482 312; 380 456];
HoleRad = 60;
X = HoleRad+1;
Y = HoleRad+1;

[DataImg] = ReadData([DataName 'Mean'], [], ROICo);

CorImg = (DataImg-DarkImg)./FloodImg;
%CorImg(CorImg<0) = 0;
CorImg = RemoveLine(CorImg, 'x', [281 281]);

for j=1:size(HoleCo,1)
    
    ROI = CorImg(HoleCo(j,2)-HoleRad:HoleCo(j,2)+HoleRad,HoleCo(j,1)-HoleRad:HoleCo(j,1)+HoleRad);
    
    [Prof(j,:), Rad(j,:)] = RadProf(ROI, [], 2);
    
    %imagesc(ROI, prctile(reshape(ROI, 1, []), [1 99]));
    %colormap('gray')
    %axis image;
    %line([X X],[Y-35 Y+35],'LineStyle','-','Color','r');
    %line([X-35 X+35],[Y Y],'LineStyle','-','Color','r');
    %pause
        
end

%imagesc(CorImg, prctile(reshape(ROI, 1, []), [1 99]));
%colormap('gray')
%axis image;
%rectangle('Position', [180 160 305 305], 'Curvature', [1 1], 'Edgecolor', 'r') 

% 1 2 3 5 10 mm wide, 2 3 4 5 6

% Scale all profiles to the same outermost value:

ScaleCos = find(Rad(1,:)>65);
ScaleCo = ScaleCos(1);
ProfScale = repmat(mean(Prof(:,ScaleCo))./Prof(:,ScaleCo),1,size(Prof,2));
Prof = Prof.*ProfScale;

MeanMax = mean(max(Prof,[],2));
RadHi = [0.5 1 1.5 2.5 5];

for i =1:size(Prof,1)
    xCos = find(Rad(i,:)/10 > RadHi(i)*4);
    if numel(xCos) > 0; xCoHi = xCos(1); else xCo = size(Rad,2); end
    xCoHi
    
    %Scale = MeanMax/max(Prof(i,1:xCoHi))
    %Prof(i,:) = Prof(i,:)*Scale;
    
    MinMax = [min(Prof(i,1:xCoHi)) max(Prof(i,1:xCoHi))];
    RadHalf(i) = interp1(Prof(i,1:xCoHi),Rad(i,1:xCoHi)*0.1, mean(MinMax));
end

% Plot radial profile and write to file:

Line = {'-b' '--r' '-.g' ':k' '-m' '--c' '-.b' ':r'};
for i = 1:size(Prof,1)
    plot(Rad(1,:)*0.1,Prof(size(Prof,1)-i+1,:), char(Line(i)));
    hold on;
end
hold off;
%plot(Rad(1,:)*0.1,Prof)

xlim([0.25 7.75]);
ylim([2000 8000]);
xlabel(gca,'Radius (mm)');
ylabel(gca,'Signal (DN pixel^{-1} frame^{-1})');
legend('0.5 mm', '1 mm', '1.5 mm', '2.5 mm', '5 mm', 'Location', 'SouthEast');

Colour = {'b' 'g' 'r' 'c' 'm'};
for i=1:5
    Sig = interp1(Rad(i,1:xCoHi)*0.1, Prof(i,1:xCoHi), RadHi(i));
    line([RadHi(i) RadHi(i)], [Sig-300 Sig+300], 'LineStyle','--','Color','k');
end

WritePlot('Holes Varying Diameter Prof', [], 'n');

% Plot r50 vs hole radius:

plot([0.5 1 1.5 2.5 5], RadHalf, '-kd', 'MarkerEdgeColor', 'b')
xlim([0 5.5]);
ylim([0 5]);
line([-1 6],[-1 6],'LineStyle','--','Color','k');
xlabel(gca,'Radius of Hole (mm)');
ylabel(gca,'r_{50} (mm)');
WritePlot('r50 Radius', [], 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%