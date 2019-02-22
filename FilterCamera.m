% INTRODUCTION

% Script to process image data of Atlantis phantom.

function [] = FilterCamera(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Location = 'Work';
VarFile = '/Users/josmond/Library/Matlab/Variables/XVI/FilterCamera.txt'
%VarFile = '/Users/John/Library/Matlab/Variables/XVI/FilterCamera.txt'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clearvars -except VarFile Location
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

if ( strcmpi(Location,'Work') == 1 )
    InDir = ['/Users/josmond/Data/' Ins '/' Name];
    OutDir = ['/Users/josmond/Results/' Ins '/' Name];
elseif ( strcmpi(Location,'Home') == 1 )
    InDir = ['/Volumes/Seagate/Data/' Ins '/' Name];
    OutDir = ['/Volumes/Seagate/Results/' Ins '/' Name];
end

GoldThick = [40 25 15];
FilterMat = {'W' 'Pb' 'Cu' 'SW'};
CrossCo = [110 122 100 110];

AuCo = [70 162 70 160; 61 155 71 163; 68 160 68 158];
NoAuCo = [66 166 65 166; 59 158 68 165; 65 163 65 162];
WCo = [56 184 58 183; 51 176 56 180; 54 180 50 178];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUT DATA

for i = 1:1
    
    for j= 1:3
        
        display(' ');
        display(['Using ' num2str(GoldThick(j)) ' micons of Au...'])
        
        SubCo = AuCo(j,:);
        NoSubCo = NoAuCo(j,:);
        AmCo = WCo(j,:);
        
        % Open and combine unfiltered data:
        
        UnFiltDir = sprintf('%02u',(j*5)-4);
        [UnFilt] = ReadData([InDir '/' UnFiltDir], [], Ins, [], ROICo);
        UnFilt(CrossCo(3):CrossCo(4),:,:) = NaN;
        UnFilt(:,CrossCo(1):CrossCo(2),:) = NaN;
        %UnFilt = AddFrames(UnFilt, i);
        UnFiltImg = nanmean(UnFilt,3);
        
        for k = [1 3 4]
            
            display(' ');
            display(['Using ' char(FilterMat(k)) ' filter...']);
            
            % Open and combine filtered data:
            
            FiltDir = sprintf('%02u',(j*5)-4+k);
            [Filt] = ReadData([InDir '/' FiltDir], [], Ins, [], ROICo);
            Filt(CrossCo(3):CrossCo(4),:,:) = NaN;
            Filt(:,CrossCo(1):CrossCo(2),:) = NaN;
            %Filt = AddFrames(Filt, i);
            FiltImg = nanmean(Filt,3);
            
            Diff = UnFilt - Filt;
            DiffImg = nanmean(Filt,3);
            
            % Display image:
            
            imagesc(DiffImg);
            colormap('gray');
            axis image;
            set(gca,'xTick',-1,'yTick',-1);
            
            % Draw boxes:
            
            rectangle('Position', ...
                [SubCo(1),SubCo(3),SubCo(2)-SubCo(1),SubCo(4)-SubCo(3)], ...
                'EdgeColor','r');
            rectangle('Position', ...
                [NoSubCo(1),NoSubCo(3),NoSubCo(2)-NoSubCo(1),NoSubCo(4)-NoSubCo(3)], ...
                'EdgeColor','r');
            rectangle('Position', ...
                [AmCo(1),AmCo(3),AmCo(2)-AmCo(1),AmCo(4)-AmCo(3)], ...
                'EdgeColor','r');
            
            % Calculate contrast:noise ratio for unfiltered:
            
            display(' ');
            display('Analysing unfiltered data...');
            
            UnFiltSubData = UnFilt(SubCo(3):SubCo(4),SubCo(1):SubCo(2),:);
            UnFiltAmData = UnFilt;
            UnFiltAmData(NoSubCo(3):NoSubCo(4),NoSubCo(1):NoSubCo(2)) = NaN;
            UnFiltAmData = UnFiltAmData(AmCo(3):AmCo(4),AmCo(1):AmCo(2));
            
            UnFiltSubMean = nanmean(reshape(UnFiltSubData,1,[]));
            UnFiltSubSTD = nanstd(reshape(UnFiltSubData,1,[]));
            UnFiltAmMean = nanmean(reshape(UnFiltAmData,1,[]));
            UnFiltAmSTD = nanstd(reshape(UnFiltAmData,1,[]));
            
            clear UnFiltSubData UnFiltAmData
            
            display(['Sub Mean: ' num2str(round(UnFiltSubMean)) ...
                ', Sub STD: ' num2str(round(UnFiltSubSTD)) ...
                ', Am Mean: '  num2str(round(UnFiltAmMean)) ...
                ', Am STD: ' num2str(round(UnFiltAmSTD))]);
            
            ConUnFilt = abs(UnFiltSubMean - UnFiltAmMean);
            ConSUnFilt = 100*ConUnFilt/UnFiltAmMean;
            NoiseUnFilt = nanmean([UnFiltSubSTD UnFiltAmSTD]);
            CNRUnFilt = ConUnFilt/NoiseUnFilt;
            
            display(['Contrast: ' num2str(round(ConUnFilt)) ...
                ', ConScale: ' num2str(round(ConSUnFilt)) ...
                '%, Noise: '  num2str(round(NoiseUnFilt)) ...
                ', CNR: ' num2str(round(CNRUnFilt))]);
            
            % Calculate contrast:noise ratio for filtered:
            
            display(' ');
            display('Analysing filtered data...');
            
            FiltSubData = Filt(SubCo(3):SubCo(4),SubCo(1):SubCo(2),:);
            FiltAmData = Filt;
            FiltAmData(NoSubCo(3):NoSubCo(4),NoSubCo(1):NoSubCo(2)) = NaN;
            FiltAmData = FiltAmData(AmCo(3):AmCo(4),AmCo(1):AmCo(2));
            
            FiltSubMean = nanmean(reshape(FiltSubData,1,[]));
            FiltSubSTD = nanstd(reshape(FiltSubData,1,[]));
            FiltAmMean = nanmean(reshape(FiltAmData,1,[]));
            FiltAmSTD = nanstd(reshape(FiltAmData,1,[]));
            
            clear FiltSubData FiltAmData
            
            display(['Sub Mean: ' num2str(round(FiltSubMean)) ...
                ', Sub STD: ' num2str(round(FiltSubSTD)) ...
                ', Am Mean: '  num2str(round(FiltAmMean)) ...
                ', Am STD: ' num2str(round(FiltAmSTD))]);
            
            ConFilt = abs(FiltSubMean - FiltAmMean);
            ConSFilt = 100*ConFilt/FiltAmMean;
            NoiseFilt = nanmean([FiltSubSTD FiltAmSTD]);
            CNRFilt = ConFilt/NoiseFilt;
            
            display(['Contrast: ' num2str(round(ConFilt)) ...
                ', ConScale: ' num2str(round(ConSFilt)) ...
                '%, Noise: '  num2str(round(NoiseFilt)) ...
                ', CNR: ' num2str(round(CNRFilt))]);
            
            % Calculate contrast:noise ratio for difference:
            
            display(' ');
            display('Analysing difference data...');
            
            DiffSubData = Diff(SubCo(3):SubCo(4),SubCo(1):SubCo(2),:);
            DiffAmData = Diff;
            DiffAmData(NoSubCo(3):NoSubCo(4),NoSubCo(1):NoSubCo(2)) = NaN;
            DiffAmData = DiffAmData(AmCo(3):AmCo(4),AmCo(1):AmCo(2));
            
            DiffSubMean = nanmean(reshape(DiffSubData,1,[]));
            DiffSubSTD = nanstd(reshape(DiffSubData,1,[]));
            DiffAmMean = nanmean(reshape(DiffAmData,1,[]));
            DiffAmSTD = nanstd(reshape(DiffAmData,1,[]));
            
            clear DiffSubData DiffAmData
            
            display(['Sub Mean: ' num2str(round(DiffSubMean)) ...
                ', Sub STD: ' num2str(round(DiffSubSTD)) ...
                ', Am Mean: '  num2str(round(DiffAmMean)) ...
                ', Am STD: ' num2str(round(DiffAmSTD))]);
            
            ConDiff = abs(DiffSubMean - DiffAmMean);
            ConSDiff = 100*ConDiff/DiffAmMean;
            NoiseDiff = nanmean([DiffSubSTD DiffAmSTD]);
            CNRDiff = ConDiff/NoiseDiff;
            
            display(['Contrast: ' num2str(round(ConDiff)) ...
                ', ConScale: ' num2str(round(ConSDiff)) ...
                '%, Noise: '  num2str(round(NoiseDiff)) ...
                ', CNR: ' num2str(round(CNRDiff))]);
            
        end
        
    end
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


