% INTRODUCTION

% Script to process image data of Atlantis phantom.

%function [] = FilterCamera(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VarFile = '/Users/josmond/Library/Matlab/Variables/XVI/FoilWater.txt'
SubName = {'BG' 'Au15' 'Mark' 'Au25'};

CuThick = {'0.25' '0.50' '0.75' '1.00'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clearvars -except VarFile SubName CuThick
close all hidden
clc
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

% FoilWater = 32000 +/- 179, 25000 +/- 260, 21000 +/- 205
% Foil = 22000 +/- 134, 18000 +/- 160, 16000 +/- 151
% GNP = 18000 +/- 138, 15000 +/- 138 in BG

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SET CONSTANTS

% Calculate qualitative constants:

InDir = ['/Users/josmond/Data/' Ins '/' Name '/' Exp];
OutDir = ['/Users/josmond/Results/' Ins '/' Name '/' Exp];

% Framenum = 2 4 6 8 10 12 14 16 18 20

FrameNum = 10;
Dose = 0.25*FrameNum;
display(' ');
display(['Dose: ' num2str(Dose)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open flood data:

%FloodDir = ['/Users/josmond/Data/' Ins '/' Name '/Flood/01'];
%[Flood] = ReadData(FloodDir, [], Ins, Frames, CuCo);
%FloodImg = mean(Flood,3)./mean(reshape(Flood,1,[]));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop round all Cu thickness:

for i = 1:4
    
    display(' ');
    display([char(CuThick(i)) ' mm of Cu:']);
    
    % Read Data:
    
    for DataName = {'Phan' 'PhanCu' 'Cu'}
        Dir = [InDir '/' char(CuThick(i)) '/' char(DataName)];
        [Data] = ReadData(Dir, [], Ins, Frames, CuCo);
        %eval([char(DataName) 'Img = Data(:,:,40);']);
        eval([char(DataName) 'Img = sum(Data(:,:,40:40+FrameNum-1),3);']);
        %eval([char(DataName) 'Img = medfilt2(Data(:,:,40));'])
        eval(['clear ' char(DataName) ';']);
    end
    
    % Create images:
    
    NormImg = PhanImg;
    SoftImg = NormImg - PhanCuImg;
    
    %imtool(NormImg)
    %pause
    
    % Report Hard Image (Temp!!):
    
    display(' ');
    display('HardImg:');
    display(' ');
    Co(1:2) = Au15Co(1:2) - CuCo(1) + 1;
    Co(3:4) = Au15Co(3:4) - CuCo(3) + 1;
    RegData = PhanCuImg(Co(3):Co(4),Co(1):Co(2));
    RegMean = mean2(RegData);
    RegSTD = std2(RegData);
    Co(1:2) = BGCo(1:2) - CuCo(1) + 1;
    Co(3:4) = BGCo(3:4) - CuCo(3) + 1;
    BGData = PhanCuImg(Co(3):Co(4),Co(1):Co(2));
    BGMean = mean2(BGData);
    BGSTD = std2(BGData);
    s = sprintf('HardImg Mean: %5.0f  STD: %4.1f BGMean: %5.0f  BGSTD: %4.1f',...
        RegMean,RegSTD,BGMean,BGSTD);
    
    Hard(i) = RegMean;
    HardNoise(i) = RegSTD;
    
    disp(s)
        
    % Loop round norm then soft image:
    
    for j = {'NormImg' 'SoftImg'}
        
        display(' ');
        display([char(j) ':']);
        display(' ');
        
        eval(['Img = ' char(j) ';'])
        
        % Draw Data
        
        imagesc(Img, quantile(reshape(Img,1,[]),[0.01 0.995]));
        axis image;
        set(gca,'xtick',[],'ytick',[]);
        colormap('gray');
        
        % Calculate BG Info:
        
        Co(1:2) = BGCo(1:2) - CuCo(1) + 1;
        Co(3:4) = BGCo(3:4) - CuCo(3) + 1;
        BGData = Img(Co(3):Co(4),Co(1):Co(2));
        BGMean = mean2(BGData);
        BGSTD = std2(BGData);
        
        % Loop around all subregiouns:
        
        for k = 1:size(SubName,2)
            
            % Write co-ordinates of subregion to Co variable:
            
            eval(['Co = ' char(SubName(k)) 'Co;']);
            Co(1:2) = Co(1:2) - CuCo(1);
            Co(3:4) = Co(3:4) - CuCo(3);
            
            % Mark each subregion on image with different colour:
            
            Col = 'k';
            if (strcmpi(char(SubName(k)),'Au15') == 1)
                Col = 'w';
                text(mean(Co(1:2))-15,mean(Co(3:4)),'15 \mum','Color',Col)
            elseif (strcmpi(char(SubName(k)),'Au25') == 1)
                Col = 'w';
                text(mean(Co(1:2))-15,mean(Co(3:4)),'25 \mum','Color',Col)
            elseif (strcmpi(char(SubName(k)),'BG') == 1)
                Col = 'k';
                text(mean(Co(1:2))-9,mean(Co(3:4)),'BG','Color',Col)
            end
            
            if (strcmpi(char(SubName(k)),'Mark') ~= 1)
                rectangle('Position',[Co(1),Co(3),Co(2)-Co(1),Co(4)-Co(3)],'EdgeColor',Col);
            end
            
            % Calculate mean and std of subregion:
            
            SubData = Img(Co(3):Co(4),Co(1):Co(2));
            
            %imtool(SubData);
            %pause
            
            SubMean = mean2(SubData);
            SubSTD = std2(SubData);
            
            % Calculate SNR and CNR of subregion:
            
            SNR = SubMean/SubSTD;
            Con = abs(100*(BGMean-SubMean)/BGMean);
            CNR = abs((BGMean-SubMean)/SubSTD);
            
            % If region not markers print results to screen:
            
            if (strcmpi(char(SubName(k)),'Mark') ~= 1);
                s = sprintf('%-4s  Mean: %5.0f  STD: %4.1f  SNR: %5.1f  Con: %4.1f  CNR: %4.1f',...
                char(SubName(k)),SubMean,SubSTD,SNR,Con,CNR);
            disp(s)
            else
                Prof = mean(SubData,1);
                
                MarkXAll = [441 454 469 484];
                for l = 1:4
                    MarkX = MarkXAll(l) - MarkCo(1) + 1;
                    MarkMin = min(Prof(MarkX-7:MarkX+7));
                    MarkMax = max(Prof(MarkX-7:MarkX+7));
                    MarkCon(l) = 100*(MarkMax-MarkMin)/MarkMax;
                    MarkCNR(l) = (MarkMax-MarkMin)./BGSTD;
                end
                s = sprintf('%-4s  Con:  %5.0f  CNR: %4.1f  Con: %5.1f  CNR: %4.1f Con: %5.1f CNR: %4.1f Con: %5.1f CNR: %4.1f',...
                char(SubName(k)),MarkCon(1),MarkCNR(1),MarkCon(2),MarkCNR(2),MarkCon(3),MarkCNR(3),MarkCon(4),MarkCNR(4));
            end
            
            % If image normal image write to normal array:
            
            if (strcmpi(char(j),'NormImg') == 1)
                ConNorm(i,k) = Con;
                CNRNorm(i,k) = CNR;
                if (strcmpi(char(SubName(k)),'Mark') == 1);
                    MarkConNorm(i,:) = MarkCon;
                    MarkCNRNorm(i,:) = MarkCNR;
                end
            else
                ConHard(i,k) = Con;
                CNRHard(i,k) = CNR;
                if (strcmpi(char(SubName(k)),'Mark') == 1);
                    MarkConHard(i,:) = MarkCon;
                    MarkCNRHard(i,:) = MarkCNR;
                end
            end
            
            % Noise study
            
            if (strcmpi(char(SubName(k)),'Au15') == 1);
                if (strcmpi(char(j),'NormImg') == 1)
                    Broad(i) = SubMean;
                    BroadNoise(i) = SubSTD;
                else
                    Soft(i) = SubMean;
                    SoftNoise(i) = SubSTD;
                end
            end
        
        end
        
        if (i == 1 && strcmpi(char(j),'NormImg') == 1)
            WritePlot(OutDir, ['Img0.00mmCu'], [16 18], 'n');
        end
        
        if (strcmpi(char(j),'SoftImg') == 1)
            WritePlot(OutDir, ['Img' char(CuThick(i)) 'mmCu'], [16 18], 'n');
        end
        
    end
    
end

% Plot results:

plot(str2num(char(CuThick)),ConHard(:,2),'-bd')
hold on
plot(str2num(char(CuThick)),ConHard(:,4),'--rd')
hold off
line([0 1.1],[mean(ConNorm(:,2)) mean(ConNorm(:,2))],'LineStyle','-','Color','k');
line([0 1.1],[mean(ConNorm(:,4)) mean(ConNorm(:,4))],'LineStyle','--','Color','k');

legend('15 \mum Au','25 \mum Au');
xlim([0.21 1.04])
ylim([15 35])
xlabel(gca,'Cu Thickness (mm)');
ylabel(gca,'C (%)');
set(findobj('-property','MarkerSize'),'MarkerSize',8);
WritePlot(OutDir, 'ConThick', [], 'n');

plot(str2num(char(CuThick)),CNRHard(:,2),'-bd')
hold on
plot(str2num(char(CuThick)),CNRHard(:,4),'--rd')
hold off
line([0 1.1],[mean(CNRNorm(:,2)) mean(CNRNorm(:,2))],'LineStyle','-','Color','k');
line([0 1.1],[mean(CNRNorm(:,4)) mean(CNRNorm(:,4))],'LineStyle','--','Color','k');

legend('15 \mum Au','25 \mum Au');
xlim([0.21 1.04])
ylim([15 45])
xlabel(gca,'Cu Thickness (mm)');
ylabel(gca,'{\it CNR}');
set(findobj('-property','MarkerSize'),'MarkerSize',8);
WritePlot(OutDir, 'CNRThick', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LineAll = {'-' '--' '-.' ':'};
ColAll = {'r' 'g' 'b' 'k'};
for i = 1:4
   plot(str2num(char(CuThick)),MarkConHard(:,i),[char(LineAll(i)) 'd' char(ColAll(i))]);
   hold on;
end
hold off;
for i = 1:4
   line([0 1.1],[mean(MarkConNorm(:,i)) mean(MarkConNorm(:,i))],'LineStyle',char(LineAll(i)),'Color',char(ColAll(i)));
end

legend('2 mm','1.6 mm','1.2 mm','0.8 mm','Location','SouthEast');
xlim([0.21 1.04])
ylim([52 71])
xlabel(gca,'Cu Thickness (mm)');
ylabel(gca,'C (%)');
set(findobj('-property','MarkerSize'),'MarkerSize',8);
WritePlot(OutDir, 'MarkConThick', [], 'n');

for i = 1:4
   plot(str2num(char(CuThick)),MarkCNRHard(:,i),[char(LineAll(i)) 'd' char(ColAll(i))]);
   hold on;
end
hold off;
for i = 1:4
   line([0 1.1],[mean(MarkCNRNorm(:,i)) mean(MarkCNRNorm(:,i))],'LineStyle',char(LineAll(i)),'Color',char(ColAll(i)));
end

legend('2 mm','1.6 mm','1.2 mm','0.8 mm','Location','SouthEast');
xlim([0.21 1.04])
ylim([30 120])
xlabel(gca,'Cu Thickness (mm)');
ylabel(gca,'{\it CNR}');
set(findobj('-property','MarkerSize'),'MarkerSize',8);
WritePlot(OutDir, 'MarkCNRThick', [], 'n');

%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 0.5 mm:

CNRNorm(2,2);
CNRHard(2,2); % (0.5 mm, Au15)

Dose = [0.5 1 1.5 2 2.5 3 3.5 4 4.5 5];
CNRNormDose = [16.1 20.0 22.6 24.2 25.3 26.1 26.7 27.4 28.0 28.4];
CNRSoftDose = [12.0 16.3 19.5 21.7 23.9 25.5 27.3 28.7 30.1 31.3];

plot(Dose,CNRNormDose,'r',Dose,CNRSoftDose,'--b');
legend('Standard','Soft','Location','NorthWest');
line([2.5 2.5],[12 32],'LineStyle','-','Color','k');
xlim([0.5 5])
ylim([12 32])
xlabel(gca,'Dose (mAs)');
ylabel(gca,'{\it CNR}');
set(findobj('-property','MarkerSize'),'MarkerSize',8);
WritePlot(OutDir, 'CNRDose0.5', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CNRNorm(4,2)
CNRHard(4,2) % (1 mm, Au15)

Dose = [0.5 1 1.5 2 2.5 3 3.5 4 4.5 5];
CNRNormDose = [15.7 19.9 22.5 24.4 25.4 26.1 27.0 27.5 28.0 28.2];
CNRSoftDose = [15.1 20.2 24.0 27.0 29.1 31.0 32.6 33.7 35.0 36.0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(Dose,CNRNormDose.^2,'r',Dose,CNRSoftDose.^2,'--b');
legend('Standard','Soft','Location','NorthWest');
line([2.5 2.5],[0 1400],'LineStyle',':','Color','k');
xlim([0.5 5])
%ylim([14 38])
ylim([0 1400])
xlabel(gca,'Dose (mAs)');
ylabel(gca,'{\it CNR}^{2}');
set(findobj('-property','MarkerSize'),'MarkerSize',8);
WritePlot(OutDir, 'CNRDose1', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BroadPoiss = sqrt(Broad);
BroadDiff = sqrt((BroadNoise.^2)-(BroadPoiss.^2));

% Hard:

HardPoiss = sqrt(Hard);
%HardPoiss = BroadPoiss;
HardDiff = sqrt((HardNoise.^2)-(HardPoiss.^2));

plot([0; str2num(char(CuThick))],[mean(BroadNoise) HardNoise],'r');
hold on;
plot([0; str2num(char(CuThick))],[mean(BroadPoiss) HardPoiss],'--g');
plot([0; str2num(char(CuThick))],[mean(BroadDiff) HardDiff],'-.b');
hold off;
legend('Measured','Poisson','Difference')
xlim([-0.04 1.04])
xlabel(gca,'Cu Thickness (mm)');
ylabel(gca,'\sigma');
WritePlot(OutDir, 'HardNoise', [], 'n');

% Soft:

%SoftPoiss = sqrt(Soft);
SoftPoiss = sqrt((HardPoiss.^2)+(BroadPoiss.^2))
%SoftPoiss = sqrt((HardNoise.^2)+(BroadNoise.^2))
SoftDiff = sqrt((SoftNoise.^2)-(SoftPoiss.^2));

plot(str2num(char(CuThick)),SoftNoise,'r');
hold on;
plot(str2num(char(CuThick)),SoftPoiss,'--g');
plot(str2num(char(CuThick)),SoftDiff,'-.b');
hold off;
legend('Measured','Poisson','Difference','Location','SouthEast')
xlim([-0.04 1.04])
xlabel(gca,'Cu Thickness (mm)');
ylabel(gca,'\sigma');
WritePlot(OutDir, 'SoftNoise', [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ExCuThick = [0 0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5];
ExHardSNR = [130.1262 93.3415 66.2193 46.0003 31.7069 22.2804 15.6568 11.0018 7.7310 5.4325 3.8175]

%SNR = 5
%Cross = 0.2 and 2.3 mm

% Hard Sig/Noise (0.7027):

%plot([0; str2num(char(CuThick))],[mean(Broad)/mean(BroadNoise) Hard./HardNoise],'r');
plot(ExCuThick, ExHardSNR,'r');
xlim([0 2.5])
xlabel(gca,'Cu Thickness (mm)');
ylabel(gca,'Signal Noise^{-1}');
%WritePlot(OutDir, 'HardSNR', [], 'n');

hold on
plot(ExCuThick(1:5),[0 Soft./SoftNoise],'--b');
hold off
%WritePlot(OutDir, 'SoftSNR', [], 'n');
line([0 2.5],[5 5],'LineStyle',':','Color','k');
legend('Hard-Band','Soft-Band','Location','NorthEast');
WritePlot(OutDir, 'SNR', [], 'n');

plot(str2num(char(CuThick)),ConHard(:,2),'-bd')
hold on
plot(str2num(char(CuThick)),ConHard(:,4),'--rd')
hold off
line([0 1.1],[mean(ConNorm(:,2)) mean(ConNorm(:,2))],'LineStyle','-','Color','k');
line([0 1.1],[mean(ConNorm(:,4)) mean(ConNorm(:,4))],'LineStyle','--','Color','k');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ConSoftGNP1 = [22.0841 20.8032 20.3729 20.0605];
ConNormGNP1 = 18.8460;
ConSoftGNP2 = [22.6121 21.8148 21.1971 20.5756];
ConNormGNP2 = 19.6613;

plot(str2num(char(CuThick)),ConSoftGNP1,'-kd')
hold on
plot(str2num(char(CuThick)),ConSoftGNP2,'--rd')
plot(str2num(char(CuThick)),ConHard(:,2),'-.bd')
plot(str2num(char(CuThick)),ConHard(:,4),':md')
hold off

line([0 1.1],[ConNormGNP1 ConNormGNP1],'LineStyle','-','Color','k');
line([0 1.1],[ConNormGNP2 ConNormGNP2],'LineStyle','--','Color','r');
line([0 1.1],[mean(ConNorm(:,2)) mean(ConNorm(:,2))],'LineStyle','-.','Color','b');
line([0 1.1],[mean(ConNorm(:,4)) mean(ConNorm(:,4))],'LineStyle',':','Color','m');

legend('GNP1','GNP2','15 \mum Au','25 \mum Au','Location','East');
xlim([0.21 1.04])
ylim([17 33])
xlabel(gca,'Cu Thickness (mm)');
ylabel(gca,'C (%)');
set(findobj('-property','MarkerSize'),'MarkerSize',8);
WritePlot(OutDir, 'ConThickAll', [], 'n');
