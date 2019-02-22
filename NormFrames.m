% Script to accept a data, dark and open image and apply correction

function [DataOut] = NormFrames(DataIn)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Normalising frames...');

MedAll = nanmedian(reshape(DataIn,1,[]));

for i = 1:size(DataIn,3)
    Scale = MedAll/nanmedian(reshape(DataIn(:,:,i),1,[]));
    DataOut(:,:,i) = DataIn(:,:,i)*Scale;
end

disp('...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end