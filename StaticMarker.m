% INTRODUCTION

% Script to process image data of Atlantis phantom.

function [Dose, SNR, CNR] = StaticMarker(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%VarFile = '/Users/josmond/Library/Matlab/Variables/Shark/StaticMarker19.txt'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clearvars -except VarFile
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

[Dark] = ReadData(InDir, DarkName, Ins, DarkFrames, ROICo);
DarkImg = nanmean(Dark,3);
clear Dark;

% Read flood data:

FloodImg = 'n';

% Read data:

[Data] = ReadData(InDir, DataName, Ins, Frames, ROICo);

% Correct data:

[DataImg, ~] = CorImg(Data, DarkImg, FloodImg);

% Check data:

%for i = 1:20
%    [DataAdd] = AddFrames(Data,i);
%    LookImg(DataAdd(:,:,1:10))
%end

% Plot frame mean and std vs time:

TimeSeries(Data, OutDir, num2str(DoseMin), FrameRate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove bars:

[Data, ~] = RemoveBars(Data);

% Normalise frames:

[Data] = NormFrames(Data);

% Combine frames to increase dose:

for i = 1:20
    
    % Calculate constants:
    
    %FrameAdd = 2^(i-1);
    FrameAdd = i;
    Dose(i) = double((DoseMin/(60*FrameRate))*FrameAdd);
    
    % Add frames and create image and profile:
    
    [DataAdd] = AddFrames(Data,FrameAdd);
    DataImg = nanmean(DataAdd,3);
    DataProf = nanmean(DataImg,2);
    
    % Calculate ambient mean and std:
    
    AmImg = DataAdd(:,1:MarkX(1)-ROICo(1)-5,:);
    AmSig = nanmean(reshape(AmImg,1,[]));
    Noise = nanstd(reshape(AmImg,1,[]));
    
    SNR(i) = AmSig/Noise;
    
    % Calculate signal and contrast :noise:
    
    for j = 1:4
        MarkSig = min(DataProf(MarkY(j)-ROICo(3)-5:MarkY(j)-ROICo(3)+5));
        CNR(i,j) = abs(MarkSig-AmSig)/Noise;
        abs(MarkSig-AmSig);
    end
    
    %plot(DataAm1D(1:1000));
    %pause
    %LookImg(DataAm(:,:,1:10));
    
end

% Plot results:

plot(Dose,SNR,'-b');
legend off;
xlabel(gca,'{\it d} (MU)');
ylabel(gca,'{\it SNR}');
WritePlot(OutDir, ['SNRDose' num2str(DoseMin)], [], 'n');

Style = {'-r' '--g' '-.b' ':k'};
for i = 1:4; plot(Dose,CNR(:,i),char(Style(i))); hold on; end
hold off;

if (DoseMin == 18)
    xlim([0 2])
    ylim([0 2])
end

legend('2 mm','1.6 mm','1.2 mm','0.8 mm','Location','NorthWest');
%line([0 2],[1 1],'LineStyle','-','Color','k')
xlabel(gca,'{\it D} (MU)');
ylabel(gca,'{\it CNR}');
WritePlot(OutDir, ['CNRDose' num2str(DoseMin)], [], 'n');

%randn(1000,1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Demonstrate failure of EPID:

clearvars -except InDir OutDir Dose SNR CNR
close all hidden
%clc
tic

VarFile = '/Users/josmond/Library/Matlab/Variables/Shark/MovingMarker.txt'

[Var] = ReadVar(VarFile);

% Copy structured array elements to individual variables:

for i = 1:size(Var,2)
    if ( strcmp(char(Var(i).Type),'s') == 1 )
        eval([char(Var(i).Name{:}) '= char(Var(i).Value{:});']);
    else
        eval([char(Var(i).Name{:}) '= cell2mat(Var(i).Value);']);
    end
end

InDir = ['/Users/josmond/Data/' Ins '/' Name];
OutDir = ['/Users/josmond/Results/' Ins '/' Name];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SET CONSTANTS

% Calculate quantitative constants:

NoFrames = single(diff(Frames));

[Dark] = ReadData(InDir, DarkName, Ins, DarkFrames, ROICo);
DarkImg = nanmean(Dark,3);
clear Dark;

% Read flood data:

FloodImg = 'n';

% Read data:

[Data] = ReadData(InDir, DataName, Ins, Frames, ROICo);

% Correct data:

[DataImg, ~] = CorImg(Data, DarkImg, FloodImg);

Disp = (1:131)/3;

for i = 1:15
    imagesc(Data(:,:,i),[21000 25000]);
    axis image;
    set(gca,'xtick',[],'ytick',[]);
    colormap('gray');
    WritePlot(OutDir, ['ImgMov' num2str(i)], [20 12], 'n');
    
    Prof = mean(Data(:,MarkX(1)-ROICo(1)+1:MarkX(2)-ROICo(1)+1,i),2);
    ProfAll(i,:) = 100*Prof/max(Prof);
    plot(ProfAll(i,:));
    xlim([1 131]);
    ylim([80 100]);
    xlabel(gca,'{\it y} (mm)');
    ylabel(gca,'{\it I} (%)');
    WritePlot(OutDir, ['Prof' num2str(i)], [], 'n');
end

%plot(Disp,[(1:17)*NaN ProfAll(3,:)],'-b')
plot(Disp,ProfAll(3,:),'--r')
hold on;
plot(Disp,ProfAll(6,:),'-b')
hold off
xlim([1 40])
ylim([84 100])
xlabel(gca,'{\it s} (mm)');
ylabel(gca,'{\it I} (%)');
legend(' {\it v} = 0 mm s^{-1}',' {\it v} = 6.6 mm s^{-1}','Location','East');

WritePlot(OutDir, 'ProfAll', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
