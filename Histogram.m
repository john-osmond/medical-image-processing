% Format existing plot and write out:

function [HistX, HistY] = Histogram(Data, XBins, Name, XLabel, YLabel, Legend)

% Calculate multiple histograms and plot.  First dimension of Data must
% define histogram number, second dimension is 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:size(Data,1)
    
    display(['Creating histogram ' num2str(i) ' of ' num2str(size(Data,1)) '...']);
    
    % Calculate plot valies:
    
    if numel(XBins) > 0
        [HistY(i,:), HistX(i,:)] = hist(Data(i,:), XBins);
    else
        [HistY(i,:), HistX(i,:)] = hist(Data(i,:));
    end
    
    DataNumEl = sum(isfinite(reshape(Data(i,:),1,[])));
    HistY(i,:) = (HistY(i,:)/DataNumEl)*100;
  
end

WriteHist(HistX, HistY, Name, XLabel, YLabel, Legend);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end