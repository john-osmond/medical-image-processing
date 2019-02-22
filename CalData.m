% Format existing plot and write out:

function [DataOut] = CalData(DataIn, FrameRate)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (FrameRate == 10)
    m = 580.5;
    c = 19.548;
    fps = 10.01875;
elseif (FrameRate == 20)
    m = 623.02;
    c = 295.87;
    fps = 21.00833;
elseif (FrameRate == 50)
    m = 844.18;
    c = 887.02;
    fps = 50;
end

DataOut = ((((DataIn*fps/10.01875)-c)/m)*580.5+19.548); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end