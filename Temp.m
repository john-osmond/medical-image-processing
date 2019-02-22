clc

x = [5.5 6.5 7.5 8.5 9.5 10.5 11.5 12.5 13.5 14.5];
y = [1 3 2 14 16 15 10 1 0 1];

Mean = sum(x.*y)/sum(y)
STD = sqrt(sum((y - Mean).^2)/sum(y))

Mean + STD

Me = (8/75)*100

% Mean Height = 5 ft 10 = 70 in +- 3
% My height = 6 ft 3 = 75 in (1.67 STDs above mean = 96%)

% Mean val = 9.7 +- 2.8

% My length = 8
% My val = 10.7 (0.36 STDs above mean 66%)

% Conclusion: I am in top 4% of height and top 34% for my height.

% Average length = 5.5 or 7.3 in for my height.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear Data
clc
clear

Ins = 'Kinect';
InDir = '/Users/josmond/Data/Kinect'
Name = 'WaterTank1';

% last stationary frame from 1 = 99

[Data] = ReadData(InDir, Name, Ins, [1 1316], [100 300 1 190]);
Data(Data<930) = NaN;
Data(Data>1450) = NaN;

%LookImg(Data(:,:,:))

% Cut out Ping Pong Ball template from first frame

ROIData = [100 300 1 190];

PPBF = 1;
PPBCo = [32 31];
PPBS = 6;

PPB = Data(PPBCo(PPBF,2)-PPBS:PPBCo(PPBF,2)+PPBS,...
    PPBCo(PPBF,1)-PPBS:PPBCo(PPBF,1)+PPBS,1);

PPBDepth = nanmin(reshape(PPB(PPBS:PPBS+2,PPBS:PPBS+2),1,[]));
PPB(PPB>(PPBDepth+18)) = NaN;

ROIS = 12;

for i = 1:size(Data,3)
    
    % Cut out region of interest:
    
    if (i == 1)
        ROICo = PPBCo;
        ROIDepth = PPBDepth;
    else
        ROICo = Co(i-1,:);
        ROIDepth = Depth(i-1);
    end
    
    ROI = Data(ROICo(2)-ROIS:ROICo(2)+ROIS,ROICo(1)-ROIS:ROICo(1)+ROIS,i);
    %ROI(ROI<(Depth-100)) = NaN;
    %ROI(ROI>(ROIDepth+18)) = NaN;
    
    % Find offset in x and y:
    
    [x,y] = MatchImg(ROI,PPB,'y');
    Co(i,:) = [ROICo(1)+x ROICo(2)+y];
    if (i > 1 && pdist([Co(i,:); Co(i-1,:)]) > 6) Co(i,:) = Co(i-1,:); end
    
    % Calculate Depth
    
    ROISmall = Data(Co(i,2)-2:Co(i,2)+2,Co(i,1)-2:Co(i,1)+2,i);
    Depth(i) = nanmin(reshape(ROISmall,1,[]));
    %Depth(i) = nanmedian(reshape(ROISmall,1,[]));
    %Depth(i) = nanmean(reshape(ROISmall,1,[]));
    
    if (i > 1 && abs(Depth(i)-Depth(i-1)) > 18) Depth(i) = Depth(i-1); end
    
    disp(['Frame = ' num2str(i) ', x = ' num2str(Co(i,1))...
        ', y = ' num2str(Co(i,1)) ', Depth = ' num2str(Depth(i))])
    
    % Check results:
    
    %if (i > 1000)
    imagesc(ROI)
    colormap('gray')
    hold on;
    plot(ROIS+1+x,ROIS+1+y,'rd','MarkerSize',10)
    hold off;
    pause
    %end
    
end
  
plot(Co(:,1)*3)
ylim([90 140])
pause
plot(Co(:,2)*3)
ylim([50 450])
pause
plot(Depth)
ylim([940 1450])