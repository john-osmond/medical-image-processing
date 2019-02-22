% Format existing plot and write out:

function [DataOut] = RemoveNan(DataIn)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DataOut = DataIn;

% Loop round frame, then x and y:

for i = 1:size(DataIn,3)
for j = 1:size(DataIn,1)
for k = 1:size(DataIn,2)
if (isnan(DataIn(j,k,i)) == 1)

% Set initial variables:
    
Size = 0;
Val = NaN;

% Iteratively increase size of median kernel until median valus is not nan:

while isnan(Val) == 1
    
    Size = Size + 1;
    
    % Set x and y variables and constrain within image size:
    
    if (j <= Size) jLo = 1; else jLo = j-Size; end
    if (j > size(DataIn,1)-Size) jHi = size(DataIn,1); else jHi = j+Size; end
    if (k <= Size) kLo = 1; else kLo = k-Size; end
    if (k > size(DataIn,2)-Size) kHi = size(DataIn,2); else kHi = k+Size; end
    
    % Calculate median value and write to output image:
    
    Val = nanmedian(reshape(DataIn(jLo:jHi,kLo:kHi,i),1,[]));
    DataOut(j,k,i) = Val;
end
                
end
end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end