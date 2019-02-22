% Script to

function [DataOut, DataFrame, NoSpikeInd] = RemoveSpikes(DataIn, YLo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Removing spiking subcolumns...');

% Increase image size to properly place subcolumns:

if YLo;
    DataTemp = zeros([1350 size(DataIn,2) size(DataIn,3)]) * NaN;
    DataTemp(YLo:YLo+size(DataIn,1)-1,:,:) = DataIn;
else
    DataTemp = DataIn;
end

% Loop round frames then columns and calculate column std/l

for i = 1:size(DataTemp,3)
    
    for j = 1:10
        yLo = 2+(135*(j-1));
        yHi = 135+(135*(j-1));
        ColumnSTD(i,j) = nanstd(reshape(DataTemp(yLo:yHi,:,i),1,[]));
    end
    
end

% Calculate mean std:

SpikeInd = ColumnSTD(:,1) > nanmean(ColumnSTD(:,1),1);
NoSpikeInd = ColumnSTD(:,1) <= nanmean(ColumnSTD(:,1),1);

% Blank spikey sub-columns:

%for j = 7:2:9

for j = 1:2:9
    yLo = 2+(135*(j-1));
    yHi = 135+(135*(j-1));
    DataTemp(yLo:yHi,:,SpikeInd) = NaN;
end

if YLo;
    DataOut = DataTemp(YLo:YLo+size(DataIn,1)-1,:,:);
else
    DataOut = DataTemp;
end

% Create dataset with frames blanked:

%DataFrame = DataOut;
%DataFrame(:,:,SpikeInd) = NaN;
DataFrame = DataOut(:,:,NoSpikeInd);

disp('...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end