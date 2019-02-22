% Format existing plot and write out:

function [] = WritePlot(Name, FontSize, Markers)

disp('Starting WritePlot...');

if CountEnv({'OutDir'}) < 1;
    disp('Missing environment variables');
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set plot values:

AspectRatio = [0.7 0.7];
Format1={'eps2' 'eps'; 'epsc2' 'eps'};
Format2={'epsc2' 'eps'; 'pdf' 'pdf'};

if FontSize
else
    FontSize = [12 14];
end

LineWidth = [1 1.6];
Marker = {'d' 'd'};
MarkerEdgeColor = {'b' 'b'};
MarkerFaceColor = {'w' 'w'};
MarkerSize = [8 10];
%PaperSize = [148 210];
%PaperUnits = 'mm';
Type = {'Paper' 'Slide'};

NameNoSpace = Name(Name~=' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create out directory if necessary:

if (exist(getenv('OutDir'),'dir') ~= 7)
    mkdir(getenv('OutDir'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:2
    
    % Set aspect ratio:
        
    pbaspect([1 AspectRatio(i) 1]);
    
    % Find objects with properties and reassign values:
    
    set(findobj('-property','FontSize'),'FontSize',FontSize(i));
    set(findobj('-property','LineWidth'),'LineWidth',LineWidth(i));
    
    % Format markers:
    
    if ( strcmpi(Markers,'y') == 1 )
        
        set(findobj('-property','Marker'),'Marker',char(Marker(i)));
        set(findobj('-property','MarkerEdgeColor'),...
            'MarkerEdgeColor',char(MarkerEdgeColor(i)));
        set(findobj('-property','MarkerFaceColor'),...
            'MarkerFaceColor',char(MarkerFaceColor(i)));
        set(findobj('-property','MarkerSize'),'MarkerSize',MarkerSize(i));
    
    end
    
    %set(findobj('-property','PaperSize'),'PaperSize',PaperSize);
    %set(findobj('-property','PaperUnits'),'PaperUnits',PaperUnits);

    % This shouldn't be necessary but label size seems to lag the rest!:
    
    set(get(gca,'Title'),'FontSize',FontSize(i));
    set(get(gca,'XLabel'),'FontSize',FontSize(i));
    set(get(gca,'YLabel'),'FontSize',FontSize(i));
    
    % Write plots:
    
    if (i==1)
        for j = 1:size(Format1,1)
            print(['-d' char(Format1(j,1))],...
                [getenv('OutDir') '/' NameNoSpace '_' char(Type(i)) '_' ...
                char(Format1(j,1)) '.' char(Format1(j,2))]);
        end
    elseif (i==2)
        for j = 1:size(Format2,1)
            print(['-d' char(Format2(j,1))],...
                [getenv('OutDir') '/' NameNoSpace '_' char(Type(i)) '_' ...
                char(Format2(j,1)) '.' char(Format2(j,2))]);
        end
    end
    
end

close;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('...done.');

end