% INTRODUCTION

% Script to process image data of Atlantis phantom.

%function [Dose, SNR, CNRStat, MR, Success] = MovingMarker(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VarFile = '/Users/josmond/Library/Matlab/Variables/LAS/MovingMarker20.txt'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clearvars -except VarFile Location
close all hidden
%clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% READ VARIABLES

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SET CONSTANTS

% Calculate qualitative constants:

InDir = ['/Users/josmond/Data/' Ins '/' Name];
OutDir = ['/Users/josmond/Results/' Ins '/' Name];

% Calculate quantitative constants:

NoFrames = single(diff(Frames));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUT DATA

% Read dark data:

[Dark] = ReadData(InDir, DarkName, Ins, Frames, ROICo);
[Dark, ~] = RemoveOutliers(Dark);
%[~, Dark] = RemoveSpikes(Dark, ROICo(3));
DarkImg = nanmedian(Dark,3);
clear Dark;

% Read flood data:

[Flood] = ReadData(InDir, FloodName, Ins, Frames, ROICo);
[Flood, ~] = RemoveOutliers(Flood);
%[~, Flood] = RemoveSpikes(Flood, ROICo(3));
[Flood, ~] = RemoveBars(Flood);
FloodImg = nanmedian(Flood,3);
clear Flood;

% Read data:

[Data] = ReadData(InDir, DataName, Ins, Frames, ROICo);

[~, ~, NoSpikeInd] = RemoveSpikes(Data, ROICo(3));

% Correct data:

[Data, ~] = CorImg(Data, DarkImg, FloodImg);
%TimeSeries(Data, OutDir, num2str(DoseMin), ROICo(3));
[Data, ~] = RemoveOutliers(Data);
[Data, ~] = RemoveBars(Data);

% Plot frame mean and std vs time:

TimeSeries(Data, OutDir, num2str(DoseMin), ROICo(3));

% Normalise frames:

[Data] = NormFrames(Data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CREATE MOVIE

WriteAVI(Data, '/Users/josmond/Desktop/LAS.avi', [3800 7200], 20);

pause

%WriteAVI(Data, [OutDir '/' 'Example.avi'], [3800 7200], 20);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop round different number of frames to add:

% Create time array:

tLo = 0;
tHi = (size(Data,3)-1)/FrameRate;
t = reshape(tLo:1/FrameRate:tHi,[],1);

clear CNRAll dAll;

for i = 1:20
%i = 1
    
    display(['Sum of ' num2str(i) ' frame(s)']);
    display(' ');
    
    % Add frames to increase dose:
    
    FrameRateAdd = FrameRate/i;
    ti = round(1000/FrameRateAdd);
    DataAdd = AddFrames(Data,i);
    Dose(i) = double(DoseMin/(60*FrameRateAdd));
    
    % Add time:
    
    clear tAdd
    
    for j = 1:floor(numel(t)/i)
        IndLo = (j*i)-i+1;
        IndHi = (j*i);
        tAdd(j) = nanmean(t(IndLo:IndHi));
    end
    
    tAdd = reshape(tAdd,[],1);
    
    if (i > 1)
        clear LVal;
        for j = 1:4
            eval(['LMod = LModFirst' num2str(j) ';']);
            LVal(:,j) = LMod.d0 + LMod.a*(cos(((pi*tAdd)/LMod.tau)+LMod.c).^(2*n));
        end
    end
    
    % Looop round all frames and locate markers:
    
    clear Disp Con CNR
    
    for j = 1:size(DataAdd,3)
        if (i > 1)
            MarkY = LVal(j,:)*double(Scale);
        else
            MarkY = [];
        end
        [Disp(j,:), Con(j,:), CNR(j,:)] = FindMarker(DataAdd(:,:,j), MarkX-ROICo(1)+1, MarkY);
        Disp(j,:) = Disp(j,:)/double(Scale);
    end
        
    % Identify markers more than 2 mm from expected position and remove:
    
    DispGood = Disp;
    ConGood = Con;
    CNRGood = CNR;
    
    clear BadInd
    
    if ( i == 1 )
        
        % On first iteration use position of biggest marker:
        
        OffSet = [-3.7 -9.1 -14.4];
        
        for j = 2:4
            
            DispN = Disp(:,j)-Disp(:,1);
            
            BadInd(:,j) = DispN < OffSet(j-1)-2 | DispN > OffSet(j-1)+2;
            DispGood(BadInd(:,j),j) = NaN;
            ConGood(BadInd(:,j),j) = NaN;
            CNRGood(BadInd(:,j),j) = NaN;
            
        end
    else
        
        % Afterwards use model positions:
        
        for j = 1:4
            
            BadInd(:,j) = abs(Disp(:,j)-LVal(:,j)) > 2;
            DispGood(BadInd(:,j),j) = NaN;
            ConGood(BadInd(:,j),j) = NaN;
            CNRGood(BadInd(:,j),j) = NaN;
            
        end
    end
    
    Success(i,:) = nanmean(isfinite(DispGood),1);
    
    % Calculate SNR (check norm between frames):
  
    Signal = nanmedian(reshape(DataAdd(1:50,:,:),1,[]));
    Noise(i) = nanstd(reshape(DataAdd(1:50,:,:),1,[]));
    SNR(i) = Signal/Noise(i);
    
    % Calculate CNR for stationary markers:
    
    CNRStat(i,:) = ConStat/(Noise(i)/i);
    
    % Calculate number of saturadted pixels:
    
    SatFrac(i) = 100*(1-sum(reshape(DataAdd >= 5639,1,[]))/sum(reshape(isfinite(DataAdd),1,[])));
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set Lujan variables:

    d0 = 0;
    a = 20; % Peak to peak.
    tau = 6; % Period in seconds.0.03
    n = 2; % Flatness of sine wave.
    c = pi/2;
    
    % Fit marker position vs time:
    
    Dimm = [2 1.6 1.2 0.8 0.8];
    
    clear LVal LRes
    
    for j = 1:4
        
        % Fit displacement values for unaveraged data:
        
        if (i == 1)
            
            % Set fit options:
            
            FO = fitoptions('Method','NonlinearLeastSquares',...
                'Lower',[0,0,5,0],...
                'Upper',[50,50,7,10],...
                'Startpoint',[25,25,6,5]);
            
            % Set model:
            
            f = fittype('d0 + a*(cos(((pi*tAdd)/tau)+c).^(2*2))',...
                'coefficients',{'d0' 'a' 'tau' 'c'},...
                'independent','tAdd',...
                'options',FO);
            
            % Fit model:
            
            [LMod,gof2] = fit(tAdd(isfinite(DispGood(:,j))),...
                DispGood(isfinite(DispGood(:,j)),j),f);
            
            eval(['LModFirst' num2str(j) ' = LMod;']);
            
            % Print Results to screen:
            
            display(['Marker width = ' num2str(Dimm(j)) ' mm']);
            display(['Amplitude = ' num2str(LMod.a) ' mm']);
            display(['Time period = ' num2str(LMod.tau) ' s']);
            display(['Mean error = ' num2str(gof2.rmse) ' mm']);
            display(' ');
            
        end
        
        % Calculate model values and residual array:
        
        eval(['LMod = LModFirst' num2str(j) ';']);
        
        LVal(:,j) = LMod.d0 + LMod.a*(cos(((pi*tAdd)/LMod.tau)+LMod.c).^(2*n));
        LRes(:,j) = Disp(:,j) - LVal(:,j);
        
        % Store fit for plotting later
        
        if (i == 1); LValFirst(:,j) = LVal(:,j); end;
        
    end
    
    % Set
        
    LRes(LRes > 2) = NaN;
    MR(i,:) = nanstd(LRes,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Calculate velocity array:
    
    v = LVal(:,1)*0;
    for j = 2:size(LVal,1)-1;
        v(j) = (LVal(j+1,1)-LVal(j-1,1))/(tAdd(j+1)-tAdd(j-1));
    end
    v(1) = v(2);
    v(end) = v(end-1);
    
    % Calculate speed array:

    s = abs(v);
    
    % Calculate distance array:
    
    d = s*(ti/1000);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Plotting

    % Plot Displacement:Time graph:
    
    Marker = {'s' '^' 'o' 'x'};
    Colour = {'r' 'g' 'b' 'k'};
    for j=1:4; plot(tAdd(isfinite(DispGood(:,j))),DispGood(isfinite(DispGood(:,j)),j),[char(Marker(j)) char(Colour(j))]); hold on; end;
    for j=1:4; plot(t,LValFirst(:,j),char(Colour(j))); end;
    hold off;
    
    legend('2 mm','1.6 mm','1.2 mm','0.8 mm','Location','SouthEast');
    text(0.7,36,['{\it t}_{i} = ' num2str(50*i) ' ms']);
    xlim([0 6]);
    xlabel(gca,'{\it t} (s)');
    ylabel(gca,'{\it s} (mm)');
    WritePlot(OutDir, ['DispTime' num2str(DoseMin) 'F' num2str(i)], [], 'n');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Plot Contrast:Speed graph:
    
    Line = {'-rs' '--g^' '-.bo' ':kx'};
    
    for j = 1:4
        [XBin, YBin, YBinErr, NBin] = BinData(s, Con(:,j), 0, 14, 7);
        errorbar(XBin,YBin,YBinErr,char(Line(j)));
        hold on;
    end
    
    hold off;
    xlim([0 14]);
    ylim([0 14]);
    legend('2 mm','1.6 mm','1.2 mm','0.8 mm');
    text(1,12.6,['{\it t}_{i} = ' num2str(ti) ' ms']);
    xlabel(gca,'{\it v} (mm s^{-1})');
    ylabel(gca,'{\it C} (%)');
    WritePlot(OutDir, ['ConSpeed' num2str(DoseMin) 'F' num2str(i)], [], 'n');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Plot CNR:Speed graph:
    
    Line = {'-rs' '--g^' '-.bo' ':kx'};
    
    for j = 1:4
        [XBin, YBin, YBinErr, NBin] = BinData(s, CNR(:,j), 0, 14, 7);
        errorbar(XBin,YBin,YBinErr,char(Line(j)));
        hold on;
        if (j == 1); yHi = ceil(max(YBin+YBinErr)); end
    end
    
    hold off;
    legend('2 mm','1.6 mm','1.2 mm','0.8 mm');
    %text(11.2,0.65*yHi,['{\it t}_{i} = ' num2str(ti) ' ms']);
    xlim([0 14]);
    %ylim([0 yHi]);
    xlabel(gca,'{\it v} (mm s^{-1})');
    ylabel(gca,'{\it CNR}');
    WritePlot(OutDir, ['CNRSpeed' num2str(DoseMin) 'F' num2str(i)], [], 'n');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Save variables:
    
    if (i == 1)
        ConAll = ConGood;
        dAll = d;
        CNRAll = CNR;
    else
        ConAll = [ConAll; ConGood];
        dAll = [dAll; d];
        CNRAll = [CNRAll; CNR];
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot Success vs CNR:

for i = 1:20
    Ind = CNRAll > i-1 & CNRAll <= i;
    SuccessBin(i) = 100*sum(isfinite(ConAll(Ind)))/numel(ConAll(Ind));
    CNRBin(i) = i-0.5;
end

plot(CNRBin,SuccessBin,'-db')
xlim([0 20]);
ylim([0 105]);
xlabel(gca,'{\it CNR}');
ylabel(gca,'{\it Success} (%)');
%line([0 20],[50 50],'LineStyle','-','Color','k')

WritePlot(OutDir, ['SuccessCNR' num2str(DoseMin)], [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot SNR vs dose

plot(Dose,SNR,'^');
xlim([0 2.5]);
ylim([60 220]);
xlabel(gca,'{\it d} (MU)');
ylabel(gca,'{\it SNR}');

FO = fitoptions('Method','NonlinearLeastSquares','Lower',[0,0,0],'Upper',[20,5,50],'Startpoint',[10,2,25]);
f = fittype('m*(Dose.^n)+c','coefficients',{'m' 'n' 'c'},'independent','Dose','options',FO);
[Mod,gof2] = fit(reshape(Dose,[],1),reshape(SNR,[],1),f);

hold on;
plot(Dose,Mod.m*(Dose.^Mod.n)+Mod.c,'--r')
hold off;

m = sprintf('%0.1f',Mod.m);
n = sprintf('%0.2f',Mod.n);
c = sprintf('%0.1f',Mod.c);
text(0.3,200,['\sigma_{i} = ' num2str(m) ' \times{\it D} ^{' num2str(n) '} + ' num2str(c)])

WritePlot(OutDir, ['SNRDose' num2str(DoseMin)], [], 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot CNR vs dose:

Line = {'-r' '--g' '-.b' ':k'};
for j=1:4; plot(Dose,CNRStat(:,j),char(Line(j))); hold on; end;
hold off;

legend('2 mm','1.6 mm','1.2 mm','0.8 mm','Location','NorthWest');
xlim([0 2]);
ylim([0 20]);
%line([0 2],[1 1],'LineStyle','-','Color','k')
xlabel(gca,'{\it D} (MU)');
ylabel(gca,'{\it CNR}');
WritePlot(OutDir, ['CNRDose' num2str(DoseMin)], [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot Noise vs dose:

NoiseNorm = Noise./(1:20);
plot(Dose,NoiseNorm,'^');
xlim([0 2.5]);
ylim([15 75]);
xlabel(gca,'{\it d} (MU)');
ylabel(gca,'\sigma_{I}');

FO = fitoptions('Method','NonlinearLeastSquares','Lower',[0,-5,0],'Upper',[20,0,50],'Startpoint',[10,-2,25]);
f = fittype('m*(Dose.^n)+c','coefficients',{'m' 'n' 'c'},'independent','Dose','options',FO);
[Mod,gof2] = fit(reshape(Dose,[],1),reshape(NoiseNorm,[],1),f);

hold on;
plot(Dose,Mod.m*(Dose.^Mod.n)+Mod.c,'--r')
hold off;

m = sprintf('%0.1f',Mod.m);
n = sprintf('%0.2f',Mod.n);
c = sprintf('%0.1f',Mod.c);
text(1.5,63,['\sigma_{i} = ' num2str(m) ' \times{\it d} ^{' num2str(n) '} + ' num2str(c)])

WritePlot(OutDir, ['NoiseDose' num2str(DoseMin)], [], 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot mean error vs dose:

IntTime = 1000/FrameRate:1000/FrameRate:size(MR,1)*1000/FrameRate;
Line = {'-r' '--g' '-.b' ':k'};
for j=1:4; plot(IntTime,MR(:,j),char(Line(j))); hold on; end;
hold off;

line([50 50],[0 2],'LineStyle','-','Color','k')
line([400 400],[0 2],'LineStyle','-','Color','k')
text(65,1.5,'APS');
text(415,1.5,'a-Si EPID');

legend('2 mm','1.6 mm','1.2 mm','0.8 mm','Location','West');
xlim([0 950]);
ylim([0 1.6])
xlabel(gca,'{\it t}_{i} (ms)');
ylabel(gca,'\sigma_{s} (mm)');
WritePlot(OutDir, ['METime' num2str(DoseMin)], [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot success vs integration time:

Line = {'-r' '--g' '-.b' ':k'};
for j=1:4; plot(IntTime,Success(:,j)*100,char(Line(j))); hold on; end;
hold off;

line([50 50],[0 105],'LineStyle','-','Color','k')
line([400 400],[0 105],'LineStyle','-','Color','k')
text(65,8,'APS');
text(415,8,'a-Si EPID');

legend('2 mm','1.6 mm','1.2 mm','0.8 mm','Location','West');
xlim([0 950]);
ylim([0 105]);
xlabel(gca,'{\it t}_{i} (ms)');
ylabel(gca,'{\it Success} (%)');
WritePlot(OutDir, ['SuccessTime' num2str(DoseMin)], [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot Con vs distance:
    
Line = {'rs' 'g^' 'bo' 'kx'};
    
for j = 1:4
    [XBin(j,:), YBin(j,:), YBinErr(j,:), NBin(j,:)] = BinData(dAll, ConAll(:,j), 0, 3.5, 7);
    errorbar(XBin(j,:),YBin(j,:),YBinErr(j,:),char(Line(j)));
    hold on;
end

for j = 1:4
    
    FO = fitoptions('Method','NonlinearLeastSquares',...
        'Lower',[-10,0],...
        'Upper',[-0,20],...
        'Startpoint',[0,0],...
        'Weights',1./YBinErr(j,:));
    
f = fittype('(m*XBin)+c','coefficients',{'m' 'c'},'independent','XBin','options',FO);
[Mod,gof2] = fit(reshape(XBin(j,:),[],1),reshape(YBin(j,:),[],1),f);
Mod

plot(XBin(j,:),(Mod.m*XBin(j,:))+Mod.c,'--k');
end
 
hold off;
legend('2 mm','1.6 mm','1.2 mm','0.8 mm');
xlim([0 3.5]);
ylim([0 12]);
xlabel(gca,'\Delta_{s} (mm)');
ylabel(gca,'{\it C} (%)');
WritePlot(OutDir, ['ConDist' num2str(DoseMin)], [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot CNR vs distance:

CNRAll = ConAll*SNR(1)/100;
    
Line = {'-rs' '--g^' '-.bo' ':kx'};
    
for j = 1:4
    [XBin, YBin, YBinErr, NBin] = BinData(dAll, CNRAll(:,j), 0, 3.5, 7);
    errorbar(XBin,YBin,YBinErr,char(Line(j)));
    hold on;
end
    
hold off;
legend('2 mm','1.6 mm','1.2 mm','0.8 mm');
xlim([0 3.5]);
ylim([0 7]);
%line([0 3.5],[1 1],'LineStyle','-','Color','k');
xlabel(gca,'\Delta_{s} (mm)');
ylabel(gca,'{\it CNR}');
WritePlot(OutDir, ['CNRDist' num2str(DoseMin)], [], 'n');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%end

% Notes: Have to run remove bars in correct mode (not exclude) and then remove outliers
% from corrected image to avoid strongly deviating columns which increase
% noise. Alternatively increase exclude region.

% Using exclude mode does not improve detectibility of smallest stationary
% marker.

% Small marker is stationary in same place, at edge of detector.  Detectibility result of signal
% dipping towards centre of detector?  Change in shape of beam or spatial response
% between open field and data acquisition? Can correct in this data but not
% in patient data.

% Removing pixels outside 1.5*IQR includes pixels within signal from largest
% marker.  Need to use 3 IQR

% Unbinned: 4626 +- 85 to Binned: 4626 +- 43,

% Main = 84 to 52

% No significant correlation is seen in the relationship between error and
% speed.

% Adjust signal to noise to account for scintillator and pixel size.

% Fit SNR.
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Plot CNR:Time graph:
    
    %Colour = {'-r' '--g' '-.b' ':k'};
    %for j=1:4; plot(t,CNR(:,j),['x' char(Colour(j))]); hold on; end;
    %hold off;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % CORRELATE
    
    %[XBin, YBin] = BinData(s, LRes(:,2), 0, 14, 5, 'y');
    
    %xlabel(gca,'Speed (s)');
    %ylabel(gca,'CNR');
    %WritePlot(OutDir, ['CNRSpeed' num2str(DoseMin)], 'n', 'y');