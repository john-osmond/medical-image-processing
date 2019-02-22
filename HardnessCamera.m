% INTRODUCTION

% Script to process image data of Atlantis phantom.

function [] = FilterCamera(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VarFile = '/Users/josmond/Library/Matlab/Variables/XVI/GNP.txt'
SubName = {'BG' 'GNP1' 'GNP2'};

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SET CONSTANTS

% Calculate qualitative constants:

InDir = ['/Users/josmond/Data/' Ins '/' Name '/' Exp];
OutDir = ['/Users/josmond/Results/' Ins '/' Name '/' Exp];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open flood data:

%FloodDir = ['/Users/josmond/Data/' Ins '/' Name '/Flood/01'];
%[Flood] = ReadData(FloodDir, [], Ins, Frames, CuCo);
%FloodImg = mean(Flood,3)./mean(reshape(Flood,1,[]));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop round all directories:

for i = 1:4
    
    display(' ');
    display([char(CuThick(i)) ' mm of Cu:']);
    
    % Read Data:
    
    for DataName = {'Phan' 'PhanCu' 'Cu'}
        Dir = [InDir '/' char(CuThick(i)) '/' char(DataName)];
        [Data] = ReadData(Dir, [], Ins, Frames, CuCo);
        %eval([char(DataName) 'Img = Data(:,:,40);']);
        eval([char(DataName) 'Img = sum(Data(:,:,40:49),3);']);
        %eval([char(DataName) 'Img = medfilt2(Data(:,:,40));'])
        eval(['clear ' char(DataName) ';']);
    end
    
    %NormImg = PhanImg./FloodImg;
    %HardImg = NormImg - (PhanCuImg./(CuImg./mean2(CuImg)));
    
    NormImg = PhanImg;
    HardImg = NormImg - PhanCuImg;
    
    % Loop round all objects:
    
    for j = {'NormImg' 'HardImg'}
        
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
        
        for k = 1:size(SubName,2)
            
            eval(['Co = ' char(SubName(k)) 'Co;']);
            Co(1:2) = Co(1:2) - CuCo(1);
            Co(3:4) = Co(3:4) - CuCo(3);
            
            % Mark object on image:
            
            rectangle('Position',[Co(1),Co(3),Co(2)-Co(1),Co(4)-Co(3)],'EdgeColor','r');
            
            SubData = Img(Co(3):Co(4),Co(1):Co(2));
            SubMean = mean2(SubData);
            SubSTD = std2(SubData);
            
            SNR = SubMean/SubSTD;
            Con = abs(100*(BGMean-SubMean)/BGMean);
            CNR = abs((BGMean-SubMean)/SubSTD);
            
            s = sprintf('%-4s  Mean: %4.0f  STD: %4.1f  SNR: %5.1f  Con: %4.1f  CNR: %4.1f',...
                char(SubName(k)),SubMean,SubSTD,SNR,Con,CNR);
            if (strcmpi(char(SubName(k)),'Mark') ~= 1); disp(s); end
            
            if (strcmpi(char(j),'NormImg') == 1)
                ConNorm(i,k) = Con;
                CNRNorm(i,k) = CNR;
            else
                ConHard(i,k) = Con;
                CNRHard(i,k) = CNR;
            end
        
        end
        
        if (i == 1 && strcmpi(char(j),'NormImg') == 1)
            WritePlot(OutDir, ['Img0.00mmCu'], [], 'n');
        end
        
        if (strcmpi(char(j),'HardImg') == 1)
            WritePlot(OutDir, ['Img' char(CuThick(i)) 'mmCu'], [], 'n');
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
ylim([20 45])
xlabel(gca,'Cu Thickness (mm)');
ylabel(gca,'Contrast (%)');
WritePlot(OutDir, 'ConThick', [], 'n');

plot(str2num(char(CuThick)),CNRHard(:,2),'-bd')
hold on
plot(str2num(char(CuThick)),CNRHard(:,4),'--rd')
hold off
line([0 1.1],[mean(CNRNorm(:,2)) mean(CNRNorm(:,2))],'LineStyle','-','Color','k');
line([0 1.1],[mean(CNRNorm(:,4)) mean(CNRNorm(:,4))],'LineStyle','--','Color','k');

legend('15 \mum Au','25 \mum Au');
xlim([0.21 1.04])
ylim([20 60])
xlabel(gca,'Cu Thickness (mm)');
ylabel(gca,'{\it CNR}');
WritePlot(OutDir, 'CNRThick', [], 'n');
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


