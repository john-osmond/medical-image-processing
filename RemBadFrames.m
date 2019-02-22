% Script to accept a data, dark and open image and apply correction

function [DataOut] = RemBadFrames(DataIn, STDMax)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Removing bad frames...']);

% Remove frames with intraframe STD above threshold:

if ( strcmpi(num2str(STDMax),'n') == 0 )
    
    j = 0;
    for i = 1:size(DataIn,3)
        FrameSTD = std2(DataIn(:,:,i));
        if (FrameSTD <= STDMax)
            j = j + 1;
            DataTemp(:,:,j) = DataIn(:,:,i);
            FrameMean(j) = mean2(DataIn(:,:,i));
        end
    end
    
else
    DataTemp = DataIn;
    FrameMean = squeeze(mean(mean(DataIn)));
end

% Remove frames with intraframe mean below threshold:

MeanThresh = max(FrameMean)/2;

j = 0;
for i = 1:size(DataTemp,3)
    if (FrameMean(i) >= MeanThresh)
        j = j + 1;
        DataOut(:,:,j) = DataTemp(:,:,i);
    end
end

disp(['...done.']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end