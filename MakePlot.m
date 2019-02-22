function [] = makeplot(x, y, log, xname, yname, plotname)

% Set variables:

fontsize = 14;
linewidth = 1.4;
markersize = 10;

set(0,'DefaultLineLineWidth',linewidth,...
    'DefaultTextFontSize',fontsize,...
    'DefaultAxesFontSize',fontsize);

% Draw plot:

if ( strcmp(log,'x') == 1 )
    
    semilogx(x,y,'-b','MarkerEdgeColor','k','MarkerFaceColor','r',...
    'MarkerSize',markersize);

elseif ( strcmp(log,'y') == 1 )
    
    semilogy(x,y,'-b','MarkerEdgeColor','k','MarkerFaceColor','r',...
    'MarkerSize',markersize);
        
elseif ( strcmp(log,'xy') == 1 )
    
    loglog(x,y,'-b','MarkerEdgeColor','k','MarkerFaceColor','r',...
    'MarkerSize',markersize);

else
  
    plot(x,y,'-bx','MarkerEdgeColor','k','MarkerFaceColor','r',...
    'MarkerSize',markersize);
    
end

set(gca,'Linewidth',linewidth);

% Draw line at zero:

%hline = refline(0,0);
%set(hline,'LineStyle','--','Color','k');

% Label axes:

xlabel(xname);
ylabel(yname);

% Print to file and close plot:

print('-depsc2','-tiff',[plotname '_col.eps']);
print('-deps2',[plotname '_bw.eps']);

end