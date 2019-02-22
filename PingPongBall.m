clear Data
clc
clear


setenv('Ins', 'Kinect');
setenv('Name', 'WaterTank1');
setenv('InDir', ['/Users/josmond/Data/' getenv('Ins')]);
setenv('OutDir', ['/Users/josmond/Results/Dynamite/' getenv('Ins') '/' getenv('Name')]);

Name = 'WaterTank1';

% last stationary frame from 1 = 99

%[Data] = ReadData(InDir, Name, Ins, [1 1316], [100 300 1 190]);

%PPBF = 1;
%PPBCo = [32 31];

[Data] = ReadData(Name, [], []);
LookImg(Data)

pause

[Data] = ReadData(Name, [1317 2803], [100 300 1 190]);

PPBF = 1;
PPBCo = [29 149];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Data(Data<930) = NaN;
Data(Data>1460) = NaN;

%LookImg(Data(:,:,:))

% Cut out Ping Pong Ball template from first frame

ROIData = [100 300 1 190];

% Ping Pong Ball Size

PPBS = 6;

% Image of Ping Pong Ball:

PPB = Data(PPBCo(PPBF,2)-PPBS:PPBCo(PPBF,2)+PPBS,...
    PPBCo(PPBF,1)-PPBS:PPBCo(PPBF,1)+PPBS,1);

% Ping Pong Ball Depth:

PPBDepth = nanmin(reshape(PPB(PPBS:PPBS+2,PPBS:PPBS+2),1,[]));

% Ignore data futher away than 18 mm behind ping pong ball:

DepthIgnore = 20;
PPB(PPB>(PPBDepth+DepthIgnore)) = NaN;

ROIS = 9; % ROI Size

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
    %ROI(ROI<(ROIDepth-18)) = NaN;
    %ROI(ROI>(ROIDepth+36)) = NaN;
    
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
    
    % Check resu lts:
    
    if (i > 900)
    imagesc(ROI)
    colormap('gray')
    hold on;
    plot(ROIS+1+x,ROIS+1+y,'rd','MarkerSize',10)
    hold off;
    pause
    end
    
end
  
plot(Co(:,1)*3)
ylim([90 140])
pause
plot(Co(:,2)*3)
ylim([50 450])
pause
plot(Depth)
ylim([940 1450])
