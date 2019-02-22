% Script to remove interferance bars from a stack of images.

function [DataOut] = RemoveBars(DataOut, Dir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Removing bars...');

% Calculate master profile:

ProfAll = nanmean(medfilt2(nanmean(DataOut,3)),Dir);

%imtool(nanmean(DataIn,3))
%plot(ProfAll)
%pause

% Requires rolling bars to work.

% Loop round frames to blank bars from data:

for i = 1:size(DataOut,3)
    
    % Calculate profile of bars:
    
    Prof = nanmean(medfilt2(DataOut(:,:,i)),Dir);
    ProfBars = Prof./ProfAll;
    
    IndLow = ProfBars < 1;
    IndHigh = ProfBars >= 1;
    
    if ( Dir == 1 )
        DataOut(:,IndLow,i) = DataOut(:,IndLow,i)./mean(Prof(IndLow));
        DataOut(:,IndHigh,i) = DataOut(:,IndHigh,i)./mean(Prof(IndHigh));
    else
        DataOut(IndLow,:,i) = DataOut(IndLow,:,i)./mean(Prof(IndLow));
        DataOut(IndHigh,:,i) = DataOut(IndHigh,:,i)./mean(Prof(IndHigh));
    end
    
    % Remove bars from data:
    
    %plot(ProfBars);
    %pause
    %imtool(DataOut(:,:,i),'InitialMagnification','adaptive');
    %pause
    %LookImg(DataOut(:,:,i))

end

disp('...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end