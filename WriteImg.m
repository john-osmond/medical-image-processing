% Format existing plot and write out:

function [] = WriteImg(Img, Name, Lims, Scale, ColourBar)

disp('Starting WriteImg...');

if CountEnv({'OutDir'}) < 1;
    disp('Missing environment variables');
    return
end

% Scale: 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if numel(Lims) == 0
    Lims = prctile(reshape(Img, 1, []), [1 99]);
end

% Plot image:

imagesc(Img, Lims);
axis image;
colormap('bone');
set(gca,'xtick',[],'ytick',[]);

% If required add title:

%if numel(Name) > 0; title(Name); end

% If required draw scale line on image:

if numel(Scale) > 0
    mm = 100*Scale;
    line([50 150], [75 75], 'Color', 'r')
    text(56, 50, [num2str(mm) ' mm'], 'Color', 'r')
end

% Add colorbar:

if strcmpi(ColourBar,'y') == 1
    colorbar
end

% Write image to disk:

WritePlot([Name(Name~=' ') 'Img'], [], 'n');
close;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('...done.');

end