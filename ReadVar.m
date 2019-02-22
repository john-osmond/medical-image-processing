% Read variables from ASCII text file and export in a structured array.

function [Var] = ReadVar(File)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Reading variables...');

% Count number of lines in variable file:

FID = fopen(File, 'r');
All = textscan(FID, '%s', 'delimiter', '\n');
NoLines = length(All{1});

% Allocate structured variable array:

Var = struct('Name', {}, 'Type', {}, 'Value', {});

% Move to beginning of variable file:

fseek(FID, 0, 'bof');

% Loop round each line:

for Line = 1:NoLines
    
    % Read variable formatting information:
    
    Format = textscan(FID, '%s %s %u16 %u16', 1);
    
    % Read each value into element of variable array:
    
    if ( Format{3} == 1 && Format{4} == 1 )
        VarVal = textscan(FID, char(['%*' Format{2}]), 'delimiter', '\n');
    else
        for Element = 1:Format{3}*Format{4}
            VarVal(Element) = textscan(FID, char(['%*' Format{2}]), 1);
        end
    end
    
    VarVal = permute(reshape(VarVal, [Format{3} Format{4}]),[2 1]);
    
    % Copy variable name and array into seperate elements of cell array:
    
    Var(Line).Name = Format{1};
    Var(Line).Type = Format{2};
    Var(Line).Value = VarVal;
    clear Format VarVal;
    
end

% Close variable file:

fclose(FID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('...done.');
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end