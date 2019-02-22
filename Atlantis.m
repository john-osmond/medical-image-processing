% INTRODUCTION

% Script to process image data of Atlantis phantom.

function [] = Atlantis(VarFile)

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

VarFile = '/Users/josmond/Library/Matlab/Variables/Vanilla/Atlantis.txt'

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

% CONSTANTS

% Calculate qualitative constants:

InDir = ['/Users/josmond/Data/' Ins '/' Name];
OutDir = ['/Users/josmond/Results/' Ins '/' Name];

% Calculate quantitative constants:

NoFrames = single(diff(Frames));

InNo = 4;
InSizemm = 23;
InSepmm = 38;
InMarg = 10;

BoxSizemm = ((3*InSepmm)+InSizemm);
BoxSize = diff(BoxCo);
ImageScale = mean(BoxSize) / BoxSizemm;

InSize = InSizemm * ImageScale;
InSep = InSepmm * ImageScale;
InGap = InSep - InSize;
InArea = round((InSize-(2*InMarg)+1)^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUT DATA

% Read data:

[DataImg, DataSD] = StatData([InDir '/' DataName], Ins, Frames, GroupSize);
[DarkImg, DarkSD] = StatData([InDir '/' DarkName], Ins, Frames, GroupSize);
[OpenImg, OpenSD] = StatData([InDir '/' OpenName], Ins, Frames, GroupSize);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPROCESSING

% Correct data:

[CorImg, FiltImg, MaskImg, CorSD] = CorData(DataImg, DataSD, DarkImg, DarkSD, OpenImg, OpenSD);

% Use cor script on these:

DataImg = DataImg - DarkImg;
OpenImg = OpenImg - DarkImg;

% Rotate images:

NameAll = {'DataImg' 'DataSD' 'OpenImg' 'OpenSD' 'CorImg' 'FiltImg' 'CorSD'};

for i = 1:length(NameAll)
    eval([NameAll{i} 'Rot = imrotate(' NameAll{i} ',Angle,''bilinear'');']);
end

clear NameAll

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CHECK CO-ORDINATES

% Display image:

imagesc(FiltImgRot, iLim);
axis image;
colormap(gray);

% Draw box:

BoxSize = diff(BoxCo);
rectangle('Position',[BoxCo(1,1),BoxCo(1,2),BoxSize(1),BoxSize(2)],'EdgeColor','r');

% Prompt for approval:

disp('Co-ordinates of top-left and bottom-right corners of inserts:');
BoxCo
Orient = {'L to R' 'T to B'; 'L to R' 'T to B'}
disp('Check co-ordinates then press any key to continue...')
pause;
close;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PROCESSING

% Calculate difference image:

DiffImg = OpenImgRot - DataImgRot;

% Calculate co-ordinates of missing insert:

IndZero = find(ThickAll==0);
xZero = ceil(IndZero/4);
yZero = IndZero - ((xZero-1)*4);

xPos = uint16(BoxCo(1,1) + ((xZero-1)*InSep));
yPos = uint16(BoxCo(1,2) + ((yZero-1)*InSep));

SquareCo = [xPos xPos+InSize yPos yPos+InSize];
SquareCo = round(SquareCo);

% Calculate offset between data and open image due to change in temp:

Offset = mean2(DiffImg(SquareCo(3):SquareCo(4),SquareCo(1):SquareCo(2)));

% Correct open image for change in temp:

OpenImgRot = OpenImgRot - Offset;

%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate error images:

DataErr = DataSDRot./sqrt(NoFrames);
OpenErr = OpenSDRot./sqrt(NoFrames);

% Calculate contrast and contrast error images:

Num = (OpenImgRot - DataImgRot);
NumErr = sqrt((OpenErr.^2) + (DataErr.^2));

Den = (OpenImgRot + DataImgRot)/2;
DenErr = NumErr/2;

ConImg = (Num./Den)*100;
ConErrImg = ConImg.*sqrt(((NumErr./Num).^2)+((DenErr./Den).^2))*1.96;

% Calculate noise image:

NoiseImg = sqrt((DataSDRot.^2)+(OpenSDRot.^2));
NoiseErrImg = sqrt(((DataSDRot/sqrt((2*NoFrames)-1)).^2)+((OpenSDRot/sqrt((2*NoFrames)-1)).^2))*1.96;

% Calculate CNR image:

CNRImg = Num./NoiseImg;
CNRErrImg = CNRImg.*sqrt(((ConErrImg./ConImg).^2)+((NoiseErrImg./NoiseImg).^2))*1.96;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Display image:

imagesc(FiltImgRot, iLim);
axis image;
colormap(gray);

% Loop round boxes in x then y:

for x = 1:InNo
    for y = 1:InNo
        
        z = ((x-1)*4)+y;
        
        % Define co-ordinates of top left corner of each box:

        xPos = uint16(BoxCo(1,1) + ((x-1)*InSep));
        yPos = uint16(BoxCo(1,2) + ((y-1)*InSep));
       
        % Draw square on image:
        
        rectangle('Position',[xPos,yPos,InSize,InSize],'EdgeColor','r');
        
        % Define co-ordinates of small square:
        
        SqCo = round([xPos xPos+InSize yPos yPos+InSize]);
        SqSmCo = [SqCo(1)+InMarg SqCo(2)-InMarg SqCo(3)+InMarg SqCo(4)-InMarg];
        
        MeanCo = [mean(SqCo(1:2)) mean(SqCo(3:4))];
        
        % Cut out squares:
        
        NameAll = {'ConImg' 'ConErrImg' 'CNRImg' 'CNRErrImg' 'MaskImg' 'Num'};
        
        for i = 1:length(NameAll)
            eval([NameAll{i} 'Sq = ' NameAll{i} '(SqSmCo(3):SqSmCo(4),SqSmCo(1):SqSmCo(2));']);
            eval([NameAll{i} 'Sq(isnan(' NameAll{i} 'Sq)) = 0;']);
            eval([NameAll{i} 'Sq(isinf(' NameAll{i} 'Sq)) = 0;']);
        end
        
        MaskImgSq(isnan(ConImgSq)) = 0;
        MaskImgSq(isinf(ConImgSq)) = 0;
        Ind = find(MaskImgSq == 1);
        NoPix = length(Ind);

        Con = mean2(ConImgSq(Ind));
        SumCor = ((NoFrames-1)/((NoFrames*NoPix)-1));
        ConErr = sqrt(sum(sum(ConErrImgSq(Ind).^2))*SumCor);
        %ConErr = ConErr/10;
        %CNR = mean2(CNRImgSq(Ind));
        CNR = mean2(NumSq(Ind))/std2(NumSq(Ind));
        CNRErr = sqrt(sum(sum(CNRErrImgSq(Ind).^2))*SumCor);
        
        ValAll(:,z) = [Con; ConErr; CNR; CNRErr; MeanCo(1); MeanCo(2)];
                  
    end
end

% Print image:

xlabel('X');
ylabel('Y');

WritePlot(OutDir, [Name '_Img'], 'n', 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PLOT CONTRAST VS THICKNESS:

% Set plot variables:

xData = ThickAll;
yData = ValAll(1,:);
eData = ValAll(2,:);
xCo = ValAll(5,:);
yCo = ValAll(6,:);

xLabel = ['Bone Thickness (mm)'];
yLabel = ['Contrast (%)'];

% Correct data for water level change if necessary:

if (Cor ~= 0)
    [yDataCor] = CorAtlantis(xData, yData, xCo, yCo);
    FracCor = yDataCor./yData;
else
    yDataCor = yData;
end

% Plot data:

errorbar(xData,yDataCor,eData,'d');

% Plot trend line:

PolyDeg = 1;

if (PolyDeg >= 0)
    
    FitVals = polyfit(xData, yDataCor, 1);
    FitData = polyval(FitVals, xData);
    
    %MinVal = min(min(yDataCor));
    %yDataPlus = yData - MinVal;
    %FitDataPlus = FitData - MinVal;
    %[h,p,st] = chi2gof(xData,'frequency',yDataPlus,'expected',FitDataPlus);
    %disp(['Chi-Squared = ', num2str(st.chi2stat), '; p = ' num2str(p)]);
    
    hold on;
    plot(xData,FitData,'k','LineStyle','-');
    hold off;
    
end

% Add text:

if (exist('Text','var') == 1)
    text(TextCo(1),TextCo(2),Text)
end

% Print data:

set(gca,'xLim',xLim,'yLim',yLim);
xlabel(xLabel);
ylabel(yLabel);

WritePlot(OutDir, [Name '_Con'], 'n', 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PLOT CNR VS THICKNESS:

% Set plot variables:

yData = ValAll(3,:);
eData = ValAll(4,:);

xLabel = ['Bone Thickness (mm)'];
yLabel = ['CNR'];

if (Cor ~= 0)
    yDataCor = yData.*FracCor;
else
    yDataCor = yData;
end

% Plot data:

errorbar(xData,yDataCor,eData,'d');

set(gca,'xLim',xLim,'yLim',[-1 7]);
xlabel(xLabel);
ylabel(yLabel);

WritePlot(OutDir, [Name '_CNR'], 'n', 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% REPORT

% Write out numbers:

Var = struct('Name', {}, 'Type', {}, 'Value', {});

Var(1).Name = {'Thickness'};
Var(1).Type = {'u16'};
Var(1).Value = {xData};

Var(2).Name = {'Contrast'};
Var(2).Type = {'f'};
Var(2).Value = {yData};

Var(3).Name = {'ConErr'};
Var(3).Type = {'f'};
Var(3).Value = {eData};

Var(3).Name = {'Fit'};
Var(3).Type = {'f'};
Var(3).Value = {FitData};

WriteVar(Var, [OutDir '/Numbers.txt']);

close;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%