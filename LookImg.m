% Script to step through a 3D image stack and display each one
% individually.

% Data: 3D array containing a stack of images.

function [] = LookImg(Data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:size(Data,3)
    
    display(['Frame ' num2str(i) ' press any key...']);
    
    subplot(2,2,[1 3]);
    imagesc(Data(:,:,i))
    colormap('gray')
    axis image
    set(gca,'xtick',[],'ytick',[]);
    xlabel('X');
    ylabel('Y');
    title(['M: ' num2str(round(nanmean(reshape(Data(:,:,i),1,[])))) ...
        ', STD: ' num2str(round(nanstd(reshape(Data(:,:,i),1,[]))))])
    
    subplot(2,2,2);
    plot(nanmean(Data(:,:,i),1));
    xlim([1 size(Data,2)]);
    set(gca,'xtick',[]);
    xlabel('X');
    
    subplot(2,2,4);
    plot(fliplr(nanmean(Data(:,:,i),2)));
    xlim([1 size(Data,1)]);
    set(gca,'xtick',[]);
    xlabel('Y');
    
    pause
    
end

close;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end