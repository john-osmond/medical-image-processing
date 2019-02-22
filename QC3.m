% INTRODUCTION

% Script to process image data of QC3 phantom.

% Box co-ordinates must be entered from left to right (increasing x).

% VarFile = '/Users/josmond/Library/Matlab/Variables/Vanilla/QC3.txt';

function [] = QC3(VarFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clearvars -except VarFile
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VarFile = '/Users/josmond/Library/Matlab/Variables/Vanilla/QC3.txt'

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

BoxCo = double(BoxCo);

% Calculate rotational properties of phantom (Incresing X = Increasing XY).

PhanSize = sort([74 124]);
PhanAng = 2*atan(PhanSize(1)/PhanSize(2));

%%%%%%

if ( BoxCo(1,2) > BoxCo(2,2) )
    Orient = -1;
else
    Orient = 1;
end

OffAng = Orient * [0 PhanAng pi pi+PhanAng];

% Calculate co-ordinates of centre of box:

CenCo = mean(BoxCo);

% Calculate co-ordinates of four corners relative to centre of box:

XY1 = BoxCo(1,:) - CenCo;
[TR1(1),TR1(2)] = cart2pol(XY1(1),XY1(2));

TR2 = [TR1(1)+OffAng(2) TR1(2)];
[XY2(1),XY2(2)] = pol2cart(TR2(1),TR2(2));

TR3 = [TR1(1)+OffAng(3) TR1(2)];
[XY3(1),XY3(2)] = pol2cart(TR3(1),TR3(2));

TR4 = [TR1(1)+OffAng(4) TR1(2)];
[XY4(1),XY4(2)] = pol2cart(TR4(1),TR4(2));

% Calculate same co-ordinates relative to corner of image:

BoxCoAll = [ XY1 + CenCo; XY2 + CenCo; XY3 + CenCo; XY4 + CenCo];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NumFrames = diff(Frames)+1;

[Sorted Ind] = sort(BoxCoAll(:,1));
BoxCoSort = BoxCoAll(Ind,:);

% Calculate size of box:

BoxDist = pdist(BoxCoSort);
BoxSizeRot(1) = mean([diff(BoxCoSort([1 3],1)) diff(BoxCoSort([2 4],1))]);
BoxSizeRot(2) = mean([diff(BoxCoSort(1:2,1)) diff(BoxCoSort(3:4,1))]);
BoxSize = [mean(BoxDist([2 5])) mean(BoxDist([1 6]))];
BoxAng = TR1(1)+(Orient*(pi+(PhanAng/2)));

%if ( BoxCoAll(2,2) > BoxCoAll(1,2))
%    BoxAng = BoxAng * -1;
%end

% Calculate width of border for whole image:

Bord = max(BoxSize)/10;

% Calculate co-ordinates of cropped image:

CropCo = round([min(BoxCoSort(:,2))-Bord max(BoxCoSort(:,2))+Bord ...
    min(BoxCoSort(:,1))-Bord max(BoxCoSort(:,1))+Bord]);

% Crop sorted co-ordinates:

BoxCoSort(:,1) = BoxCoSort(:,1) - CropCo(3);
BoxCoSort(:,2) = BoxCoSort(:,2) - CropCo(1);
BoxCoCen = mean(BoxCoSort);

% Calculate co-ordinates of each end of line through regions:

LineCo = [mean(BoxCoSort(1:2,:)) ; mean(BoxCoSort(3:4,:))];
RegSize = diff(LineCo)/5;

% Set line spaceing:

MinInd = find(Res == min(Res));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% READ IMAGES

% Read data:

[DataImg, DataSD] = StatData([InDir '/' DataName], Ins, Frames, GroupSize);
[DarkImg, DarkSD] = StatData([InDir '/' DarkName], Ins, Frames, GroupSize);
[OpenImg, OpenSD] = StatData([InDir '/' OpenName], Ins, Frames, GroupSize);
    
% Correct data:

[ImgCor, SDCor] = CorData(DataImg, DataSD, DarkImg, DarkSD, OpenImg, OpenSD);

% Constrain crop co-ordinates to be within image size:

ImgSize = size(ImgCor);

if ( CropCo(1) < 1 )
    CropCo(1) = 1;
end

if ( CropCo(2) > ImgSize(1) )
    CropCo(2) = ImgSize(1);
end

if ( CropCo(3) < 1 )
    CropCo(3) = 1;
end

if ( CropCo(4) > ImgSize(2) )
    CropCo(4) = ImgSize(2);
end

% Crop data:

ImgCrop = medfilt2(ImgCor(CropCo(1):CropCo(2),CropCo(3):CropCo(4)), [3 3]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot image:

imagesc(ImgCrop, [iLim]);
colormap('gray');
axis image;

WritePlot(OutDir, [Name '_Img'], 'n', 'n');

% Draw box on figure:

BoxX = [(BoxCoCen(1)-BoxSize(1)/2) (BoxCoCen(1) - BoxSize(1)/2)...
    (BoxCoCen(1)+BoxSize(1)/2) (BoxCoCen(1) + BoxSize(1)/2)];
BoxY = [(BoxCoCen(2)-BoxSize(2)/2) (BoxCoCen(2)+BoxSize(2)/2)...
    (BoxCoCen(2) + BoxSize(2)/2) (BoxCoCen(2) - BoxSize(2)/2)];

Box = patch(BoxX,BoxY,[0.95 1.0 0.95],...
    'EdgeColor','r','FaceColor','None');
rotate(Box,[0 0 1],BoxAng*(180/pi));

disp('Co-ordinates of left and right-most corners of phantom:');
BoxCo
disp('Check co-ordinates then press any key to continue...')
pause;

xlabel('X');
ylabel('Y');

% Loop round all regions:

for RegNo = 1:5
    
    % Define region of interest:
    
    RegCo(1:2) = round([bsxfun(@plus,LineCo(1,:),(RegNo-1).*RegSize)]);
    RegCo(3:4) = round([bsxfun(@plus,LineCo(1,:),RegNo.*RegSize)]);
    
    RegCo([2 4]) = sort(RegCo([2 4]));
    
    % Extract region:
    
    Reg = ImgCrop(RegCo(1):RegCo(3),RegCo(2):RegCo(4));
    %SDReg = SDCrop(RegCo(1):RegCo(3),RegCo(2):RegCo(4));
    
    % Draw region on image:
    
    rectangle('Position',[RegCo(1),RegCo(2),abs(RegSize(1)),abs(RegSize(2))],...
            'EdgeColor','r');
        
    IndFin = isfinite(Reg);
    NumFin = sum(sum(IndFin));
        
    % Calculate variances on both images and subtracted image:
    
    Mod(RegNo) = (std2(Reg(IndFin))).^2;
        
end

WritePlot(OutDir, [Name '_ImgReg'], 'n', 'y');

% Calculate final values of rmtf and f50:

Res

RMTF = sqrt(Mod/Mod(MinInd))

f50 = interp1(RMTF,Res,0.5,'linear')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% REPORT

% Write out numbers:

Var = struct('Name', {}, 'Type', {}, 'Value', {});

Var(1).Name = {'Res'};
Var(1).Type = {'f'};
Var(1).Value = {Res};

Var(2).Name = {'RMTF'};
Var(2).Type = {'f'};
Var(2).Value = {RMTF};

Var(3).Name = {'f50'};
Var(3).Type = {'f'};
Var(3).Value = {f50};

WriteVar(Var, [OutDir '/Numbers.txt']);

% Plot results:

Rak = [1 0.686 0.586 0.236 0.05];
plot(sort(Res,'ascend'), sort(RMTF,'descend'));
line([0 f50 f50],[0.5 0.5 0],'LineStyle','--','Color','k');
text(f50+0.02,0.08,['f_{50} = ' num2str(f50,2)])

set(gca,'xLim',xLim,'yLim',yLim);
xlabel(xLabel);
ylabel(yLabel);

WritePlot(OutDir, 'RMTF', 'n', 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

