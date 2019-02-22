% Script to remove interferance bars from a stack of images.

function [] = TimeSeries(DataIn, OutDir, Name, YLo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Examining time series...');

if (strcmpi(YLo,'n')~=1);
    DataTemp = zeros([1350 size(DataIn,2) size(DataIn,3)]) * NaN;
    DataTemp(YLo:YLo+size(DataIn,1)-1,:,:) = DataIn;
else
    DataTemp = DataIn;
end

% Plot frame mean and std vs time:

for i = 1:size(DataIn,3)
    FrameMean(i) = nanmean(reshape(DataIn(:,:,i),1,[]));
    FrameSTD(i) = nanstd(reshape(DataIn(:,:,i),1,[]));
    
    % Loop around sub-columns
    
    for j = 1:10
        yLo = 2+(135*(j-1));
        yHi = 135+(135*(j-1));
        ColumnMean(i,j) = nanmean(reshape(DataTemp(yLo:yHi,:,i),1,[]));
        ColumnSTD(i,j) = nanstd(reshape(DataTemp(yLo:yHi,:,i),1,[]));
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GRAPHICAL RESULTS

% Plot frame mean vs time:

plot(FrameMean);
xlim([0 numel(FrameMean)]);
xlabel(gca,'Time (s)');
ylabel(gca,'Signal Mean (DN)');
WritePlot(OutDir, ['FrameMeanTime' Name], [], 'n');

% Plot frame std vs time:

plot(FrameSTD);
xlim([0 numel(FrameSTD)]);
xlabel(gca,'Time (s)');
ylabel(gca,'Signal STD (DN)');
WritePlot(OutDir, ['FrameSTDTime' Name], [], 'n');

% Plot column mean vs time:

Line = {'-r' '--r' '-g' '--g' '-b' '--b' '-m' '--m' '-k' '--k'};
for j = 1:10; plot(ColumnMean(:,j),char(Line(j))); hold on; end;
hold off;
xlim([0 numel(FrameMean)]);
%ylim([150 180]);
xlabel(gca,'Frame');
ylabel(gca,'Subcolumn Mean (DN)');
WritePlot(OutDir, ['SubcolMeanTime' Name], [], 'n');

% Plot column std vs time:

Line = {'-r' '--r' '-g' '--g' '-b' '--b' '-m' '--m' '-k' '--k'};
for j = 1:10; plot(ColumnSTD(:,j),char(Line(j))); hold on; end;
hold off;
xlim([0 numel(FrameSTD)]);
%ylim([150 180]);
xlabel(gca,'Frame');
ylabel(gca,'Subcolumn STD (DN)');
WritePlot(OutDir, ['SubcolSTDTime' Name], [], 'n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NUMERICAL RESULTS

% Calculate interframe mean and std:

FrameSignal = nanmean(FrameMean);
FrameNoise = nanstd(FrameMean);
FrameSN = FrameSignal/FrameNoise;

% Display interframe mean and std:

display(['Frame S: ' num2str(round(FrameSignal)) ...
    ', N: ' num2str(round(FrameNoise)) ...
    ', S/N: ' num2str(round(FrameSN))]);

disp('...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end