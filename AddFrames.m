% Script to add 

function [DataOut] = AddFrames(DataIn, Num)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Adding frames...');

for i = 1:floor(size(DataIn,3)/Num)
    FrameLo = (i*Num)-Num+1;
    FrameHi = (i*Num);
    DataOut(:,:,i) = nanmean(DataIn(:,:,FrameLo:FrameHi),3)*Num;
end

disp('...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end