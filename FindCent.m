% Format existing plot and write out:

function [Cent SD] = FindCent(Data, Invert)

% Scale: 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% display matrix to screen
% x is is left to right
% y is top to bottom.

% If necessary invert data:

if strcmpi(Invert, 'y') == 1
    DataInv = nanmax(reshape(Data,1,[]))-Data;
else
    DataInv = Data;
end

% Calculate mean:

for i = 1:ndims(DataInv)
    Co = nansum(DataInv,i);
    for j = 1:numel(Co); Co(j) = j; end;
    DataCo = nansum(DataInv,i).*Co;
    Cent(i) = nansum(DataCo)/nansum(reshape(DataInv,1,[]));
end

% Calculate standard deviation:

for i = 1:ndims(Data)
    
    Co = nansum(Data,i);
    for j = 1:numel(Co); Co(j) = j; end;
    Dev = (Co-Cent(i)).^2;
    DataCo = nansum(Data,i).*Dev;
    SD(i) = sqrt(nansum(DataCo)/nansum(reshape(Data,1,[])));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end