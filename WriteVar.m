% Read variables from ASCII text file and export in a structured array.

function [] = WriteVar(Var, File)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Writing variables...');

% Calculate number of lines in variable:

NoLines = size(Var,2);

% Open file:

FID = fopen(File,'wt');

for Line = 1:NoLines
    
    % Calculate number of elements in cell:
    
    ElSize = size(Var(Line).Value{:});
    
    % Set number of tabs based on length of name:
    
    if ( length(Var(Line).Name{:}) < 7 )
        Tab = '\t \t';
    else
        Tab = '\t';
    end
    
    % Convert value from cell array:
    
    if (strcmp(char(Var(Line).Type),'s') == 1)
        Val = char(Var(Line).Value{:});
    else
        Val = cell2mat(Var(Line).Value);
    end
    
    % Print line:
    
    fprintf(FID,['%s ' Tab ' %s \t %s \t %s \t %s\n'],...
        Var(Line).Name{:},...
        num2str(Var(Line).Type{:}),...
        num2str(ElSize(1)),...
        num2str(ElSize(2)),...
        num2str(Val)...
        );

end

% Close file:

fclose(FID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('done.');
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end