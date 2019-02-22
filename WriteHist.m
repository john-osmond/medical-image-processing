% Format existing plot and write out:

function [] = WriteHist(HistX, HistY, Name, XLabel, YLabel, Legend)

% Calculate multiple histograms and plot.  First dimension of Data must
% define histogram number, second dimension is 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:size(HistY,1)
    
    display(['Creating histogram ' num2str(i) ' of ' num2str(size(HistY,1)) '...']);
    
    BinSize = mean(diff(HistX(i,:)));
    %DataNumEl = sum(isfinite(Datai));
    %HistY = (HistY/DataNumEl)*100;
    
    % Create single line version of histogram:
    
    for j = 1:size(HistY,2)
        if j == 1
            LineX(i,(j*2)-1) = HistX(i,j)-(BinSize/2);
            LineY(i,(j*2)-1) = 0;
        elseif j == size(HistY,2)
            LineX(i,(j*2)+2) = HistX(i,j)+(BinSize/2);
            LineY(i,(j*2)+2) = 0;
        end
        for k=1:2
            if k == 1
                LineX(i,(j*2)-1+k) = HistX(i,j)-(BinSize/2);
            else
                LineX(i,(j*2)-1+k) = HistX(i,j)+(BinSize/2);
            end
            LineY(i,(j*2)-1+k) = HistY(i,j);
        end
    end
   
end

% Display plot:

%Line = {'-b' '--r' '-.g' ':k'};
Line = {'-b' '--r' '-.g' '-k' '--m' '-.c'};

for i = 1:size(LineY,1)
    plot(LineX(i,:), LineY(i,:), char(Line(i-(numel(Line)*(ceil(i/numel(Line))-1)))));
    hold on;
end

hold off;

% Format plot:

N = 10;
XLim = [min(reshape(LineX,1,[]))+BinSize/2 max(reshape(LineX,1,[]))-BinSize/2];
YLim = [0 N*ceil(max(reshape(LineY,1,[]))/N)];

xlim(XLim);
ylim(YLim);

%if numel(Name) > 0; title(Name); end
if numel(XLabel) > 0; xlabel(XLabel); else xlabel('Value'); end
if numel(YLabel) > 0; ylabel(YLabel); else ylabel('Number of Values (%)'); end

% Add Legend

if numel(Legend) > 0
    legend(Legend{1:end-1}, 'Location', Legend{end})
end

% Write plot to disk:

WritePlot([Name(Name~=' ') 'Hist'], [], 'n');
close;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end