% Format existing plot and write out:

function [DataOut] = SlideWin(DataIn, KernSize)

disp('Starting SlideWin...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
DataOut = DataIn;

for i = 1:length(DataOut)
    
    LoEl = i - floor((KernSize-1)/2);
    HiEl = i + ceil((KernSize-1)/2);
    
    if LoEl < 1; LoEl = 1; end
    if HiEl > length(DataOut); HiEl = length(DataOut); end
    
    DataOut(i) = nanmean(DataIn(LoEl:HiEl));
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('...done.');

end