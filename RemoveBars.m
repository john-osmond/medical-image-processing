% Script to remove interferance bars from a stack of images.

function [DataOut, DataBlank] = RemoveBars(DataIn, Dir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Dir = 1;
%DataIn = Flood;

disp('Removing bars...');

% Initiate blanked and binary images:

DataBlank = DataIn;

% Calculate master profile:

ProfAll = nanmean(medfilt2(nanmean(DataIn,3)),Dir);

%imtool(nanmean(DataIn,3))
%plot(ProfAll)
%pause

% Requires rolling bars to work.

% Loop round frames to blank bars from data:

for i = 1:size(DataIn,3)
    
    % Calculate profile of bars:
    
    Prof = nanmean(medfilt2(DataIn(:,:,i)),Dir);
    ProfBars = Prof./ProfAll;
    
    % Decide wether bars are positive or negative and define indices:
    
    Thresh = nanmean([min(ProfBars) max(ProfBars)]);
    if ( Thresh >= 1 )
        Ind = ProfBars >= Thresh;
    elseif ( Thresh < 1 )
        Ind = ProfBars <= Thresh;
    end
    
    % Remove bars from data:
    
    if ( Dir == 1 )
        DataBlank(:,Ind,i) = NaN;
    else
        DataBlank(Ind,:,i) = NaN;
    end
    
    %plot(ProfBars);
    %pause
    %imtool(DataIn(:,:,i),'InitialMagnification','adaptive');
    %pause
    %imtool(DataBlank(:,:,i),'InitialMagnification','adaptive');
    %pause
    %LookImg(DataBlank(:,:,i))

end

% Recalculate master profile from data with bars blanked out:

ProfAll = nanmean(medfilt2(nanmean(DataBlank,3)),Dir);

% Loop round all frames:

for i = 1:size(DataIn,3)
    
    i
    
    % Calculate profile of bars:
    
    Prof = nanmean(medfilt2(DataIn(:,:,i)),Dir);
    ProfBars = Prof./ProfAll;
    
    %plot(ProfBars);
    %pause
    %LookImg(DataIn(:,:,i));
    
    % Calculate image of bars and remove from data image:
    
    if ( Dir == 1 )
        ImgBars = repmat(ProfBars,size(DataIn,1),1);
    else
        ImgBars = repmat(ProfBars,1,size(DataIn,2));
    end
    
    DataOut(:,:,i) = DataIn(:,:,i)./ImgBars;
    
    %Prof = nanmean(medfilt2(DataOut(:,:,i)),Dir);
    %plot(ProfBars);
    %pause
    %LookImg(ImgBars(:,:,i));
    
    
end

disp('...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end