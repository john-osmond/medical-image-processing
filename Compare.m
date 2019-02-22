% PREPARATION

% Prepare workspace:

clearvars -except VarFile
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VarFile = '/Users/josmond/Results/VanOld/QC3/Numbers.txt'

% Read variables into a structured array:

[Var] = ReadVar(VarFile);

% Copy structured array elements to individual variables:

for i = 1:size(Var,2)
    if ( strcmp(char(Var(i).Type),'s') == 1 )
        eval([char(Var(i).Name{:}) '= char(Var(i).Value{:});']);
    else
        eval([char(Var(i).Name{:}) '= cell2mat(Var(i).Value);']);
    end
end

f50a = f50; 

plot(sort(Res,'ascend'), sort(RMTF,'descend'), '-b');

hold on

VarFile = '/Users/josmond/Results/LAS/QC3/Numbers.txt'

% Read variables into a structured array:

[Var] = ReadVar(VarFile);

% Copy structured array elements to individual variables:

for i = 1:size(Var,2)
    if ( strcmp(char(Var(i).Type),'s') == 1 )
        eval([char(Var(i).Name{:}) '= char(Var(i).Value{:});']);
    else
        eval([char(Var(i).Name{:}) '= cell2mat(Var(i).Value);']);
    end
end

plot(sort(Res,'ascend'), sort(RMTF,'descend'), '-r');

legend('Vanilla','LAS')

line([0 f50a f50a],[0.5 0.5 0],'LineStyle','--','Color','k');
line([0 f50 f50],[0.5 0.5 0],'LineStyle','--','Color','k');

hold off

VarFile = '/Users/josmond/Library/Matlab/Variables/LAS/QC3.txt'

% Read variables into a structured array:

[Var] = ReadVar(VarFile);

% Copy structured array elements to individual variables:

for i = 1:size(Var,2)
    if ( strcmp(char(Var(i).Type),'s') == 1 )
        eval([char(Var(i).Name{:}) '= char(Var(i).Value{:});']);
    else
        eval([char(Var(i).Name{:}) '= cell2mat(Var(i).Value);']);
    end
end

set(gca,'xLim',xLim,'yLim',yLim);
xlabel(xLabel);
ylabel(yLabel);

OutDir = ['/Users/josmond/Results/Compare/' Name];
WritePlot(OutDir, 'RMTF_comp', 'n', 'y');
